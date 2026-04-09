# Classify-consensus-blast_by_QIIME2

このリポジトリは、メタバーコーディング解析（16S/18S rRNA等）で得られた配列データに対し、QIIME 2の公式プラグイン（`classify-consensus-blast`）とSILVAデータベースを用いて系統分類を自動で行うためのツール一式です。
Windows上のLinux環境（WSL2）で動作するように最適化されています。

## 特徴
- **自動化:** フォルダ名を指定するだけで、系統分類から可視化（棒グラフ作成）、R解析用のCSV出力まで一括実行します。
- **エラー回避:** QIIME 2（BIOMツール）特有の「系統名が短い場合にエクスポートが止まるバグ」を回避するスクリプトを同梱しています。
- **階級分割:** 系統情報を「門・綱・目・科・属・種」の列に自動分割してCSV出力します。

## フォルダ構成（推奨）
解析データを整理するため、以下の構成を前提としています。

```text
Taxonomic_analysis/
├── scripts/       # 本リポジトリのスクリプト
│   ├── run_qiime2_blast.sh
│   └── convert_to_csv_split.py
├── database/      # SILVAデータベースを配置
└── analysis/      # 解析プロジェクトごとにフォルダを作成
    └── HIroshimabay_2025_18S/ 
        ├── repset.qza  # DADA2等で得られた代表配列
        ├── table.qza   # ASVカウント表
        └── map.txt     # サンプル情報（メタデータ）
セットアップ手順（初回のみ）
1. QIIME 2 (2025.10) のインストール
高速化ツール mamba を使用して環境を構築します。

Bash
conda install -n base -c conda-forge mamba -y
wget [https://raw.githubusercontent.com/qiime2/distributions/refs/heads/dev/2025.10/amplicon/released/qiime2-amplicon-ubuntu-latest-conda.yml](https://raw.githubusercontent.com/qiime2/distributions/refs/heads/dev/2025.10/amplicon/released/qiime2-amplicon-ubuntu-latest-conda.yml)
mamba env create --name qiime2-amplicon-2025.10 --file qiime2-amplicon-ubuntu-latest-conda.yml
2. SILVAデータベースの準備
database/ フォルダ内で実行し、SILVA 138のQZAファイルをダウンロードします。

Bash
cd database
wget [https://data.qiime2.org/2024.10/common/silva-138-99-seqs.qza](https://data.qiime2.org/2024.10/common/silva-138-99-seqs.qza)
wget [https://data.qiime2.org/2024.10/common/silva-138-99-tax.qza](https://data.qiime2.org/2024.10/common/silva-138-99-tax.qza)
解析の実行手順
新しいデータを解析するたびに以下のコマンドを実行します。

1. 解析フォルダの準備
analysis/ 内に新しいフォルダ（例：Project_A）を作り、そこに repset.qza, table.qza, map.txt を配置します。

2. スクリプトの実行
QIIME 2環境を起動し、フォルダ名を指定して実行します。

Bash
# QIIME 2の起動
conda activate qiime2-amplicon-2025.10

# 解析の実行（フォルダ名は適宜変更してください）
bash scripts/run_qiime2_blast.sh analysis/HIroshimabay_2025_18S
出力結果
実行完了後、指定したフォルダ内に以下のファイルが生成されます。

final_ASV_table.csv:
ハッシュIDを「ASV_0001」形式に変換し、系統情報を門〜種まで列分割したCSV。そのままExcelやRで読み込めます。

taxa-bar-plots.qzv:
サンプルごとの組成棒グラフ。QIIME 2 Viewにドラッグ＆ドロップして閲覧してください。

taxonomy.qzv:
各ASVの分類結果詳細。
