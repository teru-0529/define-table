Attribute VB_Name = "Config"
Option Explicit

Const CHAR_SET = "UTF-8"

Public SAVE_DATA As String
Public ELEMENTS_DATA As String
Public DDL_VIEW As String
Public DDL_DIR As String

Public FULL_VERSION As String
Public OPERATION_MODE As String
Public SAVE_HISTORY_FUNC As Boolean
Public Const CLI_FILE = "define-table.exe"

'// 項目定義の更新日時を記録
Public Sub setModifyDatetime()
  ThisWorkbook.Names.Add Name:="CURRENT_DATETIME", RefersToR1C1:=getModifyTime(ELEMENTS_DATA)
End Sub

'// 項目定義の更新日時が最新かどうかをチェック
Public Function isUpdateModifyDatetime() As Boolean
  ThisWorkbook.Names.Add Name:="MODIFY_DATETIME", RefersToR1C1:=getModifyTime(ELEMENTS_DATA)
  isUpdateModifyDatetime = ThisWorkbook.Names("CURRENT_DATETIME") <> ThisWorkbook.Names("MODIFY_DATETIME")
End Function

'// 開発モードの場合にTrue
Public Function isDevelop() As Boolean
  isDevelop = OPERATION_MODE = "develop"
End Function

'// 絶対パスを取得
Public Function absPath(ByVal path) As String
  absPath = CreateObject("Scripting.FileSystemObject").BuildPath(ThisWorkbook.path, path)
End Function

'// .envから情報を取得してPublic変数に設定する
Public Sub getEnv()
  Const ENV_FILE = ".env"
  
  Dim adoSt As Object
  Dim line As String, v() As String
  Dim schemaJp As String, schemaEn As String
  Dim dic As New Dictionary
  Dim startTime As Double: startTime = Timer
  
  Set adoSt = CreateObject("ADODB.Stream")

  With adoSt
    .Type = adTypeText
    .Charset = CHAR_SET
    .LineSeparator = adLF
    .Open
    Call .LoadFromFile(absPath(ENV_FILE))
    
    Do While Not (.EOS)
      line = .ReadText(adReadLine)
      
      If Len(line) = 0 Then GoTo CONTINUE
      If Left(line, 1) = "#" Then GoTo CONTINUE
      
      '// データ行
      If InStr(1, line, "=") > 0 Then
        v = Split(line, "=")
        '// Dictionaryに登録
        Call dic.Add(v(0), v(1))
      End If

CONTINUE:
    Loop
    
    .Close
  End With
  Set adoSt = Nothing

  Debug.Print "|----|---- configuration setup start ----|----|"
  schemaJp = dic.item("schemaNameJp")
  Range("SCHEMA_JP").Value = schemaJp
  Debug.Print "[config] SCHEMA_JP: " & schemaJp
  
  schemaEn = dic.item("schemaNameEn")
  Range("SCHEMA_EN").Value = schemaEn
  Debug.Print "[config] SCHEMA_EN: " & schemaEn

  SAVE_DATA = absPath(dic.item("saveData"))
  Debug.Print "[config] SAVE_DATA: " & SAVE_DATA

  ELEMENTS_DATA = absPath(dic.item("elementsData"))
  Debug.Print "[config] ELEMENTS_DATA: " & ELEMENTS_DATA

  DDL_VIEW = absPath(dic.item("viewDir"))
  Debug.Print "[config] DDL_VIEW: " & DDL_VIEW

  DDL_DIR = absPath(dic.item("ddlDir"))
  Debug.Print "[config] DDL_DIR: " & DDL_DIR

  OPERATION_MODE = dic.item("mode")
  Debug.Print "[config] OPERATION_MODE: " & OPERATION_MODE
  
  SAVE_HISTORY_FUNC = dic.item("saveHistoryFunc")
  Debug.Print "[config] SAVE_HISTORY_FUNC: " & SAVE_HISTORY_FUNC
  
  FULL_VERSION = Process.outerExec("version -F")
  Debug.Print "[config] FULL_VERSION: " & FULL_VERSION
  
  Call Util.showTime(Timer - startTime)
  Debug.Print "|----|---- configuration setup end ----|----|"
End Sub

'// 更新日時取得
Private Function getModifyTime(ByVal path As String) As String
  If CreateObject("Scripting.FileSystemObject").FileExists(path) = False Then
    MsgBox "[" & path & "] は存在しません。"
    getModifyTime = ""
    Exit Function
  End If

  getModifyTime = CreateObject("Scripting.FileSystemObject").getFile(path).dateLastModified

  Debug.Print "[modifyTime] path:" & path
  Debug.Print "[modifyTime] time:" & getModifyTime
End Function
