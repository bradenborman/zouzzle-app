"""
Build the final game-ready JSON from the player database.
Only includes players with complete data (no empty stats).

Usage:
    python3 scripts/build_game_data.py
"""

import json
from pathlib import Path

DATABASE_PATH = Path(__file__).parent.parent / "data" / "player_database.json"
OUTPUT_PATH = Path(__file__).parent.parent / "assets" / "data" / "basketball_players.json"


def main():
    print("🏀 Building game data from player database...")

    with open(DATABASE_PATH) as f:
        data = json.load(f)

    players = data["players"]

    # Filter to only players with complete stats
    complete = []
    for p in players:
        if p["points"] == "" or p["rebounds"] == "" or p["assists"] == "" or p["steals"] == "":
            continue
        if p["height"] == 0:
            continue

        complete.append({
            "fullName": p["fullName"],
            "sport": "basketball",
            "position": p["position"],
            "jerseyNumber": p["jerseyNumber"],
            "height": p["height"],
            "startYear": p["startYear"],
            "endYear": p["endYear"],
            "wentPro": False,  # Can be manually updated
            "statisticalTier": "Role Player",  # Can be manually updated
            "points": p["points"],
            "rebounds": p["rebounds"],
            "assists": p["assists"],
            "steals": p["steals"],
        })

    # Sort by points descending
    complete.sort(key=lambda p: -(p["points"] if isinstance(p["points"], int) else 0))

    output = {"players": complete}
    with open(OUTPUT_PATH, "w") as f:
        json.dump(output, f, indent=2)

    print(f"\n✅ {len(complete)} players with complete data (out of {len(players)} total)")
    print(f"💾 Saved to {OUTPUT_PATH}")

    if complete:
        print(f"\n🎯 Top 10 by points:")
        for i, p in enumerate(complete[:10], 1):
            ht = f"{p['height'] // 12}'{p['height'] % 12}\""
            print(f"   {i:2d}. {p['fullName']:<25s} {p['points']:>5} pts  {ht}  {p['startYear']}-{p['endYear']}")


if __name__ == "__main__":
    main()
