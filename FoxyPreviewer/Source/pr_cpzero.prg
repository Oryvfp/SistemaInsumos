* 2011-04-30
* Modified eliminating the CLOSE DATABASES command
* as suggested by Hallyson (Brazil)

* 2011-10-06
* Modified by Jacques Parent (Canada)
* Encapsulated all the main methods into a Session class, to protect the working environment
   * Modified to eliminate the need for CREATE VIEW, 
   * command that is not working correctly in the case there are
   * many SET CLASSLIB TO command.
   * I simply éliminated the CREATE VIEW by creating a "SESSION" object.

* CPZERO -- Poke a codepage byte into a database header
* Copyright Microsoft Corp, 1993-2001
*
* Usage: 
*    DO CPZERO WITH dbfname                     && marks the database with codepage 0 (i.e., no codepage)
* 
*    DO CPZERO WITH dbfname, codepage_number    && marks the database with specified codepage
*
* Some common valid numbers are:
*   Windows            1252
*   DOS                 437
*   International DOS   850

PARAMETER m.fname, m.cpbyte

PRIVATE m.mtalk, m.oCP

IF SET("TALK") = "ON"
   SET TALK OFF
   m.mtalk = "ON"
ELSE
   m.mtalk = "OFF"
ENDIF

#define C_TOTAL 29     && total code page numbers supported

IF PARAMETERS() < 2
   m.cpbyte = 0
ENDIF


#define c_buf_size 32

#define c_noopen   1
#define c_badbyte  2
#define c_notfox   3
#define c_maxerror 4

#DEFINE c_notopened_LOC 	"The table could not be opened."
#DEFINE c_invalid_page_LOC	"Invalid code page specified."
#DEFINE c_NotFoxTable_LOC	"Not a FoxPro table."

#DEFINE c_OpenTable_LOC		"Table:"


m.oCP = CREATEOBJECT("ClsCPZero")
m.oCP.Set_CP(m.fname, m.cpbyte)
RELEASE m.oCP

SET TALK &mtalk


DEFINE CLASS ClsCPZero as session
	mOldTalk = ""
	
	PROCEDURE INIT
		SET TALK OFF
	
		This.AddProperty("error_array[" + TRANSFORM(c_maxerror) + "]")
		
		This.error_array[c_noopen]  = c_notopened_LOC
		This.error_array[c_badbyte] = c_invalid_page_LOC
		This.error_array[c_notfox]  = c_NotFoxTable_LOC
		
		
		* Set up table of code pages and DBF bytes numbers
		This.AddProperty("cpnums[" + TRANSFORM(C_TOTAL) + ",2]")
		
		This.cpnums[ 1,1] = 437		&& MS-DOS, U.S.A.
		This.cpnums[ 1,2] = 1
		This.cpnums[ 2,1] = 850		&& MS-DOS, International
		This.cpnums[ 2,2] = 2
		This.cpnums[ 3,1] = 1252	&& Windows, U.S.A & West European
		This.cpnums[ 3,2] = 3
		This.cpnums[ 4,1] = 10000	&& Macintosh, U.S.A.
		This.cpnums[ 4,2] = 4
		This.cpnums[ 5,1] = 852		&& MS-DOS, East European
		This.cpnums[ 5,2] = 100
		This.cpnums[ 6,1] = 866		&& MS-DOS, Russian
		This.cpnums[ 6,2] = 101
		This.cpnums[ 7,1] = 865		&& MS-DOS, Nordic
		This.cpnums[ 7,2] = 102
		This.cpnums[ 8,1] = 861		&& MS-DOS, Iceland
		This.cpnums[ 8,2] = 103
		This.cpnums[ 9,1] = 895		&& MS-DOS, Kamenicky (Czech)
		This.cpnums[ 9,2] = 104
		This.cpnums[10,1] = 620		&& MS-DOS, Mazovia (Polish)
		This.cpnums[10,2] = 105
		This.cpnums[11,1] = 737		&& MS-DOS, Greek
		This.cpnums[11,2] = 106
		This.cpnums[12,1] = 857		&& MS-DOS, Turkey
		This.cpnums[12,2] = 107
		This.cpnums[13,1] = 863		&& MS-DOS, Canada
		This.cpnums[13,2] = 108
		This.cpnums[14,1] = 950		&& Windows, Traditional Chinese
		This.cpnums[14,2] = 120
		This.cpnums[15,1] = 949		&& Windows, Korean (Hangul)
		This.cpnums[15,2] = 121
		This.cpnums[16,1] = 936		&& Windows, Simplified Chinese
		This.cpnums[16,2] = 122
		This.cpnums[17,1] = 932		&& Windows, Japanese (Shift-jis)
		This.cpnums[17,2] = 123
		This.cpnums[18,1] = 874		&& Windows, Thai
		This.cpnums[18,2] = 124
		This.cpnums[19,1] = 10007	&& Macintosh, Russian
		This.cpnums[19,2] = 150
		This.cpnums[20,1] = 10029	&& Macintosh, East European
		This.cpnums[20,2] = 151
		This.cpnums[21,1] = 10006	&& Macintosh, Greek
		This.cpnums[21,2] = 152
		This.cpnums[22,1] = 1250	&& Windows, East European
		This.cpnums[22,2] = 200
		This.cpnums[23,1] = 1251	&& Windows, Russian
		This.cpnums[23,2] = 201
		This.cpnums[24,1] = 1253	&& Windows, Greek
		This.cpnums[24,2] = 203
		This.cpnums[25,1] = 1254	&& Windows, Turkish
		This.cpnums[25,2] = 202
		This.cpnums[26,1] = 1255	&& Windows, Hebrew (Only supported on Hebrew OS)
		This.cpnums[26,2] = 125
		This.cpnums[27,1] = 1256	&& Windows, Arabic (Only supported on Arabic OS)
		This.cpnums[27,2] = 126
		This.cpnums[28,1] = 1257	&& Windows, Baltic
		This.cpnums[28,2] = 204
		This.cpnums[29,1] = 0		&& No codepage mark.
		This.cpnums[29,2] = 0
		
	ENDPROC
	
	PROCEDURE SET_CP
		LPARAMETERS m.fname, m.cpbyte

		PRIVATE m.fp_in, m.buf, m.found_one, m.i, m.outbyte

		IF EMPTY(m.fname)
		   m.fname = getfile("DBF|SCX|VCX|FRX|LBX|MNX",c_OpenTable_LOC)
		ENDIF
		IF !EMPTY(m.fname)
		   * CLOSE DATABASES
		   m.outbyte 	= m.cpbyte
		   m.found_one 	= .F.
		   
		   FOR m.i = 1 TO C_TOTAL
		      IF m.cpbyte 		= This.cpnums[m.i,1]
		         m.outbyte 		= This.cpnums[m.i,2]
		         m.found_one 	= .T.
		         EXIT
		      ENDIF
		   ENDFOR
		   
		   IF m.found_one
		      m.cpbyte = m.outbyte
		   ELSE
		      * Was it a valid DBF byte if it wasn't a valid code page?
		      FOR m.i = 1 TO C_TOTAL
		         IF m.cpbyte = This.cpnums[m.i,2]
		            m.found_one = .T.
		         ENDIF
		      ENDFOR
		      
		      IF !m.found_one
		         This.errormsg(c_badbyte)
		         RETURN
		      ENDIF
		   ENDIF
		   
		   IF FILE(m.fname)
		       m.fp_in = FOPEN(m.fname,2)
		       
		       IF m.fp_in > 0
		          * First check that we have a FoxPro table...
		          m.buf=FREAD(m.fp_in,c_buf_size)
		          
		          IF (SUBSTR(m.buf,1,1) = CHR(139) OR SUBSTR(m.buf,1,1) = CHR(203);
		             	OR SUBSTR(m.buf,31,1) != CHR(0) OR SUBSTR(m.buf,32,1) != CHR(0))
		              =fclose(m.fp_in)
		              This.errormsg(c_notfox)
		              RETURN
		          ELSE
		              * Now poke the codepage id into byte 29
		              =FSEEK(m.fp_in,29)
		              =FWRITE(m.fp_in,CHR(m.cpbyte)) 
		              =FCLOSE(m.fp_in)
		          ENDIF
		       ELSE
		          This.errormsg(c_noopen)
		          RETURN
		       ENDIF
		    ELSE
		       This.errormsg(c_noopen)
		       RETURN
		    ENDIF
		ENDIF      
	ENDPROC
	
	PROCEDURE DESTROY
		*!* No cleanup to do since this is in a session!
	ENDPROC
	
	PROCEDURE errormsg
		LPARAMETER num

		WAIT WINDOW This.error_array[num] NOWAIT
	ENDPROC
	
ENDDEFINE
