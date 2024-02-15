Attribute VB_Name = "table_sheets"
Option Explicit

' �V�K�e�[�u���V�[�g�쐬
Public Function create_table_sheet(calling_sht As Worksheet, table_no As Long, name_jp As String, name_en As String) As Worksheet
  Dim new_sht As Worksheet
  
  template.Visible = xlSheetVisible
  
  '�Ō���Ƀe���v���[�g���R�s�[
  template.Copy After:=Worksheets(Worksheets.Count)
  Set new_sht = ActiveSheet
  new_sht.name = name_jp
  
  '�e�[�u�����o�^
  new_sht.Range("TABLE_NO").value = table_no
  
  calling_sht.Activate
  template.Visible = xlSheetHidden
  
  Set create_table_sheet = new_sht
End Function

' DDL�p�̃V�[�g���N���A����
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

