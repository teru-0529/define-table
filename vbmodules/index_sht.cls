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
  Dim rc As Integer

  '「シート作成」のセルが対象の場合のみ処理する
  If Target.Column = 2 And Target.Value = 1 Then
    rc = MsgBox("テーブルシートを作成します。よろしいですか？", vbYesNo + vbQuestion, "作成確認")
  
    Application.ScreenUpdating = False
    Application.EnableEvents = False
    If rc = vbYes Then Call createTable(Target.Offset(, 2))
    Application.EnableEvents = True
    Application.Calculate
    Application.ScreenUpdating = True
  End If
  
  Cancel = True

End Sub

'// データLoad(From yaml)
Public Sub load(ByVal data As String)
  Const DELIM1 = "*1*"
  Dim records() As String, bases() As String
  Dim i As Long
  Dim table As Worksheet

  '// 初期化
  Call init

  '// 行ごとのデータに分割
  records = Split(data, vbLf)

  '// テーブル名を取得し、シート作成
  For i = 0 To UBound(records) - 1
    '// [tableJp]<tab>[tableEn]<tab>[isMaster]<DELIM1>[Fields]<DELIM1>...
    bases = Split(Split(records(i), DELIM1)(0), vbTab)

    Cells(i + 2, 4).Value = bases(0) ' tableJp
    Cells(i + 2, 5).Value = bases(1) ' tableEn
    Set table = index_sht.createTable(Cells(i + 2, 4))
    
    '// データロード
    Call Tables.load(table, records(i))
  Next i
End Sub

'// 初期化処理（☆☆☆）
Public Sub init()
  Range("DATA_AREA").ClearContents
  Tables.Delete
End Sub

'// テーブル作成
Public Function createTable(ByRef tableName As Range) As Worksheet
  
  '// シート作成
  Set createTable = Tables.Create(tableName.Row - 1, tableName.Value)
  
  '// ハイパーリンク設定
  Call Formatter.addLink(index_sht, tableName.Offset(, -1), "'" & tableName.Value & "'!A1", tableName.Value)
  Call Formatter.setFunction(tableName.Offset(, 2), "＝" & tableName.Value & "!ERRORS")
End Function

'// テーブル削除
Public Sub dropTable(ByVal tableNo As Long)
  Util.unionRange(Cells(tableNo + 1, 3), Cells(tableNo + 1, 6)).ClearContents
End Sub



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

