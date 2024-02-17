Attribute VB_Name = "Tables"
Option Explicit

'// DDL用のシートを作成する
Public Function Create(tableNo As Long, tableName As String) As Worksheet
  Dim new_sht As Worksheet
  
  template.Visible = xlSheetVisible
  
  '// 最後尾にテンプレートをコピー
  template.Copy After:=Worksheets(Worksheets.Count)
  Set Create = ActiveSheet
  Create.Name = tableName
  
  '// テーブル番号登録
  Create.Range("TABLE_NO").Value = tableNo
  
  index_sht.Activate
  template.Visible = xlSheetHidden
End Function

'// DDL用のシートを全て削除する
Public Sub Delete()
  Dim Target As Worksheet

  For Each Target In Worksheets
    Select Case Target.Name
      Case elements.Name, index_sht.Name, template.Name, work.Name

      Case Else
        Application.DisplayAlerts = False
        Target.Delete
        Application.DisplayAlerts = True
        
     End Select
  Next Target
End Sub

'// データLoad(From yaml)
Public Sub load(sht As Worksheet, record As String)
  Const DELIM1 = "*1*"
  Const DELIM2 = "*2*"
  Dim i As Long, j As Long
  Dim data() As String, fields() As String, field() As String, pk() As String, uniques() As String, unique() As String
  
  '// [tableJp]<tab>[tableEn]<tab>[isMaster]<DELIM1>[Fields]<DELIM1>...
  data = Split(record, DELIM1)
  
  '// base
  sht.Range("IS_MASTER").Value = Split(data(0), vbTab)(2) ' isMaster
  
  Debug.Print sht.Name
  
  '// fields
  '// [fieldName]<tab>[notNull]<tab>[default]<DELIM2>[fieldName]<tab>[notNull]...
  Debug.Print data(1)
  fields = Split(data(1), DELIM2)
  For i = 0 To UBound(fields)
    field = Split(fields(i), vbTab)
    sht.Range("FIELD_NAME").Resize(1).Offset(i).Value = field(0)
    sht.Range("FIELD_NAME").Resize(1).Offset(i, 3).Value = field(1)
    sht.Range("FIELD_NAME").Resize(1).Offset(i, 4).Value = field(2)
  Next i
  
  '// pk
  '// [fieldName]<tab>[fieldName]<tab>[fieldName]...
  Debug.Print data(2)
  pk = Split(data(2), vbTab)
  For i = 0 To UBound(pk)
    sht.Range("PK_AREA").Resize(, 1).Offset(, i).Value = pk(i)
  Next i
  
  '// uniques
  '// [fieldName]<tab>[fieldName]<tab>[fieldName]<DELIM2>[fieldName]<DELIM2>[fieldName]<tab>[fieldName]...
  Debug.Print data(3)
  If Len(data(3)) > 0 Then
    uniques = Split(data(3), DELIM2)
    For i = 0 To UBound(uniques)
      unique = Split(uniques(i), vbTab)
      For j = 0 To UBound(unique)
        sht.Range("UNIQUE_AREA").Resize(1, 1).Offset(i, j).Value = unique(j)
      Next j
    Next i
  End If
  
  Call createFieldList(sht)
End Sub

'// フィールドリスト/NotNullリストの生成
Public Sub createFieldList(sht As Worksheet)
  Dim baseField As Range, nnField As Range, src As Range

  '// リストのクリア
  sht.Range("FIELD_AREA").ClearContents
  sht.Range("FIELD_AREA").Resize(1).Value = "N/A"

  '// 登録位置
  Set baseField = sht.Range("FIELD_AREA").Resize(1, 1)
  Set nnField = baseField.Offset(, 1)

  For Each src In sht.Range("FIELD_NAME")
    If src.Value <> "" Then
      '// フィールドリスト登録
      baseField.Value = src.Value
      Set baseField = baseField.Offset(1)

      If src.Offset(, 3).Value = 1 Then
        '// NotNullリスト登録
        nnField.Value = src.Value
        Set nnField = nnField.Offset(1)
      End If

    End If
  Next src
End Sub
