*PROCEDURE prepararTablaFotos_( )
PROCEDURE prepararTabla( )
OPEN DATABASE c:\infoball\DBINFOBALL.dbc
set exclusive on
USE c:\Listas_\per_sort.dbf shared 
          
cDirectorioFotos = "d:\winmaker2007\bmp\"
SCAN
	cCadenaAuxiliar = ""
	nContador = 1
	DO while nContador <= LEN(nromaes) 
		IF !((SUBSTR(nromaes,nContador,1) == "-")  OR (SUBSTR(nromaes,nContador,1) == " "))
		IF !((SUBSTR(nromaes,nContador,1) == "/")  OR (SUBSTR(nromaes,nContador,1) == " "))
			 cCadenaAuxiliar = cCadenaAuxiliar + SUBSTR(nromaes,nContador,1)
		endif
		endif
		nContador = nContador + 1
	ENDDO
	IF FILE ( cDirectorioFotos + cCadenaAuxiliar + ".bmp" )
		INSERT INTO tblFotos2(nombrefoto, directorio, nombrepiez, stock,nromaes,nropro,ubica,ubica_reta,tipologia,linea);
		 VALUES (cCadenaAuxiliar + ".bmp" , cDirectorioFotos, per_sort.pieza, ;
		 per_sort.stock,per_sort.nromaes, per_sort.nropro,per_sort.ubica,per_sort.ubica_reta,per_sort.tipologia,per_sort.linea)
	ELSE
		INSERT INTO tblFotos2(nombrefoto, directorio, nombrepiez, stock,nromaes,nropro,ubica,ubica_reta, tipologia,linea);
		VALUES ( "pagebackg.bmp" , cDirectorioFotos, per_sort.pieza, per_sort.stock,;
		 per_sort.nromaes,per_sort.nropro,per_sort.ubica,per_sort.ubica_reta,per_sort.tipologia,per_sort.linea)
	ENDIF 	
ENDSCAN
CLOSE DATABASES ALL
ENDPROC
* /////////////////////////////////////////////////////////////////////////////////////////////////////
PROCEDURE nuevoRep()
USE c:\infoball\tblFotos2.dbf EXCLUSIVE
DELETE ALL
PACK
prepararTabla( )
ENDPROC
