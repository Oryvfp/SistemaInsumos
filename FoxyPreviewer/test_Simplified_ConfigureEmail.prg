* This sample shows how you can configure lots of email options, in order to determine how
* your reports will be sent by email
* Allows adding other attachments, see the cAttachments property
* Make sure to provide all the correct SMTP settings, the provided here are just samples

DO LOCFILE("FoxyPreviewer.App")

WITH _Screen.oFoxyPreviewer

	*!*	REPORT FORM LOCFILE(_Samples + "\Solution\Reports\Percent.frx")  PREVIEW
	*!*	REPORT FORM LOCFILE(_Samples + "\Solution\Reports\Invoice.frx")  PREVIEW
	*!*	REPORT FORM LOCFILE(_Samples + "\Solution\Reports\Colors.frx")   PREVIEW
	*!*	REPORT FORM LOCFILE(_Samples + "\Solution\Reports\Wrapping.frx") PREVIEW

	.cDestFile      = "c:\Teste9.pdf"  && Use to create an output without previewing

	.lEmailAuto     = .T.   && Automatically generates the report output file
	.cEmailType     = "PDF" && The file type to be used in Emails (PDF, RTF, HTML or XLS)
	.nEmailMode     = 2     && 1 = MAPI, 2 = CDOSYS HTML, 3 = CDOSYS TEXT, 4 = Custom procedure

	.cEmailTo       = "TestDest@uol.com.br"
	.cSMTPServer    = "smtps.uol.com.br"
	.cEmailFrom     = "name@uol.com.br"
	.cEmailSubject  = "Subject test"

	.nSMTPPort      = 465
	.lSMTPUseSSL    = .T.
	.cSMTPUserName  = "name@uol.com.br"
	.cSMTPPassword  = "password"

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
	*!* .cTextBody = _goHelper.cEmailBody
	*!* && "This is a text body." + CHR(13) + CHR(10) + ;
	*!* && "It'll be displayed if HTML body is not present or by text only email clients"

	.cEmailBody = "<HTML><BR>Email Test with <b>FoxyPreviewer</b></HTML>"

	REPORT FORM (_Samples + "\Solution\Reports\percent.frx") PREVIEW

ENDWITH