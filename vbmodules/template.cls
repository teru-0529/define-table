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

Const COL_NOTNULL = 5
Const COL_DEFAULT = 6
Const COL_FORCE_NOTNULL = 8

'カラム番号

  '// FIXME:★★★★★
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

Private Sub Worksheet_SelectionChange(ByVal Target As Range)
  '// ペースト無効
  Application.CutCopyMode = False
End Sub

'// テーブルシート削除イベント
Private Sub Worksheet_BeforeDelete()
  index_sht.dropTable (Range("TABLE_NO").value)
  index_sht.Activate
End Sub

'// 計算処理イベント
Private Sub Worksheet_Calculate()
  Call Util.invalidTableSheet(ThisWorkbook.Worksheets(name), Range("ERRORS").value > 0)
End Sub

'セル値の変更があった場合
Private Sub Worksheet_Change(ByVal Target As Range)
  Dim area As Range, elm As Range, i As Long
  
  Application.ScreenUpdating = False
  Application.EnableEvents = False

  '// FieldNameが変更された場合
  Set area = Intersect(Target, Range("FIELD_NAME"))
  If Not area Is Nothing Then
    For Each elm In area
      i = elm.Row
      '// 入力値(NotNull、デフォルト値)のクリア
      Util.unionRange(Cells(i, COL_NOTNULL), Cells(i, COL_DEFAULT)).ClearContents
      '// 強制NOTNULLの設定
      If Cells(i, COL_FORCE_NOTNULL).value = True Then Cells(i, COL_NOTNULL).value = 1
      
      '// 条件付き書式の設定（※入力後すぐのエラーを抑止するため初期化後に書式登録）
      If elm.value = "" Then
        Call Formatter.condClear(Cells(i, COL_NOTNULL))
      Else
        Call Formatter.condFunction(Cells(i, COL_NOTNULL), "=RC22")
      End If
    Next
  End If
  
  '// フィールドリスト/NotNullリストの生成
  If Not Intersect(Target, Util.unionRange(Range("FIELD_NAME"), Range("FIELD_NN"))) Is Nothing Then _
    Call Tables.createFieldList(Worksheets(name))
  
  Application.EnableEvents = True
  Application.ScreenUpdating = True
End Sub



  '// FIXME:★★★★★
'----+----+----+----+----+----+----+----+----+----+
'出力
Public Sub save_(data() As String)
  Dim Target As Range, i As Long

  Call push_array(data, "- ddl:")
  
  '基本情報
  Call push_array(data, indent(2) & to_yaml("table_name_jp", Range("TABLE_JP").value))
  Call push_array(data, indent(2) & to_yaml("table_name_en", Range("TABLE_EN").value))
  Call push_array(data, "")
  
  'テーブル項目
  Call push_array(data, indent(2) & "fielsd:")
  For Each Target In Range("FIELD_NAME")
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
  For Each Target In Range("PK_AREA")
    If Target.value <> "" Then
      Call push_array(data, indent(3) & "- " & Target.value)
    End If
  Next
  Call push_array(data, "")
  
  'ユニーク制約
  Call push_array(data, indent(2) & "unique:")
  Call push_array(data, indent(3) & to_yaml("exists", Range("UNIQUE_EXIST").value))
  If Range("UNIQUE_EXIST").value Then
    Call push_array(data, indent(3) & "constraints:")
    For Each Target In Range("UNIQUE_AREA")
      If Target.value <> "" Then
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

  '// FIXME:★★★★★
Public Sub out_view_md(data() As String)
  Dim Target As Range, i As Long, is_not_null As Boolean, constraint As String

  Call push_array(data, "")
  
  '基本情報
  Call push_array(data, "## #" & Range("TABLE_NO").value & " " & Range("TABLE_JP").value & " (" & Range("TABLE_EN").value & ")")
  Call push_array(data, "")
  
  'テーブル項目
  Call push_array(data, "### fielsds")
  Call push_array(data, "| # | name_jp | name_en | model | not_null | default | field_constraint |")
  Call push_array(data, "| -- | -- | -- | -- | -- | -- | -- |")
  For Each Target In Range("FIELD_NAME")
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
  For Each Target In Range("PK_AREA")
    If Target.value <> "" Then
      Call push_array(data, "* " & Target.value)
    End If
  Next
  
  If Range("UNIQUE_EXIST").value Then
    Call push_array(data, "#### unique")
    i = 0
    For Each Target In Range("UNIQUE_AREA")
      If Target.value <> "" Then
        i = i + 1
        Call push_array(data, "##### " & Range("TABLE_EN") & "_unique_" & i)
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


  '// FIXME:★★★★★
Public Sub out_ddl(ByVal line_sep As Integer)
  Dim data() As String, file_name As String, table_name As String, Target As Range, i As Long, j As Long
  Dim wk() As String
  
  file_name = DDL_DIR & "\" & DDL_PREFIX & SCHEMA_EN & "_" & Range("TABLE_EN").value & ".sql"
  table_name = SCHEMA_EN & "." & Range("TABLE_EN").value

  Call push_array(data, "")
  
  '基本情報
  Call push_array(data, "-- " & Range("TABLE_NO").value & "." & Range("TABLE_JP").value & "(" & Range("TABLE_EN").value & ")")
  Call push_array(data, "")
  
  'Create Table
  Call push_array(data, "-- Create Table")
  Call push_array(data, "DROP TABLE IF EXISTS " & table_name & " CASCADE;")
  Call push_array(data, "CREATE TABLE " & table_name & " (")
  
  For Each Target In Range("FIELD_NAME")
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
  For Each Target In Range("FIELD_NAME")
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
  For Each Target In Range("PK_AREA")
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
  If Range("UNIQUE_EXIST").value Then Call push_array(data, "-- Set Unique Constraint")
  i = 0
  For Each Target In Range("UNIQUE_AREA")
    If Target.value <> "" Then
      i = i + 1
      Call push_array(data, "ALTER TABLE " & table_name & " ADD CONSTRAINT " & Range("TABLE_EN") & "_unique_" & i & " UNIQUE (")
      
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
  Call push_array(data, "CREATE TRIGGER " & Range("TABLE_EN").value & "_updated")
  Call push_array(data, indent(1) & "BEFORE UPDATE")
  Call push_array(data, indent(1) & "ON " & table_name)
  Call push_array(data, indent(1) & "FOR EACH ROW")
  Call push_array(data, "EXECUTE PROCEDURE set_updated_at()")
            
  Call text_io.plain_out(file_name, data, line_sep)
End Sub

  '// FIXME:★★★★★
' not null の文字列
Private Function not_null_token(val As Long) As String
  If val = 1 Then not_null_token = " NOT NULL" Else not_null_token = ""
End Function

  '// FIXME:★★★★★
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

  '// FIXME:★★★★★
' check制約 の文字列
Private Function check_constraint(val As String) As String
  If val = "0" Then
    check_constraint = ""
  Else
    check_constraint = " check " & val
  End If
End Function
