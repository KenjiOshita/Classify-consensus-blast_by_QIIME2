# Classify-consensus-blast_by_QIIME2

このリポジトリは、メタバーコーディング解析で得られた配列データに対し、QIIME 2の公式プラグイン（classify-consensus-blast）とSILVAデータベースを用いて系統分類を自動で行い、最終的にASVテーブル（TSV形式）を出力する手順をまとめたものです [cite: 56]。
[cite_start]これらの解析はWindowsでLunixが使える状態で実施可能です [cite: 8]。

## フォルダ構成（推奨）
[cite_start]解析データを整理するため、ホームディレクトリに専用のフォルダ構造を作成します [cite: 42]。
[cite_start]以下の構成になるようにファイルを配置してください [cite: 49]。

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
        └── map.txt     # サンプル情報（メタデータ）
```

---

## [cite_start]１．解析の準備（初回のみ）
[cite_start]この解析はメモリ（RAM）を大量に消費するため、必ずRAMが16GB以上（推奨32GB以上）のPCで実行してください。

### [cite_start]１－１．Minicondaのインストール
[cite_start]「Miniconda」をインストール（Lunixで実行）します [cite: 10][cite_start]。ホーム（拠点）ディレクトリで作業します 。

```bash
# [cite_start]ホームディレクトリへ移動
[cite_start]cd ~
# [cite_start]Linux用のMinicondaインストーラーをダウンロード
[cite_start]wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh 
# [cite_start]インストーラーを実行 
[cite_start]bash Miniconda3-latest-Linux-x86_64.sh 
```

**【インストール中の進め方】**
Enter キーを押し、ライセンス条項をスクロールして確認。Do you accept the license terms? [yes|no] → yes と入力して Enter。Press ENTER to confirm the location → そのまま Enter。by running conda init? [cite_start][yes|no] → yes と入力して Enter。

**【設定の反映】**
インストール完了後、以下のコマンドで設定を有効化します 。
```bash
source ~/.bashrc
```
これで、画面の左側に再び (base) が表示されれば、Linux版Minicondaのインストール完了です。以下のコマンドでバージョンが出るかを確認します。
```bash
conda -V [cite: 24]
```

### [cite_start]１－２．Qiime2 のダウンロード（mambaによる安定版構築） [cite: 25]
[cite_start]QIIME 2はデータが重く、標準の conda ではエラーが出やすいため、高速化ツール mamba を使用して安定版（2025.10）をインストールします [cite: 26]。

```bash
# 高速化ツール「mamba」の導入 [cite: 27]
conda install -n base -c conda-forge mamba -y [cite: 28]

# 2. QIIME 2（2025.10）の設計図をダウンロード [cite: 29]
wget https://raw.githubusercontent.com/qiime2/distributions/refs/heads/dev/2025.10/amplicon/released/qiime2-amplicon-ubuntu-latest-conda.yml [cite: 30]

# 3. mamba を使って環境構築（インストール）を実行 [cite: 31]
mamba env create --name qiime2-amplicon-2025.10 --file qiime2-amplicon-ubuntu-latest-conda.yml [cite: 32]

# ４.不要になった設定ファイルを削除 [cite: 33]
rm qiime2-amplicon-ubuntu-latest-conda.yml [cite: 34]
```

### １－３．データベースのダウンロード（初回のみ）
[cite_start]BLASTコンセンサス法では「配列」と「分類名」の2つのファイルを使用します。公式のSILVA 138データベースをダウンロードします [cite: 70]。

```bash
# [cite_start]databaseフォルダに移動 [cite: 71]
cd /mnt/e/Taxonomic_analysis/database

# [cite_start]SILVA 138の代表配列（seqs）と分類名（tax）をダウンロード [cite: 73]
[cite_start]wget https://data.qiime2.org/2024.10/common/silva-138-99-seqs.qza [cite: 74]
[cite_start]wget https://data.qiime2.org/2024.10/common/silva-138-99-tax.qza [cite: 75]
```

---

## ２．解析の実行（新しいデータが来るたびに実行）

### ２－１．準備：QIIME 2の起動とSSDへの移動
WSL（Ubuntu）を起動し、以下のコマンドでQIIME 2環境を有効化してから、SSD内の解析フォルダへ移動します [cite: 64]。
データの場所は外付けSSD（WSL上では /mnt/e/ や /mnt/d/ などとして認識されます）を想定しています [cite: 60, 61]。

```bash
# [cite_start]QIIME 2環境の有効化 [cite: 65]
# [cite_start]左側の文字が (base) から (qiime2-amplicon-2025.10) に変われば完了 [cite: 35]
[cite_start]conda activate qiime2-amplicon-2025.10 [cite: 36]

# 作業ディレクトリへ移動
cd /mnt/e/Taxonomic_analysis
```

### ２－２．一括解析スクリプトの実行
手動で行っていた「一致率97%（0.97）の閾値でコンセンサス分類」や「カウント表と系統分類の結合」を自動で実行します [cite: 79, 101]。

```bash
# 解析の実行（一番最後の解析フォルダ名「HIroshimabay_2025_18S」を適宜変更すること）
bash scripts/run_qiime2_blast.sh analysis/HIroshimabay_2025_18S
```

---

## ３．出力結果とグラフの確認方法（QIIME 2 View）

解析が完了すると、指定したフォルダ内に以下のファイルが作成されます。

### ① R解析・Excel閲覧用データ
- **`final_ASV_table.csv`**
  QIIME 2専用の .qza 形式から、汎用的なデータ形式を取り出します [cite: 92]。出力されたカウント表に、系統分類の文字列情報を結合し、Excel等で開けるTSV（タブ区切りテキスト）形式に変換したものをさらに整形したファイルです [cite: 103]。

### ② 系統組成棒グラフの作成（taxa-bar-plots.qzvの作成） [cite: 131]
サンプルごとの生物の割合（どんな生き物が、どれくらいいるか）を示す棒グラフを作成します [cite: 132]。作成された拡張子 .qzv のファイルは、専用のWebサイトで閲覧します [cite: 138]。

１．Windows側のエクスプローラーで作業フォルダを開きます [cite: 139]。
２．ブラウザで QIIME 2 View にアクセスします [cite: 140]。
３．確認したいファイル（taxa-bar-plots.qzv など）をブラウザの画面上にドラッグ＆ドロップします [cite: 141]。

**【グラフの操作方法】**
- **Taxonomic Level:** グラフ上部のメニューからレベルを変更することで、「門(Phylum)」「綱(Class)」など、分類の解像度を自由に変えらます [cite: 142]。
- **Sort / Color:** メタデータ（map.txt に記載されたサンプルの採取場所や条件など）に基づいて、グラフの並び替えや色分けが可能です [cite: 143]。

---

