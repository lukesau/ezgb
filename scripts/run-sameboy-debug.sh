#!/usr/bin/env bash
# Thin wrapper so the debug flow matches other scripts/*.sh.
exec "$(dirname "$0")/run-sameboy-debug.py" "$@"
