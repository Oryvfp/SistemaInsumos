*:*********************************************************************
define window pedir from 18,3 to 24,47 double float close minimize;
  title 'CARGANDO PEDIDOS'
  define window control from 3,48 to 24,79 double float close minimize
  define window alter from 14,2 to 18,11 double float close minimize

store space(8) to po
store 'S' to pido
ACTIVATE WINDOW pedir 
do while pido = 'S'
   store 0 to canti
  * it =0
  *  @ 3,8 say 'CUAL ##? ELIGE ----->' get it pict '99' range 0,nv-1
  * read
* clear 
 *  j = it - nv
  * skip j
   store pieza to pza
   store nromaes to nro
   store nropro to ap
   STORE precious TO pre
   store provee to pro,alt
   store indus to in
   STORE imagen TO ima
   store 0 to xa
if pro = 'RENAULT '
STORE 'RENAULT ' TO ALT
ACTIVATE WINDOW ALTER
SELECT alterna
BROW noedit
STORE PROVEE TO PRO
ENDIF
DEACTIVATE WINDOW ALTER
    select Artiped                                                         
    set order to nromaes2                                                  
    seek nro                                                         
       store 6 to ct                                                 
       if found()                                                    
       ?? chr(7) + chr(7)                                            
 DEACTIVATE WINDOW PEDIR   
    activate window control
     seek nro              
       store 3 to ct                                                 
       @  1,5 say 'ESTO LO TIENE PEDIDO !!!!!!!!'                    
       @  2,0 say 'Nro.    --PROVEEDOR -- CANT--'                    
       do while nro = nromaes                                        
          @ ct,0 say nropro pict 'XXXXXXXXXX'                        
          @ ct,12 say provee pict 'XXXXXXXX'                         
          @ ct,21 say cant pict '9999'                               
    if control = 'Y'                                                 
          @ ct,21 say fecha                                          
    endif                                                            
    xa = cant
          store ct + 1 to ct                                         
         skip
      enddo  

       SELECT Artiped                
    STORE ' ' TO RESP          
    @ ct+1,5 prompt 'PEDIR   '
    @ ct+2,5 prompt 'BORRAR  ' 
    @ ct+3,5 prompt 'VOLVER  ' 
     store 1 to voy            
     menu to voy               
     do case                   
     case voy = 1              
    STORE 'T' TO RESP
     case voy = 2              
     store 'B' to resp         
     case voy = 3              
SELECT giesse
STORE 'N' TO PIDO
LOOP
   otherwise                   
   endcase                     
    if resp = 'B'                                                           
       seek nro                                                             
  locate rest for nromaes = nro .and. provee = pro .and. nropro = ap .and. pieza = pza .and. control <> 'Y' .and.indus = in                                 
                                                       
                                                                       
                                                                      
SELECT giesse
STORE 'N' TO PIDO
LOOP
    endif                                                                   
                                                          
  DEACTIVATE WINDOW CONTROL
ENDIF
  ACTIVATE WINDOW PEDIR
*SELECT A  
  STORE XA TO CANTI
   @ 1,6 say 'NUMERO DEL PROVEEDOR--> '
   @ 1,30 say ap pict 'XXXXXXXXXXX'
   @ 1,41 say indus
   @ 3,4 say pza pict 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
   @ 4,2  say 'CANTIDAD    ' get canti pict '9999'
   @ 4,24 say 'PROVEEDOR  '
   @ 4,35 say pro pict 'XXXXXXXX'
   @ 5,1 say 'precious'  
   @ 5,15 say pre
   read
do while canti = 0
  ?? chr(7)
  ?? chr(7)
  ?? chr(7)
      @ 4,2  say 'CANTIDAD    ' get canti pict '9999'
  read
 enddo
   select pedidos
   set order to provee1
   seek pro
   if .not. found()
      set order to fecha2
      go bottom
      store nroped to np
      appe blank
repla provee with pro,fecha with date(),nroped with np+1
   endif
   if control = 'Y'
      locate rest for provee = pro .and. control <> 'Y'
      if .not. found()
         set order to fecha2
         go bottom
         store nroped to np
         appe blank
  repla provee with pro,fecha with date(),nroped with np+1
      endif
   endif
   store nroped to np
ACTIVATE WINDOW  CONTROL
      SELECT Artiped
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
      seek nro
  locate rest for nromaes = nro .and. provee = pro .and. nropro = ap .and. pieza = pza .and.control <> 'Y'
      if .not. found()
         appe blank
 repla provee with pro,nromaes with nro
 repla nropro with ap,indus with in,pieza with pza,nroped WITH np
 replace imagen WITH ima
 replace precious WITH pre
 replace fecha WITH DATE()
      endif
      replace cant with canti
   endif
   select giesse
   store 'N' to pido
enddo
deactivate window control
DEACTIVATE WINDOW alter
DEACTIVATE WINDOW pedir
clear
*return
*: EOF: PEDIPRO.PRG
