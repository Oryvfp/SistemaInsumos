Function OpenForm1
LPARAMETER cForm
LOCAL i, lOk

lOk = .F.

* recorro todos los forms abiertos...
FOR i = i + 1 TO _SCREEN.FormCount
  * consulto por la propiedad 'cFormName'...
  IF  PEMSTATUS(_SCREEN.Forms[m.i],'cFormName',5)
    IF _SCREEN.Forms[m.i].cFormName == cForm
      _SCREEN.Forms[m.i].Show()
      lOk = .T.
    ENDIF
  ENDIF
NEXT i
IF !lOk
  DO FORM (cForm) NAME _Form NOSHOW
  * si no tiene la propiedad 'cFormName' la creo
  IF  !PEMSTATUS(_SCREEN.Forms[m.i],'cFormName',5)
    _SCREEN.Forms[m.i].AddProperty('cFormName')
  
   endif
    _Form.cFormNam = cForm
  
_Form.Show()
*ENDIF
ENDIF

**********