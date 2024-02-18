Attribute VB_Name = "Process"
Option Explicit

'// �N���C�A���g�o���f�[�V����
Public Sub validate()
  Dim startTime As Double: startTime = Timer

  Debug.Print "|----|---- validation start ----|----|"

  '// �o���f�[�V�������ʂ����Z�b�g
  Call resetValidationResult

  '// �e�V�[�g���Ƃ̃o���f�[�V����(�G���[���ɂ͂��ꂼ�ꂪinvalid��o�^����)
  Call index_sht.validate

  Call Util.showTime(Timer - startTime)
  Debug.Print "|----|---- validation end ----|----|"
End Sub

'// �O���v���Z�X�̌Ăяo��(�������ʁ��W���o�͂�Ԃ�)
Public Function outerExec(ByVal param As String) As String
  Const CLI_FILE = "define-table.exe"
  Dim startTime As Double: startTime = Timer

  Dim FSO As Object: Set FSO = CreateObject("Scripting.FileSystemObject")
  Dim cliPath As String: cliPath = FSO.BuildPath(ThisWorkbook.path, CLI_FILE)

  Debug.Print "|----|---- outer exec start ----|----|"

  If Dir(cliPath) = "" Then
    Debug.Print "[outerExec] cli file not exist: " & CLI_FILE
    outerExec = "����̈ʒu��CLI�t�@�C��������܂���B: " & vbCrLf & cliPath
    GoTo FINALLY
  End If

  Debug.Print "[outerExec] exec: " & CLI_FILE & " " & param
  outerExec = SystemAccessor.GetCommandResult(cliPath & " " & param)
  Debug.Print outerExec

FINALLY:
  Call Util.showTime(Timer - startTime)
  Set FSO = Nothing
  Debug.Print "|----|---- outer exec end ----|----|"
  Debug.Print ""

End Function

'// �o���f�[�V�������ʂ����Z�b�g
Private Sub resetValidationResult()
  ThisWorkbook.Names.Add "VALID", RefersToR1C1:=True
  ThisWorkbook.Names.Add "INVALID", RefersToR1C1:=False
  '// �����l�Ƃ���[VALID(true)]��ݒ�
  ThisWorkbook.Names.Add "VALIDATION_RESULT", RefersToR1C1:=True
  Debug.Print "[validation] reset(valid)"
End Sub

'// �o���f�[�V�����G���[��ݒ�
Public Sub invalid()
  '[INVALID(false)]�ɕύX
  ThisWorkbook.Names.Add "VALIDATION_RESULT", RefersToR1C1:=False
  Debug.Print "[validation] set invalid"
End Sub

'// �o���f�[�V�������ʂ��擾
Public Function isValid() As Boolean
  isValid = ThisWorkbook.Names("VALIDATION_RESULT") = ThisWorkbook.Names("VALID")
End Function
