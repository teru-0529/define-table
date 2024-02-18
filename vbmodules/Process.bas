Attribute VB_Name = "Process"
Option Explicit

'// クライアントバリデーション
Public Sub validate()
  Dim startTime As Double: startTime = Timer

  Debug.Print "|----|---- validation start ----|----|"

  '// バリデーション結果をリセット
  Call resetValidationResult

  '// 各シートごとのバリデーション(エラー時にはそれぞれがinvalidを登録する)
  Call index_sht.validate

  Call Util.showTime(Timer - startTime)
  Debug.Print "|----|---- validation end ----|----|"
End Sub

'// 外部プロセスの呼び出し(処理結果＝標準出力を返す)
Public Function outerExec(ByVal param As String) As String
  Const CLI_FILE = "define-table.exe"
  Dim startTime As Double: startTime = Timer

  Dim FSO As Object: Set FSO = CreateObject("Scripting.FileSystemObject")
  Dim cliPath As String: cliPath = FSO.BuildPath(ThisWorkbook.path, CLI_FILE)

  Debug.Print "|----|---- outer exec start ----|----|"

  If Dir(cliPath) = "" Then
    Debug.Print "[outerExec] cli file not exist: " & CLI_FILE
    outerExec = "所定の位置にCLIファイルがありません。: " & vbCrLf & cliPath
    GoTo FINALLY
  End If

  Debug.Print "[outerExec] exec: " & CLI_FILE & " " & param
  outerExec = SystemAccessor.GetCommandResult(cliPath & " " & param)
  Debug.Print outerExec

FINALLY:
  Call Util.showTime(Timer - startTime)
  Set FSO = Nothing
  Debug.Print "|----|---- outer exec end ----|----|"
  Debug.Print ""

End Function

'// バリデーション結果をリセット
Private Sub resetValidationResult()
  ThisWorkbook.Names.Add "VALID", RefersToR1C1:=True
  ThisWorkbook.Names.Add "INVALID", RefersToR1C1:=False
  '// 初期値として[VALID(true)]を設定
  ThisWorkbook.Names.Add "VALIDATION_RESULT", RefersToR1C1:=True
  Debug.Print "[validation] reset(valid)"
End Sub

'// バリデーションエラーを設定
Public Sub invalid()
  '[INVALID(false)]に変更
  ThisWorkbook.Names.Add "VALIDATION_RESULT", RefersToR1C1:=False
  Debug.Print "[validation] set invalid"
End Sub

'// バリデーション結果を取得
Public Function isValid() As Boolean
  isValid = ThisWorkbook.Names("VALIDATION_RESULT") = ThisWorkbook.Names("VALID")
End Function
