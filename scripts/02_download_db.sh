#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "$0")" && pwd)/config.sh"

mkdir -p "$DB_DIR"
cd "$DB_DIR"

if [ ! -f silva-138-99-seqs.qza ]; then
  echo "Downloading SILVA sequences..."
  wget "$SILVA_SEQS_URL"
else
  echo "SILVA sequences already exist."
fi

if [ ! -f silva-138-99-tax.qza ]; then
  echo "Downloading SILVA taxonomy..."
  wget "$SILVA_TAX_URL"
else
  echo "SILVA taxonomy already exist."
fi
