PROCEDURE prepararTablaFotos( )
OPEN DATABASE c:\infoball\DBINFOBALL.dbc
set exclusive on
USE c:\sistemayocca\proj\filtro.dbf SHARED
       
      
cDirectorioFotos = "c:\sistemayocca\proj\Imagenes\"
SCAN
	cCadenaAuxiliar = ""
	nContador = 1
	DO while nContador <= LEN(nropro) 
		IF !((SUBSTR(nropro,nContador,1) == "-")  OR (SUBSTR(nropro,nContador,1) == " "))
		IF !((SUBSTR(nropro,nContador,1) == "/")  OR (SUBSTR(nropro,nContador,1) == " "))
			 cCadenaAuxiliar = cCadenaAuxiliar + SUBSTR(nropro,nContador,1)
		endif
		endif
		nContador = nContador + 1
	ENDDO
	IF FILE ( cDirectorioFotos + cCadenaAuxiliar + ".jpg" )
		INSERT INTO tblFotos4(nombrefoto, directorio, nombrepiez, nromaes,nropro,stock,linea,ubica,modelos);
		 VALUES (cCadenaAuxiliar + ".jpg" , cDirectorioFotos, filtro.pieza,filtro.nromaes,filtro.nropro, ;
		 filtro.stock,filtro.linea,filtro.ubica,filtro.modelos)
	ELSE
		INSERT INTO tblFotos4(nombrefoto, directorio, nombrepiez, nromaes,nropro,stock,linea,ubica,modelos) ;
		VALUES ("pagebackg.jpg" , cDirectorioFotos, filtro.pieza,filtro.nromaes,filtro.nropro, ;
		filtro.stock,filtro.linea,filtro.ubica,filtro.modelos)
	ENDIF 	
ENDSCAN
CLOSE DATABASES ALL
ENDPROC
* /////////////////////////////////////////////////////////////////////////////////////////////////////
PROCEDURE nuevoReporte()
USE c:\infoball\tblFotos4.dbf EXCLUSIVE
DELETE ALL
PACK
prepararTablaFotos( )
ENDPROC
