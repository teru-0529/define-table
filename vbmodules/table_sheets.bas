Attribute VB_Name = "table_sheets"
Option Explicit

' 新規テーブルシート作成
Public Function create_table_sheet(calling_sht As Worksheet, table_no As Long, name_jp As String, name_en As String) As Worksheet
  Dim new_sht As Worksheet
  
  template.Visible = xlSheetVisible
  
  '最後尾にテンプレートをコピー
  template.Copy After:=Worksheets(Worksheets.Count)
  Set new_sht = ActiveSheet
  new_sht.name = name_jp
  
  'テーブル名登録
  new_sht.Range("TABLE_NO").value = table_no
  
  calling_sht.Activate
  template.Visible = xlSheetHidden
  
  Set create_table_sheet = new_sht
End Function

' DDL用のシートをクリアする
Public Sub clear()
  Dim Target As Worksheet

  For Each Target In Worksheets
    Select Case Target.name
      Case elements.name, index_sht.name, template.name, work.name

      Case Else
        Application.DisplayAlerts = False
        Target.Delete
        Application.DisplayAlerts = True
        
     End Select
  Next Target
End Sub

