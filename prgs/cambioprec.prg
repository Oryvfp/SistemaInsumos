*:*********************************************************************
**
define window pedir from 20,3 to 50,60 double float close minimize; 
title 'Resto STOCK' COLOR w+/n&& Crea una ventana 
define window control from 3,48 to 24,79 double float close minimize
define window alter from 14,2 to 20,11 double float close minimize
MODIFY WINDOW Pedir  FONT "Segoe Marker", 12  STYLE "N"
set color of highlight to gr+
SET COLOR OF BOX TO BR/GR
store space(8) to po
store 'S' to pido
ACTIVATE WINDOW pedir 
do while pido = 'S'
store 0 to canti   && pone 0 la variable canti
store pieza to pza  
store nromaes to nro
store nropro to ap
STORE precious TO pre
STORE STOCK TO STO
store provee to pro,alt
store indus to in
STORE imagen TO ima
STORE ubica TO ubi
store 0 to xa 
if pro = 'RENAULT '
STORE 'RENAULT ' TO ALT
ACTIVATE WINDOW ALTER
SELECT alterna
BROW noedit
STORE PROVEE TO PRO
ENDIF
DEACTIVATE WINDOW ALTER
select stock   && Selecciona la Tabla Stock.dbf                                                         
STORE coment TO observ && Creo la variable 
STORE preciode TO prede 
STORE precious TO precio                        
     store 3 to ct                                                 
   *  SELECT stock                
            

  ACTIVATE WINDOW PEDIR
*SELECT A  
  STORE XA TO CANTI
   *@ 1,0 to 2.5,54 double color bg/r
   @ 1,0 say '�NUMERO PROVEEDOR-->'
   @ 1,23 say ap                     
   @ 3,0 say '�precio Anterior->'
   @ 3,21 say pre                         
   @ 5,0 say '�Pieza-->' 
   @ 5,17 say pza 
    @ 6,0 say '�Ubicacion-->' 
   @ 6,14 say ubi 
   @ 7,0  say '�precious' get canti pict '999999.99'
   @ 9,0 say '�PROVEEDOR-->'
   @ 9,20 say pro 
   @ 11,0 say 'Precio de:'
   @ 12,1 get prede 
   @ 13,1 say '�Stock Anterior->'
   @ 13,21 say sto pict '999999.99' 
   @ 14,0 say 'Comentario '
   @ 15,1 get observ  
 
   read
do while canti = 0  && si no Escribe la cantidad se ejecuta el bucle dowhile
  ?? chr(7)
  ?? chr(7)
  ?? chr(7)
      @ 7,0  say 'Precious-->' get canti pict '999999.99'
  read
 enddo
   
ACTIVATE WINDOW  CONTROL
      SELECT stock
   STORE ' ' TO RESP
   @ ct+1,5 prompt 'CONFIRMAR'
   @ ct+3,5 prompt ' VOLVER  '
    store 1 to voy           
    menu to voy              
    do case                  
    case voy = 1             
    STORE 'S' TO RESP                    
    case voy = 2       
  otherwise      
 DEACTIVATE WINDOW control
 DEACTIVATE WINDOW alter            
 DEACTIVATE WINDOW pedir
  endcase                    
 if resp = 'S'
 appe blank
 repla provee with pro,nromaes with nro,ubica WITH ubi
 repla nropro with ap,indus with in,pieza with pza
 replace imagen WITH ima
 replace fecha WITH DATE()
 replace precious with canti
 replace preciode WITH prede
 replace stock WITH STO
 replace stocupdate WITH stock
 replace coment WITH observ
 
   endif
select giesse
   replace precious WITH canti  && Hace un Replace Con Formula Sustraccion
   replace stock WITH STO
   store 'N' to pido
enddo
deactivate window control
DEACTIVATE WINDOW alter
DEACTIVATE WINDOW pedir
clear
*return
*: EOF: PEDIPRO.PRG
