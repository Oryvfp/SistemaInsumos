DO LOCFILE("FoxyPreviewer.App") && WITH "c:\YourAppFolderHere\"

* Adding watermarks to reports
_Screen.oFoxyPreviewer.cWatermarkImage = ADDBS(HOME()) + "Graphics\Gifs\Morphfox.gif"
_Screen.oFoxyPreviewer.nWaterMarkType = 1 && 1 = Colored (default), 2 = B&W

_Screen.oFoxyPreviewer.nWatermarktransparency = .30 && (0-1) Transparency, 0 = Transparent, 1 = Opaque
_Screen.oFoxyPreviewer.nWaterMarkWidthRatio   = .75 && (0-1) Proportion that the watermark will occupy in the page width
_Screen.oFoxyPreviewer.nWaterMarkHeightRatio  = .75 && (0-1) Proportion that the watermark will occupy in the page height

REPORT FORM LOCFILE(_Samples + "\Solution\Reports\Colors.frx") OBJECT TYPE 10 NOPAGEEJECT NORESET TO FILE "c:\Test1.pdf" PREVIEW 
REPORT FORM LOCFILE(_Samples + "\Solution\Reports\Percent.frx") OBJECT TYPE 10 PREVIEW

RETURN 



REPORT FORM LOCFILE(_Samples + "\Solution\Reports\Percent.frx")  PREVIEW
REPORT FORM LOCFILE(_Samples + "\Solution\Reports\Invoice.frx")  PREVIEW
REPORT FORM LOCFILE(_Samples + "\Solution\Reports\Colors.frx")   PREVIEW
REPORT FORM LOCFILE(_Samples + "\Solution\Reports\Wrapping.frx") PREVIEW