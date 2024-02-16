Attribute VB_Name = "text_io"
Option Explicit

Const char_set = "UTF-8"

  '// FIXME:★★★★★

'プレーンテキスト入力
Public Function plain_in(ByVal path As String, ByVal line_sep As Integer) As String()
  Dim adoSt As Object, data() As String
  Set adoSt = CreateObject("ADODB.Stream")
  
  If CreateObject("Scripting.FileSystemObject").fileexists(path) = False Then
    '存在しない場合はダミーデータを返す
    Call Util.push_array(data, "NO_DATA")
    plain_in = data()
    Exit Function
  End If

  With adoSt
    .Type = adTypeText
    .Charset = char_set
    .LineSeparator = line_sep
    .Open
    .LoadFromFile (path)
    
    Do While Not (.EOS)
      Call Util.push_array(data, .ReadText(adReadLine))
    Loop
    
    .Close
  End With
  
  Set adoSt = Nothing
  plain_in = data()
  
  Debug.Print "<<INPUT>>"
  Debug.Print "PATH:" & path
  Debug.Print "LINE_SEP:" & line_sep
  Call Util.Print_Array(data)

End Function


  '// FIXME:★★★★★
'プレーンテキスト出力
Public Sub plain_out(ByVal path As String, ByRef data() As String, ByVal line_sep As Integer)
  Dim adoSt As Object, v_buf() As Byte, i As Long
  Set adoSt = CreateObject("ADODB.Stream")

  With adoSt
    .Type = adTypeText
    .Charset = char_set
    .LineSeparator = line_sep
    
    .Open
    For i = 0 To UBound(data)
      .WriteText data(i), adWriteLine
    Next i
    
    .Position = 0 'ストリーム位置
    .Type = adTypeBinary
    .Position = 3 'ストリーム位置
    v_buf = .read '一時格納用
    .Close
    
    .Open 'ストリームリセット
    .Write v_buf
    .SaveToFile path, adSaveCreateOverWrite
    .Close
  
  End With
  
  Set adoSt = Nothing
  
  Debug.Print "<<OUTPUT>>"
  Debug.Print "PATH:" & path
  Debug.Print "LINE_SEP:" & line_sep
  Call Util.Print_Array(data)

End Sub
