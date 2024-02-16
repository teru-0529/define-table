Attribute VB_Name = "Util"
Option Explicit

Const NULL_VALUE = "null"

'// �^�C�}�[�̕\��
Public Sub showTime(ByVal sec As Double)
  '// �����b���擾
  Dim hh As String:  hh = Format(Int(sec / 3600), "00")
  Dim mm As String:  mm = Format(Int((sec Mod 3600) / 60), "00")
  Dim ss As String:  ss = Format(Int((sec Mod 3600) Mod 60), "00")

  Dim vSec As Double: vSec = Int(sec * 100) / 100
  '// �f�o�b�N�\��
  Debug.Print "operation-time:(" & hh & ":" & mm & ":" & ss & ") �c" & vSec & "(sec)"
End Sub

'�z��v�f�̒ǉ�
Public Sub push_array(ByRef my_array() As String, ByVal item As String)
  If is_array_empty(my_array) Then
    '������
    ReDim Preserve my_array(0)
  Else
    '�v�f���g��
    ReDim Preserve my_array(UBound(my_array) + 1)
  End If
  my_array(UBound(my_array)) = item

End Sub


'�z��̋󔻒�
Private Function is_array_empty(ByRef my_array() As String) As Boolean
On Error GoTo ERROR_
  is_array_empty = IIf(UBound(my_array) >= 0, False, True)
  Exit Function
    
ERROR_:
  If Err.Number = 9 Then
    is_array_empty = True
  Else
    '�z��O�G���[
  End If
End Function


'union���b�p�[
Public Function unionRange(ByVal rng1 As Range, ByVal rng2 As Range) As Range
  If rng1 Is Nothing And rng2 Is Nothing Then
    Set unionRange = Nothing
  ElseIf rng1 Is Nothing Then
    Set unionRange = rng2
  ElseIf rng2 Is Nothing Then
    Set unionRange = rng1
  Else
    Set unionRange = Union(rng1, rng2)
  End If
End Function


Public Sub Print_Array(ByRef arr As Variant)
  Dim i As Long, d As String
    
  i = UBound(arr)
  For i = LBound(arr) To UBound(arr)
    d = Replace(arr(i), vbTab, "<TAB>")
    Debug.Print i & ": " & d & "<E>"
  Next i
  
End Sub

'�G���[������ꍇ�ɃV�[�g�F��ύX����
Public Sub invalidTableSheet(ByVal sht As Worksheet, ByVal is_error As Boolean)
  If is_error Then
    sht.Tab.Color = RGB(255, 204, 255) 'PINK
  Else
    sht.Tab.Color = RGB(255, 255, 255) 'WHITE
  End If
End Sub

' yaml �p��key-value��������쐬����ivalue����̏ꍇ��null�l�ɕϊ��j
Public Function to_yaml(ByVal key As String, ByVal value As String) As String
  to_yaml = key & ": "
  If value = "" Then to_yaml = to_yaml & NULL_VALUE Else: to_yaml = to_yaml & value
End Function

' yaml �p��key-value�����񂩂�value�𒊏o����ivalue��null�l�̏ꍇ�͋󕶎��ɕϊ��j
Public Function from_yaml(ByVal yaml As String) As String
  Dim val As String
  
  'yaml�`���ł͂Ȃ��ꍇ�̓u�����N
  If InStr(yaml, ":") = 0 Then
    from_yaml = ""
    Exit Function
  End If
  
  val = Trim(Mid(yaml, InStr(yaml, ":") + 1))
  If val = NULL_VALUE Then from_yaml = "" Else from_yaml = val
End Function

Public Function indent(ByVal num As Integer) As String
  indent = String(num * YAML_INDENT_SPACE, " ")
End Function




