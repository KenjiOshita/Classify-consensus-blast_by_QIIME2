#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "$0")" && pwd)/config.sh"

source "$(conda info --base)/etc/profile.d/conda.sh"
conda activate "$ENV_NAME"

cd "$ANALYSIS_DIR"

if [ ! -d exported-table ] || [ ! -d exported-taxonomy ]; then
  echo "Exported folders not found. Run scripts/04_export_results.sh first." >&2
  exit 1
fi

if [ ! -f exported-table/feature-table.biom ]; then
  echo "Missing exported-table/feature-table.biom" >&2
  exit 1
fi

if [ ! -f exported-taxonomy/taxonomy.tsv ]; then
  echo "Missing exported-taxonomy/taxonomy.tsv" >&2
  exit 1
fi

# QIIME2 export の taxonomy.tsv は 1行目を調整して biom に渡しやすくする
sed -i '1s/^Feature ID/#OTU ID/' exported-taxonomy/taxonomy.tsv

echo "Adding taxonomy metadata to biom..."
biom add-metadata \
  -i exported-table/feature-table.biom \
  -o table-with-taxonomy.biom \
  --observation-metadata-fp exported-taxonomy/taxonomy.tsv \
  --sc-separated taxonomy

echo "Converting feature table to TSV..."
biom convert \
  -i exported-table/feature-table.biom \
  -o asv_counts.tsv \
  --to-tsv

echo "Table creation finished."
