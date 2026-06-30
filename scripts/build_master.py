"""
Combine all individual roster files into a single deduplicated player database.
Reads from data/rosters/*.json — no web calls.

Usage:
    python3 scripts/build_master.py
"""

import json
from pathlib import Path

ROSTERS_DIR = Path(__file__).parent.parent / "data" / "rosters"
OUTPUT = Path(__file__).parent.parent / "data" / "player_database.json"


def main():
    print("🏀 Building master player database from roster files...")

    roster_files = sorted(ROSTERS_DIR.glob("*.json"))
    print(f"   Found {len(roster_files)} roster files\n")

    player_map = {}  # name -> player data

    for roster_file in roster_files:
        with open(roster_file) as f:
            data = json.load(f)

        season = data.get("season", roster_file.stem)
        players = data.get("players", [])

        for p in players:
            name = p["name"]
            year = p["season_end_year"]

            if name not in player_map:
                player_map[name] = {
                    "fullName": name,
                    "position": p["position"],
                    "height": p["height"],
                    "height_str": p.get("height_str", ""),
                    "weight": p.get("weight", 0),
                    "jerseyNumber": p["jersey"],
                    "hometown": p.get("hometown", ""),
                    "startYear": year - 1,
                    "endYear": year,
                    "seasons": [season],
                    # Stats — empty until we scrape them
                    "points": "",
                    "rebounds": "",
                    "assists": "",
                    "steals": "",
                    "playerUrl": "",
                    "validated": False,
                }
            else:
                existing = player_map[name]
                existing["endYear"] = max(existing["endYear"], year)
                existing["startYear"] = min(existing["startYear"], year - 1)
                if season not in existing["seasons"]:
                    existing["seasons"].append(season)
                # Prefer non-zero values
                if p["height"] > 0:
                    existing["height"] = p["height"]
                    existing["height_str"] = p.get("height_str", "")
                if p.get("weight", 0) > 0:
                    existing["weight"] = p["weight"]
                if p["jersey"] > 0:
                    existing["jerseyNumber"] = p["jersey"]

    # Sort by most recent first
    players_list = sorted(player_map.values(), key=lambda p: -p["startYear"])

    output = {"players": players_list, "total": len(players_list)}
    with open(OUTPUT, "w") as f:
        json.dump(output, f, indent=2)

    print(f"✅ {len(players_list)} unique players")
    print(f"💾 Saved to {OUTPUT}")

    # Stats summary
    with_stats = sum(1 for p in players_list if p["points"] != "")
    print(f"\n📊 Stats filled: {with_stats}/{len(players_list)}")
    print(f"   Still need stats: {len(players_list) - with_stats}")

    print(f"\n🎯 Sample:")
    for p in players_list[:10]:
        ht = p.get("height_str", "?")
        yrs = f"{p['startYear']}-{p['endYear']}"
        print(f"   {p['fullName']:<25s} {p['position']:<4s} {ht:<5s} {yrs}")


if __name__ == "__main__":
    main()
