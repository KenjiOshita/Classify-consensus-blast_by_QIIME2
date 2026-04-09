# 共有設定ファイル
# 他のスクリプトから source して使う

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# 解析フォルダ名。別データセットを使うときはここだけ変える。
ANALYSIS_NAME="${ANALYSIS_NAME:-HIroshimabay_2025_18S}"

ANALYSIS_DIR="$ROOT_DIR/analysis/$ANALYSIS_NAME"
DB_DIR="$ROOT_DIR/database"

# QIIME 2 環境名
ENV_NAME="${ENV_NAME:-qiime2-amplicon-2025.10}"

# SILVA データベース
SILVA_SEQS_URL="https://data.qiime2.org/2024.10/common/silva-138-99-seqs.qza"
SILVA_TAX_URL="https://data.qiime2.org/2024.10/common/silva-138-99-tax.qza"
