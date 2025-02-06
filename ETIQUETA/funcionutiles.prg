PROCEDURE prepararTablaFotos( )
OPEN DATABASE "c:\sistemayocca\proj\data\DBINFOBALL.dbc"
set exclusive on
USE c:\sistemayocca\proj\Etiqueta\Etiqueta.dbf SHARED
       
      
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
		INSERT INTO tblGiesrot(nombrefoto, directorio, nombrepiez, Articulo,nropro, stock,linea,ubica,ubicacaja,modelos);
		 VALUES (cCadenaAuxiliar + ".bmp" , cDirectorioFotos, etiqueta.pieza,etiqueta.nromaes,etiqueta.nropro,etiqueta.stock,etiqueta.linea,etiqueta.ubica,etiqueta.ubicacaja,etiqueta.modelos)
	ELSE
		INSERT INTO tblGiesrot(nombrefoto, directorio, nombrepiez, Articulo,nropro, stock,linea,ubica,ubicacaja,modelos);
		VALUES ("pagebackg.bmp" , cDirectorioFotos, etiqueta.pieza,etiqueta.nromaes,etiqueta.nropro,etiqueta.stock,etiqueta.linea,etiqueta.ubica,etiqueta.ubicacaja,etiqueta.modelos)
	ENDIF 	
ENDSCAN
CLOSE DATABASES ALL
ENDPROC
* /////////////////////////////////////////////////////////////////////////////////////////////////////
PROCEDURE nuevoReporte()
USE c:\sistemayocca\proj\data\tblGiesrot EXCLUSIVE
DELETE ALL
PACK
prepararTablaFotos( )
*SELECT PERFILES
ENDPROC
