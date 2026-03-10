#!/usr/bin/env bash
#
# Download the latest regexes.yaml from the ua-parser/uap-core repository
# and place it in the project's priv directory (or the directory pointed to
# by REBAR_BARE_COMPILER_OUTPUT_DIR if that is set and exists).
#
# Usage:
#   bash scripts/update_regexes.sh
# Environment:
#   UAP_CORE_REPO_URL - optional, override the default raw URL (for testing)
#   REBAR_BARE_COMPILER_OUTPUT_DIR - if set and exists, the script will write to its "priv" subdir
#
set -euo pipefail

# Default raw URL for the uap-core regex file (master branch)
UAP_CORE_REPO_URL_DEFAULT="https://raw.githubusercontent.com/ua-parser/uap-core/master/regexes.yaml"
UAP_CORE_REPO_URL="${UAP_CORE_REPO_URL:-$UAP_CORE_REPO_URL_DEFAULT}"

# Determine target priv directory (mirror logic in build_deps.sh)
TARGET_PRIV="priv"
if [[ -n "${REBAR_BARE_COMPILER_OUTPUT_DIR:-}" && -d "$REBAR_BARE_COMPILER_OUTPUT_DIR" ]]; then
    TARGET_PRIV="${REBAR_BARE_COMPILER_OUTPUT_DIR%/}/priv"
fi

mkdir -p "$TARGET_PRIV"

# Create a temporary directory and temporary file for the download (portable mktemp)
TMPDIR="$(mktemp -d 2>/dev/null || mktemp -d -t update_regexes)"
if [[ -z "${TMPDIR:-}" || ! -d "$TMPDIR" ]]; then
    echo "Error: failed to create temporary directory." >&2
    exit 6
fi
TMPFILE="$TMPDIR/regexes.yaml"
cleanup() {
    rm -rf "$TMPDIR" || true
}
trap cleanup EXIT

echo "Downloading regexes.yaml from: $UAP_CORE_REPO_URL"
if command -v curl >/dev/null 2>&1; then
    curl -fsSL "$UAP_CORE_REPO_URL" -o "$TMPFILE" || {
        echo "Error: curl failed to download the file." >&2
        exit 2
    }
elif command -v wget >/dev/null 2>&1; then
    wget -qO "$TMPFILE" "$UAP_CORE_REPO_URL" || {
        echo "Error: wget failed to download the file." >&2
        exit 2
    }
else
    echo "Error: neither 'curl' nor 'wget' is available to download the file." >&2
    exit 3
fi

# Basic validation: file exists and not empty
if [[ ! -s "$TMPFILE" ]]; then
    echo "Error: downloaded file is empty." >&2
    exit 4
fi

# Basic content validation: ensure it looks like the uap-core regexes.yaml
# This file is expected to contain the 'user_agent_parsers' key at minimum.
if ! grep -q -E 'user_agent_parsers[[:space:]]*:' "$TMPFILE"; then
    echo "Warning: downloaded file does not look like a uap-core regexes.yaml (missing 'user_agent_parsers:' key)." >&2
    echo "Aborting to avoid replacing priv/regexes.yaml with an unexpected file." >&2
    exit 5
fi

DEST="$TARGET_PRIV/regexes.yaml"
if mv "$TMPFILE" "$DEST"; then
    # disable the trap removal since file has been moved
    trap - EXIT
    echo "Updated $DEST"
else
    echo "Error: failed to move temporary file to $DEST" >&2
    exit 7
fi
