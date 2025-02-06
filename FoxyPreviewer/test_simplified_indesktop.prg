DO LOCFILE("FoxyPreviewer.App")

LOCAL oRep AS Form
oRep = CREATEOBJECT("FormReport")

WITH oRep 
	.Caption= "Titulo del Reporte" 
	.Height      = SysMetric(2)
	.Width       = SysMetric(1)
ENDWITH 

*!* REPORT FORM LOCFILE(_Samples + "\Solution\Reports\Percent.frx")  PREVIEW WINDOW (oRep.Name)
*!* REPORT FORM LOCFILE(_Samples + "\Solution\Reports\Invoice.frx")  PREVIEW WINDOW (oRep.Name)
*!* REPORT FORM LOCFILE(_Samples + "\Solution\Reports\Colors.frx")   PREVIEW WINDOW (oRep.Name)
REPORT FORM LOCFILE(_Samples + "\Solution\Reports\Wrapping.frx") PREVIEW WINDOW (oRep.Name)

DEFINE CLASS FormReport AS Form
	AlwaysOnTop = .T.
    WindowState = 2
	Desktop     = .T.
ENDDEFINE