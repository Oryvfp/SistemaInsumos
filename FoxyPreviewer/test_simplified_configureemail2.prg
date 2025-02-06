* This sample shows how you can configure lots of email options, in order to determine how
* your reports will be sent by email
* Allows adding other attachments, see the cAttachments property
* Make sure to provide all the correct SMTP settings, the provided here are just samples

* Several email settings
* http://www.emailaddressmanager.com/tips/mail-settings.html

IF VARTYPE(_Screen.oFoxyPreviewer) <> "O"
	DO LOCFILE("FoxyPreviewer.App")
ENDIF 

WITH _Screen.oFoxyPreviewer
	.cLanguage      = "FRANÇAIS"

	.cEmailTo       = "foxypreviewer@hotmail.com"
	.lEmailAuto     = .T.   && Automatically generates the report output file
	.cEmailType     = "PDF" && The file type to be used in Emails (PDF, RTF, HTML or XLS)
	.nEmailMode     = 2     && 1 = MAPI, 2 = CDOSYS HTML, 3 = CDOSYS TEXT, 4 = Custom procedure

*!*		* UOL
*!*		.cSMTPServer    = "smtps.uol.com.br"   &&  "smtp.live.com"  
*!*		.cEmailFrom     = "cchvfp@uol.com.br"
*!*		.cEmailSubject  = "Subject test"
*!*		.nSMTPPort      = 587 && 25
*!*		.lSMTPUseSSL    = .F. && .T.
*!*		* .cSMTPUserName  = "FoxyPreviewer testing emails<cchvfp@uol.com.br>"
*!*		.cSMTPUserName  = "cchvfp@uol.com.br"
*!*		.cSMTPPassword  = "**********"

*!*		* HOTMAIL
*!*		.cSMTPServer    = "smtp.live.com"  
*!*		.cEmailFrom     = "cchalom@hotmail.com"
*!*		.cEmailSubject  = "Subject test"
*!*		.nSMTPPort      = 25   && 587 
*!*		.lSMTPUseSSL    = .T.  && .F.
*!*		.cSMTPUserName  = "cchalom@hotmail.com"
*!*		.cSMTPPassword  = "**********"

	* GMAIL
	.cSMTPServer    = "smtp.gmail.com"  
	.cEmailFrom     = "foxypreviewer@gmail.com"
	.cEmailSubject  = "Subject test"
	.nSMTPPort      = 465
	.lSMTPUseSSL    = .T.
	.cSMTPUserName  = "foxypreviewer@gmail.com"
*	.cSMTPUserName  = "FoxyPreviewer support<foxypreviewer@gmail.com>"  && DOes not work with GMAIL server
	.cSMTPPassword  = "*****"


	.lReadReceipt   = .T.
	.lPriority      = .T.

	.cAttachments   = GETFILE() && Comma delimited

	* Other possible properties
	*!*	.cEmailCC
	*!*	.cEmailBCC
	*!*	.cEmailReplyTo

	*!* * Uncomment next lines to send HTML body
	*!* *.cHtmlBody = "<html><body><b>This is an HTML body<br>" + ;
	*!* *		"It'll be displayed by most email clients</b></body></html>"
	*!*
	*!* .cTextBody = loFP.cEmailBody
	*!* && "This is a text body." + CHR(13) + CHR(10) + ;
	*!* && "It'll be displayed if HTML body is not present or by text only email clients"

	.cEmailBody = "<HTML><BR>Email Test with <b>FoxyPreviewer</b></HTML>"
	REPORT FORM (_Samples + "\Solution\Reports\percent.frx") OBJECT TYPE 10 TO FILE "c:\Temp\Email1.pdf"

	* Now we can send the file we created by email !
	.SendEmailUsingCDO("c:\Temp\Email1.pdf")

ENDWITH

RETURN
