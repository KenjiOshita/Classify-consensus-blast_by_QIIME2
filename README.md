# Classify-consensus-blast_by_QIIME2

このリポジトリは、メタバーコーディング解析で得られた配列データに対し、QIIME 2の公式プラグイン（classify-consensus-blast）とSILVAデータベースを用いて系統分類を自動で行い、最終的にASVテーブル（CSV形式）を出力する手順をまとめたものです。PCのスペックが高くなくても系統分類の自動化できる解析方法です。RAMが16GB以上あるPCの場合は、機械学習などより高度なアルゴリズムを用いた系統分類が可能であり、本解析方法はそのような解析ができないが、系統分類を自動化したい場合に適しています。注意：これらの解析はWindowsでLunixが使える状態で実施可能です。Lunixをダウンロード済みのPCで実行してください。

## フォルダ構成（推奨）
解析データを整理するため、ホームディレクトリに専用のフォルダ構造を作成します。
以下の構成になるようにファイルを配置してください。

```text
Taxonomic_analysis/ 
├── scripts/       # 解析に使用するスクリプトを保存 
│   ├── run_qiime2_blast.sh
│   └── convert_to_csv_split.py
├── database/      # SILVAなどのデータベースを保存 
└── analysis/      
    └── HIroshimabay_2025_18S/ # 生物技研から提供されたファイル「repset.qza」「table.qza」をここに入れる 
        ├── repset.qza  # キメラ除去済みのASV代表配列 
        ├── table.qza   # ASVのカウント表 
        └── convert.txt     # サンプル情報（メタデータ）
```

---

## １．解析の準備（初回のみ）

### １－１．Minicondaのインストール
「Miniconda」をインストール（Lunixで実行）します 。ホーム（拠点）ディレクトリで作業します 。

```bash
# ホームディレクトリへ移動
cd ~
# Linux用のMinicondaインストーラーをダウンロード
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh 
# インストーラーを実行 
bash Miniconda3-latest-Linux-x86_64.sh 
```

**【インストール中の進め方】**
Enter キーを押し、ライセンス条項をスクロールして確認。Do you accept the license terms? [yes|no] → yes と入力して Enter。Press ENTER to confirm the location → そのまま Enter。by running conda init? → yes と入力して Enter。

**【設定の反映】**
インストール完了後、以下のコマンドで設定を有効化します 。
```bash
source ~/.bashrc
```
これで、画面の左側に再び (base) が表示されれば、Linux版Minicondaのインストール完了です。以下のコマンドでバージョンが出るかを確認します。
```bash
conda -V
```

### １－２．Qiime2 のダウンロード（mambaによる安定版構築）
QIIME 2はデータが重く、標準の conda ではエラーが出やすいため、高速化ツール mamba を使用して安定版（2025.10）をインストールします。

```bash
# 高速化ツール「mamba」の導入
conda install -n base -c conda-forge mamba -y 

# 2. QIIME 2（2025.10）の設計図をダウンロード 
wget https://raw.githubusercontent.com/qiime2/distributions/refs/heads/dev/2025.10/amplicon/released/qiime2-amplicon-ubuntu-latest-conda.yml 

# 3. mamba を使って環境構築（インストール）を実行
mamba env create --name qiime2-amplicon-2025.10 --file qiime2-amplicon-ubuntu-latest-conda.yml 

# ４.不要になった設定ファイルを削除 
rm qiime2-amplicon-ubuntu-latest-conda.yml 
```

### １－３．データベースのダウンロード（初回のみ）
BLASTコンセンサス法では「配列」と「分類名」の2つのファイルを使用します。公式のSILVA 138データベースをダウンロードします。

```bash
# databaseフォルダに移動
cd /mnt/e/Taxonomic_analysis/database

#SILVA 138の代表配列（seqs）と分類名（tax）をダウンロード 
wget https://data.qiime2.org/2024.10/common/silva-138-99-seqs.qza 
wget https://data.qiime2.org/2024.10/common/silva-138-99-tax.qza 
```

---

## ２．解析の実行

### ２－１．準備：QIIME 2の起動とフォルダへの移動
WSL（Ubuntu）を起動し、以下のコマンドでQIIME 2環境を有効化してから、フォルダ（ここではSSD内の解析フォルダ）へ移動します。
データの場所は外付けSSD（WSL上では /mnt/e/ として認識されます）を想定しています。

```bash
# QIIME 2環境の有効化
# 左側の文字が (base) から (qiime2-amplicon-2025.10) に変われば完了
[cite_start]conda activate qiime2-amplicon-2025.10 

# 作業ディレクトリへ移動
cd /mnt/e/Taxonomic_analysis
```

### ２－２．一括解析スクリプトの実行
一致率97%（0.97）の閾値でコンセンサス分類とカウント表と系統分類の結合を自動で実行します。条件は、後の解析で使用したいデータの分類階級ごとに変更してください。

```bash
# 解析の実行（一番最後の解析フォルダ名「HIroshimabay_2025_18S」を適宜変更すること）
bash scripts/run_qiime2_blast.sh analysis/HIroshimabay_2025_18S
```

---

## ３．出力結果とグラフの確認方法（QIIME 2 View）

解析が完了すると、指定したフォルダ内に以下のファイルが作成されます。

### ① R解析・Excel閲覧用データ
- **`final_ASV_table.csv`**
  QIIME 2専用の .qza 形式から、汎用的なデータ形式を取り出します。出力されたカウント表に、系統分類の文字列情報を結合し、Excel等で開けるTSV（タブ区切りテキスト）形式に変換したものをさらに整形したファイルです。

### ② 系統組成棒グラフの作成（taxa-bar-plots.qzvの作成）
サンプルごとの生物の割合を示す棒グラフを作成します 。作成された拡張子 .qzv のファイルは、専用のWebサイトで閲覧します 。

１．Windows側のエクスプローラーで作業フォルダを開きます。
２．ブラウザで QIIME 2 View にアクセスします。
３．確認したいファイル（taxa-bar-plots.qzv など）をブラウザの画面上にドラッグ＆ドロップします。

**【グラフの操作方法】**
- **Taxonomic Level:** グラフ上部のメニューからレベルを変更することで、門(Phylum)綱(Class)」など分類の解像度を自由に変えらます。
- **Sort / Color:** メタデータ（map.txt に記載されたサンプルの採取場所や条件など）に基づいて、グラフの並び替えや色分けが可能です。

---

