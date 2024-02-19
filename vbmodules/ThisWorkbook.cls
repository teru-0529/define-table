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

' bookのActivate時、項目定義ファイルがアップデートされている場合は、データを更新する。
Private Sub Workbook_Activate()
  Application.ScreenUpdating = False

  '// パス情報の取得
  Call Config.init("vba.ini")

  '// 更新時刻のチェック
  If Config.isUpdateModifyDatetime() Then
    '// 項目定義の再取得
    Call elements.load(outerExec("loadElements -I " & ELEMENTS_DATA))
    Debug.Print "[modifyTime] updated"
    Call Config.setModifyDatetime
  End If
  Application.ScreenUpdating = True
End Sub

' 起動時
Private Sub Workbook_Open()
  startTime = Timer

  '// パス情報の取得
  Call Config.init("vba.ini")

  Application.ScreenUpdating = False
  Application.EnableEvents = False
  '■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
  '// 入力ファイルの存在チェック
  If Not Util.existFile(ELEMENTS_DATA) Then
    MsgBox "項目定義の入力ファイルが存在しません" & vbCrLf & "[" & ELEMENTS_DATA & "]" & _
    vbCrLf & vbCrLf & "vba.ini(elementsData) に正しいパスを指定してください"
    '// 保存せず終了する
    ThisWorkbook.Close SaveChanges:=False
  End If
  
  If Not Util.existFile(SAVE_DATA) Then
    MsgBox "入出力ファイルが存在しないため空シートを生成します" & vbCrLf & "[" & SAVE_DATA & "]"
  End If
  
  '// 項目定義の取得
  Call elements.load(outerExec("loadElements -I " & ELEMENTS_DATA))
  Call Config.setModifyDatetime

  '// 読込み
  Call index_sht.load(outerExec("load -D " & SAVE_DATA))
  '■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
  Application.EnableEvents = True
  Application.Calculate
  Application.ScreenUpdating = True
  Application.StatusBar = False
  
  Debug.Print "[operationMode] " & Config.OPERATION_MODE
  Debug.Print Config.getFullVersion
  Call showTime(Timer - startTime)
  MsgBox Config.getFullVersion()

End Sub

' 保存時
Private Sub Workbook_BeforeSave(ByVal SaveAsUI As Boolean, Cancel As Boolean)
  startTime = Timer

  '// クライアントバリデーション
  Call Process.validate

End Sub

' 保存時
Private Sub Workbook_AfterSave(ByVal Success As Boolean)
  Dim message As String, addHistoryFlag As String
  
  '// パス情報の取得
  Call Config.init("vba.ini")

  Application.ScreenUpdating = False
  '■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
  '業務ロジック

  If Process.isValid() Then
    '// Yamlファイルの出力
    Call outerExec("save -D " & SAVE_DATA & " -E " & ThisWorkbook.FullName)
    
    '// DDLファイルの出力
    If SAVE_HISTORY_FUNC Then addHistoryFlag = " -H"
    Call outerExec("ddl -D " & SAVE_DATA & " -I " & ELEMENTS_DATA & " -O " & DDL_DIR & addHistoryFlag)
    
    '// MDファイルの出力
    Call outerExec("view -D " & SAVE_DATA & " -I " & ELEMENTS_DATA & " -O " & DDL_VIEW)
    
    message = "管理用yamlファイル、DDLを作成しました。"

  Else
    message = "登録内容にエラーがあるため、出力ファイルの保存ができませんでした。"

  End If

  '■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
  Application.ScreenUpdating = True
  Application.StatusBar = False

  Debug.Print "[operationMode] " & Config.OPERATION_MODE
  '// 開発モードの場合、モジュールを出力
  If Config.isDevelop() Then Call ExportModule.SaveModule
  Debug.Print Config.getFullVersion
  Call showTime(Timer - startTime)
  MsgBox message
  
End Sub
