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
  '■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
  '// 項目定義の取得
  Call elements.load(outerExec("loadElements -I " & ELEMENTS_DATA))
  Call Config.setModifyDatetime

  '// FIXME:★★★★★
  Call read_write_files.load_(adLF)
  '■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
  Application.ScreenUpdating = True
  Application.StatusBar = False

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
  Dim start_time As Double
  start_time = Timer

  '// パス情報の取得
  Call Config.init("vba.ini")

  Application.ScreenUpdating = False
  '■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
  '業務ロジック

  '// FIXME:★★★★★
  If index_sht.Range("SAVE_OK").value Then
    Call index_sht.save_(adLF)
    Call index_sht.out_ddl(adLF)
    Call index_sht.out_view_md(adLF)
    Call showTime(Timer - start_time)
    MsgBox "Git管理用ファイル、DDLを作成しました。"

  Else
    MsgBox "何らかのエラーがあるため、出力ファイルの保存ができませんでした。"

  End If

  '■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
  Application.ScreenUpdating = True
  Application.StatusBar = False

  '// 開発モードの場合、モジュールを出力
  If Config.isDevelop() Then Call ExportModule.SaveModule
  Debug.Print Config.getFullVersion
End Sub
