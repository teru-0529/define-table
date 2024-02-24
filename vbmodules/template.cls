VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "template"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = True
Option Explicit

Const COL_NOTNULL = 5
Const COL_DEFAULT = 6
Const COL_FORCE_NOTNULL = 8

Private Sub Worksheet_SelectionChange(ByVal Target As Range)
  '// ペースト無効
  Application.CutCopyMode = False
End Sub

'// テーブルシート削除イベント
Private Sub Worksheet_BeforeDelete()
  Call index_sht.dropTable(Range("TABLE_NO").Value)
  index_sht.Activate
End Sub

'// 計算処理イベント
Private Sub Worksheet_Calculate()
  Call Util.invalidTableSheet(ThisWorkbook.Worksheets(Name), Range("ERRORS").Value > 0)
End Sub

'セル値の変更があった場合
Private Sub Worksheet_Change(ByVal Target As Range)
  Dim area As Range, elm As Range, i As Long
  
  Application.ScreenUpdating = False
  Application.EnableEvents = False

  '// FieldNameが変更された場合
  Set area = Intersect(Target, Range("FIELD_NAME"))
  If Not area Is Nothing Then
    For Each elm In area
      i = elm.Row
      '// 入力値(NotNull、デフォルト値)のクリア
      Util.unionRange(Cells(i, COL_NOTNULL), Cells(i, COL_DEFAULT)).ClearContents
      '// 強制NOTNULLの設定
      If Cells(i, COL_FORCE_NOTNULL).Value = True Then Cells(i, COL_NOTNULL).Value = 1
      
      '// 条件付き書式の設定（※入力後すぐのエラーを抑止するため初期化後に書式登録）
      If elm.Value = "" Then
        Call Formatter.condClear(Cells(i, COL_NOTNULL))
      Else
        Call Formatter.condFunction(Cells(i, COL_NOTNULL), "=RC22")
      End If
    Next
  End If
  
  '// フィールドリスト/NotNullリストの生成
  If Not Intersect(Target, Util.unionRange(Range("FIELD_NAME"), Range("FIELD_NN"))) Is Nothing Then _
    Call Tables.createFieldList(Worksheets(Name))
  
  Application.EnableEvents = True
  Application.Calculate
  Application.ScreenUpdating = True
End Sub
