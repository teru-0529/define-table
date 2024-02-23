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

Private Sub Worksheet_SelectionChange(ByVal Target As Range)
  '// ペースト無効
  Application.CutCopyMode = False
End Sub

' ダブルクリック時の処理（新規テーブル作成）
Private Sub Worksheet_BeforeDoubleClick(ByVal Target As Range, Cancel As Boolean)
  Dim rc As Integer

  '「シート作成」のセルが対象の場合のみ処理する
  If Target.Column = 2 And Target.Value = 1 Then
    rc = MsgBox("テーブルシートを作成します。よろしいですか？", vbYesNo + vbQuestion, "作成確認")
  
    Application.ScreenUpdating = False
    Application.EnableEvents = False
    If rc = vbYes Then
      '// テーブルシート作成
      Call createTable(Target.Offset(, 2))
      '// テーブルリストの最新化
      Call Tables.ListUpdate
    End If
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
  Range("DATA_AREA").ClearContents
  Tables.Delete

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

'// 入力バリデーション
Public Sub validate()
  If Range("ERRORS").Value > 0 Then Call Process.invalid
End Sub
