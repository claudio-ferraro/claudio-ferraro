#!/usr/bin/env bash
set -euo pipefail

user="${GITHUB_REPOSITORY_OWNER}"
list=$(gh search prs --author "$user" --merged --sort updated --limit 30 \
  --json repository,title,url,closedAt \
  --jq '[.[] | select(.repository.nameWithOwner | startswith("'"$user"'/") | not)] | .[:5][] | "- [\(.title)](\(.url)) in `\(.repository.nameWithOwner)`"')

if [ -z "$list" ]; then
  list="- No recent merged pull requests."
fi

python3 - "$list" <<'PY'
import re, sys
readme = open("README.md", encoding="utf-8").read()
block = "<!-- ACTIVITY:START -->\n" + sys.argv[1] + "\n<!-- ACTIVITY:END -->"
readme = re.sub(r"<!-- ACTIVITY:START -->.*?<!-- ACTIVITY:END -->", block, readme, flags=re.S)
open("README.md", "w", encoding="utf-8").write(readme)
PY
