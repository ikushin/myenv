#!/bin/python3
#!/bin/python3 xlsx2csv.py ./a.xlsx
#

# coding: utf-8
import openpyxl
import re
import sys
import os
import csv

# 引数処理
args = sys.argv
xlsx = args[1]

dest_dir = "./out"
os.makedirs(dest_dir, exist_ok=True)


# ブックを読み込み
book = openpyxl.load_workbook(xlsx, data_only=True)

# シートでループ
for sheet in book.worksheets:
    sheet_name = sheet.title  # シート名を取得
    dest_path = os.path.join(dest_dir, sheet_name + '.csv')

    with open(dest_path, 'w', encoding='utf-8') as fp:
        writer = csv.writer(fp)

        for cols in sheet.rows:
            writer.writerow([str(col.value or '') for col in cols])
