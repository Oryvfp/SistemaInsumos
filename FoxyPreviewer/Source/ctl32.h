
**************************************************************************************
*-- Custom
**************************************************************************************
#Define TRUE                                    .T.
#Define FALSE                                   .F.

#Define CR                                      CHR(13)
#Define LF                                      CHR(10)
#Define CRLF                                    CR+LF

#Define BORDERSTYLE_NONE                        0
#Define BORDERSTYLE_FIXEDSINGLE                 1
#Define BORDERSTYLE_FIXEDDIALOG                 2
#Define BORDERSTYLE_SIZABLE                     3

#Define SHOWWINDOW_INSCREEN                     0
#Define SHOWWINDOW_INTOPLEVELFORM               1
#Define SHOWWINDOW_ASTOPLEVELFORM               2

#Define VERSION2_RUNTIME                        0

*-- ObjToClient parameters
#Define OTC_TOP                                 1
#Define OTC_LEFT				2
#Define OTC_WIDTH				3
#Define OTC_HEIGHT				4

#Define CTL32_FORMTYPE_DEFAULT			0
#Define CTL32_FORMTYPE_TOPLEVEL			1
#Define CTL32_FORMTYPE_SCREEN			2

#Define CTL32_SBBORDER_HORIZONTAL		1
#Define CTL32_SBBORDER_VERTICAL			2
#Define CTL32_SBBORDER_SEPARATOR		3

**************************************************************************************
*-- API
**************************************************************************************
#Define CCM_FIRST				0x2000
#Define CCM_GETUNICODEFORMAT			0x2006  && (CCM_FIRST + 6)
#Define CCM_SETBKCOLOR				0x2001  && (CCM_FIRST + 1)
#Define CCM_SETUNICODEFORMAT			0x2005  && (CCM_FIRST + 5)

#Define CCS_ADJUSTABLE				0x20
#Define CCS_BOTTOM				0x3
#Define CCS_LEFT                      0x81    && Bitor(CCS_VERT, CCS_TOP)
#Define CCS_NODIVIDER                 0x40
#Define CCS_NOMOVEX                   0x82    && Bitor(CCS_VERT, CCS_NOMOVEY)
#Define CCS_NOMOVEY                   0x2
#Define CCS_NOPARENTALIGN             0x8
#Define CCS_NORESIZE                  0x4
#Define CCS_RIGHT                     0x83    && Bitor(CCS_VERT, CCS_BOTTOM)
#Define CCS_TOP                       0x1
#Define CCS_VERT                      0x80


#Define CLR_DEFAULT                   0xFF000000
#Define COLOR_BTNFACE                 15
#Define COLOR_BTNFACE                 15
#Define COLOR_HIGHLIGHT               13
#Define COLOR_WINDOW                  5

#DEFINE CW_USEDEFAULT	0x80000000

#Define DATE_LONGDATE                 0x2
#Define DATE_SHORTDATE                0x1

#Define GW_CHILD                      5

#Define GWL_EXSTYLE                  -20
#Define GWL_HINSTANCE                -6
#Define GWL_STYLE                    -16
#Define GWL_WNDPROC                  -4

#Define HWND_TOP                      0
#Define LOCALE_SISO639LANGNAME        0x59
#Define LOCALE_SYSTEM_DEFAULT         0x800
#Define LOCALE_USER_DEFAULT           0x400
#Define LOCALE_NOUSEROVERRIDE         0x80000000

#DEFINE CCM_GETUNICODEFORMAT          (CCM_FIRST + 6)
#DEFINE CCM_SETUNICODEFORMAT          (CCM_FIRST + 5)

#DEFINE MAXLONG                       0x7FFFFFFF

#DEFINE MCM_FIRST				0x1000
#DEFINE MCM_GETCOLOR				0x1011 && (MCM_FIRST + 11)
#DEFINE MCM_GETCURSEL				0x1001 && (MCM_FIRST + 1)
#DEFINE MCM_GETFIRSTDAYOFWEEK			0x1016 && (MCM_FIRST + 16)
#DEFINE MCM_GETMAXSELCOUNT			0x1003 && (MCM_FIRST + 3)
#DEFINE MCM_GETMAXTODAYWIDTH			0x1021 && (MCM_FIRST + 21)
#DEFINE MCM_GETMINREQRECT			0x1009 && (MCM_FIRST + 9)
#DEFINE MCM_GETMONTHDELTA			0x1019 && (MCM_FIRST + 19)
#DEFINE MCM_GETMONTHRANGE			0x1007 && (MCM_FIRST + 7)
#DEFINE MCM_GETRANGE	(MCM_FIRST + 17)
#DEFINE MCM_GETSELRANGE	(MCM_FIRST + 5)
#DEFINE MCM_GETTODAY	(MCM_FIRST + 13)
#DEFINE MCM_GETUNICODEFORMAT	CCM_GETUNICODEFORMAT
#DEFINE MCM_HITTEST	(MCM_FIRST + 14)
#DEFINE MCM_SETCOLOR	(MCM_FIRST + 10)
#DEFINE MCM_SETCURSEL	(MCM_FIRST + 2)
#DEFINE MCM_SETDAYSTATE	(MCM_FIRST + 8)
#DEFINE MCM_SETFIRSTDAYOFWEEK	(MCM_FIRST + 15)
#DEFINE MCM_SETMAXSELCOUNT	(MCM_FIRST + 4)
#DEFINE MCM_SETMONTHDELTA	(MCM_FIRST + 20)
#DEFINE MCM_SETRANGE	(MCM_FIRST + 18)
#DEFINE MCM_SETSELRANGE	(MCM_FIRST + 6)
#DEFINE MCM_SETTODAY	(MCM_FIRST + 12)
#DEFINE MCM_SETUNICODEFORMAT	CCM_SETUNICODEFORMAT

#DEFINE MCS_DAYSTATE	0x1
#DEFINE MCS_MULTISELECT	0x2
#DEFINE MCS_NOTODAY	0x10
#DEFINE MCS_NOTODAYCIRCLE	0x8
#DEFINE MCS_WEEKNUMBERS	0x4

#DEFINE MCSC_BACKGROUND	0
#DEFINE MCSC_MONTHBK	4
#DEFINE MCSC_TEXT	1
#DEFINE MCSC_TITLEBK	2
#DEFINE MCSC_TITLETEXT	3
#DEFINE MCSC_TRAILINGTEXT	5

#Define MF_APPEND                              0x100
#Define MF_BITMAP                              0x4
#Define MF_BYCOMMAND                           0x0
#Define MF_BYPOSITION                          0x400
#Define MF_CALLBACKS                           0x8000000
#Define MF_CHANGE                              0x80
#Define MF_CHECKED                             0x8
#Define MF_CONV                                0x40000000
#Define MF_DEFAULT                             0x1000
#Define MF_DELETE                              0x200
#Define MF_DISABLED                            0x2
#Define MF_DLL_NAME                           "Microsoft Picture Converter"
#Define MF_ENABLED                             0x0
#Define MF_END                                 0x80
#Define MF_ERRORS                              0x10000000
#Define MF_FLAGS_CREATE_BUT_NO_SHOW_DISABLED   0x8
#Define MF_FLAGS_EVEN_IF_NO_RESOURCE           0x1
#Define MF_FLAGS_FILL_IN_UNKNOWN_RESOURCE      0x4
#Define MF_FLAGS_NO_CREATE_IF_NO_RESOURCE      0x2
#Define MF_FPCR_FUNC                           0x25
#Define MF_FPCR_FUNC_STR                      "mf_fpcr"
#Define MF_GRAYED                              0x1
#Define MF_HELP                                0x4000
#Define MF_HILITE                              0x80
#Define MF_HSZ_INFO                            0x1000000
#Define MF_INSERT                              0x0
#Define MF_LINKS                               0x20000000
#Define MF_MASK                                0xFF000000
#Define MF_MENUBARBREAK                        0x20
#Define MF_MENUBREAK                           0x40
#Define MF_MOUSESELECT                         0x8000
#Define MF_OWNERDRAW                           0x100
#Define MF_POPUP                               0x10
#Define MF_POSTMSGS                            0x4000000
#Define MF_REMOVE                              0x1000
#Define MF_RIGHTJUSTIFY                        0x4000
#Define MF_SENDMSGS                            0x2000000
#Define MF_SEPARATOR                           0x800
#Define MF_STRING                              0x0
#Define MF_SYSMENU                             0x2000
#Define MF_UNCHECKED                           0x0
#Define MF_UNHILITE                            0x0
#Define MF_USECHECKBITMAPS                     0x200

#Define PBM_DELTAPOS                  0x403    && (WM_USER+3)
#Define PBM_GETPOS                    0x408    && (WM_USER+8)
#Define PBM_GETRANGE                  0x407    && (WM_USER+7)
#Define PBM_SETBARCOLOR               0x409    && (WM_USER + 9)
#Define PBM_SETBKCOLOR                0x2001   && CCM_SETBKCOLOR
#Define PBM_SETMARQUEE                0x40A    && (WM_USER+10)
#Define PBM_SETPOS                    0x402    && (WM_USER+2)
#Define PBM_SETRANGE                  0x401    && (WM_USER+1)
#Define PBM_SETRANGE32                0x406    && (WM_USER + 6)
#Define PBM_SETSTEP                   0x404    && (WM_USER + 4)
#Define PBM_STEPIT                    0x405    && (WM_USER+5)

#Define PBS_MARQUEE                   0x8      && Comctl32.dll version 6
#Define PBS_SMOOTH                    0x1      && Comctl32.dll Version 4.7 or later
#Define PBS_VERTICAL                  0x4      && Comctl32.dll Version 4.7 or later

#Define PS_SOLID                      0

#DEFINE RBS_AUTOSIZE	0x2000
#DEFINE RBS_BANDBORDERS	0x400
#DEFINE RBS_DBLCLKTOGGLE	0x8000
#DEFINE RBS_FIXEDORDER	0x800
#DEFINE RBS_REGISTERDROP	0x1000
#DEFINE RBS_TOOLTIPS	0x100
#DEFINE RBS_VARHEIGHT	0x200
#DEFINE RBS_VERTICALGRIPPER	0x4000
#DEFINE RBSTR_CHANGERECT	0x2
#DEFINE RBSTR_PREFERNOLINEBREAK	0x1

#DEFINE SB_BOTH	3
#DEFINE SB_CTL	2

#Define SB_GETBORDERS                 0x407    && (WM_USER + 7)
#Define SB_GETICON                    0x414    && (WM_USER + 20)
#Define SB_GETPARTS                   0x406    && (WM_USER + 6)
#Define SB_GETRECT                    0x40A    && (WM_USER + 10)
#Define SB_GETTEXTA                   0x402    && (WM_USER + 2)
#Define SB_GETTEXTLENGTHA             0x403    && (WM_USER + 3)
#Define SB_GETTEXTLENGTHW             0x40C    && (WM_USER + 12)
#Define SB_GETTEXTW                   0x40D    && (WM_USER + 13)
#Define SB_GETTIPTEXTA                0x412    && (WM_USER + 18)
#Define SB_GETTIPTEXTW                0x413    && (WM_USER + 19)
#Define SB_GETUNICODEFORMAT           0x2006   && CCM_GETUNICODEFORMAT
#DEFINE SB_HORZ	0
#Define SB_ISSIMPLE                   0x40E    && (WM_USER + 14)
#Define SB_SETBKCOLOR                 0x2001   && CCM_SETBKCOLOR
#Define SB_SETICON                    0x40F    && (WM_USER + 15)
#Define SB_SETMINHEIGHT               0x408    && (WM_USER + 8)
#Define SB_SETPARTS                   0x404    && (WM_USER + 4)
#Define SB_SETTEXTA                   0x401    && (WM_USER + 1)
#Define SB_SETTEXTW                   0x40B    && (WM_USER + 11)
#Define SB_SETTIPTEXTA                0x410    && (WM_USER + 16)
#Define SB_SETTIPTEXTW                0x411    && (WM_USER + 17)
#Define SB_SETUNICODEFORMAT           0X2005   && CCM_SETUNICODEFORMAT
#Define SB_SIMPLE                     0x409    && (WM_USER + 9)
#DEFINE SB_VERT	1

#DEFINE SB_LINELEFT		0
#DEFINE SB_LINERIGHT		1
#DEFINE SB_PAGELEFT		2
#DEFINE SB_PAGERIGHT		3
#DEFINE SB_THUMBPOSITION	4
#DEFINE SB_THUMBTRACK		5
#DEFINE SB_LEFT			6
#DEFINE SB_RIGHT		7
#DEFINE SB_ENDSCROLL		8

#DEFINE SB_LINEUP		0
#DEFINE SB_LINEDOWN		1
#DEFINE SB_PAGEUP		2
#DEFINE SB_PAGEDOWN		3
#DEFINE SB_TOP			6
#DEFINE SB_BOTTOM		7

#Define SBARS_SIZEGRIP                0x100
#Define SBARS_TOOLTIPS                0x800

#DEFINE SBM_ENABLE_ARROWS	0xE4
#DEFINE SBM_GETPOS	0xE1
#DEFINE SBM_GETRANGE	0xE3
#DEFINE SBM_GETSCROLLBARINFO	0xEB
#DEFINE SBM_GETSCROLLINFO	0xEA
#DEFINE SBM_SETPOS	0xE0
#DEFINE SBM_SETRANGE	0xE2
#DEFINE SBM_SETRANGEREDRAW	0xE6
#DEFINE SBM_SETSCROLLINFO	0xE9

#DEFINE SBS_BOTTOMALIGN	0x4
#DEFINE SBS_HORZ	0x0
#DEFINE SBS_LEFTALIGN	0x2
#DEFINE SBS_RIGHTALIGN	0x4
#DEFINE SBS_SIZEBOX	0x8
#DEFINE SBS_SIZEBOXBOTTOMRIGHTALIGN	0x4
#DEFINE SBS_SIZEBOXTOPLEFTALIGN	0x2
#DEFINE SBS_SIZEGRIP	0x10
#DEFINE SBS_TOPALIGN	0x2
#DEFINE SBS_VERT	0x1

#Define SBT_NOBORDERS                 0x100
#Define SBT_NOTABPARSING              0x800
#Define SBT_OWNERDRAW                 0x1000
#Define SBT_POPOUT                    0x200
#Define SBT_RTLREADING                0x400
#Define SBT_TOOLTIPS                  0x800

#Define SC_CLOSE                      0xF060
#Define SC_MAXIMIZE                   0xF030
#Define SC_MINIMIZE                   0xF020
#Define SC_MOVE                       0xF010
#Define SC_RESTORE                    0xF120
#Define SC_SEPARATOR                  0xF00F
#Define SC_SIZE                       0xF000

#DEFINE SIF_ALL                       0x17 && Bitor(SIF_RANGE, SIF_PAGE, SIF_POS, SIF_TRACKPOS)
#DEFINE SIF_DISABLENOSCROLL           0x8
#DEFINE SIF_PAGE                      0x2
#DEFINE SIF_POS                       0x4
#DEFINE SIF_RANGE                     0x1
#DEFINE SIF_TRACKPOS                  0x10

#DEFINE SS_BITMAP	0xE
#DEFINE SS_BLACKFRAME	0x7
#DEFINE SS_BLACKRECT	0x4
#DEFINE SS_CENTER	0x1
#DEFINE SS_CENTERIMAGE	0x200
#DEFINE SS_ELLIPSISMASK	0xC000
#DEFINE SS_ENDELLIPSIS	0x4000
#DEFINE SS_ENHMETAFILE	0xF
#DEFINE SS_ETCHEDFRAME	0x12
#DEFINE SS_ETCHEDHORZ	0x10
#DEFINE SS_ETCHEDVERT	0x11
#DEFINE SS_GRAYFRAME	0x8
#DEFINE SS_GRAYRECT	0x5
#DEFINE SS_ICON	0x3
#DEFINE SS_LEFT	0x0
#DEFINE SS_LEFTNOWORDWRAP	0xC
#DEFINE SS_LEVEL_VERSION	0
#DEFINE SS_MAJOR_VERSION	7
#DEFINE SS_MINIMUM_VERSION	"7.00.00.0000"
#DEFINE SS_MINOR_VERSION	0
#DEFINE SS_NOPREFIX	0x80
#DEFINE SS_NOTIFY	0x100
#DEFINE SS_OWNERDRAW	0xD
#DEFINE SS_PATHELLIPSIS	0x8000
#DEFINE SS_REALSIZECONTROL	0x40
#DEFINE SS_REALSIZEIMAGE	0x800
#DEFINE SS_RIGHT	0x2
#DEFINE SS_RIGHTJUST	0x400
#DEFINE SS_SIMPLE	0xB
#DEFINE SS_SUNKEN	0x1000
#DEFINE SS_TYPEMASK	0x1F
#DEFINE SS_USERITEM	0xA
#DEFINE SS_WHITEFRAME	0x9
#DEFINE SS_WHITERECT	0x6
#DEFINE SS_WORDELLIPSIS	0xC000



#Define SW_AUTOPROF_LOAD_MASK         0x1
#Define SW_AUTOPROF_SAVE_MASK         0x2
#Define SW_ERASE                      0x4
#Define SW_FORCEMINIMIZE              11
#Define SW_HIDE                       0
#Define SW_INVALIDATE                 0x2
#Define SW_MAX                        10
#Define SW_MAXIMIZE                   3
#Define SW_MINIMIZE                   6
#Define SW_NORMAL                     1
#Define SW_OTHERUNZOOM                4
#Define SW_OTHERZOOM                  2
#Define SW_PARENTCLOSING              1
#Define SW_PARENTOPENING              3
#Define SW_RESTORE                    9
#Define SW_SCROLLCHILDREN             0x1
#Define SW_SHOW                       5
#Define SW_SHOWDEFAULT                10
#Define SW_SHOWMAXIMIZED              3
#Define SW_SHOWMINIMIZED              2
#Define SW_SHOWMINNOACTIVE            7
#Define SW_SHOWNA                     8
#Define SW_SHOWNOACTIVATE             4
#Define SW_SHOWNORMAL                 1

#Define SWP_FRAMECHANGED              0x20
#Define SWP_NOMOVE                    0x2
#Define SWP_NOSIZE                    0x1
#Define SWP_NOZORDER                  0x4

#Define TIME_NOSECONDS                0x2

#Define WM_ACTIVATE                   0x0006
#Define WM_ACTIVATEAPP                0x001C
#Define WM_GETFONT                    0x0031
#DEFINE WM_HSCROLL                    0x0114
#Define WM_NCPAINT                    0x0085
#Define WM_NOTIFY                     0x004E
#Define WM_PAINT                      0x000F
#Define WM_SIZE                       0x0005
#Define WM_SYSCOLORCHANGE             0x0015
#Define WM_THEMECHANGED               0x031A
#Define WM_USER                       0x0400
#DEFINE WM_VSCROLL                    0x0115

#DEFINE WS_ACTIVECAPTION	0x1
#DEFINE WS_BORDER                     0x800000
#DEFINE WS_BORDER_BIT                 23
#DEFINE WS_CAPTION	0xC00000
#Define WS_CHILD                      0x40000000
#DEFINE WS_CHILDWINDOW	0x40000000
#Define WS_CLIPCHILDREN               0x2000000
#Define WS_CLIPSIBLINGS               0x4000000
#DEFINE WS_DISABLED	0x8000000
#DEFINE WS_DLGFRAME	0x400000
#Define WS_VISIBLE                    0x10000000

#Define WS_EX_LAYOUTRTL               0x400000
#Define WS_EX_LAYOUTRTL_BIT           22
#Define WS_EX_LEFT                    0x0
#Define WS_EX_LTRREADING              0x0
#Define WS_EX_NOPARENTNOTIFY          0x4
#Define WS_EX_RIGHTSCROLLBAR          0x0
#Define WS_EX_STATICEDGE              0x20000
#Define WS_EX_STATICEDGE_BIT          17
#Define WS_EX_TOPMOST                 0x8


#DEFINE WS_EX_ACCEPTFILES	0x10
#DEFINE WS_EX_APPWINDOW	0x40000
#DEFINE WS_EX_CLIENTEDGE	0x200
#DEFINE WS_EX_CONTEXTHELP	0x400
#DEFINE WS_EX_CONTROLPARENT	0x10000
#DEFINE WS_EX_DLGMODALFRAME	0x1
#DEFINE WS_EX_LAYERED	0x80000
#DEFINE WS_EX_LEFTSCROLLBAR	0x4000
#DEFINE WS_EX_MDICHILD	0x40
#DEFINE WS_EX_NOACTIVATE	0x8000000
#DEFINE WS_EX_NOINHERITLAYOUT	0x100000
#DEFINE WS_EX_OVERLAPPEDWINDOW	(WS_EX_WINDOWEDGE Or WS_EX_CLIENTEDGE)
#DEFINE WS_EX_PALETTEWINDOW	(WS_EX_WINDOWEDGE Or WS_EX_TOOLWINDOW Or WS_EX_TOPMOST)
#DEFINE WS_EX_RIGHT	0x1000
#DEFINE WS_EX_RTLREADING	0x2000
#DEFINE WS_EX_TOOLWINDOW	0x80
#DEFINE WS_EX_TOPMOST	0x8
#DEFINE WS_EX_TRANSPARENT	0x20
#DEFINE WS_EX_WINDOWEDGE	0x100




**************************************************************************************
* From foxpro.h
**************************************************************************************

*-- Sysmetric() parameter values
#Define SYSMETRIC_SCREENWIDTH              1 && Screen width
#Define SYSMETRIC_SCREENHEIGHT             2 && Screen width
#Define SYSMETRIC_SIZINGBORDERWIDTH        3 && Width of the sizing border around a resizable window
#Define SYSMETRIC_SIZINGBORDERHEIGHT       4 && Height of the sizing border around a resizable window
#Define SYSMETRIC_VSCROLLBARWIDTH          5 && Width of a vertical scroll bar
#Define SYSMETRIC_VSCROLLBARHEIGHT         6 && Height of the arrow bitmap on a vertical scroll bar
#Define SYSMETRIC_HSCROLLBARWIDTH          7 && Width of the arrow bitmap on a horizontal scroll bar
#Define SYSMETRIC_HSCROLLBARHEIGHT         8 && Height of a horizontal scroll bar
#Define SYSMETRIC_WINDOWTITLEHEIGHT        9 && Height of window title (caption) area
#Define SYSMETRIC_WINDOWBORDERWIDTH       10 && Width of a window border
#Define SYSMETRIC_WINDOWBORDERHEIGHT      11 && Height of a window border
#Define SYSMETRIC_WINDOWFRAMEWIDTH        12 && Width of the frame around the perimeter of a window that has a caption but is not sizable
#Define SYSMETRIC_WINDOWFRAMEHEIGHT       13 && Height of the frame around the perimeter of a window that has a caption but is not sizable
#Define SYSMETRIC_THUMBBOXWIDTH           14 && Width of the thumb box in a horizontal scroll bar
#Define SYSMETRIC_THUMBBOXHEIGHT          15 && Height of the thumb box in a vertical scroll bar
#Define SYSMETRIC_ICONWIDTH               16 && Width of an icon
#Define SYSMETRIC_ICONHEIGHT              17 && Height of an icon
#Define SYSMETRIC_CURSORWIDTH             18 && Width of a cursor
#Define SYSMETRIC_CURSORHEIGHT            19 && Height of a cursor
#Define SYSMETRIC_MENUBAR                 20 && Height of a single-line menu bar
#Define SYSMETRIC_CLIENTWIDTH             21 && Width of the client area for a full-screen window
#Define SYSMETRIC_CLIENTHEIGHT            22 && Height of the client area for a full-screen window
#Define SYSMETRIC_KANJIWINHEIGHT          23 && Height of the Kanji window at the bottom of the screen in DBCS versions
#Define SYSMETRIC_MINDRAGWIDTH            24 && Minimum tracking width of a window. (The user cannot drag the window frame to a size smaller than this)
#Define SYSMETRIC_MINDRAGHEIGHT           25 && Minimum tracking height of a window. (The user cannot drag the window frame to a size smaller than this)
#Define SYSMETRIC_MINWINDOWWIDTH          26 && Minimum width of a window
#Define SYSMETRIC_MINWINDOWHEIGHT         27 && Minimum height of a window
#Define SYSMETRIC_TITLEBARBUTTONWIDTH     28 && Width of a title bar button
#Define SYSMETRIC_TITLEBARBUTTONHEIGHT    29 && Height of a title bar button
#Define SYSMETRIC_MOUSEPRESENT            30 && Is mouse present?  1 => mouse is installed, 0 => no mouse is installed
#Define SYSMETRIC_DEBUGVERSION            31 && Is this a debug version?  1 => debug version, 0 => retail version
#Define SYSMETRIC_MOUSEBUTTONSWAP         32 && Are mouse buttons swapped?  1 => Yes, 0 => No
#Define SYSMETRIC_HALFHEIGHTBUTTONWIDTH   33 && Width of a button in a half-height title bar
#Define SYSMETRIC_HALFHEIGHTBUTTONHEIGHT  34 && Height of a button in a half-height title bar

*-- Window Borders
#Define BORDER_NONE                       0
#Define BORDER_SINGLE                     1
#Define BORDER_DOUBLE                     2
#Define BORDER_SYSTEM                     3

*-- WindowState
#Define WINDOWSTATE_NORMAL                0       && Normal
#Define WINDOWSTATE_MINIMIZED             1       && Minimized
#Define WINDOWSTATE_MAXIMIZED             2       && Maximized

*-- Toolbar and Form Docking Positions
#Define TOOL_NOTDOCKED                   -1
#Define TOOL_TOP                          0
#Define TOOL_LEFT                         1
#Define TOOL_RIGHT                        2
#Define TOOL_BOTTOM                       3
#Define TOOL_TAB                          4
#Define TOOL_LINK                         5

*-- TYPE() tags
#Define T_CHARACTER     "C"
#Define T_NUMERIC       "N"
#Define T_DOUBLE        "B"
#Define T_DATE          "D"
#Define T_DATETIME      "T"
#Define T_MEMO          "M"
#Define T_GENERAL       "G"
#Define T_OBJECT        "O"
#Define T_SCREEN        "S"
#Define T_LOGICAL       "L"
#Define T_CURRENCY      "Y"
#Define T_UNDEFINED     "U"
#Define T_INTEGER       "N"
#Define T_VARCHAR       "C"
#Define T_VARBINARY     "Q"
#Define T_BLOB          "W"

*-- Button parameter masks
#Define BUTTON_LEFT     1
#Define BUTTON_RIGHT    2
#Define BUTTON_MIDDLE   4

*-- Function Parameters
*-- MessageBox parameters
#Define MB_OK                   0       && OK button only
#Define MB_OKCANCEL             1       && OK and Cancel buttons
#Define MB_ABORTRETRYIGNORE     2       && Abort, Retry, and Ignore buttons
#Define MB_YESNOCANCEL          3       && Yes, No, and Cancel buttons
#Define MB_YESNO                4       && Yes and No buttons
#Define MB_RETRYCANCEL          5       && Retry and Cancel buttons

#Define MB_ICONSTOP             16      && Critical message
#Define MB_ICONQUESTION         32      && Warning query
#Define MB_ICONEXCLAMATION      48      && Warning message
#Define MB_ICONINFORMATION      64      && Information message

#Define MB_APPLMODAL            0       && Application modal message box
#Define MB_DEFBUTTON1           0       && First button is default
#Define MB_DEFBUTTON2           256     && Second button is default
#Define MB_DEFBUTTON3           512     && Third button is default
#Define MB_SYSTEMMODAL          4096    && System Modal

#Define LANG_NEUTRAL                     0x00

#Define LANG_AFRIKAANS                   0x36
#Define LANG_ALBANIAN                    0x1c
#Define LANG_ARABIC                      0x01
#Define LANG_BASQUE                      0x2d
#Define LANG_BELARUSIAN                  0x23
#Define LANG_BULGARIAN                   0x02
#Define LANG_CATALAN                     0x03
#Define LANG_CHINESE                     0x04
#Define LANG_CROATIAN                    0x1a
#Define LANG_CZECH                       0x05
#Define LANG_DANISH                      0x06
#Define LANG_DUTCH                       0x13
#Define LANG_ENGLISH                     0x09
#Define LANG_ESTONIAN                    0x25
#Define LANG_FAEROESE                    0x38
#Define LANG_FARSI                       0x29
#Define LANG_FINNISH                     0x0b
#Define LANG_FRENCH                      0x0c
#Define LANG_GERMAN                      0x07
#Define LANG_GREEK                       0x08
#Define LANG_HEBREW                      0x0d
#Define LANG_HUNGARIAN                   0x0e
#Define LANG_ICELANDIC                   0x0f
#Define LANG_INDONESIAN                  0x21
#Define LANG_ITALIAN                     0x10
#Define LANG_JAPANESE                    0x11
#Define LANG_KOREAN                      0x12
#Define LANG_LATVIAN                     0x26
#Define LANG_LITHUANIAN                  0x27
#Define LANG_NORWEGIAN                   0x14
#Define LANG_POLISH                      0x15
#Define LANG_PORTUGUESE                  0x16
#Define LANG_ROMANIAN                    0x18
#Define LANG_RUSSIAN                     0x19
#Define LANG_SERBIAN                     0x1a
#Define LANG_SLOVAK                      0x1b
#Define LANG_SLOVENIAN                   0x24
#Define LANG_SPANISH                     0x0a
#Define LANG_SWEDISH                     0x1d
#Define LANG_THAI                        0x1e
#Define LANG_TURKISH                     0x1f
#Define LANG_UKRAINIAN                   0x22
#Define LANG_VIETNAMESE                  0x2a
