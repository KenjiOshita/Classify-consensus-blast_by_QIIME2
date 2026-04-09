#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "$0")" && pwd)/config.sh"

mkdir -p "$ANALYSIS_DIR"
mkdir -p "$DB_DIR"
mkdir -p "$ROOT_DIR/docs/images"

echo "Created directories:"
echo "  $ANALYSIS_DIR"
echo "  $DB_DIR"
echo "  $ROOT_DIR/docs/images"
