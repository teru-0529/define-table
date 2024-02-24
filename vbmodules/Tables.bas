Attribute VB_Name = "Tables"
Option Explicit

'// DDL�p�̃V�[�g���쐬����
Public Function Create(tableNo As Long, tableName As String) As Worksheet
  Dim new_sht As Worksheet
  
  template.Visible = xlSheetVisible
  
  '// �Ō���Ƀe���v���[�g���R�s�[
  template.Copy After:=Worksheets(Worksheets.Count)
  Set Create = ActiveSheet
  Create.Name = tableName
  
  '// �e�[�u���ԍ��o�^
  Create.Range("TABLE_NO").Value = tableNo
  
  index_sht.Activate
  template.Visible = xlSheetHidden
End Function

'// DDL�p�̃V�[�g��S�č폜����
Public Sub Delete()
  Dim Target As Worksheet

  For Each Target In Worksheets
    If isTable(Target) Then
      Application.DisplayAlerts = False
      Target.Delete
      Application.DisplayAlerts = True
    End If
  Next Target
End Sub

'// �f�[�^Load(From yaml)
Public Sub load(sht As Worksheet, record As String)
  Const DELIM1 = "*1*"
  Const DELIM2 = "*2*"
  Const DELIM3 = "*3*"
  Const DELIM4 = "*4*"
  Dim i As Long, j As Long, rowNo As Long, colNo As Long
  Dim data() As String, fields() As String, field() As String, pk() As String, uniques() As String, unique() As String
  Dim fks() As String, fk() As String, fkFields() As String, indexes() As String, index() As String, indexFields() As String
  
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
      '// �����t�������̐ݒ�
    Call Formatter.condFunction(sht.Range("FIELD_NAME").Resize(1).Offset(i, 3), "=RC22")
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
  
  '// fks
  '// [refTabke]<DELIM3>[deleteOption]<DELIM3>[updateOption]<DELIM3>[thisField]<tab>[refField]<DELIM4>[thisField]<tab>[refField]<DELIM2>
  '//     [refTabke]<DELIM3>[deleteOption]<DELIM3>[updateOption]<DELIM3>[thisField]<tab>[refField]...
  Debug.Print data(4)
  If Len(data(4)) > 0 Then
    fks = Split(data(4), DELIM2)
    For i = 0 To UBound(fks)
      rowNo = 26 + i * 5 '// �e�[�u�������L�ڂ���s�ԍ�
      fk = Split(fks(i), DELIM3)
      sht.Cells(rowNo, 12).Value = fk(0)  '// refTable
      sht.Cells(rowNo, 14).Value = fk(1)  '// deleteOption
      sht.Cells(rowNo, 16).Value = fk(2)  '// updateOption
      fkFields = Split(fk(3), DELIM4)
      For j = 0 To UBound(fkFields)
        colNo = 12 + j '// �t�B�[���h�����L�ڂ����ԍ�
        sht.Cells(rowNo + 2, colNo).Value = Split(fkFields(j), vbTab)(0)  '// thisField
        sht.Cells(rowNo + 3, colNo).Value = Split(fkFields(j), vbTab)(1)  '// refField
      Next j
    Next i
  End If
  
  '// indexes
  '// [unique]<DELIM3>[field]<tab>[isAsc]<DELIM4>[field]<tab>[isAsc]<DELIM2>
  '//     [unique]<DELIM3>[field]<tab>[isAsc]...
  Debug.Print data(5)
  If Len(data(5)) > 0 Then
    indexes = Split(data(5), DELIM2)
    For i = 0 To UBound(indexes)
      rowNo = 55 + i * 2 '// �L�ڂ���s�ԍ�
      index = Split(indexes(i), DELIM3)
      sht.Cells(rowNo + 1, 11).Value = index(0) '// Unique
      indexFields = Split(index(1), DELIM4)
      For j = 0 To UBound(indexFields)
        colNo = 12 + j '// �t�B�[���h�����L�ڂ����ԍ�
        sht.Cells(rowNo, colNo).Value = Split(indexFields(j), vbTab)(0)   '// field
        sht.Cells(rowNo + 1, colNo).Value = Split(indexFields(j), vbTab)(1)  '// asc
      Next j
    Next i
  End If
  
  Call createFieldList(sht)
End Sub

'// �t�B�[���h���X�g/NotNull���X�g�̐���
Public Sub createFieldList(sht As Worksheet)
  Dim baseField As Range, nnField As Range, src As Range

  '// ���X�g�̃N���A
  sht.Range("FIELD_AREA").ClearContents
  sht.Range("FIELD_AREA").Resize(1).Value = "N/A"

  '// �o�^�ʒu
  Set baseField = sht.Range("FIELD_AREA").Resize(1, 1)
  Set nnField = baseField.Offset(, 1)

  For Each src In sht.Range("FIELD_NAME")
    If src.Value <> "" Then
      '// �t�B�[���h���X�g�o�^
      baseField.Value = src.Value
      Set baseField = baseField.Offset(1)

      If src.Offset(, 3).Value = 1 Then
        '// NotNull���X�g�o�^
        nnField.Value = src.Value
        Set nnField = nnField.Offset(1)
      End If

    End If
  Next src
End Sub

'// �e�[�u�����X�g���ŐV������
Public Sub ListUpdate()
  Dim Target As Worksheet

  For Each Target In Worksheets
    If isTable(Target) Then Call createTableList(Target)
  Next Target
  Debug.Print "[tableListUpdated]"
End Sub

'// �e�[�u�����X�g�̐���
Public Sub createTableList(sht As Worksheet)
  Dim table As Range, ws As Worksheet

  '// ���X�g�̃N���A
  sht.Range("TABLE_AREA").ClearContents
  sht.Range("TABLE_AREA").Resize(1).Value = "N/A"

  '// �o�^�ʒu
  Set table = sht.Range("TABLE_AREA").Resize(1)

  For Each ws In ThisWorkbook.Worksheets
    '// ���g�������e�[�u���V�[�g�̏ꍇ�Ƀ��X�g�ɒǉ�
    If isTable(ws) And ws.Name <> sht.Name Then
      table.Value = ws.Name
      Set table = table.Offset(1)
    End If
  Next ws
End Sub

'// �e�[�u���V�[�g���ǂ�����Ԃ�
Private Function isTable(ws As Worksheet) As Boolean
  Select Case ws.Name
    Case elements.Name, index_sht.Name, work.Name, template.Name
      isTable = False
    Case Else
      isTable = True
  End Select
End Function
