VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "elements"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = True
Option Explicit

Const COL_NAME_JP = 1

Private Sub Worksheet_SelectionChange(ByVal Target As Range)
  '// ペースト無効
  Application.CutCopyMode = False
End Sub

'// データLoad(From yaml)
Public Sub load(ByVal data As String)
  Dim records() As String, items() As String
  Dim i As Long, rowLength As Long

  '// 初期化
  UsedRange.Offset(1).clear

  '// 行ごとのデータに分割
  records = Split(data, vbLf)
  rowLength = UBound(records)
  ReDim wkRange(rowLength - 1, 7)
  
  '// 列ごとの配列に変換
  For i = 0 To rowLength - 1
    items = Split(records(i), vbTab)

    wkRange(i, 0) = items(0) '名称_和
    wkRange(i, 1) = items(1) '名称_英
    wkRange(i, 2) = items(2) 'DB型
    wkRange(i, 3) = items(3) 'チェック制約
    wkRange(i, 4) = items(4) '強制NOTNULL
    wkRange(i, 5) = items(5) '説明
    wkRange(i, 6) = items(6) '派生項目
    wkRange(i, 7) = items(7) '派生元
  Next i

  '// 値セット
  Cells(2, COL_NAME_JP).Resize(rowLength, 8) = wkRange

  '// フォーマット
  Call areaFormat
End Sub

'// フォーマット
Private Sub areaFormat()

  '// 枠線
  Call Formatter.borderAndFontsize(Range("DATA_AREA"))

  '// 背景色
  Call Formatter.notInput(Range("DATA_AREA"))

  '// 表示形式
  Call Formatter.formatLocal(Range("DATA_AREA_G"), """○"";;;")

  '// 表示形式
  Call Formatter.horizontalPosition(Range("DATA_AREA_G"), xlCenter)

End Sub
