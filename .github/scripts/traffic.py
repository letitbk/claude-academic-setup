#!/usr/bin/env python3
"""Save this repository's GitHub traffic counts and update the totals in README.md.

GitHub keeps daily views and clones for only 14 days. This script adds the
days GitHub reports to .github/traffic/*.csv, keeps the larger count when a
day is already saved, and rewrites the block between the traffic markers in
README.md. Run it at least once every 14 days so no day is lost.

Needs two environment variables:
  TRAFFIC_TOKEN      a token that can read traffic: a fine-grained token with
                     "Administration: Read-only" on this repository
  GITHUB_REPOSITORY  owner/name, e.g., letitbk/claude-academic-setup
"""
import csv
import json
import os
import re
import sys
import urllib.request
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
DATA = ROOT / ".github" / "traffic"
README = ROOT / "README.md"
BLOCK = re.compile(r"(<!-- traffic:start -->\n).*?(<!-- traffic:end -->)", re.S)
FIELDS = ["date", "count", "uniques"]


def fetch(repo, kind, token):
    request = urllib.request.Request(
        f"https://api.github.com/repos/{repo}/traffic/{kind}?per=day",
        headers={
            "Authorization": f"Bearer {token}",
            "Accept": "application/vnd.github+json",
            "X-GitHub-Api-Version": "2022-11-28",
        },
    )
    with urllib.request.urlopen(request, timeout=30) as response:
        return json.load(response)[kind]


def merge(path, days):
    rows = {}
    if path.exists():
        with path.open(newline="") as f:
            for row in csv.DictReader(f):
                rows[row["date"]] = {k: int(row[k]) if k != "date" else row[k] for k in FIELDS}
    for day in days:
        date = day["timestamp"][:10]
        old = rows.get(date, {"count": 0, "uniques": 0})
        # The newest day may be partial, so keep the larger count.
        rows[date] = {
            "date": date,
            "count": max(old["count"], day["count"]),
            "uniques": max(old["uniques"], day["uniques"]),
        }
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=FIELDS)
        writer.writeheader()
        for date in sorted(rows):
            writer.writerow(rows[date])
    return [rows[date] for date in sorted(rows)]


def table(views, clones):
    dates = [row["date"] for row in views + clones]

    def total(rows, key):
        return f"{sum(row[key] for row in rows):,}"

    return (
        f"Counts from {min(dates)} to {max(dates)}:\n\n"
        "| | Total | Unique |\n"
        "|---|---|---|\n"
        f"| Views | {total(views, 'count')} | {total(views, 'uniques')} |\n"
        f"| Clones | {total(clones, 'count')} | {total(clones, 'uniques')} |\n\n"
    )


def main():
    token = os.environ.get("TRAFFIC_TOKEN")
    repo = os.environ.get("GITHUB_REPOSITORY")
    if not token or not repo:
        sys.exit("Set TRAFFIC_TOKEN and GITHUB_REPOSITORY. See the top of this script.")
    views = merge(DATA / "views.csv", fetch(repo, "views", token))
    clones = merge(DATA / "clones.csv", fetch(repo, "clones", token))
    if not views and not clones:
        sys.exit("GitHub returned no traffic and nothing is saved yet.")
    text = README.read_text()
    if not BLOCK.search(text):
        sys.exit("README.md has no <!-- traffic:start --> and <!-- traffic:end --> markers.")
    README.write_text(BLOCK.sub(lambda m: m.group(1) + table(views, clones) + m.group(2), text, count=1))
    print(f"Saved {len(views)} days of views and {len(clones)} days of clones.")


if __name__ == "__main__":
    main()
