MESSAGEBOX("This is a deprecated and UNSUPPORTED sample." + CHR(13) + ;
	"Although it works, the 'PREVIEWHELPER' object is not supported any more!"+ CHR(13) + ;
	"Use this sample at your own risk!", 16, "IMPORTANT")



MESSAGEBOX("This sample uses the new adress book available for the Send email form." + CHR(13) + ;
	"To make it work, make sure to:" + CHR(13) + CHR(13) + ;
	"- Run your report, click the settings button" + CHR(13) + ;
	"- Select the Email tab" + CHR(13) + ;
	"- Select the CDO-HTML email type" + CHR(13) + ;
	"- Configure your SMTP settings properly.", 64, "Attention")

ON ERROR DO errHandler WITH ;
   ERROR( ), MESSAGE( ), MESSAGE(1), PROGRAM( ), LINENO( )

LOCAL lcType
lcType = "PRG"

* Adjusting paths to access the sources
LOCAL lcSrcPath
lcSrcPath = ADDBS(JUSTPATH(SYS(16))) + "Source\"
SET PATH TO (lcSrcPath) ADDITIVE 
SET PATH TO (ADDBS(JUSTPATH(SYS(16)))) ADDITIVE
SET PROCEDURE TO (lcSrcPath + "FoxyPreviewer." + lcType) ADDITIVE 

LOCAL loReport as "PreviewHelper" OF ("FoxyPreviewer." + lcType)
loReport = CREATEOBJECT("PreviewHelper")

WITH loReport as ReportHelper

SET POINT TO ","
SET DECIMALS TO 2
SET SEPARATOR TO "."


	*	.AddReport(_Samples + "\Solution\Reports\colors.frx")
	*	.AddReport(_Samples + "\Solution\Reports\wrapping.frx", "NODIALOG FOR title = [S]")
		.AddReport(_Samples + "\Solution\Reports\percent.frx")
	*	.AddReport("Sample.frx")


	* Creating the cursor with the adress book
	SELECT CAST(LOWER(GETWORDNUM(Contact, 1, " "))+"@vfp.com" AS C(30)) As email,* From (_samples + '\data\customer') ;
		Where .T. Into Cursor Test Readwrite

	.cAdressTable  = "Test"
	.cAdressSearch = "Contact"
	.RunReport()

	* Clear the Adress cursor
	USE IN SELECT("Test")
	USE IN SELECT("Customer")

	
	DO CASE
	
	CASE .lPrinted	
		MESSAGEBOX("Report was printed !",64, "Report status")

	CASE .lEmailed
		MESSAGEBOX("Report was sent to email, with the attached file: " + ;
			CHR(13) + .cDestFile,;
			64, "Report status")

	CASE .lSaved
		MESSAGEBOX("Report was saved as file:" + CHR(13) + .cDestFile,;
			64, ;
			"Report status")
		=OpenFile(.cDestFile)

	OTHERWISE
		MESSAGEBOX("Report Preview was closed without saving or printing",48, "Report status")

	ENDCASE

ENDWITH

RETURN

PROCEDURE OpenFile(tcFileName)
	DECLARE INTEGER ShellExecute ;
          IN SHELL32.DLL ;
          INTEGER nWinHandle,;
          STRING cOperation,;   
          STRING cFileName,;
          STRING cParameters,;
          STRING cDirectory,;
          INTEGER nShowWindow
	RETURN ShellExecute(0, "open", m.tcFileName, "", "", 1)
ENDPROC


PROCEDURE errHandler
   PARAMETER merror, mess, mess1, mprog, mlineno
   CLEAR
   ? 'Error number: ' + LTRIM(STR(merror))
   ? 'Error message: ' + mess
   ? 'Line of code with error: ' + mess1
   ? 'Line number of error: ' + LTRIM(STR(mlineno))
   ? 'Program with error: ' + mprog
ENDPROC