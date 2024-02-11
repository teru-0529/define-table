VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "template"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = True
Option Explicit

'�J�����ԍ�
Private Enum field_col_no
  NO = 1
  ���ږ�JP = 2
  ���ږ�EN = 3
  �f�[�^�^ = 4
  NOTNULL = 5
  �f�t�H���g�l = 6
  �`�F�b�N���� = 7
  ����NOTNULL = 8
  ������f�t�H���g�L�� = 9
End Enum
  
Const max_field_col = 9


Private Sub Worksheet_BeforeDelete()
  Dim Target As Range
  Set Target = index_sht.Cells(Range("�e�[�u��No").value + 1, 3)
  
  Target.ClearContents
  Target.Offset(, 3).ClearContents
  index_sht.Activate
  
End Sub

Private Sub Worksheet_Calculate()
  Dim sht As Worksheet: Set sht = ThisWorkbook.Worksheets(name)
  Call Util.validate_sheet_color(sht, Range("�G���[����").value > 0)
End Sub

'�Z���l�̕ύX���������ꍇ
Private Sub Worksheet_Change(ByVal Target As Range)
  Dim elm As Range, i As Long
  If Not Intersect(Target, Range("�e�[�u������FORM")) Is Nothing Then
  
    For Each elm In Intersect(Target, Range("�e�[�u������FORM"))
      i = elm.Row
      
      Cells(i, NOTNULL).ClearContents
      Cells(i, �f�t�H���g�l).ClearContents
      '����NOTNULL���ǂ���
      If Cells(i, ����NOTNULL).value = True Then Cells(i, NOTNULL).value = 1
      
    Next
    
    '�e�[�u�����ڂ̍Đ���
    Call reset_table_items
    
    

  End If
End Sub

'�e�[�u�����ڂ̍ēo�^
Private Sub reset_table_items()
  Dim Target As Range: Set Target = Range("�e�[�u������START")
  Dim src As Range
  
  '�������
  Target.EntireColumn.ClearContents
  Target.value = "N/A"
  
  For Each src In Range("�e�[�u������FORM")
    If src.value <> "" Then
      Target.value = src.value
      Set Target = Target.Offset(1)
    End If
  Next src
End Sub

'----+----+----+----+----+----+----+----+----+----+
'�o��
Public Sub save_(data() As String)
  Dim Target As Range, i As Long

  Call push_array(data, "- ddl:")
  
  '��{���
  Call push_array(data, indent(2) & to_yaml("table_name_jp", Range("�e�[�u��JP").value))
  Call push_array(data, indent(2) & to_yaml("table_name_en", Range("�e�[�u��EN").value))
  Call push_array(data, "")
  
  '�e�[�u������
  Call push_array(data, indent(2) & "fielsd:")
  For Each Target In Range("�e�[�u������FORM")
    If Target.value <> "" Then
      i = Target.Row
      Call push_array(data, indent(3) & to_yaml("- name", Cells(i, ���ږ�JP).value))
      Call push_array(data, indent(4) & to_yaml("not_null", Cells(i, NOTNULL).value))
      Call push_array(data, indent(4) & to_yaml("default", Cells(i, �f�t�H���g�l).value))
      Call push_array(data, "")
    End If
  Next
  
  'PK����
  Call push_array(data, indent(2) & "primary_key:")
  For Each Target In Range("PK����FORM")
    If Target.value <> "" Then
      Call push_array(data, indent(3) & "- " & Target.value)
    End If
  Next
  Call push_array(data, "")
  
  '���j�[�N����
  Call push_array(data, indent(2) & "unique:")
  Call push_array(data, indent(3) & to_yaml("exists", Range("���j�[�N_EXISTS").value))
  If Range("���j�[�N_EXISTS").value Then
    Call push_array(data, indent(3) & "constraints:")
    For Each Target In Range("���j�[�N_FORM")
      If Target.value Then
        Call push_array(data, indent(4) & "- constraint:")
        If Target.Offset(, -6).value <> "" Then Call push_array(data, indent(5) & "- " & Target.Offset(, -6).value)
        If Target.Offset(, -5).value <> "" Then Call push_array(data, indent(5) & "- " & Target.Offset(, -5).value)
        If Target.Offset(, -4).value <> "" Then Call push_array(data, indent(5) & "- " & Target.Offset(, -4).value)
        If Target.Offset(, -3).value <> "" Then Call push_array(data, indent(5) & "- " & Target.Offset(, -3).value)
        If Target.Offset(, -2).value <> "" Then Call push_array(data, indent(5) & "- " & Target.Offset(, -2).value)
      End If
    Next
  End If
  Call push_array(data, "")
  
  '�`�F�b�N����
  Call push_array(data, indent(2) & "check:")
  Call push_array(data, "")
  
  '�O���L�[����
  Call push_array(data, indent(2) & "foreign_key:")
  Call push_array(data, "")
  
End Sub

Public Sub out_view_md(data() As String)
  Dim Target As Range, i As Long, is_not_null As Boolean, constraint As String

  Call push_array(data, "")
  
  '��{���
  Call push_array(data, "## #" & Range("�e�[�u��NO").value & " " & Range("�e�[�u��JP").value & " (" & Range("�e�[�u��EN").value & ")")
  Call push_array(data, "")
  
  '�e�[�u������
  Call push_array(data, "### fielsds")
  Call push_array(data, "| # | name_jp | name_en | model | not_null | default | field_constraint |")
  Call push_array(data, "| -- | -- | -- | -- | -- | -- | -- |")
  For Each Target In Range("�e�[�u������FORM")
    If Target.value <> "" Then
      i = Target.Row
      is_not_null = Cells(i, NOTNULL).value = 1
      If Cells(i, �`�F�b�N����).value = "0" Then constraint = "" Else constraint = Replace(Cells(i, �`�F�b�N����).value, "|", "&#124;")
      
      Call push_array(data, "| " & Cells(i, NO).value & " | " & Cells(i, ���ږ�JP).value & " | " & Cells(i, ���ږ�EN).value & _
       " | " & Cells(i, �f�[�^�^).value & " | " & is_not_null & " | " & Cells(i, �f�t�H���g�l).value & " | " & constraint & " |")
    End If
  Next
  
  Call push_array(data, "### table constraint")
  Call push_array(data, "#### primary key")
  For Each Target In Range("PK����FORM")
    If Target.value <> "" Then
      Call push_array(data, "* " & Target.value)
    End If
  Next
  
  If Range("���j�[�N_EXISTS").value Then
    Call push_array(data, "#### unique")
    i = 0
    For Each Target In Range("���j�[�N_FORM")
      If Target.value Then
        i = i + 1
        Call push_array(data, "##### " & Range("�e�[�u��EN") & "_unique_" & i)
        If Target.Offset(, -6).value <> "" Then Call push_array(data, "* " & Target.Offset(, -6).value)
        If Target.Offset(, -5).value <> "" Then Call push_array(data, "* " & Target.Offset(, -5).value)
        If Target.Offset(, -4).value <> "" Then Call push_array(data, "* " & Target.Offset(, -4).value)
        If Target.Offset(, -3).value <> "" Then Call push_array(data, "* " & Target.Offset(, -3).value)
        If Target.Offset(, -2).value <> "" Then Call push_array(data, "* " & Target.Offset(, -2).value)
      End If
    Next
  End If
  
  Call push_array(data, "----------")
  
End Sub


Public Sub out_ddl(ByVal line_sep As Integer)
  Dim data() As String, file_name As String, table_name As String, Target As Range, i As Long, j As Long
  Dim wk() As String
  
  file_name = DDL_DIR & "\" & DDL_PREFIX & SCHEMA_EN & "_" & Range("�e�[�u��EN").value & ".sql"
  table_name = SCHEMA_EN & "." & Range("�e�[�u��EN").value

  Call push_array(data, "")
  
  '��{���
  Call push_array(data, "-- " & Range("�e�[�u��NO").value & "." & Range("�e�[�u��JP").value & "(" & Range("�e�[�u��EN").value & ")")
  Call push_array(data, "")
  
  'Create Table
  Call push_array(data, "-- Create Table")
  Call push_array(data, "DROP TABLE IF EXISTS " & table_name & " CASCADE;")
  Call push_array(data, "CREATE TABLE " & table_name & " (")
  
  For Each Target In Range("�e�[�u������FORM")
    If Target.value <> "" Then
      i = Target.Row
      Call push_array(data, indent(1) & Cells(i, ���ږ�EN).value & " " & Cells(i, �f�[�^�^).value & _
         not_null_token(Cells(i, NOTNULL).value) & default_token(Cells(i, �f�t�H���g�l).value, Cells(i, ������f�t�H���g�L��).value) & _
         check_constraint(Cells(i, �`�F�b�N����).value) & ",")
    End If
  Next
  Call push_array(data, indent(1) & "created_at timestamp NOT NULL DEFAULT current_timestamp,")
  Call push_array(data, indent(1) & "updated_at timestamp NOT NULL DEFAULT current_timestamp,")
  Call push_array(data, indent(1) & "created_by varchar(30),")
  Call push_array(data, indent(1) & "updated_by varchar(30)")
   
  Call push_array(data, ");")
  Call push_array(data, "")
  

  'Column Comment
  Call push_array(data, "-- Set Column Comment")
  For Each Target In Range("�e�[�u������FORM")
    If Target.value <> "" Then
      i = Target.Row
      Call push_array(data, "COMMENT ON COLUMN " & table_name & "." & Cells(i, ���ږ�EN).value & " IS '" & Cells(i, ���ږ�JP).value & "';")
    End If
  Next
  Call push_array(data, "COMMENT ON COLUMN " & table_name & ".created_at IS '�쐬����';")
  Call push_array(data, "COMMENT ON COLUMN " & table_name & ".updated_at IS '�X�V����';")
  Call push_array(data, "COMMENT ON COLUMN " & table_name & ".created_by IS '�쐬��';")
  Call push_array(data, "COMMENT ON COLUMN " & table_name & ".updated_by IS '�X�V��';")
  Call push_array(data, "")
  
  
  'PK Constraint
  Call push_array(data, "-- Set PK Constraint")
  Call push_array(data, "ALTER TABLE " & table_name & " ADD PRIMARY KEY (")
  
  '��xwk�ɓ����i�Ōゾ���J���}�������Ȃ����߁j
  For Each Target In Range("PK����FORM")
    If Target.value <> "" Then Call push_array(wk, indent(1) & Target.Offset(, 25).value)
  Next Target
  
  For i = 0 To UBound(wk) - 1
    Call push_array(data, wk(i) & ",")
  Next i
  Call push_array(data, wk(UBound(wk)))
  Erase wk
  
  Call push_array(data, ");")
  Call push_array(data, "")
  
  
  'Unique Constraint
  If Range("���j�[�N_EXISTS").value Then Call push_array(data, "-- Set Unique Constraint")
  i = 0
  For Each Target In Range("���j�[�N_FORM")
    If Target.value Then
      i = i + 1
      Call push_array(data, "ALTER TABLE " & table_name & " ADD CONSTRAINT " & Range("�e�[�u��EN") & "_unique_" & i & " UNIQUE (")
      
      '��xwk�ɓ����i�Ōゾ���J���}�������Ȃ����߁j
      For j = -6 To -2
        If Target.Offset(, j).value <> "" Then Call push_array(wk, indent(1) & Target.Offset(, j + 25).value)
      Next j
      
      For j = 0 To UBound(wk) - 1
        Call push_array(data, wk(j) & ",")
      Next j
      Call push_array(data, wk(UBound(wk)))
      Erase wk
      
      Call push_array(data, ");")
      Call push_array(data, "")
    End If
  Next
  
  
  'Create set_update_at Trigger
  Call push_array(data, "-- Create 'set_update_at' Trigger")
  Call push_array(data, "CREATE TRIGGER " & Range("�e�[�u��EN").value & "_updated")
  Call push_array(data, indent(1) & "BEFORE UPDATE")
  Call push_array(data, indent(1) & "ON " & table_name)
  Call push_array(data, indent(1) & "FOR EACH ROW")
  Call push_array(data, "EXECUTE PROCEDURE set_updated_at()")
            
  Call text_io.plain_out(file_name, data, line_sep)
End Sub

' not null �̕�����
Private Function not_null_token(val As Long) As String
  If val = 1 Then not_null_token = " NOT NULL" Else not_null_token = ""
End Function

' default�̕�����
Private Function default_token(val As String, is_string_default As Boolean) As String
  If val = "" Then
    default_token = ""
  ElseIf is_string_default Then
    default_token = " DEFAULT '" & val & "'"
  Else
    default_token = " DEFAULT " & val
  End If
End Function

' check���� �̕�����
Private Function check_constraint(val As String) As String
  If val = "0" Then
    check_constraint = ""
  Else
    check_constraint = " check " & val
  End If
End Function
