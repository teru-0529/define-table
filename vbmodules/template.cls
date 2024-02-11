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

'カラム番号
Private Enum field_col_no
  NO = 1
  項目名JP = 2
  項目名EN = 3
  データ型 = 4
  NOTNULL = 5
  デフォルト値 = 6
  チェック制約 = 7
  強制NOTNULL = 8
  文字列デフォルト有無 = 9
End Enum
  
Const max_field_col = 9


Private Sub Worksheet_BeforeDelete()
  Dim Target As Range
  Set Target = index_sht.Cells(Range("テーブルNo").value + 1, 3)
  
  Target.ClearContents
  Target.Offset(, 3).ClearContents
  index_sht.Activate
  
End Sub

Private Sub Worksheet_Calculate()
  Dim sht As Worksheet: Set sht = ThisWorkbook.Worksheets(name)
  Call Util.validate_sheet_color(sht, Range("エラーあり").value > 0)
End Sub

'セル値の変更があった場合
Private Sub Worksheet_Change(ByVal Target As Range)
  Dim elm As Range, i As Long
  If Not Intersect(Target, Range("テーブル項目FORM")) Is Nothing Then
  
    For Each elm In Intersect(Target, Range("テーブル項目FORM"))
      i = elm.Row
      
      Cells(i, NOTNULL).ClearContents
      Cells(i, デフォルト値).ClearContents
      '強制NOTNULLかどうか
      If Cells(i, 強制NOTNULL).value = True Then Cells(i, NOTNULL).value = 1
      
    Next
    
    'テーブル項目の再生成
    Call reset_table_items
    
    

  End If
End Sub

'テーブル項目の再登録
Private Sub reset_table_items()
  Dim Target As Range: Set Target = Range("テーブル項目START")
  Dim src As Range
  
  '列を消去
  Target.EntireColumn.ClearContents
  Target.value = "N/A"
  
  For Each src In Range("テーブル項目FORM")
    If src.value <> "" Then
      Target.value = src.value
      Set Target = Target.Offset(1)
    End If
  Next src
End Sub

'----+----+----+----+----+----+----+----+----+----+
'出力
Public Sub save_(data() As String)
  Dim Target As Range, i As Long

  Call push_array(data, "- ddl:")
  
  '基本情報
  Call push_array(data, indent(2) & to_yaml("table_name_jp", Range("テーブルJP").value))
  Call push_array(data, indent(2) & to_yaml("table_name_en", Range("テーブルEN").value))
  Call push_array(data, "")
  
  'テーブル項目
  Call push_array(data, indent(2) & "fielsd:")
  For Each Target In Range("テーブル項目FORM")
    If Target.value <> "" Then
      i = Target.Row
      Call push_array(data, indent(3) & to_yaml("- name", Cells(i, 項目名JP).value))
      Call push_array(data, indent(4) & to_yaml("not_null", Cells(i, NOTNULL).value))
      Call push_array(data, indent(4) & to_yaml("default", Cells(i, デフォルト値).value))
      Call push_array(data, "")
    End If
  Next
  
  'PK制約
  Call push_array(data, indent(2) & "primary_key:")
  For Each Target In Range("PK項目FORM")
    If Target.value <> "" Then
      Call push_array(data, indent(3) & "- " & Target.value)
    End If
  Next
  Call push_array(data, "")
  
  'ユニーク制約
  Call push_array(data, indent(2) & "unique:")
  Call push_array(data, indent(3) & to_yaml("exists", Range("ユニーク_EXISTS").value))
  If Range("ユニーク_EXISTS").value Then
    Call push_array(data, indent(3) & "constraints:")
    For Each Target In Range("ユニーク_FORM")
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
  
  'チェック制約
  Call push_array(data, indent(2) & "check:")
  Call push_array(data, "")
  
  '外部キー制約
  Call push_array(data, indent(2) & "foreign_key:")
  Call push_array(data, "")
  
End Sub

Public Sub out_view_md(data() As String)
  Dim Target As Range, i As Long, is_not_null As Boolean, constraint As String

  Call push_array(data, "")
  
  '基本情報
  Call push_array(data, "## #" & Range("テーブルNO").value & " " & Range("テーブルJP").value & " (" & Range("テーブルEN").value & ")")
  Call push_array(data, "")
  
  'テーブル項目
  Call push_array(data, "### fielsds")
  Call push_array(data, "| # | name_jp | name_en | model | not_null | default | field_constraint |")
  Call push_array(data, "| -- | -- | -- | -- | -- | -- | -- |")
  For Each Target In Range("テーブル項目FORM")
    If Target.value <> "" Then
      i = Target.Row
      is_not_null = Cells(i, NOTNULL).value = 1
      If Cells(i, チェック制約).value = "0" Then constraint = "" Else constraint = Replace(Cells(i, チェック制約).value, "|", "&#124;")
      
      Call push_array(data, "| " & Cells(i, NO).value & " | " & Cells(i, 項目名JP).value & " | " & Cells(i, 項目名EN).value & _
       " | " & Cells(i, データ型).value & " | " & is_not_null & " | " & Cells(i, デフォルト値).value & " | " & constraint & " |")
    End If
  Next
  
  Call push_array(data, "### table constraint")
  Call push_array(data, "#### primary key")
  For Each Target In Range("PK項目FORM")
    If Target.value <> "" Then
      Call push_array(data, "* " & Target.value)
    End If
  Next
  
  If Range("ユニーク_EXISTS").value Then
    Call push_array(data, "#### unique")
    i = 0
    For Each Target In Range("ユニーク_FORM")
      If Target.value Then
        i = i + 1
        Call push_array(data, "##### " & Range("テーブルEN") & "_unique_" & i)
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
  
  file_name = DDL_DIR & "\" & DDL_PREFIX & SCHEMA_EN & "_" & Range("テーブルEN").value & ".sql"
  table_name = SCHEMA_EN & "." & Range("テーブルEN").value

  Call push_array(data, "")
  
  '基本情報
  Call push_array(data, "-- " & Range("テーブルNO").value & "." & Range("テーブルJP").value & "(" & Range("テーブルEN").value & ")")
  Call push_array(data, "")
  
  'Create Table
  Call push_array(data, "-- Create Table")
  Call push_array(data, "DROP TABLE IF EXISTS " & table_name & " CASCADE;")
  Call push_array(data, "CREATE TABLE " & table_name & " (")
  
  For Each Target In Range("テーブル項目FORM")
    If Target.value <> "" Then
      i = Target.Row
      Call push_array(data, indent(1) & Cells(i, 項目名EN).value & " " & Cells(i, データ型).value & _
         not_null_token(Cells(i, NOTNULL).value) & default_token(Cells(i, デフォルト値).value, Cells(i, 文字列デフォルト有無).value) & _
         check_constraint(Cells(i, チェック制約).value) & ",")
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
  For Each Target In Range("テーブル項目FORM")
    If Target.value <> "" Then
      i = Target.Row
      Call push_array(data, "COMMENT ON COLUMN " & table_name & "." & Cells(i, 項目名EN).value & " IS '" & Cells(i, 項目名JP).value & "';")
    End If
  Next
  Call push_array(data, "COMMENT ON COLUMN " & table_name & ".created_at IS '作成日時';")
  Call push_array(data, "COMMENT ON COLUMN " & table_name & ".updated_at IS '更新日時';")
  Call push_array(data, "COMMENT ON COLUMN " & table_name & ".created_by IS '作成者';")
  Call push_array(data, "COMMENT ON COLUMN " & table_name & ".updated_by IS '更新者';")
  Call push_array(data, "")
  
  
  'PK Constraint
  Call push_array(data, "-- Set PK Constraint")
  Call push_array(data, "ALTER TABLE " & table_name & " ADD PRIMARY KEY (")
  
  '一度wkに入れる（最後だけカンマつけたくないため）
  For Each Target In Range("PK項目FORM")
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
  If Range("ユニーク_EXISTS").value Then Call push_array(data, "-- Set Unique Constraint")
  i = 0
  For Each Target In Range("ユニーク_FORM")
    If Target.value Then
      i = i + 1
      Call push_array(data, "ALTER TABLE " & table_name & " ADD CONSTRAINT " & Range("テーブルEN") & "_unique_" & i & " UNIQUE (")
      
      '一度wkに入れる（最後だけカンマつけたくないため）
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
  Call push_array(data, "CREATE TRIGGER " & Range("テーブルEN").value & "_updated")
  Call push_array(data, indent(1) & "BEFORE UPDATE")
  Call push_array(data, indent(1) & "ON " & table_name)
  Call push_array(data, indent(1) & "FOR EACH ROW")
  Call push_array(data, "EXECUTE PROCEDURE set_updated_at()")
            
  Call text_io.plain_out(file_name, data, line_sep)
End Sub

' not null の文字列
Private Function not_null_token(val As Long) As String
  If val = 1 Then not_null_token = " NOT NULL" Else not_null_token = ""
End Function

' defaultの文字列
Private Function default_token(val As String, is_string_default As Boolean) As String
  If val = "" Then
    default_token = ""
  ElseIf is_string_default Then
    default_token = " DEFAULT '" & val & "'"
  Else
    default_token = " DEFAULT " & val
  End If
End Function

' check制約 の文字列
Private Function check_constraint(val As String) As String
  If val = "0" Then
    check_constraint = ""
  Else
    check_constraint = " check " & val
  End If
End Function

