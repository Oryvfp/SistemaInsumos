ON ERROR DO errHandler WITH ;
   ERROR( ), MESSAGE( ), MESSAGE(1), PROGRAM( ), LINENO( )

LOCAL lcPath
lcPath = ADDBS(JUSTPATH(SYS(16)))
SET PATH TO (lcPath) ADDITIVE
SET PATH TO "..\..\Source" additive 

IF NOT FILE("FoxyPreviewer.App")
	MESSAGEBOX("Please locate the file 'FoxyPreviewer.App' to run these samples", 32, "FoxyPreviewer test")
ENDIF

LOCAL llError
llError = .F.
TRY 
	SET PROCEDURE TO LOCFILE("FoxyPreviewer.App")
CATCH
	MESSAGEBOX("Could not locate FoxyPreviewer.App" + CHR(13) + ;
		"This sample cannot run without this file." + CHR(13) + ;
		"The application will be closed", 16, "FoxyPreviewer Test")
	llError = .T.
ENDTRY 
IF llError
	RETURN
ENDIF


SET SYSMENU OFF 
SET TALK OFF
SET CONSOLE OFF 
ON SHUTDOWN QUIT

DO LOCFILE("FoxyPreviewer.App")

_Screen.WindowState = 2 && Maximized
_Screen.BackColor = RGB(0,64,128)
_Screen.Caption = "FOXYPREVIEWER IN AN EXE"

_Screen.AddObject("oLabel", "Label")
WITH _Screen.oLabel as Label
	.AutoSize = .T. 
	.BackStyle = 0 && Transparent
	.Caption = "FoxyPreviewer testing in an EXE"
	.FontBold = .T. 
	.FontSize = 24
	.ForeColor = RGB(255,255,255)
	.Top = 50
	.Left = 100
	.Visible = .T. 
ENDWITH 

_Screen.AddObject("oCmdScreen"   , "cmdInscreen")
_Screen.AddObject("oCmdTopLevel" , "cmdTopLevel")
_Screen.AddObject("oCmdInWindow" , "cmdInWindow")
_Screen.AddObject("oCmdOrdinary" , "cmdOrdinary")
_Screen.AddObject("oCmdOrdinary2", "cmdOrdinary2")
_Screen.AddObject("oCmdNoScreen" , "cmdNoScreen")
_Screen.AddObject("oCmdTestFJ"   , "cmdTestFJ")

READ EVENTS
CLEAR EVENTS 
ON ERROR  && Restores system error handler.

IF _VFP.Startmode = 4 && EXE or APP
	CLEAR ALL
	ON SHUTDOWN
	QUIT
ENDIF

RETURN 





PROCEDURE errHandler
	PARAMETER merror, mess, mess1, mprog, mlineno

	LOCAL lcMsg 
	lcMsg = 'Error number: ' + LTRIM(STR(merror)) + CHR(13) + ;
		'Error message: ' + mess + CHR(13) + ;
		'Line of code with error: ' + mess1 + CHR(13) + ;
		'Line number of error: ' + LTRIM(STR(mlineno)) + CHR(13) + ;
		'Program with error: ' + mprog
	MESSAGEBOX(lcMsg, 16, "FoxyPreviewer testing App error")
ENDPROC






DEFINE CLASS cmdInScreen AS MyButton
	Caption = "In _Screen Form"
	Top  = 200

	PROCEDURE Click
		DO FORM TestForm
	ENDPROC
ENDDEFINE

DEFINE CLASS cmdTopLevel AS MyButton
	Top  = 260
	Caption = "Top-Level Form"

	PROCEDURE Click
		DO FORM TestFormTopLevel
	ENDPROC
ENDDEFINE

DEFINE CLASS cmdInWindow AS MyButton
	Top  = 320
	Caption = "Custom window"

	PROCEDURE Click
		DO FORM TestFormInWindow
	ENDPROC
ENDDEFINE

DEFINE CLASS cmdOrdinary AS MyButton
	Top  = 380
	Caption = "Ordinary report"
	ToolTipText = "Run a predetermined report using the _REPORTPREVIEW factory"

	PROCEDURE Click

		* Run a report in the original way
		* From now on, all the reports from your APP will use this factory
		REPORT FORM (ADDBS(HOME(1)) + "Samples\Solution\Reports\colors.frx") PREVIEW

	ENDPROC
ENDDEFINE

DEFINE CLASS cmdOrdinary2 AS MyButton

	Top  = 440
	Caption = "Your report"
	ToolTipText = "Run a the report that you choose using the _REPORTPREVIEW factory"

	PROCEDURE Click

*!*			DO maintest.prg
*!*			RETURN 

		MESSAGEBOX("Choose any report to see how it will run under the FoxyPreviewer interface." + CHR(13) + ;
			"Using the original REPORT FORM command", 64, "FoxyPreviewer")

		TRY 
			SET DEFAULT TO (ADDBS(HOME(1)) + "Samples\Solution\Reports\")
		CATCH
		ENDTRY
		
		LOCAL lcFRX
		lcFRX = GETFILE("FRX")
		* Run a report in the original way
		* From now on, all the reports from your APP will use this factory
		REPORT FORM (lcFRX) PREVIEW

*		REPORT FORM ("Sample.Frx") OBJECT TYPE 10 TO FILE "c:\TestPDF2.PDF" PREVIEW
		
		REPORT FORM (lcFRX) OBJECT TYPE 10 TO FILE "c:\TestPDF.PDF" PREVIEW
		REPORT FORM (lcFRX) OBJECT TYPE 12 TO FILE "c:\TestRTF.RTF" PREVIEW
		REPORT FORM (lcFRX) OBJECT TYPE 13 TO FILE "c:\TestXLS.XLS" PREVIEW
		REPORT FORM (lcFRX) OBJECT TYPE 14 TO FILE "c:\TestHTM.HTM" PREVIEW
		REPORT FORM (lcFRX) OBJECT TYPE 15 TO FILE "c:\TestHTM.HTM" PREVIEW
	
	ENDPROC
ENDDEFINE


DEFINE CLASS cmdNoScreen AS MyButton
	Top  = 500
	Caption = "Top-Level with hidden _Screen"

	PROCEDURE Click
		_Screen.Visible = .F.
		DO FORM TestFormTopLevelNoScreen
	ENDPROC
ENDDEFINE


DEFINE CLASS cmdTestFJ AS MyButton

	Top  = 560
	Caption = "TEST <FJ>"

	PROCEDURE Click
		DO maintest.prg
		RETURN 
	ENDPROC
ENDDEFINE



DEFINE CLASS myButton as CommandButton
	Left = 100
	FontSize = 16
	Width = 300
	Height = 40
	Visible = .T.
ENDDEFINE


PROCEDURE FoxyGetImage  && Retrieve only image files
	LPARAMETERS tcImageFile
	LOCAL lcPicVal
	lcPicVal = ""
	IF INLIST(UPPER(JUSTEXT(tcImageFile)), "BMP", "GIF", "PNG", "JPG", "JPEG", "TIFF", "TIF", "EMF")
		TRY 
			lcPicVal = FILETOSTR(tcImageFile)
		CATCH 
		ENDTRY
	ENDIF 
	RETURN lcPicVal
ENDPROC 
