DO LOCFILE("FoxyPreviewer.Prg")

* Make PDF
REPORT FORM ;
	(_Samples + "\Solution\Reports\Invoice.frx") ;
	OBJECT TYPE 11 ; && OBJTYPE 10 = PDF , 11 = PDF AS IMAGE
	TO FILE "c:\TestReport2.Pdf" ; && Destination
	PREVIEW && Open the default PDF viewer
	
*!*	* Make RTF
*!*	REPORT FORM ;
*!*		(_Samples + "\Solution\Reports\Wrapping.frx") ;
*!*		OBJECT TYPE 12 ; && OBJTYPE 10 = PDF , 11 = PDF AS IMAGE, 12 = RTF
*!*		TO FILE "c:\TestReport.Rtf" ; && Destination
*!*		PREVIEW && Open the default RTF viewer	