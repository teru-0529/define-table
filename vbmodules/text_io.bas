Attribute VB_Name = "text_io"
Option Explicit

Const char_set = "UTF-8"

  '// FIXME:����������

'�v���[���e�L�X�g����
Public Function plain_in(ByVal path As String, ByVal line_sep As Integer) As String()
  Dim adoSt As Object, data() As String
  Set adoSt = CreateObject("ADODB.Stream")
  
  If CreateObject("Scripting.FileSystemObject").fileexists(path) = False Then
    '���݂��Ȃ��ꍇ�̓_�~�[�f�[�^��Ԃ�
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


  '// FIXME:����������
'�v���[���e�L�X�g�o��
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
    
    .Position = 0 '�X�g���[���ʒu
    .Type = adTypeBinary
    .Position = 3 '�X�g���[���ʒu
    v_buf = .read '�ꎞ�i�[�p
    .Close
    
    .Open '�X�g���[�����Z�b�g
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
