import 'dart:ui';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ChartPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ChartPageState();
}

class _ChartPageState extends State<ChartPage> {
  static const double barWidth = 22;
  int touchedIndex = -1;
  int pieTouchedIndex = -1;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('图表页面'),
      ),
      body: Column(
        children: [
          Expanded(child: ListView(
            children: [
              Padding(padding: EdgeInsets.only(top: 20),),
              InkWell(
                child: Padding(padding: EdgeInsets.only(left: 16, right: 16, bottom: 16),
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    width: MediaQuery.of(context).size.width, height: 60,
                    child: Text("1.折线图1", style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold,),),
                  ),
                ),
                onTap: (){
                  Fluttertoast.showToast(msg: "折线图1");
                },
              ),
              Padding(padding: EdgeInsets.only(top: 10, left: 16, right: 6),
                child: AspectRatio(
                  aspectRatio: 1.23,
                  child: Container(
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(18)),
                      gradient: LinearGradient(
                        colors: [
                          Color(0xff2c274c),
                          Color(0xff46426c),
                        ],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.only(left: 16, right: 6, top: 15, bottom: 15,),
                      child: LineChart(
                        LineChartData(
                          lineTouchData: LineTouchData(
                              handleBuiltInTouches: true,
                              touchTooltipData: LineTouchTooltipData(
                                tooltipBgColor: Colors.blueGrey.withOpacity(0.8),
                              )
                          ),
                          gridData: FlGridData(show: true),
                          titlesData: FlTitlesData(
                            bottomTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 12,
                                margin: 15,
                                interval: 2,
                                getTextStyles: (context, value) => const TextStyle(
                                  color: Color(0xff72719b),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                                getTitles: (value){
                                  switch (value.toInt()) {
                                    case 2:
                                      return "2月";
                                    case 4:
                                      return "4月";
                                    case 6:
                                      return "6月";
                                    case 8:
                                      return "8月";
                                    case 10:
                                      return '10月';
                                  }
                                  return '';
                                }
                            ),
                            rightTitles: SideTitles(showTitles: false),
                            topTitles: SideTitles(showTitles: false),
                            leftTitles: SideTitles(
                              getTitles: (value){
                                switch (value.toInt()) {
                                  case 1:
                                    return '60';
                                  case 2:
                                    return '70';
                                  case 3:
                                    return '80';
                                  case 4:
                                    return '80';
                                  case 5:
                                    return '100';
                                }
                                return '';
                              },
                              showTitles: true,
                              margin: 8,
                              interval: 1,
                              reservedSize: 40,
                              getTextStyles: (context,value) => const TextStyle(
                                color: Color(0xff75729e),
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          borderData: FlBorderData(
                            show: true,
                            border: const Border(
                              bottom: BorderSide(color: Color(0xff4e4965), width: 4),
                              left: BorderSide(color: Colors.transparent),
                              top: BorderSide(color: Colors.transparent),
                              right: BorderSide(color: Colors.transparent),
                            ),
                          ),
                          lineBarsData: [
                            LineChartBarData(
                              isCurved: true, ///是否曲线
                              colors: [Colors.orange], ///线条颜色
                              barWidth: 6,
                              isStrokeCapRound: true, ///是否圆头
                              dotData: FlDotData(show: false),///线段上是否显示坐标点
                              belowBarData: BarAreaData(show: false),///下方是否显示面积区
                              spots: [
                                FlSpot(1, 1),
                                FlSpot(3, 1.5),
                                FlSpot(4, 1.2),
                                FlSpot(5, 3),
                                FlSpot(6, 2),
                                FlSpot(7, 2.8),
                                FlSpot(8, 3.5),
                                FlSpot(9, 2.7),
                                FlSpot(10, 4.5),
                                FlSpot(11, 4.6),
                              ],
                            ),
                            LineChartBarData(
                              isCurved: true,
                              colors: [Color(0xff4af699)],
                              barWidth: 6,
                              isStrokeCapRound: true,
                              dotData: FlDotData(show: false),
                              belowBarData: BarAreaData(show: false),
                              spots: [
                                FlSpot(1, 1),
                                FlSpot(3, 3.5),
                                FlSpot(5, 1.5),
                                FlSpot(6, 4),
                                FlSpot(7, 2.3),
                                FlSpot(10, 1),
                                FlSpot(11, 3),
                              ],
                            ),
                            LineChartBarData(
                              isCurved: true,
                              colors: [Color(0xff27b6fc)],
                              barWidth: 6,
                              isStrokeCapRound: true,
                              dotData: FlDotData(show: false),
                              belowBarData: BarAreaData(show: false),
                              spots: [
                                FlSpot(1, 3.6),
                                FlSpot(2, 1.5),
                                FlSpot(5, 2.4),
                                FlSpot(7, 4.2),
                                FlSpot(9, 4.6),
                                FlSpot(10, 2.5),
                                FlSpot(11, 2.5),
                              ],
                            ),
                          ],
                          minX: 0,
                          maxX: 12,
                          minY: 0,
                          maxY: 5,
                        ),
                        swapAnimationDuration: const Duration(milliseconds: 250),
                      ),
                    ),
                  ),
                ),
              ),

              Padding(padding: EdgeInsets.only(top: 30),),
              InkWell(
                child: Padding(padding: EdgeInsets.only(left: 16, right: 16, bottom: 16),
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    width: MediaQuery.of(context).size.width, height: 60,
                    child: Text("2.折线图2", style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold,),),
                  ),
                ),
                onTap: (){
                  Fluttertoast.showToast(msg: "折线图2");
                },
              ),
              Padding(padding: EdgeInsets.only(top: 10, left: 16, right: 6),
                child: AspectRatio(
                  aspectRatio: 1.23,
                  child: Container(
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(18)),
                      gradient: LinearGradient(
                        colors: [
                          Color(0xff2c274c),
                          Color(0xff46426c),
                        ],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.only(left: 16, right: 6, top: 15, bottom: 15,),
                      child: LineChart(
                        LineChartData(
                          lineTouchData: LineTouchData(
                              handleBuiltInTouches: true,
                              touchTooltipData: LineTouchTooltipData(
                                tooltipBgColor: Colors.blueGrey.withOpacity(0.8),
                              )
                          ),
                          gridData: FlGridData(show: true),
                          titlesData: FlTitlesData(
                            bottomTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 12,
                                margin: 15,
                                interval: 2,
                                getTextStyles: (context, value) => const TextStyle(
                                  color: Color(0xff72719b),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                                getTitles: (value){
                                  switch (value.toInt()) {
                                    case 2:
                                      return "2月";
                                    case 4:
                                      return "4月";
                                    case 6:
                                      return "6月";
                                    case 8:
                                      return "8月";
                                    case 10:
                                      return '10月';
                                  }
                                  return '';
                                }
                            ),
                            rightTitles: SideTitles(showTitles: false),
                            topTitles: SideTitles(showTitles: false),
                            leftTitles: SideTitles(
                              getTitles: (value){
                                switch (value.toInt()) {
                                  case 1:
                                    return '60';
                                  case 2:
                                    return '70';
                                  case 3:
                                    return '80';
                                  case 4:
                                    return '80';
                                  case 5:
                                    return '100';
                                }
                                return '';
                              },
                              showTitles: true,
                              margin: 8,
                              interval: 1,
                              reservedSize: 40,
                              getTextStyles: (context,value) => const TextStyle(
                                color: Color(0xff75729e),
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          borderData: FlBorderData(
                            show: true,
                            border: const Border(
                              bottom: BorderSide(color: Color(0xff4e4965), width: 4),
                              left: BorderSide(color: Colors.transparent),
                              top: BorderSide(color: Colors.transparent),
                              right: BorderSide(color: Colors.transparent),
                            ),
                          ),
                          lineBarsData: [
                            LineChartBarData(
                              isCurved: true,
                              colors: [Colors.amberAccent],
                              barWidth: 6,
                              isStrokeCapRound: true,
                              dotData: FlDotData(show: false),
                              belowBarData: BarAreaData(show: true),
                              spots: [
                                FlSpot(1, 1.6),
                                FlSpot(3, 2.5),
                                FlSpot(5, 2.4),
                                FlSpot(7, 4.2),
                                FlSpot(9, 4.6),
                                FlSpot(10, 2.5),
                                FlSpot(11, 2.5),
                                FlSpot(12, 4.5),
                              ],
                            ),
                          ],
                          minX: 0,
                          maxX: 12,
                          minY: 0,
                          maxY: 5,
                        ),
                        swapAnimationDuration: const Duration(milliseconds: 250),
                      ),
                    ),
                  ),
                ),
              ),

              Padding(padding: EdgeInsets.only(top: 30),),
              InkWell(
                child: Padding(padding: EdgeInsets.only(left: 16, right: 16, bottom: 16),
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    width: MediaQuery.of(context).size.width, height: 60,
                    child: Text("3.柱状图1", style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold,),),
                  ),
                ),
                onTap: (){
                  Fluttertoast.showToast(msg: "柱状图1");
                },
              ),
              Padding(padding: EdgeInsets.only(top: 10, left: 16, right: 6),
                child: AspectRatio(
                  aspectRatio: 1.23,
                  child: Container(
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(18)),
                      gradient: LinearGradient(
                        colors: [
                          Color(0xff2c274c),
                          Color(0xff46426c),
                        ],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.only(left: 16, right: 6, top: 15, bottom: 15,),
                      child: BarChart(
                        BarChartData(
                          barTouchData: BarTouchData(
                            enabled: true,
                            touchTooltipData: BarTouchTooltipData(
                              tooltipBgColor: Colors.transparent,
                              tooltipPadding: const EdgeInsets.all(0),
                              tooltipMargin: 8,
                              getTooltipItem: (
                                  BarChartGroupData group,
                                  int groupIndex,
                                  BarChartRodData rod,
                                  int rodIndex,
                                  ){
                                return BarTooltipItem(rod.y.round().toString(), TextStyle(color: Colors.white, fontWeight: FontWeight.bold));
                              }
                            ),
                          ),
                          titlesData: FlTitlesData(
                            show: true,
                            bottomTitles: SideTitles(
                              showTitles: true,
                              getTextStyles: (context, value) => const TextStyle(
                                color: Color(0xff7589a2),
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                              margin: 20,
                              getTitles: (double value) {
                                switch (value.toInt()) {
                                  case 0:
                                    return "Mn";
                                  case 1:
                                    return "Te";
                                  case 2:
                                    return "Wn";
                                  case 3:
                                    return "Tu";
                                  case 4:
                                    return "Fr";
                                  case 5:
                                    return "St";
                                  case 6:
                                    return "Sn";
                                  default:
                                    return "";
                                }
                              }
                            ),
                            leftTitles: SideTitles(showTitles: false),
                            rightTitles: SideTitles(showTitles: false),
                            topTitles: SideTitles(showTitles: false),
                          ),
                          borderData: FlBorderData(
                            show: false,
                          ),
                          barGroups: [
                            BarChartGroupData(
                              x: 0,
                              barRods: [
                                BarChartRodData(
                                  y: 8,
                                  colors: [Colors.lightBlueAccent, Colors.greenAccent],
                                ),
                              ],
                              showingTooltipIndicators: [0],
                            ),
                            BarChartGroupData(
                              x: 1,
                              barRods: [
                                BarChartRodData(
                                    y: 10, colors: [Colors.lightBlueAccent, Colors.greenAccent])
                              ],
                              showingTooltipIndicators: [0],
                            ),
                            BarChartGroupData(
                              x: 2,
                              barRods: [
                                BarChartRodData(
                                    y: 14, colors: [Colors.lightBlueAccent, Colors.greenAccent])
                              ],
                              showingTooltipIndicators: [0],
                            ),
                            BarChartGroupData(
                              x: 3,
                              barRods: [
                                BarChartRodData(
                                    y: 15, colors: [Colors.lightBlueAccent, Colors.greenAccent])
                              ],
                              showingTooltipIndicators: [0],
                            ),
                            BarChartGroupData(
                              x: 3,
                              barRods: [
                                BarChartRodData(
                                    y: 13, colors: [Colors.lightBlueAccent, Colors.greenAccent])
                              ],
                              showingTooltipIndicators: [0],
                            ),
                            BarChartGroupData(
                              x: 3,
                              barRods: [
                                BarChartRodData(
                                    y: 10, colors: [Colors.lightBlueAccent, Colors.greenAccent])
                              ],
                              showingTooltipIndicators: [0],
                            ),
                          ],
                          alignment: BarChartAlignment.spaceAround,
                          maxY: 20,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              Padding(padding: EdgeInsets.only(top: 30),),
              InkWell(
                child: Padding(padding: EdgeInsets.only(left: 16, right: 16, bottom: 16),
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    width: MediaQuery.of(context).size.width, height: 60,
                    child: Text("4.柱状图2", style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold,),),
                  ),
                ),
                onTap: (){
                  Fluttertoast.showToast(msg: "柱状图2");
                },
              ),
              Padding(padding: EdgeInsets.only(top: 10, left: 16, right: 6),
                child: AspectRatio(
                  aspectRatio: 0.8,
                  child: Container(
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(18)),
                      gradient: LinearGradient(
                        colors: [
                          Color(0xff2c274c),
                          Color(0xff46426c),
                        ],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.only(left: 16, right: 6, top: 15, bottom: 15,),
                      child: BarChart(
                        BarChartData(
                          barTouchData: BarTouchData(
                            touchCallback: (FlTouchEvent event, barTouchResponse) {
                              if (!event.isInterestedForInteractions ||
                                  barTouchResponse == null ||
                                  barTouchResponse.spot == null) {
                                setState(() {
                                  touchedIndex = -1;
                                });
                                return;
                              }
                              setState(() {
                                touchedIndex = barTouchResponse.spot!.touchedBarGroupIndex;
                              });
                            },
                          ),
                          gridData: FlGridData(
                            show: true,
                            checkToShowHorizontalLine: (value) => value % 5 == 0,
                            getDrawingHorizontalLine: (value) {
                              if (value == 0) {
                                return FlLine(
                                    color: const Color(0xff363753), strokeWidth: 3);
                              }
                              return FlLine(
                                color: const Color(0xff2a2747),
                                strokeWidth: 0.8,
                              );
                            },
                          ),
                          titlesData: FlTitlesData(
                            show: true,
                            bottomTitles: SideTitles(
                                showTitles: true,
                                getTextStyles: (context, value) => const TextStyle(
                                  color: Color(0xff7589a2),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                ),
                                margin: 10,
                                getTitles: (double value) {
                                  switch (value.toInt()) {
                                    case 0:
                                      return "Mn";
                                    case 1:
                                      return "Te";
                                    case 2:
                                      return "Wn";
                                    case 3:
                                      return "Tu";
                                    case 4:
                                      return "Fr";
                                    case 5:
                                      return "St";
                                    case 6:
                                      return "Sn";
                                    default:
                                      return "";
                                  }
                                }
                            ),
                            leftTitles: SideTitles(
                              showTitles: true,
                              getTextStyles: (context, value) =>
                              const TextStyle(color: Colors.white, fontSize: 10),
                              rotateAngle: 45,
                              getTitles: (double value) {
                                if (value == 0) {
                                  return '0';
                                }
                                return '${value.toInt()}0k';
                              },
                              interval: 5,
                              margin: 8,
                              reservedSize: 30,
                            ),
                            rightTitles: SideTitles(
                              showTitles: true,
                              getTextStyles: (context, value) =>
                              const TextStyle(color: Colors.white, fontSize: 10),
                              rotateAngle: 90,
                              getTitles: (double value) {
                                if (value == 0) {
                                  return '0';
                                }
                                return '${value.toInt()}0k';
                              },
                              interval: 5,
                              margin: 8,
                              reservedSize: 30,
                            ),
                            topTitles: SideTitles(
                                showTitles: true,
                                getTextStyles: (context, value) => const TextStyle(
                                  color: Color(0xff7589a2),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                ),
                                margin: 10,
                                getTitles: (double value) {
                                  switch (value.toInt()) {
                                    case 0:
                                      return "Mn";
                                    case 1:
                                      return "Te";
                                    case 2:
                                      return "Wn";
                                    case 3:
                                      return "Tu";
                                    case 4:
                                      return "Fr";
                                    case 5:
                                      return "St";
                                    case 6:
                                      return "Sn";
                                    default:
                                      return "";
                                  }
                                }
                            ),
                          ),
                          borderData: FlBorderData(
                            show: false,
                          ),
                          barGroups: [
                            BarChartGroupData(
                              x: 0,
                              barRods: [
                                BarChartRodData(
                                  y: 15.1,
                                  width: barWidth,
                                  borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(6),
                                      topRight: Radius.circular(6)),
                                  rodStackItems: [
                                    BarChartRodStackItem(
                                        0,
                                        2,
                                        const Color(0xff2bdb90),
                                        BorderSide(
                                            color: Colors.white,
                                            width: touchedIndex == 0 ? 2 : 0)),
                                    BarChartRodStackItem(
                                        2,
                                        5,
                                        const Color(0xffffdd80),
                                        BorderSide(
                                            color: Colors.white,
                                            width: touchedIndex == 0 ? 2 : 0)),
                                    BarChartRodStackItem(
                                        5,
                                        7.5,
                                        const Color(0xffff4d94),
                                        BorderSide(
                                            color: Colors.white,
                                            width: touchedIndex == 0 ? 2 : 0)),
                                    BarChartRodStackItem(
                                        7.5,
                                        15.5,
                                        const Color(0xff19bfff),
                                        BorderSide(
                                            color: Colors.white,
                                            width: touchedIndex == 0 ? 2 : 0)),
                                  ],
                                ),
                              ],
                            ),
                            BarChartGroupData(
                              x: 1,
                              barRods: [
                                BarChartRodData(
                                  y: -14,
                                  width: barWidth,
                                  borderRadius: const BorderRadius.only(
                                      bottomLeft: Radius.circular(6),
                                      bottomRight: Radius.circular(6)),
                                  rodStackItems: [
                                    BarChartRodStackItem(
                                        0,
                                        -1.8,
                                        const Color(0xff2bdb90),
                                        BorderSide(
                                            color: Colors.white,
                                            width: touchedIndex == 1 ? 2 : 0)),
                                    BarChartRodStackItem(
                                        -1.8,
                                        -4.5,
                                        const Color(0xffffdd80),
                                        BorderSide(
                                            color: Colors.white,
                                            width: touchedIndex == 1 ? 2 : 0)),
                                    BarChartRodStackItem(
                                        -4.5,
                                        -7.5,
                                        const Color(0xffff4d94),
                                        BorderSide(
                                            color: Colors.white,
                                            width: touchedIndex == 1 ? 2 : 0)),
                                    BarChartRodStackItem(
                                        -7.5,
                                        -14,
                                        const Color(0xff19bfff),
                                        BorderSide(
                                            color: Colors.white,
                                            width: touchedIndex == 1 ? 2 : 0)),
                                  ],
                                ),
                              ],
                            ),
                            BarChartGroupData(
                              x: 2,
                              barRods: [
                                BarChartRodData(
                                  y: 13,
                                  width: barWidth,
                                  borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(6),
                                      topRight: Radius.circular(6)),
                                  rodStackItems: [
                                    BarChartRodStackItem(
                                        0,
                                        1.5,
                                        const Color(0xff2bdb90),
                                        BorderSide(
                                            color: Colors.white,
                                            width: touchedIndex == 2 ? 2 : 0)),
                                    BarChartRodStackItem(
                                        1.5,
                                        3.5,
                                        const Color(0xffffdd80),
                                        BorderSide(
                                            color: Colors.white,
                                            width: touchedIndex == 2 ? 2 : 0)),
                                    BarChartRodStackItem(
                                        3.5,
                                        7,
                                        const Color(0xffff4d94),
                                        BorderSide(
                                            color: Colors.white,
                                            width: touchedIndex == 2 ? 2 : 0)),
                                    BarChartRodStackItem(
                                        7,
                                        13,
                                        const Color(0xff19bfff),
                                        BorderSide(
                                            color: Colors.white,
                                            width: touchedIndex == 2 ? 2 : 0)),
                                  ],
                                ),
                              ],
                            ),
                            BarChartGroupData(
                              x: 3,
                              barRods: [
                                BarChartRodData(
                                  y: 13.5,
                                  width: barWidth,
                                  borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(6),
                                      topRight: Radius.circular(6)),
                                  rodStackItems: [
                                    BarChartRodStackItem(
                                        0,
                                        1.5,
                                        const Color(0xff2bdb90),
                                        BorderSide(
                                            color: Colors.white,
                                            width: touchedIndex == 3 ? 2 : 0)),
                                    BarChartRodStackItem(
                                        1.5,
                                        3,
                                        const Color(0xffffdd80),
                                        BorderSide(
                                            color: Colors.white,
                                            width: touchedIndex == 3 ? 2 : 0)),
                                    BarChartRodStackItem(
                                        3,
                                        7,
                                        const Color(0xffff4d94),
                                        BorderSide(
                                            color: Colors.white,
                                            width: touchedIndex == 3 ? 2 : 0)),
                                    BarChartRodStackItem(
                                        7,
                                        13.5,
                                        const Color(0xff19bfff),
                                        BorderSide(
                                            color: Colors.white,
                                            width: touchedIndex == 3 ? 2 : 0)),
                                  ],
                                ),
                              ],
                            ),
                            BarChartGroupData(
                              x: 4,
                              barRods: [
                                BarChartRodData(
                                  y: -18,
                                  width: barWidth,
                                  borderRadius: const BorderRadius.only(
                                      bottomLeft: Radius.circular(6),
                                      bottomRight: Radius.circular(6)),
                                  rodStackItems: [
                                    BarChartRodStackItem(
                                        0,
                                        -2,
                                        const Color(0xff2bdb90),
                                        BorderSide(
                                            color: Colors.white,
                                            width: touchedIndex == 4 ? 2 : 0)),
                                    BarChartRodStackItem(
                                        -2,
                                        -4,
                                        const Color(0xffffdd80),
                                        BorderSide(
                                            color: Colors.white,
                                            width: touchedIndex == 4 ? 2 : 0)),
                                    BarChartRodStackItem(
                                        -4,
                                        -9,
                                        const Color(0xffff4d94),
                                        BorderSide(
                                            color: Colors.white,
                                            width: touchedIndex == 4 ? 2 : 0)),
                                    BarChartRodStackItem(
                                        -9,
                                        -18,
                                        const Color(0xff19bfff),
                                        BorderSide(
                                            color: Colors.white,
                                            width: touchedIndex == 4 ? 2 : 0)),
                                  ],
                                ),
                              ],
                            ),
                            BarChartGroupData(
                              x: 5,
                              barRods: [
                                BarChartRodData(
                                  y: -17,
                                  width: barWidth,
                                  borderRadius: const BorderRadius.only(
                                      bottomLeft: Radius.circular(6),
                                      bottomRight: Radius.circular(6)),
                                  rodStackItems: [
                                    BarChartRodStackItem(
                                        0,
                                        -1.2,
                                        const Color(0xff2bdb90),
                                        BorderSide(
                                            color: Colors.white,
                                            width: touchedIndex == 5 ? 2 : 0)),
                                    BarChartRodStackItem(
                                        -1.2,
                                        -2.7,
                                        const Color(0xffffdd80),
                                        BorderSide(
                                            color: Colors.white,
                                            width: touchedIndex == 5 ? 2 : 0)),
                                    BarChartRodStackItem(
                                        -2.7,
                                        -7,
                                        const Color(0xffff4d94),
                                        BorderSide(
                                            color: Colors.white,
                                            width: touchedIndex == 5 ? 2 : 0)),
                                    BarChartRodStackItem(
                                        -7,
                                        -17,
                                        const Color(0xff19bfff),
                                        BorderSide(
                                            color: Colors.white,
                                            width: touchedIndex == 5 ? 2 : 0)),
                                  ],
                                ),
                              ],
                            ),
                            BarChartGroupData(
                              x: 6,
                              barRods: [
                                BarChartRodData(
                                  y: 16,
                                  width: barWidth,
                                  borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(6),
                                      topRight: Radius.circular(6)),
                                  rodStackItems: [
                                    BarChartRodStackItem(
                                        0,
                                        1.2,
                                        const Color(0xff2bdb90),
                                        BorderSide(
                                            color: Colors.white,
                                            width: touchedIndex == 6 ? 2 : 0)),
                                    BarChartRodStackItem(
                                        1.2,
                                        6,
                                        const Color(0xffffdd80),
                                        BorderSide(
                                            color: Colors.white,
                                            width: touchedIndex == 6 ? 2 : 0)),
                                    BarChartRodStackItem(
                                        6,
                                        11,
                                        const Color(0xffff4d94),
                                        BorderSide(
                                            color: Colors.white,
                                            width: touchedIndex == 6 ? 2 : 0)),
                                    BarChartRodStackItem(
                                        11,
                                        17,
                                        const Color(0xff19bfff),
                                        BorderSide(
                                            color: Colors.white,
                                            width: touchedIndex == 6 ? 2 : 0)),
                                  ],
                                ),
                              ],
                            ),
                          ],
                          alignment: BarChartAlignment.center,
                          maxY: 20,
                          minY: -20,
                          groupsSpace: 12,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              Padding(padding: EdgeInsets.only(top: 30),),
              InkWell(
                child: Padding(padding: EdgeInsets.only(left: 16, right: 16, bottom: 16),
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    width: MediaQuery.of(context).size.width, height: 60,
                    child: Text("5.饼状图1", style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold,),),
                  ),
                ),
                onTap: (){
                  Fluttertoast.showToast(msg: "饼状图1");
                },
              ),
              Padding(padding: EdgeInsets.only(top: 10, left: 16, right: 6),
                child: AspectRatio(
                  aspectRatio: 1.0,
                  child: Container(
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(18)),
                      gradient: LinearGradient(
                        colors: [
                          Color(0xff2c274c),
                          Color(0xff46426c),
                        ],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.only(left: 16, right: 6, top: 15, bottom: 15,),
                      child: PieChart(
                        PieChartData(
                          pieTouchData: PieTouchData(
                              touchCallback: (FlTouchEvent event, pieTouchResponse) {
                                setState(() {
                                  if (!event.isInterestedForInteractions ||
                                      pieTouchResponse == null ||
                                      pieTouchResponse.touchedSection == null) {
                                    pieTouchedIndex = -1;
                                    return;
                                  }
                                  pieTouchedIndex =
                                      pieTouchResponse.touchedSection!.touchedSectionIndex;
                                });
                              }),
                          borderData: FlBorderData(
                            show: false,
                          ),
                          sectionsSpace: 10,
                          centerSpaceRadius: 30,
                          sections: List.generate(4, (i) {
                            final isTouched = i == touchedIndex;
                            final fontSize = isTouched ? 20.0 : 16.0;
                            final radius = isTouched ? 110.0 : 100.0;
                            final widgetSize = isTouched ? 55.0 : 40.0;

                            switch (i) {
                              case 0:
                                return PieChartSectionData(
                                  color: const Color(0xff0293ee),
                                  value: 40,
                                  title: '40%',
                                  radius: radius,
                                  titleStyle: TextStyle(
                                      fontSize: fontSize,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xffffffff)),
                                  badgeWidget: _Badge(
                                    'assets/ophthalmology-svgrepo-com.svg',
                                    size: widgetSize,
                                    borderColor: const Color(0xff0293ee),
                                  ),
                                  badgePositionPercentageOffset: .98,
                                );
                              case 1:
                                return PieChartSectionData(
                                  color: const Color(0xfff8b250),
                                  value: 30,
                                  title: '30%',
                                  radius: radius,
                                  titleStyle: TextStyle(
                                      fontSize: fontSize,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xffffffff)),
                                  badgeWidget: _Badge(
                                    'assets/librarian-svgrepo-com.svg',
                                    size: widgetSize,
                                    borderColor: const Color(0xfff8b250),
                                  ),
                                  badgePositionPercentageOffset: .98,
                                );
                              case 2:
                                return PieChartSectionData(
                                  color: const Color(0xff845bef),
                                  value: 16,
                                  title: '16%',
                                  radius: radius,
                                  titleStyle: TextStyle(
                                      fontSize: fontSize,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xffffffff)),
                                  badgeWidget: _Badge(
                                    'assets/fitness-svgrepo-com.svg',
                                    size: widgetSize,
                                    borderColor: const Color(0xff845bef),
                                  ),
                                  badgePositionPercentageOffset: .98,
                                );
                              case 3:
                                return PieChartSectionData(
                                  color: const Color(0xff13d38e),
                                  value: 15,
                                  title: '15%',
                                  radius: radius,
                                  titleStyle: TextStyle(
                                      fontSize: fontSize,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xffffffff)),
                                  badgeWidget: _Badge(
                                    'assets/worker-svgrepo-com.svg',
                                    size: widgetSize,
                                    borderColor: const Color(0xff13d38e),
                                  ),
                                  badgePositionPercentageOffset: .98,
                                );
                              default:
                                throw 'Oh no';
                            }
                          }),
                        ),

                      ),
                    ),
                  ),
                ),
              ),

            ],
          ))
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String svgAsset;
  final double size;
  final Color borderColor;

  const _Badge(
      this.svgAsset, {
        Key? key,
        required this.size,
        required this.borderColor,
      }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: PieChart.defaultDuration,
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(
          color: borderColor,
          width: 2,
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withOpacity(.5),
            offset: const Offset(3, 3),
            blurRadius: 3,
          ),
        ],
      ),
      padding: EdgeInsets.all(size * .15),
      child: Center(
        child: SvgPicture.asset(
          svgAsset,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}