"""
Scrape career stats (per-game averages at Missouri) for Mizzou players.
Reads player_database.json, hits each player's sports-reference page,
validates Missouri is listed, and grabs their Missouri per-game averages.

Usage:
    python3 scripts/scrape_stats.py

Respects rate limits with 10s delays between requests.
Can be stopped and resumed — only processes players with empty stats.
"""

import json
import re
import time
import requests
from bs4 import BeautifulSoup
from pathlib import Path

DATABASE_PATH = Path(__file__).parent.parent / "data" / "player_database.json"
BASE_URL = "https://www.sports-reference.com"

HEADERS = {
    "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126.0.0.0 Safari/537.36",
    "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9",
    "Accept-Language": "en-US,en;q=0.9",
}

DELAY = 10  # seconds between requests


def name_to_slugs(name):
    """Generate possible URL slugs for a player name."""
    slug = name.lower().strip()
    slug = re.sub(r"['.()]", "", slug)
    slug = re.sub(r"\s+", "-", slug)
    slug = re.sub(r"-+", "-", slug)
    # Try -1, -2, -3
    return [f"{slug}-1", f"{slug}-2", f"{slug}-3"]


def find_player_page(name):
    """Try URL patterns until we find the player AT Missouri. Returns (url, soup) or (None, None)."""
    for slug in name_to_slugs(name):
        url = f"{BASE_URL}/cbb/players/{slug}.html"
        try:
            resp = requests.get(url, headers=HEADERS, timeout=10)
            if resp.status_code == 200:
                soup = BeautifulSoup(resp.text, "html.parser")
                # Only accept if Missouri is on this page
                if validate_missouri(soup):
                    return url, soup
            elif resp.status_code == 429:
                print("RATE LIMITED", end=" ")
                return None, None
        except requests.RequestException:
            pass
        time.sleep(2)
    return None, None


def get_missouri_stats(soup):
    """
    Find the Missouri row in the per-game table and extract averages.
    Returns dict with pts, reb, ast, stl as floats, or empty strings if not found.
    """
    stats = {"points": "", "rebounds": "", "assists": "", "steals": "", "games": ""}

    # Find the per-game table
    table = soup.find("table", {"id": "players_per_game"})
    if not table:
        return stats

    # Check tfoot for Missouri subtotal row
    tfoot = table.find("tfoot")
    if tfoot:
        for row in tfoot.find_all("tr"):
            row_text = row.get_text().lower()
            if "missouri" in row_text:
                cells = row.find_all(["th", "td"])
                values = {}
                for cell in cells:
                    stat = cell.get("data-stat", "")
                    values[stat] = cell.get_text(strip=True)

                try:
                    stats["points"] = float(values.get("pts_per_g", "0") or "0")
                except (ValueError, TypeError):
                    pass
                try:
                    stats["rebounds"] = float(values.get("trb_per_g", "0") or "0")
                except (ValueError, TypeError):
                    pass
                try:
                    stats["assists"] = float(values.get("ast_per_g", "0") or "0")
                except (ValueError, TypeError):
                    pass
                try:
                    stats["steals"] = float(values.get("stl_per_g", "0") or "0")
                except (ValueError, TypeError):
                    pass
                try:
                    stats["games"] = int(values.get("games", "0") or "0")
                except (ValueError, TypeError):
                    pass
                return stats

    # No Missouri subtotal — player only played at Missouri, use Career row
    if tfoot:
        for row in tfoot.find_all("tr"):
            row_text = row.get_text().lower()
            if "career" in row_text:
                cells = row.find_all(["th", "td"])
                values = {}
                for cell in cells:
                    stat = cell.get("data-stat", "")
                    values[stat] = cell.get_text(strip=True)

                try:
                    stats["points"] = float(values.get("pts_per_g", "0") or "0")
                except (ValueError, TypeError):
                    pass
                try:
                    stats["rebounds"] = float(values.get("trb_per_g", "0") or "0")
                except (ValueError, TypeError):
                    pass
                try:
                    stats["assists"] = float(values.get("ast_per_g", "0") or "0")
                except (ValueError, TypeError):
                    pass
                try:
                    stats["steals"] = float(values.get("stl_per_g", "0") or "0")
                except (ValueError, TypeError):
                    pass
                try:
                    stats["games"] = int(values.get("games", "0") or "0")
                except (ValueError, TypeError):
                    pass
                return stats

    return stats


def validate_missouri(soup):
    """Check if Missouri appears on the page."""
    text = soup.get_text().lower()
    return "missouri" in text


def main():
    print("🏀 Scraping per-game stats (Missouri averages)")
    print(f"   Database: {DATABASE_PATH}")
    print(f"   Delay: {DELAY}s between requests")
    print()

    with open(DATABASE_PATH) as f:
        data = json.load(f)

    players = data["players"]
    need_stats = [p for p in players if p["points"] == ""]
    already_done = len(players) - len(need_stats)

    print(f"   Total players: {len(players)}")
    print(f"   Already have stats: {already_done}")
    print(f"   Need stats: {len(need_stats)}")
    print()

    processed = 0
    found = 0
    failed = 0

    for i, player in enumerate(need_stats):
        name = player["fullName"]
        print(f"  [{i+1}/{len(need_stats)}] {name:<25s} ", end="", flush=True)

        url, soup = find_player_page(name)

        if not url:
            print("❌ not found")
            player["playerUrl"] = ""
            player["validated"] = False
            failed += 1
            time.sleep(DELAY)
            continue

        # Get Missouri-specific stats
        stats = get_missouri_stats(soup)
        player["playerUrl"] = url
        player["validated"] = True

        # If no real stats (0 games or all zeros), leave as empty
        if stats["games"] == 0 or stats["games"] == "" or (stats["points"] == 0.0 and stats["rebounds"] == 0.0 and stats["assists"] == 0.0):
            player["points"] = ""
            player["rebounds"] = ""
            player["assists"] = ""
            player["steals"] = ""
            print("⚠️  no stats (0 games)")
            failed += 1
        else:
            player["points"] = stats["points"]
            player["rebounds"] = stats["rebounds"]
            player["assists"] = stats["assists"]
            player["steals"] = stats["steals"]
            if stats["games"]:
                player["games"] = stats["games"]

            pts = stats["points"] if stats["points"] != "" else "?"
            reb = stats["rebounds"] if stats["rebounds"] != "" else "?"
            ast = stats["assists"] if stats["assists"] != "" else "?"
            stl = stats["steals"] if stats["steals"] != "" else "?"
            g = stats["games"] if stats["games"] != "" else "?"
            print(f"✓ {pts}ppg {reb}rpg {ast}apg {stl}spg ({g}g)")
            found += 1

        processed += 1

        # Save progress every 5 players
        if processed % 5 == 0:
            with open(DATABASE_PATH, "w") as f:
                json.dump(data, f, indent=2)
            print(f"       💾 saved progress ({found} found so far)")

        time.sleep(DELAY)

    # Final save
    with open(DATABASE_PATH, "w") as f:
        json.dump(data, f, indent=2)

    print(f"\n{'='*50}")
    print(f"✅ Processed: {processed}")
    print(f"   Found stats: {found}")
    print(f"   Failed/not found: {failed}")
    print(f"💾 Saved to {DATABASE_PATH}")


if __name__ == "__main__":
    main()
