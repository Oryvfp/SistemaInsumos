LOCAL i,cn,vlnamef
vlnamef='Ejemplo'	&&Debe colocarse como parametro el name del formulario a ejecutar
cn=0
FOR i = 1 TO _SCREEN.FormCount
vlname=_screen.Forms(i).name
IF vlname=vlnamef
cn=cn+1
ENDIF
ENDFOR

IF cn=0
DO FORM &vlnamef
ENDIF