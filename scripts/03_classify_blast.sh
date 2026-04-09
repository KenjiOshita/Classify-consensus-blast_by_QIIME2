#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "$0")" && pwd)/config.sh"

# 必要ファイルの確認
for f in repset.qza table.qza map.txt; do
  if [ ! -f "$ANALYSIS_DIR/$f" ]; then
    echo "Missing file: $ANALYSIS_DIR/$f" >&2
    exit 1
  fi
done

if [ ! -f "$DB_DIR/silva-138-99-seqs.qza" ] || [ ! -f "$DB_DIR/silva-138-99-tax.qza" ]; then
  echo "SILVA database not found. Run scripts/02_download_db.sh first." >&2
  exit 1
fi

# conda を非対話シェルで使えるようにする
source "$(conda info --base)/etc/profile.d/conda.sh"
conda activate "$ENV_NAME"

cd "$ANALYSIS_DIR"

echo "Running classify-consensus-blast..."
qiime feature-classifier classify-consensus-blast \
  --i-query repset.qza \
  --i-reference-reads "$DB_DIR/silva-138-99-seqs.qza" \
  --i-reference-taxonomy "$DB_DIR/silva-138-99-tax.qza" \
  --p-perc-identity 0.97 \
  --p-query-cov 0.80 \
  --p-maxaccepts 10 \
  --p-min-consensus 0.51 \
  --o-classification my_taxonomy_blast.qza \
  --o-search-results search_results.qza

echo "Classification finished."
