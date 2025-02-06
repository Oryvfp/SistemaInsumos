* FoxyPreviewerCaller.Prg
* Version 2.86    2011-11-27

DEFINE CLASS FoxyPreviewerCaller AS Custom

	cPrinterName      = NULL && SET("Printer",3)

	lSaveToFile       = NULL &&     = .T. && adds the save to file button
	lSendToEmail      = NULL &&     = .T. && adds the send to email button
	lPrintVisible     = NULL &&   = .T. && shows the print button in the toolbar
	lShowCopies       = NULL &&   = .T. && shows the copies spinner
	lShowMiniatures   = NULL &&  = .T. && shows the miniatures page
	lShowSetup        = NULL &&  = .T. && shows the setup configuration form
	lPrinterPref      = NULL &&  = .T. && shows the printer preferences button
	lShowSearch       = NULL
	lShowClose        = NULL

	lClearPrinterInfo = .T. && NULL &&  = .T. && clears the EXPR, TAG, TAG2 fields of the FRX

	* Output types allowed in the "Save as.." button from the toolbar
	lSaveAsImage	  = NULL && = .T.
	lSaveAsHTML		  = NULL && = .T.
	lSaveAsRTF		  = NULL && = .T.
	lSaveAsXLS		  = NULL && = .T.
	lSaveAsPDF	 	  = NULL && = .T.
	lSaveAsTXT        = NULL
	lSaveAsMHT        = NULL

	cOutputPath       = NULL

	nPageTotal        = NULL && = 0 && Total pages of the current report
	nCopies           = NULL && = 1 && The quantity of copies to be printed
	cTitle            = NULL && = "" && The preview window title 
	cToolbarTitle     = NULL && = "" && The preview window title 

	oListener         = NULL
	cDefaultListener  = NULL && = "FOXYLISTENER"
	cSuccessor        = NULL
	lUseListener      = NULL && = .T.

	nCanvasCount      = NULL && = 1 && initial nr of pages rendered on the preview form. 
			&& Valid values are 1 (default), 2, or 4.

	nZoomLevel        = NULL && = 5 && initial zoom level of the preview window. Possible values are:
			&& 1-10%, 2-25%, 3-50%, 4-75%, 5-100% default, 6-150% ;
			&& 7-200%, 8-300%, 9-500%, 10-whole page

	lExtended         = NULL && = .T. && Flag that tells if the report is being run automatically
					&& using the _REPORTPERVIEW global variable

	nWindowState      = NULL && = 0 && Normal
	nDockType	      = NULL && = .F.

	cDestFile         = NULL &&    = ""  && the destination file (image, htm, pdf, etc)
	lPrinted          = NULL &&    = .F.  && knows if the user printed the report
	lSaved            = NULL &&    = .F.  && knows if the user saved the report to a file
	nVersion          = NULL
	cVersion          = NULL


	cFormIcon         = NULL && = "" && "wwrite.ico"
	lEmailAuto        = NULL && = .T.
	cEmailType        = NULL && = "PDF"
	cEmailPRG         = NULL && = ""

	cSaveDefName	  = NULL && ""		*!* 2010-09-17 - Jacques Parent - Add the cSaveDefName

	lEmailed          = NULL &&  = .F.
	cCodePage         = NULL && = "CP1252" && CodePage, to be used by PDF Listener
			&& No more need to leave this property, because this is set automatically
			&& left for backwards compatibility

	nMaxMiniatureDisplay  = NULL && = 64	&& Number of miniature proof
	nPDFPageMode   = NULL && = 0
	cLanguage      = NULL && = ""
	nShowToolBar   = NULL && = 1 && Visible
	lShowPrinters  = NULL && = .T. && determines if the available printers combo will be shown


	lAutoSendMail  = NULL

	nEmailMode     = NULL && = 1 && 1 = MAPI, 2 = CDOSYS, 3 = Custom procedure
	cSMTPServer    = NULL && = ""
	nSMTPPort      = NULL && = 25
	lSMTPUseSSL    = NULL && = .F.
	cSMTPUserName  = NULL && = ""
	cSMTPPassword  = NULL && = "" 

	cEmailTo          = NULL && = ""
	cEmailSubject     = NULL && = ""
	cEmailCC          = NULL
	cEmailBCC         = NULL
	cEmailBody        = NULL && = ""
	cEmailFrom        = NULL && = ""
	cEmailReplyTo     = NULL
	cEmailBodyFile    = NULL
	nButtonSize       = NULL && = 1 && 1=16x16 pixels (default), 2=32x32 pixels
	lSilent		      = NULL		&& Tell Foxypreviewer to stay silent and to write message to the cErrors property
	cErrors		      = ""
	lDirectPrint      = .F.
	nPrinterProptype  = NULL
	nThermType        = NULL
	nSearchPages      = NULL

	cEncryptProcedure = NULL
	cDecryptProcedure = NULL
	cCryptKey         = NULL
	lReadReceipt      = NULL
	lPriority         = NULL


	* PDF properties
	lPDFEmbedFonts      = NULL
	lPDFReplaceFonts    = NULL
	lPDFCanPrint        = NULL
	lPDFCanEdit         = NULL
	lPDFCanCopy         = NULL
	lPDFCanAddNotes     = NULL
	lPDFEncryptDocument = NULL
	cPDFMasterPassword  = NULL
	cPDFUserPassword    = NULL
	lOpenViewer         = NULL
	
	cPdfAuthor          = NULL
	cPdfTitle           = NULL
	cPdfSubject         = NULL
	cPdfKeyWords        = NULL
	cPdfCreator         = NULL
	lPDFShowErrors      = NULL
	cPDFSymbolFontsList = NULL
	cPDFDefaultFont     = NULL

	cAdressTable        = NULL
	cAdressSearch       = NULL
	cAttachments        = NULL

	&& Added in 2011-08-08
	cImgPrint 			= NULL 
	cImgPrintPref   	= NULL 
	cImgSave        	= NULL 
	cImgClose       	= NULL 
	cImgClose2      	= NULL 
	cImgEmail       	= NULL 
	cImgSetup       	= NULL 
	cImgMiniatures  	= NULL	 
	cImgSearch      	= NULL 
	cImgSearchAgain 	= NULL 
	cImgSearchBack  	= NULL 
	lExpandFields   	= NULL 
	cPrintJobName   	= NULL 

	* XLS properties
	lExcelConvertToXLS  = NULL && Convert worksheet to 'Excel 95' format? (requires MS Excel or OpenOffice installed)                 
	lExcelRepeatHeaders = NULL && Repeat report page headers in worksheet                
	lExcelRepeatFooters = NULL && Repeat report page footers in worksheet                
	lExcelHidePageNo    = NULL && Hides report fields that contain "_PAGENO" information
	cExcelDefaultExtension = NULL
	lExcelAlignLeft        = NULL

	* Internal use properties
	_oReports = "" && Internal use, collection that contains the report names to be used
	_oClauses = ""
	_oAliases = ""
	_oNames   = ""
	_oFoxy    = ""

PROCEDURE Init
ENDPROC 


PROCEDURE AddReport(tcReport, tcClauses, tcAlias, tcName) && 2011-08-12 - Jacques Parent

	* populates a collection object with the report files and clauses
	* This method can be called many times, providing an easy way to merge reports.

	*/ [20100517]... Now supporting Labels also (LBX,LBT) by Nick Porfyris
	LOCAL lcReport, lcTempDir, lcFile, lcFile2, lcExtension, lcExtension2
	lcTempDir = ADDBS(GETENV("TEMP"))

	* Retrieve the FRX and FRT files from the EXE
		
	lcExtension=UPPER(JUSTEXT(tcReport))
	IF EMPTY(lcExtension)
		lcExtension=[FRX]
		lcExtension2=[FRT]
	ELSE
		* LBX, LBT, ??X, ??T files...
		lcExtension2=STUFF(lcExtension, LEN(lcExtension), 1, [T])
	ENDIF
	lcFile = lcTempDir + "TMP_FP_" + SYS(2015) + "."



	* by Nick Porfyris
	* Corrections for FoxyPreviewerCaller.prg in order to work properly the 
	* "lClearPrinterInfo" variable if it is setting to .F. !!!

	IF THIS.lClearPrinterInfo = .T. OR ;
				EMPTY(SYS(2000, tcReport))
	* Retrieve the FRX, FRT, LBX, LBT, ??X, ??T files...from the EXE

		lcFile2 = FORCEEXT(tcReport,lcExtension)

		STRTOFILE(FILETOSTR(lcFile2), lcFile + lcExtension)
		STRTOFILE(FILETOSTR(FORCEEXT(tcReport,lcExtension2)), lcFile + lcExtension2)

		IF THIS.lClearPrinterInfo = .T.			&& <<<===== [20100719] by Nick Porfyris...
			lcFile = lcFile + lcExtension
			USE (lcFile) IN 0 ALIAS TmpReport

		* Keep only the "ORIENTATION" information
			LOCAL lcExpr
			lcExpr = TmpReport.EXPR
			lcExpr = MLINE(lcExpr,ATLINE("ORIENTATION",lcExpr)) + CHR(13) + ;
				MLINE(lcExpr,ATLINE("PAPERSIZE",lcExpr))

			REPLACE EXPR WITH lcExpr ;
				TAG WITH "", ;
				Tag2 WITH "" IN TmpReport
			USE IN TmpReport
		ENDIF
	ELSE
		lcFile = tcReport
	ENDIF

	IF VARTYPE(This._oReports) <> "O"
		This._oReports = CREATEOBJECT("Collection")
		This._oClauses = CREATEOBJECT("Collection")
		This._oAliases = CREATEOBJECT("Collection")
		This._oNames   = CREATEOBJECT("Collection")		
	ENDIF
	This._oReports.Add(FORCEEXT(lcFile, lcExtension)) && <--- this new one supporting LBX... by Nick
	This._oClauses.Add(EVL(tcClauses,""))
	This._oAliases.Add(EVL(tcAlias,""))
	This._oNames.Add(EVL(tcName,JUSTSTEM(JUSTFNAME(tcReport)))) && 2011-08-12 - Jacques Parent - Let the report name be specified

	*\ [20100517]...
		
ENDPROC



PROCEDURE RunReport

	TRY 
		SET PROCEDURE TO FoxyPreviewer.App ADDITIVE
	CATCH 
		SET PROCEDURE TO FoxyPreviewer.Prg ADDITIVE
	ENDTRY
	
	LOCAL loReport as "PreviewHelper" OF "FoxyPreviewer.App"
	loReport = CREATEOBJECT("PreviewHelper")
	
	WITH loReport

		LOCAL n, lnCount
		lnCount = This._oReports.Count
		FOR n = 1 TO lnCount
			loReport.AddReport(THIS._oReports(n), THIS._oClauses(n), THIS._oAliases(n), This._oNames(n))
		ENDFOR


		IF NOT ISNULL(This.cTitle)
			.cTitle = This.cTitle
		ENDIF
		
		IF NOT ISNULL(This.cToolbarTitle)
			.cToolbarTitle = This.cToolbarTitle
		ENDIF

		IF NOT ISNULL(This.lSendToEmail )
			.lSendToEmail 		= This.lSendToEmail 
		ENDIF

		IF NOT ISNULL(This.lSaveToFile )
			.lSaveToFile 		= This.lSaveToFile 
		ENDIF

		IF NOT ISNULL(This.lShowCopies )
			.lShowCopies 		= This.lShowCopies 
		ENDIF

		IF NOT ISNULL(This.lShowMiniatures )
			.lShowMiniatures 	= This.lShowMiniatures 
		ENDIF

		IF NOT ISNULL(This.lShowSetup)
			.lShowSetup 		= This.lShowSetup
		ENDIF

		IF NOT ISNULL(This.lShowSearch)
			.lShowSearch 		= This.lShowSearch
		ENDIF

		IF NOT ISNULL(This.lPrintVisible)
			.lPrintVisible		= This.lPrintVisible
		ENDIF

		IF NOT ISNULL(This.lPrinterPref)
			.lPrinterPref		= This.lPrinterPref
		ENDIF

		IF NOT ISNULL(This.nCopies)
			.nCopies 			= This.nCopies
		ENDIF

		IF NOT ISNULL(This.lPrintVisible)
			.lPrintVisible 		= This.lPrintVisible
		ENDIF

		IF NOT ISNULL(This.cDefaultListener)
			.cDefaultListener 	= This.cDefaultListener 
		ENDIF

		IF NOT ISNULL(This.cSuccessor)
			.cSuccessor 	    = This.cSuccessor 
		ENDIF

		IF NOT ISNULL(This.lUseListener)
			.lUseListener 		= This.lUseListener
		ENDIF

		IF NOT ISNULL(This.nCanvasCount)
			.nCanvasCount 		= This.nCanvasCount 
		ENDIF

		IF NOT ISNULL(This.nZoomLevel)
			.nZoomLevel 		= This.nZoomLevel 
		ENDIF

		IF NOT ISNULL(This.oListener)
			.oListener			= This.oListener
		ENDIF

		IF NOT ISNULL(This.cPrinterName)
			.cPrinterName 		= This.cPrinterName
		ENDIF

		IF NOT ISNULL(This.lSaveAsImage)
			.lSaveAsImage		= This.lSaveAsImage
		ENDIF

		IF NOT ISNULL(This.lSaveAsHTML)
			.lSaveAsHTML		= This.lSaveAsHTML
		ENDIF

		IF NOT ISNULL(This.lSaveAsRTF)
			.lSaveAsRTF			= This.lSaveAsRTF
		ENDIF

		IF NOT ISNULL(This.lSaveAsXLS)
			.lSaveAsXLS			= This.lSaveAsXLS
		ENDIF

		IF NOT ISNULL(This.lSaveAsPDF)
			.lSaveAsPDF			= This.lSaveAsPDF
		ENDIF

		IF NOT ISNULL(This.nWindowState)
			.nWindowState		= This.nWindowState
		ENDIF

		IF NOT ISNULL(This.nDockType)
			.nDockType			= This.nDockType
		ENDIF

		IF NOT ISNULL(This.nMaxMiniatureDisplay)
			.nMaxMiniatureDisplay = This.nMaxMiniatureDisplay
		ENDIF

		IF NOT ISNULL(This.nPDFPageMode)
			.nPDFPageMode		= This.nPDFPageMode
		ENDIF

		IF NOT ISNULL(This.nShowToolBar)
			.nShowToolBar		= This.nShowToolBar
		ENDIF

		IF NOT ISNULL(This.lShowPrinters)
			.lShowPrinters      = This.lShowPrinters
		ENDIF
		
		IF NOT ISNULL(This.cFormIcon)
			.cFormIcon  = This.cFormIcon
		ENDIF
		
		IF NOT ISNULL(This.cLanguage)
			.cLanguage  = This.cLanguage
		ENDIF

		IF NOT ISNULL(This.lEmailAuto)
			.lEmailAuto = This.lEmailAuto
		ENDIF

		IF NOT ISNULL(This.cEmailType)
			.cEmailType = This.cEmailType
		ENDIF

		IF NOT ISNULL(This.cEmailPRG)
			.cEmailPRG  = This.cEmailPRG
		ENDIF

		IF NOT ISNULL(This.lEmailed)
			.lEmailed   = This.lEmailed
		ENDIF

		*!* 2010-09-17 - Jacques Parent - Add the cSaveDefName
		IF NOT ISNULL(This.cSaveDefName)
			.cSaveDefName = This.cSaveDefName
		ENDIF

		*!*	IF NOT ISNULL(This.cCodePage)
		*!*		.cCodePage  = This.cCodePage
		*!*	ENDIF

		IF NOT ISNULL(This.nEmailMode)
			.nEmailMode    = This.nEmailMode
		ENDIF

		IF NOT ISNULL(This.cSMTPServer)
			.cSMTPServer   = This.cSMTPServer
		ENDIF

		IF NOT ISNULL(This.nSMTPPort)
			.nSMTPPort     = This.nSMTPPort
		ENDIF

		IF NOT ISNULL(This.lSMTPUseSSL)
			.lSMTPUseSSL   = This.lSMTPUseSSL
		ENDIF

		IF NOT ISNULL(This.cSMTPUserName)
			.cSMTPUserName = This.cSMTPUserName
		ENDIF

		IF NOT ISNULL(This.cSMTPPassword)
			.cSMTPPassword = This.cSMTPPassword
		ENDIF

		IF NOT ISNULL(This.cEmailTo)
			.cEmailTo      = This.cEmailTo
		ENDIF

		IF NOT ISNULL(This.cEmailSubject)
			.cEmailSubject = This.cEmailSubject
		ENDIF

		IF NOT ISNULL(This.cEmailBody)
			.cEmailBody    = This.cEmailBody
		ENDIF

		IF NOT ISNULL(This.cEmailFrom)
			.cEmailFrom    = This.cEmailFrom
		ENDIF

		IF NOT ISNULL(This.nButtonSize)
			.nButtonSize   = This.nButtonSize
		ENDIF
		
		IF NOT ISNULL(This.cDestFile)
			.cDestFile		= This.cDestFile
		ENDIF

		IF NOT ISNULL(This.cEmailCC)
			.cEmailCC 		= This.cEmailCC
		ENDIF

		IF NOT ISNULL(This.cEmailBCC)
			.cEmailBCC 		= This.cEmailBCC
		ENDIF

		IF NOT ISNULL(This.cEmailReplyTo)
			.cEmailReplyTo	= tHIS.cEmailReplyTo
		ENDIF

		IF NOT ISNULL(This.lAutoSendMail)
			.lAutoSendMail	= NOT ISNULL(This.cDestFile) AND This.lAutoSendMail
			._lSendingEmail = .lAutoSendMail
		ENDIF

		IF NOT ISNULL(This.lSilent)
			.lSilent		= This.lSilent
		ENDIF
		
		IF NOT ISNULL(This.lDirectPrint) AND This.lDirectPrint
			.lDirectPrint   = .T.
		ENDIF

		IF NOT ISNULL(This.lSaveAsTXT)
			.lSaveAsTXT	 = This.lSaveAsTXT
		ENDIF

		IF NOT ISNULL(This.cOutputPath)
			.cOutputPath = This.cOutputPath
		ENDIF

		IF NOT ISNULL(This.nPrinterProptype)
			.nPrinterProptype = This.nPrinterProptype
		ENDIF

		IF NOT ISNULL(This.nThermType)
			.nThermType = This.nThermType
		ENDIF

		IF NOT ISNULL(This.nSearchPages)
			.nSearchPages = This.nSearchPages
		ENDIF

		IF NOT ISNULL(THIS.cDecryptProcedure)
			.cDecryptProcedure = THIS.cDecryptProcedure 
		ENDIF
 
		IF NOT ISNULL(THIS.cEncryptProcedure)
			.cEncryptProcedure = THIS.cEncryptProcedure 
		ENDIF

		IF NOT ISNULL(THIS.cCryptKey)
			.cCryptKey = THIS.cCryptKey 
		ENDIF

		IF NOT ISNULL(THIS.lReadReceipt)
			.lReadReceipt = THIS.lReadReceipt 
		ENDIF

		IF NOT ISNULL(THIS.lPriority)
			.lPriority = THIS.lPriority 
		ENDIF

		IF NOT ISNULL(THIS.cEmailBodyFile)
			.cEmailBodyFile = THIS.cEmailBodyFile 
		ENDIF

		IF NOT ISNULL(THIS.lPDFEmbedFonts)
			.lPDFEmbedFonts = THIS.lPDFEmbedFonts
		ENDIF

		IF NOT ISNULL(THIS.lPDFReplaceFonts)
			.lPDFReplaceFonts = THIS.lPDFReplaceFonts
		ENDIF

		IF NOT ISNULL(THIS.lPDFCanPrint)
			.lPDFCanPrint = THIS.lPDFCanPrint
		ENDIF

		IF NOT ISNULL(THIS.lPDFCanEdit)
			.lPDFCanEdit = THIS.lPDFCanEdit
		ENDIF

		IF NOT ISNULL(THIS.lPDFCanCopy)
			.lPDFCanCopy = THIS.lPDFCanCopy
		ENDIF

		IF NOT ISNULL(THIS.lPDFCanAddNotes)
			.lPDFCanAddNotes = THIS.lPDFCanAddNotes
		ENDIF

		IF NOT ISNULL(THIS.lPDFEncryptDocument)
			.lPDFEncryptDocument = THIS.lPDFEncryptDocument
		ENDIF

		IF NOT ISNULL(THIS.cPDFMasterPassword)
			.cPDFMasterPassword = THIS.cPDFMasterPassword
		ENDIF

		IF NOT ISNULL(THIS.cPDFUserPassword)
			.cPDFUserPassword = THIS.cPDFUserPassword
		ENDIF

		IF NOT ISNULL(THIS.lOpenViewer)
			.lOpenViewer = THIS.lOpenViewer
		ENDIF

		IF NOT ISNULL(THIS.cPdfAuthor)
			.cPdfAuthor = THIS.cPdfAuthor
		ENDIF

		IF NOT ISNULL(THIS.cPdfTitle)
			.cPdfTitle = THIS.cPdfTitle
		ENDIF

		IF NOT ISNULL(THIS.cPdfSubject)
			.cPdfSubject = THIS.cPdfSubject
		ENDIF

		IF NOT ISNULL(THIS.cPdfKeyWords)
			.cPdfKeyWords = THIS.cPdfKeyWords
		ENDIF

		IF NOT ISNULL(THIS.cPdfCreator)
			.cPdfCreator = THIS.cPdfCreator
		ENDIF

		IF NOT ISNULL(THIS.lPDFShowErrors)
			.lPDFShowErrors = THIS.lPDFShowErrors
		ENDIF
	
		IF NOT ISNULL(THIS.cPDFSymbolFontsList)
			.cPDFSymbolFontsList = THIS.cPDFSymbolFontsList
		ENDIF

		IF NOT ISNULL(THIS.cAdressTable)
			.cAdressTable = THIS.cAdressTable
		ENDIF

		IF NOT ISNULL(THIS.cAdressSearch)
			.cAdressSearch = THIS.cAdressSearch
		ENDIF

		IF NOT ISNULL(THIS.cAttachments)
			.cAttachments = THIS.cAttachments
		ENDIF

		IF NOT ISNULL(THIS.lShowClose)
			.lShowClose = THIS.lShowClose
		ENDIF

		IF NOT ISNULL(THIS.cPDFDefaultFont)
			.cPDFDefaultFont = THIS.cPDFDefaultFont
		ENDIF

		&& Added in 2011-08-08

		IF NOT ISNULL(This.cImgPrint)
			.cImgPrint = This.cImgPrint
		ENDIF

		IF NOT ISNULL(This.cImgPrintPref)
			.cImgPrintPref = This.cImgPrintPref
		ENDIF

		IF NOT ISNULL(This.cImgSave)
			.cImgSave = This.cImgSave
		ENDIF

		IF NOT ISNULL(This.cImgClose)
			.cImgClose = This.cImgClose
		ENDIF

		IF NOT ISNULL(This.cImgClose2)
			.cImgClose2 = This.cImgClose2
		ENDIF

		IF NOT ISNULL(This.cImgEmail)
			.cImgEmail = This.cImgEmail
		ENDIF

		IF NOT ISNULL(This.cImgSetup)
			.cImgSetup = This.cImgSetup
		ENDIF

		IF NOT ISNULL(This.cImgMiniatures)
			.cImgMiniatures = This.cImgMiniatures
		ENDIF

		IF NOT ISNULL(This.cImgSearch)
			.cImgSearch = This.cImgSearch
		ENDIF

		IF NOT ISNULL(This.cImgSearchAgain)
			.cImgSearchAgain = This.cImgSearchAgain
		ENDIF

		IF NOT ISNULL(This.cImgSearchBack)
			.cImgSearchBack = This.cImgSearchBack
		ENDIF

		IF NOT ISNULL(This.lExpandFields)
			.lExpandFields = This.lExpandFields
		ENDIF

		IF NOT ISNULL(This.cPrintJobName)
			.cPrintJobName = This.cPrintJobName
		ENDIF

*!*			IF NOT ISNULL(THIS.)
*!*				. = THIS.
*!*			ENDIF

		IF NOT ISNULL(THIS.lExcelConvertToXLS)
			.lExcelConvertToXLS = THIS.lExcelConvertToXLS
		ENDIF

		IF NOT ISNULL(THIS.lExcelRepeatHeaders)
			.lExcelRepeatHeaders = THIS.lExcelRepeatHeaders
		ENDIF

		IF NOT ISNULL(THIS.lExcelRepeatFooters)
			.lExcelRepeatFooters = THIS.lExcelRepeatFooters
		ENDIF

		IF NOT ISNULL(THIS.lExcelHidePageNo)
			.lExcelHidePageNo = THIS.lExcelHidePageNo
		ENDIF

		IF NOT ISNULL(THIS.cExcelDefaultExtension)
			.cExcelDefaultExtension = THIS.cExcelDefaultExtension
		ENDIF

		IF NOT ISNULL(THIS.lExcelAlignLeft)
			.lExcelAlignLeft = THIS.lExcelAlignLeft
		ENDIF
		
		IF NOT ISNULL(THIS.lSaveAsMHT)
			.lSaveAsMHT = THIS.lSaveAsMHT
		ENDIF

	ENDWITH

	loReport.RunReport(This) && This flag will tell FoxyPreviewer that it has a caller object in an EXE
			&& The main class will update the properties
			&& "lSaved", "lPrinted", "lEmailed", "nVersion", "cVersion", "cErrors"
ENDPROC 



PROCEDURE DESTROY
	*/ [20100517]... Now supporting Labels also (LBX,LBT) by Nick Porfyris
	* Clean up, delete the temporary FRX, FRT, LBX, LBT, ??X, ??T files...
	LOCAL N, lnCount, lcFile, lcExtension, lcExtension2
	lnCount = THIS._oReports.COUNT
	FOR N = 1 TO lnCount
		lcFile = THIS._oReports(N)
		IF LEFT(JUSTFNAME(lcFile),7) = "TMP_FP_" && We have a temp ??X, ??T files to delete
			TRY
				DELETE FILE (lcFile)
				lcExtension=JUSTEXT(lcFile)
				lcExtension2=STUFF(lcExtension, LEN(lcExtension), 1, [T])
				DELETE FILE FORCEEXT(lcFile, lcExtension2)
			CATCH
			ENDTRY
		ENDIF
	ENDFOR
	
*!*		RELEASE _oReportOutput	&& 2011-08-12 - Jacques Parent - Release this object because I have 
*!*								** seen on some occasion that the FRXPREVIEWFORM form was not release 
*!*								** when used with TOP LEVEL FORM
ENDPROC

ENDDEFINE
