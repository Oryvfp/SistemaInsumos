LPARAMETERS tcSource, tcDestination

IF EMPTY(tcSource)
	tcSource = GETFILE("xml", "Spreadsheet file")
ENDIF
IF EMPTY(tcSource)
	RETURN
ENDIF

IF EMPTY(tcDestination)
	tcDestination = FORCEEXT(tcSource, "xls")
ENDIF


* Create a spreadsheet.
LOCAL oDoc

* oDoc = OOoOpenURL( "private:factory/scalc" )
oDoc = OOoOpenURL(OOoConvertToURL(tcSource))

LOCAL ARRAY aOneArg[1]
LOCAL cFile, cURL

*!*	   * Now save the spreadsheet.
*!*	   cURL = OOoConvertToURL( cFile + ".ods" )
*!*	   aOneArg[1] = OOoMakePropertyValue( "Overwrite", .T. )
*!*	   oDoc.storeToUrl( cURL, @ aOneArg )

* Now save it as Excel
cURL = OOoConvertToURL(tcDestination)
aOneArg[1] = OOoMakePropertyValue( "FilterName", "MS Excel 97" )
oDoc.storeToUrl( cURL, @ aOneArg )

* Close the document.
oDoc.close( 1 ) && TRUE
oDoc = NULL
RELEASE oDoc 

RETURN 


* Open or Create a document from it's URL.
* New documents are created by URL's such as:
*   private:factory/sdraw
*   private:factory/swriter
*   private:factory/scalc
*   private:factory/simpress
FUNCTION OOoOpenURL( cURL )
	*   LOCAL oPropertyValue
	*   oPropertyValue = OOoCreateStruct( "com.sun.star.beans.PropertyValue" )

	*   LOCAL ARRAY aNoArgs[1]
	*   aNoArgs[1] = oPropertyValue
	*   aNoArgs[1].Name = "ReadOnly"
	*   aNoArgs[1].Value = .F.

	* These two lines replace the alternate version above,
	*  which are left commented for the insight they provide.
	LOCAL ARRAY aNoArgs[1]

	* To make the conversion work in Visible mode
	* aNoArgs[1] = OOoMakePropertyValue( "Hidden", .F. )

	aNoArgs[1] = OOoMakePropertyValue( "Hidden", .T. )

	LOCAL oDesktop
	oDesktop = OOoGetDesktop()

	LOCAL oDoc
	oDoc = oDesktop.LoadComponentFromUrl( cURL, "_blank", 0, @ aNoArgs )

	* ODesk.loadComponentFromURL "file:///c|/aswin/objun.dbf", "_blank", 0, ;
	*	Array(MakePropertyValue("FilterName", "dBase"), MakePropertyValue("Hidden", False))

	* Make sure that arrays passed to this document are passed zero based.
	COMARRAY( oDoc, 10 )

	RETURN oDoc
ENDFUNC


* Create a com.sun.star.beans.PropertyValue struct and return it.
FUNCTION OOoMakePropertyValue( cName, uValue, nHandle, nState )
	LOCAL oPropertyValue
	oPropertyValue = OOoCreateStruct( "com.sun.star.beans.PropertyValue" )

	oPropertyValue.Name = cName
	oPropertyValue.Value = uValue

	IF TYPE([nHandle])="N"
		oPropertyValue.Handle = nHandle
	ENDIF
	IF TYPE([nState])="N"
		oPropertyValue.State = nState
	ENDIF

	RETURN oPropertyValue
ENDFUNC


* Sugar coated routine to create any UNO struct.
* Use the Bridge_GetStruct() feature of the OLE-UNO bridge.
FUNCTION OOoCreateStruct( cTypeName )
	LOCAL oServiceManager
	oServiceManager = OOoGetServiceManager()

	LOCAL oStruct
	oStruct = .NULL.

	LOCAL cOldErrHandler
	cOldErrHandler = ON( "ERROR" )
	ON ERROR = DoNothing__ErrorHandler( ERROR(), MESSAGE(), LINENO(), SYS(16), PROGRAM(), SYS(2018) )
	oStruct = oServiceManager.Bridge_GetStruct( cTypeName )
	ON ERROR &cOldErrHandler

	IF ISNULL( oStruct )
		=__OOoReleaseCachedVars()
		oServiceManager = OOoGetServiceManager()
		oStruct = oServiceManager.Bridge_GetStruct( cTypeName )
	ENDIF

	RETURN oStruct
ENDFUNC


* Return the OpenOffice.org desktop object.
* Cache it in a global variable.
* Create it if not already cached.
FUNCTION OOoGetDesktop()
	IF (TYPE([goOOoDesktop])!="O")  OR  ISNULL( goOOoDesktop )
		PUBLIC goOOoDesktop
		goOOoDesktop = OOoServiceManager_CreateInstance( "com.sun.star.frame.Desktop" )
		COMARRAY( goOOoDesktop, 10 )
	ENDIF
	RETURN goOOoDesktop
ENDFUNC


* Return the OpenOffice.org service manager object.
* Cache it in a global variable.
* Create it if not already cached.
FUNCTION OOoGetServiceManager()
	IF (TYPE([goOOoServiceManager])!="O")  OR  ISNULL( goOOoServiceManager )
		PUBLIC goOOoServiceManager
		goOOoServiceManager = CREATEOBJECT( "com.sun.star.ServiceManager" )
	ENDIF
	RETURN goOOoServiceManager
ENDFUNC


* Sugar coated routine to ask the service manager to
*  create you an instance of some other OpenOffice.org UNO object.
FUNCTION OOoServiceManager_CreateInstance( cServiceName )
	LOCAL oServiceManager
	oServiceManager = OOoGetServiceManager()

	LOCAL oInstance
	oInstance = .NULL.

	LOCAL cOldErrHandler
	cOldErrHandler = ON( "ERROR" )
	ON ERROR = DoNothing__ErrorHandler( ERROR(), MESSAGE(), LINENO(), SYS(16), PROGRAM(), SYS(2018) )
	oInstance = oServiceManager.createInstance( cServiceName )
	ON ERROR &cOldErrHandler

	IF ISNULL( oInstance )
		=__OOoReleaseCachedVars()
		oServiceManager = OOoGetServiceManager()
		oInstance = oServiceManager.createInstance( cServiceName )
	ENDIF
	RETURN oInstance
ENDFUNC


PROCEDURE DoNothing__ErrorHandler( pnError, pcErrMessage, pnLineNo, pcProgramFileSys16, pcProgram, pcErrorParamSys2018 )
ENDPROC


PROCEDURE __OOoReleaseCachedVars()
	RELEASE goOOoServiceManager, goOOoDesktop, goOOoCoreReflection
ENDPROC


* Convert a local filename to an OOo URL.
FUNCTION OOoConvertToURL( cFilename )
	* Ensure leading slash.
	IF LEFT( cFilename, 1 ) != "/"
		cFilename = "/" + cFilename
	ENDIF

	LOCAL cURL
	cURL = CHRTRAN( cFilename, "\", "/" )   && change backslashes to forward slashes.
	cURL = "file://" + cURL
	RETURN cURL
ENDFUNC