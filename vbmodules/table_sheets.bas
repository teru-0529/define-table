Attribute VB_Name = "table_sheets"
Option Explicit

  '// FIXME:★★★★★
' 新規テーブルシート作成
Public Function create_table_sheet(calling_sht As Worksheet, table_no As Long, name_jp As String, name_en As String) As Worksheet
  Dim new_sht As Worksheet
  
  template.Visible = xlSheetVisible
  
  '最後尾にテンプレートをコピー
  template.Copy After:=Worksheets(Worksheets.Count)
  Set new_sht = ActiveSheet
  new_sht.Name = name_jp
  
  'テーブル名登録
  new_sht.Range("TABLE_NO").Value = table_no
  
  calling_sht.Activate
  template.Visible = xlSheetHidden
  
  Set create_table_sheet = new_sht
End Function
