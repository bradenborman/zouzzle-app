"""
Fetch Mizzou basketball player stats from SportsDataIO API.
Iterates through seasons, deduplicates players, aggregates career stats,
and outputs basketball_players.json in the format the app expects.

Usage:
    python scripts/fetch_mizzou_bball.py
"""

import json
import time
import requests
from pathlib import Path

API_KEY = "3b4eb4d02b814aa6b9cd77dc790a98f6"
BASE_URL = "https://api.sportsdata.io/v3/cbb/stats/json/PlayerSeasonStatsByTeam"
TEAM = "MISSR"  # Mizzou abbreviation in SportsDataIO

# Seasons to fetch — free tier may limit older seasons
SEASONS = [f"{year}" for year in range(2022, 2027)]

OUTPUT_PATH = Path(__file__).parent.parent / "assets" / "data" / "basketball_players.json"


def fetch_season(season: str) -> list:
    """Fetch player stats for a single season."""
    url = f"{BASE_URL}/{season}/{TEAM}"
    headers = {"Ocp-Apim-Subscription-Key": API_KEY}

    print(f"  Fetching {season}...")
    resp = requests.get(url, headers=headers)

    if resp.status_code == 200:
        return resp.json()
    else:
        print(f"  ⚠️  {season}: HTTP {resp.status_code} - {resp.text[:100]}")
        return []


def classify_position(pos: str) -> str:
    """Map API position codes to our simplified positions."""
    if not pos:
        return "Guard"
    pos = pos.strip().upper()
    if pos in ("PG", "SG", "G"):
        return "Guard"
    elif pos in ("SF", "PF", "F"):
        return "Forward"
    elif pos in ("C",):
        return "Center"
    elif pos in ("GF", "G-F", "SG-SF"):
        return "Guard"
    elif pos in ("FC", "F-C", "PF-C"):
        return "Forward"
    else:
        return "Guard"  # default fallback


def classify_tier(points: int, games: int) -> str:
    """Rough tier classification based on career points per game."""
    if games == 0:
        return "Walk-On"
    ppg = points / games
    if ppg >= 15:
        return "All-American"
    elif ppg >= 10:
        return "Starter"
    elif ppg >= 5:
        return "Role Player"
    else:
        return "Walk-On"


def main():
    print("🏀 Fetching Mizzou basketball data from SportsDataIO...")
    print(f"   Team: {TEAM}")
    print(f"   Seasons: {SEASONS[0]} - {SEASONS[-1]}")
    print()

    # Aggregate player data across seasons
    # Key: player name -> accumulated stats
    players_data = {}

    for season in SEASONS:
        season_players = fetch_season(season)
        time.sleep(1)  # Be nice to the API (15 min interval noted)

        for p in season_players:
            name = p.get("Name", "").strip()
            if not name:
                continue

            year = int(season[:4])

            if name not in players_data:
                players_data[name] = {
                    "fullName": name,
                    "position": classify_position(p.get("Position", "")),
                    "jerseyNumber": p.get("Jersey") or 0,
                    "startYear": year,
                    "endYear": year,
                    "points": 0,
                    "rebounds": 0,
                    "assists": 0,
                    "steals": 0,
                    "games": 0,
                }
            else:
                # Update end year
                players_data[name]["endYear"] = max(players_data[name]["endYear"], year)
                players_data[name]["startYear"] = min(players_data[name]["startYear"], year)

            # Accumulate career stats
            players_data[name]["points"] += int(p.get("Points") or 0)
            players_data[name]["rebounds"] += int(p.get("Rebounds") or 0)
            players_data[name]["assists"] += int(p.get("Assists") or 0)
            players_data[name]["steals"] += int(p.get("Steals") or 0)
            players_data[name]["games"] += int(p.get("Games") or 0)

            # Update jersey if we got a real one
            if p.get("Jersey") and p["Jersey"] > 0:
                players_data[name]["jerseyNumber"] = p["Jersey"]

    print(f"\n📊 Found {len(players_data)} unique players across {len(SEASONS)} seasons.")

    # Filter: only keep players with meaningful minutes (at least 10 games)
    MIN_GAMES = 10
    qualified = {k: v for k, v in players_data.items() if v["games"] >= MIN_GAMES}
    print(f"✅ {len(qualified)} players with {MIN_GAMES}+ career games.")

    # Build output
    output_players = []
    for name, data in sorted(qualified.items(), key=lambda x: -x[1]["points"]):
        jersey = data["jerseyNumber"]
        # Clamp jersey to 0-99
        if jersey < 0 or jersey > 99:
            jersey = 0

        player = {
            "fullName": data["fullName"],
            "sport": "basketball",
            "position": data["position"],
            "jerseyNumber": jersey,
            "startYear": data["startYear"],
            "endYear": data["endYear"],
            "wentPro": False,  # We'll default to false; can manually adjust notable pros
            "statisticalTier": classify_tier(data["points"], data["games"]),
            "points": data["points"],
            "rebounds": data["rebounds"],
            "assists": data["assists"],
            "steals": data["steals"],
        }
        output_players.append(player)

    # -------------------------------------------------------------------------
    # Merge with hand-curated historical players so we have legends + current
    # -------------------------------------------------------------------------
    historical_path = OUTPUT_PATH.parent / "basketball_players_historical.json"
    if historical_path.exists():
        with open(historical_path) as f:
            historical = json.load(f)
        historical_names = {p["fullName"] for p in historical.get("players", [])}
        # Add API players that aren't already in historical
        for p in output_players:
            if p["fullName"] not in historical_names:
                historical["players"].append(p)
        output = historical
        output_players = output["players"]
        print(f"\n🔀 Merged with historical data: {len(output_players)} total players")
    else:
        output = {"players": output_players}
        print(f"\n   (No historical file found at {historical_path}, writing API-only data)")

    # Write output
    OUTPUT_PATH.parent.mkdir(parents=True, exist_ok=True)
    with open(OUTPUT_PATH, "w") as f:
        json.dump(output, f, indent=2)

    print(f"\n💾 Wrote {len(output_players)} players to {OUTPUT_PATH}")
    print("\n🎯 Top 10 by career points:")
    for i, p in enumerate(output_players[:10], 1):
        print(f"   {i:2d}. {p['fullName']:<22s} {p['points']:,} pts  ({p['startYear']}-{p['endYear']})")


if __name__ == "__main__":
    main()
