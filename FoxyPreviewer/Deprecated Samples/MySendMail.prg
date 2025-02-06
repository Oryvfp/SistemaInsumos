LPARAMETERS tcFile

* This sample shows how you can customize your email sending, using your own email
* classes.
* The file to be sent is the one received as parameter.
* If you need to use this file further, 
*   make sure to make a copy of it before exiting this PRG
*   because FoxyPreviewer will delete it automatically.

MESSAGEBOX("File to send by email: " + tcFile, 64)


* In this sample, I'll use a CDO email class from the VFP guru Sergey Berezniker
* http://www.berezniker.com/content/pages/visual-foxpro/cdo-2000-class-sending-emails

* The easiest way to configure CDOSYS is to configure Outlook Express.
* You do not ever need to use it, but if you configure it to send e-mail, 
* CDO has the registry entries it needs so that you do not need to configure it explicitly.

* Replace addresses with real ones before running the code
 
* loMail = NEWOBJECT("Cdo2000", "Cdo2000.fxp")
loMail = CREATEOBJECT("Cdo2000")
 
WITH loMail
	.cServer = "smtp.live.com"
	.nServerPort = 25
	.lUseSSL = .T.
 
	.nAuthenticate = 1 	&& cdoBasic
 	.cUserName = "yourAccount@live.com"
	.cPassword = "yourPassword"
 
	*.cFrom = "yourlAccount@live.com"
 	.cFrom = .cUserName
 
	.cTo = "vfpimaging@hotmail.com" && "somebody@otherdomain.com, somebodyelse@otherdomain.com"
 
	.cSubject = "FOXYPREVIEWER email"
 
	* Uncomment next lines to send HTML body
	*.cHtmlBody = "<html><body><b>This is an HTML body<br>" + ;
	*		"It'll be displayed by most email clients</b></body></html>" 	
 
	.cTextBody = "This is a text body." + CHR(13) + CHR(10) + ;
			"It'll be displayed if HTML body is not present or by text only email clients"
 
	* Attachments are optional
	.cAttachment = tcFile && "myreport.pdf, myspreadsheet.xls"
ENDWITH
 
IF loMail.Send() > 0
	FOR i=1 TO loMail.GetErrorCount()
		? i, loMail.Geterror(i)
	ENDFOR
ELSE
	MESSAGEBOX("Email sent.")
ENDIF

RETURN 



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
 
DEFINE CLASS cdo2000 AS Custom
 
	PROTECTED aErrors[1], nErrorCount, oMsg, oCfg, cXMailer  
 
	nErrorCount = 0
 
	* Message attributes
	oMsg = Null
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
 
	cCharset = ""
 
	* Configuration object fields values
	oCfg = Null
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
 
	PROTECTED PROCEDURE Init
		This.aErrors = Null 
	ENDPROC
 
	* Send message
	PROCEDURE Send
 
		WITH This
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
 
		IF EMPTY(This.cTo) AND EMPTY(This.cCC) AND EMPTY(cBCC)
			This.AddError("ERROR : To,CC and BCC all are Empty.")
		ENDIF
 
		IF This.GetErrorCount() > 0
			RETURN This.GetErrorCount()
		ENDIF
 
		This.SetHeader()
 
		WITH This.oMsg
 
			.From     = This.cFrom
			.ReplyTo  = This.cReplyTo
 
			.To       = This.cTo
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
				FOR lnind=1 TO ALINES(laList, CHRTRAN(This.cAttachment, [,;], CHR(13) + CHR(13)))
					lcAttachment = ALLTRIM(laList[lnind])
					* Ignore empty values
					IF EMPTY(laList[lnind])
						LOOP
					ENDIF
 
					* Make sure that attachment exists
					IF ADIR(laDummy, lcAttachment) = 0
						This.AddError("ERROR: Attacment not Found - " + lcAttachment)
					ELSE
						* The full path is required.
						IF 	UPPER(lcAttachment) <> UPPER(FULLPATH(lcAttachment))
							lcAttachment = FULLPATH(lcAttachment)
						ENDIF
						.AddAttachment(lcAttachment)
					ENDIF
				ENDFOR
			ENDIF
 
			IF NOT EMPTY(This.cCharset)
				.BodyPart.Charset = This.cCharset
			ENDIF
 
		ENDWITH
 
 
		IF This.GetErrorCount() > 0
			RETURN This.GetErrorCount()
		ENDIF
 
		This.oMsg.Send()
 
		RETURN This.GetErrorCount()
 
	ENDPROC
 
	* Clear errors collection
	PROCEDURE ClearErrors()
		This.nErrorCount = 0
		DIMENSION This.aErrors[1]
		This.aErrors[1] = Null
		RETURN This.nErrorCount
	ENDPROC
 
	* Return # of errors in the error collection
	PROCEDURE GetErrorCount
		RETURN This.nErrorCount
	ENDPROC
 
	* Return error by index
	PROCEDURE GetError
		LPARAMETERS tnErrorno
		IF	tnErrorno <= This.GetErrorCount()
			RETURN This.aErrors[tnErrorno]
		ELSE
			RETURN Null
		ENDIF
	ENDPROC
 
	* Populate configuration object
	PROTECTED PROCEDURE SetConfiguration
 
		* Validate supplied configuration values
		IF EMPTY(This.cServer)
			This.AddError("ERROR: SMTP Server isn't specified.")
		ENDIF
		IF NOT INLIST(This.nAuthenticate, cdoAnonymous, cdoBasic)
			This.AddError("ERROR: Invalid Authentication protocol ")
		ENDIF
		IF This.nAuthenticate = cdoBasic ;
				AND (EMPTY(This.cUserName) OR EMPTY(This.cPassword))
			This.AddError("ERROR: User name/Password is required for basic authentication")
		ENDIF
 
		IF 	This.GetErrorCount() > 0
			RETURN This.GetErrorCount()
		ENDIF
 
		WITH This.oCfg.Fields
 
			* Send using SMTP server
			.Item(cdoSendUsingMethod)       	= cdoSendUsingPort
			.Item(cdoSMTPServer)        		= This.cServer
			.Item(cdoSMTPServerPort)			= This.nServerPort
			.Item(cdoSMTPConnectionTimeout)	 	= This.nConnectionTimeout
 
			.Item(cdoSMTPAuthenticate)  		= This.nAuthenticate
			IF This.nAuthenticate = cdoBasic
				.Item(cdoSendUserName)    	  	= This.cUserName
				.Item(cdoSendPassword)    	  	= This.cPassword
			ENDIF
			.Item(cdoURLGetLatestVersion) 	  	= This.lURLGetLatestVersion
			.Item(cdoSMTPUseSSL) 				= This.lUseSSL
 
			.Update()
		ENDWITH
 
		RETURN This.GetErrorCount()
 
	ENDPROC
 
	*----------------------------------------------------
	* Add message to the error collection
	PROTECTED PROCEDURE AddError
		LPARAMETERS tcErrorMsg
		This.nErrorCount = This.nErrorCount + 1
		DIMENSION This.aErrors[This.nErrorCount]
		This.aErrors[This.nErrorCount] = tcErrorMsg
		RETURN This.nErrorCount
	ENDPROC
 
	*----------------------------------------------------
	* Format an error message and add to the error collection
	PROTECTED PROCEDURE AddOneError
		LPARAMETERS tcPrefix, tnError, tcMethod, tnLine 
		LOCAL lcErrorMsg, laList[1]
		IF INLIST(tnError, 1427,1429)
			AERROR(laList)
			lcErrorMsg = TRANSFORM(laList[7], "@0") + ;
				"  " + laList[4]  + "  " + laList[3]
		ELSE
			lcErrorMsg = MESSAGE()
		ENDIF
		This.AddError(tcPrefix + ":" + TRANSFORM(tnError) + " # " + ;
			tcMethod + " # " + TRANSFORM(tnLine) + " # " + lcErrorMsg)
		RETURN This.nErrorCount
	ENDPROC
 
	*----------------------------------------------------
	* Simple Error handler. Adds VFP error to the objects error collection
	PROTECTED PROCEDURE Error
		LPARAMETERS tnError, tcMethod, tnLine
		*!*			This.AddError("VFP Error: " + TRANSFORM(tnError) + " # " + ;
		*!*				tcMethod + " # " + TRANSFORM(tnLine) + " # " + MESSAGE())
		This.AddOneError("ERROR: ", tnError, tcMethod, tnLine )
		RETURN This.nErrorCount
	ENDPROC
 
	*-------------------------------------------------------
	* Set mail header fields, if necessary. For now sets X-MAILER, if specified
	PROTECTED PROCEDURE SetHeader
		LOCAL loHeader
		IF NOT EMPTY(This.cXMailer)
			loHeader = This.oMsg.Fields
			WITH loHeader
				.Item(cdoXMailer) =  This.cXMailer
				.Update()
			ENDWITH
		ENDIF
	ENDPROC
 
ENDDEFINE
