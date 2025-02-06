DO LOCFILE("FoxyPreviewer.Prg")

* Make PRF
* REPORT FORM ;
	(_Samples + "\Solution\Reports\Colors.frx") ;
	OBJECT TYPE 20 ; && OBJTYPE 10 = PDF , 11 = PDF AS IMAGE, 12 = RTF, 13 = XLS
	TO FILE "c:\TestReport.pdf" ; && Destination
	PREVIEW && Open the default XLS viewer	
	

* REPORT FORM ;
	LOCFILE("Sample_TF.frx") ;
	OBJECT TYPE 20 ; && OBJTYPE 10 = PDF , 11 = PDF AS IMAGE, 12 = RTF, 13 = XLS
	TO FILE "c:\TestReportTF.pdf" ; && Destination
	PREVIEW && Open the default XLS viewer	


* REPORT FORM ;
	LOCFILE("Sample_TF.frx") ;
	OBJECT TYPE 20 ; && OBJTYPE 10 = PDF , 11 = PDF AS IMAGE, 12 = RTF, 13 = XLS
	TO FILE "c:\TestReportTF.HTM" ; && Destination
	PREVIEW && Open the default XLS viewer	


*REPORT FORM ;
	LOCFILE("Sample_TF.frx") ;
	OBJECT TYPE 20 ; && OBJTYPE 10 = PDF , 11 = PDF AS IMAGE, 12 = RTF, 13 = XLS
	TO FILE "c:\TestReportTF_114.HTM" ; && Destination
	PREVIEW && Open the default XLS viewer	



*REPORT FORM ;
	LOCFILE("Sample_TF.frx") ;
	OBJECT TYPE 20 ; && OBJTYPE 10 = PDF , 11 = PDF AS IMAGE, 12 = RTF, 13 = XLS
	TO FILE "c:\TestReportTF_114.JPG" ; && Destination
	PREVIEW && Open the default XLS viewer	



*REPORT FORM ;
	LOCFILE("Sample_TF.frx") ;
	OBJECT TYPE 20 ; && OBJTYPE 10 = PDF , 11 = PDF AS IMAGE, 12 = RTF, 13 = XLS
	TO FILE "c:\TestReportTF_114.EMF" ; && Destination
	PREVIEW && Open the default XLS viewer	


REPORT FORM ;
	(_Samples + "\Solution\Reports\Colors.frx") ;
	OBJECT TYPE 20 ; && OBJTYPE 10 = PDF , 11 = PDF AS IMAGE, 12 = RTF, 13 = XLS
	TO FILE "c:\TestReportTF_114.xls" ; && Destination
	PREVIEW && Open the default XLS viewer	



*!*	* Make PDF
*!*	REPORT FORM ;
*!*		(_Samples + "\Solution\Reports\Wrapping.frx") ;
*!*		OBJECT TYPE 10 ; && OBJTYPE 10 = PDF , 11 = PDF AS IMAGE
*!*		TO FILE "c:\TestReport.Pdf" ; && Destination
*!*		PREVIEW && Open the default PDF viewer

*!*	* Make RTF
*!*	REPORT FORM ;
*!*		(_Samples + "\Solution\Reports\Wrapping.frx") ;
*!*		OBJECT TYPE 12 ; && OBJTYPE 10 = PDF , 11 = PDF AS IMAGE, 12 = RTF
*!*		TO FILE "c:\TestReport.Rtf" ; && Destination
*!*		PREVIEW && Open the default RTF viewer	
