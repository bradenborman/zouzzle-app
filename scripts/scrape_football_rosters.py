"""
Scrape Mizzou football rosters from mutigers.com.
Dumps each season's roster into data/football_rosters/ as individual JSON files.
Then combines into a single deduplicated player database.

Usage:
    python3 scripts/scrape_football_rosters.py

Note: 10s delays between requests to be respectful.
"""

import json
import time
import requests
from bs4 import BeautifulSoup
from pathlib import Path

BASE_URL = "https://mutigers.com/sports/football/roster"
OUTPUT_DIR = Path(__file__).parent.parent / "data" / "football_rosters"
COMBINED_OUTPUT = Path(__file__).parent.parent / "data" / "football_player_database.json"

# Seasons to scrape
START_YEAR = 2000
END_YEAR = 2025

HEADERS = {
    "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126.0.0.0 Safari/537.36",
    "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9",
    "Accept-Language": "en-US,en;q=0.9",
}


def parse_height(height_str):
    """Convert height string like 6' 2'' to total inches."""
    if not height_str:
        return 0
    import re
    match = re.match(r"(\d+)'\s*(\d+)", height_str)
    if match:
        return int(match.group(1)) * 12 + int(match.group(2))
    return 0


def scrape_roster(year):
    """Scrape a single season's football roster from mutigers.com."""
    url = f"{BASE_URL}/{year}"
    print(f"  {year} ... ", end="", flush=True)

    try:
        resp = requests.get(url, headers=HEADERS, timeout=15)
    except requests.RequestException as e:
        print(f"❌ {e}")
        return []

    if resp.status_code != 200:
        print(f"❌ HTTP {resp.status_code}")
        return []

    soup = BeautifulSoup(resp.text, "html.parser")

    # Find the first table with roster data
    tables = soup.find_all("table", class_="w-full")
    if not tables:
        print("❌ no table found")
        return []

    roster_table = tables[0]
    rows = roster_table.find_all("tr")

    if len(rows) < 2:
        print("❌ no data rows")
        return []

    # Parse header to get column indices
    header_cells = [c.get_text(strip=True).lower() for c in rows[0].find_all(["th", "td"])]

    players = []
    for row in rows[1:]:
        cells = row.find_all(["th", "td"])
        if len(cells) < 6:
            continue

        values = [c.get_text(strip=True) for c in cells]

        # Map based on typical column order: No, Name, Pos, Ht, Wt, Year, Hometown
        try:
            jersey_str = values[0] if len(values) > 0 else ""
            name = values[1] if len(values) > 1 else ""
            position = values[2] if len(values) > 2 else ""
            height_str = values[3] if len(values) > 3 else ""
            weight_str = values[4] if len(values) > 4 else ""
            player_class = values[5] if len(values) > 5 else ""
            hometown = values[6] if len(values) > 6 else ""
        except IndexError:
            continue

        if not name:
            continue

        try:
            jersey_num = int(jersey_str)
        except (ValueError, TypeError):
            jersey_num = 0

        try:
            weight_num = int(weight_str)
        except (ValueError, TypeError):
            weight_num = 0

        players.append({
            "name": name,
            "jersey": jersey_num,
            "class": player_class,
            "position": position,
            "height": parse_height(height_str),
            "height_str": height_str,
            "weight": weight_num,
            "hometown": hometown,
            "season": year,
        })

    print(f"✓ {len(players)} players")
    return players


def main():
    print("🏈 Scraping Mizzou Football Rosters (mutigers.com)")
    print(f"   Seasons: {START_YEAR}-{END_YEAR}")
    print(f"   Output: {OUTPUT_DIR}/")
    print()

    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

    all_players = {}

    for year in range(START_YEAR, END_YEAR + 1):
        players = scrape_roster(year)

        # Save individual season file
        if players:
            season_file = OUTPUT_DIR / f"{year}.json"
            with open(season_file, "w") as f:
                json.dump({"season": year, "players": players}, f, indent=2)

        # Merge into combined database
        for p in players:
            name = p["name"]
            if name not in all_players:
                all_players[name] = {
                    "fullName": name,
                    "position": p["position"],
                    "height": p["height"],
                    "height_str": p["height_str"],
                    "weight": p["weight"],
                    "jerseyNumber": p["jersey"],
                    "hometown": p["hometown"],
                    "startYear": year,
                    "endYear": year,
                    "seasons": [year],
                }
            else:
                existing = all_players[name]
                existing["endYear"] = max(existing["endYear"], year)
                existing["startYear"] = min(existing["startYear"], year)
                if year not in existing["seasons"]:
                    existing["seasons"].append(year)
                if p["height"] > 0:
                    existing["height"] = p["height"]
                    existing["height_str"] = p["height_str"]
                if p["weight"] > 0:
                    existing["weight"] = p["weight"]
                if p["jersey"] > 0:
                    existing["jerseyNumber"] = p["jersey"]

        time.sleep(10)

    # Sort by most recent first
    players_list = sorted(all_players.values(), key=lambda p: -p["startYear"])

    # Save combined database
    with open(COMBINED_OUTPUT, "w") as f:
        json.dump({"players": players_list, "total": len(players_list)}, f, indent=2)

    print(f"\n{'='*50}")
    print(f"✅ {len(players_list)} unique players")
    print(f"💾 Individual rosters: {OUTPUT_DIR}/")
    print(f"💾 Combined database:  {COMBINED_OUTPUT}")

    # Position breakdown
    from collections import Counter
    positions = Counter(p["position"] for p in players_list)
    print(f"\n📊 Position breakdown:")
    for pos, count in positions.most_common(15):
        print(f"   {pos}: {count}")

    print(f"\n🎯 Sample players:")
    for p in players_list[:10]:
        ht = p.get("height_str", "?")
        print(f"   {p['fullName']:<25s} {p['position']:<5s} {ht:<8s} {p['startYear']}-{p['endYear']}")


if __name__ == "__main__":
    main()
