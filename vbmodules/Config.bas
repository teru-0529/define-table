Attribute VB_Name = "Config"
Option Explicit

'// iniファイル読込み用関数定義
Declare PtrSafe Function GetPrivateProfileString Lib _
    "kernel32" Alias "GetPrivateProfileStringA" ( _
    ByVal section As String, _
    ByVal key As Any, _
    ByVal default As String, _
    ByVal value As String, _
    ByVal Size As Long, _
    ByVal ini_path As String _
) As Long

'// スキーマ
Public SCHEMA_JP As String
Public SCHEMA_EN As String

'// 入出力パス
Public SAVE_DATA As String
Public ELEMENTS_DATA As String
Public DDL_VIEW As String

Public DDL_DIR As String

'// 操作モード
Dim OPERATION_MODE As String
Dim SAVE_HISTORY_FUNC As Boolean

'// スキーマ名取得
Public Function getSchemaJp() As String
  getSchemaJp = SCHEMA_JP
End Function

'// スキーマ名取得
Public Function getSchemaEn() As String
  getSchemaEn = SCHEMA_EN
End Function

'// バージョン情報取得（Full）
Public Function getFullVersion() As String
  getFullVersion = Process.outerExec("version -F")
End Function

'// バージョン情報取得
Public Function getVersion() As String
  getVersion = Process.outerExec("version")
End Function

'// 項目定義の更新日時を記録
Public Sub setModifyDatetime()
  ThisWorkbook.Names.Add name:="CURRENT_DATETIME", RefersToR1C1:=getModifyTime(ELEMENTS_DATA)
End Sub

'// 項目定義の更新日時が最新かどうかをチェック
Public Function isUpdateModifyDatetime() As Boolean
  ThisWorkbook.Names.Add name:="MODIFY_DATETIME", RefersToR1C1:=getModifyTime(ELEMENTS_DATA)
  isUpdateModifyDatetime = ThisWorkbook.Names("CURRENT_DATETIME") <> ThisWorkbook.Names("MODIFY_DATETIME")
End Function

'// 開発モードの場合にTrue
Public Function isDevelop() As Boolean
  isDevelop = OPERATION_MODE = "develop"
End Function

'// ./vba.iniから情報を取得してPublic変数に設定する
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

'// 絶対パスを取得
Private Function absPath(ByVal path) As String
  absPath = CreateObject("Scripting.FileSystemObject").BuildPath(ThisWorkbook.path, path)
End Function

'// 更新日時取得
Private Function getModifyTime(ByVal path As String) As String
  If CreateObject("Scripting.FileSystemObject").fileexists(path) = False Then
    MsgBox "[" & path & "] は存在しません。"
    getModifyTime = ""
    Exit Function
  End If

  getModifyTime = CreateObject("Scripting.FileSystemObject").getFile(path).dateLastModified

  Debug.Print "[modifyTime] path:" & path
  Debug.Print "[modifyTime] time:" & getModifyTime
End Function
