#!/usr/bin/env python3
"""Claude Code statusline: 2-line display with Fine Bar + Gradient context meter."""
import hashlib
import json
import os
import re
import subprocess
import sys
import time

if sys.platform == "win32":
    sys.stdout.reconfigure(encoding="utf-8")

data = json.load(sys.stdin)

R = "\033[0m"
DIM = "\033[2m"
GREEN = "\033[32m"
YELLOW = "\033[33m"

# ── helpers ──────────────────────────────────────────────────────────────────

def gradient_color(pct: float) -> str:
    """Return an ANSI true-color escape that goes green → yellow → red."""
    if pct < 50:
        r = int(pct * 5.1)
        return f"\033[38;2;{r};200;80m"
    else:
        g = int(200 - (pct - 50) * 4)
        return f"\033[38;2;255;{max(g, 0)};60m"


def fine_bar(pct: float, width: int = 12) -> str:
    """Fine Bar + Gradient: filled █ with gradient color, unfilled ░ dimmed."""
    pct = min(max(pct, 0), 100)
    filled = int(pct / 100 * width)
    color = gradient_color(pct)
    bar = f"{color}{'█' * filled}{R}{DIM}{'░' * (width - filled)}{R}"
    return bar


def model_short_name(model_id: str) -> str:
    """claude-opus-4-6 → Opus 4.6"""
    for key in ("opus", "sonnet", "haiku"):
        if key in model_id:
            name = key.capitalize()
            m = re.search(rf"{key}-(\d+)-(\d+)", model_id)
            if m:
                return f"{name} {m.group(1)}.{m.group(2)}"
            return name
    return "Claude"


def run_git(*args: str, cwd: str) -> str:
    """Run a git command and return stripped stdout, or '' on failure."""
    try:
        r = subprocess.run(
            ["git", *args],
            cwd=cwd,
            capture_output=True,
            text=True,
            timeout=5,
        )
        return r.stdout.strip() if r.returncode == 0 else ""
    except Exception:
        return ""


def get_pr_url(branch: str, cwd: str) -> str:
    """Get PR URL for the branch, with /tmp file cache (5-min TTL)."""
    repo_hash = hashlib.md5(cwd.encode()).hexdigest()
    cache_file = f"/tmp/claude-statusline-pr-{repo_hash}-{branch}"
    now = time.time()

    # Clean stale caches (>1h) — best-effort, non-blocking
    try:
        for f in os.listdir("/tmp"):
            if f.startswith("claude-statusline-pr-"):
                p = os.path.join("/tmp", f)
                if now - os.path.getmtime(p) > 3600:
                    os.unlink(p)
    except Exception:
        pass

    # Read cache if fresh (<5 min)
    try:
        if os.path.exists(cache_file):
            if now - os.path.getmtime(cache_file) < 300:
                return open(cache_file).read().strip()
            else:
                os.unlink(cache_file)
    except Exception:
        pass

    # Fetch from gh CLI
    pr_url = ""
    try:
        r = subprocess.run(
            ["gh", "pr", "view", "--json", "url", "-q", ".url"],
            cwd=cwd,
            capture_output=True,
            text=True,
            timeout=5,
        )
        if r.returncode == 0:
            pr_url = r.stdout.strip()
    except Exception:
        pass

    # Write cache
    try:
        with open(cache_file, "w") as f:
            f.write(pr_url)
    except Exception:
        pass

    return pr_url


# ── data extraction ──────────────────────────────────────────────────────────

model_id = data.get("model", {}).get("id") or data.get("model", {}).get("display_name", "Claude")
model = model_short_name(model_id)

current_dir = data.get("workspace", {}).get("current_dir") or data.get("cwd", "")
project_name = os.path.basename(current_dir) if current_dir else ""

ctx_pct = data.get("context_window", {}).get("used_percentage")
total_cost = data.get("cost", {}).get("total_cost_usd")

# ── line 1: model / project / git ────────────────────────────────────────────

line1_parts = [f"[{model}]"]

if project_name:
    line1_parts.append(f"📁 {project_name}")

if current_dir and run_git("rev-parse", "--git-dir", cwd=current_dir):
    branch = run_git("rev-parse", "--abbrev-ref", "HEAD", cwd=current_dir)
    if branch:
        # git status counts
        porcelain = run_git("--no-optional-locks", "status", "--porcelain", cwd=current_dir)
        status_parts = []
        if porcelain:
            added = sum(1 for l in porcelain.splitlines() if l.startswith("A"))
            modified = sum(1 for l in porcelain.splitlines() if l.startswith(" M") or l.startswith("M"))
            if added > 0:
                status_parts.append(f"{GREEN}+{added}{R}")
            if modified > 0:
                status_parts.append(f"{YELLOW}~{modified}{R}")

        # PR hyperlink
        branch_display = branch
        pr_url = get_pr_url(branch, current_dir)
        if pr_url:
            branch_display = f"\033]8;;{pr_url}\033\\{branch}\033]8;;\033\\"

        git_info = f"🌿 {branch_display}"
        if status_parts:
            git_info += " " + "".join(status_parts)
        line1_parts.append(git_info)

line1 = " | ".join(line1_parts)

# ── line 2: context bar + cost ───────────────────────────────────────────────

line2_parts = []

if ctx_pct is not None:
    p = round(ctx_pct, 1)
    color = gradient_color(ctx_pct)
    line2_parts.append(f"ctx {fine_bar(ctx_pct)} {color}{p}%{R}")

if total_cost is not None:
    line2_parts.append(f"💰 ${total_cost:.2f}")

line2 = " | ".join(line2_parts)

# ── output ───────────────────────────────────────────────────────────────────

print(line1)
if line2:
    print(line2)
