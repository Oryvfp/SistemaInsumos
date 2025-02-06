* This sample uses the HTMLListener original class from VFP9
* Accessing the FoxyPreviewer version directly from the APP

* Todo: Create a new ObjectType to allow a more simplified HTML generation

LOCAL loListener AS "HTMLListener" && OF HOME() + "FFC/PR_ReportListener.vcx"
loListener = NEWOBJECT("PR_HTMLListener", "PR_ReportListener.vcx", "FoxyPreviewer.App")
loListener.TargetFileName = "c:\TestReport.HTML"
loListener.QUIETMODE = .T.  && Optional, for hiding the ProgressBar
loListener.CopyImageFilesToExternalFileLocation = .T.	&& Copy images to HTML output dir so the created HTML will
														&& always access images from his currect directory 

* Make HTML using the Listener
REPORT FORM ;
	(_Samples + "\Solution\Reports\Colors.frx") ;
	OBJECT loListener