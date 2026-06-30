"""
Validate and fix player database issues.
- Fix positions that have height strings instead of position codes
- Check for missing/invalid data
- Report issues

Usage:
    python3 scripts/validate_data.py
"""

import json
import re
from pathlib import Path

DATABASE_PATH = Path(__file__).parent.parent / "data" / "player_database.json"
GAME_DATA_PATH = Path(__file__).parent.parent / "assets" / "data" / "basketball_players.json"


def fix_position(pos, height_inches):
    """Fix position field. If it looks like a height string, infer from height."""
    # Check if position looks like a height (e.g., "6-2", "6-9")
    if re.match(r'^\d+-\d+$', pos):
        # It's a height string, not a position. Infer from actual height.
        if height_inches >= 80:  # 6'8"+
            return "C"
        elif height_inches >= 77:  # 6'5"+
            return "F"
        else:
            return "G"
    if pos == '' or pos is None:
        if height_inches >= 80:
            return "C"
        elif height_inches >= 77:
            return "F"
        else:
            return "G"
    return pos


def main():
    print("🔍 Validating player database...")
    print()

    with open(DATABASE_PATH) as f:
        data = json.load(f)

    players = data["players"]
    issues = 0
    fixed = 0

    # Fix positions
    for p in players:
        old_pos = p["position"]
        new_pos = fix_position(old_pos, p.get("height", 75))
        if old_pos != new_pos:
            print(f"  FIX position: {p['fullName']:<25s} '{old_pos}' → '{new_pos}'")
            p["position"] = new_pos
            fixed += 1

    # Check for zero height
    zero_height = [p for p in players if p.get("height", 0) == 0]
    if zero_height:
        print(f"\n  ⚠️  {len(zero_height)} players with 0 height:")
        for p in zero_height[:5]:
            print(f"     {p['fullName']}")
        issues += len(zero_height)

    # Check for empty stats that should have data
    empty_stats = [p for p in players if p["points"] == "" and p.get("games", 0) > 0]
    if empty_stats:
        print(f"\n  ⚠️  {len(empty_stats)} players with games but no stats:")
        for p in empty_stats[:5]:
            print(f"     {p['fullName']}")
        issues += len(empty_stats)

    # Check difficulty distributions
    print("\n📊 Difficulty distributions:")
    easy = [p for p in players if p["points"] != "" and (p["points"] >= 10 or p["rebounds"] >= 7 or p["assists"] >= 3)]
    medium = [p for p in players if p["points"] != "" and (p["points"] >= 6 or p["rebounds"] >= 4)]
    hard = [p for p in players if p["points"] != "" and (p["points"] >= 2 or p["rebounds"] >= 1)]
    print(f"   Easy (10ppg/7rpg/3apg):   {len(easy)} players")
    print(f"   Medium (6ppg/4rpg):       {len(medium)} players")
    print(f"   Hard (2ppg/1rpg):         {len(hard)} players")

    # Save fixes
    with open(DATABASE_PATH, "w") as f:
        json.dump(data, f, indent=2)

    print(f"\n✅ Fixed {fixed} issues")
    print(f"⚠️  {issues} remaining issues")

    # Also fix the game data file
    if GAME_DATA_PATH.exists():
        with open(GAME_DATA_PATH) as f:
            game_data = json.load(f)
        for p in game_data["players"]:
            old_pos = p["position"]
            new_pos = fix_position(old_pos, p.get("height", 75))
            if old_pos != new_pos:
                p["position"] = new_pos
        with open(GAME_DATA_PATH, "w") as f:
            json.dump(game_data, f, indent=2)
        print(f"💾 Also fixed {GAME_DATA_PATH}")


if __name__ == "__main__":
    main()
