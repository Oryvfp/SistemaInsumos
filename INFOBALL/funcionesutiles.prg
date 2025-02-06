PROCEDURE prepararTablaFotos( )
OPEN DATABASE "c:\sistemayocca\proj\data\DBINFOBALL.dbc"
set exclusive on
USE c:\sistemayocca\proj\Etiqueta\etiqueta.dbf SHARED
       
      
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
		INSERT INTO Tblgiesserot(nombrefoto, directorio, nombrepiez, nromaes,nropro, stock,stockmin,tipologia,modelos,linea,ubica,ubicacaja);
		 VALUES (cCadenaAuxiliar + ".bmp" , cDirectorioFotos, etiqueta.pieza,etiqueta.nromaes,etiqueta.nropro,etiqueta.stock,etiqueta.stockmin,etiqueta.tipologia,etiqueta.modelos,etiqueta.linea,etiqueta.ubica,etiqueta.ubicacaja)
	ELSE
		INSERT INTO Tblgiesserot(nombrefoto, directorio, nombrepiez, nromaes,nropro, stock,stockmin,tipologia,modelos,linea,ubica,ubicacaja) ;
		VALUES ("pagebackg.bmp" , cDirectorioFotos, etiqueta.pieza,etiqueta.nromaes,etiqueta.nropro,etiqueta.stock,etiqueta.stockmin,etiqueta.tipologia,etiqueta.modelos,etiqueta.linea,etiqueta.ubica,etiqueta.ubicacaja)
		
	ENDIF 	
ENDSCAN
CLOSE DATABASES ALL
ENDPROC
* /////////////////////////////////////////////////////////////////////////////////////////////////////
PROCEDURE nuevoReporte()
USE c:\sistemayocca\proj\data\tblgiesserot.dbf EXCLUSIVE 
DELETE ALL
PACK
prepararTablaFotos( )
*SELECT PERFILES
ENDPROC
