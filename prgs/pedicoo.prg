*:*********************************************************************
clear
define window VEOPE from 1,1 to 20,42 panel title 'PEDIDOS'
define window buceo from 1,1 to 20,62 panel title 'PEDIDOS' 
  CLEAR
  @ 5,43,9,78 box replicate(chr(178),9)
   close databases
   select a
   use pedidos INDEX NROPED,PEDIDOS
   select b
   use artiped index artiped
   store 0 to npe
   @ 2,4 say date()
  * set clock to 2,57
   if contro = 'C'
      @ 7,47 say 'EXPORTA SU PEDIDO A EXCEL'
   endif
   if contro = 'J'
      @ 7,47 say 'PANTALLA para PEDIR PENDIENTES'
   endif

   if contro = 'B'
      @ 7,47 say 'PANTALLA BAJAS DE PEDIDOS'
   endif
   if contro = 'I'
      @ 6,48 say 'PANTALLA PARA IMPRESION'
      @ 7,48 say '     DE PEDIDOS        '
   endif
   if contro = 'Y'
      @ 6,48 say 'PANTALLA PARA CERRAR '
      @ 7,48 SAY 'PEDIDOS SIN IMPRESORA'
   endif      
   if contro = 'Z'
      @ 6,48 say 'PANTALLA ABRE PEDIDOS'
      @ 7,48 say '  PARA MODIFICARLOS  '
    endif                                                     
  
SELECT A
GO BOTT
BROW FIELDS Pedido=NROPED*1,FECHA,Proveedor=PROVEE+'',Impreso=CONTROL+'',M=MODEM+'' noedit nomenu normal window VEOPE 

store provee to pro
store nroped to npe
store fecha to fed
IF CONTRO = 'J'
LOCATE FOR PROVEE = PRO AND CONTROL =  ' '
IF NOT FOUND()
SET DELETED OFF
SELECT A
GO BOTT
STORE NROPED+1 TO NP
APPE BLANK
REPLA NROPED WITH NP,PROVEE WITH PRO,FECHA WITH FED
SET DELETED ON
ENDIF
SELECT B
COPY TO PEPE FOR NROPED = NPE
SELECT A
store provee to pro
store nroped to npe
store fecha to fed

CLOSE DATABASES
USE PEPE
REPLA ALL NROPED WITH NPE
  use artiped index artiped,ARTALTER,nromaes
appe from pepe
endif
   if contro = 'Y'
   select a
   repla all control with 'Y' for nroped = npe
   select b
   repla all control with 'Y' for nroped = npe
   endif
  if contro = 'Z'
  select a
  locate all for nroped = npe
  locate all for provee = pro and control = ' '
  if found()
  @ 10,26 to 12,60 double
  @ 11,27 say 'Primero debe cerrar el pedido nro-->' + str(nroped)
  @ 22,0
   WAIT '>>>>>>>>>>>>>>>> PULSE UNA TECLA PARA CONTINUAR>>>>>>>>>>>>>'
 clear
 return
  endif
    repla all control with ' ' for nroped = npe
    select b                                   
    repla all control with ' ' for nroped = npe
    set confirm off                            
    endif                                      
   if contro = 'B'
  @ 22,4  to 24,14 double   
  @ 22,15 to 24,25 double   
  @ 23,5  prompt 'BORRO ?? '
  @ 23,16 prompt 'NO BORRO '
  store 2 to opcion         
  menu to opcion            
  do case                   
   case opcion = 1          

     select b
      delete all for nroped = npe
      select a
      delete all for nroped = npe
        clear               
   case opcion = 2
   clear
 OTHERWISE
 ENDCASE 
endif
if contro = 'C'
     close databases 
      select a
      use giesse index propro
      select b
      use artiped index artalter
SET RELATION TO alltrim(ALTER)+alltrim(nropro)+alltrim(indus) INTO giesse
      clear
      @  2,6 say 'Numero de Pedido:  '
      @  2,25 say npe picture '9999'
      @  4,6 say 'Proveedor --> ' + pro
      @  5,46 say 'Fecha de Pedido: '
      @  5,63 say fed
brow field prelis=a->prelis,Cost_iva=round(a->Precious*1.25,2):8,nropro,cant,a->pieza,Precio=a->precious*1.25 :6,TOTAL = round(a->precious*CANT,2):8 freeze cant FOR PROVEE = PRO AND NROPED = NPE nomenu normal window BUCEO COLOR G+ 
store 1.25 to precious
COPY TO D:\PEDIDO.XLS TYPE xls FIELDS NROPRO,CANT,PIEZA,precious FOR PROVEE = PRO AND NROPED = NPE 
! D:\ARCHIV~1\MICROS~2\OFFICE10\EXCEL.EXE D:\PEDIDO.XLS
Deactivate windoW buceo
dele all for cant = 0
SUM ALL CANT*A->PRECIOUS TO TOTA FOR NROPED = NPE AND PROVEE = PRO
      @ 15,20 say 'IMPORTE TOTAL EN sin IVA U$s'
      @ 15,49 say tota pict '99,999.99'
SUM ALL CANT*A->PRECIOUS*1.25 TO TOTA FOR NROPED = NPE AND PROVEE = PRO
@ 17,20 say 'IMPORTE TOTAL EN con IVA U$s + flete'
      @ 17,49 say tota pict '99,999.99'
WAIT ' ' TIMEOUT (5)
 clear
 CLOSE DATABASES
 endif
      if contro = 'I'
       store 0 to total
      erase c:orden.dbf
select b
      sort on provee to orden for nroped  = npe
         do impped
         clear
CLOSE DATABASES
      endif
*: EOF: PEDICOO.PRG
