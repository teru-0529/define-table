Attribute VB_Name = "Tables"
Option Explicit

' DDL用のシートを全て削除する
Public Sub Delete()
  Dim Target As Worksheet

  For Each Target In Worksheets
    Select Case Target.Name
      Case elements.Name, index_sht.Name, template.Name, work.Name

      Case Else
        Application.DisplayAlerts = False
        Target.Delete
        Application.DisplayAlerts = True
        
     End Select
  Next Target
End Sub

'// フィールドリスト/NotNullリストの生成
Public Sub createFieldList(sht As Worksheet)
  Dim baseField As Range, nnField As Range, src As Range

  '// リストのクリア
  sht.Range("FIELD_AREA").ClearContents
  sht.Range("FIELD_AREA").Resize(1).Value = "N/A"

  '// 登録位置
  Set baseField = sht.Range("FIELD_AREA").Resize(1, 1)
  Set nnField = baseField.Offset(, 1)

  For Each src In sht.Range("FIELD_NAME")
    If src.Value <> "" Then
      '// フィールドリスト登録
      baseField.Value = src.Value
      Set baseField = baseField.Offset(1)

      If src.Offset(, 3).Value = 1 Then
        '// NotNullリスト登録
        nnField.Value = src.Value
        Set nnField = nnField.Offset(1)
      End If

    End If
  Next src
End Sub
