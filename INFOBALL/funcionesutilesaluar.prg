PROCEDURE prepararTablaFotos3( )
OPEN DATABASE c:\infoball\DBINFOBALL.dbc
set exclusive on
USE c:\sistemaperfiles\filtro.dbf SHARED
       
      
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
		INSERT INTO tblFotos3(nombrefoto, directorio, nombrepiez, nromaes, stock,linea,tipologia,ubica_reta,ubica,nro_aluar,peso);
		 VALUES (cCadenaAuxiliar + ".bmp" , cDirectorioFotos, filtro.pieza,filtro.nromaes, ;
		 filtro.stock,filtro.linea,filtro.tipologia,filtro.ubica_reta,filtro.ubica,filtro.nro_aluar,filtro.peso)
	ELSE
		INSERT INTO tblFotos3(nombrefoto, directorio, nombrepiez, nromaes, stock,linea,tipologia,ubica_reta,ubica,nro_aluar,peso) ;
		VALUES ("pagebackg.bmp" , cDirectorioFotos, filtro.pieza,filtro.nromaes, ;
		 filtro.stock,filtro.linea,filtro.tipologia,filtro.ubica_reta,filtro.ubica,filtro.nro_aluar,filtro.peso)
	ENDIF 	
ENDSCAN
CLOSE DATABASES ALL
ENDPROC
* /////////////////////////////////////////////////////////////////////////////////////////////////////
PROCEDURE nuevoReporte()
USE c:\infoball\tblFotos3.dbf EXCLUSIVE
DELETE ALL
PACK
prepararTablaFotos3( )
*SELECT 
ENDPROC
