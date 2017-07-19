#!/usr/bin/python3
#
import sys
import re
import openpyxl
import datetime

# コピー先シート名
nss = [
    "aaa",
    "bbb",
    "ccc",
]

# ブック
f=sys.argv[1]

# コピー元シート名
s='Sheet1'

# 新規ブック名
_d = datetime.datetime.today()
d = _d.strftime("%Y%m%d")
nf = re.sub(r'_\d{8}[a-z]', '_' + d + 'x' , f)

# ブック・シートopen
wb = openpyxl.load_workbook(f)
ws = wb.get_sheet_by_name(s)

# シートコピー
for ns in nss :
    dist = wb.copy_worksheet(ws)
    dist.title = ns

# save
wb.save(nf)
