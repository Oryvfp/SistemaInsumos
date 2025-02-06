lParameter tcFormName
for each oForm in _screen.forms
   if upper(oForm.Name) = upper(tcFormName)
      return .T.
   endif
endfor
return .F.