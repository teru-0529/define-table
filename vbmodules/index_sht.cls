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
  
    If rc = vbYes Then Set temp = create_table_sheet(Target)
  End If
  
  Cancel = True

End Sub

'// データLoad(From yaml)
Public Sub load(ByVal data As String)

  '// 初期化
  'Call clear
  'Call table_sheets.clear

Debug.Print data
End Sub

Public Sub clear()
  Range("DATA_AREA").ClearContents
End Sub

Public Sub dropTable(ByVal rowNo As Long)
  Util.unionRange(Range("BASE_CELL").Offset(rowNo), Range("BASE_CELL").Offset(rowNo, 3)).ClearContents
End Sub

  '// FIXME:★★★★★
' 新規テーブルの作成
Public Function create_table_sheet(Targer As Range) As Worksheet
  Dim table_name_jp As String, table_name_en As String
  
  table_name_jp = Targer.Offset(, 2).Value
  table_name_en = Targer.Offset(, 3).Value
  Set create_table_sheet = table_sheets.create_table_sheet(Worksheets(index), Targer.Row - 1, table_name_jp, table_name_en)
  
  'ハイパーリンク設定
  Hyperlinks.Add Anchor:=Targer.Offset(, 1), Address:="", SubAddress:="'" & table_name_jp & "'!A1", TextToDisplay:=table_name_jp
  Targer.Offset(, 1).Font.Size = 9
  Targer.Offset(, 4).Formula2R1C1 = "＝" & table_name_jp & "!ERRORS"
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

