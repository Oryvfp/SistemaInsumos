DO LOCFILE("FoxyPreviewer.App")

* To merge reports, the trick is to use the clauses
* NOPAGEEJECT NORESET

REPORT FORM LOCFILE(_Samples + "\Solution\Reports\Colors.frx") ;
	OBJECT TYPE 10 PREVIEW NOPAGEEJECT NORESET

REPORT FORM LOCFILE(_Samples + "\Solution\Reports\Wrapping.frx") ;
	OBJECT TYPE 10  TO FILE "c:\Temp\1.pdf" PREVIEW
	