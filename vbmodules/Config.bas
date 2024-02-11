Attribute VB_Name = "Config"
Option Explicit

'// ini�t�@�C���Ǎ��ݗp�֐���`
Declare PtrSafe Function GetPrivateProfileString Lib _
    "kernel32" Alias "GetPrivateProfileStringA" ( _
    ByVal section As String, _
    ByVal key As Any, _
    ByVal default As String, _
    ByVal value As String, _
    ByVal Size As Long, _
    ByVal ini_path As String _
) As Long

'// ���o�̓p�X
Public SAVE_DATA As String
Public TABLE_ELEMENTS As String
Public API_ELEMENTS As String
Public TYPES_DDL As String

Public VIEW_DIR As String

'// ���샂�[�h
Dim OPERATION_MODE As String

'// �o�[�W�������擾�iFull�j
Public Function getFullVersion() As String
  getFullVersion = Process.outerExec("version -F")
End Function

'// �o�[�W�������擾
Public Function getVersion() As String
  getVersion = Process.outerExec("version")
End Function

'// �J�����[�h�̏ꍇ��True
Public Function isDevelop() As Boolean
  'isDevelop = OPERATION_MODE = "develop" FIXME:
  isDevelop = True
End Function

'// ./vba.ini��������擾����Public�ϐ��ɐݒ肷��
Public Sub init(ByVal iniFile As String)
  Dim startTime As Double: startTime = Timer

  Dim FSO As Object: Set FSO = CreateObject("Scripting.FileSystemObject")
  Dim iniPath As String: iniPath = FSO.BuildPath(ThisWorkbook.path, iniFile)

  Debug.Print "|----|---- configuration setup start ----|----|"

  SAVE_DATA = absPath(getIniValue("Path", "saveData", iniPath))
  Debug.Print "[config] SAVE_DATA: " & SAVE_DATA

  TABLE_ELEMENTS = absPath(getIniValue("Path", "tableElements", iniPath))
  Debug.Print "[config] TABLE_ELEMENTS: " & TABLE_ELEMENTS

  API_ELEMENTS = absPath(getIniValue("Path", "apiElements", iniPath))
  Debug.Print "[config] API_ELEMENTS: " & API_ELEMENTS

  TYPES_DDL = absPath(getIniValue("Path", "typesDDL", iniPath))
  Debug.Print "[config] TYPES_DDL: " & TYPES_DDL

  VIEW_DIR = absPath(getIniValue("Path", "viewDir", iniPath))
  Debug.Print "[config] VIEW_DIR: " & VIEW_DIR

  OPERATION_MODE = getIniValue("Operation", "mode", iniPath)
  Debug.Print "[config] OPERATION_MODE: " & OPERATION_MODE
  
  Set FSO = Nothing
  Call Util.showTime(Timer - startTime)
  Debug.Print "|----|---- configuration setup end ----|----|"
End Sub

Private Function getIniValue(ByVal base As String, ByVal key As String, ByVal path As String) As String
  Const TEMP_LENGTH = 255
  Dim temp As String: temp = Space(TEMP_LENGTH)

  Call GetPrivateProfileString(base, key, "N/A", temp, TEMP_LENGTH, path)
  getIniValue = Trim(Left(temp, InStr(temp, vbNullChar) - 1))
End Function

Private Function absPath(ByVal path) As String
  '// ��΃p�X���擾
  absPath = CreateObject("Scripting.FileSystemObject").BuildPath(ThisWorkbook.path, path)
End Function


