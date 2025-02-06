LPARAMETERS tcPrinterName, tnOrientation
* Adapted from http://news2news.com/vfp/index.php?example=555&ver=vcs
* Code from Anatolyi Mogylevetz
* Returns a PrinterDC handle, for the chosen printer and paper orientation

DO declare

IF VARTYPE(m.tnOrientation) <> "N"
	m.tnOrientation = 0 && Portrait
ENDIF 

IF EMPTY(m.tcPrinterName)
    * obtain the default printer name from API call;
    * or use VFP native GETPRINTER() or APRINTERS() functions
    m.tcPrinterName = GetDefaultPrinterName()
ENDIF

IF RIGHT(m.tcPrinterName,1) <> 0h00
	m.tcPrinterName = m.tcPrinterName + 0h00
ENDIF

&& 0 = Portrait
&& 1 = Landscape

#DEFINE DM_OUT_BUFFER        2
#DEFINE DM_IN_BUFFER         8
 
#DEFINE DM_ORIENTATION       1
#DEFINE DM_ORIENT_PORTRAIT   1
#DEFINE DM_ORIENT_LANDSCAPE  2
#DEFINE DM_OFFS_DMFIELDS    41  && DEVMODE dmFields offset
#DEFINE DM_OFFS_ORIENTATION 45  && DEVMODE dmOrientation offset
 
#DEFINE DOCINFO_SIZE        20
 
 
LOCAL hPrinterDC
 
* create device context for the default printer
* setting specified printing page orientation
m.hPrinterDC = GetPrinterDC(m.tcPrinterName, m.tnOrientation + 1) &&(DM_ORIENT_LANDSCAPE)
 
RETURN m.hPrinterDC
* end of main
  
 
FUNCTION GetPrinterDC(tcPrinterName, nOrientation As Number) As Number
* returns device context for the default printer
 
    LOCAL hPrinter, nErrorCode,;
        oDevmode As PChar, nDevmodeSize, hPrinterDC
 
    m.hPrinter=0
    = OpenPrinter(tcPrinterName, @m.hPrinter, 0)
    IF m.hPrinter = 0
        m.nErrorCode=GetLastError()
        = MESSAGEBOX("OpenPrinter() failed: " +;
            TRANSFORM(m.nErrorCode), 48, "Error")
        RETURN 0
    ENDIF
 
    * first DocumentProperties call is configured 
    * to return the required size for DEVMODE buffer
    m.nDevmodeSize = DocumentProperties(_screen.HWnd, m.hPrinter,;
        tcPrinterName, 0, 0, 0)
 
    m.oDevmode = CREATEOBJECT("PChar",;
        REPLICATE(CHR(0),m.nDevmodeSize))
 
    * second DocumentProperties call populates
    * the DEVMODE buffer
    = DocumentProperties(_screen.HWnd, m.hPrinter,;
        tcPrinterName, m.oDevmode.GetAddr(), 0, DM_OUT_BUFFER)
 
    * the printer handle is not required anymore
    * and can be closed
    = ClosePrinter(m.hPrinter)
 
    * switching to the specified page orientation 
    * by adjusting the DEVMODE structure
    DO SetPageOrientation WITH m.oDevMode, m.nOrientation
 
    * the device context for the default printer
    * is created based on the DEVMODE configured 
    * to the sepcified page orientation
    m.hPrinterDC = CreateDC("winspool", tcPrinterName,;
        0, m.oDevmode.GetAddr())
 
    IF m.hPrinterDC = 0
        m.nErrorCode=GetLastError()
        = MESSAGEBOX("CreateDC() failed: " +;
            TRANSFORM(m.nErrorCode), 48, "Error")
    ENDIF
 
RETURN m.hPrinterDC
  
PROCEDURE SetPageOrientation
PARAMETERS oDevmode As PChar, nOrientation As Number
 
    LOCAL cDevmode, dmFlags
 
    * copy DEVMODE bytes from memory block to string buffer
    m.cDevmode = oDevmode.GetValue()
 
    * setting DEVMODE members flag and page orientation value
    m.dmFlags = buf2word(SUBSTR(m.cDevmode, DM_OFFS_DMFIELDS, 4))
    m.dmFlags = BITOR(m.dmFlags, DM_ORIENTATION)
 
    m.cDevmode = STUFF(m.cDevmode, DM_OFFS_DMFIELDS,;
        4, BINTOC(m.dmFlags,"4RS"))
 
    m.cDevmode = STUFF(m.cDevmode, DM_OFFS_ORIENTATION,;
        2, BINTOC(nOrientation, "2RS"))
 
    * copy DEVMODE bytes from string buffer back to memory block
    oDevmode.SetValue(m.cDevmode)
  
FUNCTION GetDefaultPrinterName() As String
    LOCAL cPrinter, nBufsize
    m.nBufsize=250
    m.cPrinter=REPLICATE(CHR(0), m.nBufsize)
RETURN IIF(GetDefaultPrinter(@m.cPrinter, @m.nBufsize)=0, "",;
    SUBSTR(m.cPrinter, 1, AT(CHR(0),m.cPrinter)-1))
  
PROCEDURE declare
    DECLARE INTEGER ClosePrinter IN winspool.drv INTEGER hPrinter 
    DECLARE INTEGER GetLastError IN kernel32
    DECLARE INTEGER DeleteDC IN gdi32 INTEGER hdc
    DECLARE INTEGER StartPage IN gdi32 INTEGER hdc
    DECLARE INTEGER EndPage IN gdi32 INTEGER hdc
    DECLARE INTEGER EndDoc IN gdi32 INTEGER hdc
    DECLARE INTEGER StartDoc IN gdi32 INTEGER hdc, STRING lpdi
 
    DECLARE INTEGER GetDefaultPrinter IN winspool.drv;
        STRING @pszBuffer, INTEGER @pcchBuffer
 
    DECLARE INTEGER OpenPrinter IN winspool.drv;
        STRING pPrinterName, INTEGER @phPrinter, INTEGER pDefault
 
    DECLARE INTEGER DocumentProperties IN winspool.drv;
        INTEGER hWnd, INTEGER hPrinter, STRING pDeviceName,;
        INTEGER pDevModeOutput, INTEGER pDevModeInput, INTEGER fMode
 
    DECLARE INTEGER CreateDC IN gdi32;
        STRING lpszDriver, STRING lpszDevice,;
        INTEGER lpszOutput, INTEGER lpInitData
  
DEFINE CLASS PChar As Session
PROTECTED hMem
 
PROCEDURE Init(lcString)
    THIS.hMem = 0
    THIS.setValue(lcString)
  
PROCEDURE Destroy
    THIS.ReleaseString
  
FUNCTION GetAddr
RETURN THIS.hMem
  
FUNCTION GetValue
    LOCAL lnSize, lcBuffer
    m.lnSize = THIS.getAllocSize()
    lcBuffer = SPACE(m.lnSize)
 
    IF THIS.hMem <> 0
        DECLARE RtlMoveMemory IN kernel32 As MemToStr;
            STRING @, INTEGER, INTEGER
        = MemToStr(@lcBuffer, THIS.hMem, m.lnSize)
    ENDIF
RETURN lcBuffer
  
FUNCTION GetAllocSize
    DECLARE INTEGER GlobalSize IN kernel32 INTEGER hMem
RETURN Iif(THIS.hMem=0, 0, GlobalSize(THIS.hMem))
  
PROCEDURE SetValue(lcString)
#DEFINE GMEM_FIXED 0
#DEFINE GMEM_MOVEABLE 2
#DEFINE GMEM_ZEROINIT 0x0040
 
    THIS.ReleaseString
 
    DECLARE INTEGER GlobalAlloc IN kernel32 INTEGER, INTEGER
    DECLARE RtlMoveMemory IN kernel32 As StrToMem;
        INTEGER, STRING @, INTEGER
 
    LOCAL lnSize
    m.lcString = m.lcString + Chr(0)
    m.lnSize = Len(m.lcString)
    THIS.hMem = GlobalAlloc(GMEM_ZEROINIT, m.lnSize)
    IF THIS.hMem <> 0
        = StrToMem(THIS.hMem, @m.lcString, m.lnSize)
    ENDIF
  
PROCEDURE ReleaseString
    IF THIS.hMem <> 0
        DECLARE INTEGER GlobalFree IN kernel32 INTEGER
        = GlobalFree (THIS.hMem)
        THIS.hMem = 0
    ENDIF
 ENDDEFINE


FUNCTION buf2word (lcBuffer)
* RETURN Asc(SUBSTR(m.lcBuffer, 1,1)) + ;
       Asc(SUBSTR(m.lcBuffer, 2,1)) * 256
RETURN CTOBIN(LEFT(m.lcBuffer,2), "2RS")








*!*	/*****************************************************************************\
*!*	*                                                                             *
*!*	* print.h -     Printing helper functions, types, and definitions             *
*!*	*                                                                             *
*!*	*******************************************************************************
*!*	*
*!*	*  PRINTDRIVER       - For inclusion with a printer driver
*!*	*  NOPQ              - Prevent inclusion of priority queue APIs
*!*	*
*!*	\*****************************************************************************/

*!*	/*
*!*	 *      C/C++ Run Time Library - Version 6.5
*!*	 *
*!*	 *      Copyright (c) 1987, 1994 by Borland International
*!*	 *      All Rights Reserved.
*!*	 *
*!*	 */

*!*	#ifndef __PRINT_H       /* prevent multiple includes */
*!*	#define __PRINT_H

*!*	#ifndef __WINDOWS_H
*!*	#ifdef PRINTDRIVER
*!*	#define NORASTEROPS
*!*	#define NOTEXTMETRICS
*!*	#define NOGDICAPMASKS
*!*	#define NOGDIOBJ
*!*	#define NOBITMAP
*!*	#define NOSOUND
*!*	#define NOTEXTMETRIC
*!*	#define NOCOMM
*!*	#define NOKANJI
*!*	#include <windows.h>    /* <windows.h> must be included */
*!*	#undef NORASTEROPS
*!*	#undef NOTEXTMETRICS
*!*	#undef NOGDICAPMASKS
*!*	#undef NOGDICAPMASKS
*!*	#undef NOGDIOBJ
*!*	#undef NOBITMAP
*!*	#undef NOSOUND
*!*	#undef NOTEXTMETRIC
*!*	#undef NOCOMM
*!*	#undef NOKANJI
*!*	#else  /* !PRINTDRIVER */
*!*	#include <windows.h>    /* <windows.h> must be included */
*!*	#endif  /* PRINTERDRIVER */
*!*	#endif  /* __WINDOWS_H */

*!*	#ifndef RC_INVOKED
*!*	#pragma option -a-      /* Assume byte packing throughout */
*!*	#endif  /* RC_INVOKED */

*!*	#ifdef __cplusplus
*!*	extern "C" {            /* Assume C declarations for C++ */
*!*	#endif  /* __cplusplus */

*!*	#ifdef PRINTDRIVER

*!*	#define NOPTRC  /* don't allow gdidefs.inc to redef these */
*!*	#define PTTYPE POINT

*!*	#define PQERROR (-1)

*!*	#ifndef NOPQ

*!*	DECLARE_HANDLE(HPQ);

*!*	HPQ     WINAPI CreatePQ(int);
*!*	int     WINAPI MinPQ(HPQ);
*!*	int     WINAPI ExtractPQ(HPQ);
*!*	int     WINAPI InsertPQ(HPQ, int, int);
*!*	int     WINAPI SizePQ(HPQ, int);
*!*	void    WINAPI DeletePQ(HPQ);
*!*	#endif  /* !NOPQ */

*!*	/* Spool routines for use by printer drivers */

*!*	DECLARE_HANDLE(HPJOB);

*!*	HPJOB   WINAPI OpenJob(LPSTR, LPSTR, HPJOB);
*!*	int     WINAPI StartSpoolPage(HPJOB);
*!*	int     WINAPI EndSpoolPage(HPJOB);
*!*	int     WINAPI WriteSpool(HPJOB, LPSTR, int);
*!*	int     WINAPI CloseJob(HPJOB);
*!*	int     WINAPI DeleteJob(HPJOB, int);
*!*	int     WINAPI WriteDialog(HPJOB, LPSTR, int);
*!*	int     WINAPI DeleteSpoolPage(HPJOB);

*!*	#endif /* PRINTDRIVER */

*!*	typedef struct tagBANDINFOSTRUCT
*!*	{
*!*	    BOOL    fGraphics;
*!*	    BOOL    fText;
*!*	    RECT    rcGraphics;
*!*	} BANDINFOSTRUCT, FAR* LPBI;

*!*	#define USA_COUNTRYCODE 1

*!*	/*
*!*	 *  Printer driver initialization using ExtDeviceMode()
*!*	 *  and DeviceCapabilities().
*!*	 *  This replaces Drivinit.h
*!*	 */

*!*	/* size of a device name string */
*!*	#define CCHDEVICENAME 32
*!*	#define CCHPAPERNAME  64

*!*	/* current version of specification */
*!*	#define DM_SPECVERSION 0x30A

*!*	/* field selection bits */
*!*	#define DM_ORIENTATION      0x0000001L
*!*	#define DM_PAPERSIZE        0x0000002L
*!*	#define DM_PAPERLENGTH      0x0000004L
*!*	#define DM_PAPERWIDTH       0x0000008L
*!*	#define DM_SCALE            0x0000010L
*!*	#define DM_COPIES           0x0000100L
*!*	#define DM_DEFAULTSOURCE    0x0000200L
*!*	#define DM_PRINTQUALITY     0x0000400L
*!*	#define DM_COLOR            0x0000800L
*!*	#define DM_DUPLEX           0x0001000L
*!*	#define DM_YRESOLUTION      0x0002000L
*!*	#define DM_TTOPTION         0x0004000L

*!*	/* orientation selections */
*!*	#define DMORIENT_PORTRAIT   1
*!*	#define DMORIENT_LANDSCAPE  2

*!*	/* paper selections */
*!*	/*  Warning: The PostScript driver mistakingly uses DMPAPER_ values between
*!*	 *  50 and 56.  Don't use this range when defining new paper sizes.
*!*	 */
*!*	#define DMPAPER_FIRST       DMPAPER_LETTER
*!*	#define DMPAPER_LETTER      1           /* Letter 8 1/2 x 11 in               */
*!*	#define DMPAPER_LETTERSMALL 2           /* Letter Small 8 1/2 x 11 in         */
*!*	#define DMPAPER_TABLOID     3           /* Tabloid 11 x 17 in                 */
*!*	#define DMPAPER_LEDGER      4           /* Ledger 17 x 11 in                  */
*!*	#define DMPAPER_LEGAL       5           /* Legal 8 1/2 x 14 in                */
*!*	#define DMPAPER_STATEMENT   6           /* Statement 5 1/2 x 8 1/2 in         */
*!*	#define DMPAPER_EXECUTIVE   7           /* Executive 7 1/4 x 10 1/2 in        */
*!*	#define DMPAPER_A3          8           /* A3 297 x 420 mm                    */
*!*	#define DMPAPER_A4          9           /* A4 210 x 297 mm                    */
*!*	#define DMPAPER_A4SMALL     10          /* A4 Small 210 x 297 mm              */
*!*	#define DMPAPER_A5          11          /* A5 148 x 210 mm                    */
*!*	#define DMPAPER_B4          12          /* B4 250 x 354                       */
*!*	#define DMPAPER_B5          13          /* B5 182 x 257 mm                    */
*!*	#define DMPAPER_FOLIO       14          /* Folio 8 1/2 x 13 in                */
*!*	#define DMPAPER_QUARTO      15          /* Quarto 215 x 275 mm                */
*!*	#define DMPAPER_10X14       16          /* 10x14 in                           */
*!*	#define DMPAPER_11X17       17          /* 11x17 in                           */
*!*	#define DMPAPER_NOTE        18          /* Note 8 1/2 x 11 in                 */
*!*	#define DMPAPER_ENV_9       19          /* Envelope #9 3 7/8 x 8 7/8          */
*!*	#define DMPAPER_ENV_10      20          /* Envelope #10 4 1/8 x 9 1/2         */
*!*	#define DMPAPER_ENV_11      21          /* Envelope #11 4 1/2 x 10 3/8        */
*!*	#define DMPAPER_ENV_12      22          /* Envelope #12 4 \276 x 11           */
*!*	#define DMPAPER_ENV_14      23          /* Envelope #14 5 x 11 1/2            */
*!*	#define DMPAPER_CSHEET      24          /* C size sheet                       */
*!*	#define DMPAPER_DSHEET      25          /* D size sheet                       */
*!*	#define DMPAPER_ESHEET      26          /* E size sheet                       */
*!*	#define DMPAPER_ENV_DL      27          /* Envelope DL 110 x 220mm            */
*!*	#define DMPAPER_ENV_C5      28          /* Envelope C5 162 x 229 mm           */
*!*	#define DMPAPER_ENV_C3      29          /* Envelope C3  324 x 458 mm          */
*!*	#define DMPAPER_ENV_C4      30          /* Envelope C4  229 x 324 mm          */
*!*	#define DMPAPER_ENV_C6      31          /* Envelope C6  114 x 162 mm          */
*!*	#define DMPAPER_ENV_C65     32          /* Envelope C65 114 x 229 mm          */
*!*	#define DMPAPER_ENV_B4      33          /* Envelope B4  250 x 353 mm          */
*!*	#define DMPAPER_ENV_B5      34          /* Envelope B5  176 x 250 mm          */
*!*	#define DMPAPER_ENV_B6      35          /* Envelope B6  176 x 125 mm          */
*!*	#define DMPAPER_ENV_ITALY   36          /* Envelope 110 x 230 mm              */
*!*	#define DMPAPER_ENV_MONARCH 37          /* Envelope Monarch 3.875 x 7.5 in    */
*!*	#define DMPAPER_ENV_PERSONAL 38         /* 6 3/4 Envelope 3 5/8 x 6 1/2 in    */
*!*	#define DMPAPER_FANFOLD_US  39          /* US Std Fanfold 14 7/8 x 11 in      */
*!*	#define DMPAPER_FANFOLD_STD_GERMAN  40  /* German Std Fanfold 8 1/2 x 12 in   */
*!*	#define DMPAPER_FANFOLD_LGL_GERMAN  41  /* German Legal Fanfold 8 1/2 x 13 in */

*!*	#define DMPAPER_LAST        DMPAPER_FANFOLD_LGL_GERMAN

*!*	#define DMPAPER_USER        256

*!*	/* bin selections */
*!*	#define DMBIN_FIRST         DMBIN_UPPER
*!*	#define DMBIN_UPPER         1
*!*	#define DMBIN_ONLYONE       1
*!*	#define DMBIN_LOWER         2
*!*	#define DMBIN_MIDDLE        3
*!*	#define DMBIN_MANUAL        4
*!*	#define DMBIN_ENVELOPE      5
*!*	#define DMBIN_ENVMANUAL     6
*!*	#define DMBIN_AUTO          7
*!*	#define DMBIN_TRACTOR       8
*!*	#define DMBIN_SMALLFMT      9
*!*	#define DMBIN_LARGEFMT      10
*!*	#define DMBIN_LARGECAPACITY 11
*!*	#define DMBIN_CASSETTE      14
*!*	#define DMBIN_LAST          DMBIN_CASSETTE

*!*	#define DMBIN_USER          256     /* device specific bins start here */

*!*	/* print qualities */
*!*	#define DMRES_DRAFT         (-1)
*!*	#define DMRES_LOW           (-2)
*!*	#define DMRES_MEDIUM        (-3)
*!*	#define DMRES_HIGH          (-4)

*!*	/* color enable/disable for color printers */
*!*	#define DMCOLOR_MONOCHROME  1
*!*	#define DMCOLOR_COLOR       2

*!*	/* duplex enable */
*!*	#define DMDUP_SIMPLEX    1
*!*	#define DMDUP_VERTICAL   2
*!*	#define DMDUP_HORIZONTAL 3

*!*	/* TrueType options */
*!*	#define DMTT_BITMAP     1       /* print TT fonts as graphics */
*!*	#define DMTT_DOWNLOAD   2       /* download TT fonts as soft fonts */
*!*	#define DMTT_SUBDEV     3       /* substitute device fonts for TT fonts */

*!*	/* If included with the 3.0 windows.h, define compatible aliases */
*!*	#if !defined(WINVER) || (WINVER < 0x030a)
*!*	#define CALLBACK    FAR PASCAL
*!*	#define HMODULE     HANDLE
*!*	#define UINT        WORD
*!*	#define WINAPI      FAR PASCAL
*!*	#endif  /* WIN3.0 */

*!*	typedef struct tagDEVMODE
*!*	{
*!*	    char  dmDeviceName[CCHDEVICENAME];
*!*	    UINT  dmSpecVersion;
*!*	    UINT  dmDriverVersion;
*!*	    UINT  dmSize;
*!*	    UINT  dmDriverExtra;
*!*	    DWORD dmFields;
*!*	    int   dmOrientation;
*!*	    int   dmPaperSize;
*!*	    int   dmPaperLength;
*!*	    int   dmPaperWidth;
*!*	    int   dmScale;
*!*	    int   dmCopies;
*!*	    int   dmDefaultSource;
*!*	    int   dmPrintQuality;
*!*	    int   dmColor;
*!*	    int   dmDuplex;
*!*	    int   dmYResolution;
*!*	    int   dmTTOption;
*!*	} DEVMODE;

*!*	typedef DEVMODE* PDEVMODE, NEAR* NPDEVMODE, FAR* LPDEVMODE;

*!*	/* mode selections for the device mode function */
*!*	#define DM_UPDATE           1
*!*	#define DM_COPY             2
*!*	#define DM_PROMPT           4
*!*	#define DM_MODIFY           8

*!*	#define DM_IN_BUFFER        DM_MODIFY
*!*	#define DM_IN_PROMPT        DM_PROMPT
*!*	#define DM_OUT_BUFFER       DM_COPY
*!*	#define DM_OUT_DEFAULT      DM_UPDATE

*!*	/* device capabilities indices */
*!*	#define DC_FIELDS           1
*!*	#define DC_PAPERS           2
*!*	#define DC_PAPERSIZE        3
*!*	#define DC_MINEXTENT        4
*!*	#define DC_MAXEXTENT        5
*!*	#define DC_BINS             6
*!*	#define DC_DUPLEX           7
*!*	#define DC_SIZE             8
*!*	#define DC_EXTRA            9
*!*	#define DC_VERSION          10
*!*	#define DC_DRIVER           11
*!*	#define DC_BINNAMES         12
*!*	#define DC_ENUMRESOLUTIONS  13
*!*	#define DC_FILEDEPENDENCIES 14
*!*	#define DC_TRUETYPE         15
*!*	#define DC_PAPERNAMES       16
*!*	#define DC_ORIENTATION      17
*!*	#define DC_COPIES           18

*!*	/* bit fields of the return value (DWORD) for DC_TRUETYPE */
*!*	#define DCTT_BITMAP         0x0000001L
*!*	#define DCTT_DOWNLOAD       0x0000002L
*!*	#define DCTT_SUBDEV         0x0000004L

*!*	/* export ordinal definitions */
*!*	#define PROC_EXTDEVICEMODE      MAKEINTRESOURCE(90)
*!*	#define PROC_DEVICECAPABILITIES MAKEINTRESOURCE(91)
*!*	#define PROC_OLDDEVICEMODE      MAKEINTRESOURCE(13)

*!*	/* define types of pointers to ExtDeviceMode() and DeviceCapabilities()
*!*	 * functions
*!*	 */
*!*	typedef UINT   (CALLBACK* LPFNDEVMODE)(HWND, HMODULE, DEVMODE FAR*,
*!*	                          LPSTR, LPSTR, DEVMODE FAR*, LPSTR, UINT);

*!*	typedef DWORD  (CALLBACK* LPFNDEVCAPS)(LPSTR, LPSTR, UINT, LPSTR, DEVMODE FAR*);

*!*	HDC     WINAPI ResetDC(HDC, const DEVMODE FAR*);

*!*	/* this structure is used by the GETSETSCREENPARAMS escape */
*!*	typedef struct tagSCREENPARAMS
*!*	{
*!*	   int angle;
*!*	   int frequency;
*!*	} SCREENPARAMS;

*!*	#ifdef __cplusplus
*!*	}                       /* End of extern "C" { */
*!*	#endif  /* __cplusplus */

*!*	#ifndef RC_INVOKED
*!*	#pragma option -a.      /* Revert to default packing */
*!*	#endif  /* RC_INVOKED */

*!*	#endif  /* __PRINT_H */
*!*	
