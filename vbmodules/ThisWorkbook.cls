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

' book選択時、テーブル連携用ファイルがアップデートされている場合は、データを更新する。
Private Sub Workbook_Activate()
  Application.ScreenUpdating = False
  If is_update_modify_datetime() Then
    'MsgBox outerExec("loadElements -I C:\Users\andre\.local\share\go\workspace\define-table\save_data_elm.yaml")

    Call elements.load_(adLF)
    Call set_modify_datetime
    Debug.Print "Updated!"
  End If
  Application.ScreenUpdating = True
    
End Sub

' 起動時
Private Sub Workbook_Open()
  Dim start_time As Double
  start_time = Timer

  '// パス情報の取得
  Call Config.init("vba.ini")
  
  Application.ScreenUpdating = False
  '■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
  '業務ロジック
  Call elements.load_(adLF)
  Call set_modify_datetime
  
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

'項目ファイルの更新日時を登録
Private Sub set_modify_datetime()
  ThisWorkbook.Names.Add name:="CURRENT_DATETIME", RefersToR1C1:=text_io.modify_datetime(ELEMENTS_DATA)
End Sub

'項目ファイルの更新日時が最新かどうかをチェック
Private Function is_update_modify_datetime() As Boolean
  ThisWorkbook.Names.Add name:="MODIFY_DATETIME", RefersToR1C1:=text_io.modify_datetime(ELEMENTS_DATA)
  is_update_modify_datetime = ThisWorkbook.Names("CURRENT_DATETIME") <> ThisWorkbook.Names("MODIFY_DATETIME")
End Function

