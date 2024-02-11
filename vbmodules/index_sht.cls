VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "index_sht"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = True
Option Explicit

' �_�u���N���b�N���̏����i�V�K�e�[�u���쐬�j
Private Sub Worksheet_BeforeDoubleClick(ByVal Target As Range, Cancel As Boolean)
  Dim rc As Integer, temp As Worksheet

  '�u�V�[�g�쐬�v�̃Z�����Ώۂ̏ꍇ�̂ݏ�������
  If Target.Column = 2 And Target.value = 1 Then
    rc = MsgBox("�e�[�u���V�[�g���쐬���܂��B��낵���ł����H", vbYesNo + vbQuestion, "�쐬�m�F")
  
    If rc = vbYes Then Set temp = create_table_sheet(Target)
  End If
  
  Cancel = True

End Sub

Public Sub clear()
  Range("�e�[�u���ꗗJP").Offset(, -1).Resize(, 4).ClearContents
End Sub

' �V�K�e�[�u���̍쐬
Public Function create_table_sheet(Targer As Range) As Worksheet
  Dim table_name_jp As String, table_name_en As String
  
  table_name_jp = Targer.Offset(, 2).value
  table_name_en = Targer.Offset(, 3).value
  Set create_table_sheet = table_sheets.create_table_sheet(Worksheets(index), Targer.Row - 1, table_name_jp, table_name_en)
  
  '�n�C�p�[�����N�ݒ�
  Hyperlinks.Add Anchor:=Targer.Offset(, 1), Address:="", SubAddress:="'" & table_name_jp & "'!A1", TextToDisplay:=table_name_jp
  Targer.Offset(, 1).Font.Size = 9
  Targer.Offset(, 4).Formula2R1C1 = "��" & table_name_jp & "!�G���[����"
End Function


'save_data.yaml.�o��
Public Sub save_(ByVal line_sep As Integer)
  Dim data() As String, Target As Range
  
  For Each Target In Range("�e�[�u���ꗗJP")
    If Target.Offset(, 4).value Then Call Worksheets(Target.value).save_(data)
  Next
  
  Call text_io.plain_out(SAVE_DATA, data, line_sep)
End Sub

'ddl.�o��
Public Sub out_ddl(ByVal line_sep As Integer)
  Dim Target As Range
  
  For Each Target In Range("�e�[�u���ꗗJP")
    If Target.Offset(, 4).value Then Call Worksheets(Target.value).out_ddl(line_sep)
  Next
  
End Sub



'view_md.�o��
Public Sub out_view_md(ByVal line_sep As Integer)
  Dim data() As String, Target As Range
  
  Call push_array(data, "# �e�[�u����`")
  Call push_array(data, "----------")
  
  For Each Target In Range("�e�[�u���ꗗJP")
    If Target.Offset(, 4).value Then Call Worksheets(Target.value).out_view_md(data)
  Next
  
  Call push_array(data, "")
  Call text_io.plain_out(DDL_VIEW, data, line_sep)
End Sub
