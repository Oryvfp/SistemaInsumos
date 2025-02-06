DEFINE CLASS GPATTRIB AS CUSTOM
	PROTECTED gdipHandle
	PROTECTED Stat
	gdipHandle = 0
	Stat = 0

PROCEDURE Init
*!*	IMAGE ATTRIBUTES
	DECLARE INTEGER GdipCreateImageAttributes IN gdiplus.dll ;
		INTEGER @ImgAttr

	IF This.GdipHandle <> 0
		This.DisposeImageAttributes(This.GdipHandle)
	ENDIF 
	LOCAL lhImageAttr
	lhImageAttr = 0
	This.Stat = GdipCreateImageAttributes(@lhImageattr)
	This.GdipHandle = lhImageAttr

	DECLARE INTEGER GdipSetImageAttributesColorMatrix IN gdiplus.dll ;
		INTEGER imageattr, ;
		INTEGER ColorAdjustType, ;
		INTEGER enableFlag, ;
		STRING  colorMatrix, ;
		INTEGER grayMatrix, ;
		INTEGER ColorMatrixFlags

	DECLARE INTEGER GdipSetImageAttributesRemapTable IN gdiplus.dll ;
		INTEGER imageattr, ;
		INTEGER ColorAdjustType, ;
		INTEGER enableFlag, ;
		INTEGER mapsize, ;
		STRING  colorMap
ENDPROC


PROCEDURE GetHandle
	RETURN This.gdipHandle
ENDPROC 

PROTECTED Procedure stat_Assign(tnStatus)
	If tnStatus != 0
			Local lnOption
			lnOption = MessageBox("GDI+ error in " + Program(Program(-1) - 1) + CRLF;
				+ "Error code : " + Transform(tnStatus) + CRLF ;
				+ "Description: " + This.ErrorInfo(tnStatus) + CRLF + CRLF;
				+ "Press 'Retry' to debug the application.", 16 + 2, "Error")
		If lnOption = 3
			Cancel
		EndIf
		If lnOption = 4
			Suspend
		EndIf
	EndIf
	This.stat = tnStatus
ENDPROC

PROCEDURE Destroy
	IF This.GdipHandle <> 0
		This.DisposeImageAttributes(This.GdipHandle)
	ENDIF 
ENDPROC


*!*	IMAGE ATTRIBUTES

PROCEDURE SetColorMatrix(taColMatrix)
	*!*	The enableFlag parameter in the flat function is a Boolean value 
	*!*	that specifies whether a separate color adjustment is enabled for
	*!*	the category specified by the type parameter. SetColorMatrix sets
	*!*	enableFlag to TRUE, and ClearColorMatrix sets enableFlag to FALSE.

	*!*	The grayMatrix parameter specifies a matrix to be used for adjusting 
	*!*	gray shades when the value of the flags parameter is ColorMatrixFlagsAltGray.

	LOCAL lcColorMatrix
	IF VARTYPE(taColMatrix) = "C" && already defined by COLORMATRIX function
		lcColorMatrix = taColMatrix
	ELSE
		lcColorMatrix = This.MakeColorMatrix(@taColMatrix)
	ENDIF 
		
	This.Stat = GdipSetImageAttributesColorMatrix(This.GdipHandle, ;
		0, ;
		1, ;
		lcColorMatrix, ;
		0, ;
		0)
ENDPROC 

PROCEDURE SetGamma(tnGamma)
	DECLARE LONG GdipSetImageAttributesGamma IN GDIPLUS.dll ;
		LONG imageattr, LONG ClrAdjType, LONG enableFlag, SINGLE gamma
	This.Stat = GdipSetImageAttributesGamma(This.GdipHandle, ;
		0, ;
		1, ;
		tnGamma)
ENDPROC 

PROCEDURE ApplyImageAttribute(toImage)
	LOCAL lnWidth, lnHeight, lnNativeImage
	lnWidth  = 0
	lnHeight = 0

	DO CASE 
		CASE VARTYPE(m.toImage) = "O"
			lnNativeImage = toImage.GetHandle()
		CASE VARTYPE(m.toImage) = "N"
			lnNativeImage = toImage
		OTHERWISE 
			ERROR 11 && function argument
			RETURN .F.
	ENDCASE 

	DECLARE Long GdipGetImageWidth in GdiPlus.dll ;
		Long nativeImage, Long @ width
	DECLARE Long GdipGetImageHeight in GdiPlus.dll ;
		Long nativeImage, Long @ height

	This.stat = GdipGetImageWidth(lnNativeImage, @lnWidth)
	This.stat = GdipGetImageHeight(lnNativeImage, @lnHeight)
	This.DrawImageRectRect(lnNativeImage,0,0,lnWidth,lnHeight,0,0,lnWidth,lnHeight)
ENDPROC 


PROCEDURE DrawImageRectRect(tnImage, ;
		dstx, dsty, dstwidth, dstheight, ;
		srcx, srcy, srcwidth, srcheight)

	LOCAL lnScrUnit, lhGfx
	lnSrcUnit = 2 && GraphicsUnit:Pixel

	*!*	We need to obtain the graphics handle to overwrite the image
	lhGfx = 0
	DECLARE Long GdipGetImageGraphicsContext in GdiPlus.dll ;
			Long image, Long @ graphics
	This.Stat = GdipGetImageGraphicsContext(m.tnImage, @lhGfx)

	DECLARE INTEGER GdipDrawImageRectRect IN gdiplus.dll ;
		INTEGER Graphics, INTEGER nImage, ;
		SINGLE dstx, SINGLE dsty, SINGLE dstwidth, SINGLE dstheight, ;
		SINGLE srcx, SINGLE srcy, SINGLE srcwidth, SINGLE srcheight, ;
		INTEGER srcUnit, INTEGER imageAttributes, ;
		INTEGER Callback, INTEGER CallbackData			
	This.Stat = GdipDrawImageRectRect(lhGfx, tnImage, ;
		m.dstx, m.dsty, m.dstwidth, m.dstheight, ;
		m.srcx, m.srcy, m.srcwidth, m.srcheight, ;
		m.lnSrcUnit, This.GdipHandle, 0, 0)

	DECLARE INTEGER GdipDeleteGraphics IN GdiPlus.dll ;
		INTEGER graphics 		
	This.Stat = GdipDeleteGraphics(lhGfx)
ENDPROC 	


PROCEDURE RemapTable(tnOldColor, tnNewColor, tnOldAlpha, tnNewAlpha)
	LOCAL lnArgbOld, lnArgbNew, lcColorMap
	IF PCOUNT() = 1 AND VARTYPE(tnOldColor) = "N" && Array of Colors is expected
		lcColorMap = MakeColorMap(@tnOldColor)			
	ELSE
		IF PCOUNT() = 2 && Ignore Alpha = 255 - opaque
			tnOldAlpha = 255
			tnNewAlpha = 255
		ENDIF 
		IF VARTYPE(tnOldColor) + VARTYPE(tnNewColor) <> "NN"
			ERROR 11
		ENDIF 
		lnArgbOld = This.MakeArgb(tnOldColor, tnOldAlpha)
		lnArgbNew = This.MakeArgb(tnNewColor, tnNewAlpha)
		lcColorMap = BINTOC(lnArgbOld, "2RS") + BINTOC(lnArgbNew, "2RS")
	ENDIF
	This.Stat = GdipSetImageAttributesRemapTable(This.GdipHandle, 0 ,1, (LEN(lcColorMap)/4), lcColorMap)
ENDPROC


PROCEDURE DisposeImageAttributes(tnImgAttributes)
	DECLARE INTEGER GdipDisposeImageAttributes IN GdiPlus.dll ;
		INTEGER imageattr
	This.Stat = GdipDisposeImageAttributes(tnImgAttributes)
	This.GdipHandle = 0
ENDPROC 

*!*	PROCEDURE ResetImageAttributes(tnImgAttributes)
*!*		DECLARE INTEGER GdipResetImageAttributes IN gdiplus.dll ; 
*!*			INTEGER imageattr, INTEGER ColorAdjustType
*!*		This.Stat = GdipResetImageAttributes(tnImgAttributes, 0)
*!*		This.GdipHandle = 0
*!*	ENDPROC 

FUNCTION MultiplyColorMatrix(tcColMatr1, tcColMatr2)
	DIMENSION CM1(5,5), CM2(5,5), CMResult(5,5), CVal(5)
	
	x = 1
	FOR n = 1 TO 25
		y = INT((n-1)/5) + 1
		CM1(y,x) = F2INT2(SUBSTR(tcColMatr1,(((n-1)*4)+1),4))
		x = x + 1
		IF x = 6
			x = 1
		ENDIF 
	NEXT 
	
	x = 1
	FOR n = 1 TO 25
		y = INT((n-1)/5) + 1
		CM2(y,x) = F2INT2(SUBSTR(tcColMatr2,(((n-1)*4)+1),4))
		x = x + 1
		IF x = 6
			x = 1
		ENDIF 
	NEXT 
	
	LOCAL i, j, k
	FOR j = 1 TO 5
		FOR k = 1 TO 5
			CVal(k) = CM1(k, j)
		NEXT
		FOR i = 1 TO 5
			sum = 0
			FOR k = 1 TO 5
				SUM = sum + CM2(i, k) * CVal(k)
			NEXT
			CMResult(i, j) = sum
		NEXT
	NEXT 
	RETURN This.MAKECOLORMATRIX(@CMResult)
ENDFUNC

FUNCTION POINTF(X,Y)
	RETURN BINTOC(X, "4RS") + BINTOC(Y, "4RS")
ENDFUNC 

FUNCTION RECTF(tnX, tnY, tnWIDTH, tnHEIGHT)
	RETURN BINTOC(tnX, "4RS") + BINTOC(tnY, "4RS") + ;
		BINTOC(tnWidth, "4RS") + BINTOC(tnHeight, "4RS")
ENDFUNC 

FUNCTION MAKEARGB(tnColor, tnAlpha)  && Alexander GolovLev
	LOCAL lnArgb, lnRed, lnGreen, lnBlue
	lnBlue  = BITRSHIFT(BITAND(tnColor, 0x00FF0000), 16)
	lnGreen = BITRSHIFT(BITAND(tnColor, 0x0000FF00), 8)
	lnRed   = BITAND(tnColor, 0x000000FF)
	lnArgb  = lnBlue + BITLSHIFT(lnGreen, 8) + BITLSHIFT(lnRed, 16)
	IF VARTYPE(tnAlpha) = 'N'
		lnArgb = lnArgb + BITLSHIFT(BITAND(tnAlpha, 0xFF), 24)
	ELSE
		lnArgb = lnArgb + BITLSHIFT(255, 24)
	ENDIF
	RETURN lnArgb
ENDFUNC 

FUNCTION MakePointsFSequence(taIntPoints)
	*** Creates a String containing all PointsF of the received array
	EXTERNAL ARRAY taIntPoints
	LOCAL lcPointsFSequence, lcPointF, n
	lcPointsFSequence = ""
	FOR n = 1 TO ALEN(taIntPoints,1)
		lcPointF = PointF(taIntPoints(n,1), taIntPoints(n,2))
		lcPointsFSequence = lcPointsFSequence + lcPointF
	ENDFOR
	RETURN lcPointsFSequence
ENDFUNC 

FUNCTION MakeColorMatrix(taColMatrix)
*** Creates a String containing ColorMatrix from the 5x5 received array
	EXTERNAL ARRAY taColMatrix
	LOCAL lcColorMatrix, nRow, nCol
	lcMatrix = ""
	FOR nRow = 1 TO 5
		FOR nCol = 1 TO 5
			lcMatrix = lcMatrix + BINTOC(taColMatrix(nRow, nCol), "F")
		ENDFOR 
	ENDFOR
	RETURN lcMatrix
ENDFUNC

FUNCTION ColorMatrix(tm11, tm12, tm13, tm14, tm15, ;
					 tm21, tm22, tm23, tm24, tm25, ;
					 tm31, tm32, tm33, tm34, tm35, ;
					 tm41, tm42, tm43, tm44, tm45, ;
					 tm51, tm52, tm53, tm54, tm55)
	IF PCOUNT() <> 25
		ERROR 11
	ENDIF
	*** Creates a String containing ColorMatrix from the 5x5 received array
	RETURN (BINTOC(tm11, "F") + BINTOC(tm12, "F") + BINTOC(tm13, "F") + BINTOC(tm14, "F") + BINTOC(tm15, "F") + ;
			BINTOC(tm21, "F") + BINTOC(tm22, "F") + BINTOC(tm23, "F") + BINTOC(tm24, "F") + BINTOC(tm25, "F") + ;
			BINTOC(tm31, "F") + BINTOC(tm32, "F") + BINTOC(tm33, "F") + BINTOC(tm34, "F") + BINTOC(tm35, "F") + ;
			BINTOC(tm41, "F") + BINTOC(tm42, "F") + BINTOC(tm43, "F") + BINTOC(tm44, "F") + BINTOC(tm45, "F") + ;
			BINTOC(tm51, "F") + BINTOC(tm52, "F") + BINTOC(tm53, "F") + BINTOC(tm54, "F") + BINTOC(tm55, "F"))
ENDFUNC

FUNCTION MakeColorMap(taColorMap)
*** Creates a String containing ColorMap from the 4 column Array
	EXTERNAL ARRAY taColorMap
	LOCAL lcColorMap, n, lnArgbOld, lnArgbNew
	lcColorMap = ""
	FOR n = 1 TO ALEN(taColorMap,1)
		lnargbOld = This.MakeArgb(taColorMap(n,1), taColorMap(n,3))
		lnargbNew = This.MakeArgb(taColorMap(n,2), taColorMap(n,4))
		lcColorMap = lcColorMap + BINTOC(lnArgbOld, "4RS") + BINTOC(lnArgbNew, "4RS")
	ENDFOR
	RETURN lcColorMap
ENDFUNC


* FUNCTION ApplyColorMatrix(tcClrMatrix AS Character, ;
				toBmp, ;
				tiFormat AS EnumPixelFormat)

FUNCTION ApplyColorMatrix(tcClrMatrix AS Character, ;
				toBmp as GpBitmap OF HOME() + "\ffc\_gdiPlus.vcx", ;
				tiFormat AS EnumPixelFormat, ;
				tnBackColor)

	This.SetColorMatrix(tcClrMatrix)

	LOCAL lnWidth, lnHeight
	lnWidth  = toBmp.ImageWidth 
	lnHeight = toBmp.ImageHeight

	#define	GDIPLUS_PIXELFORMAT_32bppARGB      	0x0026200A
	m.tiFormat = EVL(m.tiFormat, GDIPLUS_PIXELFORMAT_32bppARGB)

	LOCAL loNewBmp AS GpBitmap OF HOME() + "\ffc\_gdiPlus.vcx"
	loNewBmp = CREATEOBJECT("GpBitmap")
	loNewBmp.Create(lnWidth, lnHeight, tiFormat)

	LOCAL loGfx AS GpGraphics OF HOME() + "\ffc\_gdiPlus.vcx"
	loGfx = CREATEOBJECT("GpGraphics")
	loGfx.CreateFromImage(loNewBmp)
	
	#DEFINE ARGB_Transparent    16777215 
	IF PCOUNT() = 4 AND tnBackColor > 0
		loGfx.Clear(tnBackColor)
	ELSE 
		loGfx.Clear(ARGB_Transparent)
	ENDIF 
	

	LOCAL lnScrUnit, lhGfx
	lnSrcUnit = 2 && GraphicsUnit:Pixel

	DECLARE INTEGER GdipDrawImageRectRect IN gdiplus.dll ;
		INTEGER Graphics, INTEGER nImage, ;
		SINGLE dstx, SINGLE dsty, SINGLE dstwidth, SINGLE dstheight, ;
		SINGLE srcx, SINGLE srcy, SINGLE srcwidth, SINGLE srcheight, ;
		INTEGER srcUnit, INTEGER imageAttributes, ;
		INTEGER Callback, INTEGER CallbackData			

	This.Stat = GdipDrawImageRectRect(loGfx.GetHandle(), toBmp.GetHandle(), ;
		0, 0, lnWidth, lnHeight, ;
		0, 0, lnWidth, lnHeight, ;
		m.lnSrcUnit, This.GdipHandle, 0, 0)


	toBmp.SetHandle(loNewBmp.GetHandle())


	IF toBmp.GetHandle() <> 0
		toBmp.Destroy()

		*	loClonedBmp.Clone(toBmp)
		* Bug in FFC class, so we'll do it here using API calls
		LOCAL lhCloned
		lhCloned = 0
		Declare Integer GdipCloneImage In GDIPlus.Dll ;
			integer nImage, integer @nCloneImage
		This.Stat = GdipCloneImage( ;
			loNewBmp.GetHandle() ;
			,	@lhCloned)

*		m.loBmpOrig = m.loBmp.Clone(m.loRect, m.loBmp.PixelFormat)
		toBmp.SetHandle(lhCloned, .T.)
	ENDIF

	loGfx = NULL

ENDFUNC 




FUNCTION ErrorInfo(tnStatus)
	DO CASE
	CASE tnStatus = 0
		RETURN "Ok"
	CASE tnStatus = 1
		RETURN "Generic Error"
	CASE tnStatus = 2
		RETURN "Invalid Parameter"
	CASE tnStatus = 3
		RETURN "Out Of Memory"
	CASE tnStatus = 4
		RETURN "Object Busy"
	CASE tnStatus = 5
		RETURN "Insufficient Buffer"
	CASE tnStatus = 6
		RETURN "Not Implemented"
	CASE tnStatus = 7
		RETURN "Win32 Error"
	CASE tnStatus = 8
		RETURN "Wrong State"
	CASE tnStatus = 9
		RETURN "Aborted"
	CASE tnStatus = 10
		RETURN "File Not Found"
	CASE tnStatus = 11
		RETURN "Value Overflow"
	CASE tnStatus = 12
		RETURN "Access Denied"
	CASE tnStatus = 13
		RETURN "Unknown Image Format"
	CASE tnStatus = 14
		RETURN "Font Family Not Found"
	CASE tnStatus = 15
		RETURN "Font Style Not Found"
	CASE tnStatus = 16
		RETURN "Not True Type Font"
	CASE tnStatus = 17
		RETURN "Unsupported Gdiplus Version"
	CASE tnStatus = 18
		RETURN "Gdiplus Not Initialized"
	CASE tnStatus = 19
		RETURN "Property Not Found"
	CASE tnStatus = 20
		RETURN "Property Not Supported"
	OTHERWISE 
		RETURN "Unknown Error"
	ENDCASE 
ENDFUNC



ENDDEFINE






FUNCTION __ApplyColorMatrix(tcClrMatrix AS Character, ;
				toBmp as GpBitmap OF HOME() + "\ffc\_gdiPlus.vcx", ;
				tiFormat AS EnumPixelFormat)

	This.SetColorMatrix(tcClrMatrix)

	LOCAL lnWidth, lnHeight
	lnWidth  = toBmp.ImageWidth 
	lnHeight = toBmp.ImageHeight

	#define	GDIPLUS_PIXELFORMAT_32bppARGB      	0x0026200A
	m.tiFormat = EVL(m.tiFormat, GDIPLUS_PIXELFORMAT_32bppARGB)

	LOCAL loNewBmp AS GpBitmap OF HOME() + "\ffc\_gdiPlus.vcx"
	loNewBmp = CREATEOBJECT("GpBitmap")
	loNewBmp.Create(lnWidth, lnHeight, tiFormat)

	LOCAL loGfx AS GpGraphics OF HOME() + "\ffc\_gdiPlus.vcx"
	loGfx = CREATEOBJECT("GpGraphics")
	loGfx.CreateFromImage(toBmp)
	

	LOCAL loClonedBmp AS GpBitmap OF HOME() + "\ffc\_gdiPlus.vcx"
	LOCAL loGfx AS GpGraphics OF HOME() + "\ffc\_gdiPlus.vcx"

	loClonedBmp = CREATEOBJECT("GpBitmap")
		
*	loClonedBmp.Clone(toBmp)
	* Bug in FFC class, so we'll do it here using API calls
	LOCAL lhCloned
	lhCloned = 0
	Declare Integer GdipCloneImage In GDIPlus.Dll ;
		integer nImage, integer @nCloneImage
	This.Stat = GdipCloneImage( ;
		toBmp.GetHandle() ;
		,	@lhCloned)
	loClonedBmp.SetHandle(lhCloned)
	

	loGfx = CREATEOBJECT("GpGraphics")
	loGfx.CreateFromImage(toBmp)

	#DEFINE ARGB_Transparent    16777215 
	loGfx.Clear(ARGB_Transparent)

	LOCAL lnScrUnit, lhGfx
	lnSrcUnit = 2 && GraphicsUnit:Pixel

	DECLARE INTEGER GdipDrawImageRectRect IN gdiplus.dll ;
		INTEGER Graphics, INTEGER nImage, ;
		SINGLE dstx, SINGLE dsty, SINGLE dstwidth, SINGLE dstheight, ;
		SINGLE srcx, SINGLE srcy, SINGLE srcwidth, SINGLE srcheight, ;
		INTEGER srcUnit, INTEGER imageAttributes, ;
		INTEGER Callback, INTEGER CallbackData			

	This.Stat = GdipDrawImageRectRect(loGfx.GetHandle(), loClonedBmp.GetHandle(), ;
		0, 0, lnWidth, lnHeight, ;
		0, 0, lnWidth, lnHeight, ;
		m.lnSrcUnit, This.GdipHandle, 0, 0)

	loClonedBmp = NULL
	loGfx = NULL

ENDFUNC 







* Original
FUNCTION ApplyColorMatrix_Orig(tcClrMatrix AS Character, ;
				toBmp as GpBitmap OF HOME() + "\ffc\_gdiPlus.vcx", ;
				tiFormat AS EnumPixelFormat)

	This.SetColorMatrix(tcClrMatrix)

	#define	GDIPLUS_PIXELFORMAT_32bppARGB      	0x0026200A
	m.tiFormat = EVL(m.tiFormat, GDIPLUS_PIXELFORMAT_32bppARGB)

	LOCAL loClonedBmp AS GpBitmap OF HOME() + "\ffc\_gdiPlus.vcx"
	LOCAL loGfx AS GpGraphics OF HOME() + "\ffc\_gdiPlus.vcx"

	loClonedBmp = CREATEOBJECT("GpBitmap")
		
*	loClonedBmp.Clone(toBmp)
	* Bug in FFC class, so we'll do it here using API calls
	LOCAL lhCloned
	lhCloned = 0
	Declare Integer GdipCloneImage In GDIPlus.Dll ;
		integer nImage, integer @nCloneImage
	This.Stat = GdipCloneImage( ;
		toBmp.GetHandle() ;
		,	@lhCloned)
	loClonedBmp.SetHandle(lhCloned)
	

	loGfx = CREATEOBJECT("GpGraphics")
	loGfx.CreateFromImage(toBmp)

	#DEFINE ARGB_Transparent    16777215 
	loGfx.Clear(ARGB_Transparent)

	LOCAL lnWidth, lnHeight
	lnWidth  = toBmp.ImageWidth 
	lnHeight = toBmp.ImageHeight

	LOCAL lnScrUnit, lhGfx
	lnSrcUnit = 2 && GraphicsUnit:Pixel

	DECLARE INTEGER GdipDrawImageRectRect IN gdiplus.dll ;
		INTEGER Graphics, INTEGER nImage, ;
		SINGLE dstx, SINGLE dsty, SINGLE dstwidth, SINGLE dstheight, ;
		SINGLE srcx, SINGLE srcy, SINGLE srcwidth, SINGLE srcheight, ;
		INTEGER srcUnit, INTEGER imageAttributes, ;
		INTEGER Callback, INTEGER CallbackData			

	This.Stat = GdipDrawImageRectRect(loGfx.GetHandle(), loClonedBmp.GetHandle(), ;
		0, 0, lnWidth, lnHeight, ;
		0, 0, lnWidth, lnHeight, ;
		m.lnSrcUnit, This.GdipHandle, 0, 0)

	loClonedBmp = NULL
	loGfx = NULL

ENDFUNC 


PROCEDURE f2int2
ENDPROC