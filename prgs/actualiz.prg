*:*********************************************************************
*PASORAS

*:*********************************************************************
*:*********************************************************************
*PASORAS
 *define window ACTUAL from 0,10 to 40,80 panel title 'ACTUALIZACION DE BALSAMO'
 *define window espera from 8,20 to 19,60 panel title 'TRABAJANDO'
close databases
set clock to
set confirm on
set exclusive on
select a
use archivo
select b
use maespr_1 index maesnro,nropro,maesabc,propro
select c
use cambios
store .t. to carga
do while .t. carga
store 0 to d1,d2,d3,dol,uti
store date() to fe
clear
*ACTIVATE WINDOW ACTUAL
*@  0,3 to 2,36 double
*@  9,20 to 15,72 double
*@  1,4 say ' CARGA DE LISTA BALSAMO S.A.'
*  4,10 prompt 'RASTROJERO'
*  5,10 prompt 'FGH bombas de agua'
*  6,10 prompt 'DELFABRO amortiguadores'
*  7,10 prompt 'LIGGETT resortes de suspensi�n'
*@  4,10 prompt 'RENAULT '
*store 1 to cu
*menu to cu
*do case
*case cu = 1
*   store 're' to cu
*endcase
*set talk on
*@ 10,22 say 'PULSE ENTER PARA COPIAR EL ARCHIVO'
*accept to r
*store time() to ini
*store seconds() to inis
*@ 11,22 say 'ESTOY COPIANDO AHORA MISMO' COLOR *
                         
*if cu = 're'
 copy file renolaa. to balsa1.txt             
* @ 12,22 say 'AHORA INTRODUZCA EL 2do DISKET Y PULSE ENTER'
 *accept to r                                               
* @ 13,22 say 'ESTOY COPIANDO EL 2do DISKET    '    
* copy file a:\renolab. to c:\listas\balsa2.txt             
   store '6' to tip
 *endif  
set talk off
*@ 14,22 say 'AHORA DIGITE DESCUENTOS - UTILIDAD - DOLAR REFERENCIAL'
*@ 16,20 say  'DESCUENTOS 1 - 2 - 3  ' get d1 pict '99.99'
*@ 16,53 get d2 pict '99.99'
*@ 16,60 get d3 pict '99.99'
*@ 18,20 say 'UTILIDAD      ------->' get uti pict '99.99'
*@ 20,21 say 'DOLAR REFERENCIAL --->' get dol pict '9,999.99'
@ 22,21 say 'FECHA DE LA LISTA --->' get fe
read
*  @ 22,4  to 24,14 double   
*  @ 22,15 to 24,25 double   
*  @ 23,5  prompt 'VUELVE   '
*  @ 23,16 prompt 'CONFIRMA '
*  store 2 to opcion         
*  menu to opcion            
*  do case                   
*   case opcion = 1          
*        clear               
* return                    
*   case opcion = 2

*dd1 = 100-d1
*dd1 = dd1/100
*dd2 = 100-d2
*dd2 = dd2/100
*dd3 = 100-d3
*dd3 = dd3/100
uti = uti/100+1
clear
*@ 22,0 to 24,79 double
*@ 23,1 say'VEA USTED COMO TRABAJO TENGAME PACIENCIA GRACIAS!!!!!' COLOR G+*
select a
zap
*ACTIVATE WINDOW ESPERA
SET TALK ON
append from balsa1.txt sdf
*if cu = 're'
*appe from balsa2.txt sdf
*endif
go top
store 0 to ct
erase balsa1.txt 
*if cu = 're'
*erase c:\listas\balsa2.txt
*endif
pv = 'BALSAMO'
in = '  '
do while .not. eof()
   select b
   set order to 4
   np = upper(substr(a->linea,1,15))
   pre=substr(a->linea,71,6)+substr(a->linea,78,2)
   preci= val(pre)/100 
   u= val(substr(a->linea,82,4))
   
    bu = alltrim(pv)+alltrim(np)+alltrim(in)
    
    seek bu
    
   if .not. found()
            append blank
 repla nropro with np,nromaes with upper(substr(a->linea,16,11)),pieza with upper(substr(a->linea,31,40)),provee with pv,tipo with tip
             if nromaes = '           '
               repla nromaes with np
            endif
         endif
     if preci<>prelis
     select c
     appe blank
     repla nropro with np,prelis with preci,fechacam with fe
          endif
     select b
     pe = preci &&* dd1 *dd2*dd3                      
repla precious with preci,fechaPRECI with fe

 if ue <> '*'
   repla ut with uti
   endif
      select a
      skip
    enddo
set talk off
*deactivate window espera
clear
select a
zap
*otherwise
*endcase
close databases
USE MAESPR_1
repla ALL coddes with '@' FOR PROVEE = PV AND FECHAPRECI<>FE 
*store time() to fin  
*store seconds() to fins
*tarda = fins - inis    
*@ 20,6 say 'Inici�'  
*@ 20,16 say 'Termin�'
*@ 20,26 say 'Tard�'
*@ 22,6 say ini       
*@ 22,16 say fin      
*store 0 to minu,res,sec
*tarda = int(tarda)
*if tarda>60
*minu = tarda/60
*res = minu - int(minu)
**sec = res*60
*endif
*if tarda<60
*sec = tarda
*endif
*@ 22,29 say minu pict '99'
*@ 22,31 say ':'
*@ 22,32 say sec pict'99'    
*@ 21,5 to 23,14 
*@ 21,15 to 23,24
*/@ 21,25 to 23,34
*wait ' ' timeout(8)
CLOSE all
*DEACTIVATE WINDOW ACTUAL
return TO main
*: EOF: PASORAS.PRG
enddo
