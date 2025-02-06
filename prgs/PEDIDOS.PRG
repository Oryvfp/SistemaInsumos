
*:*********************************************************************
* PEDIDOS
********
set confirm off
store .f. to salped
store ' ' to c,b,i
close databases
set clock to 4,47
do while .not. salped
   clear
 @ 0,0,24,79 box replicate(chr(178),9)
   @ 2,3 to 4,45 double
   @ 2,4 say date()
   @ 3,14 say 'PANTALLA QUE MANEJA LOS PEDIDOS'
   @  8,20 to 21,52 double
   @ 18,21 to 18,51
   @  9,21 prompt ' 1 - CARGO PEDIDOS             '
   @ 10,21 prompt ' 2 - BAJA DE PEDIDOS           '
   @ 11,21 prompt ' 3 - EXPORTAR PEDIDO A EXCEL   '
   @ 12,21 prompt ' 4 - EXPORTAR ROTULOS A EXCEL  '
   @ 13,21 prompt ' 5 - Cierre pedido s/impresora '
   @ 14,21 prompt ' 6 - Abre pedido p/modificar   '
   @ 15,21 prompt ' 7 - Genero para modem o e-mail'
   @ 16,21 prompt ' 8 - Hacer mensaje para modem  '
   @ 17,21 prompt ' 9 - Volver a pedir pendientes ' 
   @ 18,21 prompt '10 - Acceso a Outlook 2000     '
   @ 20,21 prompt '11 - VOLVER AL MENU PRINCIPAL  '

   store 1 to opcion
   menu to opcion
   @ 5,10
   do case
   case opcion = 1
      do pedicon
   case opcion = 2
      store 'B' to contro
      do pedicoo
   case opcion = 3
      store 'C' to contro
      do pedicoo
   case opcion = 4
      store 'C' to contro
      do pedicoo_
   case opcion = 5
      store 'Y' to contro
      do pedicoo
   case opcion = 6
     store 'Z' to contro
     do pedicoo
   case opcion = 7
     do modem
  case opcion = 8
set clock to 24,71
   modi comm c:\infobal\modem\mensaje.txt
  case opcion = 9
store 'J' to contro
do pedicoo
 case opcion = 10
! /n C:\Aw\newremo\awremote.exe
   case opcion = 11
      clear
      return
   otherwise
  endcase
  enddo
*: EOF: PEDIDOS.PRG
