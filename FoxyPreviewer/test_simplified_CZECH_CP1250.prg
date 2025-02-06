DO LOCFILE("FoxyPreviewer.App")
SET DATE BRITISH

CREATE CURSOR Foxy_CP1250 (Text c(60), Date d)
INSERT INTO Foxy_CP1250 VALUES ("This is cp1250  - czech language letters:", DATE())
INSERT INTO Foxy_CP1250 VALUES ("", DATE())
INSERT INTO Foxy_CP1250 VALUES ("¡ » œ Ã … Õ “ ” ÿ ä ç ⁄ Ÿ › é", CTOD("01/01/2012"))
INSERT INTO Foxy_CP1250 VALUES ("¡ » œ Ã … Õ “ ” ÿ ä ç ⁄ Ÿ › é", CTOD("06/01/2012"))
INSERT INTO Foxy_CP1250 VALUES ("¡ » œ Ã … Õ “ ” ÿ ä ç ⁄ Ÿ › é", CTOD("11/01/2012"))
INSERT INTO Foxy_CP1250 VALUES ("¡ » œ Ã … Õ “ ” ÿ ä ç ⁄ Ÿ › é", CTOD("16/01/2012"))
INSERT INTO Foxy_CP1250 VALUES ("¡ » œ Ã … Õ “ ” ÿ ä ç ⁄ Ÿ › é", CTOD("21/01/2012"))
INSERT INTO Foxy_CP1250 VALUES ("¡ » œ Ã … Õ “ ” ÿ ä ç ⁄ Ÿ › é", CTOD("26/01/2012"))

INSERT INTO Foxy_CP1250 VALUES ("¡ » œ Ã … Õ “ ” ÿ ä ç ⁄ Ÿ › é", CTOD("01/10/2012"))
INSERT INTO Foxy_CP1250 VALUES ("¡ » œ Ã … Õ “ ” ÿ ä ç ⁄ Ÿ › é", CTOD("06/10/2012"))
INSERT INTO Foxy_CP1250 VALUES ("¡ » œ Ã … Õ “ ” ÿ ä ç ⁄ Ÿ › é", CTOD("11/10/2012"))
INSERT INTO Foxy_CP1250 VALUES ("¡ » œ Ã … Õ “ ” ÿ ä ç ⁄ Ÿ › é", CTOD("16/10/2012"))
INSERT INTO Foxy_CP1250 VALUES ("¡ » œ Ã … Õ “ ” ÿ ä ç ⁄ Ÿ › é", CTOD("21/10/2012"))
INSERT INTO Foxy_CP1250 VALUES ("¡ » œ Ã … Õ “ ” ÿ ä ç ⁄ Ÿ › é", CTOD("26/10/2012"))

m.temp=sys(2015)
create report (m.temp) from foxy_cp1250 COLUMN 

with _screen.oFoxyPreviewer
	.lQuietMode=.t.
	.lPDFEmbedFonts=.t.
	.lPDFReplaceFonts=.f.
	.lPDFCanEdit=.f.
	.cCodePage="1250"
endwith

report form (m.temp) PREVIEW 
report form (m.temp) object type 10 to file "test1.pdf" PREVIEW 
erase (forceext(m.temp,"*"))