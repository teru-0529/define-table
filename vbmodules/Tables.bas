Attribute VB_Name = "Tables"
Option Explicit

'// �t�B�[���h���X�g/NotNull���X�g�̐���
Public Sub createFieldList(sht As Worksheet)
  Dim baseField As Range, nnField As Range, src As Range

  '// ���X�g�̃N���A
  sht.Range("FIELD_AREA").ClearContents
  sht.Range("FIELD_AREA").Resize(1).value = "N/A"

  '// �o�^�ʒu
  Set baseField = sht.Range("FIELD_AREA").Resize(1, 1)
  Set nnField = baseField.Offset(, 1)

  For Each src In sht.Range("FIELD_NAME")
    If src.value <> "" Then
      '// �t�B�[���h���X�g�o�^
      baseField.value = src.value
      Set baseField = baseField.Offset(1)

      If src.Offset(, 3).value = 1 Then
        '// NotNull���X�g�o�^
        nnField.value = src.value
        Set nnField = nnField.Offset(1)
      End If

    End If
  Next src
End Sub
