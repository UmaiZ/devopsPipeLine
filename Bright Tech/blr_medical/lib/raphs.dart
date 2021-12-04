import 'package:blr_medical/Helpers/colors.dart';
import 'package:syncfusion_flutter_charts/sparkcharts.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:flutter/material.dart';

class GraphScreen extends StatefulWidget {
  const GraphScreen({Key? key}) : super(key: key);

  @override
  _GraphScreenState createState() => _GraphScreenState();
}

class _GraphScreenState extends State<GraphScreen>
    with TickerProviderStateMixin {
  late var _isChecked = true;



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        title: Text('Sales'),
        centerTitle:true,
      ),
      body: Column(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.02,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 13, right: 13),
            child: Column(
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _isChecked = !_isChecked;
                    });
                  },
                  child: Row(
                    children: [
                      Text('Peak Hours Today and Yesterday',
                          style: new TextStyle(
                              fontSize: 18,
                              color: kPrimaryColor,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'PoppinsMedium'))
                    ],
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.02,
                ),
                AnimatedSize(
                  vsync: this,
                  duration: Duration(milliseconds: 450),
                  child: Container(
                    height: _isChecked ? null : 0,
                    child: _isChecked
                        ? SfCartesianChart(
                            primaryXAxis: CategoryAxis(),
                            tooltipBehavior: TooltipBehavior(enable: true),
                            series: <ChartSeries<SalesData, String>>[
                                StackedColumnSeries<SalesData, String>(
                                    dataSource: <SalesData>[
                                      // Separate data source maintained for series - 1
                                      SalesData('12 - 16', 1000),
                                      SalesData('16 - 20', 1500),
                                      SalesData('20 - 24', 2000),
                                      SalesData('24 - 04', 800),
                                      SalesData('04 - 08', 700),
                                      SalesData('08 - 12', 1000),
                                    ],
                                    xValueMapper: (SalesData sales, _) =>
                                        sales.x,
                                    yValueMapper: (SalesData sales, _) =>
                                        sales.y,
                                    name: 'Yesterday',
                                    color: textGreyColor),
                                StackedColumnSeries<SalesData, String>(
                                    dataSource: <SalesData>[
                                      // // Separate data source maintained for series – 2
                                      SalesData('12 - 16', 1200),
                                      SalesData('16 - 20', 800),
                                      SalesData('20 - 24', 2300),
                                      SalesData('24 - 04', 1000),
                                      SalesData('04 - 08', 500),
                                      SalesData('08 - 12', 1200),
                                    ],
                                    xValueMapper: (SalesData sales, _) =>
                                        sales.x,
                                    yValueMapper: (SalesData sales, _) =>
                                        sales.y,
                                    name: 'Today',
                                    color: kPrimaryColor)
                              ])
                        : Container(),
                  ),
                ),
             
              ],
            ),
          )
        ],
      ),
    );
  }
}

class SalesData {
  SalesData(this.x, this.y);

  final String x;
  final double y;
}
