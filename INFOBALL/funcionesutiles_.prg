PROCEDURE prepararTablaFotos( )
OPEN DATABASE c:\infoball\DBINFOBALL.dbc
set exclusive on
USE c:\ETIQUETA\ETIQUETA.dbf SHARED
       
      
cDirectorioFotos = "d:\winmaker2007\bmp\"
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
	IF FILE ( cDirectorioFotos + cCadenaAuxiliar + ".bmp" )
		INSERT INTO tblFotos(nombrefoto, directorio, nombrepieza, stock, nromaes,nropro);
		 VALUES (cCadenaAuxiliar + ".bmp" , cDirectorioFotos, ETIQUETA.pieza, ETIQUETA.nro_aluar,Etiqueta.tipologia,etiqueta.linea,etiqueta.ubica_reta,etiqueta.ubica, ;
		 ETIQUETA.stock, ETIQUETA.articulo, ETIQUETA.nropro)
	ELSE
		INSERT INTO tblFotos(nombrefoto, directorio, nombrepieza, stock, nromaes,nropro);
		VALUES ( "pagebackg.gif" , cDirectorioFotos, ETIQUETA.pieza, ETIQUETA.stock,ETIQUETA.nro_aluar,Etiqueta.tipologia,etiqueta.linea,etiqueta.ubica_reta,etiqueta.ubica, ;
		ETIQUETA.articulo, ETIQUETA.nropro)
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
