**Main.prg
**Date: 12/09/09
**Description :
**Name: Renato

** setup the application environment

*_Screen.Caption = "Sistema de Gestion Empresarial ORY S.R.L."
_Screen.WindowState= 2
  
_Screen.TitleBar = 0
*_screen.Icon = 'C:\ARCHIVOS DE PROGRAMA\MICROSOFT VISUAL FOXPRO 9\GRAPHICS\ICONS\TRAFFIC\TRFFC16.ICO'
ON SHUTDOWN do cleanup in MENU1.prg
*SET PATH TO 
SET TALK OFF
SET DELETED on
*SET REPROCESS TO automatic
SET EXCLUSIVE OFF
SET SYSMENU off
*SYS(2700,0)
_SCREEN.Visible= .F.
*!*	_screen.Picture = ''  
*!*	_SCREEN.ADDOBJECT("oImg", "Image")
*!*	_SCREEN.oImg.PICTURE = 'C:\GESTIONORY\ZOOM\DESKTOP.PNG'
*!*	_SCREEN.oImg.TOP = _SCREEN.HEIGHT/2 - _SCREEN.oImg.HEIGHT/2
*!*	_SCREEN.oImg.LEFT = _SCREEN.WIDTH/2 - _SCREEN.oImg.WIDTH/2
*!*	_SCREEN.oImg.VISIBLE = .T.

RELEASE WINDOWS "STANDARD"

*!*	xDir =SYS(5) && Esto sierve para defenir el Drive donde esta ubicado.

*!*	Ruta = xDir +"\idriesgo\"
SET TALK OFF
SET DELETED on
SET CLOCK TO 7,205

SET REPROCESS TO automatic
SET EXCLUSIVE OFF
SYS(2700,0)
CLEAR all
CLOSE all
SET DEFAULT TO c:\sistemainsumos\FoxyPreviewer
SET PATH TO source

DO foxypreviewer.app
_Screen.oFoxyPreviewer.lOpenViewer=.t.
SET DEFAULT TO c:\sistemainsumos
SET PATH TO batchfiles;data;ETIQUETA;forms;FoxyPreviewer;imagenes;imagenes_new;images;INFOBALL;menus;Pedidos;prgs;Procesos;menus;Pedidos;Prgs;Reports

***Setup Any menus
*DO FORM MenuPrinc.scx
SET STATUS bar OFF
SET PROCEDURE TO "f_activawin.prg"
openform('MenuPrinc.scx')

*DO FORM RENLIST.SCX

***************
**************
* Programa para background
************
READ EVENT


*** CLEAN UP
CLEAR
_Screen.TitleBar = 0
_Screen.BackColor = RGB(255,255,255)
_Screen.Caption = "Microsoft Visual FoxPro"
SET STATUS BAR OFF
RELEASE WINDOWS "STANDARD"

*SET SYSMENU TO default
*DEFINE WINDOW Standard
ON SHUTDOWN
PROCEDURE cleanup
CLEAR EVENTS     &&& Stop events processing
*** close all open befor exiting
FOR x = 1 TO _screen.FormCount
  _screen.Forms[_screen.FormCount].Release()
  NEXT x
  quit
ENDPROC

*SHOW WINDOW Standard
  