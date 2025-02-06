DO LOCFILE("FoxyPreviewer.App")

* After initializing FoxyPreviewer, here are some optional properties that you can set:
* choosing what controls or tabs will be disabled in the settings form
* This brings you an option to control what functions each user will have available
WITH _Screen.oFoxyPreviewer.oSettingsDlg
	.lEnableTabPdf        = .F.
	.lEnableLanguage      = .F.
	.lEnableChkSaveasTxt  = .F.
	.lEnableChkSaveasHtml = .F.
ENDWITH 

*_Screen.oFoxyPreviewer.cImgPrint = GETPICT("bmp")

_Screen.oFoxyPreviewer.cLanguage  = "PORTUGUES"
_Screen.oFoxyPreviewer.cTitle     = "Meu titulo customizado"
* _Screen.oFoxyPreviewer.cFormicon  = "source\images\pr_mail03.ico"
_Screen.oFoxyPreviewer.nDockType  = 0
* _Screen.oFoxyPreviewer.lShowClose = .F.
_Screen.oFoxypreviewer.nShowToolbar = 1 && 1=Visible, 2=Invisible

REPORT FORM LOCFILE(_Samples + "\Solution\Reports\Wrapping.frx") PREVIEW NOWAIT && RANGE 2,4
* REPORT FORM LOCFILE("Sample.frx") PREVIEW

RETURN 



REPORT FORM LOCFILE(_Samples + "\Solution\Reports\Percent.frx")  PREVIEW
REPORT FORM LOCFILE(_Samples + "\Solution\Reports\Invoice.frx")  PREVIEW
REPORT FORM LOCFILE(_Samples + "\Solution\Reports\Colors.frx")   PREVIEW
REPORT FORM LOCFILE(_Samples + "\Solution\Reports\Wrapping.frx") PREVIEW


*!*	DO LOCFILE("FoxyPreviewer.Prg")
*!*	*REPORT FORM (ADDBS(HOME(1)) + "Samples\Solution\Reports\colors.frx") PREVIEW
*!*	REPORT FORM LOCFILE("Sample.frx") FOR RECNO() < 10 PREVIEW

*!*	RETURN