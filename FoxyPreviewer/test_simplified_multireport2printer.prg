IF VARTYPE(_Screen.oFoxyPreviewer) <> "O"
	DO LOCFILE("FoxyPreviewer.App")
ENDIF

* To merge reports, the trick is to use the clauses
* NOPAGEEJECT NORESET

REPORT FORM LOCFILE(_Samples + "\Solution\Reports\Colors.frx") ;
	NOPAGEEJECT NORESET TO PRINTER 

REPORT FORM LOCFILE(_Samples + "\Solution\Reports\Wrapping.frx") ;
	NOPAGEEJECT TO PRINTER 

REPORT FORM LOCFILE(_Samples + "\Solution\Reports\Percent.frx") ;
	TO PRINTER  
