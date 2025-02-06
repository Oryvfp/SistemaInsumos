MESSAGEBOX("This sample uses the new adress book available for the Send email form." + CHR(13) + ;
	"To make it work, make sure to:" + CHR(13) + CHR(13) + ;
	"- Run your report, click the settings button" + CHR(13) + ;
	"- Select the Email tab" + CHR(13) + ;
	"- Select the CDO-HTML email type" + CHR(13) + ;
	"- Configure your SMTP settings properly.", 64, "Attention")

DO LOCFILE("FoxyPreviewer.App")


* Creating a table with the adress book
SELECT CAST(LOWER(GETWORDNUM(Contact, 1, " "))+"@vfp4.com" AS C(30)) As email,* FROM (_samples + '\data\customer') ;
	WHERE .T. INTO TABLE c:\Temp\Test2 READWRITE
* Make sure to clear this alias, forcing FoxyPreviewer to look for the emails table
USE IN SELECT("Test2")
USE IN SELECT("Customer")

* You could create a cursor as well, but
* you'll take care to leave this cursor opened all time, for all 
* FoxyPreviewer sessions to work with it.
* SELECT CAST(LOWER(GETWORDNUM(Contact, 1, " "))+"@vfp2.com" AS C(30)) As email,* FROM (_samples + '\data\customer') ;
	WHERE .T. INTO CURSOR Test READWRITE


* Setting the global properties
_Screen.oFoxyPreviewer.cAdressTable  = "c:\Temp\Test2.dbf"
_Screen.oFoxyPreviewer.cAdressSearch = "Contact"  && Optional
_Screen.oFoxyPreviewer.cEmailTo      = "test@foxypreviewer.org"  && Optional

REPORT FORM (_Samples + "\Solution\Reports\percent.frx") PREVIEW 

* Clear the Adress cursor
* USE IN SELECT("Test")