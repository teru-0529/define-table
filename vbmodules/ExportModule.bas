Attribute VB_Name = "ExportModule"
'［セキュリティセンター／マクロの設定］の
'［VBA プロジェクト オブジェクト モデルへのアクセスを信頼する］にチェックを入れておく。
' [参考]
' https://support.microsoft.com/ja-jp/office/excel-%E3%81%AE%E3%83%9E%E3%82%AF%E3%83%AD%E3%81%AE%E3%82%BB%E3%82%AD%E3%83%A5%E3%83%AA%E3%83%86%E3%82%A3%E8%A8%AD%E5%AE%9A%E3%82%92%E5%A4%89%E6%9B%B4%E3%81%99%E3%82%8B-a97c09d2-c082-46b8-b19f-e8621e8fe373

Option Explicit

' この Module が書かれている Book のすべての Module をExportする
Sub SaveModule()

  Dim FSO As Object: Set FSO = CreateObject("Scripting.FileSystemObject")
  Const DIR_NAME = "vbmodules" '出力ディレクトリ名

  Dim dir_path As String ' モジュール出力フォルダ
  Dim xlMod As Object 'Module

  '// 出力ディレクトリの準備
  dir_path = makeCleanDir(DIR_NAME, FSO)

  For Each xlMod In ThisWorkbook.VBProject.VBComponents
    xlMod.Export FSO.BuildPath(dir_path, xlMod.Name & getModuleExt(xlMod.Type))
  Next

  Set FSO = Nothing
  Debug.Print "[saveModule]"
End Sub

'// モジュールタイプに対応する拡張子を返す
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

'// Bookと同じ階層にディレクトリを作成し絶対パスを返す（既に存在する場合は中身を削除する）
Private Function makeCleanDir(ByVal Name As String, fso_ As Object) As String

  Dim dir_path As String ' ディレクトリパス

  dir_path = fso_.BuildPath(ThisWorkbook.path, Name)

  '// ディレクトリが存在する場合は削除してから作成する
  If Dir(dir_path, vbDirectory) <> "" Then
    fso_.DeleteFolder dir_path
  End If

  '// ディレクトリを作成する
  makeCleanDir = fso_.CreateFolder(dir_path)

End Function
