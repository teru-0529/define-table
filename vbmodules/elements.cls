VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "elements"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = True
Option Explicit

'�J�����ԍ�
Private Enum col_no
  ���ږ�J = 1
  ���ږ�ES = 2
  �f�[�^�^ = 3
  �`�F�b�N���� = 4
  ����NOTNULL = 5
  ������f�t�H���g�L�� = 6
  ���� = 7
  �h������ = 8
  �h�����ږ� = 9
End Enum
  
Const max_col = 9


'�t�H�[�}�b�g������
Public Sub init_format(ByVal start_row As Integer, ByVal rows As Integer)
  Application.EnableEvents = False
  
  Dim f_rows As Integer: f_rows = rows  '�t�H�[�}�b�g���s��
  If f_rows = 0 Then Exit Sub

  '�����s�ȍ~���N���A
  UsedRange.Offset(start_row - 1).clear
  
  '�g��
  With Cells(start_row, 1).Resize(f_rows, max_col)
    .Interior.Color = RGB(255, 255, 213) 'CREAM
    .Borders.LineStyle = xlContinuous
    .Borders.Color = RGB(68, 114, 196) 'DEEP_BLUE
    .Borders(xlEdgeTop).Color = RGB(189, 215, 238) 'WEAK_BLUE
    .Borders(xlInsideHorizontal).Color = RGB(189, 215, 238) 'WEAK_BLUE
    .Font.Size = 9
  End With

  '�\���`��
  Cells(start_row, col_no.�h������).Resize(f_rows).NumberFormatLocal = """��"";;;"
  
  '�\���`��
  Cells(start_row, col_no.�h������).Resize(f_rows).HorizontalAlignment = xlCenter
  
  Application.EnableEvents = True
End Sub

'table_elements�Ǎ�
Public Sub load_(ByVal line_sep As Integer)
  Const PARAMS = 10
  Dim data() As String, row_length As Long
  Dim i As Long
  
  data = text_io.plain_in(ELEMENTS_DATA, line_sep)
  row_length = (UBound(data) + 1) / PARAMS
  ReDim wk_range(row_length - 1, 8)
  
  '�`��ӏ��̃t�H�[�}�b�g
  Call init_format(2, row_length)
  
  For i = 0 To row_length - 1
    wk_range(i, 0) = from_yaml(data(i * PARAMS + 0)) '����_�a
    wk_range(i, 1) = from_yaml(data(i * PARAMS + 1)) '����_�p
    wk_range(i, 2) = from_yaml(data(i * PARAMS + 2)) 'DB�^
    wk_range(i, 3) = from_yaml(data(i * PARAMS + 3)) '�`�F�b�N����
    wk_range(i, 4) = from_yaml(data(i * PARAMS + 4)) '����NOTNULL
    wk_range(i, 5) = from_yaml(data(i * PARAMS + 5)) '������f�t�H���g�L��
    wk_range(i, 6) = from_yaml(data(i * PARAMS + 6)) '����
    If from_yaml(data(i * PARAMS + 7)) = "true" Then wk_range(i, 7) = 0 Else wk_range(i, 7) = 1 '�h���C��
    wk_range(i, 8) = from_yaml(data(i * PARAMS + 8)) '�h����
  Next i
    
  '�l�Z�b�g
  Cells(2, col_no.���ږ�J).Resize(row_length, 9) = wk_range
  
End Sub
