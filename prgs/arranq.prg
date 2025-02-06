
*:*********************************************************************
*ESTE PROGRAMA GENERA LA PANTALLA PRINCIPAL .
clear all
set color of messages to w+
set color of highlight to gr+
set color of titles to r+
SET COLOR OF BOX TO BR/GR
define window BUCEO from 6,1 to 19,78 panel 
DEFINE WINDOW MSG FROM 17,02 TO 21,45 DOUBLE
DEFINE WINDOW IMPRE FROM 00,00 TO 02,14 DOUBLE COLOR W+
define window preso from 5,10 to 18,59 panel
DEFINE WINDOW TEC_ESC FROM 07,00 TO 09,43 DOUBLE COLOR W+

SET MULTILOCKS ON
SET REPROCESS TO AUTOMATIC
SET EXCLUSIVE OFF
set escape off
set debug off
set hours to 24
set delimiter on
set decimals to 2
set fixed on
set echo off
set exact on
set talk off
set bell on
set confirm off
set intensity on
set status off
set delete on
set safety off
set date ital
set typeahead to 10

store .f. to salida
close databases 
*clear
 define window espera from 11,20 to 20,60 panel
SET PRINTER TO LPT1
do while .not. salida
   @ 4,53 say date()
   set clock to 4,14
   @ 3,23 to 5,51 double
   @ 7,21 to 19,54 double
   @ 17,22,17,51 box replicate(chr(178),9)
   @ 17,22 say repl(chr(240),30)
   @  1,22 say 'SISTEMA ORY VERSION I'
*   @  4,24 say EMPRE
   set message to 28
 
   @ 16,22 prompt ' 1 - ORGANIZAR MAESTRO          ' message '                ----->>INDEXA LISTADO MAESTRO'
   @ 18,22 prompt '2 - SALIR DEL SISTEMA          ' message '                ----->>SALE DEL PROGRAMA'
   
   store 1 to opcion
   menu to opcion
   do case
       case opcion = 1
   store ' ' to resp
      @ 21,10 to 23,60 double
      @ 22,11 say 'ESTA SEGURO DE QUERER REINDEXAR!!!!' get resp pict '!'
      read
      if resp = 'S'
         clear
   @ 7,19 to 10,56 double
   @ 8,20 say 'UN MOMENTO POR FAVOR ESTOY INDEXANDO'
   @ 9,20 say '             ==MUCHAS GRACIAS==     '
      activate window espera
         set talk on
        use maespr_1
         index on nromaes to maesnro compact
         use maespr_1
         index on nropro to nropro compact
         use maespr_1
         index on substr(pieza,1,11) to maesabc compact
         use maespr_1
index on alltrim(provee)+alltrim(nropro)+alltrim(indus) to propro compact
         close databases
     set talk off
     deactivate window espera
        endif
      CASE OPCION = 2
      close all     
      clear all
      clear
      set clock to
      set sysmenu to default
      @ 24,2 say 'CIERRE DE BASE NORMAL'
clear
return
*quit
    otherwise
   endcase
enddo
