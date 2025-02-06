FUNCTION ShellExecute
LPARAMETERS cFile, cOperation, cDefaultDirectory, cParameters
LOCAL nHwnd, cParameters, cDefaultDirectory, nShowWindow
DECLARE INTEGER ShellExecute IN shell32.dll AS ShellExecute;
	INTEGER nHwnd,;
	STRING @cOperation,;
	STRING @cFile,;
	STRING @cParameters,;
	STRING @cDefaultDirectory,;
	INTEGER nShowWindow
nHwnd = 0
cOperation = IIF(EMPTY(cOperation),'open',cOperation)
cParameters = IIF(EMPTY(cParameters),NULL,cParameters)
cDefaultDirectory = IIF(EMPTY(cDefaultDirectory),'',cDefaultDirectory)
nShowWindow = 1
= ShellExecute(nHwnd, @cOperation, @cFile, @cParameters, @cDefaultDirectory, nShowWindow)
CLEAR DLLS