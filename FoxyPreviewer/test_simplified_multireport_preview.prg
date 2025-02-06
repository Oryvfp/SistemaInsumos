IF VARTYPE(_Screen.oFoxyPreviewer) <> "O"
	DO LOCFILE("FoxyPreviewer.App")
ENDIF 

* To merge reports, the trick is to use the clauses
* NOPAGEEJECT NORESET
SET REPORTBEHAVIOR 90

REPORT FORM LOCFILE(_Samples + "\Solution\Reports\Colors.frx") ;
	PREVIEW NORESET NOPAGEEJECT

REPORT FORM LOCFILE(_Samples + "\Solution\Reports\Wrapping.frx") ;
	PREVIEW
	