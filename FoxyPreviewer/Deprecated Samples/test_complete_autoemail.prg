MESSAGEBOX("This is a deprecated and UNSUPPORTED sample." + CHR(13) + ;
	"Although it works, the 'PREVIEWHELPER' object is not supported any more!"+ CHR(13) + ;
	"Use this sample at your own risk!", 16, "IMPORTANT")

* This sample shows how you can generate a report silently, and send it to an email
* Allows adding other attachments, see the cAttachments property
* Make sure to provide all the correct SMTP settings

SET PROCEDURE TO LOCFILE("FoxyPreviewer.App") ADDITIVE 
LOCAL loReport as "PreviewHelper" OF "FoxyPreviewer.Prg" 
loReport = CREATEOBJECT("PreviewHelper") 
WITH loReport as ReportHelper 

*!*	REPORT FORM LOCFILE(_Samples + "\Solution\Reports\Percent.frx")  PREVIEW
*!*	REPORT FORM LOCFILE(_Samples + "\Solution\Reports\Invoice.frx")  PREVIEW
*!*	REPORT FORM LOCFILE(_Samples + "\Solution\Reports\Colors.frx")   PREVIEW
*!*	REPORT FORM LOCFILE(_Samples + "\Solution\Reports\Wrapping.frx") PREVIEW

.AddReport(_Samples + "\Solution\Reports\percent.frx", "NODIALOG") 
.cDestFile      = "c:\Teste9.pdf"  && Use to create an output without previewing

.lAutoSendMail  = .T.
.lEmailAuto     = .T.   && Automatically generates the report output file
.cEmailType     = "PDF" && The file type to be used in Emails (PDF, RTF, HTML or XLS)

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

*!*			* Attachments are optional
*!*			IF NOT EMPTY(_goHelper._cAttachment) && "myreport.pdf, myspreadsheet.xls"
*!*				.cAttachment = _goHelper._cAttachment
*!*			ELSE 
*!*				.cAttachment = tcFile
*!*			ENDIF

.RunReport() 
ENDWITH 
loReport = NULL 
* RUN /N Explorer.Exe c:\Teste1.pdf 

RETURN