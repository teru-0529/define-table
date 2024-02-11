VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "ThisWorkbook"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = True
Option Explicit

Dim startTime As Double

' book�I�����A�e�[�u���A�g�p�t�@�C�����A�b�v�f�[�g����Ă���ꍇ�́A�f�[�^���X�V����B
Private Sub Workbook_Activate()
  Application.ScreenUpdating = False
  If is_update_modify_datetime() Then
    Call elements.load_(adLF)
    Call set_modify_datetime
    Debug.Print "Updated!"
  End If
  Application.ScreenUpdating = True
    
End Sub

' �N����
Private Sub Workbook_Open()
  Dim start_time As Double
  start_time = Timer

  '// �p�X���̎擾
  Call Config.init("vba.ini")
  
  Application.ScreenUpdating = False
  '��������������������������������������������������������������������
  '�Ɩ����W�b�N
  Call elements.load_(adLF)
  Call set_modify_datetime
  
  Call read_write_files.load_(adLF)
  '��������������������������������������������������������������������
  Application.ScreenUpdating = True
  Application.StatusBar = False

  Call showTime(Timer - startTime)
  MsgBox Config.getFullVersion()
End Sub

' �ۑ���
Private Sub Workbook_BeforeSave(ByVal SaveAsUI As Boolean, Cancel As Boolean)
  startTime = Timer

  '// �N���C�A���g�o���f�[�V����
  Call Process.validate

End Sub

' �ۑ���
Private Sub Workbook_AfterSave(ByVal Success As Boolean)
  Dim start_time As Double
  start_time = Timer

  '// �p�X���̎擾
  Call Config.init("vba.ini")

  Application.ScreenUpdating = False
  '��������������������������������������������������������������������
  '�Ɩ����W�b�N
  
  If index_sht.Range("SAVE_OK").value Then
    Call index_sht.save_(adLF)
    Call index_sht.out_ddl(adLF)
    Call index_sht.out_view_md(adLF)
    Call showTime(Timer - start_time)
    MsgBox "Git�Ǘ��p�t�@�C���ADDL���쐬���܂����B"
  
  Else
    MsgBox "���炩�̃G���[�����邽�߁A�o�̓t�@�C���̕ۑ����ł��܂���ł����B"
  
  End If
  
  
  '��������������������������������������������������������������������
  Application.ScreenUpdating = True
  Application.StatusBar = False

  '// �J�����[�h�̏ꍇ�A���W���[�����o��
  If Config.isDevelop() Then Call ExportModule.SaveModule
  Debug.Print Config.getFullVersion
  Call Config.init("vba.ini")
End Sub

'���ڃt�@�C���̍X�V������o�^
Private Sub set_modify_datetime()
  ThisWorkbook.Names.Add name:="CURRENT_DATETIME", RefersToR1C1:=text_io.modify_datetime(ELEMENTS_DATA)
End Sub

'���ڃt�@�C���̍X�V�������ŐV���ǂ������`�F�b�N
Private Function is_update_modify_datetime() As Boolean
  ThisWorkbook.Names.Add name:="MODIFY_DATETIME", RefersToR1C1:=text_io.modify_datetime(ELEMENTS_DATA)
  is_update_modify_datetime = ThisWorkbook.Names("CURRENT_DATETIME") <> ThisWorkbook.Names("MODIFY_DATETIME")
End Function
