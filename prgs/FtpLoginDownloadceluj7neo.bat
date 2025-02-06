@ftp -i -s:"%~f0"&GOTO:EOF
open 192.168.1.20 2121
fox
fox
cd mmt
cd sdcard
cd DCIM
cd oryjpg
lcd "C:\Sistemayocca\proj\imagenes_new"
binary


mget *.jpg 
close


disconnect
exit
bye

