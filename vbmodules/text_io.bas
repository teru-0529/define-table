Attribute VB_Name = "text_io"
Option Explicit

Const char_set = "UTF-8"


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
