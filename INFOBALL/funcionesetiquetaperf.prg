PROCEDURE prepararTablaFotos6( )
OPEN DATABASE c:\infoball\DBINFOBALL.dbc
set exclusive on
USE c:\etiqueta\rotperf.dbf shared
      
cDirectorioFotos = "d:\winmaker2007\bmp\"
SCAN
	cCadenaAuxiliar = ""
	nContador = 1
	DO while nContador <= LEN(articulo) 
		IF !((SUBSTR(articulo,nContador,1) == "-")  OR (SUBSTR(articulo,nContador,1) == " "))
		IF !((SUBSTR(articulo,nContador,1) == "/")  OR (SUBSTR(articulo,nContador,1) == " "))
			 cCadenaAuxiliar = cCadenaAuxiliar + SUBSTR(articulo,nContador,1)
		endif
		endif
		nContador = nContador + 1
	ENDDO
	IF FILE ( cDirectorioFotos + cCadenaAuxiliar + ".bmp" )
		INSERT INTO tblFotos6(nombrefoto, directorio, nombrepiez, articulo, stock,linea,tipologia,ubica_reta,ubica,cantperf,fecha,modelos,tipologia);
		 VALUES (cCadenaAuxiliar + ".bmp" , cDirectorioFotos, rotperf.pieza,rotperf.articulo,;
		 rotperf.stock,rotperf.linea,rotperf.tipologia,rotperf.ubica_reta,rotperf.ubica,rotperf.cantperf,rotperf.fecha,rotperf.modelos,rotperf.tipologia)
	ELSE
		INSERT INTO tblFotos6(nombrefoto, directorio, nombrepiez, articulo, stock,linea,tipologia,ubica_reta,ubica,cantperf,fecha,modelos,tipologia) ;
		VALUES ("pagebackg.bmp" , cDirectorioFotos, rotperf.pieza,rotperf.articulo, ;
		 rotperf.stock,rotperf.linea,rotperf.tipologia,rotperf.ubica_reta,rotperf.ubica,rotperf.cantperf,rotperf.fecha,rotperf.modelos,rotperf.tipologia)
	ENDIF 	
ENDSCAN
CLOSE DATABASES ALL
ENDPROC
* /////////////////////////////////////////////////////////////////////////////////////////////////////
PROCEDURE nuevoReporte()
USE c:\infoball\tblFotos6.dbf EXCLUSIVE
DELETE ALL
PACK
prepararTablaFotos6( )
ENDPROC
