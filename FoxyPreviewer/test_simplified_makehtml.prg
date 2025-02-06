DO LOCFILE("FoxyPreviewer.APP")

* Make HTML
REPORT FORM ;
	(_Samples + "\Solution\Reports\Wrapping.frx") ;
	OBJECT TYPE 14 ; && OBJTYPE 10 = PDF , 11 = PDF AS IMAGE, 12 = RTF
	TO FILE "c:\TestReport.HTML" ; && Destination
	PREVIEW && Open the default RTF viewer	

	
*!*	* Make PDF
*!*	REPORT FORM ;
*!*		(_Samples + "\Solution\Reports\Wrapping.frx") ;
*!*		OBJECT TYPE 10 ; && OBJTYPE 10 = PDF , 11 = PDF AS IMAGE
*!*		TO FILE "c:\TestReport.Pdf" ; && Destination
*!*		PREVIEW && Open the default PDF viewer