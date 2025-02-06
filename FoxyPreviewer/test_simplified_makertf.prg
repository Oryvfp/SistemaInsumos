DO LOCFILE("FoxyPreviewer.App")

* Make RTF
REPORT FORM ;
	(_Samples + "\Solution\Reports\Wrapping.frx") ;
	OBJECT TYPE 12 ; && OBJTYPE 10 = PDF , 11 = PDF AS IMAGE, 12 = RTF
	TO FILE "c:\TestReport.Rtf" ; && Destination
	PREVIEW && Open the default RTF viewer	

	
*!*	* Make PDF
*!*	REPORT FORM ;
*!*		(_Samples + "\Solution\Reports\Wrapping.frx") ;
*!*		OBJECT TYPE 10 ; && OBJTYPE 10 = PDF , 11 = PDF AS IMAGE
*!*		TO FILE "c:\TestReport.Pdf" ; && Destination
*!*		PREVIEW && Open the default PDF viewer