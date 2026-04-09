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

if [ ! -f map.txt ]; then
  echo "Missing map.txt." >&2
  exit 1
fi

echo "Creating taxonomy.qzv..."
qiime metadata tabulate \
  --m-input-file my_taxonomy_blast.qza \
  --o-visualization taxonomy.qzv

echo "Creating taxa-bar-plots.qzv..."
qiime taxa barplot \
  --i-table table.qza \
  --i-taxonomy my_taxonomy_blast.qza \
  --m-metadata-file map.txt \
  --o-visualization taxa-bar-plots.qzv

echo "Visualization finished."
