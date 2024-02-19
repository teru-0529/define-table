Attribute VB_Name = "Util"
Option Explicit

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

'// union���b�p�[
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

'// �G���[������ꍇ�ɃV�[�g�F��ύX����
Public Sub invalidTableSheet(ByVal sht As Worksheet, ByVal is_error As Boolean)
  If is_error Then
    sht.Tab.Color = RGB(255, 204, 255) 'PINK
  Else
    sht.Tab.Color = RGB(255, 255, 255) 'WHITE
  End If
End Sub

'// ���̓t�@�C���̑��݃`�F�b�N
Public Function existFile(ByVal path As String) As Boolean
  existFile = CreateObject("Scripting.FileSystemObject").FileExists(path)
End Function

