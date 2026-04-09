# QIIME 2 classify-consensus-blast workflow (18S)

このリポジトリは、QIIME 2 を用いて 18S 配列の系統分類を行い、ASV テーブルと可視化ファイルを作成するための手順をまとめたものです。
処理は段階ごとに分けてあり、どこで失敗したかを追いやすい構成にしています。

## このリポジトリの考え方
- 初回だけやる作業と、毎回の解析作業を分ける
- 1本のスクリプトにまとめず、工程ごとに分ける
- ファイル名が変わっても、設定1か所の変更で再利用できる

## フォルダの役割
- analysis/ : 解析データを置く場所
- database/ : 参照データベースを置く場所
- scripts/ : 実行スクリプト
- docs/ : 図

## 初回だけやること
1. フォルダ作成
   bash scripts/01_prepare_dirs.sh

2. データベース取得
   bash scripts/02_download_db.sh

3. QIIME2確認
   conda activate qiime2-amplicon-2025.10

## 毎回やること
1. データを配置
   analysis/HIroshimabay_2025_18S/ に以下を置く
   - repset.qza
   - table.qza
   - map.txt

2. 系統分類
   bash scripts/03_classify_blast.sh

3. export
   bash scripts/04_export_results.sh

4. テーブル作成
   bash scripts/05_make_tables.sh

5. 可視化
   bash scripts/06_make_visualization.sh

## フォルダ名を変える場合
scripts/config.sh の以下を変更：

ANALYSIS_NAME="新しいフォルダ名"

または一時的に：

ANALYSIS_NAME=NewData bash scripts/03_classify_blast.sh

## 注意
- analysis/ はGitに含めない
- database/ もGitに含めない
- スクリプトだけ共有する
