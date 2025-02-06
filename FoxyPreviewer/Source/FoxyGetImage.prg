* PROCEDURE FoxyGetImage  && Retrieve only image files
	LPARAMETERS tcImageFile
	LOCAL lcPicVal
	lcPicVal = ""
	IF INLIST(UPPER(JUSTEXT(tcImageFile)), "BMP", "GIF", "PNG", "JPG", "JPEG", "TIFF", "TIF", "EMF")
		TRY 
			lcPicVal = FILETOSTR(tcImageFile)
		CATCH 
		ENDTRY
	ENDIF 
	RETURN lcPicVal
