CREATE CURSOR TestData (cData1 M)

LOCAL cText

TEXT TO cText NOSHOW
	Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aenean commodo ligula eget dolor. Aenean massa. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Donec quam felis, ultricies nec, pellentesque eu, pretium quis, sem. Nulla consequat massa quis enim. Donec pede justo, fringilla vel, aliquet nec, vulputate eget, arcu. In enim justo, rhoncus ut, imperdiet a, venenatis vitae, justo. Nullam dictum felis eu pede mollis pretium. Integer tincidunt. Cras dapibus. Vivamus elementum semper nisi. Aenean vulputate eleifend tellus. Aenean leo ligula, porttitor eu, consequat vitae, eleifend ac, enim. Aliquam lorem ante, dapibus in, viverra quis, feugiat a, tellus. Phasellus viverra nulla ut metus varius laoreet. Quisque rutrum. Aenean imperdiet. Etiam ultricies nisi vel augue. Curabitur ullamcorper ultricies nisi. Nam eget dui. Etiam rhoncus. Maecenas tempus, tellus eget condimentum rhoncus, sem quam semper libero, sit amet adipiscing sem neque sed ipsum. Nam quam nunc, blandit vel, luctus pulvinar, hendrerit id, lorem. Maecenas nec odio et ante tincidunt tempus. Donec vitae sapien ut libero venenatis faucibus. Nullam quis ante. Etiam sit amet orci eget eros faucibus tincidunt. Duis leo. Sed fringilla mauris sit amet nibh. Donec sodales sagittis magna. Sed consequat, leo eget bibendum sodales, augue velit cursus nunc, 
ENDTEXT

INSERT INTO TestData (cData1) VALUES (cText)

SET PROCEDURE TO FoxyPreviewerCaller.prg ADDITIVE 

LOCAL loReport as "FoxyPreviewerCaller" OF "FoxyPreviewerCaller.Prg"
loReport = CREATEOBJECT("FoxyPreviewerCaller")


WITH loReport as ReportHelper
	.nWindowState 			= 2		&& numeric, defines the previewform.WindowState 0 = Normal, 2 = Maximized new! 
	.nDockType 				= 0		&& logical or numeric (0-4). If False, the dock will follow the resource file used. Or numeric, to force the toolbar docking. new!
	.nMaxMiniatureDisplay	= 32	&& Numeric;  Number of PROOF to display on proof sheet

	.cTitle = "Main test"
*!*		.cDestFile = "test.pdf"

	.cSaveDefName = "test"
	.AddReport("ReportFile.frx")
	.RunReport()
	
	DO CASE
	CASE .lPrinted	
		MESSAGEBOX("Report was printed !",64, "Report status")
	CASE .lSaved
		MESSAGEBOX("Report was saved as file:" + CHR(13) + .cDestFile,;
			64, ;
			"Report status")
		** =Thisform.OpenFile(.cDestFile)
	OTHERWISE
		MESSAGEBOX("Report Preview was closed without saving or printing",48, "Report status")
	ENDCASE
ENDWITH

USE IN "TestData"