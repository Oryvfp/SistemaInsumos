*:*********************************************************************
 define window venta from 18,3 to 24,47 double float close minimize; 
   title 'CARGANDO ETIQUETAS'                                       
*sele a

ACTIVATE WINDOW venta
store 0 to canti,it,des,sto
store '    ' to let
store space(12) to cl
*@ 0,8 say 'CUAL ##? ELIGE ----->' get it pict '99' range 0,nv-1
*read
*j = it - nv
*skip j
store nromaes to nro
store ubicacaja to caja
store ubica to ubi
store nropro to ap
store provee to pro
STORE LINEA TO LIN
store indus to in
store canti to cant
@ 1,1 say 'ARTICULO NUMERO   ----> '
@ 1,27 say ap pict 'XXXXXXXXXXX'
@ 1,39 say indus
@ 3,4 say pieza pict 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
@ 4,1 say 'CANT.ETIQ.HASTA 9 ' get canti pict '9999'
*pre = precious*ut*dolar*iva
*pre = round(pre,2)
*@ 4,13 get pre pict '9,999.99'
*@  4,24 say 'DESC'
*@  4,29 get des pict '99.99'
read
select convirt
SET INDEX TO conlet 

go top
 define window oper from 3,48 to 24,79 double float close minimize; 
   title 'confirmar o no '                              
STORE 1 TO ES
ACTIVATE WINDOW OPER

DO WHILE ES = 1
store 3 to ct
@  1,0 say '   OPERADOR      MONTO NETO'
*   @ ct,2 GET LET pict '!!!!'
 *  READ
 let = "3"
   SEEK LET
  oper ="3"
   IF FOUND()
 STORE 2 TO ES
   @ ct,2 say oper pict 'XXXXXXXX'
  @ ct,12 say monto pict '99,999.99'
   store ct + 1 to ct
store ct + 3 to ct
seek let
@ ct,1 say oper
@ ct + 1,1 to ct+3,9
@ ct + 1,10 to ct+3,13
@ ct + 1,14 to ct+3,16
@ ct + 2,2 prompt 'CONFIRMA'
@ ct + 2,11 prompt 'VUELVE'
store 1 to res
menu to res
do case
case res = 1
  select archi
  set order to letra2
  for cant = 1 to 1
  if canti = 1
   appe blank
repla letra with let,articulo with nro,cantidad with canti,pieza with a->pieza,proveedor with pro,nropro with ap,ubica with ubi,ubicacaja with caja,linea with lin
 endif
  endfor
  if canti = 2
  for cant = 1 to 2
     appe blank
repla letra with let,articulo with nro,cantidad with canti,pieza with a->pieza,proveedor with pro,nropro with ap,ubica with ubi,ubicacaja with caja,linea with lin
endfor
 endif
      if canti = 3
  for cant = 1 to 3
      appe blank
repla letra with let,articulo with nro,cantidad with canti,pieza with a->pieza,proveedor with pro,nropro with ap,ubica with ubi,ubicacaja with caja,linea with lin 
endfor
endif
IF CANTI = 4
for cant = 1 to 4
    appe blank
repla letra with let,articulo with nro,cantidad with canti,pieza with a->pieza,proveedor with pro,nropro with ap,ubica with ubi,ubicacaja with caja,linea with lin 
endfor
ENDIF
  IF CANTI = 5
for cant = 1 to 5
    appe blank
repla letra with let,articulo with nro,cantidad with canti,pieza with a->pieza,proveedor with pro,nropro with ap,ubica with ubi,ubicacaja with caja,linea with lin 
endfor
ENDIF
  IF CANTI = 6
for cant = 1 to 6
    appe blank
repla letra with let,articulo with nro,cantidad with canti,pieza with a->pieza,proveedor with pro,nropro with ap,ubica with ubi,ubicacaja with caja,linea with lin 
endfor
ENDIF

  IF CANTI = 7
for cant = 1 to 7
    appe blank
repla letra with let,articulo with nro,cantidad with canti,pieza with a->pieza,proveedor with pro,nropro with ap,ubica with ubi,ubicacaja with caja,linea with lin 
endfor

ENDIF
  IF CANTI = 8
for cant = 1 to 8

repla letra with let,articulo with nro,cantidad with canti,pieza with a->pieza,proveedor with pro,nropro with ap,ubica with ubi,ubicacaja with caja,linea with lin 
endfor

ENDIF 
  IF CANTI = 9
for cant = 1 to 9
    appe blank
repla letra with let,articulo with nro,cantidad with canti,pieza with a->pieza,proveedor with pro,nropro with ap,ubica with ubi,ubicacaja with caja,linea with lin 
endfor
 ENDIF 
   clear
  select a
DEACTIVATE WINDOW venta
  DEACTIVATE WINDOW oper
   return
case res = 2
      select giesse
 DEACTIVATE WINDOW oper
 DEACTIVATE WINDOW venta
  otherwise
endcase
ENDIF
ENDDO
*: EOF: CARGAR.PRG
