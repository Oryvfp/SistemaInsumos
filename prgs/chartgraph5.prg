**#INCLUDE "mschrt20.h"
#define VtChChartType3dBar                                0
#define VtChChartType2dBar                                1
#define VtChChartType3dLine                               2
#define VtChChartType2dLine                               3
#define VtChChartType3dArea                               4
#define VtChChartType2dArea                               5
#define VtChChartType2dPie                                14

#DEFINE VtChLabelComponentValue    1    && The value of the data point appears in the label.
#DEFINE VtChLabelComponentPercent    2    && The value of the data point is displayed in the label as a percentage of the total value of the series.

#DEFINE VtChLabelLocationTypeNone    0    && Label Location - None
#DEFINE VtChLabelLocationTypeAbovePoint    1    && Label Location - AbovePoint
#DEFINE VtChLabelLocationTypeBelowPoint    2    && Label Location - BelowPoint
#DEFINE VtChLabelLocationTypeCenter    3    && Label Location - Center
#DEFINE VtChLabelLocationTypeBase    4    && Label Location - Base
#DEFINE VtChLabelLocationTypeInside    5    && Label Location - Inside pie or doughnut
#DEFINE VtChLabelLocationTypeOutside    6    && Label Location - Outside pie or doughnut
#DEFINE VtChLabelLocationTypeLeft    7    && Label Location - Left
#DEFINE VtChLabelLocationTypeRight    8    && Label Location - Right

Public oForm
oForm=Createobject('form1')
oForm.Show

Define Class form1 As Form
  Top = 0
  Left = 0
  Height = 520
  Width = 790
  DoCreate = .T.
  Name = "Form1"

  Add Object mschart As OleControl With ;
    Top = 10, ;
    Left = 5, ;
    Height = 500, ;
    Width = 780, ;
    Name = "MsChart", ;
    OleClass = 'MSChart20Lib.MsChart'

  Procedure Init
    SELECT pieza,SUM(cantrest) As stockMax;
      FROM FILTRO;
       group By 1 ;
      where !(pieza == '');
         into Cursor crsChart

    With Thisform.mschart.DataGrid
&& Set Chart parameters using methods.
      rowLabelCount = 0
      columnLabelCount = Reccount()
      rowCount = 1
      ColumnCount = Reccount()
      .SetSize(rowLabelCount, columnLabelCount, rowCount, ColumnCount )

      With Thisform.mschart
        Scan
          .Column = Recno()
          .Row = 1
          .Data = stockMax
        
        Endscan
      Endwith
&& Then assign labels to first Level.
      labelIndex = 1
      Scan
        Column = Recno()
        .ColumnLabel(m.column, labelIndex) = pieza
      Endscan
    Endwith
    Thisform.mschart.ShowLegend = .T.
    Thisform.mschart.ChartType = VtChChartType2dPie && VtChChartType2dBar
    For Each serX In Thisform.mschart.Plot.SeriesCollection
      With serX.Datapoints.Item(-1).DatapointLabel
        .Component = VtChLabelComponentPercent  && Show as percent
        .LocationType = VtChLabelLocationTypeOutside && Inside pie slice
        .PercentFormat = '0%'
      ENDWITH
    Endfor
  Endproc
Enddefine