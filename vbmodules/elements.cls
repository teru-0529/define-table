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

'カラム番号
Private Enum col_no
  項目名J = 1
  項目名ES = 2
  データ型 = 3
  チェック制約 = 4
  強制NOTNULL = 5
  文字列デフォルト有無 = 6
  説明 = 7
  派生項目 = 8
  派生項目名 = 9
End Enum
  
Const max_col = 9


'フォーマット初期化
Public Sub init_format(ByVal start_row As Integer, ByVal rows As Integer)
  Application.EnableEvents = False
  
  Dim f_rows As Integer: f_rows = rows  'フォーマット化行数
  If f_rows = 0 Then Exit Sub

  '初期行以降をクリア
  UsedRange.Offset(start_row - 1).clear
  
  '枠線
  With Cells(start_row, 1).Resize(f_rows, max_col)
    .Interior.Color = RGB(255, 255, 213) 'CREAM
    .Borders.LineStyle = xlContinuous
    .Borders.Color = RGB(68, 114, 196) 'DEEP_BLUE
    .Borders(xlEdgeTop).Color = RGB(189, 215, 238) 'WEAK_BLUE
    .Borders(xlInsideHorizontal).Color = RGB(189, 215, 238) 'WEAK_BLUE
    .Font.Size = 9
  End With

  '表示形式
  Cells(start_row, col_no.派生項目).Resize(f_rows).NumberFormatLocal = """○"";;;"
  
  '表示形式
  Cells(start_row, col_no.派生項目).Resize(f_rows).HorizontalAlignment = xlCenter
  
  Application.EnableEvents = True
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
  ReDim wkRange1(rowLength - 1, 8)
  
  '// 列ごとの配列に変換
  For i = 0 To rowLength - 1
    items = Split(records(i), vbTab)

    wk_range(i, 0) = items(0) '名称_和
    wk_range(i, 1) = items(1) '名称_英
    wk_range(i, 2) = items(2) 'DB型
    wk_range(i, 3) = items(3) 'チェック制約
    wk_range(i, 4) = items(4) '強制NOTNULL
    wk_range(i, 5) = items(5) '文字列デフォルト有無
    wk_range(i, 6) = items(6) '説明
    wk_range(i, 7) = items(7) '派生項目
    wk_range(i, 8) = items(8) '派生元
    
  Next i

  '// 値セット
  Cells(2, COL_NAME_JP).Resize(row_length, 9) = wk_range

  '// フォーマット
  Call areaFormat
End Sub

'// フォーマット
Private Sub areaFormat()
  Application.ScreenUpdating = False
  Application.EnableEvents = False
  
  '// 枠線
  Call Formatter.borderAndFontsize(Range("ELEM_FULL"))

  '// 背景色
  Call Formatter.notInput(Range("ELEM_FULL"))
  
  '// 表示形式
  Call Formatter.formatLocal(Range("ELEM_H"), """○"";;;")

  '// 表示形式
  Call Formatter.horizontalPosition(Range("ELEM_H"), xlCenter)
  
  Application.EnableEvents = True
  Application.ScreenUpdating = True
End Sub

'table_elements読込
Public Sub load_(ByVal line_sep As Integer)
  Const PARAMS = 10
  Dim data() As String, row_length As Long
  Dim i As Long
  
  data = text_io.plain_in(ELEMENTS_DATA, line_sep)
  row_length = (UBound(data) + 1) / PARAMS
  ReDim wk_range(row_length - 1, 8)
  
  '描画箇所のフォーマット
  Call init_format(2, row_length)
  
  For i = 0 To row_length - 1
    wk_range(i, 0) = from_yaml(data(i * PARAMS + 0)) '名称_和
    wk_range(i, 1) = from_yaml(data(i * PARAMS + 1)) '名称_英
    wk_range(i, 2) = from_yaml(data(i * PARAMS + 2)) 'DB型
    wk_range(i, 3) = from_yaml(data(i * PARAMS + 3)) 'チェック制約
    wk_range(i, 4) = from_yaml(data(i * PARAMS + 4)) '強制NOTNULL
    wk_range(i, 5) = from_yaml(data(i * PARAMS + 5)) '文字列デフォルト有無
    wk_range(i, 6) = from_yaml(data(i * PARAMS + 6)) '説明
    If from_yaml(data(i * PARAMS + 7)) = "true" Then wk_range(i, 7) = 0 Else wk_range(i, 7) = 1 'ドメイン
    wk_range(i, 8) = from_yaml(data(i * PARAMS + 8)) '派生元
  Next i
    
  '値セット
  Cells(2, col_no.項目名J).Resize(row_length, 9) = wk_range
  
End Sub

