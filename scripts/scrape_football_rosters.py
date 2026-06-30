"""
Scrape Mizzou football rosters from sports-reference.com.
Dumps each season's roster into data/football_rosters/ as individual JSON files.
Then combines into a single deduplicated player database.

Usage:
    python3 scripts/scrape_football_rosters.py

Note: sports-reference rate-limits. This script adds 10s delays between requests.
"""

import json
import time
import requests
from bs4 import BeautifulSoup
from pathlib import Path

BASE_URL = "https://www.sports-reference.com/cfb/schools/missouri"
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
    """Convert height string like '6-4' to total inches."""
    if not height_str:
        return 0
    parts = height_str.strip().replace("'", "-").replace('"', '').split('-')
    if len(parts) == 2:
        try:
            return int(parts[0]) * 12 + int(parts[1])
        except ValueError:
            return 0
    return 0


def scrape_roster(year):
    """Scrape a single season's football roster page."""
    url = f"{BASE_URL}/{year}-roster.html"
    print(f"  {year} ... ", end="", flush=True)

    try:
        resp = requests.get(url, headers=HEADERS, timeout=10)
    except requests.RequestException as e:
        print(f"❌ {e}")
        return []

    if resp.status_code == 429:
        print("❌ rate limited")
        return None  # Signal to stop
    if resp.status_code != 200:
        print(f"❌ HTTP {resp.status_code}")
        return []

    soup = BeautifulSoup(resp.text, "html.parser")
    roster_table = soup.find("table", {"id": "roster"})

    if not roster_table:
        print("❌ no roster table")
        return []

    tbody = roster_table.find("tbody")
    if not tbody:
        print("❌ no tbody")
        return []

    players = []
    for row in tbody.find_all("tr"):
        if row.get("class") and "thead" in row.get("class", []):
            continue

        cells = row.find_all(["th", "td"])
        if len(cells) < 4:
            continue

        # Get data-stat values for reliable parsing
        values = {}
        for cell in cells:
            stat = cell.get("data-stat", "")
            values[stat] = cell.get_text(strip=True)

        name = values.get("player", "")
        if not name:
            continue

        jersey = values.get("uniform_number", "")
        position = values.get("pos", "")
        height_str = values.get("height", "")
        weight = values.get("weight", "")
        player_class = values.get("class", "")
        hometown = values.get("hometown", "")

        try:
            jersey_num = int(jersey) if jersey else 0
        except (ValueError, TypeError):
            jersey_num = 0

        try:
            weight_num = int(weight) if weight else 0
        except (ValueError, TypeError):
            weight_num = 0

        # Get player URL if available
        player_link = ""
        for cell in cells:
            link = cell.find("a")
            if link and link.get("href", "").startswith("/cfb/players/"):
                player_link = link["href"]
                break

        players.append({
            "name": name,
            "jersey": jersey_num,
            "class": player_class,
            "position": position,
            "height": parse_height(height_str),
            "height_str": height_str,
            "weight": weight_num,
            "hometown": hometown,
            "playerUrl": player_link,
            "season": year,
        })

    print(f"✓ {len(players)} players")
    return players


def main():
    print("🏈 Scraping Mizzou Football Rosters")
    print(f"   Seasons: {START_YEAR}-{END_YEAR}")
    print(f"   Output: {OUTPUT_DIR}/")
    print()

    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

    all_players = {}  # name -> combined player data

    for year in range(START_YEAR, END_YEAR + 1):
        players = scrape_roster(year)

        if players is None:
            # Rate limited — stop
            print("\n⚠️  Rate limited. Run again later to continue.")
            break

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
                    "playerUrl": p["playerUrl"],
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
                if p["playerUrl"]:
                    existing["playerUrl"] = p["playerUrl"]

        time.sleep(10)  # Rate limit - be nice

    # Sort by most recent first
    players_list = sorted(all_players.values(), key=lambda p: -p["startYear"])

    # Save combined database
    COMBINED_OUTPUT.parent.mkdir(parents=True, exist_ok=True)
    with open(COMBINED_OUTPUT, "w") as f:
        json.dump({"players": players_list, "total": len(players_list)}, f, indent=2)

    print(f"\n{'='*50}")
    print(f"✅ {len(players_list)} unique players")
    print(f"💾 Individual rosters: {OUTPUT_DIR}/")
    print(f"💾 Combined database:  {COMBINED_OUTPUT}")

    # Show position breakdown
    from collections import Counter
    positions = Counter(p["position"] for p in players_list)
    print(f"\n📊 Position breakdown:")
    for pos, count in positions.most_common(15):
        print(f"   {pos}: {count}")

    print(f"\n🎯 Sample players:")
    for p in players_list[:10]:
        ht = p.get("height_str", "?")
        print(f"   {p['fullName']:<25s} {p['position']:<5s} {ht:<5s} {p['startYear']}-{p['endYear']}")


if __name__ == "__main__":
    main()
