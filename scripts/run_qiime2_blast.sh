#!/bin/bash

# エラーが起きたらそこで止める設定
set -e

# 引数（フォルダ名）の確認
TARGET_DIR=$1
if [ -z "$TARGET_DIR" ]; then
  echo "エラー: 解析するフォルダを指定してください。"
  echo "例: bash scripts/run_qiime2_blast.sh analysis/HIroshimabay_2025_18S"
  exit 1
fi

# フルパスの取得
WORK_DIR="/mnt/e/Taxonomic_analysis/${TARGET_DIR}"

if [ ! -d "$WORK_DIR" ]; then
  echo "エラー: フォルダが見つかりません -> $WORK_DIR"
  exit 1
fi

echo "=========================================="
echo "QIIME 2 解析を開始します: $TARGET_DIR"
echo "=========================================="

# 作業ディレクトリへ移動
cd "$WORK_DIR"

# 1. 系統分類の実行 (コンセンサスBLAST)
echo "1/4 系統分類を実行中..."
qiime feature-classifier classify-consensus-blast \
  --i-query repset.qza \
  --i-reference-reads ../../database/silva-138-99-seqs.qza \
  --i-reference-taxonomy ../../database/silva-138-99-tax.qza \
  --p-perc-identity 0.97 \
  --p-query-cov 0.80 \
  --p-maxaccepts 10 \
  --p-min-consensus 0.51 \
  --o-classification my_taxonomy_blast.qza \
  --o-search-results search_results.qza

# 2. データの書き出し (エクスポート)
echo "2/4 データをエクスポート中..."
qiime tools export --input-path table.qza --output-path exported-table
qiime tools export --input-path my_taxonomy_blast.qza --output-path exported-taxonomy

# 3. カウント表のTSV化
echo "3/4 CSVデータを作成中..."
biom convert -i exported-table/feature-table.biom -o asv_counts.tsv --to-tsv

# Pythonスクリプトの実行 (パスを調整して実行)
python3 ../../scripts/convert_to_csv_split.py

# 4. 可視化 (QZVの作成)
echo "4/4 グラフを作成中..."
qiime metadata tabulate --m-input-file my_taxonomy_blast.qza --o-visualization taxonomy.qzv
qiime taxa barplot --i-table table.qza --i-taxonomy my_taxonomy_blast.qza --m-metadata-file map.txt --o-visualization taxa-bar-plots.qzv

echo "=========================================="
echo "解析が完了しました！"
echo "作成されたファイル:"
echo " - final_ASV_table.csv (R解析用)"
echo " - taxa-bar-plots.qzv (QIIME 2 View用)"
echo "=========================================="
