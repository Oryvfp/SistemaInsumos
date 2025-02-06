DO LOCFILE("FoxyPreviewer.App")

* Make PDF
REPORT FORM ;
	(_Samples + "\Solution\Reports\Wrapping.frx") ;
	OBJECT TYPE 10 ; && OBJTYPE 10 = PDF , 11 = PDF AS IMAGE
	TO FILE "c:\Temp\TestReport.Pdf" ; && Destination
	PREVIEW && Open the default PDF viewer

RETURN