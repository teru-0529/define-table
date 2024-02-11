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

'// �X�L�[�}
Public SCHEMA_JP As String
Public SCHEMA_EN As String

'// ���o�̓p�X
Public SAVE_DATA As String
Public ELEMENTS_DATA As String
Public DDL_VIEW As String

Public DDL_DIR As String

'// ���샂�[�h
Dim OPERATION_MODE As String
Dim SAVE_HISTORY_FUNC As Boolean

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
  isDevelop = OPERATION_MODE = "develop"
End Function

'// ./vba.ini��������擾����Public�ϐ��ɐݒ肷��
Public Sub init(ByVal iniFile As String)
  Dim startTime As Double: startTime = Timer

  Dim FSO As Object: Set FSO = CreateObject("Scripting.FileSystemObject")
  Dim iniPath As String: iniPath = FSO.BuildPath(ThisWorkbook.path, iniFile)

  Debug.Print "|----|---- configuration setup start ----|----|"

  SCHEMA_JP = getIniValue("schema", "nameJp", iniPath)
  Debug.Print "[config] SCHEMA_JP: " & SCHEMA_JP
  
  SCHEMA_EN = getIniValue("schema", "nameEn", iniPath)
  Debug.Print "[config] SCHEMA_EN: " & SCHEMA_EN

  SAVE_DATA = absPath(getIniValue("Path", "saveData", iniPath))
  Debug.Print "[config] SAVE_DATA: " & SAVE_DATA

  ELEMENTS_DATA = absPath(getIniValue("Path", "elementsData", iniPath))
  Debug.Print "[config] ELEMENTS_DATA: " & ELEMENTS_DATA

  DDL_VIEW = absPath(getIniValue("Path", "view", iniPath))
  Debug.Print "[config] DDL_VIEW: " & DDL_VIEW

  DDL_DIR = absPath(getIniValue("Path", "ddlDor", iniPath))
  Debug.Print "[config] DDL_DIR: " & DDL_DIR

  OPERATION_MODE = getIniValue("Operation", "mode", iniPath)
  Debug.Print "[config] OPERATION_MODE: " & OPERATION_MODE
  
  SAVE_HISTORY_FUNC = getIniValue("Operation", "saveHistoryFunc", iniPath)
  Debug.Print "[config] SAVE_HISTORY_FUNC: " & SAVE_HISTORY_FUNC
  
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


