LPARAMETERS tcFile, tcFaxNumber, tcHTMLBody, tcSubject
 
* Where:
* tcFile = the file name that brings your report
* tcFaxNumber = the fax number that your client will fill in the email field in the email form
* tcHTMLBody = the text that your client wrote in the email form
* tcSubject = the subject filled

* Add here your faxing procedure !

* This procedure will be called by FoxyPreviewer, from the SendEmail using CDO form
* Uses the new property: 'cFaxPRG', character, the name of the Faxing PRG to be called, allowing sending faxes from FoxyPreviewer using your custom Faxing procedures. Notice that FOxyPreviewer does not bring any internal code to manage faxes. With this property, I'm just opening a "door" to allow you to receive some ifo from FoxyPreviewer and send your documents using your Faxing app.
* To make Foxy show a "Send to fax" button in the email form, you need to fill the property “cFAXprg”, with the name of a PRG that will be responsible of sending the fax, for example:
* _Screen.oFoxyPreviewer.cFaxPrg = "mySendFax.prg"

MESSAGEBOX("File: " + tcFile + CHR(13) + ;
		"Fax: " + tcFaxNumber + CHR(13) + ;
		"Body: " + tcHTMLBody + CHR(13) + ;
		"Subject: " + tcSubject)