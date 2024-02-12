Attribute VB_Name = "Formatter"
Option Explicit


Public Const IME_MODE_ON = True
Public Const IME_MODE_OFF = False

'// ���Z�b�g
Sub reset(ByRef area As Range)
  If area Is Nothing Then Exit Sub
  With area
    .Interior.ColorIndex = xlNone
    .Validation.Delete
    .FormatConditions.Delete
    .NumberFormatLocal = "G/�W��"
  End With
End Sub

'// �g���E�����T�C�Y
Sub borderAndFontsize(ByRef area As Range)
  If area Is Nothing Then Exit Sub
  With area
    .Borders.LineStyle = xlContinuous
    .Borders.Color = RGB(68, 114, 196) 'DEEP_BLUE
    .Borders(xlEdgeTop).Color = RGB(189, 215, 238) 'WEAK_BLUE
    .Borders(xlInsideHorizontal).Color = RGB(189, 215, 238) 'WEAK_BLUE
    .Font.Size = 9
  End With
End Sub

'// ���X�g�I��
Sub listSelect(ByRef area As Range, ByVal listName As String)
  Dim condFormat As FormatCondition
  If area Is Nothing Then Exit Sub

  '���͋K��
  With area.Validation
    .Delete
    .Add Type:=xlValidateList, AlertStyle:=xlValidAlertStop, Operator:=xlBetween, Formula1:="=" & listName
  End With

  '�����t������
  Call condFunction(area, "=AND(RC<>"""",ISNA(MATCH(RC," & listName & ",0)))")
End Sub

'// �����t������
Sub condFunction(ByRef area As Range, ByVal formula As String)
  Dim condFormat As FormatCondition
  If area Is Nothing Then Exit Sub

  Set condFormat = area.FormatConditions.Add(Type:=xlExpression, Formula1:=formula)
  condFormat.Interior.Color = work.Range("�G���[").Interior.Color
End Sub

'// �����t������(�K�{)
Sub condReqired(ByRef area As Range)
  Dim condFormat As FormatCondition
  If area Is Nothing Then Exit Sub

  Set condFormat = area.FormatConditions.Add(xlBlanksCondition)
  condFormat.Interior.Color = work.Range("�G���[").Interior.Color
End Sub

'// �֐�
Sub setFunction(ByRef area As Range, ByVal formula As String)
  If area Is Nothing Then Exit Sub
  '�֐�
  area.formula = formula
  '�w�i�F
  Call notInput(area)
End Sub

'// �\���`��
Sub formatLocal(ByRef area As Range, ByVal formula As String)
  If area Is Nothing Then Exit Sub
  area.NumberFormatLocal = formula
End Sub

'// �\���ʒu
Sub horizontalPosition(ByRef area As Range, ByVal formula As Integer)
  If area Is Nothing Then Exit Sub
  area.HorizontalAlignment = formula
End Sub

'// �w�i�F
Sub notInput(ByRef area As Range)
  If area Is Nothing Then Exit Sub
  area.Interior.Color = RGB(255, 255, 213) 'CREAM
End Sub

'// IME���[�h
Sub imeMode(ByRef area As Range, ByVal mode As Boolean)
  If area Is Nothing Then Exit Sub
  With area.Validation
    .Delete
    .Add Type:=xlValidateInputOnly
    If mode Then
      .imeMode = xlIMEModeOn
    Else
      .imeMode = xlIMEModeOff
    End If
  End With
End Sub

'// ������
Sub stringSpec(ByRef area As Range)
  If area Is Nothing Then Exit Sub
  With area
    .Interior.ColorIndex = xlNone
    .Validation.Delete
    .Validation.Add Type:=xlValidateInputOnly
    .Validation.imeMode = xlIMEModeOff
    .NumberFormatLocal = "@"
  End With
End Sub

'// �����w��
Sub lengthSpec(ByRef area As Range)
  If area Is Nothing Then Exit Sub
  With area
    .Interior.ColorIndex = xlNone
    .Validation.Delete
    .Validation.Add Type:=xlValidateWholeNumber, AlertStyle:=xlValidAlertStop, Operator:=xlBetween, Formula1:="1", Formula2:="1000"
    .Validation.ErrorMessage = "1-1000�̊Ԃœ��͉\"
    .Validation.imeMode = xlIMEModeOff
    .NumberFormatLocal = "#,##0_ "
  End With
End Sub

'// ���l�͈͎w��
Sub numericSpec(ByRef area As Range)
  If area Is Nothing Then Exit Sub
  With area
    .Interior.ColorIndex = xlNone
    .Validation.Delete
    .Validation.Add Type:=xlValidateWholeNumber, AlertStyle:=xlValidAlertStop, Operator:=xlBetween, Formula1:="-999999999999", Formula2:="999999999999"
    .Validation.ErrorMessage = "���l�̂ݓ��͉\"
    .Validation.imeMode = xlIMEModeOff
    .NumberFormatLocal = "#,##0_ "
  End With
End Sub

'// ���p�s�w��
Sub unabledSpec(ByRef area As Range)
  If area Is Nothing Then Exit Sub
  With area
    .Interior.Color = work.Range("���͕s��").Interior.Color
    .Validation.Delete
    .Validation.Add Type:=xlValidateTextLength, AlertStyle:=xlValidAlertStop, Operator:=xlEqual, Formula1:="0"
    .Validation.ErrorMessage = "���͕s���ڂł�"
  End With
End Sub
