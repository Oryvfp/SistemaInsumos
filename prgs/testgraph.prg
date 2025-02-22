
 
#Define VtChChartType3dBar           0
#Define VtChChartType2dBar           1

 

Public loChartForm
loChartForm = Createobject('myForm')
loChartForm.Show

 

Define Class myForm As Form
  Top = 0
  Left = 0
  Height = 520
  Width = 790

  Add Object mschart As OleControl With ;
    Top = 10, ;
    Left = 5, ;
    Height = 500, ;
    Width = 780, ;
    Name = "MsChart", ;
    OleClass = 'MSChart20Lib.MsChart'

 

  Procedure Init
    Select fecha,Sum(cantrest) As Cantrest ;
      from ('C:\Sistemayocca\proj\ETIQUETA\filtro.dbf') ;
      group By 1 ;
      where !(pieza == '') ;
      into Cursor crsChart
      brow


    With Thisform.mschart
      && Set Chart parameters using methods.
      .ChartType = VtChChartType2dBar
      
      rowLabelCount    = 1
      columnLabelCount = 0
      rowCount         = Reccount()
      ColumnCount      = 1
      
      .DataGrid.SetSize(m.rowLabelCount, m.columnLabelCount, m.rowCount, m.ColumnCount )

      .Column = 1
      Scan
        .Row = Recno()
        .Data = Cantrest
        .DataGrid.RowLabel(Recno(),1) = fecha
      ENDSCAN
    Endwith

  Endproc
Enddefine

 