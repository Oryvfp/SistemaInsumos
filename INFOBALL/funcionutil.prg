PROCEDURE prepararTablaFoto( )
OPEN DATABASE "c:\sistemayocca\proj\data\DBINFOBALL.dbc"
set exclusive on
USE c:\sistemayocca\proj\Etiqueta\filtro.dbf SHARED
       
      
cDirectorioFotos = "C:\sistemayocca\proj\imagenes\"
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
		INSERT INTO tblgiesselst(nombrefoto, directorio, nombrepiez, nromaes,nropro, stock,stockmin,tipologia,modelos,linea,ubica,ubicacaja);
		 VALUES (cCadenaAuxiliar + ".bmp" , cDirectorioFotos, filtro.pieza,filtro.nromaes,filtro.nropro,filtro.stock,filtro.stockmin,filtro.tipologia,filtro.modelos,filtro.linea,filtro.ubica,filtro.ubicacaja)
	ELSE
		INSERT INTO tblgiesselst(nombrefoto, directorio, nombrepiez, nromaes,nropro, stock,stockmin,tipologia,modelos,linea,ubica,ubicacaja) ;
		VALUES ("pagebackg.bmp" , cDirectorioFotos, filtro.pieza,filtro.nromaes,filtro.nropro,filtro.stock,filtro.stockmin,filtro.tipologia,filtro.modelos,filtro.linea,filtro.ubica,filtro.ubicacaja)
		
	ENDIF 	
ENDSCAN
CLOSE DATABASES ALL
ENDPROC
* /////////////////////////////////////////////////////////////////////////////////////////////////////
PROCEDURE nuevoReport()
USE c:\sistemayocca\proj\data\tblgiesselst.dbf EXCLUSIVE IN 0
DELETE ALL
PACK
prepararTablaFoto( )
*SELECT PERFILES
ENDPROC
