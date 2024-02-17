Attribute VB_Name = "read_write_files"
Option Explicit

  '// FIXME:★★★★★
'save_data.yaml読込
Public Sub load_(ByVal line_sep As Integer)
  Dim data() As String, i As Long
  Dim sep_nos() As Long
  
  Call index_sht.clear
  Call table_sheets.clear
  
  
  data = text_io.plain_in(SAVE_DATA, line_sep)

  'DDL単位で分割
  ReDim Preserve sep_nos(0)
  For i = 0 To UBound(data)
    If data(i) = "- ddl:" Then
      sep_nos(UBound(sep_nos)) = i
      ReDim Preserve sep_nos(UBound(sep_nos) + 1)
    End If
  Next i
  sep_nos(UBound(sep_nos)) = UBound(data) + 1
  
  'DDL単位で処理
  For i = 0 To UBound(sep_nos) - 1
    Call load_elements(data, i, sep_nos(i), sep_nos(i + 1))
  Next i
  
End Sub

  '// FIXME:★★★★★
'DDL単位の読込
Private Sub load_elements(data() As String, table_no As Long, start_no As Long, end_no As Long)
  Dim elements() As String, i As Long
  Dim target_index_Jp As Range, target_sht As Worksheet

  Dim wk() As String
  Dim s1 As Long, s2 As Long, s3 As Long


  For i = 0 To UBound(data)
    If i > start_no And i < end_no Then Call push_array(elements, data(i))
  Next i
  
  Set target_index_Jp = index_sht.Range("テーブル一覧START").Offset(table_no)
  target_index_Jp.Value = from_yaml(elements(0))
  target_index_Jp.Offset(, 1).Value = from_yaml(elements(1))
  Set target_sht = index_sht.create_table_sheet(target_index_Jp.Offset(, -2))
  
  '区切り文字の行番号
  s1 = get_sep_no(elements, "    primary_key:")
  s2 = get_sep_no(elements, "    unique:")
  s3 = get_sep_no(elements, "    check:")
  
  'fields入力
  For i = 4 To (s1 - 1)
    Call push_array(wk, elements(i))
  Next i
  Call load_fields(target_sht, wk)
  Erase wk
  
  'pk入力
  For i = (s1 + 1) To (s2 - 2)
    Call push_array(wk, elements(i))
  Next i
  Call load_pk(target_sht, wk)
  Erase wk
  
  'unique入力
  If from_yaml(elements(s2 + 1)) = "True" Then
    For i = (s2 + 4) To (s3 - 2)
      Call push_array(wk, elements(i))
    Next i
    Call load_unique(target_sht, wk)
    Erase wk
  End If
  
  Call Tables.createFieldList(target_sht)
  
  
  'Debug.Print wk(0)
  'Debug.Print UBound(wk)
  
  
  'Debug.Print elements(UBound(elements) - 2)
  'Debug.Print UBound(elements)

End Sub


  '// FIXME:★★★★★
'フィールドデータ登録
Private Sub load_fields(target_sht As Worksheet, data() As String)
  Const PARAMS = 4
  Dim row_length As Long: row_length = (UBound(data) + 1) / PARAMS
  Dim i As Long
  ReDim wk_range_1(row_length - 1, 0)
  ReDim wk_range_2(row_length - 1, 1)
   
  For i = 0 To row_length - 1
    wk_range_1(i, 0) = from_yaml(data(i * PARAMS + 0))  '項目名JP
    
    wk_range_2(i, 0) = from_yaml(data(i * PARAMS + 1))  'NOTNULL
    wk_range_2(i, 1) = from_yaml(data(i * PARAMS + 2))  'デフォルト値
  Next i
  
  '値セット
  target_sht.Cells(6, 2).Resize(row_length) = wk_range_1
  target_sht.Cells(6, 5).Resize(row_length, 2) = wk_range_2
End Sub

  '// FIXME:★★★★★
'PKデータ登録
Private Sub load_pk(target_sht As Worksheet, data() As String)
  Dim Target As Range, i As Long

  Set Target = target_sht.Cells(8, 12)
  For i = 0 To UBound(data)
    Target.Value = Mid(Trim(data(i)), 3)
    Set Target = Target.Offset(, 1)
  Next
End Sub

  '// FIXME:★★★★★
'unique constraintデータ登録
Private Sub load_unique(target_sht As Worksheet, data() As String)
  Dim Target As Range, i As Long, x As Long, val As String
  
  x = 13
  Set Target = target_sht.Cells(x, 12)
  For i = 0 To UBound(data)
    val = Mid(Trim(data(i)), 3)
    If val = "constraint:" Then
      x = x + 1
      Set Target = target_sht.Cells(x, 12)
    Else
      Target.Value = val
      Set Target = Target.Offset(, 1)
    End If
  Next
End Sub



  '// FIXME:★★★★★
'セパレート文字列の行番号
Private Function get_sep_no(ByRef data() As String, find_val As String) As Long
  Dim i As Long
  
  For i = 0 To UBound(data)
    If data(i) = find_val Then
      get_sep_no = i
      Exit Function
    End If
  Next i
  
  get_sep_no = -1
End Function

