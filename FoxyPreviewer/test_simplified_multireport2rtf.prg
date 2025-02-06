DO LOCFILE("FoxyPreviewer.prg")

* To merge reports, the trick is to use the clauses
* NOPAGEEJECT NORESET

REPORT FORM LOCFILE(_Samples + "\Solution\Reports\Colors.frx") ;
	OBJECT TYPE 12 NOPAGEEJECT NORESET TO FILE "c:\Test10.rtf"

REPORT FORM LOCFILE(_Samples + "\Solution\Reports\Wrapping.frx") ;
	OBJECT TYPE 12 NOPAGEEJECT

REPORT FORM LOCFILE(_Samples + "\Solution\Reports\Percent.frx") ;
	OBJECT TYPE 12 PREVIEW 
	