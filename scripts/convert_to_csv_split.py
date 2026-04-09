#!/usr/bin/env python3
import csv
import os

# 実行場所のパスを確認（必要に応じて）
# 入力ファイルのパス設定
f_convert = 'convert.txt'
f_counts = 'asv_counts.tsv'
f_tax = 'exported-taxonomy/taxonomy.tsv'
f_output = 'final_ASV_table.csv'

# 1. ID辞書の作成
id_map = {}
if os.path.exists(f_convert):
    with open(f_convert, 'r') as f:
        for line in f:
            parts = line.strip().split()
            if len(parts) >= 2: id_map[parts[0]] = parts[1]

# 2. 系統分類辞書の作成
tax_map = {}
if os.path.exists(f_tax):
    with open(f_tax, 'r') as f:
        reader = csv.reader(f, delimiter='\t')
        for row in reader:
            if row and not row[0].startswith('#'): tax_map[row[0]] = row[1]

# 3. カウント表の読み込みと分割書き出し
if os.path.exists(f_counts):
    with open(f_counts, 'r') as fin, open(f_output, 'w', newline='') as fout:
        reader = csv.reader(fin, delimiter='\t')
        writer = csv.writer(fout, delimiter=',')
        tax_headers = ['Domain', 'Phylum', 'Class', 'Order', 'Family', 'Genus', 'Species']
        
        for row in reader:
            if not row or row[0].startswith('# Constructed'): continue
            if row[0].startswith('#OTU ID'):
                row[0] = 'ASV_ID'
                row.extend(tax_headers)
                writer.writerow(row)
                continue
            hash_id = row[0]
            if hash_id in id_map: row[0] = id_map[hash_id]
            tax_string = tax_map.get(hash_id, 'Unassigned')
            if tax_string == 'Unassigned':
                tax_levels = ['Unassigned'] + [''] * 6
            else:
                tax_levels = [t.strip() for t in tax_string.split(';')]
                while len(tax_levels) < 7: tax_levels.append('')
                tax_levels = tax_levels[:7]
            row.extend(tax_levels)
            writer.writerow(row)
    print(f"Success: {f_output} has been created.")
else:
    print(f"Error: {f_counts} not found.")