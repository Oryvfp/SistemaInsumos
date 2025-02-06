FUNCTION Modrepo
*************
PARAMETERS cReport

*
LOCAL sysmenuprevio
sysmenuprevio = SET("Sysmenu")
*
*
zoom window screen max
_screen.Visible= .T.
SET SYSMENU TO default
SET sysmenu on
*
modi report &cReport
*
_screen.visible = .F.
*
SET SYSMENU TO defa
SET SYSMENU &sysmenuprevio
*
