#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "$0")" && pwd)/config.sh"

source "$(conda info --base)/etc/profile.d/conda.sh"
conda activate "$ENV_NAME"

cd "$ANALYSIS_DIR"

if [ ! -f my_taxonomy_blast.qza ]; then
  echo "Missing my_taxonomy_blast.qza. Run scripts/03_classify_blast.sh first." >&2
  exit 1
fi

echo "Exporting table..."
qiime tools export \
  --input-path table.qza \
  --output-path exported-table

echo "Exporting taxonomy..."
qiime tools export \
  --input-path my_taxonomy_blast.qza \
  --output-path exported-taxonomy

echo "Export finished."
