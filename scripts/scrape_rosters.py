"""
Scrape Mizzou basketball rosters from sports-reference.com.
Dumps each season's roster into data/rosters/ as individual JSON files.
Then combines into a single deduplicated player database.

Usage:
    python3 scripts/scrape_rosters.py

Note: sports-reference rate-limits. This script adds 3s delays between requests.
"""

import json
import time
import requests
from bs4 import BeautifulSoup
from pathlib import Path

BASE_URL = "https://www.sports-reference.com/cbb/schools/missouri/men"
OUTPUT_DIR = Path(__file__).parent.parent / "data" / "rosters"
COMBINED_OUTPUT = Path(__file__).parent.parent / "data" / "player_database.json"

# Seasons to scrape (sports-reference uses the ending year)
START_YEAR = 2000
END_YEAR = 2026

HEADERS = {
    "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126.0.0.0 Safari/537.36",
    "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9",
    "Accept-Language": "en-US,en;q=0.9",
}


def parse_height(height_str: str) -> int:
    """Convert height string like '6-4' to total inches."""
    if not height_str:
        return 0
    parts = height_str.strip().split('-')
    if len(parts) == 2:
        try:
            return int(parts[0]) * 12 + int(parts[1])
        except ValueError:
            return 0
    return 0


def scrape_roster(year: int) -> list:
    """Scrape a single season's roster page. Returns list of player dicts."""
    url = f"{BASE_URL}/{year}.html"
    print(f"  {year-1}-{str(year)[2:]} ... ", end="", flush=True)

    try:
        resp = requests.get(url, headers=HEADERS, timeout=10)
    except requests.RequestException as e:
        print(f"❌ {e}")
        return []

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
        cells = [c.get_text(strip=True) for c in row.find_all(["th", "td"])]
        if len(cells) < 5:
            continue

        # Columns: name, jersey, class, position, height, weight, hometown, hs, recruiting, summary
        name = cells[0]
        jersey = cells[1]
        player_class = cells[2]
        position = cells[3]
        height_str = cells[4]
        weight = cells[5] if len(cells) > 5 else ""
        hometown = cells[6] if len(cells) > 6 else ""
        summary = cells[-1] if len(cells) > 8 else ""

        if not name:
            continue

        try:
            jersey_num = int(jersey)
        except (ValueError, TypeError):
            jersey_num = 0

        try:
            weight_num = int(weight)
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
            "summary": summary,
            "season": f"{year-1}-{str(year)[2:]}",
            "season_end_year": year,
        })

    print(f"✓ {len(players)} players")
    return players


def main():
    print("🏀 Scraping Mizzou Basketball Rosters")
    print(f"   Seasons: {START_YEAR}-{END_YEAR}")
    print(f"   Output: {OUTPUT_DIR}/")
    print()

    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

    all_players = {}  # name -> combined player data

    for year in range(START_YEAR, END_YEAR + 1):
        players = scrape_roster(year)

        # Save individual season file
        if players:
            season_file = OUTPUT_DIR / f"{year-1}_{str(year)[2:]}.json"
            with open(season_file, "w") as f:
                json.dump({"season": f"{year-1}-{str(year)[2:]}", "players": players}, f, indent=2)

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
                    "startYear": year - 1,
                    "endYear": year,
                    "seasons": [p["season"]],
                    "classes": [p["class"]],
                }
            else:
                existing = all_players[name]
                existing["endYear"] = max(existing["endYear"], year)
                existing["startYear"] = min(existing["startYear"], year - 1)
                existing["seasons"].append(p["season"])
                existing["classes"].append(p["class"])
                if p["height"] > 0:
                    existing["height"] = p["height"]
                    existing["height_str"] = p["height_str"]
                if p["weight"] > 0:
                    existing["weight"] = p["weight"]
                if p["jersey"] > 0:
                    existing["jerseyNumber"] = p["jersey"]

        time.sleep(10)  # Rate limit

    # Sort by most recent first
    players_list = sorted(all_players.values(), key=lambda p: -p["startYear"])

    # Save combined database
    COMBINED_OUTPUT.parent.mkdir(parents=True, exist_ok=True)
    with open(COMBINED_OUTPUT, "w") as f:
        json.dump({"players": players_list, "total": len(players_list)}, f, indent=2)

    print(f"\n{'='*50}")
    print(f"✅ {len(players_list)} unique players across {END_YEAR - START_YEAR + 1} seasons")
    print(f"💾 Individual rosters: {OUTPUT_DIR}/")
    print(f"💾 Combined database:  {COMBINED_OUTPUT}")
    print(f"\n🎯 Recent players:")
    for p in players_list[:10]:
        ht = p.get("height_str", "?")
        print(f"   {p['fullName']:<25s} {p['position']:<4s} {ht:<5s} {p['startYear']}-{p['endYear']}  ({', '.join(p['seasons'])})")


if __name__ == "__main__":
    main()
