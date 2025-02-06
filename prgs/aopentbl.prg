
local laObjects[1], ;
  lnObjects, ;
  lcDirectory, ;
  lcCommon, ;
  lnI, ;
  loObject, ;
  lcDatabase, ;
  lcTable

lnObjects   = amembers(laObjects, toDE, 2)
lcDirectory = oApp.cDataDir
for lnI = 1 to lnObjects
  loObject = evaluate('toDE.' +
   laObjects[lnI])
  if upper(loObject.BaseClass) = 'CURSOR'
    lcDatabase = loObject.Database
    if empty(lcDatabase)
      lcTable = loObject.CursorSource
      loObject.CursorSource = ;
   lcDirectory + ;
        substr(lcTable,;
   rat('\', lcTable) + 1)
    else
      loObject.Database = lcDirectory + ;
        substr(lcDatabase, rat('\',;
   lcDatabase) + 1)
    endif empty(lcDatabase)
  endif upper(loObject.BaseClass) = 'CURSOR'
next lnI