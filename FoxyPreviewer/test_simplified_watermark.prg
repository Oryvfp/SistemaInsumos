IF VARTYPE(_Screen.oFoxyPreviewer) <> "O"
	DO LOCFILE("FoxyPreviewer.Prg") && WITH "c:\YourAppFolderHere\"
ENDIF

* Adding watermarks to reports
_Screen.oFoxyPreviewer.cWatermarkImage = ADDBS(HOME()) + "Graphics\Gifs\Morphfox.gif"
_Screen.oFoxyPreviewer.nWaterMarkType = 2 && 1 = Colored (default), 2 = B&W

_Screen.oFoxyPreviewer.nWatermarktransparency = .90 && (0-1) Transparency, 0 = Transparent, 1 = Opaque
_Screen.oFoxyPreviewer.nWaterMarkWidthRatio   = .30 && (0-1) Proportion that the watermark will occupy in the page width
_Screen.oFoxyPreviewer.nWaterMarkHeightRatio  = .75 && (0-1) Proportion that the watermark will occupy in the page height

REPORT FORM LOCFILE(_Samples + "\Solution\Reports\Colors.frx") PREVIEW && RANGE 2,4
REPORT FORM LOCFILE(_Samples + "\Solution\Reports\Percent.frx")  PREVIEW
REPORT FORM LOCFILE(_Samples + "\Solution\Reports\Invoice.frx")  PREVIEW

RETURN 



REPORT FORM LOCFILE(_Samples + "\Solution\Reports\Percent.frx")  PREVIEW
REPORT FORM LOCFILE(_Samples + "\Solution\Reports\Invoice.frx")  PREVIEW
REPORT FORM LOCFILE(_Samples + "\Solution\Reports\Colors.frx")   PREVIEW
REPORT FORM LOCFILE(_Samples + "\Solution\Reports\Wrapping.frx") PREVIEW