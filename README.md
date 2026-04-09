# Classify-consensus-blast_by_QIIME2

このリポジトリは、メタバーコーディング解析（16S/18S rRNA等）で得られた配列データ（ASV/OTU）に対し、QIIME 2の公式プラグイン（`classify-consensus-blast`）とSILVAデータベースを用いて系統分類を自動で行い、最終的にASVテーブルやグラフを出力するツール一式です。
これらの解析は、WindowsでLinux（WSL）が使える状態で実施可能です。

## 特徴
- **自動化:** フォルダ名を指定するだけで、系統分類から可視化（棒グラフ作成）、R解析用のCSV出力まで一括実行します。
- **エラー回避:** QIIME 2（BIOMツール）特有の「系統名が短い場合にエクスポートが止まるバグ」を回避するスクリプトを同梱しています。
- **階級分割:** 系統情報を「門・綱・目・科・属・種」の列に自動分割してCSV出力します。

## フォルダ構成（推奨）
解析をスムーズに行うため、以下のようなフォルダ構成を推奨します。

```text
Taxonomic_analysis/
├── scripts/       # GitHubからダウンロードしたスクリプト
│   ├── run_qiime2_blast.sh
│   └── convert_to_csv_split.py
├── database/      # SILVAの巨大なデータを入れる場所
└── analysis/      # 自分の解析データを入れる場所
    └── HIroshimabay_2025_18S/ 
        ├── repset.qza  # キメラ除去済みのASV代表配列
        ├── table.qza   # ASVのカウント表
        └── map.txt     # サンプル情報（メタデータ）
```
##１．解析の準備（初回のみ）
この解析はメモリを大量に消費するため、RAMが16GB以上（推奨32GB以上）のPCで実行してください。ターミナルを立ち上げ、以下の手順で環境を構築します。

#１－１．Minicondaのインストール
Windows上のLinux環境に、Python等を管理するMinicondaをインストールします。

Bash
# ホームディレクトリへ移動
cd ~

# Linux用のMinicondaインストーラーをダウンロード
wget [https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh](https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh)

# インストーラーを実行
bash Miniconda3-latest-Linux-x86_64.sh
【インストール中の進め方】
Enter キーを押し、ライセンス条項をスクロールして確認。Do you accept the license terms? [yes|no] → yes と入力して Enter。Press ENTER to confirm the location → そのまま Enter。by running conda init? [yes|no] → yes と入力して Enter。

インストール完了後、設定を反映させます。

Bash
source ~/.bashrc
# 画面左側に (base) が表示されれば完了。以下のコマンドでバージョンが出れば成功です。
conda -V
#１－２．QIIME 2 のダウンロード（mambaによる安定版構築）
QIIME 2はデータが重く、標準の conda ではエラーが出やすいため、高速化ツール mamba を使用して安定版（2025.10）をインストールします。

Bash
conda install -n base -c conda-forge mamba -y
wget [https://raw.githubusercontent.com/qiime2/distributions/refs/heads/dev/2025.10/amplicon/released/qiime2-amplicon-ubuntu-latest-conda.yml](https://raw.githubusercontent.com/qiime2/distributions/refs/heads/dev/2025.10/amplicon/released/qiime2-amplicon-ubuntu-latest-conda.yml)
mamba env create --name qiime2-amplicon-2025.10 --file qiime2-amplicon-ubuntu-latest-conda.yml
１－３．SILVAデータベースの準備
database/ フォルダへ移動し、SILVA 138の代表配列（seqs）と分類名（tax）をダウンロードします。

Bash
# databaseフォルダに移動
cd /mnt/e/Taxonomic_analysis/database

wget [https://data.qiime2.org/2024.10/common/silva-138-99-seqs.qza](https://data.qiime2.org/2024.10/common/silva-138-99-seqs.qza)
wget [https://data.qiime2.org/2024.10/common/silva-138-99-tax.qza](https://data.qiime2.org/2024.10/common/silva-138-99-tax.qza)


##２．解析の実行（新しいデータが来るたびに実行）
#２－１．解析フォルダとファイルの準備
ルール：analysis/ の中にプロジェクトごとのフォルダを作ります。入力ファイル名は必ず repset.qza、table.qza、map.txt の3つに統一して配置してください。

#２－２．一括解析スクリプトの実行
ターミナルを起動し、作業ディレクトリへ移動してから、QIIME 2環境を立ち上げます。その後、フォルダ名を指定してスクリプトを実行します。

Bash
# 作業ディレクトリへ移動
cd /mnt/e/Taxonomic_analysis

# 1. QIIME 2環境の起動
conda activate qiime2-amplicon-2025.10

# 2. 解析の実行（一番最後のフォルダ名「HIroshimabay_2025_18S」を適宜変更すること）
bash scripts/run_qiime2_blast.sh analysis/HIroshimabay_2025_18S
※本スクリプトにより、一致率97%（0.97）でのコンセンサス分類から、CSVデータの整形、QZVファイルの作成までが全自動で行われます。

##３．出力結果の確認
解析が完了すると、指定したフォルダ（例：analysis/HIroshimabay_2025_18S/）内に以下のファイルが作成されます。

① R解析・Excel閲覧用データ

final_ASV_table.csv
QIIME 2のハッシュIDを「ASV_0001」形式に変換し、系統分類を「Domain, Phylum, Class, Order, Family, Genus, Species」の7列に分割結合したCSVファイルです。後続のR（phyloseq等）での解析にそのまま使用できます。

② QIIME 2による群集組成の可視化データ
専用のWebサイト QIIME 2 View に以下のファイルをドラッグ＆ドロップして閲覧します。

taxa-bar-plots.qzv: サンプルごとの生物組成（どんな生き物が、どれくらいいるか）を示すインタラクティブな棒グラフです。

taxonomy.qzv: 各配列（ASV）にどのような生物名が割り当てられたかを確認できる詳細テーブルです。
