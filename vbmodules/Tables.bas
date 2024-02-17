Attribute VB_Name = "Tables"
Option Explicit

' DDL�p�̃V�[�g��S�č폜����
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

'// �t�B�[���h���X�g/NotNull���X�g�̐���
Public Sub createFieldList(sht As Worksheet)
  Dim baseField As Range, nnField As Range, src As Range

  '// ���X�g�̃N���A
  sht.Range("FIELD_AREA").ClearContents
  sht.Range("FIELD_AREA").Resize(1).Value = "N/A"

  '// �o�^�ʒu
  Set baseField = sht.Range("FIELD_AREA").Resize(1, 1)
  Set nnField = baseField.Offset(, 1)

  For Each src In sht.Range("FIELD_NAME")
    If src.Value <> "" Then
      '// �t�B�[���h���X�g�o�^
      baseField.Value = src.Value
      Set baseField = baseField.Offset(1)

      If src.Offset(, 3).Value = 1 Then
        '// NotNull���X�g�o�^
        nnField.Value = src.Value
        Set nnField = nnField.Offset(1)
      End If

    End If
  Next src
End Sub
