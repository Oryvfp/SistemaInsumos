PROCEDURE prepararTablaFotos( )
OPEN DATABASE c:\infoball\DBINFOBALL.dbc
set exclusive on
USE c:\listas_\per_sort.dbf SHARED
       
      
cDirectorioFotos = "d:\winmaker2007\bmp\"
SCAN
	cCadenaAuxiliar = ""
	nContador = 1
	DO while nContador <= LEN(nromaes) 
		IF !((SUBSTR(nromaes,nContador,1) == "-")  OR (SUBSTR(nromaes,nContador,1) == " "))
		IF !((SUBSTR(nromaes,nContador,1) == "/")  OR (SUBSTR(nromaes,nContador,1) == " "))
		IF !((SUBSTR(nromaes,nContador,1) == " ")  OR (SUBSTR(nromaes,nContador,1) == " "))
			 cCadenaAuxiliar = cCadenaAuxiliar + SUBSTR(nromaes,nContador,1)
		endif
	endif
	endif
		nContador = nContador + 1
	ENDDO
	IF FILE ( cDirectorioFotos + cCadenaAuxiliar + ".bmp" )
		INSERT INTO tblFotos(nombrefoto, directorio, nombrepieza, nropro,nromaes,stock,linea,tipologia,ubica_reta,ubica,nro_aluar);
		 VALUES (cCadenaAuxiliar + ".bmp" , cDirectorioFotos, per_sort.pieza,per_sort.nropro,per_sort.nromaes, ;
		 per_sort.stock,per_sort.linea,per_sort.tipologia,per_sort.ubica_reta,per_sort.ubica,per_sort.nro_aluar)
	ELSE
		INSERT INTO tblFotos(nombrefoto, directorio, nombrepieza,nropro,nromaes,stock,linea,tipologia,ubica_reta,ubica,nro_aluar) ;
		VALUES ("pagebackg.bmp" , cDirectorioFotos, per_sort.pieza,per_sort.nropro,per_sort.nromaes,per_sort.stock,per_sort.linea,per_sort.tipologia,per_sort.ubica_reta,per_sort.ubica,per_sort.nro_aluar)
		
	ENDIF 	
ENDSCAN
CLOSE DATABASES ALL
ENDPROC
* /////////////////////////////////////////////////////////////////////////////////////////////////////
PROCEDURE nuevoReporte()
USE c:\infoball\tblFotos.dbf EXCLUSIVE
DELETE ALL
PACK
prepararTablaFotos( )
ENDPROC
