VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "index_sht"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = True
Option Explicit

' ダブルクリック時の処理（新規テーブル作成）
Private Sub Worksheet_BeforeDoubleClick(ByVal Target As Range, Cancel As Boolean)
  Dim rc As Integer, temp As Worksheet

  '「シート作成」のセルが対象の場合のみ処理する
  If Target.Column = 2 And Target.Value = 1 Then
    rc = MsgBox("テーブルシートを作成します。よろしいですか？", vbYesNo + vbQuestion, "作成確認")
  
    Application.ScreenUpdating = False
    Application.EnableEvents = False
    If rc = vbYes Then Set temp = create_table_sheet(Target)
    Application.EnableEvents = True
    Application.Calculate
    Application.ScreenUpdating = True
  End If
  
  Cancel = True

End Sub

'// データLoad(From yaml)
Public Sub load(ByVal data As String)
  Dim records() As String
  Dim i As Long, rowLength As Long

  '// 初期化
  'Call init

  '// 行ごとのデータに分割
  records = Split(data, vbLf)
  rowLength = UBound(records)

    Debug.Print rowLength

  '// 列ごとの配列に変換
  For i = 0 To rowLength - 1
    Debug.Print records(i)
    Debug.Print ""
  Next i

'Debug.Print data
End Sub

'// 初期化処理（☆☆☆）
Public Sub init()
  Range("DATA_AREA").ClearContents
  Tables.Delete
End Sub

'// テーブル削除
Public Sub dropTable(ByVal tableNo As Long)
  Util.unionRange(Cells(tableNo + 1, 3), Cells(tableNo + 1, 6)).ClearContents
End Sub

  '// FIXME:★★★★★
' 新規テーブルの作成
Public Function create_table_sheet(Target As Range) As Worksheet
  Dim table_name_jp As String, table_name_en As String
  
  table_name_jp = Target.Offset(, 2).Value
  table_name_en = Target.Offset(, 3).Value
  Set create_table_sheet = table_sheets.create_table_sheet(Worksheets(index), Target.Row - 1, table_name_jp, table_name_en)
  
  'ハイパーリンク設定
  Call Formatter.addLink(index_sht, Target.Offset(, 1), "'" & table_name_jp & "'!A1", table_name_jp)
  Call Formatter.setFunction(Target.Offset(, 4), "＝" & table_name_jp & "!ERRORS")
End Function


  '// FIXME:★★★★★
'save_data.yaml.出力
Public Sub save_(ByVal line_sep As Integer)
  Dim data() As String, Target As Range
  
  For Each Target In Range("DATA_AREA_JP")
    If Target.Offset(, 4).Value Then Call Worksheets(Target.Value).save_(data)
  Next
  
  Call text_io.plain_out(SAVE_DATA, data, line_sep)
End Sub

  '// FIXME:★★★★★
'ddl.出力
Public Sub out_ddl(ByVal line_sep As Integer)
  Dim Target As Range
  
  For Each Target In Range("DATA_AREA_JP")
    If Target.Offset(, 4).Value Then Call Worksheets(Target.Value).out_ddl(line_sep)
  Next
  
End Sub



  '// FIXME:★★★★★
'view_md.出力
Public Sub out_view_md(ByVal line_sep As Integer)
  Dim data() As String, Target As Range
  
  Call push_array(data, "# テーブル定義")
  Call push_array(data, "----------")
  
  For Each Target In Range("DATA_AREA_JP")
    If Target.Offset(, 4).Value Then Call Worksheets(Target.Value).out_view_md(data)
  Next
  
  Call push_array(data, "")
  Call text_io.plain_out(DDL_VIEW, data, line_sep)
End Sub

