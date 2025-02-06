* FoxyPreviewer Version info
#DEFINE  FOXYPREVIEWER_VERSION    2.99
#DEFINE  FOXYPREVIEWER_VERSION2   "v2.99z36 RC 2017.03.30"
#DEFINE  MAIN_LISTENER            "FOXYLISTENER"
#DEFINE  CRYPT_KEY                "?GotData?9FoxIt!!!"
#DEFINE  ISDEBUGGING              .F.
#DEFINE  _CRLF                    CHR(13) + CHR(10)

#IF .F.
	PROCEDURE FOXYGETIMAGE
	ENDPROC 
#ENDIF

#INCLUDE FoxyPreviewer.h

LPARAMETERS loPreviewContainer

SET TALK OFF
SET CONSOLE OFF

LOCAL lcType
m.lcType = VARTYPE(m.loPreviewContainer)

IF PCOUNT() = 0 OR VARTYPE(m.loPreviewContainer) = "C" && No parameters, call the general preview
				&& initialization

	* Check if we have any printer installed
	IF APRINTERS(gaPrinters) = 0
		MESSAGEBOX("The enhanced reporting experience provided by FoxyPreviewer can't run because there are no printers installed on this computer." + ;
				CHR(13) + "Please install a printer and try again!", 16, "Install a printer")

		LOCAL loShell
		TRY 
			* Let's induce the user to install a printer
			loShell = CreateObject("WScript.Shell")
			loShell.Run("rundll32.exe shell32.dll,SHHelpShortcuts_RunDLL AddPrinter")
		CATCH 
		ENDTRY 
	ENDIF

	IF APRINTERS(gaPrinters) = 0
		RETURN .F.
	ENDIF

	* Ensure SET("FIXED") = OFF to allow the ReportOutput.App to register 
	* the desired ReportListener
	* Workaround for bug
	LOCAL lcSetFixed
	m.lcSetFixed = SET("Fixed")
	SET FIXED OFF

	LOCAL lcSys16
	m.lcSys16 = SYS(16)

	LOCAL lcLocalPath, llRelease
	m.lcLocalPath = ""
	m.llRelease   = .F.
	
	DO CASE
	CASE m.lcType = "C" AND UPPER(m.loPreviewContainer) = "RELEASE"
		m.llRelease = .T.

	CASE m.lcType = "C" AND DIRECTORY(m.loPreviewContainer)
		m.lcLocalPath = m.loPreviewContainer
		IF NOT PEMSTATUS(_Screen, "FoxypreviewerPath", 5)
			_Screen.AddProperty("FoxypreviewerPath", m.lcLocalPath)
		ENDIF

	OTHERWISE

	ENDCASE

	* Create some public variables
	TRY 
		IF VARTYPE(_FOXYPDF) = "U"
			PUBLIC _FOXYPDF, _FOXYPDFASIMAGE, _FOXYRTF, _FOXYHTML, _FOXYXLS
			_FOXYPDF        = 10
			_FOXYPDFASIMAGE = 11
			_FOXYRTF        = 12
			_FOXYXLS        = 13
			_FOXYHTML       = 14
		ENDIF
	CATCH
	ENDTRY


	IF NOT PEMSTATUS(_Screen, "FoxypreviewerOrigPreview", 5)
		_Screen.AddProperty("FoxypreviewerOrigPreview", _REPORTPREVIEW)
	ENDIF

	IF NOT PEMSTATUS(_Screen, "FoxypreviewerOrigOutput", 5)
		_Screen.AddProperty("FoxypreviewerOrigOutput", _REPORTOUTPUT)
	ENDIF

	IF NOT PEMSTATUS(_Screen, "FoxypreviewerOrigReportBehavior", 5)
		_Screen.AddProperty("FoxypreviewerOrigReportBehavior", SET("ReportBehavior"))
	ENDIF


	TRY
		_oReportOutput["1"].PREVIEWCONTAINER = .NULL.
		* _oReportOutput.Remove("1")
	CATCH TO m.loExc
	ENDTRY

	IF m.llRelease && UPPER(lcLocalPath) = "RELEASE"

		* Clean up 
		TRY
			_oReportOutput["1"].PREVIEWCONTAINER = .NULL.
			* _oReportOutput.Remove("1")
		CATCH TO m.loExc
		ENDTRY
		IF TYPE([_oReportOutput("1")]) = "O"
			_oReportOutput.Remove("1")
		ENDIF

		* Clean up the Report Factories for direct printing
		IF TYPE([_oReportOutput("0")]) = "O"
			_oReportOutput.Remove("0")
		ENDIF

		* Clean up the Report Factories for PDF, RTF and XLS
		IF TYPE([_oReportOutput("10")]) = "O"  && PDF
			_oReportOutput.Remove("10")
		ENDIF
		IF TYPE([_oReportOutput("11")]) = "O"  && PDF as Image
			_oReportOutput.Remove("11")
		ENDIF
		IF TYPE([_oReportOutput("12")]) = "O"  && RTF
			_oReportOutput.Remove("12")
		ENDIF
		IF TYPE([_oReportOutput("13")]) = "O"  && XLS
			_oReportOutput.Remove("13")
		ENDIF
		IF TYPE([_oReportOutput("14")]) = "O"  && HTML
			_oReportOutput.Remove("14")
		ENDIF
		IF TYPE([_oReportOutput("15")]) = "O"  && HTML Simplified
			_oReportOutput.Remove("15")
		ENDIF
		IF TYPE([_oReportOutput("16")]) = "O"  && Image file
			_oReportOutput.Remove("16")
		ENDIF

		
		* Preparing the new experimental report
		IF TYPE([_oReportOutput("20")]) = "O"  && PDF Offline
			_oReportOutput.Remove("20")
		ENDIF


		* Restore the original _REPORTPREVIEW
		IF "FOXYPREVIEWER" $ UPPER(_REPORTPREVIEW)
			TRY
				_REPORTPREVIEW = _Screen.FoxypreviewerOrigPreview
				REMOVEPROPERTY(_Screen, "FoxypreviewerOrigPreview")
			CATCH
			ENDTRY 
		ENDIF

		* Restore the original _REPORTOUTPUT
		IF "PR_FRXOUTPUT" $ UPPER(_REPORTOUTPUT)
			TRY
				_REPORTOUTPUT = _Screen.FoxypreviewerOrigOutput
				REMOVEPROPERTY(_Screen, "FoxypreviewerOrigOutput")
			CATCH
			ENDTRY 
		ENDIF

		* Restore the original REPORTBEHAVIOR
			LOCAL lcRepBehavior
			TRY
				lcRepBehavior = _Screen.FoxypreviewerOrigReportBehavior
				SET REPORTBEHAVIOR &lcRepBehavior.
				REMOVEPROPERTY(_Screen, "FoxypreviewerOrigReportBehavior")
			CATCH
			ENDTRY 

		* Release the public file type variables
		RELEASE _FOXYPDF, _FOXYPDFASIMAGE, _FOXYRTF, _FOXYHTML, _FOXYXLS,  _FOXYHTML2

		IF PEMSTATUS(_Screen, "oFoxyPreviewer", 5)
			TRY 
				_Screen.oFoxyPreviewer._olang = ""
				REMOVEPROPERTY(_Screen.oFoxyPreviewer, "_oLang")
			CATCH 
			ENDTRY
			TRY 
				_Screen.oFoxyPreviewer.Destroy()
				_Screen.oFoxyPreviewer = NULL
				REMOVEPROPERTY(_Screen, "oFoxyPreviewer")
			CATCH 
			ENDTRY
		ENDIF

		SET FIXED &lcSetFixed.

		* Removing the libraries used
		* 2031-08-29 Fix by Hernan Cano
		* http://foxypreviewer.codeplex.com/workitem/10310
		TRY 
			* RELEASE CLASSLIB ALIAS ("_ReportListener")
			RELEASE CLASSLIB ALIAS ("pr_ReportListener")
			RELEASE CLASSLIB ALIAS ("_GdiPlus")
			* CLOSE PROCEDURES ("FoxyPreviewer")
		CATCH 
		ENDTRY

		= ClearSetProc()
		= ClearSetClassLib()

		RETURN 
	ENDIF 


	* Proceed with normal initialization
	LOCAL loHelper, lnDataSession, lnSelect, lnRecno
	m.lnSelect      = SELECT()
	m.lnDataSession = SET("Datasession")
	m.lnRecno       = RECNO()

	* Call the helper form, that will be responsible for creating the listeners
	* needed, working on the Default DataSession
	LOCAL loHelperForm
	m.loHelperForm = CREATEOBJECT("FoxyInitForm", m.lcSys16, m.lcLocalPath)
	TRY 
		m.loHelperForm.Destroy()
	CATCH TO loExc
		* SET STEP ON 
	ENDTRY 
	m.loHelperForm = ""

	_Screen.oFoxyPreviewer.cLanguage = _Screen.oFoxyPreviewer.cLanguage

RETURN 
ENDIF PCOUNT() = 0 && End of initialization script


LOCAL lnSelect0
m.lnSelect0 = SELECT()

IF VARTYPE(_goFP) = "O"
	RELEASE _goFP
ENDIF
PUBLIC  _goFP
_goFP = CREATEOBJECT("PreviewHelper")
_goFP.lCompleteMode = .F.

SELECT (m.lnSelect0)


LOCAL loPreviewContainer AS FORM, ;
	loListener AS REPORTLISTENER, ;
	loExHandler AS ExtensionHandler OF SYS(16)

*-- Get a preview container from the
*-- .APP registered to handle object-assisted
*-- report previewing.
m.loPreviewContainer = NULL


LOCAL lcPreviewApp
* lcPreviewApp = "ReportPreview.App"
* lcPreviewApp = _Screen.FoxypreviewerOrigPreview
lcPreviewApp = "PR_FRXPreview.Prg"

TRY
	DO (m.lcPreviewApp) WITH m.loPreviewContainer
CATCH
	DO (HOME() + m.lcPreviewApp) WITH m.loPreviewContainer
ENDTRY

* Create a PREVIEW listener
TRY
	m.loListener = NEWOBJECT(MAIN_LISTENER, "PR_ReportListener.vcx") && , "ReportOutput.App")
CATCH
	m.loListener = CREATEOBJECT(MAIN_LISTENER)
ENDTRY

m.loListener.LISTENERTYPE = 3 && Preview
m.loListener.QUIETMODE = _goFP.lQuietMode
TRY 
	m.loListener.fxFeedbackClass = _goFP._cThermClass
	m.loListener.lExpandFields = _goFP.lExpandFields
CATCH
ENDTRY 

*-- Link the Listener and preview container
m.loListener.PREVIEWCONTAINER = m.loPreviewContainer

* Create an extension handler and hook it to the
* preview container. This will let you manipulate
* properties of the container and its Preview toolbar
m.loExHandler = NEWOBJECT('ExtensionHandler')
_goFP._oExHandler = m.loExHandler
_goFP.UpdateProperties()

m.loPreviewContainer.SetExtensionHandler(m.loExHandler)
m.loPreviewContainer.SetZoomLevel(_goFP.nZoomLevel)
m.loPreviewContainer.SetCanvasCount(_goFP.nCanvasCount)

RELEASE m.loPreviewContainer, m.loListener, m.loExHandler
RETURN



DEFINE CLASS PreviewHelper AS CUSTOM
	cPrinterName = SET("Printer",3)

	lSaveToFile     = .T. && adds the save to file button
	lSendToEmail    = .T. && adds the send to email button
	lPrintVisible   = .T. && shows the print button and other related printing buttons in the toolbar
	lShowCopies     = .T. && shows the copies spinner
	lShowMiniatures = .T. && shows the miniatures page
	lShowClose      = .T. && shows the close button
	lShowPrintBtn   = .T. && shows the printer button (only the print btn)
	lShowPageCount  = .T. && shows / hides the option to change page count:
	lShowFileFormatIcons = .T.  && shows / hides the file format icons in context menus for saving
	
	lPrinterPref    = .T. && shows the printer preferences button

	* Output types allowed in the "Save as.." button from the toolbar
	lSaveAsImage	 = .T.
	lSaveAsHTML		 = .T.
	lSaveAsRTF		 = .T.
	lSaveAsXLS 		 = .T.
	lSaveAsPDF		 = .T.
	lSaveasTXT       = .T. && Save as txt 11/08/2010 by mauriciobraga@ig.com.br
	lSaveAsMHT		 = .T.

	lQuietMode       = .F.

	cDestFile        = ""   && the destination file (image, htm, pdf, etc)
	lPrinted         = .F.  && knows if the user printed the report
	lSaved           = .F.  && knows if the user saved the report to a file
	lEmailed  	     = .F.  && knows if the user emailed the report
 
	nPageTotal       = 0 && Total pages of the current report
	nCopies          = 1 && The quantity of copies to be printed
	cTitle           = "" && PR_REPORTTITLE && The preview window title
	cToolbarTitle    = ""
	oListener        = NULL
	cDefaultListener = MAIN_LISTENER
	cSuccessor       = ""
	nCanvasCount = 1 && initial nr of pages rendered on the preview form.
&& Valid values are 1 (default), 2, or 4.

	nZoomLevel	= 5 && initial zoom level of the preview window. Possible values are:
&& 1-10%, 2-25%, 3-50%, 4-75%, 5-100% default, 6-150% ;
&& 7-200%, 8-300%, 9-500%, 10-whole page

	nWindowState = 0 && Normal

	nDockType	= 4 && .F. && false MEANS TO KEEP THE CURRENT DOCK SETTINGS FROM THE RESOURCE
*!*		–1 Undocks the toolbar or form.
*!*	 	 0 Positions the toolbar or form at the top of the main Visual FoxPro window.
*!*		 1 Positions the toolbar or form at the left side of the main Visual FoxPro window.
*!*		 2 Positions the toolbar or form at the right side of the main Visual FoxPro window.
*!*		 3 Positions the toolbar or form at the bottom of the main Visual FoxPro window.

	cFormIcon = PR_FORMICON
	nPreviewBackColor = NULL
	lUseListener = .T.

	lEmailAuto = .T. 		&& Automatically generates the report output file
	cEmailType = "PDF" 		&& The file type to be used in Emails (PDF, RTF, HTML, XML or XLS)
	cEmailPRG  = ""
	cFaxPRG    = ""  && If not empty, he fax button will appear in the CDOSYS email form

	*!* 2010-09-17 - Jacques Parent - Add the cSaveDefName
	cSaveDefName  = ""		&& Default name of the save file.  Available in the SAVE AS dialog OR automatically used if lEmailAuto

	cSMTPServer   = ""
	nSMTPPort     = 25
	lSMTPUseSSL   = .F.
	cSMTPUserName = ""
	cSMTPPassword = ""

	cEmailTo      = ""
	cEmailSubject = ""
	cEmailBody    = ""
	cEmailFrom    = ""

	cEmailCC 		= ""
	cEmailBCC 		= ""
	cEmailReplyTo	= ""

	lAutoSendMail= .F.		&& Send an email automatically when processing the report

	nButtonSize   = 1 && 1=16x16 pixels (default), 2=32x32 pixels
	cCodePage  = "1252"	&& CodePage, to be used by PDF Listener

*!*	CP1250 Microsoft Windows Codepage 1250 (EE)
*!*	CP1251 Microsoft Windows Codepage 1251 (Cyrl)
*!*	CP1252 Microsoft Windows Codepage 1252 (ANSI)
*!*	CP1253 Microsoft Windows Codepage 1253 (Greek)
*!*	CP1254 Microsoft Windows Codepage 1254 (Turk)
*!*	CP1255 Microsoft Windows Codepage 1255 (Hebr)
*!*	CP1256 Microsoft Windows Codepage 1256 (Arab)
*!*	CP1257 Microsoft Windows Codepage 1257 (BaltRim)
*!*	CP1258 Microsoft Windows Codepage 1258 (Viet)

	lPDFasImage     = .F.

	nMaxMiniatureDisplay = 64	&& Number of miniature to display in the miniature form

	cLanguage = PR_DEFAULTLANGUAGE

	nShowToolBar   = 1 && 1 = Visible (default), 2 = Invisible, 3 = Use resource
	lShowSetup     = .T.
	lShowPrinters  = .T. && determines if the available printers combo will be shown
	lShowSearch    = .T. && determines if the Search buttons will be visible

	lSilent	= .F.		&& Stay silent AND write any messagebox to the cErrors properties
	cErrors = ""		&& Contains any error message

	lCompleteMode      = .T. && Flag that tells if the report is being run autoin the old and unsupported COMPLETE mode

	* Internal use properties
	_ClausenRangeFrom = 1
	_ClausenRangeTo = -1 && All pages

	_ClausenPrintRangeFrom = 0
	_ClausenPrintRangeTo   = 0

	_ClauselSummary = .F.
	_ClausecHeading = ""

	_cFRXName      = "" && the ReportFrxName
	_cFRXFullName  = ""

	_oReports = "" && Internal use, collection that contains the report names to be used
	_oClauses = ""
	_oAliases = ""
	_oNames = ""

	_oProofSheet    = ""
	_oSettingsSheet = ""
	_oEmailSheet    = ""

	_cOriginalPrinter = SET("Printer",3)
	_lSendToPrinter = .F.	&& Flag that will tell the object to
		&& run the report again and send the output
		&& to another printer after the preview window is closed
	_lNoWait = .F.
	_OldReportOutput = ""
	_oExHandler = ""
	_oCaller = "" && The caller object, used in the APP mode, when called from an EXE
	_oParentForm = ""
	_DE_Name = "" && the dataenvironment name, to be used on cleanup
	_oReport = ""
	_lSendingEmail = .F.
	_lSendingFax   = .F.  && Flag to tell that we are sending a FAX instead of an email

	_cDefaultFolder = SYS(5) + SYS(2003)
	_lIsDotMatrix = .F.

	_oLang = ""
	_nBtSize = 0
	_aLanguages = ""
	_aLangLocal = ""
	_LangIndex  = ""

	_cReportEnvPrinterName = ""

	* by Mauricio Braga
	cOutputPath = ""  && destination path 11/08/2010 by mauriciobraga@ig.com.br


	* Search properties
	_cOutputAlias     = ""
	_cTextToFind      = ""
	_nIndex           = 0 && the index number of the reports collection
	_lCanSearch       = .F.
	_lShowSearchAgain = .F.


	nPrinterPropType  = 1 && 1 = PRINTER PROMPT Printer dialog     2 = Current printer properties
	lDirectPrint      = .F. && Flag that directs the output directly to the printer, without preview

	_TopForm = .F.
	nVersion = FOXYPREVIEWER_VERSION
	cVersion = FOXYPREVIEWER_VERSION2
	nSearchPages = -1
	_cThermClass = "FOXYTHERM"
	nThermType   = 2 && 1 = Default     2 = Enhanced, with CTL32
	nThermFormWidth = 356

	cDecryptPROCEDURE = ""	&& The programmer can apply his own Scrambling method on the password string...
	cEncryptPROCEDURE = ""	&& The programmer can apply his own Scrambling method on the password string...
	cCryptKey         = CRYPT_KEY

	_cAttachment      = ""
	cAttachments      = ""
	lReadReceipt      = .F.
	lPriority         = .F.

	nEmailMode        = 1   && 1 = MAPI, 2 = CDOSYS HTML, 3 = CDOSYS TEXT, 4 = Custom PROCEDURE, 5 = MAPI2
	cEmailBodyFile    = ""  && HTML file to be used as email body


	* PDF properties
	lPDFEmbedFonts      = .F.
	lPDFCanPrint        = .T.
	lPDFCanEdit         = .T.
	lPDFCanCopy         = .T.
	lPDFCanAddNotes     = .T.
	lPDFEncryptDocument = .F.
	cPDFMasterPassword  = ""
	cPDFUserPassword    = ""
	lOpenViewer         = .F.
	nPDFPageMode        = 1 && Default = 1, 1 = Normal view, 2 = Show the outlines pane, 3 = Show the thumbnails pane
	lPDFShowErrors      = .F.
	cPDFSymbolFontsList = "" && List of fonts to 
	cPdfAuthor          = ""
	cPdfTitle           = ""
	cPdfSubject         = ""
	cPdfKeyWords        = ""
	cPdfCreator         = "PDFx / FoxyPreviewer"
	cPDFDefaultFont     = "Helvetica"
	
	lPDFReplaceFonts    = .T.
	nPDFLineHeightRatio = 1

	cAdressTable        = ""
	cAdressSearch       = ""


	* XLS properties
	lExcelConvertToXLS  = .T. && Convert worksheet to 'Excel 95' format? (requires MS Excel or OpenOffice installed)                 
	lExcelRepeatHeaders = .F. && Repeat report page headers in worksheet                
	lExcelRepeatFooters = .F. && Repeat report page footers in worksheet                
	lExcelHidePageNo    = .T. && Hides report fields that contain "_PAGENO" information
	lExcelAlignLeft     = .F.
	nExcelSaveFormat	= 56 && 56=Excel8 - 43=xlExcel9795 

	_SetUDFParms    = ""

	cImgPrint 		= ""
	cImgPrintPref   = ""
	cImgSave        = ""
	cImgClose       = ""
	cImgClose2      = ""
	cImgEmail       = ""
	cImgSetup       = ""
	cImgMiniatures  = ""
	cImgSearch      = ""
	cImgSearchAgain = ""
	cImgSearchBack  = ""
	
	cImgPrintBig       = ""
	cImgPrintPrefBig   = ""
	cImgSaveBig        = ""
	cImgCloseBig       = ""
	cImgClose2Big      = ""
	cImgEmailBig       = ""
	cImgSetupBig       = ""
	cImgMiniaturesBig  = ""
	cImgSearchBig      = ""
	cImgSearchAgainBig = ""
	cImgSearchBackBig  = ""

	_SettingsFile   = ""
	_lAlreadyOpened = .F.
	_Sys16          = ""
	_clocalPath     = ""
	_cOrigRepPreview= ""


	_oLang          = "" && Not used in complete mode, it is here to avoid errors in the simplified mode
	_cLangLoaded    = "" && Not used in complete mode, it is here to avoid errors in the simplified mode
	_PreviewVersion = ""

	oSettingsDlg    = "" && Not used in complete mode, it is here to avoid errors in the simplified mode

	lExpandFields   = .F.
	cPrintJobName   = ""
	cExcelDefaultExtension = ""

*!*	lSetDiagEnabledLanguage = .T.
*!*	lSetDiagEnabledTabGeneral = .T.
*!*	lSetDiagEnabledTabControls = .T.
*!*	lSetDiagEnabledTabOutput = .T.
*!*	lSetDiagEnabledTabEmail = .T.
*!*	lSetDiagEnabledTabPDF = .T.
*!*	lSetDiagEnabledChkPrintPref = .T.
*!*	lSetDiagEnabledChkCopies = .T.
*!*	lSetDiagEnabledChkSavetoFile = .T.
*!*	lSetDiagEnabledChkPrinters = .T.
*!*	lSetDiagEnabledChkEmail = .T.
*!*	lSetDiagEnabledChkMiniatures = .T.
*!*	lSetDiagEnabledChkSearch = .T.
*!*	lSetDiagEnabledChkSettings = .T.
*!*	lSetDiagEnabledChkSaveAsImage = .T.
*!*	lSetDiagEnabledChkSaveAsPDF = .T.
*!*	lSetDiagEnabledChkSaveAsRTF = .T.
*!*	lSetDiagEnabledChkSaveAsHTML = .T.
*!*	lSetDiagEnabledChkSaveAsXLS = .T.
*!*	lSetDiagEnabledChkSaveAsTXT = .T.

	* Properties for internal use only
	_InitStatusText       = ""
	_PrepassStatusText    = ""
	_RunStatusText        = ""
	_SecondsText          = ""
	_CancelInstrText      = ""
	_CancelQueryText      = ""
	_ReportIncompleteText = ""
	_AttentionText        = ""

	_ErrorSendingMail     = ""
	_MsgNotSentText       = ""
	_MsgSuccessText       = ""
	_SendEmailText        = ""
	_AttachNotFoundText   = ""
	_SendingText          = ""

	lRepeatInPage          = .F.
	lRepeatWhenFree        = .F.

	* Watermarks
	cWatermarkImage        = ""
	nWatermarkType         = 1    && 1 = colored ; 2 = greyscale
	nWatermarkTransparency = 0.25 && 0 = transparent ; 1 = opaque
	nWatermarkWidthRatio   = 0.75 && 0 - 1
	nWatermarkHeightRatio  = 0.75 && 0 - 1

	* Double byte language
	lDoubleByteLanguage    = NULL


PROCEDURE lPrinted_Assign
	LPARAMETERS tlValue
	IF VARTYPE(_Screen.oFoxypreviewer) = "O"
		_Screen.oFoxyPreviewer.lPrinted = m.tlValue
	ENDIF
	This.lPrinted = m.tlValue
ENDPROC

PROCEDURE lSaved_Assign
	LPARAMETERS tlValue
	IF VARTYPE(_Screen.oFoxypreviewer) = "O"
		_Screen.oFoxyPreviewer.lSaved = m.tlValue
	ENDIF
	This.lSaved = m.tlValue
ENDPROC

PROCEDURE lEmailed_Assign
	LPARAMETERS tlValue
	IF VARTYPE(_Screen.oFoxypreviewer) = "O"
		_Screen.oFoxyPreviewer.lEmailed = m.tlValue
	ENDIF
	This.lEmailed = m.tlValue
ENDPROC

PROCEDURE cDestFile_Assign
	LPARAMETERS tcDestFile
	IF VARTYPE(_Screen.oFoxypreviewer) = "O"
		_Screen.oFoxyPreviewer.cDestFile = m.tcDestFile
	ENDIF
	This.cDestFile = m.tcDestFile
ENDPROC



PROCEDURE DoEncrypt
	LPARAMETERS tcString
	LOCAL lcEncrProc
	m.lcEncrProc = This.cEncryptPROCEDURE

	IF EMPTY(m.lcEncrProc) && The programmer can apply his own Scrambling method on the password string...
		RETURN RC4(m.tcString, This.cCryptKey)
	ELSE
		RETURN &lcEncrProc.(m.tcString)
	ENDIF 
ENDPROC 


PROCEDURE DoDecrypt
	LPARAMETERS tcString
	LOCAL lcDecrProc
	m.lcDecrProc = This.cDecryptPROCEDURE

	IF EMPTY(m.lcDecrProc) && The programmer can apply his own Scrambling method on the password string...
		RETURN RC4(m.tcString, This.cCryptKey)
	ELSE
		RETURN &lcDecrProc.(m.tcString)
	ENDIF 
ENDPROC 


PROCEDURE OpenFile
	LPARAMETERS tcLink As String, tcAction As String, tcParms As String

	LOCAL llSuccess
	TRY 
		m.tcAction = IIF(EMPTY(m.tcAction), "Open", m.tcAction)
		m.tcParms  = IIF(EMPTY(m.tcParms) , ""    , m.tcParms)
		This._lAlreadyOpened = .T.
		=ShellExecute(FindWindow(0, _Screen.Caption), m.tcAction, m.tcLink, m.tcParms, Sys(2023), 1)
		m.llSuccess = .T.
	CATCH 
		m.llSuccess = .F.
	ENDTRY 
	IF NOT m.llSuccess
		MESSAGEBOX("Could not locate the file or link: " + _CRLF + m.tcLink, 16, "Internal error")
	ENDIF
	RETURN m.llSuccess
ENDPROC 

PROCEDURE UpdateProperties

	TRY
		LOCAL lnProps, lcProperty, luValue
		IF VARTYPE(_Screen.oFoxyPreviewer) = "O"
			m.lnProps = AMEMBERS(laProps, _Screen.oFoxyPreviewer, 0)

			FOR m.n = 1 TO m.lnProps
				m.lcProperty = laProps(m.n)
				IF LEFT(m.lcProperty, 1) = "_"
					LOOP
				ENDIF				
				m.luValue = NULL
				TRY 
					m.luValue = EVALUATE("_Screen.oFoxyPreviewer." + m.lcProperty)
				CATCH 
				ENDTRY 
				IF ISNULL(m.luValue)
					LOOP
				ELSE 
					* Some properties of the _Screen.oFoxy object cant be updated because they are read-only
					TRY 
						This.&lcProperty. = m.luValue
					CATCH 
					ENDTRY 
				ENDIF 
			ENDFOR 
		ENDIF 
	CATCH TO m.loExc
		MESSAGEBOX("Error in method 'UpdateProperties'" + _CRLF + ;
			TRANSFORM(m.loExc.ERRORNO) + " - " + m.loExc.MESSAGE + _CRLF + ;
			"Line: " + TRANSFORM(m.loExc.LINENO) + " - " + m.loExc.LINECONTENTS)
	ENDTRY 
ENDPROC 



	PROCEDURE INIT
	LPARAMETERS tlLocal

		This._SetUDFParms = SET("Udfparms")
		SET UDFPARMS TO VALUE
		
		This.cErrors = ""

		IF _VFP.StartMode = 0 && Development
			LOCAL lcPath
			m.lcPath = ADDBS(JUSTPATH(This.Classlibrary))
			SET PROCEDURE TO (This.ClassLibrary) ADDITIVE 
			SET PATH TO (m.lcPath) ADDITIVE 
			SET PATH TO (m.lcPath) + "Images" ADDITIVE 

			IF NOT ("_GDIPLUS.VCX" $ SET("Classlib"))
				SET CLASSLIB TO m.lcPath + "_GdiPlus.vcx" ADDITIVE
			ENDIF
			IF NOT ("PR_REPORTLISTENER.VCX" $ SET("Classlib"))
				SET CLASSLIB TO m.lcPath + "PR_ReportListener.vcx" ALIAS PR_REPORTLISTENER ADDITIVE 
			ENDIF
			_REPORTOUTPUT = "PR_FRXOUTPUT"
			
		ELSE 
			IF NOT ("_GDIPLUS.VCX" $ SET("Classlib"))
				SET CLASSLIB TO "_GdiPlus.vcx" ADDITIVE
			ENDIF
			
			IF NOT ("PR_REPORTLISTENER.VCX" $ SET("Classlib"))
				SET CLASSLIB TO "PR_ReportListener.vcx" IN JUSTFNAME(SYS(16)) ALIAS PR_REPORTLISTENER ADDITIVE
			ENDIF

			_REPORTOUTPUT = "PR_FRXOUTPUT"

			IF "APP" $ SYS(16)
				SET PROCEDURE TO (SYS(16)) ADDITIVE
			ENDIF
		ENDIF


		LOCAL lcLocalFoxyPath
		m.lcLocalFoxyPath = ""
		IF PEMSTATUS(_Screen, "FoxypreviewerPath", 5)
			m.lcLocalFoxyPath = _Screen.FoxypreviewerPath
		ENDIF


		IF This.lCompleteMode = .T.
			RELEASE _goFP

			IF NOT m.tlLocal
				PUBLIC _goFP
				_goFP = THIS
			ENDIF

			* Extract the HPDF library
			LOCAL lcClassPath, lcPDFFile, lcTestPath
			IF NOT EMPTY(m.lcLocalFoxyPath)
				m.lcClassPath = m.lcLocalFoxyPath
			ELSE 
				m.lcClassPath = IIF(EMPTY(This.ClassLibrary), "", ADDBS(JUSTPATH(This.ClassLibrary)))
			ENDIF
			
			* Update the SET PATH if necessary
			IF NOT ALLTRIM(UPPER(m.lcClassPath)) $ SET("Path")
				SET PATH TO (m.lcClassPath) ADDITIVE 
			ENDIF
			
			m.lcPDFFile = "libhpdf.dll"
			IF FILE(m.lcPDFFile) AND EMPTY(SYS(2000,m.lcPDFFile))
				* File is an embedded resource
				m.lcTestPath = m.lcClassPath + m.lcPDFFile && FULLPATH("libhpdf.dll")
				IF PR_PathFileExists(m.lcTestPath + CHR(0)) = 0
					STRTOFILE(FILETOSTR(m.lcPDFFile), m.lcClassPath + m.lcPDFFile)
				ENDIF
				
				IF NOT FILE(m.lcClassPath + m.lcPDFFile)
					STRTOFILE(FILETOSTR(m.lcPDFFile), ADDBS(HOME()) + m.lcPDFFile)
					SET PATH TO (HOME()) ADDITIVE 
				ENDIF
			ENDIF
		ENDIF

		This._SYS16 = SUBSTR(SYS(16), 30)
		This.UpdateSettings()

		WITH This
			._InitStatusText     = .GetLoc("INITSTATUS") + SPACE(1)
			._PrepassStatusText  = .GetLoc("PREPSTATUS") + SPACE(1)
			._RunStatusText      = .GetLoc("RUNSTATUS")  + SPACE(1)
			._SecondsText        = .GetLoc("SECONDS")    + SPACE(1)
			._CancelInstrText    = .GetLoc("CANCELINST") + SPACE(1)
			._CancelQueryText    = .GetLoc("CANCELQUER")
			._ReportIncompleteText = .GetLoc("REPINCOMPL")
			._AttentionText      = .GetLoc("ATTENTION") 

			._ErrorSendingMail   = .GetLoc("ERRSENDMAI")
			._MsgNotSentText     = .GetLoc("MSGNOTSENT")
			._MsgSuccessText     = .GetLoc("MSGSUCCESS")
			._SendEmailText      = .GetLoc("SENDEMAIL")
			._AttachNotFoundText = .GetLoc("ATACHNOTFO")
			._SendingText        = .GetLoc("MSGSENDING")
		ENDWITH
	ENDPROC


	PROCEDURE UpdateSettings
		LPARAMETERS tlForce

		LOCAL lcLocalFoxyPath
		m.lcLocalFoxyPath = ""
		IF PEMSTATUS(_Screen, "FoxypreviewerPath", 5)
			m.lcLocalFoxyPath = _Screen.FoxypreviewerPath
		ENDIF

		LOCAL lcClassPath, lcFile, lcUserSetFile, lcDefaultSetFile, lcNewFile
		m.lcUserSetFile    = "FoxyPreviewer_Settings.dbf"
		m.lcDefaultSetFile = "FoxyPreviewer_DefaultSettings.dbf"

		IF NOT EMPTY(m.lcLocalFoxyPath)
			m.lcClassPath = m.lcLocalFoxyPath
			m.lcNewFile   = ADDBS(m.lcClassPath) + m.lcUserSetFile
		ELSE 
			m.lcClassPath = IIF(EMPTY(This.ClassLibrary), "", ADDBS(JUSTPATH(This.ClassLibrary)))
			m.lcNewFile   = ADDBS(m.lcClassPath) + m.lcUserSetFile
		ENDIF

		IF (This.lCompleteMode = .F.) AND ;
				TYPE("_Screen.oFoxyPreviewer._cLocalPath") = "C" AND ;
				NOT EMPTY(_Screen.oFoxyPreviewer._cLocalPath)
			m.lcClassPath = _Screen.oFoxyPreviewer._cLocalPath
		ENDIF
		m.lcFile           = m.lcClassPath + m.lcUserSetFile

*		IF (NOT FILE(lcUserSetFile)) AND (FILE(lcDefaultSetFile))
		IF (NOT FILE(m.lcFile)) AND (FILE(m.lcDefaultSetFile))

			* Restore from the embedded resource
			IF PR_PathFileExists(m.lcUserSetFile + CHR(0)) = 0
				STRTOFILE(FILETOSTR(m.lcDefaultSetFile), m.lcFile)
				DO pr_CPZERO WITH m.lcFile,0   && <= by Nick Porfyris [20100921]...
					&& "foxypreviewer_settings.dbf" MUST have CODE PAGE equal to ZERO, in order
					&& to save and retrieve properly the Greek and other international
					&& characters, so add the cpzero command
			ENDIF
			
			IF NOT FILE(m.lcFile)
				LOCAL lcSetSafety
				m.lcSetSafety = SET("Safety")
				SET SAFETY OFF

				STRTOFILE(FILETOSTR(m.lcDefaultSetFile), m.lcNewFile) && ADDBS(HOME()) + lcUserSetFile)
				SET PATH TO (HOME()) ADDITIVE 

				SET SAFETY &lcSetSafety.
			ENDIF

		ENDIF
		
		LOCAL lnSelect, lcAlias
		m.lnSelect = SELECT()
		m.lcAlias  = SYS(2015)

		TRY

			IF FILE(m.lcFile)
				USE (m.lcFile) IN 0 AGAIN SHARED ALIAS (m.lcAlias) && FP_Settings
			ELSE 
				USE (JUSTFNAME(m.lcFile)) IN 0 AGAIN SHARED ALIAS (m.lcAlias) && FP_Settings
			ENDIF 

			This._SettingsFile = DBF(m.lcAlias)

			SELECT (m.lcAlias) && FP_Settings
			LOCAL lcProp, lcType, luValue, luValue2
			SCAN
				m.lcProp  = ALLTRIM(EVALUATE(m.lcAlias + ".Property")) && FP_Settings.Property

				* 2013-09-12 Fix to avoid empty records
				IF EMPTY(m.lcProp)
					DELETE
					LOOP 
				ENDIF 
				m.lcType  = UPPER(LEFT(m.lcProp, 1))
				m.luValue = EVALUATE(m.lcAlias + "." + m.lcType + "Value")

				IF m.lcType = "C"
					m.luValue = ALLTRIM(m.luValue)
				ENDIF

				* [2010-10-14] Now the user is free to add his own rows into the FoxyPreviewer_settings.dbf !...
				* This.&lcProp. = luValue			&&[20101014] by Nick Porfyris...
				IF VARTYPE(This.&lcProp.) = [U]		&& user defined row, so skip it, avoiding the Error msg: "Property NOT FOUND!..."
				ELSE

					* If we're in simplified mode, we have to ignore the settings from the table, and keep
					* the settings that were set manually
					* Except if the definitions come from the Settings form
					IF This.lCompleteMode = .F. AND (tlForce = .F.)
						m.luValue2 = EVALUATE("_Screen.oFoxyPreviewer." + m.lcProp)
						IF NOT ISNULL(m.luValue2)
							m.luValue = m.luValue2
						ENDIF 
					ENDIF
					
					IF ISNULL(m.luValue) && If the settings table contains a NULL value, ignore it, and keep the default value
						LOOP
					ENDIF

					IF This.lCompleteMode = .F. AND (tlForce = .T.)
						IF NOT ISNULL(m.luValue)
							_Screen.oFoxyPreviewer.&lcProp. = m.luValue
						ENDIF 
					ENDIF

					This.&lcProp. = m.luValue
				ENDIF
				* [2010-10-14]
			ENDSCAN

		CATCH TO m.loExc
		
			SET STEP ON 
		
			* LOCAL loExc AS EXCEPTION
			IF m.loExc.ERRORNO = 1 && File not found
				This.SetError("Could not locate the settings table." + _CRLF + ;
					"Please check the folder permissions of the folder where you saved 'FoxyPreviewer.App', because this utility needs Read/Write permission in that folder." + ;
					"You may need to move the APP from that folder." + _CRLF +  _CRLF + ;
					"Loading default preview settings")

			ELSE
				LOCAL lcMsg
				lcMsg = "Error in UpdateSettings" + _CRLF + ;
					TRANSFORM(m.loExc.ERRORNO) + " - " + m.loExc.MESSAGE + _CRLF + ;
					"Line: " + TRANSFORM(m.loExc.LINENO) + " - " + m.loExc.LINECONTENTS
				This.SetError(lcMsg)
			ENDIF
		ENDTRY

		USE IN SELECT(m.lcAlias)

		SELECT (m.lnSelect)

		WITH THIS
			&& included test .F. to lSaveAsTXT && 11/08/2010 by mauriciobraga@ig.com.br
			IF TRANSFORM(.lSaveAsImage) + TRANSFORM(.lSaveAsPDF) + TRANSFORM(.lSaveAsRTF) + ;
					TRANSFORM(.lSaveAsXLS) + TRANSFORM(.lSaveAsHTML) + ;
					TRANSFORM(.lSaveasTXT) + TRANSFORM(.lSaveAsMHT) = ".F..F..F..F..F..F..F."
				.lSaveToFile = .F.
			ENDIF
		ENDWITH
	
	ENDPROC


	PROCEDURE nThermType_Assign
		LPARAMETERS tnType
		LOCAL lcThermClass
		IF m.tnType = 1
			m.lcThermClass = "FXTHERM"
		ELSE 
			m.lcThermClass = "FOXYTHERM"
		ENDIF
		This._cThermClass = m.lcThermClass
		This.nThermType   = m.tnType
	ENDPROC
	

	PROCEDURE cLanguage_Assign
		LPARAMETERS tcLanguage

		IF EMPTY(m.tcLanguage)
			m.tcLanguage = PR_DEFAULTLANGUAGE
		ENDIF

		IF m.tcLanguage = "ESPANIOL"
			m.tcLanguage = "SPANISH"
		ENDIF

		IF (This.cLanguage == m.tcLanguage) AND (VARTYPE(This._oLang) = "O")
			* We have the same language, no need to update
			RETURN
		ENDIF

		This.cLanguage = UPPER(ALLTRIM(m.tcLanguage))
		This.SetLanguage(m.tcLanguage)
	ENDPROC


	PROCEDURE SetLanguage
		LPARAMETERS tcLanguage

		LOCAL lcDBFFile, lnSelect
		m.lnSelect = SELECT()
		m.lcDBFFile = "FoxyPreviewer_Locs.dbf"

		TRY 
			USE (m.lcDBFFile) IN 0 AGAIN SHARED
		CATCH
			This.SetError("Could not load the localizations table.")
		ENDTRY 
		SELECT (m.lcDBFFile)
	
		* populate the Collection of available languages
		IF VARTYPE(This._aLanguages) <> "O"
			This._aLanguages = CREATEOBJECT("Collection")
			This._aLangLocal = CREATEOBJECT("Collection")
			SCAN
				This._aLanguages.ADD(LANGUAGE)
				This._aLangLocal.ADD(LocalLang)
			ENDSCAN
		ENDIF

		LOCATE FOR m.tcLanguage $ UPPER(LANGUAGE + LocalLang)	&& Allows searching using the English language name or the local. Eg. "FRENCH / FRANÇAIS"

		IF EOF() && Could not locate the desired language
			This.SetError(This.GetLoc("LANGNOTFOU") + " - " + m.tcLanguage + _CRLF +;
				"Make sure that the desired language is available in FoxyPreviewer_Locs.dbf")

			GO TOP
		ENDIF

		This._LangIndex = RECNO()
		This.cCodePage  = cCodePage	&& CodePage, to be used by PDF Listener			&&  <== 20100728 Modified by Nick Porfyris

		SCATTER NAME oLang
		This._oLang = oLang
		USE IN (m.lcDBFFile)
		SELECT (m.lnSelect)
	ENDPROC

	PROCEDURE SetError
		LPARAMETERS tcErrMsg, tcTitle

		IF NOT EMPTY(m.tcErrMsg)
			This.cErrors = This.cErrors + IIF(EMPTY(This.cErrors), "", _CRLF) + m.tcErrMsg
		ENDIF

		IF NOT This.lSilent
			LOCAL lcErrCaption
			TRY
				m.lcErrCaption = This.GetLoc("ERROR")
			CATCH
				m.lcErrCaption = "ERROR"
			ENDTRY 

			IF EMPTY(m.tcTitle)
				m.lcErrCaption = m.lcErrCaption + SPACE(20) + "-" + SPACE(20) + TRANSFORM(This.cVersion)
			ELSE 
				m.lcErrCaption = m.tcTitle
			ENDIF

			MESSAGEBOX(m.tcErrMsg, 16, m.lcErrCaption)
		ENDIF
	ENDPROC


	PROCEDURE GetLoc
		LPARAMETERS tcString
		LOCAL lcTransl
		TRY
			m.lcTransl = TRIM(EVALUATE("This._oLang." + m.tcString))
		CATCH
		
			IF UPPER(m.tcString) = "ERROR"
				m.lcTransl = "** ERROR **"
			ELSE
				m.lcTransl = ""
				This.SetError("Could not locate the string '" + ;
					m.tcString + "' in the localizations table." + ;
					"Please make sure that you have the latest version available of 'FoxyPreviewer_locs.dbf'.")

				IF ISDEBUGGING
					SET STEP ON 
				ENDIF 
			ENDIF
		ENDTRY 
		RETURN m.lcTransl
	ENDPROC


	PROCEDURE DESTROY

		IF ISDEBUGGING
			SET STEP ON 
		ENDIF 

		LOCAL lcUDFPar
		m.lcUDFPar = This._SetUDFParms
		SET UDFPARMS TO &lcUDFPar.

		LOCAL loParent AS CUSTOM
		m.loParent = This._oCaller
		IF VARTYPE(m.loParent) = "O"
			TRY 
				m.loParent.lSaved 	 = This.lSaved
				m.loParent.lPrinted  = This.lPrinted
				m.loParent.cDestFile = This.cDestFile
				m.loParent.lEmailed	 = This.lEmailed
				m.loParent.cErrors	 = This.cErrors
				m.loParent.nVersion  = This.nVersion
				m.loParent.cVersion  = This.cVersion
			CATCH TO m.loExc
				IF ISDEBUGGING
					SET STEP ON 
				ENDIF 
				This.SetError("Error updating the caller class." + _CRLF + ;
					"Check if the file FOXUPREVIEWERCALLER.PRG matches the APP version.")
			ENDTRY
		ENDIF

		WITH This
			._oReport       = ""
			.oListener      = ""
			._oReports       = "" && Internal use, collection that contains the report names to be used
			._oClauses       = ""
			._oAliases       = ""
			._oNames         = ""
			._oProofSheet    = ""
			._oSettingsSheet = ""
			._oEmailSheet    = ""
			._oExHandler     = ""
			._oCaller        = "" && The caller object, used in the APP mode, when called from an EXE
			._oParentForm    = ""
			._oReport        = ""
			._oLang          = ""
		ENDWITH

		This.ClearCache()

		* Just for safety, to ensure the helper object will not remain in memory
		_goFP = ""
		RELEASE _goFP
	ENDPROC



	PROCEDURE CloseSheets
		IF VARTYPE(This._oProofSheet) = "O"
			This._oProofSheet.RELEASE()
		ENDIF

		IF VARTYPE(This._oSettingsSheet) = "O"
			This._oSettingsSheet.RELEASE()
		ENDIF

		IF VARTYPE(This._oEmailSheet) = "O"
			This._oEmailSheet.RELEASE()
		ENDIF

		=DOFOXYTHERM() && Close any remaining progressbar
	ENDPROC


	PROCEDURE AddReport(tcReport, tcClauses, tcAlias, tcName)
	* populates a collection object with the report files and clauses
	* This method can be called many times, providing an easy way to merge reports.
		IF EMPTY(m.tcName)
			m.tcName = m.tcReport
		ENDIF

		IF VARTYPE(This._oReports) <> "O"
			This._oReports = CREATEOBJECT("Collection")
			This._oClauses = CREATEOBJECT("Collection")
			This._oAliases = CREATEOBJECT("Collection")
			This._oNames = CREATEOBJECT("Collection")
		ENDIF
		This._oReports.ADD(m.tcReport)
		This._oClauses.ADD(EVL(m.tcClauses,""))
		This._oAliases.ADD(EVL(m.tcAlias,""))
		This._oNames.ADD(EVL(m.tcName,""))
	ENDPROC



	PROCEDURE CallReport(toListener AS REPORTLISTENER, tlKeepHandle)
	
		LOCAL lcReport, lcClauses, lcAlias, lcType, loListener AS REPORTLISTENER

		IF VARTYPE(toListener) = "O"
			m.loListener = m.toListener
		ELSE
			m.loListener = This.oListener
		ENDIF

		IF UPPER(ALLTRIM(SET("Printer", 3))) <> UPPER(This.cPrinterName)
			* MESSAGEBOX("Alterando Impressora para: " + This.cPrinterName)
			This.SetPrinter(This.cPrinterName)
		ENDIF

		* For the case of labels we'll not deal with merged reports
		IF LOWER(JUSTEXT(This._oReports(1))) = "lbx"
			m.loListener.PrintJobName = EVL(This._oNames(1), m.loListener.PrintJobName)

			m.lcReport = This._oReports(1)
			m.lcClauses = This._oClauses(1)
			m.lcAlias = This._oAliases(1)
			IF NOT EMPTY(m.lcAlias)
				SELECT (m.lcAlias)
			ENDIF
			LABEL FORM (m.lcReport) OBJECT m.loListener &lcClauses.
		ELSE
			LOCAL lcUser, N, lnCount
			m.lnCount = This._oReports.COUNT

			FOR m.N = 1 TO m.lnCount

				m.loListener.PrintJobName = JUSTSTEM(EVL(This._oNames(m.n), m.loListener.PrintJobName))

				This._nIndex = m.n
				m.lcType = LOWER(JUSTEXT(This._oReports(m.N)))

				DO CASE
				CASE m.lnCount = 1 OR m.lnCount = m.N
					m.lcUser = ""
				OTHERWISE
					m.lcUser = "NOPAGEEJECT" && + " NORESET"

				ENDCASE
				m.lcReport = This._oReports(m.N)
				m.lcClauses = This._oClauses(m.N)

				m.lcAlias = This._oAliases(m.N)
				IF NOT EMPTY(m.lcAlias)
					SELECT (m.lcAlias)
				ENDIF

				IF m.tlKeepHandle AND PEMSTATUS(m.loListener, "WaitForNextReport", 5) 
					IF m.N = m.lnCount
						m.loListener.WaitForNextReport = .F. && last report, allow closing
					ELSE
						m.loListener.WaitForNextReport = .T.
					ENDIF
				ENDIF

				IF NOT FILE(FORCEEXT(m.lcReport, "FRX"))
					This.SetError(This.GetLoc("REPNOTFOUN") + ": " + m.lcReport)
					RETURN 
				ENDIF

				IF ((NOT This.lUseListener) AND This._lSendToPrinter) ;
						OR (This._lIsDotMatrix) ;
						OR ((NOT This.lUseListener) AND This.lDirectPrint)

					SET REPORTBEHAVIOR 80
					m.lcClauses = CleanClauses(m.lcClauses)

					IF m.lcType = "lbx"
						LABEL FORM (m.lcReport) &lcClauses. &lcUser. TO PRINTER NOCONSOLE
					ELSE
						REPORT FORM (m.lcReport) &lcClauses. &lcUser. TO PRINTER NOCONSOLE
					ENDIF
				ELSE

					IF m.lcType = "lbx"
						LABEL FORM (m.lcReport) OBJECT m.loListener &lcClauses. &lcUser.
					ELSE
						REPORT FORM (m.lcReport) OBJECT m.loListener &lcClauses. &lcUser.
					ENDIF
				ENDIF

			ENDFOR
		ENDIF
	ENDPROC


	PROCEDURE RestorePrinter
		WITH THIS
			IF ALLTRIM(UPPER(._cOriginalPrinter)) <> ALLTRIM(UPPER(SET("Printer",3))) && Current printer
				.SetPrinter(._cOriginalPrinter)
			ENDIF
		ENDWITH
	ENDPROC


	PROCEDURE RunReport
		LPARAMETERS toParent
		IF APRINTERS(gaPrinters) = 0
			This.SetError(This.GetLoc("ERRNOPRINTER"))
			RETURN .F.
		ENDIF

		WITH THIS
			.lPrinted = .F.
			._oCaller = m.toParent

			IF VARTYPE(.oListener) <> "O"
				* Create a PREVIEW listener
				TRY
				
					LOCAL lcListenerClass
					IF This.lCompleteMode
						m.lcListenerClass = This.cDefaultListener
					ELSE 
						m.lcListenerClass = MAIN_LISTENER
					ENDIF 
					
					IF _VFP.StartMode = 0
						.oListener = NEWOBJECT(m.lcListenerClass, GetCurPath() + "PR_ReportListener.vcx")
					ELSE 
						TRY 
							.oListener = NEWOBJECT(m.lcListenerClass, "PR_ReportListener.vcx")
						CATCH 
							.oListener = NEWOBJECT(m.lcListenerClass, "PR_ReportListener.vcx", This.ClassLibrary)
						ENDTRY 
					
					ENDIF 
					
					TRY 
						.oListener.fxFeedbackClass = This._cThermClass
						.oListener.lExpandFields = This.lExpandFields
					CATCH
					ENDTRY 
	
					TRY 
						LOCAL lcSuccessor
						m.lcSuccessor = ALLTRIM(UPPER(.cSuccessor))
						IF NOT INLIST(m.lcSuccessor, "REPORTLISTENER", "_REPORTLISTENER", ;
							"FXLISTENER", "DBFLISTENER", "FULLJUSTIFYLISTENER", "FOXYLISTENER", ;
							MAIN_LISTENER)
							.oListener.Successor = CREATEOBJECT(.cSuccessor)
						ENDIF 
					CATCH
					ENDTRY 

				CATCH TO m.loExc 
					* LOCAL loExc as Exception 

					lcMsg = "SYS(16) : " + SYS(16) + _CRLF + ;
					"GetCurPath() : " + GetCurPath() + _CRLF + ;
					"File('PR_ReportListener.vcx') : " + TRANSFORM(File('PR_ReportListener.vcx')) + ;
					"This.ClassLibrary : " + This.ClassLibrary

					MESSAGEBOX("Error loading FoxyListener!" + _CRLF + ;
						TRANSFORM(m.loExc.ERRORNO) + " - " + m.loExc.MESSAGE + _CRLF + ;
						"Line: " + TRANSFORM(m.loExc.LINENO) + " - " + m.loExc.LINECONTENTS + _CRLF + _CRLF + ;
						lcMsg)
				
					.oListener = NEWOBJECT('FXLISTENER', "PR_ReportListener.vcx")
				ENDTRY
			ENDIF

			IF This.lDirectPrint
				This.oListener.OutputType = 0 && Send to Printer
				IF PEMSTATUS(This.oListener, "lStoreData", 5) 
					This.oListener.lStoreData = .F. && no need to generate the coordinates table
									&& used in the Search feature
				ENDIF 
				This.DoOutput()
				RETURN
			ENDIF 


			* Update the language setting if needed
			IF VARTYPE(This._oLang) <> "O"
				This.SetLanguage(This.cLanguage)
			ENDIF

			IF EMPTY(This.cDestFile)
				.oListener.LISTENERTYPE = 1 && Preview

				LOCAL loPreviewContainer, lcPreviewAPp
				m.loPreviewContainer = NULL
*				m.lcPreviewApp = "ReportPreview.App"
				m.lcPreviewApp = "PR_FRXPreview.Prg"

				TRY
					DO (m.lcPreviewApp) WITH m.loPreviewContainer
				CATCH
					DO (HOME() + m.lcPreviewApp) WITH m.loPreviewContainer
				ENDTRY

				* Create an extension handler and hook it to the
				* preview container. This will let you manipulate
				* properties of the container and its Preview toolbar
				LOCAL loExHandler AS ExtensionHandler OF SYS(16)
				m.loExHandler = NEWOBJECT('ExtensionHandler')
				m.loPreviewContainer.SetExtensionHandler(m.loExHandler)
				This._oExHandler = m.loExHandler

				m.loPreviewContainer.ZoomLevel = This.nZoomLevel
				m.loPreviewContainer.CanvasCount = This.nCanvasCount

				* Link the Listener and preview container
				.oListener.PREVIEWCONTAINER = m.loPreviewContainer

				* Run the report
				.CallReport()
			ENDIF
			IF NOT This._lNoWait
				This.DoOutput()
			ENDIF

			TRY
				.oListener.PREVIEWCONTAINER = NULL
			CATCH
			ENDTRY

		ENDWITH

	ENDPROC


	PROCEDURE DoOutput
		LPARAMETERS tlEmail

		WITH THIS
			LOCAL lcFileFormat
			m.lcFileFormat = ""

			* Prepare the output file
			IF NOT EMPTY(.cDestFile) AND NOT .lSaved
		
				* Check if the fullpath was passed. 
				* If not, add the "cOutputPath" to the file name
				IF NOT "\" $ .cDestFile
					.cDestFile = ALLTRIM(ADDBS(.cOutputPath) + .cDestFile) && by Nick Porfyris [20101124]
				ENDIF
					
				.lSaveToFile = .T.
				m.lcFileFormat = LOWER(JUSTEXT(.cDestFile))

				* 1st step, try to delete a file with the same name
				TRY
					ERASE (.cDestFile)
				CATCH
				ENDTRY

			ENDIF

		ENDWITH


		DO CASE
		CASE This.lSaved

		CASE m.lcFileFormat = "pdf"
			* Using PDFx - by Luis Navas

			LOCAL lnType
			m.lnType = IIF(This.lPDFasImage, 2, 1)
				&& 1 = normal PDF, 2 = Image
			IF m.lnType = 1 THEN && Normal Pdf
				LOCAL loListener AS "PdfListener" OF "PR_PDFx.vcx"
				m.loListener = NEWOBJECT('PdfListener', 'PR_PDFx.vcx')
				m.loListener.cCodePage  = This.cCodePage &&CodePage
				m.loListener.lEmbedFont = This.lPDFEmbedFonts
				m.loListener.cSymbolFontsList = This.cPDFSymbolFontsList
				m.loListener.cDefaultFont     = This.cPDFDefaultFont
				m.loListener.lReplaceFonts    = This.lPdfReplaceFonts
			ELSE &&PDF As Image
				LOCAL loListener AS "PDFasImageListener" OF "PR_Pdfx.vcx"
				m.loListener = NEWOBJECT("PDFasImageListener", "PR_PDFx.vcx")
			ENDIF

			m.loListener.cTargetFileName  = ALLTRIM(This.cDestFile)
			m.loListener.QUIETMODE        = This.lQuietMode
			m.loListener.fxFeedbackClass  = This._cThermClass
			m.loListener.lCanPrint        = This.lPDFCanPrint
			m.loListener.lCanEdit         = This.lPDFCanEdit
			m.loListener.lCanCopy         = This.lPDFCanCopy
			m.loListener.lCanAddNotes     = This.lPDFCanAddNotes
			m.loListener.lEncryptDocument = This.lPDFEncryptDocument
			m.loListener.cMasterPassword  = This.cPDFMasterPassword
			m.loListener.cUserPassword    = This.cPDFUserPassword

			m.loListener.lShowErrors      = This.lPDFShowErrors
			m.loListener.cPdfAuthor       = This.cPdfAuthor
			m.loListener.cPdfTitle        = This.cPdfTitle
			m.loListener.cPdfSubject      = This.cPdfSubject
			m.loListener.cPdfKeyWords     = This.cPdfKeyWords
			m.loListener.cPdfCreator      = This.cPdfCreator

			m.loListener.lOpenViewer      = .F.
			* by Luis Navas - To be Developed, not ready yet
			* loListener.MergeDocument=.MergeDocument.Value
			* loListener.MergeDocumentName=.MergeFileName.Value
			LOCAL lnPgMode
			m.lnPgMode = MAX(This.nPDFPageMode - 1, 0)
			m.lnPgMode = IIF(m.lnPgMode = 1, 2, m.lnPgMode)
			m.loListener.nPageMode = m.lnPgMode

*			loListener.nPageMode = MAX(This.nPDFPageMode - 1, 0)

			IF This.lCompleteMode
				m.loListener.lDefaultMode = .T.
				This.CallReport(m.loListener, .T.) && flag to keep opened till last report
			ELSE && Generate PDF from the offline table
				LOCAL lcFullOutputAlias, lnWidth, lnHeight
				m.lcFullOutputAlias = This.oListener.GetFullFRXData()
				m.lnWidth  = This.oListener.GETPAGEWIDTH()
				m.lnHeight = This.oListener.GETPAGEHEIGHT()
				m.loListener.OutputFromData(This.oListener, m.lcFullOutputAlias, m.lnWidth, m.lnHeight)
			ENDIF 

			m.loListener = NULL

			IF NOT FILE(This.cDestFile)
				This.SetError(This.GetLoc("ERR_CREATI"))
			ELSE
				This.lSaved = .T.
			ENDIF


		CASE INLIST(m.lcFileFormat, "htm", "html")

			* loListener2 = NewObject("pr_UtilityReportListener", "PR_ReportListener.vcx")
			* loListener2.ListenerType = 5
			* loListener2.TargetFileName = This.cDestFile
			* This.CallReport(loListener2)
			* loListener2 = NULL

			* Check if the MSXML4 component is installed 
			* so that we can initialize the HTML Listener
			LOCAL llError, loTestXML4
			m.llError = .F.
			TRY 
				m.loTestXML4  = CREATEOBJECT("MSXML2.XSLTEMPLATE.4.0")
			CATCH
				m.llError = .T.
				This.SetError(This.GetLoc("ERR_CREATI") + _CRLF + "The MSXML4.0 library could not be loaded. Please check if it was properly installed.")
			ENDTRY 
			m.loTestXML4 = NULL

			IF NOT m.llError
				DEFINE WINDOW Window_HTML FROM 04,05 TO 27,75
				ACTIVATE WINDOW Window_HTML NOSHOW

				LOCAL loListener AS "HTMLListener" && OF HOME() + "FFC/PR_ReportListener.vcx"
				m.loListener = NEWOBJECT("PR_HTMLListener", "PR_ReportListener.vcx")
				m.loListener.TargetFileName = This.cDestFile
				m.loListener.QUIETMODE = This.lQuietMode
				m.loListener.fxFeedbackClass = This._cThermClass

				m.loListener.CopyImageFilesToExternalFileLocation = .T.	&& 2011-08-12 - Jacques Parent - Copy image to HTML output dir so the created HTML will
																		** always access images from his currect directory 

				* Run the report
				This.CallReport(m.loListener)
				m.loListener = NULL

				RELEASE WINDOWS Window_HTML

				IF NOT FILE(This.cDestFile)
					This.SetError(This.GetLoc("ERR_CREATI"))
				ELSE
					This.lSaved = .T.
				ENDIF
			ENDIF 

		CASE INLIST(m.lcFileFormat, "rtf", "doc")
			* Using fixed and updated RTFListener by Vladimir Zhuravlev

			m.loRtfListener = NEWOBJECT("RTFreportlistener", "PR_RTFListener")
			m.loRtfListener.TargetFileName = This.cDestFile
			m.loRtfListener.fxFeedbackClass = This._cThermClass

			IF This.lCompleteMode		
				This.CallReport(m.loRtfListener, .T.) && flag to keep opened till last report
			ELSE && Generate PDF from the offline table
				LOCAL lcOutputAlias, lnWidth, lnHeight
				m.lcOutputAlias = This.oListener.GetFullFRXData()
				m.lnWidth  = This.oListener.GETPAGEWIDTH()
				m.lnHeight = This.oListener.GETPAGEHEIGHT()
				m.loRtfListener.OutputFromData(This.oListener, m.lcOutputAlias, m.lnWidth, m.lnHeight)
			ENDIF 

			m.loRtfListener = NULL

			IF NOT FILE(This.cDestFile)
				This.SetError(This.GetLoc("ERR_CREATI"))
			ELSE
				This.lSaved = .T.
			ENDIF


		CASE INLIST(m.lcFileFormat, "xls", "xml")
			LOCAL loReportListener AS "ExcelListener" && OF HOME() + "FFC/PR_ReportListener.vcx"
			m.loReportListener = NEWOBJECT("ExcelListener","pr_ExcelListener.vcx")
			m.loReportListener.LISTENERTYPE    = 3	&& ?
			m.loReportListener.lOutputToCursor = .T.
			m.loReportListener.cWorkbookFile   = This.cDestFile
			m.loReportListener.cWorksheetName  = "Sheet"
			m.loReportListener.QUIETMODE       = This.lQuietMode
			m.loReportListener.fxFeedbackClass = This._cThermClass
			m.loReportListener.cCodePage       = This.cCodePage

			m.loReportListener.lConvertToXLS   = This.lExcelConvertToXLS  
			m.loReportListener.lRepeatHeaders  = This.lExcelRepeatHeaders
			m.loReportListener.lRepeatFooters  = This.lExcelRepeatFooters
			m.loReportListener.lHidePageNo     = This.lExcelHidePageNo
			m.loReportListener.lAlignLeft      = This.lExcelAlignLeft
			m.loReportListener.nExcelSaveFormat = This.nExcelSaveFormat

			This.CallReport(m.loReportListener, .F.) && flag to keep opened till last report
			m.loReportListener = NULL

			IF NOT FILE(This.cDestFile)
				This.SetError(This.GetLoc("ERR_CREATI"))
			ELSE
				This.lSaved = .T.
			ENDIF


		CASE INLIST(m.lcFileFormat, "txt") && 11/08/2010 by mauriciobraga@ig.com.br

			SET REPORTBEHAVIOR 80
			* _ASCIIROWS = nLines
			* _ASCIICOLS = nChars
			REPORT FORM (This._oReports(1)) TO FILE (This.cDestFile) ASCII
			SET REPORTBEHAVIOR 90

			IF NOT FILE(This.cDestFile)
				This.SetError(This.GetLoc("ERR_CREATI"))
			ELSE
				This.lSaved = .T.
			ENDIF


		CASE INLIST(m.lcFileFormat, "csv", "xl5") && 11/08/2010 by mauriciobraga@ig.com.br

			* Adjust xl5 format to XLS
			IF m.lcFileFormat = "xl5"
				This.cDestFile = FORCEEXT(This.cDestFile, "xls")
			ENDIF

			LOCAL loReportListener AS REPORTLISTENER
			m.loReportListener = CREATEOBJECT("ExportListener")
			m.loReportListener.cDestFile = This.cDestFile

			REPORT FORM (This._oReports(1)) OBJECT m.loReportListener
			m.loReportListener = NULL

			IF NOT FILE(This.cDestFile)
				This.SetError(This.GetLoc("ERR_CREATI"))
			ELSE
				This.lSaved = .T.
			ENDIF


		CASE INLIST(m.lcFileFormat, "png", "bmp", "jpg", "jpeg", "gif", "tif", "tiff", "emf")

			LOCAL loListener AS ReportListener
			m.loListener = NEWOBJECT("FOXYLISTENER", "PR_ReportListener.vcx")

			m.loListener.QUIETMODE = This.lQuietMode
			m.loListener.fxFeedbackClass = This._cThermClass
			m.loListener.ListenerType = 3

			This.CallReport(m.loListener, .T.) && flag to keep opened till last report

			This.lSaved = Report2Pic(m.loListener, This.cDestFile, JUSTEXT(This.cDestFile))
			m.loListener = NULL

			IF NOT This.lSaved
				This.SetError(This.GetLoc("ERR_CREATI"))
			ENDIF


		CASE This.lDirectPrint

			* MESSAGEBOX("Default: " + This._cOriginalPrinter + _CRLF + ;
				"Selected: " + This.cPrinterName)

			FOR m.N = 1 TO This.nCopies
				This.CallReport()
			ENDFOR
			This.lPrinted = .T.
			This.RestorePrinter()


		CASE This._lSendToPrinter

			TRY
				IF _VFP.StartMode = 0
					m.loListener = NEWOBJECT(MAIN_LISTENER, GetCurPath() + "PR_ReportListener.vcx")
				ELSE 
					TRY
						m.loListener = NEWOBJECT(MAIN_LISTENER, "PR_ReportListener.vcx")
					CATCH 
						m.loListener = NEWOBJECT(MAIN_LISTENER, "PR_ReportListener.vcx", This.ClassLibrary)
					ENDTRY 
				ENDIF 
				m.loListener.fxFeedbackClass = This._cThermClass

				TRY 
					LOCAL lcSuccessor
					m.lcSuccessor = ALLTRIM(UPPER(.cDefaultListener))
					IF NOT INLIST(m.lcSuccessor, "REPORTLISTENER", "_REPORTLISTENER", ;
						"FXLISTENER", "DBFLISTENER", "FULLJUSTIFYLISTENER", "FOXYLISTENER", ;
						MAIN_LISTENER)
						m.loListener.Successor = CREATEOBJECT(This.cDefaultListener)
					ENDIF
				CATCH TO m.loExc
					IF ISDEBUGGING
						SET STEP ON 
					ENDIF 
					m.loListener = NEWOBJECT('FXLISTENER', "PR_ReportListener.vcx")
				ENDTRY 

				m.loListener.LISTENERTYPE = 0 && Printer Output
				m.loListener.QUIETMODE = This.lQuietMode

*!*				IF This._ClausenPrintRangeFrom > 0
*!*					loListener.CommandClauses.PrintRangeFrom = This._ClausenPrintRangeFrom
*!*					loListener.CommandClauses.PrintRangeTo   = This._ClausenPrintRangeTo
*!*				ENDIF

				FOR m.N = 1 TO This.nCopies
					This.CallReport(m.loListener)
				ENDFOR

				This.lPrinted = .T.
				This.RestorePrinter()

			CATCH TO loException
				IF ISDEBUGGING
					SET STEP ON 
				ENDIF 
			ENDTRY

		OTHERWISE

		ENDCASE

		IF This._lSendingEmail OR This.lAutoSendMail = .T. && lEmailAuto
			This.SendReportToEmail()
		ENDIF 

		* Restore the default directory
		SET DEFAULT TO (This._cDefaultFolder)

		IF This.lOpenViewer AND ;
				This.lSaved AND ;
				(This._lSendingEmail = .F.) AND ;
				(This._lAlreadyOpened = .F.)
			This.OpenFile(This.cDestFile)
		ENDIF

		This.ReportReleased()

	ENDPROC


	PROCEDURE SendReportToEmail

		* Update the "cDestFile" property
		IF VARTYPE(_Screen.oFoxyPreviewer) = "O"
			This.cDestFile = NVL(_Screen.oFoxyPreviewer.cDestFile, This.cDestFile)
			This.cEmailPRG = NVL(_Screen.oFoxyPreviewer.cEmailPRG, This.cEmailPRG)
			This.nEmailMode = NVL(_Screen.oFoxyPreviewer.nEmailMode, This.nEmailMode)
		ENDIF 

		IF NOT FILE(This.cDestFile)
			This.SetError(This.GetLoc("ERR_CREATI"))
		ELSE

		* nEmailMode && 1 = MAPI, 2 = CDOSYS, 4 = Custom PROCEDURE
			This.lEmailed = .T.

			TRY
				DO CASE
				CASE (This.nEmailMode = 4) AND (NOT EMPTY(This.cEmailPRG))&& Custom PROCEDURE
					DO (This.cEmailPRG) WITH (This.cDestFile)	&&, This.lAutoSendMail

				CASE INLIST(This.nEmailMode, 2, 3) OR This.lAutoSendMail && lEmailAuto && CDOSYS
					DO SendCDOMail WITH (This.cDestFile), This.lAutoSendMail

				CASE This.nEmailMode = 1 && MAPI
					This.lEmailed = PR_SendMailEx(This.cDestFile)	&&, This.lAutoSendMail

				CASE This.nEmailMode = 5 && MAPI2
					LOCAL hWindow, lcDelimiter, lcFiles, lcMsgSubj, lnMAPIReturn
					hWindow = PR_GetActiveWindow()
					lcDelimiter = ";"
					lcMsgSubj = JUSTFNAME(This.cDestFile)
					
					* http://msdn.microsoft.com/en-us/library/windows/desktop/dd296731(v=vs.85).aspx
					lnMAPIReturn = PR_MAPISendDocuments (hWindow, lcDelimiter, (This.cDestFile), lcMsgSubj, 0)
					IF lnMAPIReturn <> SUCCESS_SUCCESS
						=PR_MAPIShowMessage(lnMAPIReturn)
						This.lEmailed = .F.
					ENDIF
					* Restore the default directory
					SET DEFAULT TO (This._cDefaultFolder)

				OTHERWISE
					This.SetError(This.GetLoc("BADCONFIG"))
					This.lEmailed = .F.

				ENDCASE
			CATCH TO loMailEx
				MESSAGEBOX(This.GetLoc("ERRSENDMAI") + _CRLF + ;
					This.GetLoc("MSGNOTSENT"), 16, This.GetLoc("ERROR"))
				This.lEmailed = .F.
				IF ISDEBUGGING
					SET STEP ON 
				ENDIF 
			ENDTRY

		*	lEmailAuto = .T. && Automatically generates the report output file
		*	cEmailType = "PDF" && The file type to be used in Emails (PDF, RTF, HTML or XLS)
			IF This.lEmailAuto
				TRY
					DELETE FILE (This.cDestFile)
				CATCH
				ENDTRY
				This.lSaved = .F.
			ENDIF
			This._lSendingEmail = .F.
		ENDIF
ENDPROC 



	PROCEDURE ReportReleased
		LPARAMETERS toExt

		TRY 
			This.oListener.EraseTempFiles()
			This.oListener = ""
		CATCH 
		ENDTRY 

		UNBINDEVENTS(THIS)
		IF VARTYPE(m.toExt) = "O"
			m.toExt = NULL
		ENDIF

		* if changed, restore the printer to the original
		IF ALLTRIM(UPPER(This._cOriginalPrinter)) <> ALLTRIM(UPPER(This.cPrinterName))
			This.SetPrinter(This._cOriginalPrinter)
		ENDIF

		This.CloseSheets()

		* Restore the default folder if needed
		IF (VARTYPE(_goFP) = "O") AND (SET("Default") + SYS(2003)) <> This._cDefaultFolder
			SET DEFAULT TO (This._cDefaultFolder)
		ENDIF
		This.ClearCache()

		RELEASE _goFP
		This.Destroy()
	ENDPROC


	PROCEDURE ClearCache

		* Trying to clear the report preview cache
		* If there is another Preview factory, disable it
		* http://spacefold.com/colin/archive/articles/reportpreview/rp_extend.html

		TRY
			_oReportOutput["1"].PREVIEWCONTAINER = .NULL.
			* _oReportOutput.Remove("1")
		CATCH TO m.loExc
			* LOCAL loexc as Exception
			* MESSAGEBOX("Error: " + TRANSFORM(loexc.ErrorNo) + " - " + loexc.Message, 16, "Error")
		ENDTRY

	ENDPROC


	PROCEDURE SetPrinter
		LPARAMETERS tcPrinterName
		LOCAL lcPrinter, llReturn
		m.llReturn  = .T.
		m.lcPrinter = m.tcPrinterName
		LOCAL loExc as Exception 
		TRY
			SET PRINTER TO NAME '&lcPrinter'
		CATCH TO m.loExc
			IF ISDEBUGGING
				SET STEP ON 
			ENDIF 
			This.SetError("Could not change the current printer." + _CRLF + ;
				"Current Printer: " + SET("Printer", 3) + _CRLF + ;
				"Failed Printer: " + m.tcPrinterName)
			m.llReturn = .F.
		ENDTRY
		RETURN m.llReturn
	ENDPROC

ENDDEFINE && PreviewHelper



*-------------------------
DEFINE CLASS ExtensionHandler AS CUSTOM
*-- Ref to the Preview Container's Preview Form
	PreviewForm    = NULL
	lHighlightText = .F.
	_CreatingCanvases = .F.

	IMGBTN_PREV		 = "pr_previous.bmp"
	IMGBTN_NEXT		 = "pr_next.bmp"
	IMGBTN_TOP		 = "pr_top.bmp"
	IMGBTN_BOTT		 = "pr_bottom.bmp"
	IMGBTN_MINI		 = "pr_Locate.bmp"
	IMGBTN_PRINT	 = "pr_Print.bmp"
	IMGBTN_PRINTPREF = "pr_PrintPref.bmp"
	IMGBTN_GOTOPG	 = "pr_gotopage.bmp"
	IMGBTN_1PG		 = "pr_1page.bmp"
	IMGBTN_2PG		 = "pr_2page.bmp"
	IMGBTN_4PG		 = "pr_4page.bmp"
	IMGBTN_CLOSE	 = "pr_close.bmp"
	IMGBTN_CLOSE2	 = "pr_close2.bmp"
	IMGBTN_SAVE		 = "pr_Save.bmp"
	IMGBTN_EMAIL	 = "pr_Mail.bmp"
	IMGBTN_SETUP	 = "pr_Gear.bmp"
	IMGBTN_SEARCH	 = "pr_Search.bmp"
	IMGBTN_SEARCHAGAIN = "pr_SearchAgain.bmp"
	IMGBTN_SEARCHBACK  = "pr_SearchBack.bmp"


	PROCEDURE STB_Handler(lEnabled)
* Here you work around the setting
* persistence problem in the Preview toolbar.
* The Preview toolbar class (frxpreviewtoolbar)
* already has code that you can use to enforce
* setting's persistence; it is just not called. Here,
* you call it.
		WITH This.PreviewForm.TOOLBAR
			.REFRESH()
* When you call frxpreviewtoolbar::REFRESH(), the
* toolbar caption is set to its Preview form,
* which differs from typical behavior. You must revert that
* to be consistent. If you did not do this,
* you would see " - Page 2" appended to the toolbar
* caption if you skipped pages.
			.CAPTION = This.PreviewForm.formCaption
		ENDWITH
	ENDPROC


	PROCEDURE AddBarsToMenu
		LPARAMETERS cPopup, iNextBar
		* RELEASE BAR 8 OF (m.cPopup)

		DEFINE BAR 1 OF (m.cPopup) PROMPT _goFP.GetLoc("MENUTOP")   PICTURE This.IMGBTN_TOP
		DEFINE BAR 2 OF (m.cPopup) PROMPT _goFP.GetLoc("MENUPREV")  PICTURE This.IMGBTN_PREV
		DEFINE BAR 3 OF (m.cPopup) PROMPT _goFP.GetLoc("MENUNEXT")  PICTURE This.IMGBTN_NEXT
		DEFINE BAR 4 OF (m.cPopup) PROMPT _goFP.GetLoc("MENULAST")  PICTURE This.IMGBTN_BOTT
		DEFINE BAR 5 OF (m.cPopup) PROMPT _goFP.GetLoc("MENUGOTO")  PICTURE This.IMGBTN_GOTOPG

		IF _goFP.lShowPageCount
			DEFINE BAR 8 OF (m.cPopup) PROMPT _goFP.GetLoc("MENUSHOWPA")
		ELSE 
			TRY 
				RELEASE BAR 8 OF (m.cPopup)
			CATCH 
			ENDTRY 
		ENDIF

		DEFINE BAR 10 OF (m.cPopup) PROMPT _goFP.GetLoc("MENUTOOLB")

		* Release the original Exit option (we'll add it further, to force it to the bottom of the list)
		TRY 
			RELEASE BAR 13 OF (m.cPopup)
		CATCH 
		ENDTRY 
*		DEFINE BAR 13 OF (m.cPopup) PROMPT _goFP.GetLoc("MENUCLOSE")  PICTURE This.IMGBTN_CLOSE

		IF NOT EMPTY(_goFP.GetLoc("CBOZOOMTTI"))
			DEFINE BAR 7 OF (m.cPopup) PROMPT _goFP.GetLoc("CBOZOOMTTI")
		ENDIF


		ON SELECTION BAR 5 OF (m.cPopup) ;
			m.oRef.ExtensionHandler.ActionGotoPage()

*		ON SELECTION BAR 13 OF (m.cPopup) ;
			m.oRef.ExtensionHandler.ActionClose()

		ON SELECTION BAR 10 OF (m.cPopup) m.oRef.ExtensionHandler.actionToolbarVisibility()




		* Show miniatures
		IF _goFP.lShowMiniatures

			DEFINE BAR 21 ;
				OF (m.cPopup) ;
				PROMPT _goFP.GetLoc("MENUPROOF") ;
				PICTURE This.IMGBTN_MINI

			* It is a documented fact that, at the time
			* the popup is activated, there is an object
			* reference to the PreviewContainer instance
			* in scope in a variable called "oRef":
			ON SELECTION BAR 21 OF (m.cPopup) ;
				m.oRef.ExtensionHandler.DoProof()
		ENDIF


		* Show Search buttons
		IF _goFP._lCanSearch AND _goFP.lShowSearch
		
*!*				IF NOT _goFP.lShowMiniatures
*!*					DEFINE BAR 24 OF (m.cPopup) PROMPT '\-'
*!*				ENDIF 

			DEFINE BAR 25 ;
				OF (m.cPopup) ;
				PROMPT _goFP.GetLoc("FIND") ;
				PICTURE This.IMGBTN_SEARCH

			ON SELECTION BAR 25 OF (m.cPopup) ;
				m.oRef.ExtensionHandler.DoSearch()


			IF _goFP._lShowSearchAgain
				DEFINE BAR 26 ;
					OF (m.cPopup) ;
					PROMPT _goFP.GetLoc("FINDBACK") ;
					PICTURE This.IMGBTN_SEARCHBACK

				DEFINE BAR 27 ;
					OF (m.cPopup) ;
					PROMPT _goFP.GetLoc("FINDNEXT") ;
					PICTURE This.IMGBTN_SEARCHAGAIN

				ON SELECTION BAR 26 OF (m.cPopup) ;
					m.oRef.ExtensionHandler.DoSearchBack()

				ON SELECTION BAR 27 OF (m.cPopup) ;
					m.oRef.ExtensionHandler.DoSearchAgain()
			ENDIF 

			DEFINE BAR 24 OF (m.cPopup) PROMPT '\-'

		ENDIF







		IF _goFP.lPrintVisible

			* Save to file item
			IF _goFP.lSaveToFile
				DEFINE BAR 17 ;
					OF (m.cPopup) ;
					PROMPT _goFP.GetLoc("SAVEREPORT") ;
					PICTURE This.IMGBTN_SAVE

				LOCAL lcSaveMenu
				m.lcSaveMenu = SYS(2015)

				DEFINE POPUP (m.lcSaveMenu) SHORTCUT RELATIVE

				IF NOT _goFP.lCompleteMode && Original report

					* If the report is "Searchable", show the submenu
					* Otherwise, allow only to save as image
					IF _goFP._lCanSearch
						ON BAR 17 OF (m.cPopup) ACTIVATE POPUP &lcSaveMenu.
					
						* 2012-08-17 allow omitting the file type icons
						IF _goFP.lShowFileFormatIcons
	
							IF _goFP.lSaveAsImage
								DEFINE BAR 1 OF (m.lcSaveMenu) PROMPT _goFP.GetLoc("SAVEASIMAG") PICTURE "pr_Img.bmp"
								ON SELECTION BAR 1 OF (m.lcSaveMenu) m.oRef.ExtensionHandler.DoSaveType(1)
							ENDIF
							IF _goFP.lSaveAsPDF
								DEFINE BAR 2 OF (m.lcSaveMenu) PROMPT _goFP.GetLoc("SAVEASPDF")  PICTURE "pr_Pdf.bmp"
								ON SELECTION BAR 2 OF (m.lcSaveMenu) m.oRef.ExtensionHandler.DoSaveType(2)
							ENDIF
							IF _goFP.lSaveAsRTF
								DEFINE BAR 5 OF (m.lcSaveMenu) PROMPT _goFP.GetLoc("SAVEASRTF")  PICTURE "pr_Word.bmp"
								ON SELECTION BAR 5 OF (m.lcSaveMenu) m.oRef.ExtensionHandler.DoSaveType(4)
							ENDIF
							IF _goFP.lSaveAsXLS
								DEFINE BAR 6 OF (m.lcSaveMenu) PROMPT _goFP.GetLoc("SAVEASXLS")  PICTURE "pr_Excel.bmp"
								ON SELECTION BAR 6 OF (m.lcSaveMenu) m.oRef.ExtensionHandler.DoSaveType(5)
							ENDIF
							IF _goFP.lSaveAsHTML
								DEFINE BAR 3 OF (m.lcSaveMenu) PROMPT _goFP.GetLoc("SAVEASHTML") PICTURE "pr_Html.bmp"
								ON SELECTION BAR 3 OF (m.lcSaveMenu) m.oRef.ExtensionHandler.DoSaveType(3)
							ENDIF
							IF _goFP.lSaveAsMHT AND (_goFP.lCompleteMode = .F.)
								DEFINE BAR 4 OF (m.lcSaveMenu) PROMPT _goFP.GetLoc("SAVEASMHT") PICTURE "pr_MHT.bmp"
								ON SELECTION BAR 4 OF (m.lcSaveMenu) m.oRef.ExtensionHandler.DoSaveType(8)
							ENDIF
	
						ELSE 
						
							IF _goFP.lSaveAsImage
								DEFINE BAR 1 OF (m.lcSaveMenu) PROMPT _goFP.GetLoc("SAVEASIMAG")
								ON SELECTION BAR 1 OF (m.lcSaveMenu) m.oRef.ExtensionHandler.DoSaveType(1)
							ENDIF
							IF _goFP.lSaveAsPDF
								DEFINE BAR 2 OF (m.lcSaveMenu) PROMPT _goFP.GetLoc("SAVEASPDF")
								ON SELECTION BAR 2 OF (m.lcSaveMenu) m.oRef.ExtensionHandler.DoSaveType(2)
							ENDIF
							IF _goFP.lSaveAsRTF
								DEFINE BAR 5 OF (m.lcSaveMenu) PROMPT _goFP.GetLoc("SAVEASRTF")
								ON SELECTION BAR 5 OF (m.lcSaveMenu) m.oRef.ExtensionHandler.DoSaveType(4)
							ENDIF
							IF _goFP.lSaveAsXLS
								DEFINE BAR 6 OF (m.lcSaveMenu) PROMPT _goFP.GetLoc("SAVEASXLS")
								ON SELECTION BAR 6 OF (m.lcSaveMenu) m.oRef.ExtensionHandler.DoSaveType(5)
							ENDIF
							IF _goFP.lSaveAsHTML
								DEFINE BAR 3 OF (m.lcSaveMenu) PROMPT _goFP.GetLoc("SAVEASHTML")
								ON SELECTION BAR 3 OF (m.lcSaveMenu) m.oRef.ExtensionHandler.DoSaveType(3)
							ENDIF
							IF _goFP.lSaveAsMHT AND (_goFP.lCompleteMode = .F.)
								DEFINE BAR 4 OF (m.lcSaveMenu) PROMPT _goFP.GetLoc("SAVEASMHT")
								ON SELECTION BAR 4 OF (m.lcSaveMenu) m.oRef.ExtensionHandler.DoSaveType(8)
							ENDIF
					ENDIF 


					ELSE 
						ON SELECTION BAR 17 OF (m.cPopup) ;
								m.oRef.ExtensionHandler.DoSaveType(1)
					ENDIF 
				ELSE

					ON BAR 17 OF (m.cPopup) ACTIVATE POPUP &lcSaveMenu.

					IF _goFP.lSaveAsImage
						DEFINE BAR 1 OF (m.lcSaveMenu) PROMPT _goFP.GetLoc("SAVEASIMAG") PICTURE "pr_Img.bmp"
						ON SELECTION BAR 1 OF (m.lcSaveMenu) m.oRef.ExtensionHandler.DoSaveType(1)
					ENDIF
					IF _goFP.lSaveAsPDF
						DEFINE BAR 2 OF (m.lcSaveMenu) PROMPT _goFP.GetLoc("SAVEASPDF")  PICTURE "pr_Pdf.bmp"
						ON SELECTION BAR 2 OF (m.lcSaveMenu) m.oRef.ExtensionHandler.DoSaveType(2)
					ENDIF
					IF _goFP.lSaveAsHTML
						DEFINE BAR 3 OF (m.lcSaveMenu) PROMPT _goFP.GetLoc("SAVEASHTML") PICTURE "pr_Html.bmp"
						ON SELECTION BAR 3 OF (m.lcSaveMenu) m.oRef.ExtensionHandler.DoSaveType(3)
					ENDIF

					IF _goFP.lSaveAsMHT AND (_goFP.lCompleteMode = .F.)
						DEFINE BAR 4 OF (m.lcSaveMenu) PROMPT _goFP.GetLoc("SAVEASMHT") PICTURE "pr_MHT.bmp"
						ON SELECTION BAR 4 OF (m.lcSaveMenu) m.oRef.ExtensionHandler.DoSaveType(8)
					ENDIF

					IF _goFP.lSaveAsRTF
						DEFINE BAR 5 OF (m.lcSaveMenu) PROMPT _goFP.GetLoc("SAVEASRTF")  PICTURE "pr_Word.bmp"
						ON SELECTION BAR 5 OF (m.lcSaveMenu) m.oRef.ExtensionHandler.DoSaveType(4)
					ENDIF
					IF _goFP.lSaveAsXLS
						DEFINE BAR 6 OF (m.lcSaveMenu) PROMPT _goFP.GetLoc("SAVEASXLS")  PICTURE "pr_Excel.bmp"
						ON SELECTION BAR 6 OF (m.lcSaveMenu) m.oRef.ExtensionHandler.DoSaveType(5)
					ENDIF

					IF _goFP.lSaveasTXT && Create menu option Save as TXT && 11/08/2010 by mauriciobraga@ig.com.br
						DEFINE BAR 7 OF (m.lcSaveMenu) PROMPT _goFP.GetLoc("SAVEASTXT")  PICTURE "pr_1page.bmp"
						ON SELECTION BAR 7 OF (m.lcSaveMenu) m.oRef.ExtensionHandler.DoSaveType(6)
					ENDIF
				ENDIF

			ENDIF

			* Show the Send to email item
			IF _goFP.lSendToEmail
*			DEFINE BAR 22 OF (m.cPopup) PROMPT '\-'
				DEFINE BAR 19 ;
					OF (m.cPopup) ;
					PROMPT _goFP.GetLoc("SENDTOEMAI") ;
					PICTURE This.IMGBTN_EMAIL

				ON SELECTION BAR 19 OF (m.cPopup) ;
					m.oRef.ExtensionHandler.DoSendEmail()
			ENDIF 

			* Printing preferences item
			IF _goFP.lPrinterPref
				LOCAL lcImgPrintPref
				m.lcImgPrintPref = This.IMGBTN_PRINTPREF
				DEFINE BAR 16 ;
					OF (m.cPopup) ;
					PROMPT _goFP.GetLoc("PRINTINGPR") PICTURE m.lcImgPrintPref

				ON SELECTION BAR 16 OF (m.cPopup) ;
					m.oRef.ExtensionHandler.DoCustomPrint()
			ENDIF

			IF _goFP.lShowPrintBtn
				DEFINE BAR 15 ;
					OF (m.cPopup) ;
					PROMPT _goFP.GetLoc("MENUPRINT") ;
					PICTURE This.IMGBTN_PRINT

				ON SELECTION BAR 15 OF (m.cPopup) ;
					m.oRef.ExtensionHandler.ActionPrintEx()
			ENDIF

		ENDIF


		* Show Setup
		IF _goFP.lShowSetup
			DEFINE BAR 22 OF (m.cPopup) PROMPT '\-'
			DEFINE BAR 23 ;
				OF (m.cPopup) ;
				PROMPT _goFP.GetLoc("SETUP") ;
				PICTURE This.IMGBTN_SETUP

			ON SELECTION BAR 23 OF (m.cPopup) ;
				m.oRef.ExtensionHandler.DoSetup()
		ENDIF


		* Exit
		IF _goFP.lShowClose
			DEFINE BAR 28 OF (m.cPopup) PROMPT '\-'
			DEFINE BAR 29 ;
				OF (m.cPopup) ;
				PROMPT _goFP.GetLoc("MENUCLOSE") ;
				PICTURE This.IMGBTN_CLOSE

			ON SELECTION BAR 29 OF (m.cPopup) ;
				m.oRef.ExtensionHandler.ActionClose()
		ENDIF




		* Translating the Zoom and Page menu items for non English users
		IF UPPER(_goFP.GetLoc("LANGUAGE")) <> "ENGLISH"

			PRIVATE lcZoom2, lcPages2
			lcZoom2  = SYS(2015)
			lcPages2 = SYS(2015)
			ON BAR 7 OF (m.cPopup) ACTIVATE POPUP &lcZoom2
	
			IF _goFP.lShowPageCount
				ON BAR 8 OF (m.cPopup) ACTIVATE POPUP &lcPages2
			ENDIF
*------------------------------------------------------
* Define the Zoom popup:
* slightly adapted from the Report Preview project
* the author of this piece of code is MS, (Lisa Slater Nicholls)
* code extracted from the XSource.Zip file
*------------------------------------------------------
			DEFINE POPUP (m.lcZoom2) SHORTCUT RELATIVE

* Loop through all the array items, in case user is using a modified
* context menu (Joao Batista)
* oRef.ZoomLevels(10,1) = PR_CBOZOOMWHO
* oRef.ZoomLevels(11,1) = PR_CBOZOOMPGW

			LOCAL lcItem, i
			FOR m.i = 1 TO ALEN(m.oRef.ZoomLevels, 1) && Rows
				m.lcItem = LOWER(m.oRef.ZoomLevels(m.i, 1))
				IF (m.lcItem = "whole page") OR (m.i = 10)
					m.oRef.ZoomLevels(m.i, 1) = _goFP.GetLoc("CBOZOOMWHO")
				ENDIF
				IF (m.lcItem = "fit to width") OR (m.i = 11)
					m.oRef.ZoomLevels(m.i, 1) = _goFP.GetLoc("CBOZOOMPGW")
				ENDIF
			ENDFOR

			FOR m.i = 1 TO ALEN(m.oRef.ZoomLevels,1)
				DEFINE BAR m.i OF(m.lcZoom2) PROMPT m.oRef.ZoomLevels[m.i,1] && ZOOM_LEVEL_PROMPT
				ON SELECTION BAR m.i OF (m.lcZoom2) m.oRef.actionSetZoom( BAR() )
			ENDFOR
			* Set the mark:
			SET MARK OF BAR (m.oRef.ZoomLevel) OF (m.lcZoom2) TO .T.


			IF _goFP.lShowPageCount
				*------------------------------------------------------
				* Define the Page Count popup:
				*------------------------------------------------------
				DEFINE POPUP (m.lcPages2) SHORTCUT RELATIVE
				DEFINE BAR 1 OF (m.lcPages2) PROMPT _goFP.GetLoc("ONEPGMENU")

				* Disable multi-page view for high zoom levels:
				LOCAL iPagesAllowed
				m.iPagesAllowed = m.oRef.ZoomLevels[ m.oRef.zoomLevel, 3 ] && ZOOM_LEVEL_CANVAS
	
				IF m.iPagesAllowed > 1
					DEFINE BAR 2 OF (m.lcPages2) PROMPT _goFP.GetLoc("TWOPGMENU")
				ELSE
					DEFINE BAR 2 OF (m.lcPages2) PROMPT "\" + _goFP.GetLoc("TWOPGMENU")
				ENDIF
				IF m.iPagesAllowed > 2
					DEFINE BAR 3 OF (m.lcPages2) PROMPT _goFP.GetLoc("FOURPGMENU")
				ELSE
					DEFINE BAR 3 OF (m.lcPages2) PROMPT "\" + _goFP.GetLoc("FOURPGMENU")
				ENDIF

				ON SELECTION BAR 1 OF (m.lcPages2) m.oRef.actionSetCanvasCount(1)
				ON SELECTION BAR 2 OF (m.lcPages2) m.oRef.actionSetCanvasCount(2)
				ON SELECTION BAR 3 OF (m.lcPages2) m.oRef.actionSetCanvasCount(4)

				* Set the mark:
				DO CASE
				CASE m.oRef.CanvasCount = 1
					SET MARK OF BAR 1 OF (m.lcPages2) TO .T.
				CASE m.oRef.CanvasCount = 2
					SET MARK OF BAR 2 OF (m.lcPages2) TO .T.
				CASE m.oRef.CanvasCount = 4
					SET MARK OF BAR 3 OF (m.lcPages2) TO .T.
				ENDCASE
			ENDIF 

		ENDIF

	ENDPROC


	PROCEDURE CheckHelperClass
		IF VARTYPE(_goFP) <> "O"
			PUBLIC _goFP
			_goFP = CREATEOBJECT("PreviewHelper")
			_goFP.lCompleteMode = .F.
		ENDIF

		* Update the language setting if needed
		IF VARTYPE(_goFP._oLang) <> "O"
			_goFP.SetLanguage(_goFP.cLanguage)
		ENDIF
	ENDPROC


	PROCEDURE ActionShowToolbar
		LPARAMETERS tnVisible

			&& 1 = Visible (default), 2 = Invisible, 3 = Use resource

		IF ISNULL( This.PreviewForm.TOOLBAR )
			This.PreviewForm.ToolbarIsVisible = .F.
			This.PreviewForm.CreateToolbar()
			This.UpdateToolbar()
		ENDIF
		DO CASE
		CASE m.tnVisible = 2
			* Hide the toolbar:
			This.PreviewForm.TOOLBAR.HIDE()
			This.PreviewForm.ToolbarIsVisible = .F.
		CASE m.tnVisible = 1
			* Show the toolbar:
			This.PreviewForm.ShowToolbar(.T.)
			This.PreviewForm.ToolbarIsVisible = .T.
		OTHERWISE
		* Do nothing
		ENDCASE
	ENDPROC


	PROCEDURE actionToolbarVisibility
	*--------------------------------------------------
	* .ActionToolbarVisibility() - called from menu
	*--------------------------------------------------
		IF ISNULL( This.PreviewForm.TOOLBAR )
			This.PreviewForm.ToolbarIsVisible = .F.
			This.PreviewForm.CreateToolbar()
			This.UpdateToolbar()
			RETURN 
		ENDIF
		IF This.PreviewForm.ToolbarIsVisible
			* Hide the toolbar:
			This.PreviewForm.TOOLBAR.HIDE()
			This.PreviewForm.ToolbarIsVisible = .F.
		ELSE
			* Show the toolbar:
			This.PreviewForm.ShowToolbar(.T.)
			This.PreviewForm.ToolbarIsVisible = .T.
		ENDIF
	ENDPROC


	PROCEDURE ActionGotoPage
	*-----------------------------------------------------------
	* ActionGoToPage()
	*-----------------------------------------------------------
		#DEFINE WINDOWTYPE_MODELESS		0
		#DEFINE WINDOWTYPE_MODAL		1

		LOCAL loForm, iPageNo
		m.loForm = CREATEOBJECT("CustomFrxGotoPageForm")
		m.loForm.oParentForm = This.PreviewForm

		IF VARTYPE(This.PreviewForm.TOOLBAR) = "O"
			This.PreviewForm.ShowToolbar(.F.)
			m.loForm.SHOW( WINDOWTYPE_MODAL )
			IF VARTYPE(This.PreviewForm.TOOLBAR) = "O"
				This.PreviewForm.ShowToolbar(.T.)
			ENDIF 
		ELSE
			m.loForm.SHOW( WINDOWTYPE_MODAL )
		ENDIF

		IF ISNULL(m.loForm)
			RETURN
		ENDIF 

		m.iPageNo = m.loForm.PAGENO
		RELEASE m.loForm

		ACTIVATE WINDOW (This.PreviewForm.NAME)

		IF m.iPageNo <> This.PreviewForm.currentPage
			This.PreviewForm.setCurrentPage( m.iPageNo )
		ENDIF
	ENDPROC


	PROCEDURE DoCustomPrint
	*-----------------------------------------------------------
	* DoCustomPrint()
	*-----------------------------------------------------------

		IF _goFP.nPrinterPropType = 2
			IF UPPER(_goFP._cOriginalPrinter) <> UPPER(_goFP.cPrinterName)
				_goFP.SetPrinter(_goFP.cPrinterName)
			ENDIF 
			DO SetPrinterProps
		ELSE 
			IF UPPER(_goFP._cOriginalPrinter) <> UPPER(_goFP.cPrinterName)
				_goFP.SetPrinter(_goFP.cPrinterName)
			ENDIF

			* Ensure the proof sheet is closed
			_goFP.CloseSheets()

			This.PreviewForm.oReport.COMMANDCLAUSES.PROMPT = .T.
			This.PreviewForm.oReport.CommandCLauses.PrintPageCurrent = ;
					This.PreviewForm.currentPage  && This.PreviewForm.oReport.CurrentPage


			LOCAL loListener AS REPORTLISTENER
			m.loListener = This.PreviewForm.oReport
			=BINDEVENT(m.loListener, "OutputPage", THIS, "DialogPrinting")

			This.PreviewForm.oReport.ONPREVIEWCLOSE(.T.)

			IF NOT _goFP.lCompleteMode
				_goFP.ClearCache()
			ENDIF

			This.RestoreParent()
		ENDIF 
	ENDPROC


	PROCEDURE DialogPrinting
		LPARAMETERS nPageNo, eDevice, nDeviceType, Par1, Par2, Par3, Par4
		UNBINDEVENTS(THIS)
		_goFP.lPrinted = .T.
	ENDPROC


	PROCEDURE ActionClose

		IF VARTYPE(_goFP) <> "O"
			RETURN
		ENDIF 
		
		IF NOT _goFP.lCompleteMode  && Simplified mode

			* Restore the closable property in the parent form
			TRY
				IF VARTYPE(_goFP._oParentForm) = "O"
					LOCAL loForm AS FORM
					m.loForm = _goFP._oParentForm
					m.loForm.CONTROLBOX = m.loForm.CONTROLBOX
					m.loForm.TITLEBAR = m.loForm.TITLEBAR
					m.loForm.CLOSABLE = .T.
					m.loForm.DRAW()
					m.loForm.PAINT()
				ENDIF
			CATCH
			ENDTRY

			_goFP.ReportReleased()

			TRY 
				LOCAL lcAlias, lnSession, lnRecno
				IF VARTYPE(This.PreviewForm) = "O" AND VARTYPE(This.PreviewForm.oReport) = "O"
					m.lcAlias   = This.PreviewForm.oReport.cStartingAlias
					m.lnSession = This.PreviewForm.oReport.nStartingSession
					m.lnRecNo   = This.PreviewForm.oReport.nStartingRecno
					This.PreviewForm.oReport.EraseTempFiles()
					This.PreviewForm.Release() && Another way of closing the current report session
		*			This.PreviewForm.oReport.ONPREVIEWCLOSE(.F.)
				ENDIF
			CATCH TO m.loExc
				IF ISDEBUGGING
					SET STEP ON 
				ENDIF 
			ENDTRY

			TRY 
				_goFP.Destroy()
			CATCH 
			ENDTRY

			RETURN 

		ELSE  && Complete Mode
			This.PreviewForm.oReport.ONPREVIEWCLOSE(.F.)

			IF VARTYPE(This.PreviewForm) = "O"
				This.PreviewForm.oReport = NULL
				This.PreviewForm = NULL
			ENDIF

			TRY
				_goFP.ClearCache()
			CATCH
			ENDTRY
			This.RestoreParent()
		ENDIF

	ENDPROC


	PROCEDURE PreviewUnload
		This.HideForm()

			LOCAL lcAlias, lnSession, lnRecno

			TRY 
				IF VARTYPE(This.PreviewForm) = "O" AND VARTYPE(This.PreviewForm.oReport) = "O"
					m.lcAlias   = This.PreviewForm.oReport.cStartingAlias
					m.lnSession = This.PreviewForm.oReport.nStartingSession
					m.lnRecNo   = This.PreviewForm.oReport.nStartingRecno
					This.PreviewForm.oReport.EraseTempFiles()
					This.PreviewForm.Release() && Another way of closing the current report session
		*			This.PreviewForm.oReport.ONPREVIEWCLOSE(.F.)
				ENDIF 
			CATCH TO m.loExc
				IF ISDEBUGGING
					SET STEP ON 
				ENDIF 
			ENDTRY

			TRY 
				_goFP.Destroy()
			CATCH 
			ENDTRY

	ENDPROC


	PROCEDURE PreviewUnload2
		This.RestoreParent()
			LOCAL lcAlias, lnSession, lnRecno
			TRY 
				IF VARTYPE(This.PreviewForm) = "O" AND VARTYPE(This.PreviewForm.oReport) = "O"
					m.lcAlias   = This.PreviewForm.oReport.cStartingAlias
					m.lnSession = This.PreviewForm.oReport.nStartingSession
					m.lnRecNo   = This.PreviewForm.oReport.nStartingRecno
					This.PreviewForm.oReport.EraseTempFiles()
					This.PreviewForm.Release() && Another way of closing the current report session
		*			This.PreviewForm.oReport.ONPREVIEWCLOSE(.F.)
				ENDIF 
			CATCH TO m.loExc
				IF ISDEBUGGING
					SET STEP ON 
				ENDIF 
			ENDTRY
	ENDPROC


	PROCEDURE HideForm
		UNBINDEVENTS(THIS)
		TRY 
			IF VARTYPE(This.PreviewForm) = "O"
				This.PreviewForm.Visible = .F.
				This.PreviewForm.Hide()
			ENDIF
		CATCH TO m.loExc
			IF ISDEBUGGING
				SET STEP ON 
			ENDIF 
		ENDTRY 
	ENDPROC


	PROCEDURE RestoreParent
		UNBINDEVENTS(THIS)
		This.HideForm()
		TRY
			IF VARTYPE(_goFP._oParentForm) = "O"
				LOCAL loForm AS FORM
				m.loForm = _goFP._oParentForm
				m.loForm.CONTROLBOX = m.loForm.CONTROLBOX
				m.loForm.TITLEBAR = m.loForm.TITLEBAR
				m.loForm.CLOSABLE = .T.
				m.loForm.DRAW()
				m.loForm.PAINT()
			ENDIF
		CATCH
		ENDTRY
	ENDPROC


	PROCEDURE ActionPrint
		This.PreviewForm.oReport.ONPREVIEWCLOSE(.T.)
	ENDPROC



	PROCEDURE ActionPrintEx

		* _goFP.oListener.aFRXPages[n,3]  && We'll store page by page the Orientation, PaperSize and PageCount
		* Properties available in the Listener
		*   .nPrtOrientation
		*   .nPrtPaperSize
		*   .cPrtPrinterName
		* _goFP._cReportEnvPrinterName  && Name of the printer selected in the report environment

		LOCAL lnOrientation, llLandscape, lnPageLimit, lnFrxIndex
		lnFrxIndex = 1
		lnOrientation = _goFP.oListener.aFrxPages(lnFrxIndex, 1) && Page Orientation    _goFP.oLISTENER.nPrtorientation
		&& 0 = Portrait
		&& 1 = Landscape

		llLandscape = (lnOrientation = 1)

		LOCAL l, t, w, h, lnPage, lnPrintWidth, lnPrintHeight, lnMaxWidth, lnMaxHeight, lnHorMargin, lnVertMargin, lnHorRes, lnVertRes
		STORE 0 TO m.l, m.t, m.w, m.h, m.lnPrintWidth, m.lnPrintHeight, m.lnMaxWidth, m.lnMaxHeight, m.lnHorMargin, m.lnVertMargin, m.lnHorRes, m.lnVertRes

		LOCAL lnPaperForm
		m.lnPaperForm = _goFP.oListener.nPrtPaperSize
		IF m.lnPaperForm > 0

			IF llLandscape
				=GetFormDimensions(UPPER(_goFP.cPrinterName), m.lnPaperForm, @m.h, @m.w)
			ELSE
				=GetFormDimensions(UPPER(_goFP.cPrinterName), m.lnPaperForm, @m.w, @m.h)
			ENDIF
*			=GetFormDimensions(UPPER(_goFP.cPrinterName), m.lnPaperForm, @m.w, @m.h)

			IF m.w > 0
				m.lnMaxWidth = m.w
				m.lnMaxHeight = m.h
			ENDIF
		ENDIF

		* Ensure the proof sheet is closed
		_goFP.CloseSheets()
		_goFP._lIsDotMatrix = IsDotMatrix(_goFP.cPrinterName)

		IF NOT EMPTY(_goFP.cPrintJobName)
			_goFP.oListener.PrintJobName = _goFP.cPrintJobName
		ENDIF

		LOCAL llChangedPrinter

		IF NOT EMPTY(_goFP._cReportEnvPrinterName)
			m.llChangedPrinter = (ALLTRIM(UPPER(_goFP.cPrinterName)) <> ALLTRIM(UPPER(_goFP._cReportEnvPrinterName)))
		ELSE
			m.llChangedPrinter = (ALLTRIM(UPPER(_goFP.cPrinterName)) <> ALLTRIM(UPPER(_goFP._cOriginalPrinter)))
		ENDIF

		DO CASE

			CASE _goFP.lCompleteMode = .F. AND ;
					(m.llChangedPrinter OR ;
					_goFP.nCopies > 1 OR ;
					_goFP._lIsDotMatrix) OR ;
					_goFP.lRepeatInPage OR ;
					_goFP.lRepeatWhenFree

				LOCAL llRepeatInPage, lnCopies, llCalculated, lnPrintedCopies
				llRepeatInPage  = _goFP.lRepeatInPage
				lnCopies        = _goFP.nCopies
				llCalculated    = .F.
				lnPrintedCopies = 0

				IF llRepeatInPage AND (_Screen.oFoxyPreviewer.lHalfHeightReport = .F.)
					llRepeatInPage = .F.
					* lnCopies = lnCopies * 2
				ENDIF

				* http://sjwiley.wordpress.com/2010/01/21/combining-portrait-and-landscape-reports-into-one-print-job-in-vfp9/
				* http://spacefold.com/articles/PDFPower.aspx
				* http://spacefold.com/articles/printjobs.aspx

				LOCAL lcPrinter, lhPrinter, lnPrinterDC, loListener as ReportListener
				m.lcPrinter   = ALLTRIM(_goFP.cPrinterName)
				m.loListener  = _goFP.oListener
				m.lnPrinterDC = 0

				TRY
					IF NOT EMPTY(m.lcPrinter)

						FOR m.n = 1 TO lnCopies
							* Get Printer DC for the selected Printer
							IF lnPrinterDC = 0
								lnPrinterDC = GetPrinterDC1(m.lcPrinter, m.lnOrientation)
							ENDIF

							#DEFINE DOCINFO_SIZE 20
							LOCAL lcDocInfo As String, loDocName as PChar, lcPrintJob
							m.lcPrintJob = IIF(EMPTY(m.loListener.PrintJobName), "FoxyPreviewer Report", m.loListener.PrintJobName)
							m.loDocName = CREATEOBJECT("PChar", "Printing " + m.lcPrintJob )
							* populate DOCINFO buffer
							m.lcDocInfo = PADR(BINTOC(DOCINFO_SIZE, "4RS") +;
								BINTOC(m.loDocName.GetAddr(),"4RS"), DOCINFO_SIZE, CHR(0))

							= xfcStartDoc(lnPrinterDC, @m.lcDocInfo)

							IF (NOT llCalculated) && AND EMPTY(m.lnHorMargin)
								IF llLandscape
									THIS.SizePages(@m.l, @m.t, @m.h, @m.w, lnPrinterDC, @m.lnVertRes, @m.lnHorRes)
								ELSE
									THIS.SizePages(@m.l, @m.t, @m.w, @m.h, lnPrinterDC, @m.lnHorRes, @m.lnVertRes)
								ENDIF
*								THIS.SizePages(@m.l, @m.t, @m.w, @m.h, lnPrinterDC, @m.lnHorRes, @m.lnVertRes)

								m.lnHorMargin  = m.l
								m.lnVertMargin = m.t

								IF m.lnMaxWidth = 0
									m.lnMaxWidth = m.w
								ELSE
									m.lnMaxWidth = FLOOR((m.lnMaxWidth * m.lnHorRes) / 25403)
								ENDIF

								IF m.lnMaxHeight = 0
									m.lnMaxHeight = m.h
								ELSE
									m.lnMaxHeight = (m.lnMaxHeight * m.lnVertRes) / 25403
								ENDIF
								m.lnPrintWidth  = m.lnMaxWidth  - (m.lnHorMargin * 2)
								m.lnPrintHeight = FLOOR(m.lnMaxHeight - (m.lnVertMargin * 2))
								m.llCalculated  = .T.
							ENDIF
							

							FOR m.lnPage = 1 TO m.loListener.OutputPageCount
								=xfcStartPage(lnPrinterDC)
								m.loListener.OutputPage(m.lnPage, lnPrinterDC, 0, 0, 0, m.lnPrintWidth , m.lnPrintHeight)
								lnPrintedCopies = lnPrintedCopies + 1

								* Print repeated page
								IF llRepeatInPage AND ;
										(lnPrintedCopies < lnCopies) AND ;
										MOD(lnPrintedCopies,2) = 1   && IIF(MOD(<NUMBER>,2) = 0, "EVEN/Par","ODD/Impar")
									LOCAL lnY1
									* lnY1 = FLOOR(loListener.GetPageHeight() / 7) && + m.lnVertMargin + 6
									lnY1 =  (m.lnPrintHeight / 2) + m.lnVertMargin
									m.loListener.OutputPage(m.lnPage, lnPrinterDC, 0, 0, lnY1, m.lnPrintWidth , m.lnPrintHeight)
									lnPrintedCopies = lnPrintedCopies + 1
								ELSE 
									IF _goFP.lRepeatWhenFree AND (_Screen.oFoxyPreviewer.lHalfHeightReport = .F.)
										LOCAL lnY1
										lnY1 =  (m.lnPrintHeight / 2) + m.lnVertMargin
										m.loListener.OutputPage(m.lnPage, lnPrinterDC, 0, 0, lnY1, m.lnPrintWidth , m.lnPrintHeight)
									ENDIF
								ENDIF

								=xfcEndPage(lnPrinterDC)
							ENDFOR

							xfcEndDoc(lnPrinterDC)
							xfcDeleteDC(m.lnPrinterDC)
							* 2013-08-26 CChalom
							* Resetting the lnPrinterDC variable handle to force getting a new DC for next report copies
							m.lnPrinterDC = 0
						
							IF lnPrintedCopies >= lnCopies
								EXIT 
							ENDIF 
						ENDFOR

					ENDIF
					This.PreviewForm.oReport.ONPREVIEWCLOSE(.F.)
				CATCH TO m.loExc
					MESSAGEBOX("Error trying to send the output to an alternate printer!" + _CRLF + "Please report to vfpimaging@hotmail.com ",16, "Error")
					IF ISDEBUGGING
						SET STEP ON
					ENDIF

				ENDTRY

			CASE _goFP.lCompleteMode = .F. AND m.llChangedPrinter = .F.
				This.PreviewForm.VISIBLE = .F.

				* Print the current report
				_goFP.lPrinted = .T.

				* Decrease the nCopies property
				_goFP.nCopies = _goFP.nCopies - 1
				_goFP._lSendToPrinter = .T.
				This.PreviewForm.oReport.ONPREVIEWCLOSE(.T.)


			CASE (m.llChangedPrinter = .F.) ;
					AND (_goFP.lUseListener) ;
					AND (_goFP._lIsDotMatrix = .F.)
				&& Default printer not changed, go ahead with the default behavior
				* Do the default behavior
				* Hide the Preview form
				This.PreviewForm.VISIBLE = .F.

				* Print the current report
				_goFP.lPrinted = .T.

				* Decrease the nCopies property
				_goFP.nCopies = _goFP.nCopies - 1
				_goFP._lSendToPrinter = .T.
				This.PreviewForm.oReport.ONPREVIEWCLOSE(.T.)

			OTHERWISE
				&& Changed the printer, so finish the preview and
				&& print from outside the preview window
				_goFP._lSendToPrinter = _goFP.SetPrinter(_goFP.cPrinterName)
				This.PreviewForm.oReport.ONPREVIEWCLOSE(.F.)

		ENDCASE

		IF NOT _goFP.lCompleteMode
			This.ActionClose()
		ENDIF

		IF VARTYPE(_goFP) = "O" AND _goFP._lNoWait
			_goFP.DoOutput()
		ENDIF
	ENDPROC





	PROTECTED PROCEDURE SizePages(m.tl, m.tt, m.tw, m.th, tnHDC, tnHorRes, tnVertRes)
		* By Lisa Slater Nicholls
		* coordinates and sizes are passed by reference
		#DEFINE PHYSICALWIDTH       110  && Actual page width  / Physical Width in device units
		#DEFINE PHYSICALHEIGHT      111  && Actual page length / Physical Height in device units
		#DEFINE PHYSICALOFFSETX     112  && Printable page left margin / Physical Printable Area x margin
		#DEFINE PHYSICALOFFSETY     113  && Printable page top margin  / Physical Printable Area y margin
		#DEFINE LOGPIXELSX           88  && DPI / Logical pixels/inch in X dimension
		#DEFINE LOGPIXELSY           90  && DPI / Logical pixels/inch in Y dimension
		#DEFINE LISTENER_DPI        960
		#DEFINE DEFAULT_DPI_GRAPHICS 96 

		LOCAL m.xdpi, m.ydpi, m.pw, m.ph, m.llScaleAdjust
		LOCAL loListener as ReportListener
		m.loListener = _goFP.oListener
		LOCAL lnHDC
		m.lnHDC = m.tnHDC

		m.pw = m.loListener.GetPageWidth()  && what the Engine thinks the page dimensions
		m.ph = m.loListener.GetPageHeight() && are for the full report, based on the first setup

		m.tw = xfcGetDeviceCaps(m.lnHDC, PHYSICALWIDTH)
		m.th = xfcGetDeviceCaps(m.lnHDC, PHYSICALHEIGHT)

		m.xdpi = xfcGetDeviceCaps(m.lnHDC, LOGPIXELSX)
		m.ydpi = xfcGetDeviceCaps(m.lnHDC, LOGPIXELSY)

		*!*	    IF THIS.ScalePages= "RETAIN"
		*!*	      *&* what does the Engine *think* is the aspect ratio?
		*!*	      *&* what is the real aspect ratio?
		*!*	      *&* do they match?
		*!*	      m.llScaleAdjust =  (m.tw < m.th AND m.pw >= m.ph) OR ;
		*!*	        (m.th < m.tw AND m.ph >= m.pw) OR ;
		*!*	        (m.tw = m.th AND m.ph # m.pw)
		*!*	    ENDIF

		m.tl = xfcGetDeviceCaps(m.lnHDC, PHYSICALOFFSETX)
		m.tt = xfcGetDeviceCaps(m.lnHDC, PHYSICALOFFSETY)

		*!*	    #IF USE_DEFAULT_DPI_GRAPHICS
		*!*	       *&* we can't work with the printer dpi,
		*!*	       *&* VFP is working in the default when it
		*!*	       *&* gets a Graphics object from an HDC.
		*!*	       *&* Start by fixing page offsets.
		*!*	       m.tl =  m.tl * (DEFAULT_DPI_GRAPHICS / m.xdpi)
		*!*	       m.tt =  m.tt * (DEFAULT_DPI_GRAPHICS / m.ydpi)
		*!*
		*!*	       DO CASE
		*!*	       CASE m.llScaleAdjust
		*!*	         *&* fix the larger of the two dimensions
		*!*	         *&* to fit the available space
		*!*	         IF (m.tw > m.th) AND (m.ph > m.pw)
		*!*	           m.tw = INT(m.th * (m.pw/m.ph) )
		*!*	         ELSE
		*!*	           m.th = INT(m.tw * (m.ph/m.pw) )
		*!*	         ENDIF
		*!*	         m.th = INT(m.th * (DEFAULT_DPI_GRAPHICS / m.xdpi))
		*!*	         m.tw = INT(m.tw * (DEFAULT_DPI_GRAPHICS / m.ydpi))
		*!*	       CASE THIS.ScalePages == "CLIP"
		*!*	         *&* take what the Engine expected and fix the units
		*!*	         m.tw = INT(m.pw * (DEFAULT_DPI_GRAPHICS / LISTENER_DPI))
		*!*	         m.th = INT(m.ph * (DEFAULT_DPI_GRAPHICS / LISTENER_DPI))
		*!*	       CASE .F.
		*!*	         *&* you could change the way the thing fits on the page (for example,
		*!*	         *&* four pages to the page, or envelope printing using a Title or Summary band)
		*!*	         *&* You need to keep track of the appropriate
		*!*	         *&* m.tl and m.tt values as you output each page section.
		*!*	       OTHERWISE
		*!*	         *&* fix units to scale and stretch/fill by default
		*!*	         m.tw = INT(m.tw * (DEFAULT_DPI_GRAPHICS / m.xdpi))
		*!*	         m.th = INT(m.th * (DEFAULT_DPI_GRAPHICS / m.ydpi))
		*!*	       ENDCASE
		*!*	    #ELSE
		*!*	       DO CASE
		*!*	       CASE m.llScaleAdjust
		*!*	         *&* fix the larger of the two dimensions
		*!*	         *&* to fit the available space
		*!*	         IF (m.tw > m.th) AND (m.ph > m.pw)
		*!*	           m.tw = INT((m.th - m.tt) * (m.pw/m.ph) )
		*!*	         ELSE
		*!*	           m.th = INT((m.tw - m.tl)* (m.ph/m.pw) )
		*!*	         ENDIF
		*!*	       CASE THIS.ScalePages == "CLIP"
		*!*	         *&* take what the Engine expected and fix the units
		*!*	         m.tw = INT(m.pw * ( m.xdpi / LISTENER_DPI))
		*!*	         m.th = INT(m.ph * ( m.ydpi / LISTENER_DPI))
		*!*	       CASE .F.
		*!*	         *&* see notes on other ideas above
		*!*	       OTHERWISE
		*!*	         *&* we're good to go to scale and
		*!*	         *&* stretch/fill by default
		*!*	       ENDCASE
		*!*	    #ENDIF
*!*			m.tw = m.tw - (m.tl*2)
*!*			m.th = m.th - (m.tt*2)
*!*			m.tl = 0
*!*			m.tt = 0
		*&* see note above in CASE .F. section --
		*&* 0 values will not always be appropriate
		*&* for m.tl and m.tt, depending on how
		*&* you are trying to lay out your page.

		m.tnHorRes  = m.xDpi
		m.tnVertRes = m.yDpi

	ENDPROC



	PROCEDURE DoSetup

		* Ensure the proof sheet is closed
		_goFP.CloseSheets()

		IF VARTYPE(This.PreviewForm.TOOLBAR) = "O"
			LOCAL llOldVisible
			m.llOldVisible = This.PreviewForm.Toolbar.Visible
			This.PreviewForm.ShowToolbar(.F.)
			DO FORM PR_Settings.scx NAME _goFP._oSettingsSheet
			IF VARTYPE(This.PreviewForm.TOOLBAR) = "O" AND m.llOldVisible
				This.PreviewForm.ShowToolbar(.T.)
			ENDIF 
		ELSE
			DO FORM PR_Settings.scx NAME _goFP._oSettingsSheet
		ENDIF

		_goFP._oSettingsSheet = NULL
		
		IF _Screen.Visible && NOT _goFP._TopForm
			ACTIVATE WINDOW (This.PreviewForm.NAME)
		ENDIF 
	ENDPROC



	PROCEDURE SetImages

		WITH THIS

			IF _goFP.nButtonSize = 1 && 16x16
				.IMGBTN_PREV	 = PR_IMGBTN_PREV
				.IMGBTN_NEXT	 = PR_IMGBTN_NEXT
				.IMGBTN_TOP		 = PR_IMGBTN_TOP
				.IMGBTN_BOTT	 = PR_IMGBTN_BOTT
				.IMGBTN_MINI	 = EVL(_goFP.cImgMiniatures, PR_IMGBTN_MINI)
				.IMGBTN_PRINT	 = EVL(_goFP.cImgPrint     , PR_IMGBTN_PRINT)
				.IMGBTN_PRINTPREF = EVL(_goFP.cImgPrintPref, PR_IMGBTN_PRINTPREF)
				.IMGBTN_GOTOPG	 = PR_IMGBTN_GOTOPG
				.IMGBTN_1PG		 = PR_IMGBTN_1PG
				.IMGBTN_2PG		 = PR_IMGBTN_2PG
				.IMGBTN_4PG		 = PR_IMGBTN_4PG
				.IMGBTN_CLOSE	 = EVL(_goFP.cImgClose , PR_IMGBTN_CLOSE)
				.IMGBTN_CLOSE2	 = EVL(_goFP.cImgClose2, PR_IMGBTN_CLOSE2)
				.IMGBTN_SAVE	 = EVL(_goFP.cImgSave  , PR_IMGBTN_SAVE)
				.IMGBTN_EMAIL	 = EVL(_goFP.cImgEmail , PR_IMGBTN_EMAIL)
				.IMGBTN_SETUP	 = EVL(_goFP.cImgSetup , PR_IMGBTN_SETUP)
				.IMGBTN_SEARCH	 = EVL(_goFP.cImgSearch, PR_IMGBTN_SEARCH)
				.IMGBTN_SEARCHAGAIN = EVL(_goFP.cImgSearchAgain, PR_IMGBTN_SEARCHAGAIN)
				.IMGBTN_SEARCHBACK  = EVL(_goFP.cImgSearchBack , PR_IMGBTN_SEARCHBACK)
				
			ELSE

				.IMGBTN_PREV	 = PR_IMGBTN_PREV_32
				.IMGBTN_NEXT	 = PR_IMGBTN_NEXT_32
				.IMGBTN_TOP		 = PR_IMGBTN_TOP_32
				.IMGBTN_BOTT	 = PR_IMGBTN_BOTT_32

				.IMGBTN_MINI	 = EVL(_goFP.cImgMiniaturesBig, PR_IMGBTN_MINI_32)
				.IMGBTN_PRINT	 = EVL(_goFP.cImgPrintBig     , PR_IMGBTN_PRINT_32)
				.IMGBTN_PRINTPREF = EVL(_goFP.cImgPrintPrefBig, PR_IMGBTN_PRINTPREF_32)

				.IMGBTN_GOTOPG	 = PR_IMGBTN_GOTOPG_32
				.IMGBTN_1PG		 = PR_IMGBTN_1PG_32
				.IMGBTN_2PG		 = PR_IMGBTN_2PG_32
				.IMGBTN_4PG		 = PR_IMGBTN_4PG_32

				.IMGBTN_CLOSE	 = EVL(_goFP.cImgCloseBig , PR_IMGBTN_CLOSE_32)
				.IMGBTN_CLOSE2	 = EVL(_goFP.cImgClose2Big, PR_IMGBTN_CLOSE2_32)
				.IMGBTN_SAVE	 = EVL(_goFP.cImgSaveBig  , PR_IMGBTN_SAVE_32)
				.IMGBTN_EMAIL	 = EVL(_goFP.cImgEmailBig , PR_IMGBTN_EMAIL_32)
				.IMGBTN_SETUP	 = EVL(_goFP.cImgSetupBig , PR_IMGBTN_SETUP_32)
				.IMGBTN_SEARCH	 = EVL(_goFP.cImgSearchBig, PR_IMGBTN_SEARCH_32)
				.IMGBTN_SEARCHAGAIN = EVL(_goFP.cImgSearchAgainBig, PR_IMGBTN_SEARCHAGAIN_32)
				.IMGBTN_SEARCHBACK  = EVL(_goFP.cImgSearchBackBig , PR_IMGBTN_SEARCHBACK_32)

			ENDIF

		ENDWITH

	ENDPROC



	PROCEDURE SHOW(iStyle)

		LOCAL loToolbar as Toolbar 
		LOCAL llToolbarVisible
		m.loToolbar = This.PreviewForm.Toolbar
		m.llToolbarVisible = m.loToolbar.Visible
		m.loToolbar.Visible = .F. 

		LOCAL loPreviewForm as Form
		m.loPreviewForm = This.PreviewForm

		IF NOT PEMSTATUS(m.loToolbar, "lStarted", 5)
			m.loToolbar.AddProperty("lStarted", .F.)
		ENDIF
		
		SET TALK OFF
		SET CONSOLE OFF

		* Ensure that we have a parent helper class
		This.CheckHelperClass()
		
		_goFP.oListener = This.PreviewForm.oReport
		_goFP._nBtSize = IIF(_goFP.nButtonSize = 1, 22, 36)
		IF VARTYPE(m.loPreviewForm.Label1) = "O"
			_goFP._PreviewVersion = m.loPreviewForm.Label1.Caption
		ENDIF

		IF NOT ISNULL(_goFp.nPreviewBackColor)
			m.loPreviewForm.BackColor = _goFp.nPreviewBackColor
		ENDIF 

		This.SetImages()

		WITH This.PreviewForm as Form 

			* If we are using a Desktop form, we need to force the toolbar
			* to have the new form as the parent
			* Code adapted from a sample provided by Onytoo, with insights from Yousfi Benameur
			* See thread in Foxite: http://www.foxite.com/archives/0000319599.htm

			m.loToolbar.Top = MAX(SYSMETRIC(9), m.loToolbar.Top)
			m.loToolbar.Left = MAX(m.loToolbar.Left, 0)

			IF .DeskTop = .T.
				LOCAL lnOldParent
				m.lnOldParent  = 0
				m.lnOldParent  = GetParent(m.loToolbar.HWnd)
				=SetParent(m.loToolbar.HWnd, 0)

				#DEFINE swp_nosize       1
				#DEFINE swp_nomove       2
				#DEFINE hwnd_topmost    -1
				#DEFINE hwnd_notopmost  -2

				IF m.loToolbar.Docked 
					m.loToolbar.Dock(-1)
					=SetParent(m.loToolbar.HWnd, 0)
				ENDIF
				m.loToolbar.Move(0, SYSMETRIC(9))
				m.loToolbar.Width = 1000
				m.loToolbar.Movable = .F.
				m.loToolbar.Sizable = .F. 
				
				=SetWindowPos(m.loToolbar.HWnd, HWND_TOPMOST, 0, 0, 0, 0, BITOR(SWP_NOSIZE, SWP_NOMOVE))
			ENDIF


			LOCAL llNoWait, llTopForm
			TRY
				m.llTopForm = This.PreviewForm.TopForm && to avoid the error "TopForm" property does not exist
			CATCH
			ENDTRY
			_goFP._TopForm = m.llTopForm

			This.PreviewForm.ICON = _goFP.cFormIcon
			This.PreviewForm.AllowPrintFromPreview = .F.

			* Replace the original Page number synchronization method
			BINDEVENT(This.PreviewForm, "SynchPageNo", THIS, "SynchPageNo", 1)

			* Replace the original Toolbar.Refresh method
			BINDEVENT(This.PreviewForm.TOOLBAR, "Refresh", THIS, "RefreshToolbar", 1)
			BINDEVENT(This.PreviewForm, "RenderPage", THIS, "RenderPage", 1)
			* BINDEVENT(This.PreviewForm, "CreateCanvases", THIS, "CreateCanvases", 1)

			* To avoid bug in the ReportPreview.App, when restoring from resource
			* Since that method tries to update the toolbar, we need to make sure it is present
			BINDEVENT(This.PreviewForm, "RestoreFromResource", THIS, "RestoreFromResource_Bind")



			* Don't permit the parent top-level form to be closable
			IF m.llTopForm OR This.PreviewForm.SHOWWINDOW > 0 && In Top-Level or As Top-Level form
				LOCAL lcParentTitle, lcCaption, loForm AS FORM
				m.lcParentTitle = GetParentWindow()
				FOR EACH m.loForm IN _SCREEN.FORMS FOXOBJECT
					m.lcCaption = m.loForm.CAPTION
					IF m.lcCaption = m.lcParentTitle
				*		BINDEVENT(loForm, "QueryUnload", This, "ParentClosed")

						TRY
							IF m.loForm.CLOSABLE = .T.
								m.loForm.CLOSABLE = .F.
								BINDEVENT(This.PreviewForm, "QueryUnload", THIS, "PreviewUnload2")
								BINDEVENT(This.PreviewForm, "Destroy", THIS, "PreviewUnload2")
								_goFP._oParentForm = m.loForm
							ENDIF
						CATCH
						ENDTRY

						EXIT
					ENDIF
				ENDFOR
			ELSE 
				BINDEVENT(This.PreviewForm, "QueryUnload", THIS, "PreviewUnload")
			ENDIF

			m.llNoWait = m.llTopForm OR ;
				This.PreviewForm.oReport.COMMANDCLAUSES.NOWAIT
			_goFP._lNoWait = m.llNoWait

			IF VARTYPE(_goFP.nDockType) = "N" AND ;
					_goFP.nDockType <> 4 && false or 4 MEANS TO KEEP THE CURRENT DOCK SETTINGS FROM THE RESOURCE
				This.PreviewForm.TOOLBAR.DOCK(_goFP.nDockType)
		*!*	–1 Undocks the toolbar or form.
		*!*	 0 Positions the toolbar or form at the top of the main Visual FoxPro window.
		*!*	 1 Positions the toolbar or form at the left side of the main Visual FoxPro window.
		*!*	 2 Positions the toolbar or form at the right side of the main Visual FoxPro window.
		*!*	 3 Positions the toolbar or form at the bottom of the main Visual FoxPro window.
			ENDIF

			This.PreviewForm.oReport.CommandClauses.InWindow = ""

			* Defining the previewform.WindowState
			* 0 = Normal, 1 = Minimized, 2 = Maximized
			This.PreviewForm.WINDOWSTATE = _goFP.nWindowState

			LOCAL loListener
			m.loListener = This.PreviewForm.oReport

			_goFP.nPageTotal = .PAGETOTAL
			_goFP._cFRXName  = .FrxFileName
			*!*	_goFP._cFRXFullName = loListener.CommandClausesFile

			* Retrieve report clauses
			_goFP._ClausenRangeFrom = m.loListener.COMMANDCLAUSES.RangeFrom
			_goFP._ClausenRangeTo = m.loListener.COMMANDCLAUSES.RangeTo && -1 = All pages
			_goFP._ClauselSummary = m.loListener.COMMANDCLAUSES.SUMMARY
			_goFP._ClausecHeading = m.loListener.COMMANDCLAUSES.HEADING

		ENDWITH

		* Check if we can do searches in this preview session
		LOCAL loRL as ReportListener 
		m.loRL = This.PreviewForm.oReport
		IF PEMSTATUS(m.loRL, "cOutputAlias", 5)
			_goFP._lCanSearch = .T.
		ENDIF 

		IF NOT m.loToolbar.lStarted
			This.UpdateToolbar(m.llToolbarVisible)
			m.loToolbar.lStarted = .T.
		ENDIF 

		This.ActionShowToolbar(_goFP.nShowToolbar)

		DODEFAULT(m.iStyle)
	ENDPROC


*!* Only works after SP1, so we keep calling "UpdateToolbar()" directly
*!*	PROCEDURE InitializeToolBar()
*!*		This.UpdateToolBar()
*!*	ENDPROC


	* To avoid bug in the ReportPreview.App, when restoring from resource
	* Since that method tries to update the toolbar, we need to make sure it is present
	PROCEDURE RestoreFromResource_Bind
		IF VARTYPE(This.PreviewForm.Toolbar) <> "O"
			This.PreviewForm.CreateToolBar()
			This.PreviewForm.Toolbar.Visible = .F.
		ENDIF
	ENDPROC



	PROCEDURE HandledError
		LPARAMETERS iError, cMethod, iLine

		&& Ignore errors during Canvas creation
		IF m.iError = 1771 AND UPPER(m.cMethod) = "FRXPREVIEWFORM.NEWOBJECT" AND PEMSTATUS(This.PreviewForm, "Canvas1", 5)
			RETURN && 1771
		ELSE 
			*====================================================================
			* Error()
			*
			* Use the ErrorHandler class to provide default error handling. Most 
			* objects (in frxControls.vcx anyway) will defer error handling to their
			* containers, which ultimately ends up here:
			*====================================================================
			* lparameters iError, cMethod, iLine

			LOCAL llHasError
			m.llHasError = .T.
			
*!*				llHasError = .F.
*!*				TRY 
*!*					x = newobject("ErrorHandler","frxpreview.prg","ReportPreview.App")
*!*					x.Handle( m.iError, m.cMethod, m.iLine, THIS )
*!*				CATCH 
*!*					llHasError = .T.
*!*				ENDTRY 

			IF m.llHasError

				LOCAL lcHeader, lcMode, lcText, lcField
				STORE "" TO m.lcHeader, m.lcMode, m.lcText, m.lcField
				IF VARTYPE(_goFP) = "O"
					LOCAL lcVersionText
					TRY 
						m.lcVersionText = GetVfpVersion()
					CATCH
						m.lcVersionText = ""
					ENDTRY 
					m.lcHeader = "FoxyPreviewer " + ALLTRIM(TRANSFORM(_goFP.cVersion)) + ;
						"   VFP " + m.lcVersionText + " (" + VERSION(4) + ")"
					m.lcMode = _CRLF + _CRLF + IIF(_goFP.lCompleteMode, "Complete mode", "Simplified mode") + _CRLF + _CRLF
				ENDIF 

				IF VARTYPE(This.PreviewForm) = "O"
					LOCAL lcProperty, luValue
					WITH This.PreviewForm
						m.lcText = ""
						m.lcText = m.lcText + ".pageTotal   = " + transform(.pageTotal)   + chr(9) + CHR(9)
						m.lcText = m.lcText + ".currentPage = " + transform(.currentPage) + chr(9) + CHR(9)
						m.lcText = m.lcText + "_PAGENO      = " + transform(_PAGENO) + _CRLF
						m.lcText = m.lcText + ".canvasCount = " + transform(.canvasCount) + chr(9) + CHR(9)
						m.lcText = m.lcText + ".pageHeight  = " + transform(.pageHeight) + chr(9) + CHR(9)
						m.lcText = m.lcText + ".pageWidth   = " + transform(.pageWidth)  + _CRLF + _CRLF
						m.lcText = m.lcText + "Report Clauses:" + _CRLF
						AMEMBERS( ac, .oReport.CommandClauses )
						FOR EACH m.lcField IN ac
							m.luValue = EVALUATE(".oReport.commandClauses." + TRIM(m.lcField))
							IF EMPTY(m.luValue)
								LOOP
							ENDIF
							m.lcText = m.lcText + "  " + m.lcField+ " = " + TRANSFORM(m.luValue) + _CRLF
						ENDFOR 
					ENDWITH
				ENDIF 


				LOCAL lcErrorMsg
				m.lcErrorMsg = "Error #" + TRANSFORM(m.iError) +" - "+ MESSAGE() + _CRLF + ;
							"Line " + TRANSFORM(m.iLine) + " in " + m.cMethod + "()"

				IF NOT EMPTY( MESSAGE(1) )
					m.lcErrorMsg = m.lcErrorMsg + ":" + _CRLF + MESSAGE(1)
				ENDIF

				MESSAGEBOX(m.lcErrorMsg + m.lcMode + m.lcText, 16, "Internal Error - " + m.lcHeader)

*				MESSAGEBOX("Error #" + TRANSFORM(iError) + _CRLF + ;
					"Method: " + cMethod + _CRLF + ;
					"Line: " + TRANSFORM(iLine) + _CRLF + ;
 					This.Name, 16, "Error")
			ELSE 
				do case
				case x.cancelled	
					cancel
				case x.suspended
					suspend
				endcase
			ENDIF 
		ENDIF
	ENDPROC 


	PROCEDURE SynchPageNo
	*-----------------------------------------------
	* .SynchPageNo()
	* Code from the ReportPreview source project
	*-----------------------------------------------
	* Modified 20100618 Nick Porfirys
	* Now  displays:	"Page - PageTotal" when user selects 1Page mode					i.e.: "Page 5 - 1500"
	* 			or:	"Pages from %FP% to %LP%" when user selectes 2Page or 4Page mode	i.e.: "Pages from 5 to 6" or "Pages from 5 to 8"
	*
		LOCAL iCurrentPage, cMessage, lcReportName, lcFormCaption
		WITH This.PreviewForm
			m.iCurrentPage = .currentPage + .startOffset

			IF NOT _goFP.lCompleteMode
				m.lcReportName = PROPER(_goFP._cFRXName)
			ELSE 
				m.lcReportName = JUSTSTEM(_goFP._oNames(1)) && _oReports(1))
			ENDIF
			IF EMPTY(_goFP.cTitle)
				m.lcTitle = _goFP.GetLoc("REPPREVIEW") + " - " + m.lcReportName
			ELSE 
				m.lcTitle = _goFP.cTitle
			ENDIF
			IF LEN(m.lcTitle) > 200
				m.lcTitle = LEFT(m.lcTitle,200) + "... "
			ENDIF

			m.lcFormCaption = m.lcTitle && _goFP.GetLoc("REPPREVIEW") + " - " + lcReportName

			IF EMPTY( .oReport.COMMANDCLAUSES.WINDOW )
				IF .CanvasCount > 1
					LOCAL lnLastPage
					m.lnLastPage  = MIN( m.iCurrentPage + .CanvasCount-1, .PAGETOTAL )
					m.cMessage= _goFP.GetLoc("MINILABEL") + " "	&& "Pages from %FP% to %LP%"
					.CAPTION = m.lcFormCaption + " - " + STRTRAN(STRTRAN(m.cMessage, "%FP%", TRANSFORM(m.iCurrentPage)), "%LP%", TRANSFORM(m.lnLastPage))
				ELSE
					.CAPTION = m.lcFormCaption + " - " + _goFP.GetLoc("PAGECAPTIO") + " " + TRANSFORM( m.iCurrentPage ) + " / " + TRANSFORM( .PAGETOTAL )
				ENDIF
			ENDIF
		ENDWITH
	ENDPROC


	PROCEDURE RefreshToolbar
		WITH This.PreviewForm.TOOLBAR as Toolbar
			.LockScreen = .T. 
			.SETALL("AutoSize",.T.,"cmd")
			.SETALL("AutoSize",.F.,"cmd")
			.SETALL("Height",_goFP._nBtSize) &&,"cmd")
			* .SetAll("Width",_goFP._nBtSize,"cmdReport") &&,"cmd")

			FOR EACH m.loControl IN .CONTROLS
				
				IF LOWER(m.loControl.BASECLASS) = "commandbutton"
					m.loControl.WIDTH = _goFP._nBtSize
					m.loControl.HEIGHT = _goFP._nBtSize
				ENDIF
			
				IF INLIST(LOWER(m.loControl.BASECLASS), "combobox", "spinner")
					m.loControl.HEIGHT = _goFP._nBtSize - 3
				ENDIF

				IF LOWER(m.loControl.Name) = "cntsearch1"
					This.CmdSearchVisibility() && Update the Search buttons container
				ENDIF 				
			ENDFOR
			
			LOCAL lcReportName
			m.lcReportName = PROPER(_goFP._cFRXName)
			.Caption = IIF(EMPTY(_goFP.cToolbarTitle), _goFP.GetLoc("REPPREVIEW") + " - " + m.lcReportName, _goFP.cToolbarTitle)
			.LockScreen = .F.
		ENDWITH
	ENDPROC



	PROCEDURE UpdateToolbar
		LPARAMETERS tlVisible

		WITH This.PreviewForm

			.AllowPrintfromPreview = .F. && Force this value,
				&& dont worry, because we'll add manually a new "Print" button

			WITH .TOOLBAR AS TOOLBAR

				.LockScreen = .T. 
				m.lnSize = _goFP._nBtSize

				WITH .cntNext
					.WIDTH = m.lnSize * 2 + 2
					.HEIGHT = m.lnSize

					.cmdForward.WIDTH   = m.lnSize
					.cmdForward.HEIGHT  = m.lnSize
					.cmdForward.PICTURE = This.IMGBTN_NEXT
					.cmdForward.TOOLTIPTEXT = _goFP.GetLoc("MENUNEXT")

					.cmdBottom.WIDTH  = m.lnSize
					.cmdBottom.HEIGHT = m.lnSize
					.cmdBottom.LEFT = m.lnSize + 1
					.cmdBottom.PICTURE      = This.IMGBTN_BOTT
					.cmdBottom.TOOLTIPTEXT = _goFP.GetLoc("MENULAST")
				ENDWITH

				WITH .cntPrev
					.WIDTH = m.lnSize * 2 + 2
					.HEIGHT = m.lnSize

					.cmdTop.WIDTH    = m.lnSize
					.cmdTop.HEIGHT   = m.lnSize
					.cmdTop.PICTURE  = This.IMGBTN_TOP
					.cmdTop.TOOLTIPTEXT = _goFP.GetLoc("MENUTOP")

					.cmdBack.WIDTH   = m.lnSize
					.cmdBack.HEIGHT  = m.lnSize
					.cmdBack.LEFT    = m.lnSize + 1
					.cmdBack.PICTURE = This.IMGBTN_PREV
					.cmdBack.TOOLTIPTEXT = _goFP.GetLoc("MENUPREV")

					LOCAL loCmdGoto AS COMMANDBUTTON
					IF UPPER(_goFP.GetLoc("LANGUAGE")) <> "ENGLISH"
						* Replace the GoToPage button
						This.PreviewForm.TOOLBAR.cmdGotoPage.VISIBLE = .F.
						.ADDOBJECT("cmdGoto1", "cmdGotoEx")
						m.loCmdGoto = .cmdGoTo1
						m.loCmdGoto.LEFT = .WIDTH
						.WIDTH = .WIDTH + m.lnSize
					ELSE
						* Keep the original Goto button
						m.loCmdGoto = This.PreviewForm.TOOLBAR.cmdGotoPage
					ENDIF

					m.loCmdGoto.WIDTH   = m.lnSize
					m.loCmdGoto.HEIGHT  = m.lnSize
					m.loCmdGoto.PICTURE = This.IMGBTN_GOTOPG
					m.loCmdGoto.TOOLTIPTEXT = _goFP.GetLoc("MENUGOTO")

				ENDWITH

				IF _goFP.lShowMiniatures && shows the miniatures page
					.ADDOBJECT("cmdProof1","cmdProof")
					.cmdProof1.TOOLTIPTEXT = _goFP.GetLoc("MINIATURES")
				ENDIF

				IF _goFP._lCanSearch AND _goFP.lShowSearch &&AND (_goFP._oReports.Count = 1)
					.ADDOBJECT("cntSearch1",      "cntSearch")
					.cntSearch1.cmdSearch1.TOOLTIPTEXT = _goFP.GetLoc("FIND")
					.cntSearch1.cmdSearchBack1.TOOLTIPTEXT = _goFP.GetLoc("FINDBACK")
					.cntSearch1.cmdSearchAgain1.TOOLTIPTEXT = _goFP.GetLoc("FINDNEXT")
					.cntSearch1.cmdSearchBack1.Visible = .F.
					.cntSearch1.cmdSearchAgain1.Visible = .F.
					.cntSearch1.Width = .cntSearch1.cmdSearch1.Width				
				ENDIF

				LOCAL loCombo AS COMBOBOX
				m.loCombo = .cboZoom

				IF UPPER(_goFP.GetLoc("LANGUAGE")) <> "ENGLISH"
					* Translate toolbar buttons ToolTips to non English language
					IF NOT EMPTY(_goFP.GetLoc("CBOZOOMTTI"))
						.cboZoom.TOOLTIPTEXT = _goFP.GetLoc("CBOZOOMTTI")
					ELSE
						.cboZoom.TOOLTIPTEXT = "Zoom"
					ENDIF

					* Translate the combo items
					LOCAL N, lcItem
					FOR m.N = 1 TO m.loCombo.LISTCOUNT
						m.lcItem = LOWER(m.loCombo.LISTITEM(m.N))

						IF (m.lcItem = "whole page") OR (m.N = 10)
							m.loCombo.LISTITEM(m.N) = _goFP.GetLoc("CBOZOOMWHO")
						ENDIF
						IF (m.lcItem = "fit to width") OR (m.N = 11)
							m.loCombo.LISTITEM(m.N) = _goFP.GetLoc("CBOZOOMPGW")
						ENDIF
					ENDFOR
					m.loCombo.WIDTH = m.loCombo.WIDTH + 10

					WITH .opgPageCount
						.opt1.TOOLTIPTEXT = _goFP.GetLoc("ONEPGTTIP")
						.opt2.TOOLTIPTEXT = _goFP.GetLoc("TWOPGTTIP")
						.opt3.TOOLTIPTEXT = _goFP.GetLoc("FOURPGTTIP")
					ENDWITH
				ENDIF

				IF NOT _goFP.lShowPageCount
					.opgPageCount.Visible = .F.
				ELSE 
					WITH .opgPageCount AS OPTIONGROUP
						.opt1.HEIGHT  = m.lnSize
						.opt2.HEIGHT  = m.lnSize
						.opt3.HEIGHT  = m.lnSize
						.opt1.WIDTH   = m.lnSize
						.opt2.WIDTH   = m.lnSize
						.opt3.WIDTH   = m.lnSize
						.opt2.LEFT    = m.lnSize
						.opt3.LEFT    = m.lnSize * 2
						.opt1.PICTURE = This.IMGBTN_1PG
						.opt2.PICTURE = This.IMGBTN_2PG
						.opt3.PICTURE = This.IMGBTN_4PG
	
						.HEIGHT = m.lnSize
						.WIDTH = m.lnSize * 3
					ENDWITH
				ENDIF

				IF _goFP.lPrintVisible
					* Show the printers Combo
					IF _goFP.lShowPrinters
						.ADDOBJECT("cmbPrinters1", "cmbPrinters")
						.cmbPrinters1.HEIGHT = m.loCombo.HEIGHT
						.cmbPrinters1.FONTSIZE = m.loCombo.FONTSIZE
						.cmbPrinters1.TOOLTIPTEXT = _goFP.GetLoc("AVAILABLEP")

						IF (NOT PEMSTATUS(This.PreviewForm.oReport, "cPrtPrinterName",5)) OR EMPTY(This.PreviewForm.oReport.cPrtPrinterName)
						ELSE
	
							LOCAL lcReportPrinter
							m.lcReportPrinter = This.PreviewForm.oReport.cPrtPrinterName
							IF NOT EMPTY(m.lcReportPrinter)
								_goFP._cReportEnvPrinterName = m.lcReportPrinter
							ENDIF

							IF NOT EMPTY(_goFP._cReportEnvPrinterName)
								LOCAL lnPrtIndex, lcUpperPrt, loCmb as ComboBox
								lcUpperPrt = UPPER(ALLTRIM(_goFP._cReportEnvPrinterName))
								FOR lnPrtIndex = 1 TO .cmbPrinters1.ListCount
									IF UPPER(.cmbPrinters1.List(lnPrtIndex)) = lcUpperPrt
										.CmbPrinters1.Value = m.lcReportPrinter
										_goFP.cPrinterName = m.lcReportPrinter
									ENDIF 
								ENDFOR 
							ENDIF 
							
							IF EMPTY(.CmbPrinters1.DisplayValue) && Printer is not available
								.CmbPrinters1.ListIndex = 1
							ENDIF
						ENDIF
					ENDIF

					* Show the copies spinner
					IF _goFP.lShowCopies && AND EMPTY(This.PreviewForm.oReport.cPrtPrinterName) && AND _goFP.lCompleteMode
						.ADDOBJECT("cntCopies1","cntCopies")
*!*							IF NOT EMPTY(This.PreviewForm.oReport.cPrtPrinterName)
*!*								.CntCopies1.Enabled = .F.
*!*								.cntCopies1.SpnCopies1.Enabled = .F.
*!*								IF VARTYPE(.cmbPrinters1) = "O"
*!*									.cmbPrinters1.Value = This.PreviewForm.oReport.cPrtPrinterName
*!*								ENDIF
*!*							ENDIF 
					ENDIF

					* Show the Save to file button
					IF _goFP.lSaveToFile && AND _goFP.lCompleteMode
						.ADDOBJECT("cmdSave1", "cmdSave")
						.cmdSave1.TOOLTIPTEXT = _goFP.GetLoc("SAVEREPORT")

						.ADDOBJECT("cmbSave1", "cmbSave")

						LOCAL lnCmbIndex
						m.lnCmbIndex = 0
						WITH .CmbSave1
							IF _goFP.lSaveAsImage
								m.lnCmbIndex = m.lnCmbIndex + 1
								.ADDITEM(_goFP.GetLoc("SAVEASIMAG"))
							
								IF _goFP.lShowFileFormatIcons  && Allow hiding the icon
									.PICTURE[m.lnCmbIndex] = "pr_Img.bmp"
								ENDIF
								.LIST[.NewIndex, 2] = '1'
							ENDIF

							IF _goFP.lCompleteMode OR _goFP._lCanSearch
								IF _goFP.lSaveAsPDF
									m.lnCmbIndex = m.lnCmbIndex + 1
									.ADDITEM(_goFP.GetLoc("SAVEASPDF"))
									IF _goFP.lShowFileFormatIcons  && Allow hiding the icon
										.PICTURE[m.lnCmbIndex] = "pr_Pdf.bmp"
									ENDIF 
									.LIST[.NewIndex, 2] = '2'
								ENDIF
								IF _goFP.lSaveAsRTF
									m.lnCmbIndex = m.lnCmbIndex + 1
									.ADDITEM(_goFP.GetLoc("SAVEASRTF"))
									.LIST[.NewIndex, 2] = '4'

									IF _goFP.lShowFileFormatIcons  && Allow hiding the icon
										.PICTURE[m.lnCmbIndex] = "pr_Word.bmp"
									ENDIF 
								ENDIF
								IF _goFP.lSaveAsXLS
									m.lnCmbIndex = m.lnCmbIndex + 1
									.ADDITEM(_goFP.GetLoc("SAVEASXLS"))
									.LIST[.NewIndex, 2] = '5'
									IF _goFP.lShowFileFormatIcons  && Allow hiding the icon
										.PICTURE[m.lnCmbIndex] = "pr_Excel.bmp"
									ENDIF 
								ENDIF
								IF _goFP.lSaveAsHTML
									m.lnCmbIndex = m.lnCmbIndex + 1
									.ADDITEM(_goFP.GetLoc("SAVEASHTML"))
									.LIST[.NewIndex, 2] = '3'
									IF _goFP.lShowFileFormatIcons  && Allow hiding the icon
										.PICTURE[m.lnCmbIndex] = "pr_HTML.bmp"
									ENDIF 
								ENDIF
								IF _goFP.lSaveAsMHT AND (_goFP.lCompleteMode = .F.)
									m.lnCmbIndex = m.lnCmbIndex + 1
									.ADDITEM(_goFP.GetLoc("SAVEASMHT"))
									.LIST[.NewIndex, 2] = '8'
									IF _goFP.lShowFileFormatIcons  && Allow hiding the icon
										.PICTURE[m.lnCmbIndex] = "pr_MHT.bmp"
									ENDIF 
								ENDIF

							ENDIF 


							IF _goFP.lCompleteMode
								IF _goFP.lSaveasTXT && 11/08/2010 by mauriciobraga@ig.com.br
									m.lnCmbIndex = m.lnCmbIndex + 1
									.ADDITEM(_goFP.GetLoc("SAVEASTXT"))
									.LIST[.NewIndex, 2] = '6'
									IF _goFP.lShowFileFormatIcons  && Allow hiding the icon
										.PICTURE[m.lnCmbIndex] = "pr_1page.bmp"
									ENDIF 
								ENDIF
							ENDIF

						ENDWITH

					ENDIF  && _goFP.lSaveToFile

					* Show the Send to Email button
					IF _goFP.lSendToEmail && AND _goFP.lCompleteMode
						.ADDOBJECT("cmdEmail1", "cmdEmail")
						.cmdEmail1.TOOLTIPTEXT = _goFP.GetLoc("SENDTOEMAI")
					ENDIF && _goFP.lSendToEmail

					* Show the Printer preferences button
					IF _goFP.lPrinterPref && AND _goFP.lCompleteMode
						.ADDOBJECT("cmdPrinterProps1", "cmdPrinterProps")
						.cmdPrinterProps1.TOOLTIPTEXT = _goFP.GetLoc("PRINTINGPR")
					ENDIF

					* Replace the original Print button
					.cmdPrint.Visible = .F. && Hide the original print btn

					IF _goFP.lShowPrintBtn
						.ADDOBJECT("cmdPrint1", "cmdPrintEx")
						.cmdPrint1.TOOLTIPTEXT = _goFP.GetLoc("PRINTREPOR")
					ENDIF
				ENDIF

				IF _goFP.lShowSetup
					.ADDOBJECT("cmdSetup1", "cmdSetup")
					.cmdSetup1.TOOLTIPTEXT = _goFP.GetLoc("SETUP")
				ENDIF

				* Replace the original Close button
				.cmdClose.VISIBLE = .F.
				
				IF _goFP.lShowClose
					.ADDOBJECT("cmdExit1", "cmdExit")
					.CmdExit1.TOOLTIPTEXT  = _goFP.GetLoc("CLOSEREPOR")
				ENDIF

				* Checkings for big buttons
				IF _goFP.nButtonSize = 2 AND _goFP.lPrintVisible
					IF _goFP.lSaveToFile
						.CmbSave1.FONTSIZE = 11
					ENDIF
					IF _goFP.lShowPrinters
						.cmbPrinters1.FONTSIZE = 11
					ENDIF
					.cboZoom.FONTSIZE = 11
					.cboZoom.WIDTH = 115
				ENDIF

				IF VARTYPE(.CntCopies1) = "O" && _goFP.lShowCopies AND _goFP.lPrintVisible && AND _goFP.lCompleteMode
					.cntCopies1.SpnCopies1.FONTSIZE = .cboZoom.FONTSIZE
					.cntCopies1.LblCopies1.FONTSIZE = .cboZoom.FONTSIZE
					.cntCopies1.AdjustControls()
				ENDIF

				.REFRESH()
				.LockScreen = .F. 

			ENDWITH


			LOCAL lcReportName, lcTitle
			IF NOT _goFP.lCompleteMode
				BINDEVENT(THIS, "Destroy", _goFP, "ReportReleased")
				m.lcReportName = PROPER(_goFP._cFRXName)
			ELSE 
				m.lcReportName = JUSTSTEM(_goFP._oNames(1)) && _oReports(1))
			ENDIF

*!*				IF EMPTY(_goFP.cTitle)
*!*					lcTitle = _goFP.GetLoc("REPPREVIEW") + " - " + lcReportName
*!*				ELSE 
*!*					lcTitle = _goFP.cTitle
*!*				ENDIF
*!*				IF LEN(lcTitle) > 150
*!*					lcTitle = LEFT(lcTitle,150) + "... "
*!*				ENDIF
*!*				.Caption     = lcTitle
*!*				.FormCaption = lcTitle
*!*				This.PreviewForm.CAPTION = lcTitle
*!*				This.PreviewForm.formCaption = lcTitle

			This.SynchPageNo()

			IF m.tlVisible
				This.PreviewForm.Toolbar.Visible = .T.
			ENDIF

		ENDWITH
	ENDPROC


	PROCEDURE ParentClosed
		UNBINDEVENTS(THIS)
		This.ActionClose()
		_goFP.ReportReleased(THIS)
	ENDPROC


	PROCEDURE DoProof
	
		_goFP.CloseSheets()

		LOCAL llShowToolBar
		m.llShowToolBar = VARTYPE(This.PreviewForm.TOOLBAR) = "O" ;
				and This.PreviewForm.Toolbar.Visible = .T.

		IF m.llShowToolBar
			This.PreviewForm.ShowToolbar(.F.)
		ENDIF

		_goFP._oProofSheet = CREATEOBJECT("ProofSheet")
		_goFP._oProofSheet.SetReport( This.PreviewForm.oReport )
		_goFP._oProofSheet.Caption = _goFP.GetLoc("GLOBALPREV")
		_goFP._oProofSheet.nMaxMiniatureItem = _goFP.nMaxMiniatureDisplay

		IF VARTYPE(_goFP._oParentForm) = "O"
			ACTIVATE WINDOW (_goFP._oParentForm.NAME)

			IF _Screen.Visible && NOT _goFP._TopForm
				ACTIVATE WINDOW (This.PreviewForm.NAME)
			ENDIF 
		ENDIF

		_goFP._oProofSheet.SetProofCaption()
		_goFP._oProofSheet.SHOW(1)

		* read the selected page and move to it,
		* using the .SetCurrentPage() method of
		* the default preview container:

		IF VARTYPE(NVL(_goFP._oProofSheet,"")) = "O"
			LOCAL loExc as Exception 
			TRY
				LOCAL lnPage
				m.lnPage = _goFP._oProofSheet.CurrentPage
				This.PreviewForm.setCurrentPage(m.lnPage)
				_goFP._oProofSheet = ""
			CATCH TO m.loExc
				IF ISDEBUGGING
					SET STEP ON 
				ENDIF 
			ENDTRY
		ENDIF 
		
		IF m.llShowToolBar AND VARTYPE(This.PreviewForm.TOOLBAR) = "O"
			This.PreviewForm.ShowToolbar(.T.)
		ENDIF

	ENDPROC



*----------------------------------------------------------------------
* SEARCH MODULE
*----------------------------------------------------------------------

PROCEDURE CmdSearchVisibility
	LPARAMETERS tlVisible

	LOCAL loToolbar as Toolbar 
	m.loToolBar = This.PreviewForm.Toolbar

	IF NOT ISNULL(m.loToolBar) AND VARTYPE(m.loToolbar) = "O"

		WITH m.loToolBar.cntSearch1

			IF PCOUNT() = 0  && No parameters passed, just update the size of the controls
				m.tlVisible = m.loToolBar.cntSearch1.cmdSearchAgain1.Visible
				LOCAL lnWidth
				m.lnWidth = _goFP._nBtSize
				.cmdSearch1.Width = m.lnWidth
				.cmdSearchBack1.Width = m.lnWidth
				.cmdSearchAgain1.Width = m.lnWidth
			ENDIF 

			.cmdSearchAgain1.Visible = m.tlVisible
			.cmdSearchBack1.Visible  = m.tlVisible

			IF m.tlVisible
				LOCAL lcText, lnSize
				m.lcText = ": '" + ALLTRIM(_goFP._cTextToFind) + "'"
				m.lnSize = _goFP._nBtSize
				.cmdSearchBack1.Left = m.lnSize + 1
				.cmdSearchBack1.ToolTipText = _goFP.GetLoc("FINDBACK") + m.lcText
				.cmdSearchAgain1.Left = (m.lnSize * 2) + 2
				.cmdSearchAgain1.ToolTipText = _goFP.GetLoc("FINDNEXT") + m.lcText
				.Width = .cmdSearch1.Width + .cmdSearchBack1.Width + .cmdSearchAgain1.Width + 2
			ELSE
				.Width = .cmdSearch1.Width				
			ENDIF 
		ENDWITH 
	
		_goFP._lShowSearchAgain = m.tlVisible
	ENDIF 
ENDPROC 


PROCEDURE DoSearch
	* Prompt the user for some text to find, find the first instance of it, and
	* highlight it.

	* Ensure the proof sheet is closed
	_goFP.CloseSheets()

	This.ClearBox()

	LOCAL lcText, lcReportAlias, lcAlias
	m.lcReportAlias = ALIAS()
	m.lcAlias = This.PreviewForm.oReport.cOutputAlias
	* lcAlias = _goFP._cOutputAlias

	IF EMPTY(m.lcAlias)
		MESSAGEBOX("Search feature is currently unavailable for this report.", 48, "FoxyPreviewer error")
		RETURN 
	ENDIF

	WITH This
		* lcText = INPUTBOX('Find:', 'Find Text')
		* _goFP._cTextToFind = lcText
	
		IF VARTYPE(This.PreviewForm.TOOLBAR) = "O"
			This.PreviewForm.ShowToolbar(.F.)
			DO FORM PR_Search.scx WITH _goFP._cTextToFind, This.PreviewForm
			IF VARTYPE(This.PreviewForm.TOOLBAR) = "O"
				This.PreviewForm.ShowToolbar(.T.)
			ENDIF 
		ELSE
			DO FORM PR_Search.scx WITH _goFP._cTextToFind, This.PreviewForm
		ENDIF

		IF _Screen.Visible && _goFP._TopForm
			ACTIVATE WINDOW (This.PreviewForm.NAME)
		ENDIF 

		
		* DO FORM PR_Search.scx WITH _goFP._cTextToFind
		m.lcText = _goFP._cTextToFind

		INKEY(.2)
		DOEVENTS 

		IF NOT EMPTY(m.lcText)
			LOCAL llError
			TRY
				SELECT (m.lcAlias)
			CATCH
				MESSAGEBOX("Search feature is currently unavailable for this report.", 48, "FoxyPreviewer error")
				m.llError = .T.
			ENDTRY 
			IF m.llError
				RETURN
			ENDIF 
					
			_goFP._cTextToFind = m.lcText
			LOCATE FOR UPPER(m.lcText) $ UPPER(CONTENTS)
			.HandleFind(FOUND())
		ELSE 
			This.CmdSearchVisibility(.F.)
		ENDIF 
	ENDWITH
	
	* Restore original alias
	TRY 
		SELECT (m.lcReportAlias)
	CATCH
	ENDTRY 
ENDPROC 


PROCEDURE DoSearchAgain
	This.ClearBox()
	
	LOCAL lcText, lcAlias, lcReportAlias
	m.lcReportAlias = ALIAS()
	m.lcAlias = This.PreviewForm.oReport.cOutputAlias
	m.lcText  = _goFP._cTextToFind

	IF NOT EMPTY(m.lcText)
		SELECT (m.lcAlias)
		IF NOT EOF()
			SKIP +1
		ENDIF 
		LOCATE REST FOR UPPER(m.lcText) $ UPPER(CONTENTS)
		IF EOF()
			* Search from beginning
			LOCATE FOR UPPER(m.lcText) $ UPPER(CONTENTS)
		ENDIF 
		This.HandleFind(FOUND(), .T.) && The 2nd parameter means that we are calling
									&& SearchAgain
	ENDIF
	
	* Restore original alias
	TRY 
		SELECT (m.lcReportAlias)
	CATCH
	ENDTRY 

ENDPROC 



PROCEDURE DoSearchBack
	This.ClearBox()
	
	LOCAL lcText, lcAlias, lcReportAlias
	m.lcReportAlias = ALIAS()
	m.lcAlias = This.PreviewForm.oReport.cOutputAlias
	m.lcText  = UPPER(_goFP._cTextToFind)

	IF NOT EMPTY(m.lcText)
		SELECT (m.lcAlias)

		DO WHILE .T.
			SKIP -1
			IF BOF()
				GO BOTTOM 
			ENDIF 

			IF m.lcText $ UPPER(CONTENTS)
				EXIT
			ENDIF 
		ENDDO 
		This.HandleFind(.T., .T.) && The 2nd parameter means that we are calling
									&& SearchAgain
	ENDIF
	SELECT (m.lcReportAlias)
ENDPROC 


* Handle whether the object was found or not.
PROCEDURE HandleFind
	LPARAMETERS tlFound, tlAgain

	IF m.tlFound
		This.lHighlighttext = .T.
		This.CmdSearchVisibility(.T.)
	ELSE

		IF NOT m.tlAgain
			This.CmdSearchVisibility(.F.)
		ENDIF 

		MESSAGEBOX(_goFP.GetLoc("NOTFOUND"), ;
			48, CHRTRAN(_goFP.GetLoc("FINDTEXT"),":",""))
		GO TOP 
		This.lHighlighttext = .F.
		RETURN 
	ENDIF

	IF PAGE <> This.PreviewForm.CurrentPage
		This.lHighlighttext = .T.
		This.PreviewForm.TempStopRepaint = .T.
		This.PreviewForm.setCurrentPage( PAGE )
	ENDIF 

	This.ScrollToObject(Left/10, Top/10, Width/10, Height/10)
	=INKEY(.2)
	DOEVENTS  
	This.lHighlighttext = .T.
	This.PreviewForm.RenderPages()
ENDPROC 


PROCEDURE ClearBox
	TRY 
		LOCAL loForm as Form
		m.loForm = This.PreviewForm
		IF VARTYPE(m.loForm.LineTop) = "O" 
			m.loForm.RemoveObject("lineTop")
		ENDIF 
		IF VARTYPE(m.loForm.LineBott) = "O" 
			m.loForm.RemoveObject("lineBott")
		ENDIF 
		IF VARTYPE(m.loForm.LineLeft) = "O" 
			m.loForm.RemoveObject("lineLeft")
		ENDIF 
		IF VARTYPE(m.loForm.LineRight) = "O" 
			m.loForm.RemoveObject("lineRight")
		ENDIF 
	CATCH
	ENDTRY 
ENDPROC 


* By Doug Hennig
* We may need to scroll the form if the specified object isn't currently visible.
PROCEDURE ScrollToObject
	LPARAMETERS tnLeft, tnTop, tnWidth, tnHeight
	LOCAL lnNewTop, lnNewLeft, lnVPos, lnHPos, ;
			lnVpTop, lnVpLeft, lnVpWidth, lnVpHeight

	WITH This.PreviewForm as Form
		m.lnVpTop    = .ViewPortTop 
		m.lnVpLeft   = .ViewPortLeft 
		m.lnVpWidth  = .ViewPortWidth 
		m.lnVpHeight = .ViewPortHeight 

		m.lnNewTop   = m.lnVpTop
		m.lnNewLeft  = m.lnVpLeft
		m.lnVPos     = m.tnTop  + m.tnHeight + This.PreviewForm.Canvas1.Top
		m.lnHPos     = m.tnLeft + m.tnWidth  + This.PreviewForm.Canvas1.Left

		IF NOT BETWEEN(m.lnVPos - 20, m.lnVpTop , m.lnVpTop + m.lnVpHeight)
			m.lnNewTop = m.lnVPos - m.lnVpHeight /2
		ENDIF
		IF NOT BETWEEN(m.lnHPos, m.lnVpLeft, m.lnVpLeft + m.lnVpWidth)
			m.lnNewLeft = m.lnHPos - m.lnVpWidth /2
		ENDIF
	
		IF m.lnNewTop <> m.lnVpTop OR m.lnNewLeft <> m.lnVpLeft
			.SetViewPort(m.lnNewLeft, m.lnNewTop)
		ENDIF
	ENDWITH
ENDPROC



PROCEDURE HighLightObject
	LPARAMETERS tnL , tnT, tnW , tnH

	LOCAL lnPixelsPerDPI960, lnHWnd, lnX, lnY, lnWidth, lnHeight

	WITH This.PreviewForm

		* Adjust coordinates
		m.lnPixelsPerDPI960 = .getpixelsperdpi960()
		m.lnX = .canvas1.Left + INT(m.tnL * m.lnPixelsPerDPI960) - 2
		m.lnY = .canvas1.Top  + INT(m.tnT * m.lnPixelsPerDPI960) - 2
		m.lnWidth  = INT(m.tnW * m.lnPixelsPerDPI960) + 8
		m.lnHeight = INT(m.tnH * m.lnPixelsPerDPI960) + 8

		* Draw the box
		LOCAL loForm as Form
		m.loForm = This.PreviewForm

		m.loForm.AddObject("lineTop"  , "Line")
		m.loForm.AddObject("lineBott" , "Line")
		m.loForm.AddObject("lineLeft" , "Line")
		m.loForm.AddObject("lineRight", "Line")
	
		LOCAL lnColor
		m.lnColor = RGB(255,64,64)

		.TempStopRepaint = .T.
		WITH m.loForm.LineTop as Line 
			.Width       = m.lnWidth
			.BorderColor = m.lnColor
			.BorderWidth = 0
			.Top         = m.lnY
			.Left        = m.lnX
			.Height      = 0
			.Visible     = .T.
		ENDWITH 

		.TempStopRepaint = .T.
		WITH m.loForm.LineBott as Line
			.Width       = m.lnWidth
			.BorderColor = m.lnColor
			.BorderWidth = 0
			.Top         = (m.lnY + m.lnHeight)
			.Left        = m.lnX
			.Height      = 0
			.Visible     = .T.
		ENDWITH 

		.TempStopRepaint = .T.
		WITH m.loForm.LineLeft as Line 
			.Width       = 0
			.BorderColor = m.lnColor
			.BorderWidth = 0
			.Top         = m.lnY
			.Left        = m.lnX
			.Height      = m.lnHeight
			.Visible     = .T.
		ENDWITH 

		.TempStopRepaint = .T.
		WITH m.loForm.LineRight as Line 
			.Width = 0
			.BorderColor = m.lnColor
			.BorderWidth = 0
			.Top         = m.lnY
			.Left        = m.lnX + m.lnWidth
			.Height      = m.lnHeight
			.Visible     = .T.
		ENDWITH 

	ENDWITH 
	This.lHighlightText = .F.
ENDPROC


PROCEDURE RenderPage
	LPARAMETERS tiPage, toCanvas
	This.ClearBox()
	IF This.lHighlightText
		SELECT (this.PreviewForm.oReport.cOutputAlias)
		This.lHighlightText = .F.
		This.highlightobject(left,top,width,height)
	ELSE
	ENDIF 
ENDPROC 
*----------------------------------------------------------------------
* End of SEARCH MODULE
*----------------------------------------------------------------------



	PROCEDURE PAINT
	ENDPROC


	PROCEDURE DoSave(tnIndex)
		This.DoSaveType(m.tnIndex)

		IF _goFP._lNoWait AND ; && Top form
				NOT EMPTY(_goFP.cDestFile) AND ; && Selected a file output
				NOT _goFP.lSaved AND ;
				_goFP.lCompleteMode
			_goFP.DoOutput()
		ENDIF
	ENDPROC


	PROCEDURE DoSaveType(tnType)

		_goFP.lSaved = .F.

		IF VARTYPE(_goFP.oListener) <> "O"
			_goFP.oListener	= This.PreviewForm.oReport
		ENDIF 

		LOCAL lcFile, lcReportName, lcDefault
		TRY
*			lcReportName = JUSTSTEM(_goFP._oReports(1)) &&  Output File Name
			m.lcReportName = _goFP.oListener.PrintJobName &&  Output File Name
		CATCH
			m.lcReportName = ""
		ENDTRY

		* 2013-03-24 CChalom - Now allows gettting the default name from 'cDestFile' property
		lcDefault = IIF(NOT EMPTY(_goFP.cSaveDefName), _goFP.cSaveDefName, _goFP.cDestFile)

		IF EMPTY(_goFP.cOutputPath) OR DIRECTORY(_goFP.cOutputPath)
			*!* 2010-09-17 - Jacques Parent - Add the cSaveDefName
			*!* 2010-09-27 - Jacques Parent - Correction;  Was not used if _goFP.cOutputPath was empty
			IF EMPTY(lcDefault)
				m.lcFile = IIF(EMPTY(_goFP.cOutputPath), "", ADDBS(_goFP.cOutputPath)) + m.lcReportName && Output Path + Output File Name
			ELSE
				IF "\\" $ lcDefault
					m.lcFile = lcDefault
				ELSE 
					* 2013-07-31 Fix by Oleg Dimuhametov
					* http://www.foxite.com/archives/0000381489.htm
					m.lcFile = IIF(EMPTY(_goFP.cOutputPath), "", ADDBS(_goFP.cOutputPath)) + JUSTSTEM(lcDefault) && Output Path + Output File Name
				ENDIF
			ENDIF
		ELSE
			m.lcFile = ""
		ENDIF

		DO CASE
		CASE m.tnType = 1 && Image file
			m.lcFile = PR_XPUTFILE(_goFP.GetLoc("SAVEASIMAG") + "...", m.lcFile, "Png;Bmp;Jpg;Gif;Tif;Emf")
			IF NOT EMPTY(m.lcFile) && Invalid File Name
				LOCAL loListener
				m.loListener = This.PreviewForm.oReport
				_goFP.lSaved = Report2Pic(m.loListener, m.lcFile, JUSTEXT(m.lcFile))
				m.loListener = NULL

				IF _goFP.lSaved AND ;
						_goFP.lOpenViewer AND ;
						(_goFP._lSendingEmail = .F.)
					_goFP.OpenFile(m.lcFile)
				ENDIF

				RETURN 
			ENDIF

		* 2011-03-18
		* PDF, RTF and XLS will be created without closing the current report session
		CASE m.tnType = 2 && PDF
			m.lcFile = PR_XPUTFILE(_goFP.GetLoc("SAVEASPDF") + "...", m.lcFile, "Pdf")
			IF  NOT EMPTY(m.lcFile) && AND NOT _goFP.lCompleteMode
				_goFP.lSaved = This.DoMakePDFOffline(m.lcFile)
				RETURN 
			ENDIF 

		CASE m.tnType = 3 && HTML
			m.lcFile = PR_XPUTFILE(_goFP.GetLoc("SAVEASHTML") + "...", m.lcFile, "Htm;Html")
			IF  NOT EMPTY(m.lcFile) AND NOT _goFP.lCompleteMode
				_goFP.lSaved = This.DoMakeHTMLOffline(m.lcFile)	
				RETURN
			ENDIF 

		CASE m.tnType = 8 && MHTML
			m.lcFile = PR_XPUTFILE(_goFP.GetLoc("SAVEASHTML") + "...", m.lcFile, "Mht;Mhtml")

			IF  NOT EMPTY(m.lcFile) AND NOT _goFP.lCompleteMode
				LOCAL lcTempHTMLFile, lcImgPath
				lcTempHTMLFile = ADDBS(GETENV("TEMP")) + "tmp_" + SYS(2015) + ".htm"
				IF This.DoMakeHTMLOffline(m.lcTempHTMLFile, .T.) && Create HTML 
						&& 2nd parameter tells that it will be a temp file
					m.lcImgPath = ADDBS(JUSTPATH(m.lcTempHTMLFile)) + JUSTSTEM(m.lcTempHTMLFile) + "_IMAGES"
					=ToMHTML(m.lcTempHTMLFile, m.lcFile)

					LOCAL lcSetSafe
					lcSetSafe = SET("Safety")
					SET SAFETY OFF
					CLEAR RESOURCES (m.lcTempHTMLFile)
					TRY 
						DELETE FILE (m.lcTempHTMLFile)
					CATCH 
					ENDTRY

					IF DIRECTORY(JUSTPATH(m.lcImgPath))
						TRY 
							DELETE FILE (ADDBS(m.lcImgPath) + "*.*")
							RMDIR (m.lcImgPath)
						CATCH 
						ENDTRY
					ENDIF
					SET SAFETY &lcSetSafe.
				ENDIF
				_goFP.lSaved = FILE(m.lcFile)

				IF _goFP.lOpenViewer AND (_goFP._lSendingEmail = .F.)
					_goFP.OpenFile(m.lcFile)
				ENDIF

				RETURN
			ENDIF 


		CASE m.tnType = 4 && RTF
			m.lcFile = PR_XPUTFILE(_goFP.GetLoc("SAVEASRTF") + "...", m.lcFile, "Rtf;Doc")
			IF  NOT EMPTY(m.lcFile) && AND NOT _goFP.lCompleteMode
				_goFP.lSaved = This.DoMakeRTFOffline(m.lcFile)	
				RETURN 
			ENDIF 

		CASE m.tnType = 5 && XLS
		
		*!*	oOO = CREATEOBJECT("com.sun.star.ServiceManager")
		*!*	oExcel = CREATEOBJECT("Excel.Application")
		*!*	oExcel.quit()
		*!*	oExcel = .Null.

			LOCAL lcFileExt
			IF UPPER(_goFP.cExcelDefaultExtension) = "XML"
				m.lcFileExt = "Xml;Xls"
			ELSE
				m.lcFileExt = "Xls;Xml"
			ENDIF
			m.lcFile = PR_XPUTFILE(_goFP.GetLoc("SAVEASXLS") + "...", m.lcFile, m.lcFileExt)
			IF  NOT EMPTY(m.lcFile) && AND NOT _goFP.lCompleteMode
				_goFP.lSaved = This.DoMakeXLSOffline(m.lcFile)	
				RETURN 
			ENDIF 

		CASE m.tnType = 6 && TXT
			m.lcFile = PR_XPUTFILE(_goFP.GetLoc("SAVEASTXT") + "...", m.lcFile, "Txt;Csv;Xl5")
		OTHERWISE
		ENDCASE

		IF NOT EMPTY(m.lcFile) && Invalid File Name
			_goFP.cDestFile = m.lcFile
			* Close the preview form completely
			This.ActionClose()
		ENDIF

		* CLOSE DEBUGGER

	ENDPROC


	PROCEDURE DoMakePDFOffline

		LPARAMETERS tcFile
		IF EMPTY(m.tcFile)
			RETURN
		ENDIF 

		_goFP.cDestFile = m.tcFile
		&& Generate PDF from the offline table
		
		LOCAL lnPgMode
		m.lnPgMode = MAX(_goFP.nPDFPageMode - 1, 0)
		m.lnPgMode = IIF(m.lnPgMode = 1, 2, m.lnPgMode)

		LOCAL lnType
		m.lnType = IIF(_goFP.lPDFasImage, 2, 1)
			&& 1 = normal PDF, 2 = Image
	
		IF m.lnType = 1 THEN && Normal Pdf
			LOCAL loListener AS "PdfListener" OF "PR_PDFx.vcx"
			m.loListener = NEWOBJECT('PdfListener', 'PR_PDFx.vcx')
			m.loListener.cCodePage = _goFP.cCodePage &&CodePage

			* loListener.nPageMode = MAX(_goFP.nPDFPageMode - 1, 0)
			m.loListener.cTargetFileName = m.tcFile

			m.loListener.lEmbedFont       = _goFP.lPDFEmbedFonts
			m.loListener.lCanPrint        = _goFP.lPDFCanPrint
			m.loListener.lCanEdit         = _goFP.lPDFCanEdit
			m.loListener.lCanCopy         = _goFP.lPDFCanCopy
			m.loListener.lCanAddNotes     = _goFP.lPDFCanAddNotes
			m.loListener.lEncryptDocument = _goFP.lPDFEncryptDocument
			m.loListener.cMasterPassword  = _goFP.cPDFMasterPassword
			m.loListener.cUserPassword    = _goFP.cPDFUserPassword
			m.loListener.lShowErrors      = _goFP.lPDFShowErrors
			m.loListener.cSymbolFontsList = _goFP.cPDFSymbolFontsList

			m.loListener.cPdfAuthor       = _goFP.cPdfAuthor
			m.loListener.cPdfTitle        = _goFP.cPdfTitle
			m.loListener.cPdfSubject      = _goFP.cPdfSubject
			m.loListener.cPdfKeyWords     = _goFP.cPdfKeyWords
			m.loListener.cPdfCreator      = _goFP.cPdfCreator

			m.loListener.lReplaceFonts    = _goFP.lPdfReplaceFonts

			m.loListener.nPageMode        = m.lnPgMode
			m.loListener.cDefaultFont     = _goFP.cPDFDefaultFont
			m.loListener.QuietMode        = _goFP.lQuietMode

			LOCAL lcOutputDBF, lnWidth, lnHeight, llHasFJ
			m.lcOutputDBF = _goFP.oListener.GetFullFRXData()

			TRY 
				IF _goFP.oListener.lHasFJ
					m.loListener.lEmbedFont = .F.
				ENDIF 
			CATCH
			ENDTRY 

			IF NOT EMPTY(m.lcOutputDBF)
				m.lnWidth  = _goFP.oListener.GETPAGEWIDTH()
				m.lnHeight = _goFP.oListener.GETPAGEHEIGHT()
				m.loListener.OutputFromData(_goFP.oListener, m.lcOutputDBF, m.lnWidth, m.lnHeight)
				m.loListener = NULL
			ENDIF 

		ELSE &&PDF As Image
			LOCAL loListener AS "PDFasImageListener" OF "PR_Pdfx.vcx"
			m.loListener = NEWOBJECT('PDFasImageListener', 'PR_PDFx.vcx')

			m.loListener.lEncryptDocument = _goFP.lPDFEncryptDocument
			m.loListener.cMasterPassword  = _goFP.cPDFMasterPassword
			m.loListener.cUserPassword    = _goFP.cPDFUserPassword
			m.loListener.cPdfAuthor       = _goFP.cPdfAuthor
			m.loListener.cPdfTitle        = _goFP.cPdfTitle
			m.loListener.cPdfSubject      = _goFP.cPdfSubject
			m.loListener.cPdfKeyWords     = _goFP.cPdfKeyWords
			m.loListener.cPdfCreator      = _goFP.cPdfCreator
			m.loListener.QuietMode        = _goFP.lQuietMode

			m.loListener.cTargetFileName  = m.tcFile
			
			m.loListener.OutputFromData(_goFP.oListener, ;
							_goFP.oListener.GETPAGEWIDTH(), ;
							_goFP.oListener.GETPAGEHEIGHT())
		ENDIF

		&& Ensure the thermometer is removed
		IF NOT _goFP.lQuietMode
			=DoFoxyTherm()
		ENDIF

		IF NOT FILE(m.tcFile)
			_goFP.lSaved = .F.
			_goFP.SetError(_goFP.GetLoc("ERR_CREATI"))
			RETURN .F.
		ELSE

			_goFP.lSaved = .T.
			IF _goFP.lOpenViewer AND ;
					(_goFP._lSendingEmail = .F.)
				_goFP.OpenFile(m.tcFile)
			ENDIF

			RETURN .T.
		ENDIF
	ENDPROC 


	PROCEDURE DoMakeRTFOffline

		LPARAMETERS tcFile

		IF EMPTY(m.tcFile)
			RETURN
		ENDIF 

		_goFP.cDestFile = m.tcFile

		&& Generate RTF from the offline table
		LOCAL loRTFListener as ReportListener 
		m.loRtfListener = NEWOBJECT("RTFreportlistener", "PR_RTFListener")
		m.loRtfListener.TargetFileName  = m.tcFile
		m.loRtfListener.QuietMode       = _goFP.lQuietMode

		LOCAL lcOutputDBF, lnWidth, lnHeight
		m.lcOutputDBF = _goFP.oListener.GetFullFRXData()

		IF NOT EMPTY(m.lcOutputDBF)
			m.lnWidth  = _goFP.oListener.GETPAGEWIDTH()
			m.lnHeight = _goFP.oListener.GETPAGEHEIGHT()
			m.loRTFListener.OutputFromData(_goFP.oListener, m.lcOutputDBF, m.lnWidth, m.lnHeight)
			m.loRTFListener = NULL
		ENDIF 

		&& Ensure the thermometer is removed
		IF NOT _goFP.lQuietMode
			=DoFoxyTherm()
		ENDIF

		IF NOT FILE(m.tcFile)
			_goFP.lSaved = .F.
			_goFP.SetError(_goFP.GetLoc("ERR_CREATI"))
			RETURN .F.
		ELSE
			_goFP.lSaved = .T.
			IF _goFP.lOpenViewer AND (_goFP._lSendingEmail = .F.)
				_goFP.OpenFile(m.tcFile)
			ENDIF
			RETURN .T.
		ENDIF
	ENDPROC 


	PROCEDURE DoMakeXLSOffline
		LPARAMETERS tcFile

		IF EMPTY(m.tcFile)
			RETURN
		ENDIF

		_goFP.cDestFile = m.tcFile

		&& Generate XLS (XML worksheet) from the offline table
		LOCAL loXLSListener AS "ExcelListener" && OF HOME() + "FFC/PR_ReportListener.vcx"
		m.loXLSListener = NEWOBJECT("ExcelListener","pr_ExcelListener.vcx")
		m.loXLSListener.cWorkbookFile    = m.tcFile
		m.loXLSListener.cWorksheetName   = "Sheet"
		m.loXLSListener.cCodePage        = _goFP.cCodePage

		m.loXLSListener.lConvertToXLS    = _goFP.lExcelConvertToXLS  
		m.loXLSListener.lRepeatHeaders   = _goFP.lExcelRepeatHeaders
		m.loXLSListener.lRepeatFooters   = _goFP.lExcelRepeatFooters
		m.loXLSListener.lHidePageNo      = _goFP.lExcelHidePageNo
		m.loXLSListener.lAlignLeft       = _goFP.lExcelAlignLeft
		m.loXLSListener.nExcelSaveFormat = _goFP.nExcelSaveFormat

		IF NOT _goFP.lQuietMode
			=DoFoxyTherm(0, _goFP.GetLoc("PREPDATA") + "..." + SPACE(10) + ;
				_goFP.GetLoc("PLEASEWAIT"), _goFP._RunStatusText)
		ENDIF

		LOCAL lcOutputDBF, lnWidth, lnHeight
		m.lcOutputDBF = _goFP.oListener.GetFullFRXData()

		IF NOT EMPTY(m.lcOutputDBF)
			m.loXLSListener.OutputFromData(_goFP.oListener)
			m.loXLSListener = NULL
		ENDIF 

		&& Ensure the thermometer is removed
		IF NOT _goFP.lQuietMode
			=DoFoxyTherm()
		ENDIF

		IF NOT FILE(m.tcFile)
			_goFP.lSaved = .F.
			_goFP.SetError(_goFP.GetLoc("ERR_CREATI"))
			RETURN .F.
		ELSE
			_goFP.lSaved = .T.
			IF _goFP.lOpenViewer AND (_goFP._lSendingEmail = .F.)
				_goFP.OpenFile(m.tcFile)
			ENDIF
			RETURN .T.
		ENDIF
	ENDPROC 



	PROCEDURE DoMakeHTMLOffline_old

		LPARAMETERS tcFile

		IF EMPTY(m.tcFile)
			RETURN
		ENDIF

		_goFP.cDestFile = m.tcFile

		LOCAL loListener AS "HTMLListener" && OF HOME() + "FFC/PR_ReportListener.vcx"
		m.loListener = NEWOBJECT("PR_HTMLListener", "PR_ReportListener.vcx")
		m.loListener.TargetFileName = _goFP.cDestFile
		m.loListener.QUIETMODE = _goFP.lQuietMode
		m.loListener.fxFeedbackClass = _goFP._cThermClass

		LOCAL lcOutputDBF, lnWidth, lnHeight
		m.lcOutputDBF = _goFP.oListener.GetFullFRXData()

		IF NOT EMPTY(m.lcOutputDBF)
			m.lnWidth  = _goFP.oListener.GETPAGEWIDTH()
			m.lnHeight = _goFP.oListener.GETPAGEHEIGHT()
			m.loListener.OutputFromData(_goFP.oListener, m.lcOutputDBF, m.lnWidth, m.lnHeight)
			m.loListener = NULL
		ENDIF 

		IF NOT FILE(m.tcFile)
			_goFP.lSaved = .F.
			_goFP.SetError(_goFP.GetLoc("ERR_CREATI"))
			RETURN .F.
		ELSE
			_goFP.lSaved = .T.
			IF _goFP.lOpenViewer AND (_goFP._lSendingEmail = .F.)
				_goFP.OpenFile(m.tcFile)
			ENDIF
			RETURN .T.
		ENDIF
	ENDPROC 



	PROCEDURE DoMakeHTMLOffline

		LPARAMETERS tcFile, tlTemp

		IF EMPTY(m.tcFile)
			RETURN
		ENDIF 

		_goFP.cDestFile = m.tcFile

		&& Generate RTF from the offline table
		LOCAL loHTMLListener as ReportListener 
		m.loHTMLListener = NEWOBJECT("pr_HTMLListener2", "PR_HTMLListener2")
		m.loHTMLListener.cTargetFileName = m.tcFile
		m.loHTMLListener.QuietMode       = _goFP.lQuietMode

		LOCAL lcOutputDBF, lnWidth, lnHeight
		m.lcOutputDBF = _goFP.oListener.GetFullFRXData()

		IF NOT EMPTY(m.lcOutputDBF)
			m.lnWidth  = _goFP.oListener.GETPAGEWIDTH()
			m.lnHeight = _goFP.oListener.GETPAGEHEIGHT()
			m.loHTMLListener.OutputFromData(_goFP.oListener, m.lcOutputDBF, m.lnWidth, m.lnHeight)
			m.loHTMLListener = NULL
		ENDIF 

		IF NOT _goFP.lQuietMode
			=DoFoxyTherm()
		ENDIF

		IF NOT FILE(m.tcFile)
			_goFP.lSaved = .F.
			_goFP.SetError(_goFP.GetLoc("ERR_CREATI"))
			RETURN .F.
		ELSE
			_goFP.lSaved = .T.
			
			IF m.tlTemp = .T.
			
			ELSE
				IF _goFP.lOpenViewer AND (_goFP._lSendingEmail = .F.)
					_goFP.OpenFile(m.tcFile)
				ENDIF
			ENDIF
			RETURN .T.
		ENDIF
	ENDPROC 



	PROCEDURE DoSendEmail

		* Ensure the proof sheet is closed
		_goFP.CloseSheets()

		LOCAL lcFile, lcFolder, lcExtensions

		IF _goFP.lCompleteMode
			m.lcExtensions = "Pdf;Rtf;Xls;Xml;Png;Tiff;Bmp;Gif;Emf;Jpg;Htm"
		ELSE
			m.lcExtensions = "Pdf;Rtf;Xls;Xml;Png;Tiff;Bmp;Gif;Emf;Jpg;Htm"
		ENDIF 
		
		*	lEmailAuto = .T. && Automatically generates the report output file
		*	cEmailType = "PDF" && The file type to be used in Emails (PDF, RTF, HTML, XML or XLS)
		IF _goFP.lEmailAuto
			m.lcFolder = ADDBS(GETENV("TEMP"))

				*!* 2010-09-17 - Jacques Parent - Add the cSaveDefName
				IF EMPTY(_goFP.cSaveDefName)
					IF _goFP.lCompleteMode
						m.lcFile = FORCEEXT(JUSTSTEM(JUSTFNAME(;
						_goFP.oListener.PrintJobName)), _goFP.cEmailType) && EVL(_goFP._oNames(n), loListener.PrintJobName)
					ELSE 
					
						IF NOT (LOWER(_goFP.cEmailType) $ LOWER(m.lcExtensions))
							_goFP.cEmailType = "PDF"
						ENDIF 
						m.lcFile = m.lcFolder + FORCEEXT(JUSTSTEM(JUSTFNAME(_goFP._cFRXName)), _goFP.cEmailType)

					ENDIF 
				ELSE
					m.lcFile = m.lcFolder + FORCEEXT(JUSTFNAME(_goFP.cSaveDefName), _goFP.cEmailType)
				ENDIF
		ELSE
			*!* 2010-09-17 - Jacques Parent - Add the cSaveDefName
			m.lcFile = PR_XPUTFILE(_goFP.GetLoc("SAVEAS"), _goFP.cSaveDefName, m.lcExtensions)
		ENDIF

		IF EMPTY(m.lcFile)
			RETURN
		ENDIF


		_goFP.lSaved = .F.  && Reset the lSaved property because we'll need to create the output again
		_goFP.cDestFile = m.lcFile
		_goFP._lSendingEmail = .T.


		LOCAL lcFileFormat
		m.lcFileFormat = LOWER(JUSTEXT(m.lcFile))

		DO CASE
		CASE INLIST(m.lcFileFormat, "png", "bmp", "jpg", "gif", "tif", "emf")
			LOCAL loListener
			m.loListener = This.PreviewForm.oReport
			_goFP.lSaved = Report2Pic(m.loListener, m.lcFile, JUSTEXT(m.lcFile))
			m.loListener = NULL
			IF NOT FILE(_goFP.cDestFile)
				_goFP.lSaved = .F.
				_goFP.SetError(_goFP.GetLoc("ERR_CREATI"))
			ELSE
				_goFP.lSaved = .T.
			ENDIF
			_goFP.SendReportToEmail()


		CASE (m.lcFileFormat =  "pdf") AND (NOT _goFP.lCompleteMode)
			IF This.DoMakePDFOffline(m.lcFile)
				_goFP.SendReportToEmail()
			ENDIF 

		CASE (m.lcFileFormat =  "rtf") AND (NOT _goFP.lCompleteMode)
			IF This.DoMakeRTFOffline(m.lcFile)
				_goFP.SendReportToEmail()
			ENDIF 

		CASE (INLIST(m.lcFileFormat, "xls", "xml")) AND (NOT _goFP.lCompleteMode)
			IF This.DoMakeXLSOffline(m.lcFile)
				_goFP.SendReportToEmail()
			ENDIF 
	
		OTHERWISE

		ENDCASE


		* Close the preview form completely
		IF _goFP.lCompleteMode
			This.ActionClose()
		ENDIF 

		IF _goFP.lCompleteMode AND ;
				_goFP.lSaved = .F. AND ;
				_goFP._lNoWait AND ; && Top form
				NOT EMPTY(_goFP.cDestFile) && Selected a file output
			_goFP.DoOutput()
		ENDIF

	ENDPROC


	PROCEDURE HandledKeyPress( nKeyCode, nShiftAltCtrl )
		RETURN .F.
	ENDPROC

	PROCEDURE RELEASE
		IF ISDEBUGGING
			SET STEP ON 
		ENDIF 
		RETURN .T.
	ENDPROC

	PROCEDURE DESTROY
		IF ISDEBUGGING
			SET STEP ON 
		ENDIF 
		RETURN .T.
	ENDPROC

ENDDEFINE
*-- END CODE


* Included controls classes

DEFINE CLASS BoxLine AS Line
	.Width = 0
	.BorderWidth = 0
	.Height = 0
	.Visible = .T.
ENDDEFINE

DEFINE CLASS cmdReport AS COMMANDBUTTON
	CAPTION = ""
	WIDTH   = _goFP._nBtSize + 2 && 24
	HEIGHT  = _goFP._nBtSize && 22
	SPECIALEFFECT = 2 && Hot tracking

ENDDEFINE

DEFINE CLASS cntCopies AS CONTAINER
	BACKSTYLE = 0 && Transparent
	BORDERWIDTH = 0
	HEIGHT = 23
	WIDTH = 30
	VISIBLE = .T.

	ADD OBJECT SpnCopies1 AS spnCopies
	ADD OBJECT LblCopies1 AS lblCopies

	PROCEDURE INIT
		* This.AdjustControls()
	ENDPROC

	PROCEDURE AdjustControls
		WITH THIS
			LOCAL lcCopiesCaption
			m.lcCopiesCaption = _goFP.GetLoc("COPIES")
			.LblCopies1.CAPTION = m.lcCopiesCaption
			.LblCopies1.AUTOSIZE = .T.
			.LblCopies1.TOP = (_goFP._nBtSize - .LblCopies1.HEIGHT) / 2
			.LblCopies1.TOOLTIPTEXT = m.lcCopiesCaption
			.SpnCopies1.TOOLTIPTEXT = m.lcCopiesCaption
			.TOOLTIPTEXT = m.lcCopiesCaption

			LOCAL lnTxtWidth
			m.lnTxtWidth = TXTWIDTH(m.lcCopiesCaption, ;
				.LblCopies1.FONTNAME, ;
				.LblCopies1.FONTSIZE) * ;
				FONTMETRIC(6, .LblCopies1.FONTNAME,.LblCopies1.FONTSIZE)
			.LblCopies1.LEFT = 2
			.SpnCopies1.LEFT = m.lnTxtWidth + 4
			.SpnCopies1.WIDTH = .SpnCopies1.WIDTH + IIF(.SpnCopies1.FONTSIZE > 10,4,0)
			.WIDTH = m.lnTxtWidth + 2 + .SpnCopies1.WIDTH + 2
		ENDWITH
	ENDPROC

	PROCEDURE Enabled_Assign
		LPARAMETERS tlEnabled
		LOCAL loControl as CommandButton 
		FOR EACH m.loControl IN This.Controls
			m.loControl.Enabled = m.tlEnabled
		ENDFOR 
	ENDPROC 

ENDDEFINE


DEFINE CLASS spnCopies AS SPINNER
	WIDTH   = 42
	HEIGHT  = 22
	SPECIALEFFECT = 2 && Hot tracking
	INCREMENT = 1
	SPINNERHIGHVALUE = 99
	SPINNERLOWVALUE = 1
	KEYBOARDHIGHVALUE = 99
	KEYBOARDLOWVALUE = 1
	VISIBLE = .T.

	PROCEDURE INIT
		This.VALUE = _goFP.nCopies
	ENDPROC

	PROCEDURE INTERACTIVECHANGE
		_goFP.nCopies = This.VALUE
	ENDPROC
ENDDEFINE


DEFINE CLASS lblCopies AS LABEL
	AUTOSIZE = .T.
	BACKSTYLE = 0 && Transparent
	TOP = 2
	VISIBLE = .T.
ENDDEFINE


DEFINE CLASS cmdSave AS cmdReport
	PICTURE     = PR_IMGBTN_SAVE
	VISIBLE     = .T.

	PROCEDURE CLICK
	* This.Parent.PreviewForm.ExtensionHandler.DoSave()
		This.PARENT.CmbSave1.VALUE = ""
		This.PARENT.CmbSave1.SETFOCUS()

		IF SET("Keycomp") = "DOS"
			KEYBOARD '{ENTER}' 
		ELSE 
			IF NVL(_goFP.lDoubleByteLanguage, .F.) OR ;
					INLIST(UPPER(ALLTRIM(_goFP.cLanguage)), "CHINESE", "TCHINESE", "JAPANESE", "KOREAN")
				KEYBOARD '{F4}' 
			ELSE 
				KEYBOARD "{ALT+DNARROW}"
			ENDIF
		ENDIF
	ENDPROC

	PROCEDURE INIT
		This.PICTURE = This.PARENT.PreviewForm.ExtensionHandler.IMGBTN_SAVE
	ENDPROC
ENDDEFINE


DEFINE CLASS cmbSave AS COMBOBOX
	HEIGHT      = 1
	WIDTH       = 1
	VISIBLE     = .T.
	nIndex      = 0

	PROCEDURE DROPDOWN
		This.VALUE = ""
		This.nIndex = 0
	ENDPROC

	PROCEDURE VALID
		IF NOT EMPTY(This.VALUE)
			LOCAL lnIndex
			m.lnIndex = VAL(This.LIST(This.LISTINDEX,2))
			This.nIndex = m.lnIndex
			This.VALUE = ""
			This.PARENT.PreviewForm.ExtensionHandler.DoSave(m.lnIndex)
		ENDIF
	ENDPROC

ENDDEFINE


DEFINE CLASS cmdPrinterProps AS cmdReport
	PICTURE     = PR_IMGBTN_PRINTPREF
	VISIBLE     = .T.

	PROCEDURE CLICK
		This.PARENT.PreviewForm.ExtensionHandler.DoCustomPrint()
	ENDPROC

	PROCEDURE INIT
		This.PICTURE = This.PARENT.PreviewForm.ExtensionHandler.IMGBTN_PRINTPREF
	ENDPROC

ENDDEFINE


DEFINE CLASS cmdSetup AS cmdReport
	PICTURE     = PR_IMGBTN_SETUP
	VISIBLE     = .T.

	PROCEDURE CLICK
		This.PARENT.PreviewForm.ExtensionHandler.DoSetup()
	ENDPROC

	PROCEDURE INIT
		This.PICTURE = This.PARENT.PreviewForm.ExtensionHandler.IMGBTN_SETUP
	ENDPROC

ENDDEFINE


DEFINE CLASS cmdEmail AS cmdReport
	PICTURE     = PR_IMGBTN_EMAIL
	VISIBLE     = .T.

	PROCEDURE CLICK
		This.PARENT.PreviewForm.ExtensionHandler.DoSendEmail()
	ENDPROC

	PROCEDURE INIT
		This.PICTURE = This.PARENT.PreviewForm.ExtensionHandler.IMGBTN_EMAIL
	ENDPROC

ENDDEFINE


DEFINE CLASS cmdExit AS cmdReport
	PICTURE     = PR_IMGBTN_CLOSE
	VISIBLE     = .T.

	PROCEDURE CLICK
		* Hide the Preview form
		This.PARENT.PreviewForm.VISIBLE = .F.


		IF VARTYPE(_goFP) = "O"
			_goFP.lPrinted = .F.

			* Ensure the proof sheet is closed
			_goFP.CloseSheets()

			* Close the report window
		ENDIF
	
		This.PARENT.PreviewForm.ExtensionHandler.ActionClose()
	ENDPROC

	PROCEDURE MOUSEENTER
		LPARAMETERS nButton, nShift, nXCoord, nYCoord
		This.PICTURE = This.PARENT.PreviewForm.ExtensionHandler.IMGBTN_CLOSE2
	ENDPROC

	PROCEDURE MOUSELEAVE
		LPARAMETERS nButton, nShift, nXCoord, nYCoord
		This.PICTURE = This.PARENT.PreviewForm.ExtensionHandler.IMGBTN_CLOSE
	ENDPROC

	PROCEDURE INIT
		This.PICTURE = This.PARENT.PreviewForm.ExtensionHandler.IMGBTN_CLOSE
	ENDPROC
ENDDEFINE



DEFINE CLASS cmdPrintEx AS cmdReport
	PICTURE     = PR_IMGBTN_PRINT
	VISIBLE     = .T.

	PROCEDURE INIT
		This.TOOLTIPTEXT = PR_PRINTREPOR
	ENDPROC

	PROCEDURE RIGHTCLICK
	* This.Parent.PreviewForm.ExtensionHandler.DoCustomPrint()
	ENDPROC

	PROCEDURE CLICK
		This.PARENT.PreviewForm.ExtensionHandler.ActionPrintEx()
	ENDPROC

	PROCEDURE INIT
		This.PICTURE = This.PARENT.PreviewForm.ExtensionHandler.IMGBTN_PRINT
	ENDPROC
ENDDEFINE


DEFINE CLASS cmdGotoEx AS cmdReport
	PICTURE     = PR_IMGBTN_GOTOPG
	VISIBLE     = .T.

	PROCEDURE CLICK
		This.PARENT.PARENT.PreviewForm.ExtensionHandler.ActionGotoPage()
	ENDPROC

	PROCEDURE INIT
	ENDPROC

ENDDEFINE


DEFINE CLASS cntSearch AS CONTAINER
	BACKSTYLE = 0 && Transparent
	BORDERWIDTH = 0
	HEIGHT = 23
	WIDTH = 30
	VISIBLE = .T.

	ADD OBJECT CmdSearch1      AS cmdSearch
	ADD OBJECT CmdSearchAgain1 AS cmdSearchAgain
	ADD OBJECT CmdSearchBack1  AS cmdSearchBack

	PROCEDURE AdjustControls
	ENDPROC
	
	PROCEDURE Enabled_Assign
		LPARAMETERS tlEnabled
		LOCAL loControl as CommandButton 
		FOR EACH m.loControl IN This.Controls
			m.loControl.Enabled = m.tlEnabled
		ENDFOR 
	ENDPROC 
	
ENDDEFINE


DEFINE CLASS cmdSearch AS cmdReport
	PICTURE     = PR_IMGBTN_SEARCH
	VISIBLE     = .T.

	PROCEDURE CLICK
		This.PARENT.Parent.PreviewForm.ExtensionHandler.DoSearch()
	ENDPROC

	PROCEDURE INIT
		This.PICTURE = This.PARENT.Parent.PreviewForm.ExtensionHandler.IMGBTN_SEARCH
	ENDPROC
ENDDEFINE


DEFINE CLASS cmdSearchAgain AS cmdReport
	PICTURE     = PR_IMGBTN_SEARCHAGAIN
	VISIBLE     = .T.

	PROCEDURE CLICK
		This.PARENT.Parent.PreviewForm.ExtensionHandler.DoSearchAgain()
	ENDPROC

	PROCEDURE INIT
		This.PICTURE = This.PARENT.Parent.PreviewForm.ExtensionHandler.IMGBTN_SEARCHAGAIN
	ENDPROC

ENDDEFINE



DEFINE CLASS cmdSearchBack AS cmdReport
	PICTURE     = PR_IMGBTN_SEARCHBACK
	VISIBLE     = .T.

	PROCEDURE CLICK
		This.PARENT.Parent.PreviewForm.ExtensionHandler.DoSearchBack()
	ENDPROC

	PROCEDURE INIT
		This.PICTURE = This.PARENT.Parent.PreviewForm.ExtensionHandler.IMGBTN_SEARCHBACK
	ENDPROC

ENDDEFINE


DEFINE CLASS cmbPrinters AS COMBOBOX
	WIDTH = 200
	COLUMNCOUNT = 2
	COLUMNLINES = .F.
	ROWSOURCETYPE = 0 && None
	COLUMNWIDTHS = "220,140"
	STYLE = 2 && DropDown List
	VISIBLE = .T.
	_cOriginalPrinter = ""

	PROCEDURE INIT

		LOCAL lcDefPrinter, lcCurrPrinter, lnPrinters, n
		LOCAL ARRAY laPrinters(1)
		m.lnPrinters = APRINTERS(m.laPrinters)
		m.lcDefPrinter = SET("Printer",3)

		WITH THIS AS COMBOBOX

			FOR m.n = 1 TO m.lnPrinters
				m.lcCurrPrinter = m.laPrinters(m.n, 1)
				IF UPPER(ALLTRIM(m.lcDefPrinter)) = UPPER(ALLTRIM(m.lcCurrPrinter))
					m.lcDefPrinter = m.lcCurrPrinter
					.ADDITEM(m.lcCurrPrinter)

					* by Brian Abbott
					* This stops a virtual printer with no port showing the port as NUL: in column 2 of cmbPrinters
					.LIST(.NEWINDEX, 2) = STRTRAN(NVL(m.laPrinters(m.N, 2), ""), 'NUL:', '')
					EXIT
				ENDIF
			ENDFOR

			FOR m.N = 1 TO m.lnPrinters && ALEN(laPrinters) STEP 2
				m.lcCurrPrinter = m.laPrinters(m.N, 1)
				IF NOT (UPPER(ALLTRIM(m.lcDefPrinter)) = UPPER(ALLTRIM(m.lcCurrPrinter)))
					.ADDITEM(m.lcCurrPrinter)
					
					* by Brian Abbott
					* This stops a virtual printer with no port showing the port as NUL: in column 2 of cmbPrinters
					.LIST(.NEWINDEX, 2) = STRTRAN(NVL(m.laPrinters(m.N, 2), ""), 'NUL:', '')

				ENDIF
			ENDFOR

			* .Value = lcDefPrinter
			.LISTINDEX = 1
			._cOriginalPrinter = m.lcDefPrinter

			LOCAL lcItem
			FOR m.N = 1 TO .LISTCOUNT
				m.lcItem = .LIST(m.N, 1)
				IF LEFT(m.lcItem, 1) = "\"
					.LIST(m.N, 1) = "\\" + m.lcItem
				ENDIF

				m.lcItem = .LIST(m.N, 2)
				IF LEFT(m.lcItem, 1) = "\"
					.LIST(m.N, 2) = "\\" + m.lcItem
				ENDIF
			ENDFOR

		ENDWITH
	ENDPROC

	PROCEDURE VALID
		LOCAL lcValue, lcOrigPrinter
		m.lcValue = This.VALUE
		m.lcOrigPrinter = _goFP._cOriginalPrinter

		IF LEFT(m.lcValue,1) = "\" AND SUBSTR(m.lcValue,2,1) <> "\"
			m.lcValue = "\" + m.lcValue
		ENDIF

		* IF ALLTRIM(UPPER(m.lcValue)) <> ALLTRIM(UPPER(m.lcOrigPrinter))
			_goFP.cPrinterName = m.lcValue
		* ENDIF
	ENDPROC

ENDDEFINE

DEFINE CLASS cmdProof AS cmdReport
	PICTURE = PR_IMGBTN_MINI
	VISIBLE = .T.

	PROCEDURE CLICK()
		This.PARENT.PreviewForm.ExtensionHandler.DoProof()
	ENDPROC

	PROCEDURE INIT
		This.PICTURE = This.PARENT.PreviewForm.ExtensionHandler.IMGBTN_MINI
	ENDPROC
ENDDEFINE


DEFINE CLASS cntCanvas AS Container
	BackStyle = 0 
	BorderWidth = 0
ENDDEFINE



**************************************************
*-- Class:        frxgotopageform
*-- ParentClass:  frmReport
*-- BaseClass:    form
*
DEFINE CLASS CustomFrxGotoPageForm AS frmReport
	DESKTOP = .T.
	HEIGHT = 92
	WIDTH = 345
	SHOWWINDOW = 1
	DOCREATE = .T.
	AUTOCENTER = .T.
	BORDERSTYLE = 2
	CLOSABLE = .F.
	MAXBUTTON = .F.
	MINBUTTON = .F.
	ALWAYSONTOP = .T.
	ALLOWOUTPUT = .F.
*-- Provides the current page number for report output.
	PAGENO = 0
*-- Provides a PageTotal for report output.
	PAGETOTAL = 0
	oParentForm = (.NULL.)
	NAME = "frxgotopageform"

	ADD OBJECT shp1 AS SHAPE WITH ;
		TOP = 15, ;
		LEFT = 12, ;
		HEIGHT = 66, ;
		WIDTH = 224, ;
		BACKSTYLE = 0, ;
		ZORDERSET = 0, ;
		STYLE = 3, ;
		NAME = "Shp1"

	ADD OBJECT spnpageno AS SPINNER WITH ;
		HEIGHT = 21, ;
		INPUTMASK = "9999", ;
		LEFT = 64, ;
		TOP = 36, ;
		WIDTH = 126, ;
		ZORDERSET = 1, ;
		NAME = "spnPageno"

	ADD OBJECT lblcaption AS LABEL WITH ;
		LEFT = 20, ;
		TOP = 8, ;
		ZORDERSET = 2, ;
		STYLE = 3, ;
		NAME = "lblCaption", ;
		AUTOSIZE = .T.

	ADD OBJECT cmdok AS cmdReport WITH ;
		TOP = 15, ;
		LEFT = 248, ;
		WIDTH = 84, ;
		HEIGHT = 25, ;
		DEFAULT = .T., ;
		ZORDERSET = 3, ;
		NAME = "cmdOK", ;
		SPECIALEFFECT = 0 && 3D

	ADD OBJECT cmdcancel AS cmdReport WITH ;
		TOP = 47, ;
		LEFT = 248, ;
		WIDTH = 84, ;
		HEIGHT = 25, ;
		ZORDERSET = 4, ;
		NAME = "cmdCancel", ;
		SPECIALEFFECT = 0, ; && 3D
		CANCEL = .F.


	PROCEDURE SHOW
		LPARAMETERS nStyle
		*-----------------------------------------
		* Fix for SP1: Handle positioning in top-level form
		* See frxPreviewForm::ActionGoToPage()
		* Addresses bug# 474691
		*-----------------------------------------
		This.PAGENO    = This.oParentForm.currentPage
		This.PAGETOTAL = This.oParentForm.PAGETOTAL

		This.CAPTION   = _goFP.GetLoc("REPORTTITL")
		This.lblcaption.CAPTION = _goFP.GetLoc("GOTOPG_CAP") + " (1-" + TRANSFORM(This.PAGETOTAL) + ")"

		IF This.oParentForm.SHOWWINDOW = 2 && as top-level form
			*-----------------------------------
			* If parent preview window is a top-level form,
			* center the child window in the view port:
			*-----------------------------------
			This.AUTOCENTER = .F.
			This.LEFT = This.oParentForm.VIEWPORTLEFT + INT(This.oParentForm.WIDTH/2  - This.WIDTH/2)
			This.TOP  = This.oParentForm.VIEWPORTTOP  + INT(This.oParentForm.HEIGHT/2 - This.HEIGHT/2)
		ELSE
			This.AUTOCENTER = .T.
		ENDIF
*--------------

		This.spnpageno.SPINNERLOWVALUE = 1
		This.spnpageno.SPINNERHIGHVALUE = This.PAGETOTAL

		This.spnpageno.KEYBOARDLOWVALUE = 1
		This.spnpageno.KEYBOARDHIGHVALUE = This.PAGETOTAL

		This.spnpageno.VALUE = This.PAGENO

		DODEFAULT(m.nStyle)
	ENDPROC

	PROCEDURE INIT
		IF NOT DODEFAULT()
			RETURN .F.
		ENDIF
		This.cmdok.CAPTION     = _goFP.GetLoc("GOTOPG_OK")
		This.cmdcancel.CAPTION = _goFP.GetLoc("CANCEL")
	ENDPROC

	PROCEDURE spnpageno.LOSTFOCUS
		IF This.VALUE < This.SPINNERLOWVALUE
			This.VALUE = 1
		ENDIF
		IF This.VALUE > This.SPINNERHIGHVALUE
			This.VALUE = This.SPINNERHIGHVALUE
		ENDIF
		DODEFAULT()
	ENDPROC

	PROCEDURE cmdok.CLICK
		This.PARENT.PAGENO = This.PARENT.spnpageno.VALUE
		This.PARENT.HIDE()
	ENDPROC

	PROCEDURE cmdcancel.CLICK
		This.PARENT.HIDE()
		Thisform.Release()
	ENDPROC

ENDDEFINE
*-- EndDefine: frxgotopageform
**************************************************


**************************************************
*-- Class:        frmReport
*-- ParentClass:  form
*-- BaseClass:    form
*-- Author:       CChalom
DEFINE CLASS frmReport AS FORM
	ICON 	 = PR_FORMICON
	SHOWTIPS = .T.
PROCEDURE Init
	IF VARTYPE(_goFP) = "O"
		IF NOT EMPTY(_goFP.cFormIcon)
			This.Icon = _goFP.cFormIcon
		ENDIF
	ENDIF
ENDDEFINE
*-- EndDefine: frxgotopageform
**************************************************


**************************************************
*-- Class:        proofshape
*-- ParentClass:  shape
*-- BaseClass:    shape
*-- Author:       Colin Nicholls
DEFINE CLASS proofshape AS SHAPE
	HEIGHT = 110
	WIDTH = 85

*-- Provides the current page number for report output.
	PAGENO = 0
	NAME = "proofshape"

	PROCEDURE MOUSELEAVE
		LPARAMETERS nButton, nShift, nXCoord, nYCoord
		This.MOUSEPOINTER = 0 && Default
		* This.ResetToDefault("BorderColor")
	ENDPROC

	PROCEDURE MOUSEENTER
		LPARAMETERS nButton, nShift, nXCoord, nYCoord
		This.MOUSEPOINTER = 15 && Hand
		* This.BorderColor = RGB(255,0,0) && Red
		This.PARENT.nCurrShape = This.PAGENO
	ENDPROC

	PROCEDURE CLICK
		THISFORM.currentPage = This.PAGENO
		THISFORM.HIDE()
		ACTIVATE SCREEN
	ENDPROC
ENDDEFINE
*-- EndDefine: proofshape
**************************************************


**************************************************
*-- Class:        PageSetBtn
*-- ParentClass:  Commandbutton
*-- BaseClass:    Commandbutton
*-- Author:       Jacques Parent
DEFINE CLASS PageSetBtn AS COMMANDBUTTON
	HEIGHT 	= _goFP._nBtSize
	WIDTH 	= _goFP._nBtSize
	CAPTION	= ""
	cType	= "NEXT"

	PROCEDURE CLICK
		DO CASE
		CASE This.cType == "FIRST"
			This.PARENT.nPageSet = 1

		CASE This.cType == "PREV"
			This.PARENT.nPageSet = This.PARENT.nPageSet - 1

		CASE This.cType == "NEXT"
			This.PARENT.nPageSet = This.PARENT.nPageSet + 1

		CASE This.cType == "LAST"
			This.PARENT.nPageSet = CEILING(This.PARENT.nPages / This.PARENT.nMaxMiniatureItem)

		ENDCASE

		This.PARENT.RefreshPageBtn()
	ENDPROC

	PROCEDURE REFRESH
		DO CASE
		CASE This.cType == "FIRST"
			This.ENABLED = NOT (This.PARENT.nPageSet == 1)

		CASE This.cType == "PREV"
			This.ENABLED = NOT (This.PARENT.nPageSet == 1)

		CASE This.cType == "NEXT"
			This.ENABLED = NOT (This.PARENT.nPageSet == CEILING(This.PARENT.nPages / This.PARENT.nMaxMiniatureItem))

		CASE This.cType == "LAST"
			This.ENABLED = NOT (This.PARENT.nPageSet == CEILING(This.PARENT.nPages / This.PARENT.nMaxMiniatureItem))

		ENDCASE
	ENDPROC

ENDDEFINE
*-- EndDefine: PageSetBtn
**************************************************



#DEFINE SPACE_PIXELS 10
**************************************************
*-- Class:        proofsheet
*-- ParentClass:  form
*-- BaseClass:    form
*-- Author:       Colin Nicholls
*-- Adapted to FoxyPreviewer by CChalom and Jacques PArent
DEFINE CLASS proofsheet AS frmReport
	HEIGHT 				= 274
	WIDTH 				= 622
	SCROLLBARS 			= 3
	DOCREATE 			= .T.
	AUTOCENTER 			= .T.
	SHOWWINDOW 			= 1 && In Top-Level Form
	DESKTOP				= .T.

	currentPage 		= 0
	REPORTLISTENER 		= .NULL.
	lstarted 			= .F.
	nPages 				= 1
	lpainted 			= .F.
	nCurrShape 			= 0
	NAME 				= "proofsheet"

	nPageSet			= 1
	lShowDone			= .F.
	linactive           = .F.

	nOtherThenProofObj	= 0
	nMaxMiniatureItem	= 64

	OldEscFUNCTION		= ""


	PROCEDURE INIT
	
		IF NOT DODEFAULT()
			RETURN .F.
		ENDIF
	
		This.ADDOBJECT("PageSetFirst","PageSetBtn")
		This.nOtherThenProofObj = This.nOtherThenProofObj + 1

		WITH This.PageSetFirst
			.TOP  		= 3
			.LEFT 		= SPACE_PIXELS

			.CAPTION 	= ""
			.PICTURE 	= PR_IMGBTN_TOP
			.TOOLTIPTEXT= _goFP.GetLoc("MINIFIRSTT")

			.cType		= "FIRST"
			.VISIBLE 	= .F.
		ENDWITH

		This.ADDOBJECT("PageSetPrev","PageSetBtn")
		This.nOtherThenProofObj = This.nOtherThenProofObj + 1

		WITH This.PageSetPrev
			.TOP  		= 3
			.LEFT 		= This.PageSetFirst.LEFT + This.PageSetFirst.WIDTH + 2

			.CAPTION 	= ""
			.PICTURE 	= PR_IMGBTN_PREV
			.TOOLTIPTEXT= _goFP.GetLoc("MINIPREVTI")

			.cType		= "PREV"
			.VISIBLE 	= .F.
		ENDWITH

		This.ADDOBJECT("PageSetNext","PageSetBtn")
		This.nOtherThenProofObj = This.nOtherThenProofObj + 1

		WITH This.PageSetNext
			.TOP  		= 3
			.LEFT 		= This.PageSetPrev.LEFT + This.PageSetPrev.WIDTH + 2

			.CAPTION 	= ""
			.PICTURE 	= PR_IMGBTN_NEXT
			.TOOLTIPTEXT= _goFP.GetLoc("MININEXTTI")

			.cType		= "NEXT"
			.VISIBLE 	= .F.
		ENDWITH

		This.ADDOBJECT("PageSetLast","PageSetBtn")
		This.nOtherThenProofObj = This.nOtherThenProofObj + 1

		WITH This.PageSetLast
			.TOP  		= 3
			.LEFT 		= This.PageSetNext.LEFT + This.PageSetNext.WIDTH + 2

			.CAPTION 	= ""
			.PICTURE 	= PR_IMGBTN_BOTT
			.TOOLTIPTEXT= _goFP.GetLoc("MINILASTTI")

			.cType		= "LAST"
			.VISIBLE 	= .F.
		ENDWITH


		This.ADDOBJECT("PageSetCaption","Label")
		This.nOtherThenProofObj = This.nOtherThenProofObj + 1

		WITH This.PageSetCaption
			.LEFT 		= This.PageSetLast.LEFT + This.PageSetLast.WIDTH + 10
			.AUTOSIZE 	= .T.

			.CAPTION 	= ""
			.FONTNAME	= "Arial"
			.FONTSIZE	= 10
			.FONTBOLD 	= .T.

			.TOP  		= This.PageSetNext.TOP + ((This.PageSetNext.HEIGHT-.HEIGHT)/2)

			.VISIBLE 	= .F.
		ENDWITH

		*!* Let the form be deactivated with the EACAPE key
		This.OldEscFUNCTION = ON("KEY", "ESCAPE")
		ON KEY LABEL ESCAPE _VFP.ACTIVEFORM.RELEASE()

	ENDPROC

	PROCEDURE RefreshPageBtn
		This.PageSetNext.REFRESH()
		This.PageSetPrev.REFRESH()
	ENDPROC

	PROCEDURE SetReport
		LPARAMETERS oReport
		This.REPORTLISTENER = m.oReport
		This.nPages = m.oReport.OUTPUTPAGECOUNT
	ENDPROC

	PROCEDURE RESIZE

		IF This.WINDOWSTATE = 1 && Minimized
			This.linactive = .T.
		ELSE
			IF This.linactive = .T.
				This.lShowDone = .F.
				This.PAINT()
				This.linactive = .F.
			ENDIF
		ENDIF

		This.SHOW()
	ENDPROC

	PROCEDURE ACTIVATE
		This.lShowDone = .F.
	ENDPROC

	PROCEDURE QUERYUNLOAD
		This.HIDE()
		ACTIVATE SCREEN
	ENDPROC

	PROCEDURE nPageSet_assign
		LPARAMETERS vNewValue

		DO CASE
		CASE  (This.nPageSet == CEILING(This.nPages / This.nMaxMiniatureItem)) ;
				AND (m.vNewValue <> CEILING(This.nPages / This.nMaxMiniatureItem))
			* We have to display ALL miniatures

			FOR m.i = This.nOtherThenProofObj+1 TO This.OBJECTS.COUNT
				IF NOT This.OBJECTS[m.i].VISIBLE
					This.OBJECTS[m.i].VISIBLE = .T.
				ENDIF
			ENDFOR

		CASE (This.nPageSet <> CEILING(This.nPages / This.nMaxMiniatureItem)) ;
				AND (m.vNewValue == CEILING(This.nPages / This.nMaxMiniatureItem))
				*!* We have to display only some miniatures

			FOR m.i = This.nOtherThenProofObj+1 TO This.OBJECTS.COUNT

				IF m.i > This.nPages - ((CEILING(This.nPages / This.nMaxMiniatureItem)-1) * ;
						This.nMaxMiniatureItem) + This.nOtherThenProofObj
				* IF I > This.nPages - (This.nPageSet * This.nMaxMiniatureItem) + This.nOtherThenProofObj
					This.OBJECTS[m.i].VISIBLE = .F.
				ENDIF
			ENDFOR

		ENDCASE

		This.nPageSet = m.vNewValue

		This.SetProofCaption()

		This.SHOW()
	ENDPROC

	PROCEDURE SetProofCaption
	*!* ---------------------- *!*
	*!* Calculate the caption! *!*
	*!* ---------------------- *!*
		LOCAL cMessage, nFirstPage, nLastPage

		m.nFirstPage 	= ((This.nPageSet-1) * This.nMaxMiniatureItem) + 1
		m.nLastPage  	= MIN(This.nPageSet * This.nMaxMiniatureItem, This.nPages)

		m.cMessage	= _goFP.GetLoc("MINILABEL")	&& "Pages from %FP% to %LP%"

		This.PageSetCaption.CAPTION = STRTRAN(STRTRAN(m.cMessage, "%FP%", TRANSFORM(m.nFirstPage)), "%LP%", TRANSFORM(m.nLastPage))
	ENDPROC

	PROCEDURE ReportListener_Assign
		LPARAMETERS oNewValue
		This.REPORTLISTENER = m.oNewValue
		This.DoResizeProofSheet()
	ENDPROC

	PROCEDURE nMaxMiniatureItem_Assign
		LPARAMETERS nNewItem
		This.nMaxMiniatureItem = m.nNewItem
		This.DoResizeProofSheet()
	ENDPROC

	PROCEDURE DoResizeProofSheet
		IF NOT ISNULL(This.REPORTLISTENER)
			*!* Recalculating the Proof Page size to display the max miniature at one time
			nProofWidth  = This.REPORTLISTENER.GETPAGEWIDTH() / 96
			nProofHeight = This.REPORTLISTENER.GETPAGEHEIGHT() / 96

			*!* Calculating the max col
			nMaxScreenWToConsidere = (_SCREEN.WIDTH /5) * 4		&& 4/5;  Just for "estetics"
			nMaxScreenHToConsidere = (_SCREEN.HEIGHT/5) * 4		&& 4/5;  Just for "estetics"

			nDiv = nProofWidth+SPACE_PIXELS
			nNbCol = INT((nMaxScreenWToConsidere - SPACE_PIXELS) / nDiv)

			IF nNbCol >= This.nPages
				*!* The width does need to be so large...
				*!* We will keep only the space needed do display the pages!
				nNbCol = This.nPages
			ENDIF

			*!* Now, calculating the width to set the form
			This.WIDTH = SPACE_PIXELS + (nNbCol * (nProofWidth+SPACE_PIXELS))


			*!* -------------------
			*!* Now for the hight
			*!* -------------------
			*!* Calculating number of row...
			*!* We will keep in mind that if there is less item to display than the miximum possible
			*!* then we dont need to reserve the whole place
			nNbRow = CEILING(MIN(This.nMaxMiniatureItem, This.nPages)/ nNbCol)


			*!* Checking if we must display nav btn or not
			IF CEILING(This.nPages / This.nMaxMiniatureItem) > 1
				nBaseHeight = _goFP._nBtSize + SPACE_PIXELS
			ELSE
				nBaseHeight = SPACE_PIXELS
			ENDIF

			*!* Now, calculating the height to set the form
			This.HEIGHT = MIN(nMaxScreenHToConsidere, nBaseHeight + (nNbRow * (nProofHeight+SPACE_PIXELS)))


			*!* Is the Height sufficient to display all of the miniatures?
			*!* If not, there will be a vertical scrool bar and we must reserve space for that.
			IF This.HEIGHT < nBaseHeight + (nNbRow * (nProofHeight+SPACE_PIXELS))
				*!* Add some space for the scrool bar to the WIDTH
				This.WIDTH = This.WIDTH + 20
			ENDIF

			This.AUTOCENTER = .T.	&& Auto center the proof sheet
		ENDIF
	ENDPROC

	PROCEDURE PAINT
		IF (NOT ISNULL(This.REPORTLISTENER))

			IF NOT This.lShowDone
				FOR m.i = ((This.nPageSet - 1) * This.nMaxMiniatureItem) + 1 TO This.nPageSet * This.nMaxMiniatureItem
					IF TYPE("This.Objects[m.i - ((This.nPageSet - 1) * This.nMaxMiniatureItem) + This.nOtherThenProofObj]") == "O"
						IF m.i > This.nPages
							* This.Objects[i - ((This.nPageSet - 1) * This.nMaxMiniatureItem) + This.nOtherThenProofObj].Visible = .F.
							EXIT
						ELSE
							This.OBJECTS[m.i - ((This.nPageSet - 1) * This.nMaxMiniatureItem) + This.nOtherThenProofObj].TOOLTIPTEXT = ;
								_goFP.GetLoc("PAGECAPTIO") + " " + TRANSFORM(m.i)

							This.REPORTLISTENER.OUTPUTPAGE( m.i, This.OBJECTS[m.i - ((This.nPageSet - 1) * This.nMaxMiniatureItem) + This.nOtherThenProofObj],2)
						ENDIF
					ELSE
						EXIT
					ENDIF
				ENDFOR

				This.lShowDone = .T.
			ENDIF
		ENDIF
	ENDPROC

	PROCEDURE SHOW
		LPARAMETERS nStyle

		IF CEILING(This.nPages / This.nMaxMiniatureItem) > 1
			*!* Since we have multi pages set, then we must display NAV buttons.

			IF NOT This.lstarted
				This.PageSetFirst.VISIBLE 	= .T.
				This.PageSetPrev.VISIBLE 	= .T.
				This.PageSetNext.VISIBLE 	= .T.
				This.PageSetLast.VISIBLE 	= .T.
				This.PageSetCaption.VISIBLE = .T.
			ENDIF

			iRowOffset = SPACE_PIXELS * 3 + IIF(_goFP._nBtSize > 24, _goFP._nBtSize - 20, 0)	&& Set the start to let some place to the NAV buttons
		ELSE
			*!* There is only one page set, so there is no need to display navigation button!
			*!* They are alerady
			iRowOffset = SPACE_PIXELS	&& Set the start to the top!
		ENDIF

		iColOffset = SPACE_PIXELS


		nProofWidth  = This.REPORTLISTENER.GETPAGEWIDTH() / 96
		nProofHeight = This.REPORTLISTENER.GETPAGEHEIGHT() / 96

		iColCount  = INT((THISFORM.WIDTH - iColOffset)/ (nProofWidth + SPACE_PIXELS))	&& Number of column that can fit in the space allowed

		nCurCol = 1

		This.lShowDone = .F.

		FOR m.i = ((This.nPageSet - 1) * This.nMaxMiniatureItem) + 1 TO MIN(This.nPageSet * This.nMaxMiniatureItem, This.nPages)
			* Calculate the objectID here to facilitate reading the code
			nObjectID = m.i - ((This.nPageSet - 1) * This.nMaxMiniatureItem) + This.nOtherThenProofObj

			IF NOT This.lstarted
				This.ADDOBJECT(SYS(2015),"ProofShape")
				This.OBJECTS[nObjectID].VISIBLE = .T.

				This.OBJECTS[nObjectID].WIDTH  = nProofWidth
				This.OBJECTS[nObjectID].HEIGHT = nProofHeight
			ENDIF

			* Arrange shapes on form:
			TRY
				This.OBJECTS[nObjectID].TOP  	= iRowOffset
				This.OBJECTS[nObjectID].LEFT 	= SPACE_PIXELS + ((nCurCol-1) * (nProofWidth+SPACE_PIXELS))		&& iColOffset

				This.OBJECTS[nObjectID].PAGENO = m.i

				nCurCol = nCurCol + 1

				IF nCurCol > iColCount
					nCurCol = 1
					iRowOffset = iRowOffset + SPACE_PIXELS + This.OBJECTS[nObjectID].HEIGHT
				ENDIF
			CATCH
			ENDTRY
		ENDFOR

		This.lstarted = .T.
		DODEFAULT(m.nStyle)
	ENDPROC

	PROCEDURE DESTROY
		LOCAL cEscFUNCTION
		This.REPORTLISTENER = NULL

		* Put back the ESCAPE KEY action with ON KEY LABEL
		EscFUNCTION = This.OldEscFUNCTION
		ON KEY LABEL ESCAPE &EscFUNCTION
	ENDPROC
ENDDEFINE
*-- EndDefine: ProofSheet
**************************************************



*********************************************************************
PROCEDURE PR_SendMailEx(tcAttachment, tcRecipient, tcSubject, tcText)
*********************************************************************
* PROCEDURE to send email attachment using Mapi
	LOCAL lcAttachment, lcRecipient, lcSubject, lcText
	m.lcAttachment  = EVL(m.tcAttachment, "")
	m.lcRecipient   = EVL(m.tcRecipient, "")
	m.lcSubject     = EVL(m.tcSubject, "")
	m.lcText        = EVL(m.tcText, "")


* http://www.atoutfox.org/articles.asp?ACTION=FCONSULTER&ID=0000000120
* By Mike Gagnon
* À titre d’exemple voici comment utiliser les appels API pour faire appel au simple MAPI.
* Le code suivant est gracieuseté d’Anatoliy Mogylevets de www.news2news.com/vfp.
* The code below is a courtesy of Anatoliy Mogylevets, from www.news2news.com/vfp
* It received some few tweaks in order to accept attachments

* MAPISendMail FUNCTION
* http://msdn.microsoft.com/en-us/library/dd296721(VS.85).aspx

	#DEFINE MAPI_ORIG        0
	#DEFINE MAPI_TO          1
	#DEFINE MAPI_DIALOG      8
	#DEFINE SUCCESS_SUCCESS  0

	DO DeclMapi

	LOCAL hSession
	m.hSession = getNewSession()
	IF m.hSession = 0
		* ? "Unable to log on."
		RETURN
	ENDIF

	LOCAL loRcpEmail, loSndBuf, lcRcpBuf, loSubject, loNoteText,;
		loRcpBuf, lcMapiMessage, lnResult


	LOCAL lcAttachment
	m.lcAttachment = m.tcAttachment


* MapiFileDesc Structure
* http://msdn.microsoft.com/en-us/library/dd296737(v=VS.85).aspx
*!*	typedef struct {
*!*	  ULONG  ulReserved;
*!*	  ULONG  flFlags;
*!*	  ULONG  nPosition;
*!*	  LPSTR  lpszPathName;
*!*	  LPSTR  lpszFileName;
*!*	  LPVOID lpFileType;
*!*	} MapiFileDesc, *lpMapiFileDesc

	LOCAL loAttach, loAttPath, loAttName
	LOCAL lcAttStruct
	m.loAttPath = CREATEOBJECT("PChar", m.lcAttachment)
	m.loAttName = CREATEOBJECT("PChar", JUSTFNAME(m.lcAttachment))

	m.lcAttStruct = ;
		num2dword( 0 ) +;
		num2dword( 0 ) +;
		num2dword( 0 ) +;
		num2dword( m.loAttPath.getAddr() ) +; && AttachmentPathName
	num2dword( m.loAttName.getAddr() ) +; && AttachmentName
	num2dword( 0 )
	m.loAttach = CREATEOBJECT ("PChar", m.lcAttStruct)

	* populating message recipient, subject and body
	m.loSubject  = CREATEOBJECT ("PChar", m.lcSubject)
	m.loNoteText = CREATEOBJECT ("PChar", m.lcText)

	* initializing buffer with single recipient data
	IF NOT EMPTY(m.lcRecipient)
		m.loRcpEmail = CREATEOBJECT ("PChar", m.lcRecipient)
		m.lcRcpBuf = num2dword(0) +;
			num2dword(MAPI_TO) +;
			num2dword(m.loRcpEmail.getAddr()) +;
			REPLI(CHR(0), 12)
		m.loRcpBuf = CREATEOBJECT ("PChar", m.lcRcpBuf)
	ENDIF

	* initializing buffer with sender data -- practically empty
	m.loSndBuf = CREATEOBJECT ("PChar", REPLI(CHR(0), 24))
	* merging all parts to a message buffer -- no file attachments


	* MapiMessage Structure
	* http://msdn.microsoft.com/en-us/library/dd296732(v=VS.85).aspx
	*!*	typedef struct {
	*!*	  ULONG           ulReserved;
	*!*	  LPSTR           lpszSubject;
	*!*	  LPSTR           lpszNoteText;
	*!*	  LPSTR           lpszMessageType;
	*!*	  LPSTR           lpszDateReceived;
	*!*	  LPSTR           lpszConversationID;
	*!*	  FLAGS           flFlags;
	*!*	  lpMapiRecipDesc lpOriginator;
	*!*	  ULONG           nRecipCount;
	*!*	  lpMapiRecipDesc lpRecips;
	*!*	  ULONG           nFileCount;
	*!*	  lpMapiFileDesc  lpFiles;
	*!*	} MapiMessage, *lpMapiMessage

	m.lcMapiMessage = num2dword(0) +;
		num2dword(m.loSubject.getAddr()) +;
		num2dword(m.loNoteText.getAddr()) +;
		num2dword(0) + num2dword(0) + num2dword(0) + num2dword(0) +;
		num2dword(m.loSndBuf.getAddr()) +;
		num2dword(IIF(EMPTY(m.lcRecipient), 0, 1)) +;
		num2dword(IIF(EMPTY(m.lcRecipient), 0, m.loRcpBuf.getAddr())) +;
		num2dword(IIF(EMPTY(m.lcAttachment), 0, 1)) +;
		num2dword(IIF(EMPTY(m.lcAttachment), 0, m.loAttach.getAddr()))

	* sending the message with or without a confirmation dialog
	m.lnResult = MAPISendMail(m.hSession, 0, @m.lcMapiMessage, MAPI_DIALOG, 0) && Confirm dialog
	*lnResult = MAPISendMail(hSession, 0, @lcMapiMessage, 0, 0)


	LOCAL llSuccess
	llSuccess = .T.
	IF m.lnResult <> SUCCESS_SUCCESS
		=PR_MAPIShowMessage(m.lnResult)
		llSuccess = .F.
	ELSE
	* ? "Sent initiated successfully!"
	ENDIF

	* closing current MAPI session
	= MAPILogoff (m.hSession, 0, 0, 0)
	RETURN llSuccess
ENDPROC


FUNCTION  getNewSession()

	* creates a new MAPI session and returns its handle
	#DEFINE MAPI_LOGON_UI           1
	#DEFINE MAPI_NEW_SESSION        2
	#DEFINE MAPI_USE_DEFAULT       64
	#DEFINE MAPI_FORCE_DOWNLOAD  4096 && 0x1000
	#DEFINE MAPI_PASSWORD_UI   131072 && 0x20000

	LOCAL lnResult, lnSession, lcStoredPath
	m.lcStoredPath = SYS(5) + SYS(2003)
	m.lnSession = 0
	m.lnResult = MAPILogon (0, "", "",;
		MAPI_USE_DEFAULT+MAPI_NEW_SESSION, 0, @m.lnSession)
		
	IF m.lnResult <> 0
		m.lnResult = MAPILogon (0, "", "",;
			MAPI_USE_DEFAULT + MAPI_NEW_SESSION + MAPI_LOGON_UI, 0, @m.lnSession)
	ENDIF

	IF lnResult <> SUCCESS_SUCCESS
		PR_MAPIShowMessage(lnResult)
		_goFP.lEmailed = .F.
	ENDIF

	* sometimes you need to restore default path - Outlook Express
	SET DEFAULT TO (m.lcStoredPath)

	RETURN IIF(m.lnResult=SUCCESS_SUCCESS, m.lnSession, 0)


FUNCTION  num2dword (lnValue)
	RETURN BINTOC(m.lnValue, "4RS")

	* for some structures you need not just strings but pointers to strings
	* to be assigned to structure fields;
	* this class implements such "dual" strings

DEFINE CLASS PChar AS CUSTOM
	PROTECTED HMEM

	PROCEDURE  INIT (lcString)
		This.HMEM = 0
		IF NOT EMPTY(m.lcString)
			This.setValue (m.lcString)
		ENDIF

	PROCEDURE  DESTROY
		This.ReleaseString

	FUNCTION getAddr  && returns a pointer to the string
		RETURN This.HMEM

	FUNCTION getValue && returns string value
		LOCAL lnSize, lcBuffer
		m.lnSize = This.getAllocSize()
		m.lcBuffer = SPACE(m.lnSize)
		IF This.HMEM <> 0
			DECLARE RtlMoveMemory IN kernel32 AS Heap2Str;
				STRING @, INTEGER, INTEGER
			= Heap2Str (@m.lcBuffer, This.HMEM, m.lnSize)
		ENDIF

		RETURN m.lcBuffer

	FUNCTION getAllocSize  && returns allocated memory size (string length)
		DECLARE INTEGER GlobalSize IN kernel32 INTEGER HMEM
		RETURN IIF(This.HMEM=0, 0, GlobalSize(This.HMEM))

	PROCEDURE setValue (lcString) && assigns new string value
		#DEFINE GMEM_FIXED   0

		This.ReleaseString
		DECLARE INTEGER GlobalAlloc IN kernel32 INTEGER, INTEGER
		DECLARE RtlMoveMemory IN kernel32 AS Str2Heap;
			INTEGER, STRING @, INTEGER

		LOCAL lnSize
		lcString = m.lcString + CHR(0)
		m.lnSize = LEN(m.lcString)
		This.HMEM = GlobalAlloc (GMEM_FIXED, m.lnSize)
		IF This.HMEM <> 0
			= Str2Heap (This.HMEM, @lcString, m.lnSize)
		ENDIF
	ENDPROC 

	PROCEDURE ReleaseString  && releases allocated memory
		IF This.HMEM <> 0
			DECLARE INTEGER GlobalFree IN kernel32 INTEGER
			= GlobalFree (This.HMEM)
			This.HMEM = 0
		ENDIF
	ENDPROC

ENDDEFINE


PROCEDURE  DeclMapi
	DECLARE INTEGER MAPILogon IN mapi32;
		INTEGER ulUIParam, STRING lpszProfileName,;
		STRING lpszPassword, INTEGER flFlags,;
		INTEGER ulReserved, INTEGER @lplhSession

	DECLARE INTEGER MAPILogoff IN mapi32;
		INTEGER lhSession, INTEGER ulUIParam,;
		INTEGER flFlags, INTEGER ulReserved

	DECLARE INTEGER MAPISendMail IN mapi32;
		INTEGER lhSession, INTEGER ulUIParam, STRING @lpMessage,;
		INTEGER flFlags, INTEGER ulReserved
	RETURN

	* CDO email class from by VFP guru Sergey Berezniker
	* http://www.berezniker.com/content/pages/visual-foxpro/cdo-2000-class-sending-emails

	* The easiest way to configure CDOSYS is to configure Outlook Express.
	* You do not ever need to use it, but if you configure it to send e-mail,
	* CDO has the registry entries it needs so that you do not need to configure it explicitly.

	* CDO2000.prg
	* by Sergey Berezniker
	#DEFINE cdoSendPassword "http://schemas.microsoft.com/cdo/configuration/sendpassword"
	#DEFINE cdoSendUserName "http://schemas.microsoft.com/cdo/configuration/sendusername"
	#DEFINE cdoSendUsingMethod "http://schemas.microsoft.com/cdo/configuration/sendusing"
	#DEFINE cdoSMTPAuthenticate "http://schemas.microsoft.com/cdo/configuration/smtpauthenticate"
	#DEFINE cdoSMTPConnectionTimeout "http://schemas.microsoft.com/cdo/configuration/smtpconnectiontimeout"
	#DEFINE cdoSMTPServer "http://schemas.microsoft.com/cdo/configuration/smtpserver"
	#DEFINE cdoSMTPServerPort "http://schemas.microsoft.com/cdo/configuration/smtpserverport"
	#DEFINE cdoSMTPUseSSL "http://schemas.microsoft.com/cdo/configuration/smtpusessl"
	#DEFINE cdoURLGetLatestVersion "http://schemas.microsoft.com/cdo/configuration/urlgetlatestversion"
	#DEFINE cdoAnonymous 0	&& Perform no authentication (anonymous)
	#DEFINE cdoBasic 1	&& Use the basic (clear text) authentication mechanism.
	#DEFINE cdoSendUsingPort 2	&& Send the message using the SMTP protocol over the network.
	#DEFINE cdoXMailer "urn:schemas:mailheader:x-mailer"

********************************************************************
DEFINE CLASS cdo2000 AS CUSTOM
* By Sergey Berezniker
*******************************************************************
	PROTECTED aErrors[1], nErrorCount, oMsg, oCfg, cXMailer
	nErrorCount = 0

	* Message attributes
	oMsg = NULL
	cFrom = ""
	cReplyTo = ""
	cTo = ""
	cCC = ""
	cBCC = ""
	cAttachment = ""

	cSubject = ""
	cHtmlBody = ""
	cTextBody = ""
	cHtmlBodyUrl = ""

	cCharset =  "" && _goFP.cLanguage && <================ ="GREEK" (i.e. the current language) by Nick Porfyris [20100921]...


	* Configuration object fields values
	oCfg = NULL
	cServer = ""
	nServerPort = 25
	* Use SSL connection
	lUseSSL = .F.
	nConnectionTimeout = 30			&& Default 30 sec's
	nAuthenticate = cdoAnonymous
	cUserName = ""
	cPassword = ""
	* Do not use cache for cHtmlBodyUrl
	lURLGetLatestVersion = .T.

	* Optional. Creates your own X-MAILER field in the header
	cXMailer = "VFP CDO 2000(CDOSYS) mailer Ver 1.1 2009"
	lReadReceipt = .F.
	lPriority    = .F.

	oThermForm = ""

	PROTECTED PROCEDURE INIT
		This.aErrors = NULL

		LOCAL lcCharSet
		IF INLIST(ALLTRIM(UPPER(_goFP.cLanguage)),"ENGLISH", "FRENCH", "PORTUGUESE", ;
			"ALBANIAN", "CATALAN", "DANISH", "DUTCH", "FAEROESE", "FINNISH", "GALICIAN", ;
			"GERMAN", "ICELANDIC", "ITALIAN", "NORWEGIAN", "SPANISH", "SWEDISH") 
			m.lcCharset = "" && _goFP.cLanguage && <================ ="GREEK" (i.e. the current language) by Nick Porfyris [20100921]...
		ELSE 
			* lcCharset = _goFP.cLanguage && (i.e. the current language) by Nick Porfyris [20100921]...
			&& extract the 9999 from the CP9999...
			m.lcCharSet = "windows-" + RIGHT(ALLTRIM(_goFP.cCodePage),4)
		ENDIF 
		This.cCharSet = m.lcCharset

	ENDPROC

	* Send message
	PROCEDURE SEND

		WITH THIS
			.ClearErrors()
			.oCfg = CREATEOBJECT("CDO.Configuration")
			.oMsg = CREATEOBJECT("CDO.Message")
			.oMsg.Configuration = This.oCfg
		ENDWITH

		* Fill message attributes
		LOCAL lnind, laList[1], loHeader, laDummy[1]

		IF This.SetConfiguration() > 0
			RETURN This.GetErrorCount()
		ENDIF

		IF EMPTY(This.cFrom)
			This.AddError("ERROR : From is Empty.")
		ENDIF
		IF EMPTY(This.cSubject)
			This.AddError("ERROR : Subject is Empty.")
		ENDIF

		IF EMPTY(This.cTo) AND EMPTY(This.cCC) AND EMPTY(This.cBCC)
			This.AddError("ERROR : To,CC and BCC all are Empty.")
		ENDIF

		IF This.GetErrorCount() > 0
			RETURN This.GetErrorCount()
		ENDIF

		This.SetHeader()

		WITH This.oMsg

			.FROM     = This.cFrom
			.ReplyTo  = This.cReplyTo

			.TO       = This.cTo
			.CC       = This.cCC
			.BCC      = This.cBCC
			.Subject  = This.cSubject

			* Create HTML body from external HTML (file, URL)
			IF NOT EMPTY(This.cHtmlBodyUrl)
				.CreateMHTMLBody(This.cHtmlBodyUrl)
			ENDIF

			* Send HTML body. Creates TextBody as well
			IF NOT EMPTY(This.cHtmlBody)
				.HtmlBody = This.cHtmlBody
			ENDIF

			* Send Text body. Could be different from HtmlBody, if any
			IF NOT EMPTY(This.cTextBody)
				.TextBody = This.cTextBody
			ENDIF

			IF NOT EMPTY(.HtmlBody)
				.HtmlBodyPart.Charset = This.cCharset
			ENDIF

			IF NOT EMPTY(.TextBody)
				.TextBodyPart.Charset = This.cCharset
			ENDIF

			* Process attachments
			IF NOT EMPTY(This.cAttachment)
			* Accepts comma or semicolon
			* VFP 7.0 and later
			*FOR lnind=1 TO ALINES(laList, This.cAttachment, [,], [;])
			* VFP 6.0 and later compatible
				FOR m.lnind=1 TO ALINES(m.laList, CHRTRAN(This.cAttachment, [,;], _CRLF + _CRLF))
					m.lcAttachment = ALLTRIM(m.laList[m.lnind])
					* Ignore empty values
					IF EMPTY(m.laList[m.lnind])
						LOOP
					ENDIF

					* Make sure that attachment exists
					IF ADIR(m.laDummy, m.lcAttachment) = 0
						IF VARTYPE(_Screen.oFoxyPreviewer) = "O"
							This.AddError(_Screen.oFoxyPreviewer._AttachNotFoundText + " - " + m.lcAttachment)
						ELSE 
							This.AddError(_goFP.GetLoc("ATACHNOTFO") + " - " + m.lcAttachment)
						ENDIF 
					ELSE
						* The full path is required.
						IF 	UPPER(m.lcAttachment) <> UPPER(FULLPATH(m.lcAttachment))
							m.lcAttachment = FULLPATH(m.lcAttachment)
						ENDIF
						.AddAttachment(m.lcAttachment)
					ENDIF
				ENDFOR
			ENDIF

			* by CChalom - Codes included to allow Receipt return and Priority
			* http://support.microsoft.com/kb/302839
			IF This.lReadReceipt = .T. 
				This.oMsg.Fields("urn:schemas:mailheader:disposition-notification-to") = This.cTo
				This.oMsg.Fields("urn:schemas:mailheader:return-receipt-to") = This.cTo
				This.oMsg.Fields.Update()
			ENDIF

			* Set priority if needed
			IF This.lPriority
				This.oMsg.Fields("Priority").Value = 1   && -1=Low, 0=Normal, 1=High
				This.oMsg.Fields.Item("urn:schemas:mailheader:X-Priority") = 1 && -1=Low, 0=Normal, 1=High
				This.oMsg.Fields.Item("urn:schemas:httpmail:importance") = 1
				This.oMsg.Fields.Update()
			ENDIF

			IF NOT EMPTY(This.cCharset)
				.BodyPart.Charset = This.cCharset
			ENDIF

		ENDWITH

		IF This.GetErrorCount() > 0
			RETURN This.GetErrorCount()
		ENDIF

		* Show the progressbar therm
		This.ShowTherm()

		* Sends the message
		This.oMsg.SEND()

		* Clears the progressbar therm
		This.ClearTherm()

		RETURN This.GetErrorCount()
	ENDPROC

	* Clear errors collection
	PROCEDURE ClearErrors()
		This.nErrorCount = 0
		DIMENSION This.aErrors[1]
		This.aErrors[1] = NULL
		RETURN This.nErrorCount
	ENDPROC

	* Return # of errors in the error collection
	PROCEDURE GetErrorCount
		RETURN This.nErrorCount
	ENDPROC

	* Return error by index
	PROCEDURE GetError
		LPARAMETERS tnErrorno
		IF	m.tnErrorno <= This.GetErrorCount()
			RETURN This.aErrors[m.tnErrorno]
		ELSE
			RETURN NULL
		ENDIF
	ENDPROC

	* Populate configuration object
	PROTECTED PROCEDURE SetConfiguration

		* Validate supplied configuration values
		IF EMPTY(This.cServer)
			This.AddError(_goFP.GetLoc("SMTPNOTSPE")) && "ERROR: SMTP Server isn't specified.")
		ENDIF
		IF NOT INLIST(This.nAuthenticate, cdoAnonymous, cdoBasic)
			This.AddError(_goFP.GetLoc("BADAUTHPRO")) && Invalid Authentication protocol ")
		ENDIF
		IF This.nAuthenticate = cdoBasic ;
				AND (EMPTY(This.cUserName) OR EMPTY(This.cPassword))
			This.AddError(_goFP.GetLoc("INFOREQUIR")) && User name/Password is required for basic authentication")
		ENDIF

		IF 	This.GetErrorCount() > 0
			RETURN This.GetErrorCount()
		ENDIF

		WITH This.oCfg.FIELDS

			* Send using SMTP server
			.ITEM(cdoSendUsingMethod)       	= cdoSendUsingPort
			.ITEM(cdoSMTPServer)        		= This.cServer
			.ITEM(cdoSMTPServerPort)			= This.nServerPort
			.ITEM(cdoSMTPConnectionTimeout)	 	= This.nConnectionTimeout

			.ITEM(cdoSMTPAuthenticate)  		= This.nAuthenticate
			IF This.nAuthenticate = cdoBasic
				.ITEM(cdoSendUserName)    	  	= This.cUserName
				.ITEM(cdoSendPassword)    	  	= This.cPassword
			ENDIF
			.ITEM(cdoURLGetLatestVersion) 	  	= This.lURLGetLatestVersion
			.ITEM(cdoSMTPUseSSL) 				= This.lUseSSL

			.UPDATE()
		ENDWITH

		RETURN This.GetErrorCount()

	ENDPROC

*----------------------------------------------------
* Add message to the error collection
	PROTECTED PROCEDURE AddError
		LPARAMETERS tcErrorMsg
		This.nErrorCount = This.nErrorCount + 1
		DIMENSION This.aErrors[This.nErrorCount]
		This.aErrors[This.nErrorCount] = m.tcErrorMsg
		RETURN This.nErrorCount
	ENDPROC

*----------------------------------------------------
* Format an error message and add to the error collection
	PROTECTED PROCEDURE AddOneError
		LPARAMETERS tcPrefix, tnError, tcMethod, tnLine
		LOCAL lcErrorMsg, laList[1]
		IF INLIST(m.tnError, 1427,1429)
			AERROR(m.laList)
			m.lcErrorMsg = ALLTRIM(TRANSFORM(m.laList[7], "@0") + ;
				"  " + m.laList[4]  + "  " + m.laList[3])
		ELSE
			m.lcErrorMsg = ALLTRIM(MESSAGE())
		ENDIF
		m.lcErrorMsg = CHRTRAN(m.lcErrorMsg, CHR(0), "")
	
		This.AddError("#" + TRANSFORM(m.tnError) + " - " + ;
			ALLTRIM(m.tcMethod) + " - " + m.lcErrorMsg)
		RETURN This.nErrorCount
	ENDPROC

*----------------------------------------------------
* Simple Error handler. Adds VFP error to the objects error collection
	PROTECTED PROCEDURE ERROR
		LPARAMETERS tnError, tcMethod, tnLine
		*!*	This.AddError("VFP Error: " + TRANSFORM(tnError) + " # " + ;
		*!*		tcMethod + " # " + TRANSFORM(tnLine) + " # " + MESSAGE())
		This.AddOneError("", m.tnError, m.tcMethod, m.tnLine )
		RETURN This.nErrorCount
	ENDPROC

*-------------------------------------------------------
* Set mail header fields, if necessary. For now sets X-MAILER, if specified
	PROTECTED PROCEDURE SetHeader
		LOCAL loHeader
		IF NOT EMPTY(This.cXMailer)
			m.loHeader = This.oMsg.FIELDS
			WITH m.loHeader
				.ITEM(cdoXMailer) =  This.cXMailer
				.UPDATE()
			ENDWITH
		ENDIF
	ENDPROC


	PROCEDURE ClearTherm
		IF VARTYPE(This.oThermForm) = "O"
			This.oThermForm = ""
		ENDIF
	ENDPROC 


	PROCEDURE ShowTherm
		IF VARTYPE(_Screen.oFoxyPreviewer) = "O"
			IF NVL(_Screen.oFoxyPreviewer.lQuietMode, .F.) = .T.
				RETURN 
			ENDIF
		ENDIF 
		
		IF VARTYPE(_goFP) = "O" AND _goFP.lQuietMode = .T.
			RETURN
		ENDIF 

		LOCAL loThermForm as Form
		LOCAL lnThermMargin, liThermHeight,	liThermWidth, liThermTop, liThermLeft
	
		m.lnThermMargin = 5
		*!* loThermForm = CREATEOBJECT("FORM")	&& 2011-08-12 - Jacques Parent
		m.loThermForm = CREATEOBJECT("ITLFForm")	&& 2011-08-12 - Jacques Parent - ITLFFORM = In "Top Level Forn" FORM
												** Let the "ThermForm" be displayed in a Top Level form
												** Will also work with the VFP SCREEN

		WITH m.loThermForm as Form 
			.ScaleMode = 3 && SCALEMODE_PIXELS   
			.Height = 27 && 40
			.HalfHeightCaption = .T.
			.Width = 356
			.AutoCenter = .T.
			.BorderStyle = 2 && BORDER_DOUBLE  && fixed dialog
			.ControlBox = .F.
			.Closable = .F.
			.MaxButton = .F.
			.MinButton = .F.
			.Movable = .F.
			.AlwaysOnTop = .T.
			.AllowOutput = .F.
			.NewObject("Therm","ctl32_progressbar","pr_ctl32_progressbar")
			m.liThermHeight = .Height - (m.lnThermMargin* 2) && - .ThermLabel.Height
			m.liThermWidth =  .Width - (m.lnThermMargin*2)

			IF VARTYPE(_Screen.oFoxyPreviewer) = "O"
				.Caption = _Screen.oFoxyPreviewer._SendingText
			ELSE 
				.Caption = _goFP.GetLoc("MSGSENDING")
			ENDIF 

			.Visible = .T.
		ENDWITH
  
		m.liThermTop  = m.lnThermMargin
		m.liThermLeft = m.lnThermMargin  

		WITH m.loThermForm.Therm
			.Top = m.liThermTop     
			.Left = m.liThermLeft
			.Height = m.liThermHeight
			.Width = m.liThermWidth
			.Marquee = .T.
			.MarqueeAnimationSpeed = 25
			.MarqueeSpeed = 25
			.Visible = .T.
		ENDWITH

		This.oThermForm = m.loThermForm
	ENDPROC 

ENDDEFINE


DEFINE CLASS ITLFForm as Form	&& 2011-08-12 - Jacques Parent
	ShowWindow = 1				&& Define a form IN TOP LEVEL FORM
ENDDEFINE



* ExportListener helper class, to generate the CSV and XL5 outputs
DEFINE CLASS ExportListener AS REPORTLISTENER
	cDestFile = ""
	LISTENERTYPE = 3

	FUNCTION BEFOREREPORT
		LOCAL lcType
		m.lcType = LOWER(JUSTEXT(This.cDestFile))
		DO CASE
		CASE INLIST(m.lcType, "xls", "xl5")
			COPY TO FORCEEXT(This.cDestFile, "xls") TYPE XL5

		CASE m.lcType = "csv"
			COPY TO (This.cDestFile) DELIMITED WITH CHARACTER ";"
		OTHERWISE
		ENDCASE

		NODEFAULT
		This.DESTROY()
	ENDFUNC
ENDDEFINE



* Helper FUNCTIONs
********************************************************************
PROCEDURE Report2Pic(toListener, m.tcDestFile, tcFileFormat)
********************************************************************
	IF VARTYPE(m.toListener) <> "O"
		ERROR "Report Listener could not be accessed"
		RETURN .F.
	ENDIF

	IF VARTYPE(m.tcFileFormat) = "L"
		m.tcFileFormat = JUSTEXT(m.tcDestFile)
	ENDIF
	m.tcFileFormat = LOWER(m.tcFileFormat)

	LOCAL lnPageCount, lnFileType, lnDeviceType
	m.lnPageCount = _goFP.nPageTotal && toListener.PageTotal
	IF m.lnPageCount = 0
		m.lnPageCount = toListener.PageTotal
	ENDIF

	DO CASE
	*!*	100 - imagem de tipo EMF
	*!*	101 - imagem de tipo TIFF
	*!*	102 - imagem de tipo JPEG
	*!*	103 - imagem de tipo GIF
	*!*	104 - imagem de tipo PNG
	*!*	105 - imagem de tipo BMP

	CASE m.tcFileFormat = "emf"
		m.lnFileType = 100

	CASE m.tcFileFormat = "tiff" OR tcFileFormat = "tif"
		m.lnFileType = 101

		#DEFINE OutputNothing -1
		#DEFINE OutputTIFF 101
		#DEFINE OutputTIFFAdditive (OutputTIFF+100)

		LOCAL lnPageNo
		FOR m.lnPageNo = 1 TO m.lnPageCount
			IF (m.lnPageNo == 1)
				m.lnDeviceType = OutputTIFF
			ELSE
				m.lnDeviceType = OutputTIFFAdditive
			ENDIF
			toListener.OUTPUTPAGE(m.lnPageNo,m.tcDestFile,m.lnDeviceType)
		ENDFOR
		RETURN

	CASE m.tcFileFormat = "jpeg" OR tcFileFormat = "jpg"
		m.lnFileType = 102

	CASE m.tcFileFormat = "gif"
		m.lnFileType = 103

	CASE m.tcFileFormat = "png"
		m.lnFileType = 104

	CASE m.tcFileFormat = "bmp" OR  tcFileFormat = "bitmap"
		m.lnFileType = 105

	ENDCASE

	ERASE (m.tcDestFile)

	LOCAL lcPathFile, lcDestFile, lcIndex, llSuccess
	m.llSuccess = .T.
	m.lcPathFile = ADDBS(JUSTPATH(m.tcDestFile)) + JUSTSTEM(m.tcDestFile)

	FOR m.lnPageNo = 1 TO m.lnPageCount
		IF m.lnPageNo = 1
			m.lcIndex = ""
		ELSE
			m.lcIndex = TRANSFORM(m.lnPageNo)
		ENDIF
		m.lcDestFile = FORCEEXT((m.lcPathFile + m.lcIndex),tcFileFormat)
		m.toListener.OUTPUTPAGE(m.lnPageNo, m.lcDestFile, m.lnFileType)
		IF NOT FILE(m.lcDestFile)
			m.llSuccess = .F.
		ENDIF
	ENDFOR
	RETURN m.llSuccess
ENDPROC



********************************************************************
PROCEDURE SendCDOMail
********************************************************************
	LPARAMETERS tcFile, tlDoNotEditMessage

	* Update the _goFP1 properties according to the _Screen.oFoxyPreviewer object if in Simplified mode
	IF VARTYPE(_Screen.oFoxyPreviewer) = "O"
		LOCAL loFP1
		loFP1 = _Screen.oFoxyPreviewer 
		loFP1.cCodePage   = NVL(loFP1.cCodePage, loFP1.cCodePage)

		loFP1.cEmailTo    = NVL(loFP1.cEmailTo   , loFP1.cEmailTo )
		loFP1.cSMTPServer = NVL(loFP1.cSMTPServer, loFP1.cSMTPServer)
		loFP1.lEmailAuto  = NVL(loFP1.lEmailAuto , loFP1.lEmailAuto )  		&& Automatically generates the report output file
		loFP1.cEmailType  = NVL(loFP1.cEmailType , loFP1.cEmailType ) 		&& The file type to be used in Emails (PDF, RTF, HTML or XLS)
		loFP1.cEmailPRG   = NVL(loFP1.cEmailPRG  , loFP1.cEmailPRG )
	
		loFP1.cSMTPServer = NVL(loFP1.cSMTPServer  , loFP1.cSMTPServer )  && "smtp.live.com"
		loFP1.nSMTPPort   = NVL(loFP1.nSMTPPort  , loFP1.nSMTPPort )   && 25
		loFP1.lSMTPUseSSL = NVL(loFP1.lSMTPUseSSL  , loFP1.lSMTPUseSSL )   && .T.

		loFP1.cSMTPUserName = NVL(loFP1.cSMTPUserName  , loFP1.cSMTPUserName )&& "yourAccount@live.com"
		loFP1.cSMTPPassword = NVL(loFP1.cSMTPPassword  , loFP1.cSMTPPassword )&& "yourPassword"

		loFP1.cSMTPUserName = NVL(loFP1.cSMTPUserName  , loFP1.cSMTPUserName )&& "yourAccount@live.com"

		loFP1.cEmailFrom    = NVL(loFP1.cEmailFrom     , loFP1.cEmailFrom ) && .cUserName
		loFP1.cEmailTo      = NVL(loFP1.cEmailTo       , loFP1.cEmailTo )&& "vfpimaging@hotmail.com" && "somebody@otherdomain.com, somebodyelse@otherdomain.com"
		loFP1.cEmailCC      = NVL(loFP1.cEmailCC       , loFP1.cEmailCC )
		loFP1.cEmailBCC     = NVL(loFP1.cEmailBCC      , loFP1.cEmailBCC )
		loFP1.cEmailSubject = NVL(loFP1.cEmailSubject  , loFP1.cEmailSubject )
		loFP1.cEmailReplyTo = NVL(loFP1.cEmailReplyTo  , loFP1.cEmailReplyTo )

		loFP1.cEmailBody    = NVL(loFP1.cEmailBody     , loFP1.cEmailBody )
		loFP1.lReadReceipt  = NVL(loFP1.lReadReceipt   , loFP1.lReadReceipt )
		loFP1.lPriority     = NVL(loFP1.lPriority      , loFP1.lPriority )
	ENDIF 

	_goFP.lEmailed = .F.
	LOCAL llCancelled
	IF NOT m.tlDoNotEditMessage
	
		* Ensure the proof sheet is closed
		_goFP.CloseSheets()

		LOCAL llVisible, loToolBar, loForm
		m.llVisible = .F.

		TRY
			m.loForm    = _goFP._oExHandler.PreviewForm
			m.loToolBar = _goFP._oExHandler.PreviewForm.Toolbar
		CATCH
		ENDTRY 

		IF VARTYPE(m.loToolBar) = "O"
			m.llVisible = m.loToolBar.Visible
			m.loToolbar.Visible = .F.
		ENDIF

		LOCAL lcEmailForm
		DO CASE
		CASE _goFP.nEmailMode = 2 && HTML CDOSYS
			m.lcEmailForm = "PR_SendMail2.scx"
		CASE _goFP.nEmailMode = 3 && TEXT CDOSYS
			m.lcEmailForm = "PR_SendMail.scx"
		OTHERWISE
			m.lcEmailForm = "PR_SendMail2.scx"
		ENDCASE

		IF VARTYPE(m.loToolbar) = "O"
			_goFP._oExHandler.PreviewForm.ShowToolbar(.F.)
			_goFP._oExHandler.PreviewForm.Toolbar.Visible = .F.
			
			DO FORM (m.lcEmailForm) WITH m.tcFile TO m.llCancelled NAME _goFP._oEmailSheet

			*!*	* Restore the toolbar
			*!*	IF llVisible AND VARTYPE(_goFP._oExHandler.PreviewForm.TOOLBAR) = "O"
			*!*		_goFP._oExHandler.PreviewForm.ShowToolbar(.T.)
			*!*	ENDIF
		ELSE
			DO FORM (m.lcEmailForm) WITH m.tcFile TO m.llCancelled NAME _goFP._oEmailSheet
		ENDIF

		IF VARTYPE(_goFP._oExHandler.PreviewForm) = "O"
			IF _Screen.Visible && NOT _goFP._TopForm
				ACTIVATE WINDOW (_goFP._oExHandler.PreviewForm.Name)
			ENDIF 
			* Restore the toolbar
			IF m.llVisible AND (VARTYPE(_goFP._oExHandler.PreviewForm.TOOLBAR) = "O")
				_goFP._oExHandler.PreviewForm.ShowToolbar(.T.)
				m.loToolBar.Visible = .T.
			ENDIF
		ENDIF

	ENDIF
	IF m.llCancelled
		RETURN
	ENDIF 

	IF EMPTY(_goFP.cEmailTo)
		_goFP.SetError(_goFP.GetLoc("DESTNOTDEF"), _goFP.GetLoc("BADCONFIG"))
		RETURN
	ENDIF


	* if sending a fax, we'll just collect the needed info and run the 
	* program in the property "cFAXprg"
	IF _goFP._lSendingFax
		LOCAL lnFaxSel, lnFaxDataSession
		m.lnFaxSel = SELECT()
		m.lnFaxDataSession = SET("Datasession")
		DO (_goFP.cFaxPrg) WITH m.tcFile, _goFP.cEmailTo, _goFP.cEmailBody, _goFP.cEmailSubject
		SET DATASESSION TO (m.lnFaxDataSession)
		SELECT (m.lnFaxSel)
		RETURN 
	ENDIF 

	IF EMPTY(_goFP.cSMTPServer)
		_goFP.SetError(_goFP.GetLoc("SMTPNOTSPE"), _goFP.GetLoc("BADCONFIG"))
		RETURN
	ENDIF

	IF EMPTY(_goFP.cEmailFrom)
		_goFP.SetError(_goFP.GetLoc("FROMEMPTY"), _goFP.GetLoc("BADCONFIG"))
		RETURN
	ENDIF

	IF EMPTY(_goFP.cEmailSubject)
		_goFP.SetError(_goFP.GetLoc("SUBJEMPTY"), _goFP.GetLoc("BADCONFIG"))
		RETURN
	ENDIF

	*!*	_goFP properties
	*!*		lEmailAuto = .T. 		&& Automatically generates the report output file
	*!*		cEmailType = "PDF" 		&& The file type to be used in Emails (PDF, RTF, HTML or XLS)
	*!*		cEmailPRG  = ""

	*!*		cSMTPServer   = ""
	*!*		nSMTPPort     = 25
	*!*		lSMTPUseSSL   = .F.
	*!*		cSMTPUserName = ""
	*!*		cSMTPPassword = ""

	LOCAL loMail AS cdo2000
	m.loMail = CREATEOBJECT("Cdo2000")

	WITH m.loMail
		.cServer     = _goFP.cSMTPServer   && "smtp.live.com"
		.nServerPort = _goFP.nSMTPPort     && 25
		.lUseSSL     = _goFP.lSMTPUseSSL   && .T.

		*!* .nAuthenticate = 1 	&& cdoBasic
		*!* .cUserName   = _goFP.cSMTPUserName && "yourAccount@live.com"
		*!* .cPassword   = _goFP.cSMTPPassword && "yourPassword"

		*!*	IF EMPTY(_goFP.cSMTPUserName) AND EMPTY(_goFP.cSMTPPassword)
		*!*		.nAuthenticate = 0 	&& cdoAnonymous
		*!*	ELSE
		*!*		.nAuthenticate 	= 1 	&& cdoBasic
		*!*		.cUserName   	= _goFP.cSMTPUserName && "yourAccount@live.com"
		*!*		.cPassword   	= _goFP.cSMTPPassword && "yourPassword"
		*!*	ENDIF

		IF EMPTY(_goFP.cSMTPUserName) AND EMPTY(_goFP.cSMTPPassword)
			.nAuthenticate = 0 	&& cdoAnonymous
		ELSE
			.nAuthenticate = 1 	&& cdoBasic
			.cUserName     = _goFP.cSMTPUserName && "yourAccount@live.com"

			IF _goFP.lAutoSendMail AND (_goFP.lCompleteMode = .T.)  && 2013-03-01 by Tarkan Haser
				.cPassword   	= _goFP.cSMTPPassword && "yourPassword"			&& ======> by Nick Porfyris... [20101014]
			ELSE 
				* 2012-10-17
				* If we are in simplified mode, if the password was passed manually we don't need to decrypt
				IF VARTYPE(_Screen.oFoxyPreviewer) = "O" AND NOT EMPTY(NVL(_Screen.oFoxyPreviewer.cSMTPPassword,""))
					.cPassword   	= _goFP.cSMTPPassword
				ELSE 
					.cPassword   	= _goFP.DoDecrypt(_goFP.cSMTPPassword) && "yourPassword"	&& ======> by Nick Porfyris... [20101014]
				ENDIF
			ENDIF 
		ENDIF

		*.cFrom = "yourlAccount@live.com"
		.cFrom    = _goFP.cEmailFrom    && .cUserName
		.cTo      = _goFP.cEmailTo      && "vfpimaging@hotmail.com" && "somebody@otherdomain.com, somebodyelse@otherdomain.com"
		.cCC      = _goFP.cEmailCC
		.cBCC     = _goFP.cEmailBCC
		.cSubject = _goFP.cEmailSubject && "FOXYPREVIEWER email"
		.cReplyTo = _goFP.cEmailReplyTo

		*!* * Uncomment next lines to send HTML body
		*!* *.cHtmlBody = "<html><body><b>This is an HTML body<br>" + ;
		*!* *		"It'll be displayed by most email clients</b></body></html>"
		*!*
		*!* .cTextBody = _goFP.cEmailBody
		*!* && "This is a text body." + CHR(13) + CHR(10) + ;
		*!* && "It'll be displayed if HTML body is not present or by text only email clients"

		IF EMPTY(_goFP.cEmailBody)
			_goFP.cEmailBody = "<HTML><BR></HTML>"
		ENDIF

		IF UPPER(LEFT(_goFP.cEmailBody, 6)) == "<HTML>"
			.cHtmlBody = _goFP.cEmailBody
		ELSE
			.cTextBody = _goFP.cEmailBody
			&& "This is a text body." + CHR(13) + CHR(10) + ;
			&& "It'll be displayed if HTML body is not present or by text only email clients"
		ENDIF

		* Attachments are optional
		IF NOT EMPTY(_goFP._cAttachment) && "myreport.pdf, myspreadsheet.xls"
			.cAttachment = _goFP._cAttachment
		ELSE 
			.cAttachment = m.tcFile
		ENDIF
		
		IF _goFP.lAutoSendMail   && lEmailAuto
			.cAttachment = ALLTRIM(.cAttachment) + ;
				IIF(EMPTY(_goFP.cAttachments), "", ;
					", " + _goFP.cAttachments)
		ENDIF
		.lReadReceipt = _goFP.lReadReceipt
		.lPriority    = _goFP.lPriority
	ENDWITH

	IF m.loMail.SEND() > 0
		LOCAL lcMailErr
		m.lcMailErr = ""
		FOR m.i=1 TO m.loMail.GetErrorCount()
			* ? i, loMail.Geterror(i)
			m.lcMailErr = m.lcMailErr + m.loMail.GetError(m.i) + _CRLF
		ENDFOR
		_goFP.SetError(_goFP.GetLoc("ERRSENDMAI") + ":" + _CRLF + ;
			m.lcMailErr + _CRLF + _goFP.GetLoc("MSGNOTSENT"), _goFP.GetLoc("ERRSENDMAI"))
	ELSE
		_goFP.lEmailed = .T.
		IF NOT _goFP.lSilent
			MESSAGEBOX(_goFP.GetLoc("MSGSUCCESS"),64,_goFP.GetLoc("SENDEMAIL"))
		ENDIF
	ENDIF

	RETURN

ENDPROC



********************************************************************
PROCEDURE SetPrinterProps
*********************************************************************
* Code from Barbara Peisch
* Allows changing the current printer settings
* Using the Printer preferences dialog
* http://www.foxite.com/archives/0000158197.htm

	* Lets the user set all possible printer properties
	LOCAL lcRptFile, lhWindow, lcOrigDevMode, lcModifiedDevMode, lcPrinter, lhPrinter

	* These constants come from the Windows.h file
	*!*		#DEFINE IDOK     1
	*!*		#DEFINE IDCANCEL 2

	#DEFINE DM_OUT_BUFFER 2
	#DEFINE DM_IN_BUFFER  8
	#DEFINE DM_IN_PROMPT  4

	DECLARE INTEGER OpenPrinter IN winspool.drv ;
		STRING pPrinterName, ;
		INTEGER @phPrinter, ;
		INTEGER pDefault

	DECLARE INTEGER GetActiveWindow IN user32

	DECLARE INTEGER DocumentProperties IN winspool.drv ;
		INTEGER hWnd, ;
		INTEGER hPrinter, ;
		STRING pDeviceName, ;
		STRING @pDevModeOutput, ;
		STRING @pDevModeInput, ;
		INTEGER fMode

	DECLARE INTEGER ClosePrinter IN winspool.drv INTEGER hPrinter

	m.lcPrinter = SET("Printer", 3)
	IF NOT EMPTY(m.lcPrinter)
		m.lhWindow = GetActiveWindow()

		m.lhPrinter = 0
		OpenPrinter(m.lcPrinter, @m.lhPrinter, 0)
		IF m.lhPrinter = 0
			Messagebox("Could not open printer.", 48, "Error")
			RETURN
		ENDIF

		m.lcRptFile = SYS(2015)+".FRX"

		TRY
			* Use a unique file name so we can use this in a multi-user situation
			* Using a cursor instead of a physical file doesn't work, but we can
			* create the FRX from a cursor.
			CREATE CURSOR TempCur (Temp C (10))
			CREATE REPORT (JUSTSTEM(m.lcRptFile)) FROM TempCur
			USE IN TempCur
			USE (m.lcRptFile) EXCLUSIVE ALIAS RptFile

			* Use SYS(1037,2) to read the printer settings instead of DocumentProperties
			SYS(1037,2)

			* We only want to save the original settings the first time
			lcOldExpr = EXPR
			lcOldTag  = TAG
			lcOldTag2 = TAG2
			m.lcOrigDevMode     = TAG2
			lcDevMode = TAG2
			m.lcModifiedDevMode = TAG2

			* Show printer settings dialog.
			m.lnResult = DocumentProperties(m.lhWindow, m.lhPrinter, m.lcPrinter, @m.lcModifiedDevMode, @m.lcOrigDevMode, DM_IN_PROMPT+DM_IN_BUFFER+DM_OUT_BUFFER)

			IF m.lnResult <> IDCANCEL
			* Set the printer to the new options
				SELECT RptFile
				replace expr WITH '', ;
					tag WITH '', ;
					TAG2 WITH m.lcModifiedDevMode
				lcDevMode = m.lcModifiedDevMode
				SYS(1037,3)		&& Writes the printer settings out to the printer
			ENDIF
		CATCH TO loException
		FINALLY 
			* Get rid of the temporary FRX
			IF USED("RptFile")
				USE IN RptFile
			ENDIF 
			IF FILE(m.lcRptFile)
				ERASE (JUSTSTEM(m.lcRptFile)+".*")
			ENDIF 

			* Close the printer handle
			IF NOT EMPTY(m.lhPrinter)
				ClosePrinter(m.lhPrinter)
			ENDIF 
		ENDTRY 
	ENDIF

ENDPROC && SetPrinterProps




*********************************************************************
PROCEDURE GetCurPath
*********************************************************************
	LOCAL lcProc, lnPos, lcFile, lcPath
	m.lcProc = SYS(16)
	IF "PROCEDURE" $ m.lcProc
		m.lnPos = AT(" ", m.lcProc, 2)
		IF m.lnPos > 0
			m.lcFile = SUBSTR(m.lcProc, m.lnPos + 1)
			m.lcPath = ADDBS(JUSTPATH(m.lcFile))
		ENDIF
	ELSE
		m.lcPath = ADDBS(JUSTPATH(m.lcProc))
	ENDIF
	RETURN m.lcPath
ENDPROC && EndCurPath



*********************************************************************
FUNCTION RC4
*********************************************************************
*!*    Objet : Implémention en VisualFoxPro de l'algorithme de cryptage RC4
*!*    Auteur : C.Chenavier
*!*    Version : 1.00 - 12/03/2006
*!*    RC4 signifie Rivest Cipher 4
*!*    Il a été conçu en 1987 par Ron Rivest de RSA Security.
*!*    Attention, le nom "RC4" est une marque déposée.
*!*    Algorithme : http://en.wikipedia.org/wiki/RC4
*!*    Les tests ont été réalisés grâce à l'article:
*!*    http://en.wikisource.org/wiki/RC4_test_vectors
*!*    Source: http://www.atoutfox.org/articles.asp?ACTION=FCONSULTER&ID=0000000299

	LPARAMETERS cTexte, cClef

	LOCAL I, J, K, nLongClef, nInt, cResult
	LOCAL ARRAY aInt(256)

	FOR m.I = 1 TO 256
		m.aInt(m.I) = m.I - 1
	ENDFOR

	m.J = 0
	m.nLongClef = LEN(M.cClef)
	FOR m.I = 1 TO 256
		m.J = BITAND(m.J + m.aInt(m.I) + ASC(SUBSTR(M.cClef, MOD(m.I-1,M.nLongClef)+1, 1)), 255)
		m.nInt = m.aInt(m.I)
		m.aInt(m.I) = m.aInt(m.J+1)
		m.aInt(m.J+1) = M.nInt
	ENDFOR

	m.I = 1
	m.J = 0
	m.cResult = ''
	FOR m.K = 1 TO LEN(M.cTexte)
		m.I = BITAND(m.I, 255) + 1
		m.J = BITAND(m.J + m.aInt(m.I), 255)
		m.nInt = m.aInt(m.I)
		m.aInt(m.I) = m.aInt(m.J+1)
		m.aInt(m.J+1) = M.nInt
		m.cResult = M.cResult + CHR(BITXOR(ASC(SUBSTR(M.cTexte, m.K, 1)), ;
			m.aInt(BITAND(m.aInt(m.I) + M.nInt, 255)+1)))
	ENDFOR

	RETURN M.cResult
ENDFUNC && RC4


PROCEDURE PR_SetLanguage
	LPARAMETERS tcLanguage
	m.tcLanguage = NVL(m.tcLanguage, "ENGLISH")
	m.tcLanguage = UPPER(m.tcLanguage)

	IF m.tcLanguage = "ESPANIOL"
		m.tcLanguage = "SPANISH"
	ENDIF

	LOCAL lcDBFFile, lnSelect

	m.lnSelect = SELECT()
	m.lcDBFFile = "FoxyPreviewer_Locs.dbf"

	TRY
		USE (m.lcDBFFile) IN 0 AGAIN SHARED
	CATCH
		MESSAGEBOX("Could not load the localizations table.", 48, "Error")
	ENDTRY
	SELECT (m.lcDBFFile)

	LOCATE FOR m.tcLanguage $ (LANGUAGE + LocalLang)	&& Allows searching using the English language name or the local. Eg. "FRENCH / FRANÇAIS"

	IF EOF() && Could not locate the desired language
		MESSAGEBOX("The language " + "'" + m.tcLanguage + "'" + " was not found!"+ _CRLF +;
			"Make sure that the desired language is available in FoxyPreviewer_Locs.dbf", 48, "Error")
		GO TOP
	ELSE 
		TRY 
			_Screen.oFoxyPreviewer.cLanguage = tcLanguage
		CATCH
		ENDTRY
	ENDIF


	TRY
		WITH _Screen.oFoxyPreviewer
			.cCodePage             = cCodePage

			._InitStatusText       = INITSTATUS
	    	._PrepassStatusText    = PREPSTATUS 
		    ._RunStatusText        = RUNSTATUS  
		    ._SecondsText          = SECONDS   
			._CancelInstrText      = CANCELINST
			._CancelQueryText      = CANCELQUER
			._ReportIncompleteText = REPINCOMPL
			._AttentionText        = ATTENTION 

			._ErrorSendingMail     = ERRSENDMAI
			._MsgNotSentText       = MSGNOTSENT
			._MsgSuccessText       = MSGSUCCESS
			._SendEmailText        = SENDEMAIL
			._AttachNotFoundText   = ATACHNOTFO
			._SendingText          = MSGSENDING
		ENDWITH
	CATCH
	ENDTRY

	TRY 
		SCATTER NAME loLang
		_Screen.oFoxyPreviewer._oLang       = loLang
		_Screen.oFoxyPreviewer._cLangLoaded = m.tcLanguage
	CATCH
	ENDTRY 

	USE IN (m.lcDBFFile)
	SELECT (m.lnSelect)
ENDPROC


PROCEDURE PR_GetLoc
	LPARAMETERS tcString
	
	LOCAL lcTransl
	TRY
		m.lcTransl = TRIM(EVALUATE("_Screen.oFoxyPreviewer._oLang." + m.tcString))
	CATCH
		MESSAGEBOX("Could not locate the string '" + ;
			m.tcString + "' in the localizations table." + ;
			"Please make sure that you have the latest version available of 'FoxyPreviewer_locs.dbf'.", 48, "Error")
	ENDTRY
	RETURN m.lcTransl
ENDPROC


* Adapted from original code from Sergey Berezniker
* http://www.berezniker.com/content/pages/visual-foxpro/enumerating-printer-forms#comment-349

PROCEDURE GetFormDimensions
	LPARAMETERS tcPrinter, tnID, tnWidth, tnHeight

	LOCAL llShowResult
	IF EMPTY(m.tcPrinter)
		m.tcPrinter = GETPRINTER()
		m.llShowResult = .T.
	ENDIF

	IF EMPTY(m.tnID)
		m.tnID = 9 && A4
	ENDIF

	IF EMPTY(m.tnWidth)
		STORE 0 TO m.tnWidth, m.tnHeight
	ENDIF

	* Form flag values
	#define FORM_USER       0x00000000
	#define FORM_BUILTIN    0x00000001
	#define FORM_PRINTER    0x00000002

	LOCAL loPrintForms
	m.loPrintForms = CREATEOBJECT("EnumPrinterForms") && , "EnumPrinterForms.fxp")
	m.loPrintForms.cUnit = "Internal" && "Metric" && "English"
	m.loPrintForms.nRound = 2

	* Enumerate forms for default VFP printer
	LOCAL lcPrinter
	m.loPrintForms.GetFormList(m.tcPrinter, "Envelope")

	IF NOT EMPTY(m.loPrintForms.cErrorMessage)
		IF _VFP.StartMode = 0
			MESSAGEBOX(m.loPrintForms.cErrorMessage + _CRLF +;
				m.loPrintForms.cApiErrorMessage,16, "Error loading printer information")
		ENDIF
		RETURN
	ENDIF


	*!*	* Enumerate all print forms and get info about specific for stored in the properties of the object
	*!*	IF NOT loPrintForms.GetFormList(lcPrinter, "Envelope")
	*!*		? loPrintForms.cErrorMessage
	*!*		? loPrintForms.cApiErrorMessage
	*!*		* Error
	*!*	ENDIF
	*!*
	*!*	? loPrintForms.cFormName, loPrintForms.nFormNumber
	*!*
	*!*	CREATE CURSOR crsPrintrForms ( ;
	*!*			FormID I, ;
	*!*			FormName C(30), ;
	*!*			Width N(9, loPrintForms.nRound), ;
	*!*			Height  N(9,loPrintForms.nRound), ;
	*!*			FormFlags I, ;
	*!*			IsSupported L)

	LOCAL I, loOneForm, lcFormName
	FOR m.I=1 TO m.loPrintForms.oFormList.Count
		m.loOneForm = m.loPrintForms.oFormList.Item(m.I)

		IF m.loOneForm.FormID = m.tnID
			m.tnWidth    = m.loOneForm.Width
			m.tnHeight   = m.loOneForm.Height
			m.lcFormName = m.loOneForm.FormName
			EXIT
		ENDIF

		*!*		*? loOneForm.FormID, loOneForm.FormName, loOneForm.Width, loOneForm.Height, loOneForm.FormFlags
		*!*		INSERT INTO crsPrintrForms FROM NAME loOneForm
	ENDFOR

	m.loOneForm = NULL
	m.loPrintForms = Null

	IF m.llShowResult
		MESSAGEBOX("Printer: " + m.tcPrinter + _CRLF + ;
			"Form # " + TRANSFORM(m.tnID) + " - " + TRANSFORM(m.lcFormName) + _CRLF + ;
			"Width: " + TRANSFORM(m.tnWidth) + _CRLF + ;
			"Height: " + TRANSFORM(m.tnHeight), 64, "Printer Info")
	ENDIF
	RETURN

* Class: EnumPrinterForms
* Author: Sergey Berezniker
* http://www.berezniker.com/
*
* The EnumPrinterForms class code
* EnumPrinterForms.prg
DEFINE CLASS EnumPrinterForms AS Custom
	HIDDEN hHeap, nInch2mm, nCm2mm, nCoefficient

	* Specified a Printer name for which the list of supported forms is retrieved
	*	If empty, it would retrieve the list of forms defined on local PC
	cPrinterName = ""
	* The form attributes are stored in thousands of millimeters
	* It can be converted by class to inches ("English") or centimeters ("Metric")
	cUnit = "Internal"
	* Specified how to round result of conversion
	nRound = 0
	* Conversion Coefficients
	nInch2mm = 25.4
	nCm2mm = 10
	nCoefficient = 1

	* Error code and Error message returned by Win API
	cApiErrorMessage = ""
	* Error message returned by class itself (none-API error)
	cErrorMessage = ""

	hHeap = 0
	* Collection of Print Forms retrieved
	oFormList = Null
	* Win API support class
	oWas = NULL

	* Store Form # for the form
	cFormName = ""
	nFormNumber = 0

	PROCEDURE Init(tcUnit, tnRound)

		IF PCOUNT() >= 1
			This.cUnit = PROPER(m.tcUnit)
		ENDIF
		IF PCOUNT() = 2
			This.nRound = m.tnRound
		ENDIF
		This.oFormList = CREATEOBJECT("Collection")
		This.oWas = CREATEOBJECT("WinApiSupport") && , "WinApiSupport.fxp")

		* Load DLLs
		This.LoadApiDlls()
		* Allocate a heap
		This.hHeap = HeapCreate(0, 4096*10, 0)
	ENDPROC

	PROCEDURE cUnit_Assign(tcUnit)
		IF INLIST(m.tcUnit, "English", "Metric", "Internal")
			This.cUnit = PROPER(m.tcUnit)
		ELSE
			RETURN
		ENDIF
		* Calculate conversion coefficient
		DO CASE
			CASE PROPER(This.cUnit) = "English"
				This.nCoefficient = This.nInch2mm * 1000
			CASE PROPER(This.cUnit) = "Metric"
				This.nCoefficient = This.nCm2mm * 1000
			OTHERWISE
				This.cUnit = "Internal"
				This.nCoefficient = 1
		ENDCASE
	ENDPROC

	PROCEDURE Destroy
		IF This.hHeap <> 0
			HeapDestroy(This.hHeap)
		ENDIF
	ENDPROC

	*PROCEDURE GetFormNumber(tcPrinterName, tcFormName)
	*ENDPROC

	PROCEDURE GetFormList(tcPrinterName, tcFormName)
		LOCAL lhPrinter, llSuccess, lnNeeded, lnNumberOfForms, lnBuffer, I, lcFormName, lcFormName

		IF NOT EMPTY(m.tcPrinterName)
			This.cPrinterName = m.tcPrinterName
		ENDIF

		IF NOT EMPTY(m.tcFormName)
			This.cFormName = m.tcFormName
		ENDIF

		This.ClearErrors()
		This.nFormNumber = 0
		This.oFormList.Remove(-1)

		* Open a printer
		m.lhPrinter = 0
		m.lnResult = OpenPrinter( IIF(EMPTY(This.cPrinterName),0,This.cPrinterName), @m.lhPrinter, 0)


		IF  m.lnResult = 0 AND m.lhPrinter = 0
			This.cErrorMessage = "Unable to get printer handle for '" + This.cPrinterName
			This.cApiErrorMessage = WinApiErrMsg(GetLastError())
			RETURN .F.
		ENDIF

		m.lnNeeded = 0
		m.lnNumberOfForms = 0

		* Get the size of the buffer required to fit all forms in lnNeeded
		IF EnumForms(m.lhPrinter, 1,  0, 0, @m.lnNeeded, @m.lnNumberOfForms) = 0
			IF GetLastError() <> 122   && The buffer too small error
				This.cErrorMessage = "Unable to Enumerate Forms"
				This.cApiErrorMessage = WinApiErrMsg(GetLastError())
				RETURN .F.
			ENDIF
		ENDIF

		* Get the list of forms
		m.lnBuffer = HeapAlloc(This.hHeap, 0, m.lnNeeded)
		m.llSuccess = .T.
		IF EnumForms(m.lhPrinter, 1, m.lnBuffer, @m.lnNeeded, @m.lnNeeded, 	@m.lnNumberOfForms  ) = 0
			This.cErrorMessage = "Unable to Enumerate Forms."
			This.cApiErrorMessage = WinApiErrMsg(GetLastError())
			m.llSuccess = .F.
		ENDIF

		IF m.llSuccess
			* Put list of the forms into collection with Form number (i) as a key
			* A collection here can be replaced with an array or a cursor.
			FOR m.I=1 TO m.lnNumberOfForms
				m.loOneForm = This.OneFormObj()
				WITH m.loOneForm
					lnPointer = m.lnBuffer + (m.I-1) * 32
					.FormID 	= m.I
					.FormFlags 	= This.oWas.Long2NumFromBuffer(lnPointer)
					.FormName 	= This.oWas.StrZFromBuffer(lnPointer+4)
					.Width 		= This.ConvertFormDimension(lnPointer+8)
					.Height		= This.ConvertFormDimension(lnPointer+12)
					.Left 		= This.ConvertFormDimension(lnPointer+16)
					.Top 		= This.ConvertFormDimension(lnPointer+20)
					.Right 		= This.ConvertFormDimension(lnPointer+24)
					.Bottom 	= This.ConvertFormDimension(lnPointer+28)
					* Store form # for requested form
					IF UPPER(.FormName) == UPPER(This.cFormName )
						This.nFormNumber = .FormID
					ENDIF
				ENDWITH
				This.oFormList.Add(m.loOneForm, TRANSFORM(m.I))
			ENDFOR

			* Mark forms that are supported by the printer
			m.llSuccess = This.MarkSupportedForms()

		ENDIF

		= HeapFree(This.hHeap, 0, m.lnBuffer )
		= ClosePrinter(m.lhPrinter)

		RETURN m.llSuccess

	FUNCTION ConvertFormDimension(tnPointer)
		RETURN ROUND(This.oWas.Long2NumFromBuffer(m.tnPointer) / This.nCoefficient, This.nRound)
	ENDFUNC

	PROCEDURE MarkSupportedForms
		#DEFINE DC_PAPERS     2
		LOCAL lnCount, lcBufferPapers, lnIndex, lcStr, lnFormID, loOneForm
		m.lcBufferPapers = REPLICATE(CHR(0), 2*512)
		* Get the list of supported paper sizes, 2 bytes per item
		m.lnCount = DeviceCapabilities(This.cPrinterName, "", DC_PAPERS, @m.lcBufferPapers, 0)
		IF m.lnCount <= 0
			* Call to DeviceCapabilities failed
			This.cErrorMessage = "DeviceCapabilities failed."
			This.cApiErrorMessage = WinApiErrMsg(GetLastError())
			RETURN .F.
		ENDIF

		FOR m.lnIndex=1 To m.lnCount
			m.lcStr  = SUBSTR(m.lcBufferPapers, (m.lnIndex-1)*2+1, 2)
			m.lnFormID = This.oWas.Short2Num(m.lcStr)
			IF NOT EMPTY(This.oFormList.Getkey(TRANSFORM(m.lnFormID)))
				m.loOneForm = This.oFormList.Item(TRANSFORM(m.lnFormID))
				m.loOneForm.IsSupported = .T.
			ENDIF
		ENDFOR
	ENDPROC

	* Create an object with forms attributes
	PROCEDURE OneFormObj
		LOCAL loOneForm
		m.loOneForm = NEWOBJECT("Empty")
		ADDPROPERTY(m.loOneForm, "FormFlags", 0)
		ADDPROPERTY(m.loOneForm, "FormId", 0)
		ADDPROPERTY(m.loOneForm, "FormName", "")
		ADDPROPERTY(m.loOneForm, "Width", 0)
		ADDPROPERTY(m.loOneForm, "Height", 0)
		ADDPROPERTY(m.loOneForm, "Left", 0)
		ADDPROPERTY(m.loOneForm, "Top", 0)
		ADDPROPERTY(m.loOneForm, "Right", 0)
		ADDPROPERTY(m.loOneForm, "Bottom", 0)
		* Indicates if printer supports the form
		ADDPROPERTY(m.loOneForm, "IsSupported", .F.)
		RETURN m.loOneForm
	ENDPROC

	PROCEDURE ClearErrors
		This.cErrorMessage = ""
		This.cApiErrorMessage = ""
	ENDPROC

	HIDDEN PROCEDURE LoadApiDlls
		DECLARE Long HeapCreate IN WIN32API Long dwOptions, Long dwInitialSize, Long dwMaxSize
		DECLARE Long HeapAlloc IN WIN32API Long hHeap, Long dwFlags, Long dwBytes
		DECLARE Long HeapFree IN WIN32API Long hHeap, Long dwFlags, Long lpMem
		DECLARE HeapDestroy IN WIN32API Long hHeap
		DECLARE Long GetLastError IN kernel32
	ENDPROC

ENDDEFINE && Class EnumPrinterForms
*----------------------------------------------------------------------------------------------



* Class : WinApiSupport
* Author: Sergey Berezniker
* http://www.berezniker.com/
*
DEFINE CLASS WinApiSupport AS Custom

	* Converts VFP number to the Long integer
	FUNCTION Num2Long(tnNum)
		LOCAL lcString
		m.lcString = SPACE(4)
		=RtlPL2PS(@lcString, BITOR(m.tnNum,0), 4)
		RETURN m.lcString
	ENDFUNC

	* Convert Long integer into VFP numeric variable
	FUNCTION Long2Num(tcLong)
		LOCAL lnNum
		m.lnNum = 0
		= RtlS2PL(@m.lnNum, m.tcLong, 4)
		RETURN m.lnNum
	ENDFUNC

	*  Return Number from a pointer to DWORD
	FUNCTION Long2NumFromBuffer(tnPointer)
		LOCAL lnNum
		m.lnNum = 0
		= RtlP2PL(@m.lnNum, m.tnPointer, 4)
		RETURN m.lnNum
	ENDFUNC

	* Convert Short integer into VFP numeric variable
	FUNCTION Short2Num(tcLong)
		LOCAL lnNum
		m.lnNum = 0
		= RtlS2PL(@m.lnNum, m.tcLong, 2)
		RETURN m.lnNum
	ENDFUNC

	* Retrieve zero-terminated string from a buffer into VFP variable
	FUNCTION StrZFromBuffer(tnPointer)
		LOCAL lcStr, lnStrPointer
		* Allocate 4KB buffer.
		*	Increase the size of the buffer if string could be longer
		*	or use lstrlen to get actual length of the string
		m.lcStr = SPACE(4096)
		m.lnStrPointer = 0
		= RtlP2PL(@m.lnStrPointer, m.tnPointer, 4)
		lstrcpy(@m.lcStr, m.lnStrPointer)
		RETURN LEFT(m.lcStr, AT(CHR(0),m.lcStr)-1)
	ENDFUNC

	*  Return a string from a pointer to LPWString (Unicode string)
	FUNCTION StrZFromBufferW(tnPointer)
		Local lcResult, lnStrPointer, lnLen
		m.lnStrPointer = This.Long2NumFromBuffer(m.tnPointer)

		m.lnLen = lstrlenW(m.lnStrPointer) * 2
		m.lcResult = Replicate(chr(0), m.lnLen)
		= RtlP2PS(@m.lcResult, m.lnStrPointer, m.lnLen)
		m.lcResult = StrConv(StrConv(m.lcResult, 6), 2)

		RETURN m.lcResult
	ENDFUNC

	* Retrieve zero-terminated string
	FUNCTION StrZCopy(tnPointer)
		LOCAL lcStr, lnStrPointer
		* Allocate 4KB buffer.
		*	Increase the size of the buffer if string could be longer
		*	or use lstrlen to get actual length of the string
		m.lcStr = SPACE(4096)
		lstrcpy(@m.lcStr, m.tnPointer)
		RETURN LEFT(m.lcStr, AT(CHR(0),m.lcStr)-1)
	ENDFUNC

ENDDEFINE && WinApiSupport
*------------------------------------------------------------------------

*Helper FUNCTIONs for WinApiSupport (by Sergey Berezniker)
FUNCTION RtlPL2PS(tcDest, tnSrc, tnLen)
	DECLARE RtlMoveMemory IN WIN32API AS RtlPL2PS STRING @Dest, Long @Source, Long Length
	RETURN 	RtlPL2PS(@m.tcDest, m.tnSrc, m.tnLen)

FUNCTION RtlS2PL(tnDest, tcSrc, tnLen)
	DECLARE RtlMoveMemory IN WIN32API AS RtlS2PL Long @Dest, String Source, Long Length
	RETURN 	RtlS2PL(@m.tnDest, @m.tcSrc, m.tnLen)

FUNCTION RtlP2PL(tnDest, tnSrc, tnLen)
	DECLARE RtlMoveMemory IN WIN32API AS RtlP2PL Long @Dest, Long Source, Long Length
	RETURN 	RtlP2PL(@m.tnDest, m.tnSrc, m.tnLen)

FUNCTION RtlP2PS(tcDest, tnSrc, tnLen)
	DECLARE RtlMoveMemory IN WIN32API AS RtlP2PS STRING @Dest, Long Source, Long Length
	RETURN 	RtlP2PS(@m.tcDest, m.tnSrc, m.tnLen)

FUNCTION lstrcpy (tcDest, tnSrc)
	DECLARE lstrcpy IN WIN32API STRING @lpstring1, INTEGER lpstring2
	RETURN 	lstrcpy (@m.tcDest, m.tnSrc)

FUNCTION lstrlenW(tnSrc)
	DECLARE Long lstrlenW IN WIN32API Long src
	RETURN 	lstrlenW(m.tnSrc)

FUNCTION lstrlen(tnSrc)
	DECLARE Long lstrlen IN WIN32API Long src
	RETURN 	lstrlen(m.tnSrc)


* PROCEDURE: WinApiErrMsg
* Author: Sergey Berezniker
* http://www.berezniker.com/
*
* Retrieve message definition from the system's message table.
FUNCTION WinApiErrMsg
	LPARAMETERS tnErrorCode
	#DEFINE FORMAT_MESSAGE_FROM_SYSTEM 0x1000
	LOCAL lcErrBuffer, lnNewErr, lnFlag, lcErrorMessage
	m.lnFlag = FORMAT_MESSAGE_FROM_SYSTEM
	m.lcErrBuffer = REPL(CHR(0),1000)
	m.lnNewErr = FormatMessage(m.lnFlag, 0, m.tnErrorCode, 0, @m.lcErrBuffer,500,0)
	m.lcErrorMessage = Transform(m.tnErrorCode) + "    " + LEFT(m.lcErrBuffer, AT(CHR(0),m.lcErrBuffer)- 1 )
	RETURN m.lcErrorMessage
ENDFUNC
*------------------------------------------------------------------------------------------------



PROCEDURE GetVfpVersion

	* http://www.berezniker.com/content/pages/visual-foxpro/vfp-90-versions
	* Release	        Date	    Version	        Runtime timestamps (EDT)	Description	Download	Notes
	*
	* RTM	            2004/12/22	09.00.0000.2412	2004/12/13 16:20-17:10	    Release to manufacturing
	* SP1	            2005/12/08	09.00.0000.3504	2005/11/04 17:44-18:15		SP1
	* SP2	            2007/10/12	09.00.0000.5721		                        Original release with botched splash screen
	* SP2              	2007/10/16	09.00.0000.5815	2007/10/15 10:15-10:47   	Re-release with fixed splash screen	SP2
	* Hotfix 1 for SP2	2008/04/12	09.00.0000.6303	2008/04/11 15:02	        KB 948528	Hotfix 948528
	* Hotfix 2 for SP2	2008/06/03	09.00.0000.6602	2008/06/03 12:12-12:13	    KB 952548	Hotfix 952548	Cumulative
	* Hotfix 3 for SP2	2009/04/02	09.00.0000.7423	2009/02/23 17:58-17:59	    KB 968409 Original release with VFP9T.DLL missing
	* Hotfix 3 for SP2	2009/04/06	09.00.0000.7423	2009/04/03 12:01-14:45	    KB 968409 Re-release with VFP9T.DLL included	Hotfix 968409	Cumulative
	LOCAL lcVersion
	m.lcVersion = VERSION(4)

	DO CASE
		CASE m.lcVersion = "09.00.0000.2412"
			RETURN "RTM"
		CASE m.lcVersion = "09.00.0000.3504"
			RETURN "SP1"
		CASE m.lcVersion = "09.00.0000.5721"
			RETURN "SP2"
		CASE m.lcVersion = "09.00.0000.5815"
			RETURN "SP2"
		CASE m.lcVersion = "09.00.0000.6303"
			RETURN "SP2 HF1"
		CASE m.lcVersion = "09.00.0000.6602"
			RETURN "SP2 HF2"
		CASE m.lcVersion = "09.00.0000.7423"
			RETURN "SP2 HF3"
		OTHERWISE
			RETURN ""

	ENDCASE

ENDPROC && GetVFPVersion



* DOFOXYTHERM.PRG
* =DoFoxyTherm(90, "Texto label", "Titulo")
* =DoFoxyTherm(-1, "Teste2", "Titulo") && Continuo
* =DoFoxyTherm() && Desliga
PROCEDURE DoFoxyTherm
	LPARAMETERS tnPercent, tcLabelText, tcTitleText
	IF NOT PEMSTATUS(_SCREEN, "oFoxyThermForm", 5)
		_SCREEN.ADDPROPERTY("oFoxyThermForm", "")
	ENDIF
	IF EMPTY(m.tnPercent) AND (VARTYPE(m.tnPercent) <> "N")
		TRY
			_SCREEN.oFoxyThermForm.RELEASE()
		CATCH
		ENDTRY
		_SCREEN.oFoxyThermForm = NULL
		REMOVEPROPERTY(_SCREEN, "oFoxyThermForm")
		RETURN
	ENDIF

	IF TYPE("_Screen.oFoxyThermForm.Therm") <> "O"
		DO CreateTherm
	ENDIF
	LOCAL loThermForm AS FORM
	m.loThermForm = _SCREEN.oFoxyThermForm

	m.loThermForm.ThermLabel.CAPTION = EVL(m.tcLabelText, "")
	m.loThermForm.Draw()

	IF NOT EMPTY(m.tcTitleText)
		m.loThermForm.CAPTION = m.tcTitleText
	ENDIF
	IF m.tnPercent = -1
		m.loThermForm.Therm.Marquee = .T.
	ELSE
		IF m.loThermForm.Therm.Marquee = .T.
			m.loThermForm.Therm.Marquee = .F.
		ENDIF
		m.loThermForm.Therm.VALUE = m.tnPercent
	ENDIF
	m.loThermForm.VISIBLE = .T.

	RETURN
ENDPROC  && DoFoxyTherm


PROCEDURE CreateTherm
	LOCAL loForm AS FORM
	* loForm = CREATEOBJECT("FORM")
	m.loForm = CREATEOBJECT("ATLForm") && ITLFFORM = In "Top Level Forn" FORM

	_SCREEN.oFoxyThermForm = m.loForm
	LOCAL lnBorder, liThermHeight, liThermWidth, liThermTop, liThermLeft
	m.lnBorder = 7
	WITH m.loForm AS FORM

		.SCALEMODE = 3 && Pixels
		.HEIGHT = 48
		.HALFHEIGHTCAPTION = .T.
		.WIDTH = 356
		.AUTOCENTER = .T.
		.BORDERSTYLE = 2
		.CONTROLBOX = .F.
		.CLOSABLE = .F.
		.MAXBUTTON = .F.
		.MINBUTTON = .F.
		.MOVABLE = .F.
		.ALWAYSONTOP = .T.
		.ALLOWOUTPUT = .F.

		.NEWOBJECT("Therm","ctl32_progressbar", "PR_ctl32_progressbar.vcx") &&, LOCFILE("FoxyPreviewer.app"))
		.NEWOBJECT("ThermLabel", "Label")

		.ThermLabel.VISIBLE = .T.
		.ThermLabel.FONTBOLD = .T.
		.ThermLabel.TOP = 4
		.ThermLabel.WIDTH = .WIDTH - (m.lnBorder * 2)
		.ThermLabel.ALIGNMENT = 2 && Center
		m.liThermHeight = .HEIGHT - (m.lnBorder * 2) - .ThermLabel.HEIGHT
		m.liThermWidth = .WIDTH - (m.lnBorder * 2)
	ENDWITH
	m.liThermTop = m.lnBorder + 20
	m.liThermLeft = m.lnBorder
	WITH m.loForm.Therm
		.TOP = m.liThermTop
		.LEFT = m.liThermLeft
		.HEIGHT = m.liThermHeight
		.WIDTH = m.liThermWidth
		.MarqueeSpeed = 30
		.MarqueeAnimationSpeed = 30
		.VISIBLE = .T.
		.CAPTION = ""
	ENDWITH
	loForm.Visible = .T. 

ENDPROC && CreateTherm

DEFINE CLASS ATLForm as Form	&& 2011-08-12 - Jacques Parent
	ShowWindow = 2				&& Define a form AS TOP LEVEL FORM
	ShowInTaskBar = .F. 
ENDDEFINE && ATLFFORM





* Helper form that I needed to create in order to force the change of the current DataSession to the default
* in order to initialize FoxyPreviewer from a PrivateDataSession form
* This was essencial to avoid the error of losing the Data from Grids and Combos from some forms.
DEFINE CLASS FoxyInitForm AS Form
	DataSession = 2 && Private DataSession
	Visible = .F.
	AllowOutput = .F.

	PROCEDURE Load
		SET TALK OFF
		SET CONSOLE OFF
	ENDPROC

	PROCEDURE Init

		LPARAMETERS tcSys16, tcLocalPath

		LOCAL lnSession
		m.lnSession = SET("Datasession")
		SET DATASESSION TO 1 && Default

		LOCAL lcSetFixed
		m.lcSetFixed = SET("Fixed")
		SET FIXED OFF

		LOCAL loHelper
		m.loHelper = CREATEOBJECT("PreviewHelper", .T.)
		m.loHelper.lCompleteMode = .F.


		* Check if we have any printer installed
		IF APRINTERS(gaPrinters) = 0
			m.loHelper.SetError(m.loHelper.GetLoc("ERRNOPRINTER"))
			SET REPORTBEHAVIOR 80
			m.loHelper = NULL
			SET FIXED &lcSetFixed.
			RETURN .F.
		ENDIF


		* 2011-04-22 Don Higgings
		* is there a reportoutput system variable?
		* if not better make one that points to
		* the one we distribute with the EXE ( we put it in the same folder as the EXE )
		IF VARTYPE(_ReportOutput) = "U"
			_ReportOutput = "pr_FRXOutput.Prg"
		ENDIF

		LOCAL loListener as FXLISTENER OF "PR_ReportListener.vcx"
		IF UPPER(JUSTEXT(m.tcSys16)) = "APP"
			m.loListener = NEWOBJECT(MAIN_LISTENER, "PR_ReportListener.vcx", m.tcSys16)
			IF NOT ("_GDIPLUS.VCX" $ SET("Classlib"))
				SET CLASSLIB TO "_GdiPlus.vcx" IN (m.tcSys16) ADDITIVE
			ENDIF
		ELSE
			m.loListener = NEWOBJECT(MAIN_LISTENER, ADDBS(JUSTPATH(m.tcSys16)) + "PR_ReportListener.vcx")

			IF NOT ("_GDIPLUS.VCX" $ SET("Classlib"))
				SET CLASSLIB TO ADDBS(JUSTPATH(m.tcSys16)) + "_GdiPlus.vcx" ADDITIVE
			ENDIF
		ENDIF

		IF NOT UPPER(JUSTFNAME(m.tcSys16)) $ SET("PROCEDURE")
			SET PROCEDURE TO (m.tcSys16) ADDITIVE
		ENDIF


		TRY
			m.loListener.fxFeedbackClass = m.loHelper._cThermClass
		CATCH
		ENDTRY
		m.loListener.QuietMode = m.loHelper.lQuietMode

		* Additional information:
		* http://msdn.microsoft.com/en-us/library/ms949546(VS.80).aspx
		* http://fox.wikis.com/wc.dll?Wiki~DeployingReportBehavior90InRuntime

		* This is to remove a default listener reference to be replaced
		* Clean up
		IF TYPE([_oReportOutput("1")]) = "O"
			_oReportOutput.Remove("1")
		ENDIF


		LOCAL lcReportOutput
		m.lcReportOutput = "pr_FRXOutput"

		TRY 
			DO (m.lcReportOutput) WITH 1, m.loListener
			* DO (m.lcReportOutput) IN "FoxyPreviewer.App" with 1, m.loListener
		CATCH
			MESSAGEBOX("Could not find the 'ReportOutput.App' file. This file is needed to have the new features of FoxyPreviewer." + _CRLF + ;
				"Please make sure to set the global variable '_REPORTOUTPUT' with the full path of this file " + ;
				"or save it in a folder that your app can reach", 48, "FoxyPreviewer not loaded!")
		ENDTRY
		m.loListener = ""

		*	#DEFINE PRINT_MODE    0
		*	#DEFINE PREVIEW_MODE  1
		*	#DEFINE OUTPUTAPP_LOADTYPE_RELOAD 2
		*	DO (_ReportOutput) WITH ;
		*	      PREVIEW_MODE , loListener, OUTPUTAPP_LOADTYPE_RELOAD

		LOCAL loSettings, lcDefaultSetFile
		m.loSettings = CREATEOBJECT("oFP")

		ADDPROPERTY(m.loSettings, "cSuccessor"    , NULL)
		ADDPROPERTY(m.loSettings, "lQuietMode"    , NULL)
		ADDPROPERTY(m.loSettings, "lShowSearch"   , NULL)
		ADDPROPERTY(m.loSettings, "lShowClose"    , NULL)
		ADDPROPERTY(m.loSettings, "lShowSetup"    , NULL)
		ADDPROPERTY(m.loSettings, "nThermType"    , NULL)
		ADDPROPERTY(m.loSettings, "nThermFormWidth" , NULL)
		ADDPROPERTY(m.loSettings, "lOpenViewer"   , NULL)
		ADDPROPERTY(m.loSettings, "lPrintVisible" , NULL)
		ADDPROPERTY(m.loSettings, "lShowPrintBtn" , NULL)
		ADDPROPERTY(m.loSettings, "lShowPageCount", NULL)
		ADDPROPERTY(m.loSettings, "lShowFileFormatIcons", NULL) && shows / hides the file format icons in context menus for saving
		
		ADDPROPERTY(m.loSettings, "lSaveToFile"   , NULL)
*		ADDPROPERTY(m.loSettings, "cLanguage"     , NULL)
		ADDPROPERTY(m.loSettings, "_cLanguageFromDBF", m.loHelper.cLanguage)

		ADDPROPERTY(m.loSettings, "_cOrigRepPreview" , _REPORTPREVIEW)
		ADDPROPERTY(m.loSettings, "_cLocalPath"    , m.tcLocalPath) && IIF(EMPTY(lcLocalPath), NULL, lcLocalPath)
		ADDPROPERTY(m.loSettings, "_oSettingsSheet", NULL)

		ADDPROPERTY(m.loSettings, "lSendToEmail"   , NULL)
		ADDPROPERTY(m.loSettings, "lShowMiniatures", NULL)
		ADDPROPERTY(m.loSettings, "lPrinterPref"   , NULL)
		ADDPROPERTY(m.loSettings, "lSaveAsImage"   , NULL)
		ADDPROPERTY(m.loSettings, "lSaveAsHTML"    , NULL)
		ADDPROPERTY(m.loSettings, "lSaveAsMHT"     , NULL)
		ADDPROPERTY(m.loSettings, "lSaveAsRTF"     , NULL)
		ADDPROPERTY(m.loSettings, "lSaveAsXLS"     , NULL)
		ADDPROPERTY(m.loSettings, "lSaveAsPDF"     , NULL)
		ADDPROPERTY(m.loSettings, "lSaveAsTXT"     , NULL)
		ADDPROPERTY(m.loSettings, "nCanvasCount"   , NULL)

		ADDPROPERTY(m.loSettings, "lEmailAuto"     , NULL)
		ADDPROPERTY(m.loSettings, "cEmailType"     , NULL)
		ADDPROPERTY(m.loSettings, "cEmailPRG"      , NULL)
		ADDPROPERTY(m.loSettings, "cFaxPRG"        , NULL)

		ADDPROPERTY(m.loSettings, "lShowPrinters"  , NULL)
		ADDPROPERTY(m.loSettings, "nEmailMode"     , NULL)
		ADDPROPERTY(m.loSettings, "cSMTPUserName"  , NULL)
		ADDPROPERTY(m.loSettings, "cSMTPPassword"  , NULL)
		ADDPROPERTY(m.loSettings, "nSMTPPort"      , NULL)
		ADDPROPERTY(m.loSettings, "cSMTPServer"    , NULL)
		ADDPROPERTY(m.loSettings, "lSMTPUseSSL"    , NULL)
		ADDPROPERTY(m.loSettings, "cEmailTo"       , NULL)
		ADDPROPERTY(m.loSettings, "cEmailSubject"  , NULL)
		ADDPROPERTY(m.loSettings, "cEmailBody"     , NULL)
		ADDPROPERTY(m.loSettings, "cEmailFrom"     , NULL)
		ADDPROPERTY(m.loSettings, "cEmailBodyFile" , NULL)
		ADDPROPERTY(m.loSettings, "cAttachments"   , NULL)
		ADDPROPERTY(m.loSettings, "cSaveDefName"   , NULL)

		ADDPROPERTY(m.loSettings, "cEmailCC"       , NULL)
		ADDPROPERTY(m.loSettings, "cEmailBCC"      , NULL)
		ADDPROPERTY(m.loSettings, "cEmailReplyTo"  , NULL)

		* Read only properties
		* Changing their values will not affect anything
		ADDPROPERTY(m.loSettings, "cVersion"       , FOXYPREVIEWER_VERSION2)
		ADDPROPERTY(m.loSettings, "nVersion"       , FOXYPREVIEWER_VERSION)

		ADDPROPERTY(m.loSettings, "lSilent"        , NULL)

		ADDPROPERTY(m.loSettings, "nButtonSize"    , NULL)
		ADDPROPERTY(m.loSettings, "cOutputPath"    , NULL)
		ADDPROPERTY(m.loSettings, "nPrinterPropType" , NULL)
		ADDPROPERTY(m.loSettings, "lDirectPrint"   , NULL)
		ADDPROPERTY(m.loSettings, "nSearchPages"   , NULL)

		ADDPROPERTY(m.loSettings, "nZoomLevel"     , NULL)
		ADDPROPERTY(m.loSettings, "nWindowState"   , NULL)
		ADDPROPERTY(m.loSettings, "nDockType"      , NULL)
		ADDPROPERTY(m.loSettings, "nMaxMiniatureDisplay"   , NULL)
		ADDPROPERTY(m.loSettings, "nShowToolBar"   , NULL)
		ADDPROPERTY(m.loSettings, "cFormIcon"      , NULL)
		ADDPROPERTY(m.loSettings, "cTitle"         , NULL)
		ADDPROPERTY(m.loSettings, "cToolbarTitle"  , NULL)
		ADDPROPERTY(m.loSettings, "nPreviewBackColor" , NULL)

		* Status properties that are filled after the report is run
		ADDPROPERTY(m.loSettings, "lPrinted"       , .F.)
		ADDPROPERTY(m.loSettings, "lEmailed"       , .F.)
		ADDPROPERTY(m.loSettings, "lSaved"         , .F.)
		ADDPROPERTY(m.loSettings, "cDestFile"      , .F.)

		ADDPROPERTY(m.loSettings, "cAdressTable"   , NULL)
		ADDPROPERTY(m.loSettings, "cAdressSearch"  , NULL)

		ADDPROPERTY(m.loSettings, "cImgPrint"      , NULL)
		ADDPROPERTY(m.loSettings, "cImgPrintPref"  , NULL)
		ADDPROPERTY(m.loSettings, "cImgSave"       , NULL)
		ADDPROPERTY(m.loSettings, "cImgClose"      , NULL)
		ADDPROPERTY(m.loSettings, "cImgClose2"     , NULL)
		ADDPROPERTY(m.loSettings, "cImgEmail"      , NULL)
		ADDPROPERTY(m.loSettings, "cImgSetup"      , NULL)
		ADDPROPERTY(m.loSettings, "cImgMiniatures" , NULL)
		ADDPROPERTY(m.loSettings, "cImgSearch"     , NULL)
		ADDPROPERTY(m.loSettings, "cImgSearchAgain", NULL)
		ADDPROPERTY(m.loSettings, "cImgSearchBack" , NULL)
		
		ADDPROPERTY(m.loSettings, "cImgPrintBig"      , NULL)
		ADDPROPERTY(m.loSettings, "cImgPrintPrefBig"  , NULL)
		ADDPROPERTY(m.loSettings, "cImgSaveBig"       , NULL)
		ADDPROPERTY(m.loSettings, "cImgCloseBig"      , NULL)
		ADDPROPERTY(m.loSettings, "cImgClose2Big"     , NULL)
		ADDPROPERTY(m.loSettings, "cImgEmailBig"      , NULL)
		ADDPROPERTY(m.loSettings, "cImgSetupBig"      , NULL)
		ADDPROPERTY(m.loSettings, "cImgMiniaturesBig" , NULL)
		ADDPROPERTY(m.loSettings, "cImgSearchBig"     , NULL)
		ADDPROPERTY(m.loSettings, "cImgSearchAgainBig", NULL)
		ADDPROPERTY(m.loSettings, "cImgSearchBackBig" , NULL)

		* PDF related properties
		ADDPROPERTY(m.loSettings, "lPDFEmbedFonts"  , NULL)
		ADDPROPERTY(m.loSettings, "lPDFCanPrint"    , NULL)
		ADDPROPERTY(m.loSettings, "lPDFCanEdit"     , NULL)
		ADDPROPERTY(m.loSettings, "lPDFCanCopy"     , NULL)
		ADDPROPERTY(m.loSettings, "lPDFCanAddNotes" , NULL)
		ADDPROPERTY(m.loSettings, "lPDFEncryptDocument" , NULL)
		ADDPROPERTY(m.loSettings, "lPDFAsImage"     , NULL)
		ADDPROPERTY(m.loSettings, "cPDFMasterPassword"  , NULL)
		ADDPROPERTY(m.loSettings, "cPDFUserPassword"    , NULL)
		ADDPROPERTY(m.loSettings, "cPDFAuthor"      , NULL)
		ADDPROPERTY(m.loSettings, "cPDFTitle"       , NULL)
		ADDPROPERTY(m.loSettings, "cPDFSubject"     , NULL)
		ADDPROPERTY(m.loSettings, "cPDFKeywords"    , NULL)
		ADDPROPERTY(m.loSettings, "cPDFCreator"     , NULL)
		ADDPROPERTY(m.loSettings, "lPDFShowErrors"  , NULL)
		ADDPROPERTY(m.loSettings, "cPDFSymbolFontsList" , NULL)
		ADDPROPERTY(m.loSettings, "cPDFDefaultFont" , NULL)
		ADDPROPERTY(m.loSettings, "nPDFPageMode"    , NULL)
		ADDPROPERTY(m.loSettings, "lPDFReplaceFonts", NULL)
		ADDPROPERTY(m.loSettings, "nPDFLineHeightRatio" , NULL)

		ADDPROPERTY(m.loSettings, "lExpandFields"  , NULL)
		ADDPROPERTY(m.loSettings, "cPrintJobName"  , NULL)

		ADDPROPERTY(m.loSettings, "lShowCopies"    , NULL)
		ADDPROPERTY(m.loSettings, "nCopies"        , NULL)

		ADDPROPERTY(m.loSettings, "lReadReceipt"   , NULL)
		ADDPROPERTY(m.loSettings, "lPriority"      , NULL)

		ADDPROPERTY(m.loSettings, "cEncryptPROCEDURE", NULL)
		ADDPROPERTY(m.loSettings, "cDecryptPROCEDURE", NULL)
		ADDPROPERTY(m.loSettings, "cCryptKey"        , NULL)


		* XLS properties
		ADDPROPERTY(m.loSettings, "cExcelDefaultExtension", NULL)
		ADDPROPERTY(m.loSettings, "lExcelConvertToXLS"    , NULL)
		ADDPROPERTY(m.loSettings, "lExcelRepeatHeaders"   , NULL)
		ADDPROPERTY(m.loSettings, "lExcelRepeatFooters"   , NULL)
		ADDPROPERTY(m.loSettings, "lExcelHidePageNo"      , NULL) && Shows report fields that contain "_PAGENO" information
		ADDPROPERTY(m.loSettings, "lExcelAlignLeft"       , NULL)
		ADDPROPERTY(m.loSettings, "nExcelSaveFormat"      , NULL)

		ADDPROPERTY(m.loSettings, "cCodePage"             , NULL)

		ADDPROPERTY(m.loSettings, "lRepeatInPage"         , NULL)
		ADDPROPERTY(m.loSettings, "lRepeatWhenFree"       , NULL)
 
		* Watermark properties
		ADDPROPERTY(m.loSettings, "cWatermarkImage"       , "")
		ADDPROPERTY(m.loSettings, "nWatermarkType"        , 1)    && 1 = colored ; 2 = greyscale
		ADDPROPERTY(m.loSettings, "nWatermarkTransparency", 0.25) && 0 = transparent ; 1 = opaque
		ADDPROPERTY(m.loSettings, "nWatermarkWidthRatio"  , 0.75) && 0 - 1
		ADDPROPERTY(m.loSettings, "nWatermarkHeightRatio" , 0.75) && 0 - 1

		* Double byte language
		ADDPROPERTY(m.loSettings, "lDoubleByteLanguage"   , NULL)
		

		IF _VFP.StartMode = 0

			* Adding _MemberData to Make some of the Captions easier to read in Intellisense
			IF PEMSTATUS(_Screen, "_MemberData", 5) = .F.
				_Screen.AddProperty("_MemberData")
				_Screen._MemberData = [<VFPData>]+;
					[<memberdata name="ofoxypreviewer" type="Property" display="oFoxyPreviewer"/>]+;
					[</VFPData>]
			ENDIF


			ADDPROPERTY(m.loSettings, "_MemberData", "")

			m.loSettings._MemberData = [<VFPData>]+;
				[<memberdata name="sendemailusingcdo" type="Property" display="SendEmailUsingCDO"/>]+;
				[<memberdata name="lquietmode" type="Property" display="lQuietMode"/>]+;
				[<memberdata name="lshowsearch" type="Property" display="lShowSearch"/>]+;
				[<memberdata name="lshowclose" type="Property" display="lShowClose"/>]+;
				[<memberdata name="lshowsetup" type="Property" display="lShowSetup"/>]+;
				[<memberdata name="nthermtype" type="Property" display="nThermType"/>]+;
				[<memberdata name="nthermformwidth" type="Property" display="nThermFormWidth"/>]+;
				[<memberdata name="lopenviewer" type="Property" display="lOpenViewer"/>]+;
				[<memberdata name="lprintvisible" type="Property" display="lPrintVisible"/>]+;
				[<memberdata name="lshowprintbtn" type="Property" display="lShowPrintBtn"/>]+;
				[<memberdata name="lshowpagecount" type="Property" display="lShowPageCount"/>]+;
				[<memberdata name="lsavetofile" type="Property" display="lSaveToFile"/>]+;
				[<memberdata name="clanguage" type="Property" display="cLanguage"/>]+;
				[<memberdata name="lsendtoemail" type="Property" display="lSendToEmail"/>]+;
				[<memberdata name="lshowminiatures" type="Property" display="lShowMiniatures"/>]+;
				[<memberdata name="lprinterpref" type="Property" display="lPrinterPref"/>]+;
				[<memberdata name="lsaveasimage" type="Property" display="lSaveAsImage"/>]+;
				[<memberdata name="lsaveashtml" type="Property" display="lSaveAsHTML"/>]+;
				[<memberdata name="lsaveasmht" type="Property" display="lSaveAsMHT"/>]+;
				[<memberdata name="lsaveasrtf" type="Property" display="lSaveAsRTF"/>]+;
				[<memberdata name="lsaveasxls" type="Property" display="lSaveAsXLS"/>]+;
				[<memberdata name="lsaveaspdf" type="Property" display="lSaveAsPDF"/>]+;
				[<memberdata name="lsaveastxt" type="Property" display="lSaveAsTXT"/>]+;
				[<memberdata name="ncanvascount" type="Property" display="nCanvasCount"/>]+;
				[<memberdata name="lemailauto" type="Property" display="lEmailAuto"/>]+;
				[<memberdata name="cemailprg" type="Property" display="cEmailPRG"/>]+;
				[<memberdata name="cfaxprg" type="Property" display="cFaxPRG"/>]+;
				[<memberdata name="cemailtype" type="Property" display="cEmailType"/>]+;
				[<memberdata name="cemailbodyfile" type="Property" display="cEmailBodyFile"/>]+;
				[<memberdata name="lshowprinters" type="Property" display="lShowPrinters"/>]+;
				[<memberdata name="nemailmode" type="Property" display="nEmailMode"/>]+;
				[<memberdata name="csmtpusername" type="Property" display="cSMTPUserName"/>]+;
				[<memberdata name="csmtppassword" type="Property" display="cSMTPPassword"/>]+;
				[<memberdata name="csavedefname" type="Property" display="cSaveDefName"/>]+;
				[<memberdata name="npreviewbackcolor" type="Property" display="nPreviewBackColor"/>]+;
				[<memberdata name="lshowfileformaticons" type="Property" display="lShowFileFormatIcons"/>]
				
			m.loSettings._MemberData = m.loSettings._MemberData + ;
				[<memberdata name="nsmtpport" type="Property" display="nSMTPPort"/>]+;
				[<memberdata name="csmtpserver" type="Property" display="cSMTPServer"/>]+;
				[<memberdata name="lsmtpusessl" type="Property" display="lSMTPUseSSL"/>]+;
				[<memberdata name="cemailto" type="Property" display="cEmailTo"/>]+;
				[<memberdata name="cemailsubject" type="Property" display="cEmailSubject"/>]+;
				[<memberdata name="cemailbody" type="Property" display="cEmailBody"/>]+;
				[<memberdata name="cemailfrom" type="Property" display="cEmailFrom"/>]+;
		 		[<memberdata name="cemailcc" type="Property" display="cEmailCC"/>]+;
		 		[<memberdata name="cemailbcc" type="Property" display="cEmailBCC"/>]+;
		 		[<memberdata name="cemailreplyto" type="Property" display="cEmailReplyTo"/>]+;
				[<memberdata name="cattachments" type="Property" display="cAttachments"/>]+;
				[<memberdata name="cversion" type="Property" display="cVersion"/>]+;
				[<memberdata name="nversion" type="Property" display="nVersion"/>]+;
				[<memberdata name="nbuttonsize" type="Property" display="nButtonSize"/>]+;
				[<memberdata name="coutputpath" type="Property" display="cOutputPath"/>]+;
				[<memberdata name="nprinterproptype" type="Property" display="nPrinterPropType"/>]+;
				[<memberdata name="ldirectprint" type="Property" display="lDirectPrint"/>]+;
				[<memberdata name="nzoomlevel" type="Property" display="nZoomLevel"/>]+;
				[<memberdata name="nwindowstate" type="Property" display="nWindowState"/>]+;
				[<memberdata name="ndocktype" type="Property" display="nDockType"/>]+;
				[<memberdata name="nmaxminiaturedisplay" type="Property" display="nMaxMiniatureDisplay"/>]+;
				[<memberdata name="nshowtoolbar" type="Property" display="nShowToolbar"/>]+;
				[<memberdata name="lprinted" type="Property" display="lPrinted"/>]+;
				[<memberdata name="lemailed" type="Property" display="lEmailed"/>]+;
				[<memberdata name="lsaved" type="Property" display="lSaved"/>]+;
				[<memberdata name="cdestfile" type="Property" display="cDestFile"/>]+;
				[<memberdata name="cformicon" type="Property" display="cFormIcon"/>]+;
				[<memberdata name="ctitle" type="Property" display="cTitle"/>]+;
				[<memberdata name="ctoolbartitle" type="Property" display="cToolbarTitle"/>]+;
				[<memberdata name="cadresstable" type="Property" display="cAdressTable"/>]+;
				[<memberdata name="ccodepage" type="Property" display="cCodePage"/>]+;
				[<memberdata name="cadresssearch" type="Property" display="cAdressSearch"/>]+;
				[<memberdata name="lrepeatinpage" type="Property" display="lRepeatInPage"/>]+;
				[<memberdata name="lrepeatwhenfree" type="Property" display="lRepeatWhenFree"/>]+;
				[<memberdata name="cwatermarkimage" type="Property" display="cWatermarkImage"/>]+;
				[<memberdata name="nwatermarktype" type="Property" display="nWatermarkType"/>]+;
				[<memberdata name="nwatermarktransparency" type="Property" display="nWatermarkTransparency"/>]+;
				[<memberdata name="nwatermarkwidthratio" type="Property" display="nWatermarkWidthRatio"/>]+;
				[<memberdata name="nwatermarkheightratio" type="Property" display="nWatermarkHeightRatio"/>]

			m.loSettings._MemberData = m.loSettings._MemberData + ;
				[<memberdata name="cimgprint" type="Property" display="cImgPrint"/>]+;
				[<memberdata name="cimgprintpref" type="Property" display="cImgPrintPref"/>]+;
				[<memberdata name="cimgsave" type="Property" display="cImgSave"/>]+;
				[<memberdata name="cimgclose" type="Property" display="cImgClose"/>]+;
				[<memberdata name="cimgclose2" type="Property" display="cImgClose2"/>]+;
				[<memberdata name="cimgemail" type="Property" display="cImgEmail"/>]+;
				[<memberdata name="cimgsetup" type="Property" display="cImgSetup"/>]+;
				[<memberdata name="cimgminiatures" type="Property" display="cImgMiniatures"/>]+;
				[<memberdata name="cimgsearch" type="Property" display="cImgSearch"/>]+;
				[<memberdata name="cimgsearchagain" type="Property" display="cImgSearchAgain"/>]+;
				[<memberdata name="cimgsearchback" type="Property" display="cImgSearchBack"/>]+;
				[<memberdata name="cimgprintbig" type="Property" display="cImgPrintBig"/>]+;
				[<memberdata name="cimgprintprefbig" type="Property" display="cImgPrintPrefBig"/>]+;
				[<memberdata name="cimgsavebig" type="Property" display="cImgSaveBig"/>]+;
				[<memberdata name="cimgclosebig" type="Property" display="cImgCloseBig"/>]+;
				[<memberdata name="cimgclose2big" type="Property" display="cImgClose2Big"/>]+;
				[<memberdata name="cimgemailbig" type="Property" display="cImgEmailBig"/>]+;
				[<memberdata name="cimgsetupbig" type="Property" display="cImgSetupBig"/>]+;
				[<memberdata name="cimgminiaturesbig" type="Property" display="cImgMiniaturesBig"/>]+;
				[<memberdata name="cimgsearchbig" type="Property" display="cImgSearchBig"/>]+;
				[<memberdata name="cimgsearchagainbig" type="Property" display="cImgSearchAgainBig"/>]+;
				[<memberdata name="cimgsearchbackbig" type="Property" display="cImgSearchBackBig"/>]+;
				[<memberdata name="lpdfembedfonts" type="Property" display="lPDFEmbedFonts"/>]+;
				[<memberdata name="lpdfcanprint" type="Property" display="lPDFCanPrint"/>]+;
				[<memberdata name="lpdfcanedit" type="Property" display="lPDFCanEdit"/>]+;
				[<memberdata name="lpdfcancopy" type="Property" display="lPDFCanCopy"/>]+;
				[<memberdata name="lpdfcanaddnotes" type="Property" display="lPDFCanAddNotes"/>]+;
				[<memberdata name="lpdfencryptdocument" type="Property" display="lPDFEncryptDocument"/>]+;
				[<memberdata name="lpdfasimage" type="Property" display="lPDFAsImage"/>]+;
				[<memberdata name="cpdfmasterpassword" type="Property" display="cPDFMasterPassword"/>]+;
				[<memberdata name="cpdfuserpassword" type="Property" display="cPDFUserPassword"/>]+;
				[<memberdata name="cpdfauthor" type="Property" display="cPDFAuthor"/>]+;
				[<memberdata name="cpdftitle" type="Property" display="cPDFTitle"/>]+;
				[<memberdata name="cpdfsubject" type="Property" display="cPDFSubject"/>]+;
				[<memberdata name="cpdfkeywords" type="Property" display="cPDFKeywords"/>]+;
				[<memberdata name="cpdfcreator" type="Property" display="cPDFCreator"/>]+;
				[<memberdata name="lpdfshowerrors" type="Property" display="lPDFShowErrors"/>]+;
				[<memberdata name="npdflineheightratio" type="Property" display="nPDFLineHeightRatio"/>]+;
				[<memberdata name="lpdfreplacefonts" type="Property" display="lPDFReplaceFonts"/>]+;
				[<memberdata name="cpdfsymbolfontslist"  type="Property" display="cPDFSymbolFontsList"/>]+;
				[<memberdata name="cpdfdefaultfont" type="Property" display="cPDFDefaultFont"/>]+;
				[<memberdata name="npdfpagemode" type="Property" display="nPDFPageMode"/>]+;
				[<memberdata name="osettingsdlg" type="Property" display="oSettingsDlg"/>]+;
				[<memberdata name="lexpandfields" type="Property" display="lExpandFields"/>]+;
				[<memberdata name="cprintjobname" type="Property" display="cPrintJobName"/>]+;
				[<memberdata name="ncopies" type="Property" display="nCopies"/>]+;
				[<memberdata name="lshowcopies" type="Property" display="lShowCopies"/>]+;
		 		[<memberdata name="lreadreceipt" type="Property" display="lReadReceipt"/>]+;
		 		[<memberdata name="lpriority" type="Property" display="lPriority"/>]+;
		 		[<memberdata name="cexceldefaultextension" type="Property" display="cExcelDefaultExtension"/>]+;
		 		[<memberdata name="lexcelconverttoxls" type="Property" display="lExcelConvertToXLS"/>]+;
		 		[<memberdata name="lexcelrepeatheaders" type="Property" display="lExcelRepeatHeaders"/>]+;
		 		[<memberdata name="lexcelrepeatfooters" type="Property" display="lExcelRepeatFooters"/>]+;
		 		[<memberdata name="lexcelhidepageno" type="Property" display="lExcelHidePageNo"/>]+;
		 		[<memberdata name="lexcelalignleft" type="Property" display="lExcelAlignLeft"/>]+;
		 		[<memberdata name="nexcelsaveformat" type="Property" display="nExcelSaveFormat"/>]+;
				[</VFPData>]
		ENDIF


		ADDPROPERTY(m.loSettings, "lHalfHeightReport"     , .F.)
		
		* Properties for internal use only
		ADDPROPERTY(m.loSettings, "_InitStatusText"       , m.loHelper.GetLoc("INITSTATUS") + SPACE(1) )
		ADDPROPERTY(m.loSettings, "_PrepassStatusText"    , m.loHelper.GetLoc("PREPSTATUS") + SPACE(1) )
		ADDPROPERTY(m.loSettings, "_RunStatusText"        , m.loHelper.GetLoc("RUNSTATUS")  + SPACE(1) )
		ADDPROPERTY(m.loSettings, "_SecondsText"          , m.loHelper.GetLoc("SECONDS")    + SPACE(1) )
		ADDPROPERTY(m.loSettings, "_CancelInstrText"      , m.loHelper.GetLoc("CANCELINST") + SPACE(1) )
		ADDPROPERTY(m.loSettings, "_CancelQueryText"      , m.loHelper.GetLoc("CANCELQUER") )
		ADDPROPERTY(m.loSettings, "_ReportIncompleteText" , m.loHelper.GetLoc("REPINCOMPL") )
		ADDPROPERTY(m.loSettings, "_AttentionText"        , m.loHelper.GetLoc("ATTENTION")  )

		ADDPROPERTY(m.loSettings, "_ErrorSendingMail"     , m.loHelper.GetLoc("ERRSENDMAI") )
		ADDPROPERTY(m.loSettings, "_MsgNotSentText"       , m.loHelper.GetLoc("MSGNOTSENT") )
		ADDPROPERTY(m.loSettings, "_MsgSuccessText"       , m.loHelper.GetLoc("MSGSUCCESS") )
		ADDPROPERTY(m.loSettings, "_SendEmailText"        , m.loHelper.GetLoc("SENDEMAIL")  )
		ADDPROPERTY(m.loSettings, "_AttachNotFoundText"   , m.loHelper.GetLoc("ATACHNOTFO") )
		ADDPROPERTY(m.loSettings, "_SendingText"          , m.loHelper.GetLoc("MSGSENDING") )

		m.loSettings.cCodePage = m.loHelper.GetLoc("CCODEPAGE")

		* These will be responsible for the above translations that will be used in the progressbar
		ADDPROPERTY(m.loSettings, "_oLang"            , "")
		ADDPROPERTY(m.loSettings, "_cLangLoaded"      , "ENGLISH")
		ADDPROPERTY(m.loSettings, "_oDestScreen"      , 0)

		* Special property to allow changing the DataSession, trying to fix a JUMBO bug
		ADDPROPERTY(m.loSettings, "_nDataSessionMode" , 0)
 

		LOCAL loSetDlg
		m.loSetDlg = CREATEOBJECT("Empty")

		ADDPROPERTY(m.loSetDlg, "lEnableLanguage"      , .T.)
		ADDPROPERTY(m.loSetDlg, "lEnableTabGeneral"    , .T.)
		ADDPROPERTY(m.loSetDlg, "lEnableTabControls"   , .T.)
		ADDPROPERTY(m.loSetDlg, "lEnableTabOutput"     , .T.)
		ADDPROPERTY(m.loSetDlg, "lEnableTabEmail"      , .T.)
		ADDPROPERTY(m.loSetDlg, "lEnableTabPDF"        , .T.)
		ADDPROPERTY(m.loSetDlg, "lEnableTabXLS"        , .T.)
		ADDPROPERTY(m.loSetDlg, "lEnableChkPrintPref"  , .T.)
		ADDPROPERTY(m.loSetDlg, "lEnableCmbPrintPrefType" , .T.)
		ADDPROPERTY(m.loSetDlg, "lEnableChkCopies"     , .T.)
		ADDPROPERTY(m.loSetDlg, "lEnableChkSavetoFile" , .T.)
		ADDPROPERTY(m.loSetDlg, "lEnableChkPrinters"   , .T.)
		ADDPROPERTY(m.loSetDlg, "lEnableChkEmail"      , .T.)
		ADDPROPERTY(m.loSetDlg, "lEnableChkMiniatures" , .T.)
		ADDPROPERTY(m.loSetDlg, "lEnableChkSearch"     , .T.)
		ADDPROPERTY(m.loSetDlg, "lEnableChkSettings"   , .T.)
		ADDPROPERTY(m.loSetDlg, "lEnableChkSaveAsImage", .T.)
		ADDPROPERTY(m.loSetDlg, "lEnableChkSaveAsPDF"  , .T.)
		ADDPROPERTY(m.loSetDlg, "lEnableChkSaveAsRTF"  , .T.)
		ADDPROPERTY(m.loSetDlg, "lEnableChkSaveAsHTML" , .T.)
		ADDPROPERTY(m.loSetDlg, "lEnableChkSaveAsMHT"  , .T.)
		ADDPROPERTY(m.loSetDlg, "lEnableChkSaveAsXLS"  , .T.)
		ADDPROPERTY(m.loSetDlg, "lEnableChkSaveAsTXT"  , .T.)
		ADDPROPERTY(m.loSetDlg, "lEnableCmbEmailType"  , .T.)
		ADDPROPERTY(m.loSetDlg, "lEnableCmbAttachmentType"  , .T.)
		ADDPROPERTY(m.loSetDlg, "lEnableChkEmbedFonts" , .T.)
		ADDPROPERTY(m.loSetDlg, "lEnableChkPDFasImage" , .T.)

		* Hiding properties
		ADDPROPERTY(m.loSetDlg, "lShowLanguage"        , .T.)
		ADDPROPERTY(m.loSetDlg, "lShowTabGeneral"      , .T.)
		ADDPROPERTY(m.loSetDlg, "lShowTabControls"     , .T.)
		ADDPROPERTY(m.loSetDlg, "lShowTabOutput"       , .T.)
		ADDPROPERTY(m.loSetDlg, "lShowTabEmail"        , .T.)
		ADDPROPERTY(m.loSetDlg, "lShowTabPDF"          , .T.)
		ADDPROPERTY(m.loSetDlg, "lShowTabXLS"          , .T.)
		ADDPROPERTY(m.loSetDlg, "lShowTabXLS"          , .T.)
		ADDPROPERTY(m.loSettings, "oSettingsDlg"   , m.loSetDlg)

		IF PEMSTATUS(_Screen, "oFoxyPreviewer", 5)
			TRY 
				_Screen.oFoxyPreviewer = NULL
				=REMOVEPROPERTY(_Screen, "oFoxyPreviewer")
			CATCH 
			ENDTRY
		ENDIF
		_Screen.AddProperty("oFoxyPreviewer", NULL)
		_Screen.oFoxyPreviewer = m.loSettings
		_Screen.oFoxyPreviewer.cLANGUAGE = loHelper.cLANGUAGE

		* _REPORTPREVIEW identifies the preview container factory application.
		* This program is called by Visual FoxPro when:
		* • the report engine is assisted by a ReportListener object, and
		* • the ReportListener has a ListenerType of 1, and
		* • the ReportListener does not already have an object reference assigned to its .PreviewContainer property.
		_ReportPreview = m.tcSys16
		SET REPORTBEHAVIOR 90
		SET PATH TO JUSTPATH(m.tcSys16) ADDITIVE

		*!*	* Update the thermometer
		*!*	LOCAL loListenerFactory as FXLISTENER OF ADDBS(HOME()) + "ffc\PR_ReportListener.vcx"
		*!*	loListenerFactory = _oReportOutput("1")
		*!*	loListenerFactory.fxFeedbackClass = loHelper._cThermClass

		IF TYPE([_oReportOutput("1")]) <> "O"
			MESSAGEBOX("Could not load the FOXYPREVIEWER report factory", 16, "Error")
			SET FIXED &lcSetFixed.
			RETURN .F.
		ENDIF

		#DEFINE PRINT_MODE        0
		#DEFINE PREVIEW_MODE      1
		#DEFINE PDF_MODE         10
		#DEFINE PDFASIMAGE_MODE  11
		#DEFINE RTF_MODE         12
		#DEFINE XLS_MODE         13
		#DEFINE HTML_MODE        14
		#DEFINE HTML_MODE2       15
		#DEFINE IMG_MODE         16

		#DEFINE OUTPUTAPP_LOADTYPE_RELOAD_ 2

		* Checking if the new Report factory was loaded
		LOCAL loPrevListener
		m.loPrevListener = EVALUATE([_oReportOutput("1")])
		IF UPPER(m.loPrevListener.Class) <> MAIN_LISTENER

			DO (m.lcReportOutput) WITH ;
				PREVIEW_MODE , m.loListener, OUTPUTAPP_LOADTYPE_RELOAD_
			m.loPrevListener = EVALUATE([_oReportOutput("1")])
			IF UPPER(m.loPrevListener.Class) <> MAIN_LISTENER
				MESSAGEBOX("Could not load the FOXYPREVIEWER report factory (2)" + _CRLF + ;
					"Please check the version of your 'REPORTOUTPUT.APP' file, and make sure to be using the latest version released in VFP9 SP2." + CHR(13) +;
					"Replace your current version with the new one.", 16, "Error")
				SET FIXED &lcSetFixed.
				SET DATASESSION TO (m.lnSession)
				RETURN
			ENDIF
		ENDIF


		* Enabling PDF
		* This is to remove a default listener reference to be replaced
		* Clean up
		IF TYPE([_oReportOutput("10")]) = "O"
			_oReportOutput.Remove("10")
		ENDIF
		LOCAL loPDFListener as "PdfListener" OF "PR_PDFX.vcx"
		IF UPPER(JUSTEXT(m.tcSys16)) = "APP"
			m.loPDFListener = NEWOBJECT("PdfListener", "PR_PDFX.vcx", m.tcSys16)
		ELSE
			m.loPDFListener = NEWOBJECT("PdfListener", ADDBS(JUSTPATH(m.tcSys16)) + "PR_PDFX.vcx")
		ENDIF
		
		IF VARTYPE(m.loPDFListener) = "O"
			m.loPDFListener.lObjTypeMode = .T.
			DO (m.lcReportOutput) WITH ;
				PDF_MODE , m.loPDFListener, OUTPUTAPP_LOADTYPE_RELOAD_
		ENDIF

		* Enabling PDF "As Image"
		* This is to remove a default listener reference to be replaced
		* Clean up
		IF TYPE([_oReportOutput("11")]) = "O"
			_oReportOutput.Remove("11")
		ENDIF
		LOCAL loPDFListener2 as "PdfasImageListener" OF "PR_PDFX.vcx"
		IF UPPER(JUSTEXT(m.tcSys16)) = "APP"
			m.loPDFListener2 = NEWOBJECT("PdfasImageListener", "PR_PDFX.vcx", m.tcSys16)
		ELSE
			m.loPDFListener2 = NEWOBJECT("PdfasImageListener", ADDBS(JUSTPATH(m.tcSys16)) + "PR_PDFX.vcx")
		ENDIF
		
		IF VARTYPE(m.loPDFListener2) = "O"		
			m.loPDFListener2.lObjTypeMode = .T.
			m.loPDFListener2.ListenerType = 3

			DO (m.lcReportOutput) WITH ;
				PDFASIMAGE_MODE , m.loPDFListener2, OUTPUTAPP_LOADTYPE_RELOAD_
		ENDIF
		

		* Enabling RTF
		* This is to remove a default listener reference to be replaced
		* Clean up
		IF TYPE([_oReportOutput("12")]) = "O"
			_oReportOutput.Remove("12")
		ENDIF
		LOCAL loRTFListener as "PdfasImageListener" OF "PR_PDFX.vcx"
		IF UPPER(JUSTEXT(m.tcSys16)) = "APP"
			m.loRTFListener = NEWOBJECT("RTFreportlistener", "PR_RTFListener", m.tcSys16)
		ELSE
			m.loRTFListener = NEWOBJECT("RTFreportlistener", ADDBS(JUSTPATH(m.tcSys16)) + "PR_RTFListener")
		ENDIF
		
		IF VARTYPE(m.loRTFListener) = "O"
			m.loRTFListener.lObjTypeMode = .T.
			*	loRTFListener.ListenerType = 3

			DO (m.lcReportOutput) WITH ;
				RTF_MODE , m.loRTFListener, OUTPUTAPP_LOADTYPE_RELOAD_
		ENDIF


		* Enabling XLS
		* This is to remove a default listener reference to be replaced
		* Clean up
		IF TYPE([_oReportOutput("13")]) = "O"
			_oReportOutput.Remove("13")
		ENDIF

		LOCAL loXLSListener AS ReportListener
		IF UPPER(JUSTEXT(m.tcSys16)) = "APP"
			m.loXLSListener = NEWOBJECT("ExcelListener","pr_ExcelListener.vcx", m.tcSys16)
		ELSE
			m.loXLSListener = NEWOBJECT("ExcelListener",ADDBS(JUSTPATH(m.tcSys16)) + "pr_ExcelListener.vcx")
		ENDIF

		IF VARTYPE(m.loXLSListener) = "O"
			m.loXLSListener.lObjTypeMode = .T.
			m.loXLSListener.ListenerType = 3
			m.loXLSListener.lOutputToCursor = .T.
			m.loXLSListener.cWorksheetName = "Sheet"
			m.loXLSListener.cCodePage = m.loHelper.cCodePage

			m.loXLSListener.lConvertToXLS  = m.loHelper.lExcelConvertToXLS  
			m.loXLSListener.lRepeatHeaders = m.loHelper.lExcelRepeatHeaders
			m.loXLSListener.lRepeatFooters = m.loHelper.lExcelRepeatFooters
			m.loXLSListener.lHidePageNo    = m.loHelper.lExcelHidePageNo
			m.loXLSListener.lAlignLeft     = m.loHelper.lExcelAlignLeft

			DO (m.lcReportOutput) WITH ;
				XLS_MODE , m.loXLSListener, OUTPUTAPP_LOADTYPE_RELOAD_
		ENDIF


		* Enabling HTML
		* This is to remove a default listener reference to be replaced
		* Clean up
		IF TYPE([_oReportOutput("14")]) = "O"
			_oReportOutput.Remove("14")
		ENDIF

		* Check if the MSXML4 component is installed 
		* so that we can initialize the HTML Listener
		LOCAL llXLSError, loTestXML4
		m.llXLSError = .F.
		TRY 
			m.loTestXML4  = CREATEOBJECT("MSXML2.XSLTEMPLATE.4.0")
		CATCH
			m.llXLSError = .T.
		ENDTRY 
		m.loTestXML4 = NULL

		IF NOT llXLSError
			LOCAL loHTMLListener AS ReportListener
			IF UPPER(JUSTEXT(m.tcSys16)) = "APP"
				m.loHTMLListener = NEWOBJECT("pr_HTMLListener","pr_reportlistener.vcx", m.tcSys16)
			ELSE
				m.loHTMLListener = NEWOBJECT("pr_HTMLListener",ADDBS(JUSTPATH(m.tcSys16)) + "pr_ReportListener.vcx")
			ENDIF
		
			IF VARTYPE(m.loHTMLListener) = "O"
				m.loHTMLListener.lObjTypeMode = .T.
				m.loHTMLListener.ListenerType = 3
				m.loHTMLListener.CopyImageFilesToExternalFileLocation = .T.
				DO (m.lcReportOutput) WITH ;
					HTML_MODE , m.loHTMLListener, OUTPUTAPP_LOADTYPE_RELOAD_
			ENDIF
		ENDIF



		* Enabling HTML SIMPLIFIED
		* This is to remove a default listener reference to be replaced
		* Clean up
		IF TYPE([_oReportOutput("15")]) = "O"
			_oReportOutput.Remove("15")
		ENDIF

		LOCAL loHTMLListener AS ReportListener
		IF UPPER(JUSTEXT(m.tcSys16)) = "APP"
			m.loHTMLListener = NEWOBJECT("pr_HTMLListener15","pr_reportlistener.vcx", m.tcSys16)
		ELSE
			m.loHTMLListener = NEWOBJECT("pr_HTMLListener15",ADDBS(JUSTPATH(m.tcSys16)) + "pr_ReportListener.vcx")
		ENDIF

		IF VARTYPE(m.loHTMLListener) = "O"
			m.loHTMLListener.lObjTypeMode = .T.
			m.loHTMLListener.ListenerType = 3
			DO (m.lcReportOutput) WITH ;
				HTML_MODE2 , m.loHTMLListener, OUTPUTAPP_LOADTYPE_RELOAD_
		ENDIF


		* Enabling IMAGE FILE
		* This is to remove a default listener reference to be replaced
		* Clean up
		IF TYPE([_oReportOutput("16")]) = "O"
			_oReportOutput.Remove("16")
		ENDIF

		LOCAL loImageListener AS FXLISTENER OF "PR_ReportListener.vcx"
		IF UPPER(JUSTEXT(m.tcSys16)) = "APP"
			m.loImageListener = NEWOBJECT(MAIN_LISTENER, "PR_ReportListener.vcx", m.tcSys16)
		ELSE
			m.loImageListener = NEWOBJECT(MAIN_LISTENER, ADDBS(JUSTPATH(m.tcSys16)) + "PR_ReportListener.vcx")
		ENDIF

		TRY
			m.loImageListener.fxFeedbackClass = m.loHelper._cThermClass
			m.loImageListener.QuietMode = m.loHelper.lQuietMode
		CATCH
		ENDTRY

		IF VARTYPE(m.loImageListener) = "O"		
			m.loImageListener.ListenerType = 3
			m.loImageListener.lObjTypeMode = .T.
			DO (m.lcReportOutput) WITH ;
				IMG_MODE , m.loImageListener, OUTPUTAPP_LOADTYPE_RELOAD_
		ENDIF



		* Enabling direct printing using the REPORT FORM ... TO PRINTER command
		* This is to remove a default listener reference to be replaced
		* Clean up
		IF TYPE([_oReportOutput("0")]) = "O"
			_oReportOutput.Remove("0")
		ENDIF
		LOCAL loPrintListener AS FXLISTENER OF "PR_ReportListener.vcx"
		IF UPPER(JUSTEXT(m.tcSys16)) = "APP"
			m.loPrintListener = NEWOBJECT(MAIN_LISTENER, "PR_ReportListener.vcx", m.tcSys16)
		ELSE
			m.loPrintListener = NEWOBJECT(MAIN_LISTENER, ADDBS(JUSTPATH(m.tcSys16)) + "PR_ReportListener.vcx")
		ENDIF

		TRY
			m.loPrintListener.fxFeedbackClass = m.loHelper._cThermClass
			m.loPrintListener.QuietMode = m.loHelper.lQuietMode
		CATCH
		ENDTRY

		IF VARTYPE(m.loPrintListener) = "O"		
			m.loPrintListener.ListenerType = 0
			DO (m.lcReportOutput) WITH ;
				PRINT_MODE , m.loPrintListener, OUTPUTAPP_LOADTYPE_RELOAD_
		ENDIF



		* Enabling PDF Offline
		* The report will be executed without preview, and later the PDF will be created
		*    using the info stored in the internal tables
		IF TYPE([_oReportOutput("20")]) = "O"
			_oReportOutput.Remove("20")
		ENDIF

		LOCAL loOutputListener AS FXLISTENER OF "PR_ReportListener.vcx"
		IF UPPER(JUSTEXT(m.tcSys16)) = "APP"
			m.loOutputListener = NEWOBJECT(MAIN_LISTENER, "PR_ReportListener.vcx", m.tcSys16)
		ELSE
			m.loOutputListener = NEWOBJECT(MAIN_LISTENER, ADDBS(JUSTPATH(m.tcSys16)) + "PR_ReportListener.vcx")
		ENDIF

		TRY
			m.loOutputListener.fxFeedbackClass = m.loHelper._cThermClass
			m.loOutputListener.QuietMode = m.loHelper.lQuietMode
		CATCH
		ENDTRY

		IF VARTYPE(m.loOutputListener) = "O"		
			m.loOutputListener.ListenerType = 3
			m.loOutputListener.lObjTypeMode = .T.
			DO (m.lcReportOutput) WITH ;
				20, m.loOutputListener, OUTPUTAPP_LOADTYPE_RELOAD_
		ENDIF
		m.loHelper = NULL

		SET DATASESSION TO (m.lnSession)
		RETURN .F.
	ENDPROC

	PROCEDURE Destroy
		IF ISDEBUGGING
			SET STEP ON
		ENDIF
	ENDPROC
ENDDEFINE && FoxyInitForm


PROCEDURE ClearSetProc
	LOCAL lcProc, n, lnProcs, lcCurProc
	STORE "" TO m.lcCurProc
	m.lcProc  = UPPER(SET("PROCEDURE"))
	m.lnProcs = GETWORDCOUNT(m.lcProc, ",")

	FOR m.n = 1 TO m.lnProcs
		m.lcCurProc = GETWORDNUM(m.lcProc, m.n, ",")
		IF "FOXYPREVIEWER." $ m.lcCurProc
			RELEASE PROCEDURE (m.lcCurProc)
			LOOP
		ENDIF
	ENDFOR
ENDPROC


PROCEDURE ClearSetClassLib
	=INKEY(.1)
	TRY 
		IF "PR_REPORTLISTENER" $ UPPER(SET("Classlib"))
			RELEASE CLASSLIB PR_REPORTLISTENER
		ENDIF
	CATCH 
	ENDTRY
	TRY 
		IF "_GDIPLUS" $ UPPER(SET("Classlib"))
			RELEASE CLASSLIB _GDIPLUS
		ENDIF
	CATCH 
	ENDTRY
ENDPROC




PROCEDURE ToMHTML
	LPARAMETERS tcSource, tcDestination
	* http://www.delphi3000.com/articles/article_4373.asp?SK=
	* http://www.atoutfox.org/articles.asp?ACTION=FCONSULTER&ID=0000000041

	LOCAL lcFileName,loStream, loMsg as "CDO.Message" && Variables locales
	
	IF EMPTY(tcDestination)
		lcFileName = FORCEEXT(tcSource, 'mht') && Nom du document final
	ELSE 
		lcFileName = tcDestination
	ENDIF 

	IF FILE(tcSource)
		tcSource = "file://" + tcSource
	ELSE 
		MESSAGEBOX("Source file does not exist!", "Error")
		RETURN
	ENDIF 

	LOCAL loConfig
    loConfig = CREATEOBJECT("CDO.Configuration")
	loMSG = CREATEOBJECT("CDO.Message")
	loMsg.Configuration = loConfig
	loMSG.CreateMHTMLBody(tcSource)
	loMsg.GetStream.SaveToFile(lcFileName, 2)
		&& The SaveToFile method of the ADO stream takes as its second 
		&& parameter either 1, which will create if the file doesn't exist and 
		&& will fail if it does; or 2, which will overwrite if it exists and create otherwise.
	loMsg    = NULL
	loConfig = NULL
	RELEASE loMsg, loConfig
ENDPROC



* REPORTOUTPUT WRAPPER PRG
* SP2 VERSION
* By Lisa Slater Nicholls
PROCEDURE PR_FRXOUTPUT

#INCLUDE REPORTOUTPUT.H

LPARAMETERS m.tvType, m.tvReference, m.tvUnload

EXTERNAL TABLE OUTPUTAPP_INTERNALDBF 

LOCAL m.oTemp, m.iType, m.iIndex, m.cType, m.cConfigTable, ;
   m.lSuccess, m.lSetTalkBackOn, m.lSafety, m.cFilter, m.cClass, m.cLib, m.cModule, ;
   m.oConfig, m.oError, m.lStringVar, m.lObjectMember, m.iParams, ;
   m.iUnload, m.iSelect, m.iSession, m.lSetTalkBackOnDefaultSession, m.vReturn, ;
   m.oSH
   
IF (SET("TALK") = "ON")
   SET TALK OFF
   m.lSetTalkBackOn = .T.
ENDIF

m.iParams = PARAMETERS()
m.iSession = SET("DATASESSION")

m.oSH = CREATEOBJECT("SH")

m.oSH.Execute(VFP_DEFAULT_DATASESSION)

m.iSelect = SELECT()

IF (SET("TALK") = "ON")
   SET TALK OFF
   m.lSetTalkBackOnDefaultSession = .T.
ENDIF


* if it is not integer, convert
* if it is lower than -1, 
* this is a value private to REPORTOUTPUT.APP, 
* potentially not even a ListenerType
* if it is not numeric, just set up the
* reference collection

DO CASE
CASE VARTYPE(m.tvType) # "N"
   m.vReturn = ReportOutputConfig(OUTPUTAPP_CONFIGTOKEN_SETTABLE, .F., .F., m.oSH)
   DO ReportOutputCleanup WITH ;
       m.iSelect, m.lSetTalkBackOnDefaultSession, ;
       m.iSession, m.lSetTalkBackOn, m.oSH
   RETURN m.vReturn
CASE ABS(m.tvType) # m.tvType AND m.tvType < LISTENER_TYPE_DEF 
   m.vReturn = ReportOutputConfig(m.tvType, @m.tvReference, m.tvUnload, m.oSH)
   DO ReportOutputCleanup WITH ;
       m.iSelect, m.lSetTalkBackOnDefaultSession, ;
       m.iSession, m.lSetTalkBackOn, m.oSH
   RETURN m.vReturn
OTHERWISE
  m.iType = INT(m.tvType)
ENDCASE

IF m.iParams = 3  
   m.iUnload = VAL(TRANSFORM(m.tvUnload))   
   IF VARTYPE(m.tvUnload) = "L" AND m.tvUnload
      m.vReturn = UnloadListener(m.iType)
      DO ReportOutputCleanup WITH ;
         m.iSelect, m.lSetTalkBackOnDefaultSession, ;
         m.iSession, m.lSetTalkBackOn, m.oSH
      RETURN m.vReturn
   ELSE 
      IF m.iUnload > 0 
         IF m.iUnload = OUTPUTAPP_LOADTYPE_UNLOAD
            m.vReturn = UnloadListener(m.iType)
            DO ReportOutputCleanup WITH ;
               m.iSelect, m.lSetTalkBackOnDefaultSession, ;
               m.iSession, m.lSetTalkBackOn, m.oSH
            RETURN m.vReturn
         ELSE
            DO UnloadListener WITH m.iType
         ENDIF
      ENDIF
   ENDIF
ENDIF

DO ReportOutputDeclareReference  WITH ;
   m.iParams, m.tvReference, m.lObjectMember, m.lStringVar


IF m.iType = LISTENER_TYPE_DEF
   * always provide the reference fresh,
   * do not use the collection
   m.oTemp = CREATEOBJECT("ReportListener")

ELSE

   * check for public reference var (collection)
   * if it is not available create
   m.cType = TRANSFORM(m.iType)
   m.iIndex = -1
  
   DO CheckPublicListenerCollection WITH m.cType, m.iIndex
   
   IF m.iIndex > -1
      m.oTemp = OUTPUTAPP_REFVAR.ITEM[m.iIndex]
   ELSE
      * if they've passed in an existing object and 
      * it's not in the collection yet, add
      * (SP1 change)
      IF TestListenerReference(m.tvReference)
         OUTPUTAPP_REFVAR.ADD(m.tvReference,m.cType)         
         * synch this up, JIC:
         DO CheckPublicListenerCollection WITH m.cType, m.iIndex
         IF m.iIndex > -1
            m.oTemp = m.tvReference
         ENDIF   
      ENDIF      
   ENDIF

   IF NOT TestListenerReference(m.oTemp)

      * if it is not available,
      * look for config file, choosing between built-in and
      * on-disk

      m.oError = NULL
      STORE "" TO m.cClass, m.cLib, m.cModule

      * try to open, error handle for
      * unavailability
      
      DO GetConfigObject WITH m.oConfig
      
      TRY
         SELECT 0
         
         m.iIndex = -1
         DO CheckPublicListenerCollection WITH ;
           TRANSFORM(OUTPUTAPP_CONFIGTOKEN_SETTABLE), m.iIndex
         
         IF m.iIndex > -1
            m.cConfigTable = OUTPUTAPP_REFVAR.ITEM[m.iIndex]
         ELSE
            m.cConfigTable = m.oConfig.GetConfigTable()
            * the collection will have been created by 
            * CheckPublicListenerCollection
            OUTPUTAPP_REFVAR.ADD(m.cConfigTable,TRANSFORM(OUTPUTAPP_CONFIGTOKEN_SETTABLE))                      
         ENDIF

         USE (m.cConfigTable ) ALIAS OutputConfig SHARED 

         IF m.oConfig.VerifyConfigTable("OutputConfig")

            * look for filter records first:

            * OBJTYPE   110   identifies a configuration record
            * OBJCODE   1    Configuration item type. 1= registry filter
            * OBJNAME   not used
            * OBJVALUE   not used
            * OBJINFO   Filter expression
             
            SELECT OutputConfig  
            SET ORDER TO 0
            LOCATE && GO TOP
            LOCATE FOR ObjType = OUTPUTAPP_OBJTYPE_CONFIG AND ;
                       ObjCode = OUTPUTAPP_OBJCODE_FILTER AND ;
                       NOT (EMPTY(ObjInfo) OR DELETED())
            IF FOUND()
               m.cFilter = " AND (" + ALLTR(ObjInfo) + ")"
            ELSE
               m.cFilter = ""   
            ENDIF

            * check for type record for the passed type and 
            * not deleted and in the filter

            * OBJTYPE   100   identifies a Listener registry record
            * OBJCODE   Listener Type   values -1, 0, 1, and 2 supported by default
            * OBJNAME   Class to instantiate   may be ReportListener (base class)
            * OBJVALUE   Class library or procedure file   may be blank
            * OBJINFO   Module/Application containing library   may be blank

            LOCATE && GO TOP

            LOCATE FOR ObjType = OUTPUTAPP_OBJTYPE_LISTENER AND ;
                                 (ObjCode = m.iType)  ;
                                 &cFilter. AND (NOT DELETED())
            IF FOUND()
               * get values
               m.cClass = ALLTRIM(ObjName)
               m.cLib = ALLTRIM(ObjValue)
               m.cModule = ALLTR(ObjInfo)

            ELSE

               DO GetSupportedListenerInfo WITH ;
                  m.iType, m.cClass, m.cLib, m.cModule
            ENDIF                                 
            
         ELSE   
         
            IF ISNULL(m.oError) && should be
               m.oError = CREATEOBJECT("Exception")
               m.oError.Message = OUTPUTAPP_CONFIGTABLEWRONG_LOC 
            ENDIF   
            
            IF OUTPUTAPP_DEFAULTCONFIG_AFTER_CONFIGTABLEFAILURE
               DO GetSupportedListenerInfo WITH ;
                  m.iType, m.cClass, m.cLib, m.cModule         
            ENDIF

         ENDIF

         IF USED("OutputConfig")
            USE IN OutputConfig  
         ENDIF   

         IF NOT EMPTY(m.cClass)
            IF NOT INLIST(UPPER(JUSTEXT(m.cModule)),"APP","EXE", "DLL")
               * frxoutput can be built into the current app or exe
               m.cModule = ""
            ENDIF
            m.oTemp = NEWOBJECT(m.cClass, m.cLib, m.cModule)
         ENDIF
         
        
      CATCH TO m.oError
         EXIT  
      FINALLY
         * m.oSH.Execute(m.iSession)
         * SET DATASESSION TO (m.iSession)
      ENDTRY
      
      IF NOT ISNULL(m.oError)
         DO ReportOutputCleanup WITH ;
          m.iSelect, m.lSetTalkBackOnDefaultSession, ;
          m.iSession, m.lSetTalkBackOn, m.oSH
         HandleError(m.oError)
      ELSE   
       
         IF TestListenerReference(m.oTemp) AND ;
            PEMSTATUS(m.oTemp,"ListenerType",5)
            * see notes below, we don't
            * prevent the assignment if not
            * a listener but we do not want it
            * in the collection nonetheless

            #IF OUTPUTAPP_ASSIGN_TYPE 
             IF UPPER(m.oTemp.BaseClass) == UPPER(m.oTemp.Class)
                m.oTemp.ListenerType = m.iType
             ENDIF   
            #ENDIF   
            OUTPUTAPP_REFVAR.ADD(m.oTemp,m.cType)
         ENDIF   

      ENDIF   

      STORE NULL TO m.oConfig, m.oError

   ENDIF

ENDIF


m.lSuccess = TestListenerReference(m.oTemp)

   * we don't test for listener baseclass --
   * they could hide the property --
   * also we get a more consistent
   * error message letting the product
   * handle things if the object does
   * not descend from ReportListener
   * however, we have to assign type as needed,
   * and that will require a test.


IF m.lSuccess

   #IF OUTPUTAPP_ASSIGN_OUTPUTTYPE
       TRY
         m.oTemp.OutputType =m.iType
       CATCH WHEN .T.
         * in case they
         * hid or protected it,
         * or have an assign method that errored
       ENDTRY  
   #ENDIF

   DO CASE
   CASE m.iParams = 1
      * nothing to assign, just store in the collection
   CASE m.lStringVar OR m.lObjectMember
      IF m.lStringVar AND TYPE(m.tvReference) = "U"
         PUBLIC &tvReference.   
      ENDIF   
      STORE m.oTemp TO (m.tvReference)
      #IF OUTPUTAPP_ASSIGN_TYPE 
      IF PEMSTATUS(&tvReference.,"ListenerType",5) AND ;
         UPPER(m.oTemp.BaseClass) == UPPER(m.oTemp.Class)
         &tvReference..ListenerType = m.iType
      ENDIF   
      #ENDIF
   OTHERWISE
      m.tvReference = m.oTemp
      #IF OUTPUTAPP_ASSIGN_TYPE 
      IF PEMSTATUS(m.tvReference,"ListenerType",5) AND ;
         UPPER(m.oTemp.BaseClass) == UPPER(m.oTemp.Class)
         m.tvReference.ListenerType = m.iType
      ENDIF   
      #ENDIF
   ENDCASE
ELSE
   DO CASE
   CASE m.iParams = 1
      * nothing to assign   
   CASE m.lStringVar OR m.lObjectMember
      STORE NULL TO (m.tvReference)
   OTHERWISE
      m.tvReference = NULL
   ENDCASE
ENDIF

DO ReportOutputCleanup WITH ;
      m.iSelect, m.lSetTalkBackOnDefaultSession, ;
      m.iSession, m.lSetTalkBackOn,m.oSH

RETURN m.lSuccess  && not used by the product but might be used by somebody
ENDPROC 

PROC ReportOutputCleanup( ;
   m.tiSelect, m.tlResetTalkDefaultSession, m.tiSession,m.tlResetTalk,m.toSH )
   m.toSH.Execute(VFP_DEFAULT_DATASESSION)  && JIC
   SELECT (m.tiSelect)
   IF m.tlResetTalkDefaultSession
      SET TALK ON
   ENDIF
   toSH.Execute(m.tiSession)
   IF m.tlResetTalk
      SET TALK ON
   ENDIF
   m.toSH = NULL
ENDPROC   

PROC TestListenerReference(m.toRef)

   RETURN (VARTYPE(m.toRef) = "O") && AND ;
     && (UPPER(toRef.BASECLASS) == "REPORTLISTENER")

PROC GetSupportedListenerInfo(m.tiType, m.tcClass, m.tcLib, m.tcModule)
   DO CASE 
   CASE OUTPUTAPP_XBASELISTENERS_FOR_BASETYPES AND ;
        m.tiType = LISTENER_TYPE_PRN
      m.tcClass = OUTPUTAPP_CLASS_PRINTLISTENER
      m.tcLib = OUTPUTAPP_BASELISTENER_CLASSLIB

   CASE OUTPUTAPP_XBASELISTENERS_FOR_BASETYPES AND ;
        m.tiType= LISTENER_TYPE_PRV
      m.tcClass = OUTPUTAPP_CLASS_PREVIEWLISTENER
      m.tcLib = OUTPUTAPP_BASELISTENER_CLASSLIB

   CASE INLIST(m.tiType,LISTENER_TYPE_PRN,;
                      LISTENER_TYPE_PRV, ;
                      LISTENER_TYPE_PAGED, ;
                      LISTENER_TYPE_ALLPGS)
      m.tcClass = "ReportListener"
   CASE m.tiType = LISTENER_TYPE_HTML
      m.tcClass = OUTPUTAPP_CLASS_HTMLLISTENER
      m.tcLib = OUTPUTAPP_BASELISTENER_CLASSLIB
   CASE m.tiType = LISTENER_TYPE_XML
      m.tcClass = OUTPUTAPP_CLASS_XMLLISTENER
      m.tcLib = OUTPUTAPP_BASELISTENER_CLASSLIB
   CASE m.tiType = LISTENER_TYPE_DEBUG
      m.tcClass = OUTPUTAPP_CLASS_DEBUGLISTENER
      m.tcLib = OUTPUTAPP_BASELISTENER_CLASSLIB
   OTHERWISE
      * ERROR here?  
      * No, let product handle it consistently. 
   ENDCASE

ENDPROC

PROC ReportOutputConfig(m.tnType, m.tvReference, m.tvUnload, m.toSH)
    * NB: early quit in case somebody
    * calls the thing improperly, 
    * even from the command line with a SET PROC
    IF VARTYPE(m.tnType) # "N"
       RETURN .F.
    ENDIF
    * can support other things besides writing the
    * table here
    LOCAL m.iSession, oSession, m.oError, m.oConfig, m.cDBF, m.lSuccess, m.cType, m.iIndex
    m.oError = NULL
    m.oConfig = NULL
    m.iSession = SET("DATASESSION")    
    m.lSuccess = .F.
    TRY        
       DO CASE
       CASE m.tnType = OUTPUTAPP_CONFIGTOKEN_SETTABLE AND ;
            VARTYPE(m.tvReference) = "C" AND ;
            FILE(FULLPATH(FORCEEXT(TRANSFORM(m.tvReference),"DBF"))) 
             * use FILE() because it can be in the app                         
       
            m.cDBF = FULLPATH(FORCEEXT(TRANSFORM(m.tvReference),"DBF"))
            m.iIndex = -1
            m.cType = TRANSFORM(OUTPUTAPP_CONFIGTOKEN_SETTABLE)             
            DO CheckPublicListenerCollection WITH m.cType, m.iIndex
            IF m.iIndex # -1
               OUTPUTAPP_REFVAR.REMOVE[m.iIndex]
            ENDIF
            OUTPUTAPP_REFVAR.ADD(m.cDBF,m.cType)          
            m.lSuccess = .T.
      CASE m.tnType = OUTPUTAPP_CONFIGTOKEN_WRITETABLE
            oSession = CREATEOBJECT("session")
            m.lSafety = SET("SAFETY") = "ON"
            m.toSH.Execute(oSession.DataSessionID)
            IF m.lSafety
               SET SAFETY ON
            ENDIF
            DO GetConfigObject WITH m.oConfig, .T.
            * use XML class, not config superclass, 
            * to write both sets of records, base config outline 
            * and base listener's nodenames
            m.cDBF = FORCEEXT(FORCEPATH(OUTPUTAPP_EXTERNALDBF, JUSTPATH(SYS(16,0))),"DBF")
            m.oConfig.CreateConfigTable(m.cDBF)
            IF NOT EMPTY(SYS(2000,m.cDBF))
               m.iIndex = -1
               m.cType = TRANSFORM(OUTPUTAPP_CONFIGTOKEN_SETTABLE)             
               DO CheckPublicListenerCollection WITH m.cType, m.iIndex               
               IF m.iIndex # -1
                  OUTPUTAPP_REFVAR.REMOVE[m.iIndex]
               ENDIF
               OUTPUTAPP_REFVAR.ADD(m.cDBF,m.cType)          
               USE (m.cDBF) 
               LOCATE FOR ObjType = OUTPUTAPP_OBJTYPE_LISTENER AND ;
                          ObjCode = LISTENER_TYPE_DEBUG AND ;
                          UPPER(ALLTRIM(ObjName)) == 'DEBUGLISTENER' AND ;
                          ObjValue = OUTPUTAPP_BASELISTENER_CLASSLIB AND ;
                          DELETED()
               IF EOF()           
                  INSERT INTO (ALIAS()) VALUES ;
                  (OUTPUTAPP_OBJTYPE_LISTENER ,LISTENER_TYPE_DEBUG,'DebugListener',OUTPUTAPP_BASELISTENER_CLASSLIB,SYS(16,0))
                  DELETE NEXT 1
               ENDIF   
*!*	            SELECT  ObjType, ObjCode, ObjName, ObjValue , ;
*!*	                    LEFT(ObjInfo,30) AS Info FROM (m.cDBF) ;
*!*	                    INTO CURSOR STRTRAN(OUTPUTAPP_CONFIGTABLEBROWSE_LOC," ","")
*!*	            SELECT (STRTRAN(OUTPUTAPP_CONFIGTABLEBROWSE_LOC," ",""))
*!*	            BROWSE TITLE OUTPUTAPP_CONFIGTABLEBROWSE_LOC  FIELDS ;
*!*	              ObjType, ObjCode, ObjName, ObjValue , Info = LEFT(ObjInfo,30), ObjInfo
               BROWSE TITLE OUTPUTAPP_CONFIGTABLEBROWSE_LOC  
               USE
               m.lSuccess = .T.
            ELSE
               m.lSuccess = .F.
            ENDIF   
       OTHERWISE 
            m.iIndex = -1
            m.cType = TRANSFORM(OUTPUTAPP_CONFIGTOKEN_SETTABLE)             
            DO CheckPublicListenerCollection WITH m.cType, m.iIndex
            IF m.iIndex = -1
               * don't disturb it if it's there
               DO GetConfigObject WITH m.oConfig
               m.cDBF = m.oConfig.GetConfigTable()
               OUTPUTAPP_REFVAR.ADD(m.cDBF,m.cType)                       
               m.tvReference = m.cDBF
            ELSE
               m.tvReference= OUTPUTAPP_REFVAR.ITEM[m.iIndex]   
            ENDIF
            m.lSuccess = .T.
       ENDCASE
    CATCH WHEN WTITLE() =  OUTPUTAPP_CONFIGTABLEBROWSE_LOC 
       * MESSAGEBOX("here")
       * error 57 on the browse -- no table open ad nauseum
    CATCH TO m.oError
       m.lSuccess = .F.
    FINALLY
       m.toSH.Execute(m.iSession)
    ENDTRY           
    
    IF NOT ISNULL(m.oError)
       HandleError(m.oError)
    ENDIF
    
    RETURN m.lSuccess   

ENDPROC

PROCEDURE GetConfigObject(m.toCfg, m.tXML)
   LOCAL m.lcModule
   m.lcModule = _REPORTOUTPUT
   IF NOT INLIST(UPPER(JUSTEXT(m.lcModule)),"EXE","APP","DLL")
      m.lcModule = SYS(16,0)
   ENDIF
   IF NOT INLIST(UPPER(JUSTEXT(m.lcModule)), "EXE","APP","DLL")
      m.lcModule = ""
   ENDIF
   IF m.tXML
      m.toCfg = NEWOBJECT(OUTPUTAPP_CLASS_XMLLISTENER,OUTPUTAPP_BASELISTENER_CLASSLIB, m.lcModule)         
   ELSE
      m.toCfg = NEWOBJECT(OUTPUTAPP_CLASS_UTILITYLISTENER,OUTPUTAPP_BASELISTENER_CLASSLIB, m.lcModule)   
   ENDIF            
   IF VARTYPE(toCfg) = "O"
      m.toCfg.QuietMode = .T.
      m.toCfg.AppName = OUTPUTAPP_APPNAME_LOC 
   ENDIF
ENDPROC

PROCEDURE ReportOutputDeclareReference( ;
   m.tiParams, m.tvReference, m.tlObjectMember, m.tlStringVar)
   LOCAL m.iDotPos
   IF m.tiParams > 1 AND ;
      TYPE("m.tvReference") = "C" 
      m.iDotPos = RAT(".",m.tvReference)
      IF m.iDotPos > 1 AND ;
         m.iDotPos < LEN(m.tvReference)
         IF TYPE(m.tvReference) = "U"
           IF TYPE(LEFT(m.tvReference,m.iDotPos-1)) = "O"
              AddProperty(EVAL(LEFT(m.tvReference,m.iDotPos-1)),SUBSTR(m.tvReference,m.iDotPos+1))
              m.tlObjectMember = .T.
           ENDIF
         ELSE
           m.tlObjectMember = .T.      
         ENDIF
      ELSE
         m.tlStringVar = .T.
      ENDIF    
   ENDIF   
ENDPROC

PROCEDURE UnloadListener(m.tiType)
   LOCAL m.lUnload, m.cType
   
   IF VARTYPE(OUTPUTAPP_REFVAR) # "O" OR ;
      NOT (UPPER(OUTPUTAPP_REFVAR.CLASS) == ;
      UPPER(OUTPUTAPP_REFVARCLASS))
      * nothing to do

   ELSE
      m.cType = TRANSFORM(m.tiType)
      * look for reference to a listener of the appropriate type
      FOR m.iIndex = 1 TO OUTPUTAPP_REFVAR.COUNT 
         IF OUTPUTAPP_REFVAR.GETKEY(m.iIndex) == m.cType
            OUTPUTAPP_REFVAR.Remove(m.iIndex)
            m.lUnload = .T.
            EXIT
         ENDIF
      NEXT

   ENDIF
  
   RETURN m.lUnload
ENDPROC

PROCEDURE HandleError(m.toE)
  DO CASE
  CASE NOT ISNULL(m.toE) 
     IF EMPTY(toE.ErrorNo)
        ERROR toE.Message
     ELSE
        ERROR toE.ErrorNo, toE.Details
     ENDIF
  CASE NOT EMPTY(MESSAGE())
     ERROR MESSAGE()
  OTHERWISE
     ERROR OUTPUTAPP_UNKNOWN_ERROR_LOC
  ENDCASE   
ENDPROC


PROCEDURE CheckPublicListenerCollection(m.tcType, m.tiIndex)

    LOCAL m.iIndex

   IF VARTYPE(OUTPUTAPP_REFVAR) # "O" OR ;
         NOT (UPPER(OUTPUTAPP_REFVAR.CLASS) == ;
              UPPER(OUTPUTAPP_REFVARCLASS))
      * could be a collection subclass
      * in which case look for
      * AINSTANCE(aTemp, <classname>)

      PUBLIC OUTPUTAPP_REFVAR
      STORE CREATEOBJECT(OUTPUTAPP_REFVARCLASS) TO ([OUTPUTAPP_REFVAR])

   ENDIF
   
   IF NOT EMPTY(m.tcType)

       FOR m.iIndex = 1 TO OUTPUTAPP_REFVAR.COUNT
           IF OUTPUTAPP_REFVAR.GETKEY(m.iIndex) == m.tcType
              m.tiIndex = m.iIndex
              EXIT
            ENDIF
       NEXT
       
    ENDIF   

ENDPROC

DEFINE CLASS SH AS Custom
   PROCEDURE Execute(m.tiSession)
      SET DATASESSION TO (m.tiSession)
   ENDPROC
ENDDEFINE
* End of ReportOutput files




* The oFP class is the holder that will stay in the _Screen.oFoxyPreviewer
DEFINE CLASS oFP AS Custom
	cLanguage = NULL
	PROCEDURE cLanguage_Assign
		LPARAMETERS tcLanguage
		=PR_SetLanguage(tcLanguage)
	ENDPROC 

	PROCEDURE GetLoc
		LPARAMETERS tcText
		LOCAL lcTranslation
		TRY 
			lcTranslation = EVALUATE("_Screen.oFoxyPreviewer._oLang." + ALLTRIM(tcText))
		CATCH
			lcTranslation = tcText
		ENDTRY 
		RETURN lcTranslation
	ENDPROC 
	
	PROCEDURE SendEmailUsingCDO
		LPARAMETERS tcFile
		LOCAL loMail AS cdo2000
		m.loMail = CREATEOBJECT("Cdo2000")

		LOCAL loFP1
		loFP1 = This && _Screen.oFoxyPreviewer 
		loFP1.lQuietMode = .F.

		WITH m.loMail
			.cServer     = NVL(loFP1.cSMTPServer, "")   && "smtp.live.com"
			.nServerPort = NVL(loFP1.nSMTPPort, 0)     && 25
			.lUseSSL     = NVL(loFP1.lSMTPUseSSL, .T.)   && .T.

			*!* .nAuthenticate = 1 	&& cdoBasic
			*!* .cUserName   = loFP1.cSMTPUserName && "yourAccount@live.com"
			*!* .cPassword   = loFP1.cSMTPPassword && "yourPassword"

			*!*	IF EMPTY(loFP1.cSMTPUserName) AND EMPTY(loFP1.cSMTPPassword)
			*!*		.nAuthenticate = 0 	&& cdoAnonymous
			*!*	ELSE
			*!*		.nAuthenticate 	= 1 	&& cdoBasic
			*!*		.cUserName   	= loFP1.cSMTPUserName && "yourAccount@live.com"
			*!*		.cPassword   	= loFP1.cSMTPPassword && "yourPassword"
			*!*	ENDIF

			IF EMPTY(NVL(loFP1.cSMTPUserName,"")) AND EMPTY(NVL(loFP1.cSMTPPassword,""))
				.nAuthenticate = 0 	&& cdoAnonymous
			ELSE
				.nAuthenticate = 1 	&& cdoBasic
				.cUserName     = NVL(loFP1.cSMTPUserName, "") && "yourAccount@live.com"
				.cPassword     = NVL(loFP1.cSMTPPassword, "") && "yourPassword"
			ENDIF

			*.cFrom = "yourlAccount@live.com"
			.cFrom    = NVL(loFP1.cEmailFrom, "")    && .cUserName
			.cTo      = NVL(loFP1.cEmailTo  , "")    && "vfpimaging@hotmail.com" && "somebody@otherdomain.com, somebodyelse@otherdomain.com"
			.cCC      = NVL(loFP1.cEmailCC  , "")
			.cBCC     = NVL(loFP1.cEmailBCC , "")
			.cSubject = NVL(loFP1.cEmailSubject, "") && "FOXYPREVIEWER email"
			.cReplyTo = NVL(loFP1.cEmailReplyTo, "")

			*!* * Uncomment next lines to send HTML body
			*!* *.cHtmlBody = "<html><body><b>This is an HTML body<br>" + ;
			*!* *		"It'll be displayed by most email clients</b></body></html>"
			*!*
			*!* .cTextBody = loFP1.cEmailBody
			*!* && "This is a text body." + CHR(13) + CHR(10) + ;
			*!* && "It'll be displayed if HTML body is not present or by text only email clients"

			IF EMPTY(NVL(loFP1.cEmailBody, ""))
				loFP1.cEmailBody = "<HTML><BR></HTML>"
			ENDIF

			IF UPPER(LEFT(NVL(loFP1.cEmailBody,""), 6)) == "<HTML>"
				.cHtmlBody = loFP1.cEmailBody
			ELSE
				.cTextBody = NVL(loFP1.cEmailBody, "")
				&& "This is a text body." + CHR(13) + CHR(10) + ;
				&& "It'll be displayed if HTML body is not present or by text only email clients"
			ENDIF

			* Attachments are optional
			IF NOT EMPTY(NVL(loFP1.cAttachments, "")) && "myreport.pdf, myspreadsheet.xls"
				.cAttachment = NVL(loFP1.cAttachments, "") + "," + m.tcFile
			ELSE 
				.cAttachment = m.tcFile
			ENDIF
		
			.lReadReceipt = NVL(loFP1.lReadReceipt, .F.)
			.lPriority    = NVL(loFP1.lPriority, .F.)
		ENDWITH


		IF m.loMail.SEND() > 0
			LOCAL lcMailErr
			m.lcMailErr = ""
			FOR m.i=1 TO m.loMail.GetErrorCount()
				* ? i, loMail.Geterror(i)
				m.lcMailErr = m.lcMailErr + m.loMail.GetError(m.i) + CHR(13)
			ENDFOR
			IF NOT NVL(loFP1.lSilent, .F.)
				MESSAGEBOX(loFP1._ErrorSendingMail + ":" + CHR(13) + ;
					m.lcMailErr + CHR(13) + loFP1._MsgNotSentText, 48, loFP1._ErrorSendingMail)
			ENDIF 
			loFP1.lEmailed = .F.
		ELSE
			loFP1.lEmailed = .T.
			IF NOT NVL(loFP1.lSilent, .F.)
				MESSAGEBOX(loFP1._MsgSuccessText, 64, loFP1._SendEmailText)
			ENDIF
		ENDIF

		RETURN loFP1.lEmailed

	ENDPROC 
ENDDEFINE




PROCEDURE PR_MAPIShowMessage
	LPARAMETERS tnMAPIErrNo
	LOCAL lcMessage, lcMapiMsg
	lcMapiMsg = PR_MAPI_GetMessageText(tnMAPIErrNo)
	lcMessage = TRANSFORM(tnMAPIErrNo) + " - " + lcMapiMsg

	IF VARTYPE(_goFP) = "O"
		MESSAGEBOX(_goFP.GetLoc("ERRSENDMAI") + _CRLF + ;
			lcMessage + _CRLF + ;
			_goFP.GetLoc("MSGNOTSENT"), 16, _goFP.GetLoc("ERROR"))
	ELSE
		MESSAGEBOX("Error sending email" + _CRLF + ;
			lcMessage + _CRLF + ;
			"Message was not sent", 16, "Error")
	ENDIF
	RETURN
ENDPROC


PROCEDURE PR_MAPI_GetMessageText
	LPARAMETERS tnErr
	*!*		#DEFINE SUCCESS_SUCCESS  				0
	*!*		#DEFINE MAPI_USER_ABORT  				1
	*!*		#DEFINE MAPI_E_USER_ABORT  				MAPI_USER_ABORT
	*!*		#DEFINE MAPI_E_FAILURE  				2
	*!*		#DEFINE MAPI_E_LOGIN_FAILURE  			3
	*!*		#DEFINE MAPI_E_LOGON_FAILURE  			MAPI_E_LOGIN_FAILURE
	*!*		#DEFINE MAPI_E_DISK_FULL  				4
	*!*		#DEFINE MAPI_E_INSUFFICIENT_MEMORY  	5
	*!*		#DEFINE MAPI_E_BLK_TOO_SMALL  			6
	*!*		#DEFINE MAPI_E_TOO_MANY_SESSIONS  		8
	*!*		#DEFINE MAPI_E_TOO_MANY_FILES  			9
	*!*		#DEFINE MAPI_E_TOO_MANY_RECIPIENTS  	10
	*!*		#DEFINE MAPI_E_ATTACHMENT_NOT_FOUND  	11
	*!*		#DEFINE MAPI_E_ATTACHMENT_OPEN_FAILURE  12
	*!*		#DEFINE MAPI_E_ATTACHMENT_WRITE_FAILURE 13
	*!*		#DEFINE MAPI_E_UNKNOWN_RECIPIENT  		14
	*!*		#DEFINE MAPI_E_BAD_RECIPTYPE  			15
	*!*		#DEFINE MAPI_E_NO_MESSAGES  			16
	*!*		#DEFINE MAPI_E_INVALID_MESSAGE  		17
	*!*		#DEFINE MAPI_E_TEXT_TOO_LARGE  			18
	*!*		#DEFINE MAPI_E_INVALID_SESSION  		19
	*!*		#DEFINE MAPI_E_TYPE_NOT_SUPPORTED  		20
	*!*		#DEFINE MAPI_E_AMBIGUOUS_RECIPIENT  	21
	*!*		#DEFINE MAPI_E_AMBIG_RECIP  			MAPI_E_AMBIGUOUS_RECIPIENT
	*!*		#DEFINE MAPI_E_MESSAGE_IN_USE  			22
	*!*		#DEFINE MAPI_E_NETWORK_FAILURE  		23
	*!*		#DEFINE MAPI_E_INVALID_EDITFIELDS  		24
	*!*		#DEFINE MAPI_E_INVALID_RECIPS  			25
	*!*		#DEFINE MAPI_E_NOT_SUPPORTED  			26

	LOCAL lcRet
	DO CASE
	CASE tnErr = MAPI_E_ATTACHMENT_OPEN_FAILURE
		lcRet = "One or more files could not be located. No message was sent."
	CASE tnErr = MAPI_E_ATTACHMENT_WRITE_FAILURE
		lcRet = "An attachment could not be written to a temporary file. Check directory permissions."
	CASE tnErr = MAPI_E_FAILURE
		lcRet = "One or more unspecified errors occurred while sending the message. It is not known if the message was sent."
	CASE tnErr = MAPI_E_INSUFFICIENT_MEMORY
		lcRet = "There was insufficient memory to proceed."
	CASE tnErr = MAPI_E_LOGIN_FAILURE
		lcRet = "There was no default logon, and the user failed to log on successfully when the logon dialog box was displayed. No message was sent."
	CASE tnErr = MAPI_E_USER_ABORT
		lcRet = "The user canceled one of the dialog boxes. No message was sent."
	CASE tnErr = MAPI_E_TOO_MANY_SESSIONS
		lcRet = "The user had too many sessions open simultaneously. No session handle was returned."
	CASE tnErr = MAPI_E_AMBIGUOUS_RECIPIENT
		lcRet = "A recipient matched more than one of the recipient descriptor structures and MAPI_DIALOG was not set. No message was sent."
	CASE tnErr = MAPI_E_ATTACHMENT_NOT_FOUND
		lcRet = "The specified attachment was not found. No message was sent."
	CASE tnErr = MAPI_E_BAD_RECIPTYPE
		lcRet = "The type of a recipient was not MAPI_TO, MAPI_CC, or MAPI_BCC. No message was sent."
	CASE tnErr = MAPI_E_INVALID_RECIPS
		lcRet = "One or more recipients were invalid or did not resolve to any address."
	CASE tnErr = MAPI_E_TEXT_TOO_LARGE
		lcRet = "The text in the message was too large. No message was sent."
	CASE tnErr = MAPI_E_TOO_MANY_FILES
		lcRet = "There were too many file attachments. No message was sent."
	CASE tnErr = MAPI_E_TOO_MANY_RECIPIENTS
		lcRet = "There were too many recipients. No message was sent."
	CASE tnErr = MAPI_E_UNKNOWN_RECIPIENT
		lcRet = "A recipient did not appear in the address list. No message was sent."
	* CASE tnErr = SUCCESS_SUCCESS
		* lcRet = "The call succeeded and the message was sent."
	OTHERWISE
		lcRet = ""
	ENDCASE

	RETURN lcRet
ENDPROC



FUNCTION PR_XPUTFILE(tcCustomText, tcFullPathFileName, tcFileExtensions)
	* Copyright (C) 2012 Metha Consultoria e Sistemas de Informatica Limitada
	*
	* Permission is hereby granted, free of charge, to any person obtaining a copy of this software and
	* associated documentation files (the "Software"), to deal in the Software without restriction, 
	* including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, 
	* and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so,
	* subject to the following conditions:
	* 
	* The above copyright notice and this permission notice shall be included in all copies or substantial 
	* portions of the Software.
	*
	* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT
	* LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. 
	* IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
	* WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE 
	* SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
	*
	* Version Number - Date - Comment (Author)
	* 1 - 2012-10-04 - Initial version (Marcio Gomes Goncalves)
	* 2 - 2012-10-18 - Tweaked version (VFPIMAGING) - renamed function names
	* 3 - 2013-03-24 - Fix showing the file name without the extension
	LOCAL lcFile, lcDefExt
	m.lcFile = JUSTFNAME(m.tcFullPathFileName)
	m.lcDefExt = JUSTEXT(m.lcFile)
	IF EMPTY(m.lcDefExt)
		m.lcDefExt = GETWORDNUM(tcFileExtensions, 1, ";")
	ENDIF

	IF "\\" $ m.tcFullPathFileName
		LOCAL lcFullPathCurdir, lcPath
		m.lcPath = JUSTPATH(m.tcFullPathFileName)
		m.lcFullPathCurdir = FULLPATH(CURDIR())
		SET DEFAULT TO (m.lcPath)
		m.lcFile = PUTFILE(m.tcCustomText, FORCEEXT(m.lcFile,m.lcDefExt), m.tcFileExtensions)
		SET DEFAULT TO (m.lcFullPathCurdir)
		RETURN m.lcFile
	ELSE  && Not using UNC, so do the default behavior
		RETURN PUTFILE(m.tcCustomText, FORCEEXT(m.tcFullPathFileName, m.lcDefExt), m.tcFileExtensions)
	ENDIF
ENDFUNC





* GDIPLUS FUNCTIONS BORROWED FROM THE GDIPLUSX LIBRARY FROM VFPX
*********************************************************************
FUNCTION xfcGdipDrawString(graphics, str, length, thefont, layoutRect, StringFormat, brush)
*********************************************************************
	DECLARE Long GdipDrawString IN GDIPLUS.DLL AS xfcGdipDrawString Long graphics, String str, Long length, Long thefont, String @layoutRect, Long StringFormat, Long brush
	RETURN xfcGdipDrawString(m.graphics, m.str, m.length, m.thefont, @m.layoutRect, m.StringFormat, m.brush)
ENDFUNC

*********************************************************************
FUNCTION xfcGdipMeasureString(graphics, str, length, thefont, layoutRect, StringFormat, boundingBox, codepointsFitted, linesFilled)
*********************************************************************
	DECLARE Long GdipMeasureString IN GDIPLUS.DLL AS xfcGdipMeasureString Long graphics, String str, Long length, Long thefont, String @layoutRect, Long StringFormat, String @boundingBox, Long @codepointsFitted, Long @linesFilled
	RETURN xfcGdipMeasureString(m.graphics, m.str, m.length, m.thefont, @m.layoutRect, m.StringFormat, @m.boundingBox, @m.codepointsFitted, @m.linesFilled)
ENDFUNC

*********************************************************************
FUNCTION xfcGdipRestoreGraphics(graphics, State)
*********************************************************************
	DECLARE Long GdipRestoreGraphics IN GDIPLUS.DLL AS xfcGdipRestoreGraphics Long graphics, Long State
	RETURN xfcGdipRestoreGraphics(m.graphics, m.State)
ENDFUNC

*********************************************************************
FUNCTION xfcGdipSaveGraphics(graphics, State)
*********************************************************************
	DECLARE Long GdipSaveGraphics IN GDIPLUS.DLL AS xfcGdipSaveGraphics Long graphics, Long @State
	RETURN xfcGdipSaveGraphics(m.graphics, @m.State)
ENDFUNC

*********************************************************************
FUNCTION xfcGdipSetPixelOffsetMode(graphics, PixOffsetMode)
*********************************************************************
	DECLARE Long GdipSetPixelOffsetMode IN GDIPLUS.DLL AS xfcGdipSetPixelOffsetMode Long graphics, Long PixOffsetMode
	RETURN xfcGdipSetPixelOffsetMode(m.graphics, m.PixOffsetMode)
ENDFUNC

*********************************************************************
FUNCTION xfcGdipSetRenderingOrigin(graphics, x, y)
*********************************************************************
	DECLARE Long GdipSetRenderingOrigin IN GDIPLUS.DLL AS xfcGdipSetRenderingOrigin Long graphics, Long x, Long y
	RETURN xfcGdipSetRenderingOrigin(m.graphics, m.x, m.y)
ENDFUNC

*********************************************************************
FUNCTION xfcGdipSetSmoothingMode(graphics, SmoothingMd)
*********************************************************************
	DECLARE Long GdipSetSmoothingMode IN GDIPLUS.DLL AS xfcGdipSetSmoothingMode Long graphics, Long SmoothingMd
	RETURN xfcGdipSetSmoothingMode(m.graphics, m.SmoothingMd)
ENDFUNC

*********************************************************************
FUNCTION xfcGdipSetStringFormatAlign(StringFormat, Align)
*********************************************************************
	DECLARE Long GdipSetStringFormatAlign IN GDIPLUS.DLL AS xfcGdipSetStringFormatAlign Long StringFormat, Long Align
	RETURN xfcGdipSetStringFormatAlign(m.StringFormat, m.Align)
ENDFUNC

*********************************************************************
FUNCTION xfcGdipSetStringFormatFlags(StringFormat, flags)
*********************************************************************
	DECLARE Long GdipSetStringFormatFlags IN GDIPLUS.DLL AS xfcGdipSetStringFormatFlags Long StringFormat, Long flags
	RETURN xfcGdipSetStringFormatFlags(m.StringFormat, m.flags)
ENDFUNC

*********************************************************************
FUNCTION xfcGdipSetTextRenderingHint(graphics, mode)
*********************************************************************
	DECLARE Long GdipSetTextRenderingHint IN GDIPLUS.DLL AS xfcGdipSetTextRenderingHint Long graphics, Long mode
	RETURN xfcGdipSetTextRenderingHint(m.graphics, m.mode)
ENDFUNC

*********************************************************************
FUNCTION xfcGdipSetWorldTransform(graphics, matrix)
*********************************************************************
	DECLARE Long GdipSetWorldTransform IN GDIPLUS.DLL AS xfcGdipSetWorldTransform Long graphics, Long matrix
	RETURN xfcGdipSetWorldTransform(m.graphics, m.matrix)
ENDFUNC

*********************************************************************
FUNCTION xfcGdipStringFormatGetGenericTypographic(StringFormat)
*********************************************************************
	DECLARE Long GdipStringFormatGetGenericTypographic IN GDIPLUS.DLL AS xfcGdipStringFormatGetGenericTypographic Long @StringFormat
	RETURN xfcGdipStringFormatGetGenericTypographic(@m.StringFormat)
ENDFUNC

*********************************************************************
FUNCTION xfcGdipTransformPoints(graphics, destSpace, srcSpace, pPoint, Count)
*********************************************************************
	DECLARE Long GdipTransformPoints IN GDIPLUS.DLL AS xfcGdipTransformPoints Long graphics, Long destSpace, Long srcSpace, String @pPoint, Long Count
	RETURN xfcGdipTransformPoints(m.graphics, m.destSpace, m.srcSpace, @m.pPoint, m.Count)
ENDFUNC

*********************************************************************
FUNCTION xfcGdipTransformPointsI(graphics, destSpace, srcSpace, pPoint, Count)
*********************************************************************
	DECLARE Long GdipTransformPointsI IN GDIPLUS.DLL AS xfcGdipTransformPointsI Long graphics, Long destSpace, Long srcSpace, String @pPoint, Long Count
	RETURN xfcGdipTransformPointsI(m.graphics, m.destSpace, m.srcSpace, @m.pPoint, m.Count)
ENDFUNC

*********************************************************************
FUNCTION xfcGdipTranslateClip(graphics, dx, dy)
*********************************************************************
	DECLARE Long GdipTranslateClip IN GDIPLUS.DLL AS xfcGdipTranslateClip Long graphics, Single dx, Single dy
	RETURN xfcGdipTranslateClip(m.graphics, m.dx, m.dy)
ENDFUNC


*********************************************************************
FUNCTION xfcGdipCloneStringFormat(StringFormat, newFormat)
*********************************************************************
	DECLARE Long GdipCloneStringFormat IN GDIPLUS.DLL AS xfcGdipCloneStringFormat Long StringFormat, Long @newFormat
	RETURN xfcGdipCloneStringFormat(m.StringFormat, @m.newFormat)
ENDFUNC

*********************************************************************
FUNCTION xfcGdipCreateStringFormat(formatAttributes, language, StringFormat)
*********************************************************************
	DECLARE Long GdipCreateStringFormat IN GDIPLUS.DLL AS xfcGdipCreateStringFormat Integer formatAttributes, Integer language, Long @StringFormat
	RETURN xfcGdipCreateStringFormat(m.formatAttributes, m.language, @m.StringFormat)
ENDFUNC

*********************************************************************
FUNCTION xfcGdipDeleteStringFormat(StringFormat)
*********************************************************************
	DECLARE Long GdipDeleteStringFormat IN GDIPLUS.DLL AS xfcGdipDeleteStringFormat Long StringFormat
	RETURN xfcGdipDeleteStringFormat(m.StringFormat)
ENDFUNC




*********************************************************************
FUNCTION xfcGdipGetStringFormatAlign(StringFormat, Align)
*********************************************************************
	DECLARE Long GdipGetStringFormatAlign IN GDIPLUS.DLL AS xfcGdipGetStringFormatAlign Long StringFormat, Long @Align
	RETURN xfcGdipGetStringFormatAlign(m.StringFormat, @m.Align)
ENDFUNC

*********************************************************************
FUNCTION xfcGdipGetStringFormatDigitSubstitution(StringFormat, language, substitute)
*********************************************************************
	DECLARE Long GdipGetStringFormatDigitSubstitution IN GDIPLUS.DLL AS xfcGdipGetStringFormatDigitSubstitution Long StringFormat, Integer @language, Long @substitute
	RETURN xfcGdipGetStringFormatDigitSubstitution(m.StringFormat, @m.language, @m.substitute)
ENDFUNC

*********************************************************************
FUNCTION xfcGdipGetStringFormatFlags(StringFormat, flags)
*********************************************************************
	DECLARE Long GdipGetStringFormatFlags IN GDIPLUS.DLL AS xfcGdipGetStringFormatFlags Long StringFormat, Long @flags
	RETURN xfcGdipGetStringFormatFlags(m.StringFormat, @m.flags)
ENDFUNC

*********************************************************************
FUNCTION xfcGdipGetStringFormatHotkeyPrefix(StringFormat, hkPrefix)
*********************************************************************
	DECLARE Long GdipGetStringFormatHotkeyPrefix IN GDIPLUS.DLL AS xfcGdipGetStringFormatHotkeyPrefix Long StringFormat, Long @hkPrefix
	RETURN xfcGdipGetStringFormatHotkeyPrefix(m.StringFormat, @m.hkPrefix)
ENDFUNC

*********************************************************************
FUNCTION xfcGdipGetStringFormatLineAlign(StringFormat, Align)
*********************************************************************
	DECLARE Long GdipGetStringFormatLineAlign IN GDIPLUS.DLL AS xfcGdipGetStringFormatLineAlign Long StringFormat, Long @Align
	RETURN xfcGdipGetStringFormatLineAlign(m.StringFormat, @m.Align)
ENDFUNC

*********************************************************************
FUNCTION xfcGdipGetStringFormatTabStopCount(StringFormat, Count)
*********************************************************************
	DECLARE Long GdipGetStringFormatTabStopCount IN GDIPLUS.DLL AS xfcGdipGetStringFormatTabStopCount Long StringFormat, Long @Count
	RETURN xfcGdipGetStringFormatTabStopCount(m.StringFormat, @m.Count)
ENDFUNC

*********************************************************************
FUNCTION xfcGdipGetStringFormatTabStops(StringFormat, Count, firstTabOffset, tabStops)
*********************************************************************
	DECLARE Long GdipGetStringFormatTabStops IN GDIPLUS.DLL AS xfcGdipGetStringFormatTabStops Long StringFormat, Long Count, Single @firstTabOffset, String @tabStops
	RETURN xfcGdipGetStringFormatTabStops(m.StringFormat, m.Count, @m.firstTabOffset, @m.tabStops)
ENDFUNC

*********************************************************************
FUNCTION xfcGdipGetStringFormatTrimming(StringFormat, trimming)
*********************************************************************
	DECLARE Long GdipGetStringFormatTrimming IN GDIPLUS.DLL AS xfcGdipGetStringFormatTrimming Long StringFormat, Long @trimming
	RETURN xfcGdipGetStringFormatTrimming(m.StringFormat, @m.trimming)
ENDFUNC

*********************************************************************
FUNCTION xfcGdipSetStringFormatAlign(StringFormat, Align)
*********************************************************************
	DECLARE Long GdipSetStringFormatAlign IN GDIPLUS.DLL AS xfcGdipSetStringFormatAlign Long StringFormat, Long Align
	RETURN xfcGdipSetStringFormatAlign(m.StringFormat, m.Align)
ENDFUNC

*********************************************************************
FUNCTION xfcGdipSetStringFormatDigitSubstitution(StringFormat, language, substitute)
*********************************************************************
	DECLARE Long GdipSetStringFormatDigitSubstitution IN GDIPLUS.DLL AS xfcGdipSetStringFormatDigitSubstitution Long StringFormat, Integer language, Long substitute
	RETURN xfcGdipSetStringFormatDigitSubstitution(m.StringFormat, m.language, m.substitute)
ENDFUNC

*********************************************************************
FUNCTION xfcGdipSetStringFormatFlags(StringFormat, flags)
*********************************************************************
	DECLARE Long GdipSetStringFormatFlags IN GDIPLUS.DLL AS xfcGdipSetStringFormatFlags Long StringFormat, Long flags
	RETURN xfcGdipSetStringFormatFlags(m.StringFormat, m.flags)
ENDFUNC

*********************************************************************
FUNCTION xfcGdipSetStringFormatHotkeyPrefix(StringFormat, hkPrefix)
*********************************************************************
	DECLARE Long GdipSetStringFormatHotkeyPrefix IN GDIPLUS.DLL AS xfcGdipSetStringFormatHotkeyPrefix Long StringFormat, Long hkPrefix
	RETURN xfcGdipSetStringFormatHotkeyPrefix(m.StringFormat, m.hkPrefix)
ENDFUNC

*********************************************************************
FUNCTION xfcGdipSetStringFormatLineAlign(StringFormat, Align)
*********************************************************************
	DECLARE Long GdipSetStringFormatLineAlign IN GDIPLUS.DLL AS xfcGdipSetStringFormatLineAlign Long StringFormat, Long Align
	RETURN xfcGdipSetStringFormatLineAlign(m.StringFormat, m.Align)
ENDFUNC

*********************************************************************
FUNCTION xfcGdipSetStringFormatMeasurableCharacterRanges(StringFormat, rangeCount, ranges)
*********************************************************************
	DECLARE Long GdipSetStringFormatMeasurableCharacterRanges IN GDIPLUS.DLL AS xfcGdipSetStringFormatMeasurableCharacterRanges Long StringFormat, Long rangeCount, String ranges
	RETURN xfcGdipSetStringFormatMeasurableCharacterRanges(m.StringFormat, m.rangeCount, m.ranges)
ENDFUNC

*********************************************************************
FUNCTION xfcGdipSetStringFormatTabStops(StringFormat, firstTabOffset, Count, tabStops)
*********************************************************************
	DECLARE Long GdipSetStringFormatTabStops IN GDIPLUS.DLL AS xfcGdipSetStringFormatTabStops Long StringFormat, Single firstTabOffset, Long Count, String tabStops
	RETURN xfcGdipSetStringFormatTabStops(m.StringFormat, m.firstTabOffset, m.Count, m.tabStops)
ENDFUNC

*********************************************************************
FUNCTION xfcGdipSetStringFormatTrimming(StringFormat, trimming)
*********************************************************************
	DECLARE Long GdipSetStringFormatTrimming IN GDIPLUS.DLL AS xfcGdipSetStringFormatTrimming Long StringFormat, Long trimming
	RETURN xfcGdipSetStringFormatTrimming(m.StringFormat, m.trimming)
ENDFUNC

*********************************************************************
FUNCTION xfcGdipStringFormatGetGenericDefault(StringFormat)
*********************************************************************
	DECLARE Long GdipStringFormatGetGenericDefault IN GDIPLUS.DLL AS xfcGdipStringFormatGetGenericDefault Long @StringFormat
	RETURN xfcGdipStringFormatGetGenericDefault(@m.StringFormat)
ENDFUNC

*********************************************************************
FUNCTION xfcGdipStringFormatGetGenericTypographic(StringFormat)
*********************************************************************
	DECLARE Long GdipStringFormatGetGenericTypographic IN GDIPLUS.DLL AS xfcGdipStringFormatGetGenericTypographic Long @StringFormat
	RETURN xfcGdipStringFormatGetGenericTypographic(@m.StringFormat)
ENDFUNC



* FUNCTIONs used for Printing
*********************************************************************
FUNCTION xfcCreateDC(cDriver, cDevice, lpszOutput, lpInitData)
*********************************************************************
	DECLARE Long CreateDC IN WIN32API AS xfcCreateDC ;
		STRING cDriver, STRING cDevice, ;
        STRING lpszOutput, INTEGER @lpInitData
	RETURN xfcCreateDC(m.cDriver, m.cDevice, m.lpszOutput, @m.lpInitData)
ENDFUNC

*********************************************************************
FUNCTION xfcDeleteDC(hDC)
*********************************************************************
	DECLARE Long DeleteDC IN WIN32API AS xfcDeleteDC ;
		LONG hDC
	RETURN xfcDeleteDC(m.hDC)
ENDFUNC

*********************************************************************
FUNCTION xfcStartPage(hDC)
*********************************************************************
	DECLARE INTEGER StartPage IN gdi32 as xfcStartPage INTEGER hdc
	RETURN xfcStartPage(m.hDC)
ENDFUNC

*********************************************************************
FUNCTION xfcEndPage(hDC)
*********************************************************************
	DECLARE INTEGER EndPage IN gdi32 as xfcEndPage INTEGER hdc
	RETURN xfcEndPage(m.hDC)
ENDFUNC

*********************************************************************
FUNCTION xfcStartDoc(hDC, lpdi)
*********************************************************************
	DECLARE INTEGER StartDoc IN gdi32 as xfcStartDoc INTEGER hdc, STRING @ lpdi
	RETURN xfcStartDoc(m.hDC, @m.lpdi)
ENDFUNC

*********************************************************************
FUNCTION xfcEndDoc(hDC)
*********************************************************************
	DECLARE INTEGER EndDoc IN gdi32 as xfcEndDoc INTEGER hdc
	RETURN xfcEndDoc(m.hDC)
ENDFUNC

*********************************************************************
FUNCTION xfcGetDeviceCaps(hDC, nIndex)
*********************************************************************
	DECLARE INTEGER GetDeviceCaps IN gdi32 as xfcGetDeviceCaps INTEGER hdc, INTEGER nIndex
	RETURN xfcGetDeviceCaps(m.hDC, m.nIndex)
ENDFUNC


*!*	*********************************************************************
*!*	FUNCTION xfcRevertString(tcString)
*!*	*********************************************************************
*!*	    DECLARE STRING _strrev IN msvcrt20.dll as xfcRevertString STRING @
*!*	    RETURN xfcRevertString(@m.tcString + CHR(0))
*!*	ENDFUNC 


*********************************************************************
FUNCTION PR_ScreenToClient(HWND, cPoint)
*********************************************************************
	DECLARE INTEGER ScreenToClient IN user32 AS PR_ScreenToClient INTEGER HWND, STRING @cPoint
	RETURN PR_ScreenToClient(m.hWND, @m.cPoint)
ENDFUNC

*********************************************************************
FUNCTION PR_GetCursorPos(cPoint)
*********************************************************************
	DECLARE INTEGER GetCursorPos IN user32 AS PR_GetCursorPos STRING @cPoint
	RETURN PR_GetCursorPos(@m.cPoint)
ENDFUNC

*********************************************************************
FUNCTION PR_PathFileExists(pszPath)
*********************************************************************
	DECLARE INTEGER PathFileExists IN shlwapi AS PR_PathFileExists STRING pszPath
	RETURN PR_PathFileExists(@m.pszPath)
ENDFUNC

*********************************************************************
FUNCTION PR_GetFocus()
*********************************************************************
	DECLARE INTEGER GetFocus IN user32 AS PR_GetFocus
	RETURN PR_GetFocus()
ENDFUNC

*********************************************************************
FUNCTION PR_GetWindowText(HWND, lpString, cch)
*********************************************************************
	DECLARE INTEGER GetWindowText IN user32;
		AS PR_GetWindowText ;
		INTEGER HWND, STRING @lpString, INTEGER cch
	RETURN PR_GetWindowText(m.HWND, @m.lpString, m.cch)
ENDFUNC

*********************************************************************
FUNCTION PR_GetActiveWindow()
*********************************************************************
	DECLARE INTEGER GetActiveWindow IN user32 AS PR_GetActiveWindow
	RETURN PR_GetActiveWindow()
ENDFUNC

*********************************************************************
FUNCTION PR_MAPISendDocuments(ulUIParam, lpszDelimChar, lpszFullPaths, lpszFileNames, ulReserved)
*********************************************************************
	DECLARE INTEGER MAPISendDocuments IN mapi32;
		AS PR_MAPISendDocuments ;
		INTEGER ulUIParam, STRING lpszDelimChar,;
		STRING lpszFullPaths, STRING lpszFileNames,;
		INTEGER ulReserved
	RETURN PR_MAPISendDocuments(m.ulUIParam, m.lpszDelimChar, m.lpszFullPaths, m.lpszFileNames, m.ulReserved)
ENDFUNC

********************************************************************
PROCEDURE CleanClauses(tcClauses)
********************************************************************
	LOCAL lcClauses
	m.lcClauses = STRTRAN(m.tcClauses, "NOCONSOLE", "")
	m.lcClauses = STRTRAN(m.lcClauses, "noconsole", "")
	m.lcClauses = STRTRAN(m.lcClauses, "PREVIEW", "")
	m.lcClauses = STRTRAN(m.lcClauses, "preview", "")
	RETURN m.lcClauses
ENDPROC

********************************************************************
PROCEDURE IsDotMatrix(m.tcPrinter)
********************************************************************
	#DEFINE DC_BINS 6
	#DEFINE DMBIN_TRACTOR 8
	LOCAL lnBins, lcBuff, llDotMatrix
	TRY 
		m.lcBuff = SPACE(512)
		m.lnBins = PR_DeviceCapabilities (m.tcPrinter, NULL, DC_BINS, @m.lcBuff, NULL)
		m.llDotMatrix = (CHR(DMBIN_TRACTOR) + CHR(0)) $ LEFT(m.lcBuff, m.lnBins * 2)
	CATCH TO m.loexc
		m.llDotMatrix = .F.
	ENDTRY 
	RETURN m.llDotMatrix
ENDPROC

*********************************************************************
FUNCTION PR_DeviceCapabilities(sPrinter, sPort, nCapability, sReturn, pDevMode)
*********************************************************************
	DECLARE LONG DeviceCapabilities IN WinSpool.drv AS PR_DeviceCapabilities ;
		STRING @ sPrinter, STRING @ sPort, ;
		INTEGER nCapability, STRING @ sReturn, STRING @ pDevMode

	RETURN PR_DeviceCapabilities(m.sPrinter, m.sPort, m.nCapability, @m.sReturn, m.pDevMode)
ENDFUNC

*********************************************************************
FUNCTION PR_MessageBeep(nType)
* http://msdn.microsoft.com/en-us/library/ms680356(VS.85).aspx
*********************************************************************
    DECLARE INTEGER MessageBeep in Win32API AS PR_MessageBeep integer
	RETURN PR_MessageBeep(m.nType)
ENDFUNC

*********************************************************************
PROCEDURE GetParentWindow
*********************************************************************
* Returns the Windows handle from the active form
	LOCAL hWindow
	m.hWindow = PR_GetFocus()
	RETURN GetWinText(m.hWindow)
ENDPROC

*********************************************************************
FUNCTION  GetWinText(m.hWindow)
*********************************************************************
	LOCAL lnBufsize, lcBuffer
	m.lnBufsize = 1024
	m.lcBuffer = REPLI(CHR(0), m.lnBufsize)
	m.lnBufsize = PR_GetWindowText(m.hWindow, @m.lcBuffer, m.lnBufsize)
	RETURN  IIF(m.lnBufsize=0, "", LEFT(m.lcBuffer,m.lnBufsize))


*********************************************************************
FUNCTION OpenPrinter(tcPrinterName, thPrinter, tcDefault)
*********************************************************************
	DECLARE Long OpenPrinter IN WinSpool.Drv ;
		String pPrinterName, Long @ phPrinter, String pDefault
	RETURN 	OpenPrinter(m.tcPrinterName, @m.thPrinter, m.tcDefault)

*********************************************************************
FUNCTION ClosePrinter (thPrinter)
*********************************************************************
	DECLARE Long ClosePrinter IN WinSpool.Drv Long hPrinter
	RETURN ClosePrinter(m.thPrinter)

*********************************************************************
FUNCTION EnumForms(thPrinter, tnLevel, tnForm, tnBuf, tnNeeded, tnReturned)
*********************************************************************
	DECLARE Long EnumForms IN winspool.drv ;
		Long hPrinter, Long Level, Long pForm, ;
		Long cbBuf, Long @pcbNeeded, Long @ pcReturned
	RETURN EnumForms(m.thPrinter, m.tnLevel, m.tnForm, m.tnBuf, @m.tnNeeded, @m.tnReturned)

*********************************************************************
FUNCTION DeviceCapabilities(pDevice, pPort, fwCapability, pOutput, pDevMode)
*********************************************************************
	DECLARE Long DeviceCapabilities IN winspool.drv ;
		String pDevice, String pPort, Long fwCapability, ;
		String @pOutput, Long pDevMode
	RETURN DeviceCapabilities(m.pDevice, m.pPort, m.fwCapability, @m.pOutput, m.pDevMode)


*********************************************************************
FUNCTION ShellExecute(nWinHandle, cOperation, cFileName, cParameters, cDirectory, nShowWindow)
*********************************************************************
	DECLARE INTEGER ShellExecute IN SHELL32.Dll Integer nWinHandle, String cOperation, String cFileName, String cParameters, String cDirectory, Integer nShowWindow
	RETURN ShellExecute(nWinHandle, cOperation, cFileName, cParameters, cDirectory, nShowWindow)


*********************************************************************
FUNCTION FindWindow(cNull, cWinName)
*********************************************************************
	DECLARE INTEGER FindWindow In WIN32API String cNull,String cWinName
	RETURN FindWindow(cNull, cWinName)


*********************************************************************
FUNCTION GetParent(nHWND)
*********************************************************************
	DECLARE LONG GetParent IN WIN32API LONG nHWND
	RETURN GetParent(nHWND)


*********************************************************************
FUNCTION SetParent(hWndChild, hWndNewParent)
	DECLARE LONG SetParent IN WIN32API LONG, LONG
	RETURN SetParent(hWndChild, hWndNewParent)
*********************************************************************


*********************************************************************
FUNCTION SetWindowPos(hWnd, hWndInsertAfter, X, Y, cx, cy, uFlags)
	* http://msdn.microsoft.com/en-us/library/windows/desktop/ms633545(v=vs.85).aspx
	DECLARE LONG SetWindowPos IN WIN32API LONG, LONG, LONG, LONG, LONG, LONG, LONG
	RETURN SetWindowPos(hWnd, hWndInsertAfter, X, Y, cx, cy, uFlags)
*********************************************************************


*********************************************************************
FUNCTION FormatMessage(dwFlags, lpSource, dwMessageId, dwLanguageId, lpBuffer, nSize, Arguments)
	DECLARE Long FormatMessage IN kernel32 ;
		Long dwFlags, Long lpSource, Long dwMessageId, ;
		Long dwLanguageId, String  @lpBuffer, ;
		Long nSize, Long Arguments
	RETURN FormatMessage(dwFlags, lpSource, dwMessageId, dwLanguageId, @lpBuffer, nSize, Arguments)
*********************************************************************
