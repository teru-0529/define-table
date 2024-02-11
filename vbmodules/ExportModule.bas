Attribute VB_Name = "ExportModule"
'�m�Z�L�����e�B�Z���^�[�^�}�N���̐ݒ�n��
'�mVBA �v���W�F�N�g �I�u�W�F�N�g ���f���ւ̃A�N�Z�X��M������n�Ƀ`�F�b�N�����Ă����B
' [�Q�l]
' https://support.microsoft.com/ja-jp/office/excel-%E3%81%AE%E3%83%9E%E3%82%AF%E3%83%AD%E3%81%AE%E3%82%BB%E3%82%AD%E3%83%A5%E3%83%AA%E3%83%86%E3%82%A3%E8%A8%AD%E5%AE%9A%E3%82%92%E5%A4%89%E6%9B%B4%E3%81%99%E3%82%8B-a97c09d2-c082-46b8-b19f-e8621e8fe373

Option Explicit

' ���� Module ��������Ă��� Book �̂��ׂĂ� Module ��Export����
Sub SaveModule()

  Dim FSO As Object: Set FSO = CreateObject("Scripting.FileSystemObject")
  Const DIR_NAME = "vbmodules" '�o�̓f�B���N�g����

  Dim dir_path As String ' ���W���[���o�̓t�H���_
  Dim xlMod As Object 'Module

  '// �o�̓f�B���N�g���̏���
  dir_path = makeCleanDir(DIR_NAME, FSO)

  For Each xlMod In ThisWorkbook.VBProject.VBComponents
    xlMod.Export FSO.BuildPath(dir_path, xlMod.name & getModuleExt(xlMod.Type))
  Next

  Set FSO = Nothing
  Debug.Print "[saveModule]"
End Sub

'// ���W���[���^�C�v�ɑΉ�����g���q��Ԃ�
Private Function getModuleExt(ByVal module_type As Integer) As String

  Select Case module_type
    Case 1
      getModuleExt = ".bas"
    Case 2, 100
      getModuleExt = ".cls"
    Case 3
      getModuleExt = ".frm"
  End Select

End Function

'// Book�Ɠ����K�w�Ƀf�B���N�g�����쐬����΃p�X��Ԃ��i���ɑ��݂���ꍇ�͒��g���폜����j
Private Function makeCleanDir(ByVal name As String, fso_ As Object) As String

  Dim dir_path As String ' �f�B���N�g���p�X

  dir_path = fso_.BuildPath(ThisWorkbook.path, name)

  '// �f�B���N�g�������݂���ꍇ�͍폜���Ă���쐬����
  If Dir(dir_path, vbDirectory) <> "" Then
    fso_.DeleteFolder dir_path
  End If

  '// �f�B���N�g�����쐬����
  makeCleanDir = fso_.CreateFolder(dir_path)

End Function
