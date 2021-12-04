import 'dart:math';

import 'package:percent_indicator/percent_indicator.dart';
import 'package:flash/flash.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:blr_medical/Helpers/data.dart';
import 'package:intl/intl.dart';
import 'package:blr_medical/Helpers/colors.dart';
import 'package:flutter/material.dart';
import 'package:blr_medical/Designs/dashboardCard.dart';
import 'package:blr_medical/Designs/stock.dart';
import 'package:blr_medical/Helpers/colors.dart';
import 'package:blr_medical/login.dart';
import 'package:blr_medical/raphs.dart';
import 'package:blr_medical/sales.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_charts/sparkcharts.dart';
import 'package:bottom_navy_bar/bottom_navy_bar.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        fontFamily: 'PoppinsRegular',
        primarySwatch: Colors.blue,
      ),
      home: LoginScreen(),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // bottomNavigationBar: BottomNavyBar(
      //   selectedIndex: _currentIndex,
      //   showElevation: true,
      //   itemCornerRadius: 24,
      //   curve: Curves.easeIn,
      //   backgroundColor: Colors.white,
      //   onItemSelected: (index) {
      //     setState(() => _currentIndex = index);
      //   },
      //   items: <BottomNavyBarItem>[
      //     BottomNavyBarItem(
      //         activeColor: kPrimaryColor,
      //         title: Text(' Dashboard'),
      //         icon: Icon(Icons.home)),
      //     BottomNavyBarItem(
      //         activeColor: kPrimaryColor,
      //         title: Text(' Sales'),
      //         icon: Icon(Icons.money)),
      //     BottomNavyBarItem(
      //         activeColor: kPrimaryColor,
      //         title: Text(' Stock'),
      //         icon: Icon(Icons.inventory)),
      //   ],
      // ),

      body: _currentIndex == 0
          ? MyHomePage()
          : _currentIndex == 1
              ? SalesScreen()
              : _currentIndex == 2
                  ? StockScreen()
                  : Container(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  late var _isChecked = true;

  late var _isChecked2 = true;

  String totalProduct = "";
  String totalSupplier = "";
  String totalClient = "";
  String weekDate = "";
  String showThisDate = "";
  String searchString = "";
  String searchExpiryString = "";

  String totalOpeningBalance = "";
  String totalSale = "";
  String totalSaleReturn = "";
  String totalExpenses = "";
  List<_ChartData> data = [];
  List<_ChartData> dataMonth = [];
  List<_ChartData> dataDaily = [];
  final TextEditingController searchController = new TextEditingController();
  final TextEditingController searchExpiryController =
      new TextEditingController();

  String hintFilter = "Daily";

  TooltipBehavior? _tooltip;
  double sale = 0.0;

  double highSale = 10000;
  bool yearly = false;
  bool monthly = false;
  bool daily = false;
  bool expense = false;

  DateTime currentTime = DateTime.now();

  DateTime selectedDateTime = DateTime.now();

  DateTime dailyTime = DateTime.now();

  bool showHideGraph = true;

  bool stock = false;
  bool expiry = false;

  double TotalIn = 0.0;
  double TotalOut = 0.0;

  double TotalRemaining = 0.0;

  var expiryData = [];

  var startDate;
  String showSaleTitle = "Sale";
  var endDate;

  var MedicineData = [];
  var stockData = [];

  var medList = [];

  @override
  void initState() {
    var now = new DateTime.now();
    var formatter = new DateFormat('d MMM');

    final date = DateTime.now();
    DateTime getDate(DateTime d) => DateTime(d.year, d.month, d.day);

    print('Date: $date');
    print(
        'Start of week: ${getDate(date.subtract(Duration(days: date.weekday - 1)))}');
    print(
        'End of week: ${getDate(date.add(Duration(days: DateTime.daysPerWeek - date.weekday)))}');
    startDate = getDate(date.subtract(Duration(days: date.weekday - 1)));
    endDate =
        getDate(date.add(Duration(days: DateTime.daysPerWeek - date.weekday)));
    print('startDate ${startDate}');
    print('endDate ${endDate}');

    weekDate =
        "${formatter.format(getDate(date.subtract(Duration(days: date.weekday - 1))))} - ${formatter.format(getDate(date.add(Duration(days: DateTime.daysPerWeek - date.weekday))))}";
    showThisDate = weekDate;

    Future.delayed(Duration.zero, () {
      data = [];
      dataMonth = [];
      dataDaily = [];

      _tooltip = TooltipBehavior(enable: true);
      this.getAllMed();
      this.getGraph();
      // this.getActivity();
    });
  }

  getGraph() async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Center(
              child: SpinKitWave(
                  color: kPrimaryColor, type: SpinKitWaveType.center));
        });

    var url = Uri.parse('${DomainGlobal}/api/Report/dashboardDetail');
    print('asd ${url}');

    var response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $tokenGlobal',
      },
    );
    print("${response.statusCode}");
    // print("respone back ${response.body}");
    if (response.statusCode == 200) {
      var respondedData = json.decode(response.body.toString());

      if (respondedData['succeed']) {
        print(startDate);
        print(endDate);
        this.getProducts(startDate, endDate);

        sale = 0;

        var now = new DateTime.now();
        var formatter = new DateFormat('d MMM');
        dataDaily = [];
        dailyTime = DateTime.now();

        print('dailt time ${dailyTime}');

        final date = DateTime.now();
        DateTime getDate(DateTime d) => DateTime(d.year, d.month, d.day);

        print('Date: $date');
        print(
            'Start of week: ${getDate(date.subtract(Duration(days: date.weekday - 1)))}');
        print(
            'End of week: ${getDate(date.add(Duration(days: DateTime.daysPerWeek - date.weekday)))}');

        var beginningNextMonth = (now.month < 12)
            ? new DateTime(now.year, now.month + 1, 1)
            : new DateTime(now.year + 1, 1, 1);
        var lastDay = beginningNextMonth.subtract(new Duration(days: 1)).day;

        // startDate = getDate(
        //     DateTime.parse("${date.year}-${date.month}-01"));
        // endDate = getDate(DateTime.parse(
        //     "${date.year}-${date.month}-${lastDay}"));

        startDate =
            getDate(DateTime.now().subtract(Duration(days: date.weekday - 1)));
        endDate = getDate(DateTime.now()
            .add(Duration(days: DateTime.daysPerWeek - date.weekday)));
        getProducts(date, date);
        highSale = 100;
        print('startDate ${startDate}');
        print('endDate ${endDate}');

        weekDate = DateFormat('dd MMM yyy').format(date);
        showThisDate = weekDate;
        sale = 0;

        for (var item in SalesDataDump) {
          var itemDate = DateTime.parse(item["sDate"].toString());

          if (itemDate.compareTo(startDate) > 0 &&
              itemDate.compareTo(endDate) < 0) {
            highSale =
                item["netAmount"] > highSale ? item["netAmount"] : highSale;

            print(item["sDate"]);
            print(item["netAmount"]);
            print(DateFormat('dd')
                .format(DateTime.parse(item["sDate"].toString())));
            String dayThis = DateFormat('dd')
                .format(DateTime.parse(item["sDate"].toString()));

            /// e.g Thursday
            String match1 = DateFormat('yyyy-MM-dd').format(dailyTime);
            String match2 = DateFormat('yyyy-MM-dd')
                .format(DateTime.parse(item["sDate"].toString()));
            if (match1 == match2) {
              sale = item["netAmount"];
            }

            /// e.g Thursday
            dataDaily
                .add(_ChartData(dayThis, item["netAmount"], kPrimaryColor));
          }
          if (itemDate == startDate || itemDate == endDate) {
            highSale =
                item["netAmount"] > highSale ? item["netAmount"] : highSale;

            sale = sale + double.parse(item["netAmount"].toString());
            print(item["sDate"]);
            print(item["netAmount"]);
            print(DateFormat('dd')
                .format(DateTime.parse(item["sDate"].toString())));

            /// e.g Thursday
            String dayThis = DateFormat('dd')
                .format(DateTime.parse(item["sDate"].toString()));

            /// e.g Thursday
            String match1 = DateFormat('yyyy-MM-dd').format(DateTime.now());
            String match2 = DateFormat('yyyy-MM-dd')
                .format(DateTime.parse(item["sDate"].toString()));
            if (match1 == match2) {
              sale = item["netAmount"];
            }

            /// e.g Thursday
            dataDaily
                .add(_ChartData(dayThis, item["netAmount"], kPrimaryColor));
          }
        }

        print('highSale year ${highSale}');
        setState(() {
          yearly = false;
          weekly = false;
          monthly = false;
          daily = true;
        });

        setState(() {
          SalesDataDump = respondedData['data']['sale'];
          SalesDataCopy = respondedData['data']['sale'];

          ExpenseCopy = respondedData['data']['expense'];
          PurchaseCopy = respondedData['data']['purchase'];

          print(SalesDataDump);
        });
        Navigator.pop(context);
      }
      if (!respondedData['succeed']) {
        Navigator.pop(context);
        showFlash(
            context: context,
            persistent: true,
            builder: (_, controller) {
              return Flash(
                controller: controller,
                margin: EdgeInsets.zero,
                behavior: FlashBehavior.fixed,
                position: FlashPosition.bottom,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(8), topRight: Radius.circular(8)),
                boxShadows: kElevationToShadow[8],
                backgroundGradient: RadialGradient(
                  colors: [Color(0xffdcf6ff), Color(0xffdcf6ff)],
                  center: Alignment.topLeft,
                ),
                onTap: () => controller.dismiss(),
                forwardAnimationCurve: Curves.easeInCirc,
                reverseAnimationCurve: Curves.bounceIn,
                child: DefaultTextStyle(
                  style: TextStyle(color: Colors.white),
                  child: FlashBar(
                    content: Text(respondedData['message'].toString(),
                        style: TextStyle(
                            fontFamily: 'PoppinsRegular',
                            color: kPrimaryColor,
                            fontSize: 17)),
                    primaryAction: TextButton(
                      onPressed: () => controller.dismiss(),
                      child: Icon(Icons.close_outlined, color: kPrimaryColor),
                    ),
                  ),
                ),
              );
            });
      }
      print('highSale ${highSale}');
    }
  }

  getProducts(from, to) async {
    var formatter = new DateFormat('yyy-MM-dd');

    Map body = {
      "fromDate": formatter.format(from).toString(),
      "tillDate": formatter.format(to).toString(),
      "itemId": 0,
      "periodId": 0
    };

    print('this ${body}');

    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Center(
              child: SpinKitWave(
                  color: kPrimaryColor, type: SpinKitWaveType.center));
        });

    var url = Uri.parse('${DomainGlobal}/api/Report/topProducts');
    print('asd ${url}');

    var dataSend = json.encode(body);

    var response = await http.post(url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $tokenGlobal',
        },
        body: dataSend);
    print("${response.statusCode}");
    // print("respone back ${response.body}");
    if (response.statusCode == 200) {
      var respondedData = json.decode(response.body.toString());

      if (respondedData['succeed']) {
        setState(() {
          // productShow = respondedData['data']['sale'];
          productSale = respondedData['data']['sale'];

          productExpense = respondedData['data']['expense'];
          productPurchase = respondedData['data']['purchase'];

          print('thissale ${respondedData['data']['sale']}');
          print('thisexpense ${respondedData['data']['expense']}');
          print('thispurchase ${respondedData['data']['purchase']}');

          if (showSaleTitle == "Sale") {
            productShow = productSale;
          }
          if (showSaleTitle == "Expense") {
            productShow = productExpense;
          }
          if (showSaleTitle == "Purchase") {
            productShow = productPurchase;
          }

          print("asd ${productShow}");
        });
        Navigator.pop(context);
      }
      if (!respondedData['succeed']) {
        Navigator.pop(context);
        showFlash(
            context: context,
            persistent: true,
            builder: (_, controller) {
              return Flash(
                controller: controller,
                margin: EdgeInsets.zero,
                behavior: FlashBehavior.fixed,
                position: FlashPosition.bottom,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(8), topRight: Radius.circular(8)),
                boxShadows: kElevationToShadow[8],
                backgroundGradient: RadialGradient(
                  colors: [Color(0xffdcf6ff), Color(0xffdcf6ff)],
                  center: Alignment.topLeft,
                ),
                onTap: () => controller.dismiss(),
                forwardAnimationCurve: Curves.easeInCirc,
                reverseAnimationCurve: Curves.bounceIn,
                child: DefaultTextStyle(
                  style: TextStyle(color: Colors.white),
                  child: FlashBar(
                    content: Text(respondedData['message'].toString(),
                        style: TextStyle(
                            fontFamily: 'PoppinsRegular',
                            color: kPrimaryColor,
                            fontSize: 17)),
                    primaryAction: TextButton(
                      onPressed: () => controller.dismiss(),
                      child: Icon(Icons.close_outlined, color: kPrimaryColor),
                    ),
                  ),
                ),
              );
            });
      }
      print('highSale ${highSale}');
    }
  }

  getActivity() async {
    DateTime selectedDate = DateTime.now();
    String startDate = DateFormat("yyyy-MM-d").format(selectedDate).toString();
    String endDate = DateFormat("yyyy-MM-d").format(selectedDate).toString();
    var now = new DateTime.now();
    var beginningNextMonth = (now.month < 12)
        ? new DateTime(now.year, now.month + 1, 1)
        : new DateTime(now.year + 1, 1, 1);

    var lastDay = beginningNextMonth.subtract(new Duration(days: 1)).day;

    Map body = {
      "fromDate": filterRange == 0
          ? startDate
          : filterRange == 1
              ? '${selectedDate.year}-${selectedDate.month}-1'
              : filterRange == 4
                  ? DateFormat("yyyy-MM-d")
                      .format(selectedDate.subtract(Duration(days: 7)))
                      .toString()
                  : filterRange == 2
                      ? "${selectedDate.year}-01-01"
                      : "",
      "tillDate": filterRange == 0
          ? endDate
          : filterRange == 1
              ? '${selectedDate.year}-${selectedDate.month}-${lastDay}'
              : filterRange == 4
                  ? DateFormat("yyyy-MM-d").format(selectedDate).toString()
                  : filterRange == 2
                      ? "${selectedDate.year}-12-31"
                      : "",
      "customerId": 0,
      "reportTypeId": 0,
      "sdlId": sdlId
    };

    print(json.encode(body));
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Center(
              child: SpinKitWave(
                  color: kPrimaryColor, type: SpinKitWaveType.center));
        });

    var url = Uri.parse('${DomainGlobal}/api/Report/dashboard');
    print('asd ${url}');

    //encode Map to JSON
    var data = json.encode(body);

    var response = await http.post(url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $tokenGlobal',
        },
        body: data);
    print("${response.statusCode}");
    print("respone back ${response.body}");
    if (response.statusCode == 200) {
      var respondedData = json.decode(response.body.toString());

      if (respondedData['succeed']) {
        setState(() {
          totalProduct = respondedData['data'][0]['totalProduct'].toString();
          totalSupplier = respondedData['data'][0]['totalSupplier'].toString();

          totalClient = respondedData['data'][0]['totalClient'].toString();

          totalOpeningBalance =
              respondedData['data'][0]['openingBalance'].toString();
          totalSale = respondedData['data'][0]['sale'].toString();
          totalSaleReturn = respondedData['data'][0]['saleReturn'].toString();
          totalExpenses = respondedData['data'][0]['expenses'].toString();

          Navigator.pop(context);
        });
      }
      if (!respondedData['succeed']) {
        Navigator.pop(context);
        showFlash(
            context: context,
            persistent: true,
            builder: (_, controller) {
              return Flash(
                controller: controller,
                margin: EdgeInsets.zero,
                behavior: FlashBehavior.fixed,
                position: FlashPosition.bottom,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(8), topRight: Radius.circular(8)),
                boxShadows: kElevationToShadow[8],
                backgroundGradient: RadialGradient(
                  colors: [Color(0xffcde0e7), Color(0xffcde0e7)],
                  center: Alignment.topLeft,
                ),
                onTap: () => controller.dismiss(),
                forwardAnimationCurve: Curves.easeInCirc,
                reverseAnimationCurve: Curves.bounceIn,
                child: DefaultTextStyle(
                  style: TextStyle(color: Colors.white),
                  child: FlashBar(
                    content: Text(respondedData['message'].toString(),
                        style: TextStyle(
                            fontFamily: 'PoppinsRegular',
                            color: kPrimaryColor,
                            fontSize: 17)),
                    primaryAction: TextButton(
                      onPressed: () => controller.dismiss(),
                      child: Icon(Icons.close_outlined, color: kPrimaryColor),
                    ),
                  ),
                ),
              );
            });
      }
    }
  }

  getStock(from, to, medName, itemID) async {
    var formatter = new DateFormat('yyy-MM-dd');

    Map body = {
      "fromDate": formatter.format(from).toString(),
      "tillDate": formatter.format(to).toString(),
      "itemName": medName,
      "dateFilterId": 1,
      "itemId": itemID,
      "sdlId": "1"
    };

    print('stock ${body}');

    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Center(
              child: SpinKitWave(
                  color: kPrimaryColor, type: SpinKitWaveType.center));
        });

    var url = Uri.parse('${DomainGlobal}/api/Report/stockReport');
    print('asd ${url}');

    var dataSend = json.encode(body);

    var response = await http.post(url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $tokenGlobal',
        },
        body: dataSend);
    print("${response.statusCode}");
    // print("respone back ${response.body}");
    if (response.statusCode == 200) {
      var respondedData = json.decode(response.body.toString());

      if (respondedData['succeed']) {
        setState(() {
          // productShow = respondedData['data']['sale'];

          stockData = respondedData['data'];

          print("asd ${stockData}");
          print('stock ${stockData}');
          print('stock ${stockData.length}');
        });

        TotalIn = 0.0;
        TotalOut = 0.0;

        for (var i = 0; i < stockData.length; i++) {
          var remaining = stockData[i]['itemIN'] - stockData[i]['itemOut'];
          TotalIn = TotalIn + stockData[i]['itemIN'];
          TotalOut = TotalOut + stockData[i]['itemOut'];

          TotalRemaining = remaining;
        }
        setState(() {});
        Navigator.pop(context);
      }
      if (!respondedData['succeed']) {
        Navigator.pop(context);
        showFlash(
            context: context,
            persistent: true,
            builder: (_, controller) {
              return Flash(
                controller: controller,
                margin: EdgeInsets.zero,
                behavior: FlashBehavior.fixed,
                position: FlashPosition.bottom,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(8), topRight: Radius.circular(8)),
                boxShadows: kElevationToShadow[8],
                backgroundGradient: RadialGradient(
                  colors: [Color(0xffdcf6ff), Color(0xffdcf6ff)],
                  center: Alignment.topLeft,
                ),
                onTap: () => controller.dismiss(),
                forwardAnimationCurve: Curves.easeInCirc,
                reverseAnimationCurve: Curves.bounceIn,
                child: DefaultTextStyle(
                  style: TextStyle(color: Colors.white),
                  child: FlashBar(
                    content: Text(respondedData['message'].toString(),
                        style: TextStyle(
                            fontFamily: 'PoppinsRegular',
                            color: kPrimaryColor,
                            fontSize: 17)),
                    primaryAction: TextButton(
                      onPressed: () => controller.dismiss(),
                      child: Icon(Icons.close_outlined, color: kPrimaryColor),
                    ),
                  ),
                ),
              );
            });
      }
      print('highSale ${highSale}');
    }
  }

  getAllMed() async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Center(
              child: SpinKitWave(
                  color: kPrimaryColor, type: SpinKitWaveType.center));
        });

    var url = Uri.parse('${DomainGlobal}/api/Item/en/all');

    print(url);
    http.Response res = await http.get(url, headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $tokenGlobal',
    });
    print("${res.statusCode}");
    print("${res.body}");
    var respondedData = json.decode(res.body.toString());

    if (respondedData['succeed']) {
      setState(() {
        medList = respondedData['data'];
      });

      Navigator.pop(context);

      print('medList ${medList}');
    } else {
      Navigator.pop(context);
    }
  }

  getExpiry(periodId, medName, itemID) async {
    var formatter = new DateFormat('yyy-MM-dd');

    Map body = {
      "itemName": medName,
      "periodId": periodId,
      "itemId": 0,
      "sdlId": "1"
    };

    print('stock ${body}');

    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Center(
              child: SpinKitWave(
                  color: kPrimaryColor, type: SpinKitWaveType.center));
        });

    var url = Uri.parse('${DomainGlobal}/api/Report/expiryReport');
    print('asd ${url}');

    var dataSend = json.encode(body);

    var response = await http.post(url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $tokenGlobal',
        },
        body: dataSend);
    print("${response.statusCode}");
    // print("respone back ${response.body}");
    if (response.statusCode == 200) {
      var respondedData = json.decode(response.body.toString());

      if (respondedData['succeed']) {
        setState(() {
          // productShow = respondedData['data']['sale'];

          expiryData = respondedData['data'];

          print("expiryData ${expiryData}");
          print('expiryData ${expiryData.length}');
        });

        Navigator.pop(context);
      }
      if (!respondedData['succeed']) {
        Navigator.pop(context);
        showFlash(
            context: context,
            persistent: true,
            builder: (_, controller) {
              return Flash(
                controller: controller,
                margin: EdgeInsets.zero,
                behavior: FlashBehavior.fixed,
                position: FlashPosition.bottom,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(8), topRight: Radius.circular(8)),
                boxShadows: kElevationToShadow[8],
                backgroundGradient: RadialGradient(
                  colors: [Color(0xffdcf6ff), Color(0xffdcf6ff)],
                  center: Alignment.topLeft,
                ),
                onTap: () => controller.dismiss(),
                forwardAnimationCurve: Curves.easeInCirc,
                reverseAnimationCurve: Curves.bounceIn,
                child: DefaultTextStyle(
                  style: TextStyle(color: Colors.white),
                  child: FlashBar(
                    content: Text(respondedData['message'].toString(),
                        style: TextStyle(
                            fontFamily: 'PoppinsRegular',
                            color: kPrimaryColor,
                            fontSize: 17)),
                    primaryAction: TextButton(
                      onPressed: () => controller.dismiss(),
                      child: Icon(Icons.close_outlined, color: kPrimaryColor),
                    ),
                  ),
                ),
              );
            });
      }
      print('highSale ${highSale}');
    }
  }

  bool weekly = true;

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: kPrimaryColor,
        title: Text('Dashboard',
            style: TextStyle(
                fontFamily: 'PoppinsMedium',
                fontSize: 21,
                color: Colors.white)),
        automaticallyImplyLeading: false,
        // actions: [
        //   GestureDetector(
        //     onTap: () {
        //       _modalBottomSheetMenu();
        //     },
        //     child: Padding(
        //       padding: const EdgeInsets.only(right: 7),
        //       child: Icon(
        //         Icons.filter_alt_outlined,
        //         size: 30,
        //       ),
        //     ),
        //   )
        // ]
      ),
      body: SingleChildScrollView(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          children: <Widget>[
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.0175,
            ),
            Container(
              width: width * 0.9,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: width * 0.4,
                    child: DropdownButtonFormField(
                      hint: Text('Sales'), // Not necessary for Option 1

                      items: [
                        {'value': 'Sales', 'label': 'Sales'},
                        {'value': 'Expense', 'label': 'Expense'},
                        {'value': 'Purchase', 'label': 'Purchase'},
                        {'value': 'Stock', 'label': 'Stock'},
                        {'value': 'Expiry', 'label': 'Expiry'},
                      ].map((category) {
                        return new DropdownMenuItem(
                            value: category['value'],
                            child: Text(
                              category['label'].toString(),
                              style: TextStyle(
                                color: textGreyColor,
                                fontFamily: 'SegoeUI',
                                fontSize: 14,
                              ),
                            ));
                      }).toList(),
                      onChanged: (newValue) {
                        SalesDataDump = [];
                        data = [];
                        hintFilter = "Weekly";
                        productShow = [];
                        if (newValue.toString() == "Expiry") {
                          getExpiry(13, '', 0);
                          setState(() {
                            showThisDate = weekDate;
                            selectedDateTime = DateTime.now();

                            hintFilter = "Weekly";
                            stock = false;
                            weekly = false;
                            yearly = false;
                            monthly = false;
                            daily = false;
                            showHideGraph = false;
                            expiry = true;
                            expense = false;
                          });
                        }

                        if (newValue.toString() == "Stock") {
                          var now = new DateTime.now();
                          var formatter = new DateFormat('d MMM');

                          final date = DateTime.now();
                          DateTime getDate(DateTime d) =>
                              DateTime(d.year, d.month, d.day);

                          print('Date: $date');
                          print(
                              'Start of week: ${getDate(date.subtract(Duration(days: date.weekday - 1)))}');
                          print(
                              'End of week: ${getDate(date.add(Duration(days: DateTime.daysPerWeek - date.weekday)))}');
                          var startDate = getDate(
                              date.subtract(Duration(days: date.weekday - 1)));
                          var endDate = getDate(date.add(Duration(
                              days: DateTime.daysPerWeek - date.weekday)));
                          print('startDate ${startDate}');
                          print('endDate ${endDate}');

                          setState(() {
                            showThisDate = weekDate;
                            hintFilter = "Weekly";
                            stock = true;
                            weekly = false;
                            yearly = false;

                            expense = false;
                            selectedDateTime = DateTime.now();

                            monthly = false;
                            daily = false;
                            showHideGraph = false;
                            expiry = false;
                          });

                          getStock(startDate, endDate, '', 0);
                        }

                        if (newValue.toString() == "Sales") {
                          setState(() {
                            showSaleTitle = "Sale";
                            SalesDataDump = SalesDataCopy;
                            productShow = productSale;
                            showHideGraph = true;
                            selectedDateTime = DateTime.now();
                            expense = false;

                            stock = false;
                          });
                        }
                        if (newValue.toString() == "Expense") {
                          setState(() {
                            showSaleTitle = "Expense";
                            SalesDataDump = ExpenseCopy;
                            expense = true;

                            selectedDateTime = DateTime.now();

                            productShow = productExpense;
                            showHideGraph = true;
                            stock = false;
                          });
                        }
                        if (newValue.toString() == "Purchase") {
                          setState(() {
                            showSaleTitle = "Purchase";
                            SalesDataDump = PurchaseCopy;
                            expense = false;

                            productShow = productPurchase;
                            selectedDateTime = DateTime.now();

                            showHideGraph = true;
                            stock = false;
                          });
                        }

                        var now = new DateTime.now();
                        var formatter = new DateFormat('d MMM');

                        final date = DateTime.now();
                        DateTime getDate(DateTime d) =>
                            DateTime(d.year, d.month, d.day);

                        print('Date: $date');
                        print(
                            'Start of week: ${getDate(date.subtract(Duration(days: date.weekday - 1)))}');
                        print(
                            'End of week: ${getDate(date.add(Duration(days: DateTime.daysPerWeek - date.weekday)))}');
                        startDate = getDate(
                            date.subtract(Duration(days: date.weekday - 1)));
                        endDate = getDate(date.add(Duration(
                            days: DateTime.daysPerWeek - date.weekday)));
                        print('startDate ${startDate}');
                        print('endDate ${endDate}');
                        getProducts(startDate, endDate);
                        sale = 0;

                        weekDate =
                            "${formatter.format(getDate(date.subtract(Duration(days: date.weekday - 1))))} - ${formatter.format(getDate(date.add(Duration(days: DateTime.daysPerWeek - date.weekday))))}";

                        for (var item in SalesDataDump) {
                          var itemDate =
                              DateTime.parse(item["sDate"].toString());

                          if (itemDate.compareTo(startDate) > 0 &&
                              itemDate.compareTo(endDate) < 0) {
                            highSale = item["netAmount"] > highSale
                                ? item["netAmount"]
                                : highSale;

                            sale = sale +
                                double.parse(item["netAmount"].toString());

                            print(item["sDate"]);
                            print(item["netAmount"]);
                            print(DateFormat('EEE').format(
                                DateTime.parse(item["sDate"].toString())));
                            String dayThis = DateFormat('EEE').format(
                                DateTime.parse(item["sDate"].toString()));

                            /// e.g Thursday
                            String match1 =
                                DateFormat('yyyy-MM-dd').format(DateTime.now());
                            String match2 = DateFormat('yyyy-MM-dd').format(
                                DateTime.parse(item["sDate"].toString()));

                            /// e.g Thursday
                            data.add(_ChartData(
                                dayThis, item["netAmount"], kPrimaryColor));
                          }
                          if (itemDate == startDate || itemDate == endDate) {
                            highSale = item["netAmount"] > highSale
                                ? item["netAmount"]
                                : highSale;

                            sale = sale +
                                double.parse(item["netAmount"].toString());
                            print(item["sDate"]);
                            print(item["netAmount"]);
                            print(DateFormat('EEEE').format(
                                DateTime.parse(item["sDate"].toString())));

                            /// e.g Thursday
                            String dayThis = DateFormat('EEE').format(
                                DateTime.parse(item["sDate"].toString()));

                            /// e.g Thursday
                            String match1 =
                                DateFormat('yyyy-MM-dd').format(DateTime.now());
                            String match2 = DateFormat('yyyy-MM-dd').format(
                                DateTime.parse(item["sDate"].toString()));

                            /// e.g Thursday
                            data.add(_ChartData(
                                dayThis, item["netAmount"], kPrimaryColor));
                          }
                        }
                        setState(() {
                          showThisDate = weekDate;
                          // hintFilter = "Weekly";
                          weekly = true;
                          yearly = false;
                          monthly = false;
                          daily = false;
                        });
                      },
                      decoration: new InputDecoration(
                        isDense: true,
                        border: new OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: Color(0xffE6E6E6)),
                          borderRadius: const BorderRadius.all(
                            const Radius.circular(5.0),
                          ),
                        ),
                        enabledBorder: new OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: Color(0xffE6E6E6)),
                          borderRadius: const BorderRadius.all(
                            const Radius.circular(5.0),
                          ),
                        ),
                        filled: true,
                        hintStyle: new TextStyle(
                            color: textGreyColor, fontFamily: 'SegoeUI'),
                        fillColor: Colors.white70,
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: kPrimaryColor),
                          borderRadius: const BorderRadius.all(
                            const Radius.circular(5.0),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: width * 0.4,
                    child: DropdownButtonFormField(
                      hint: Text(hintFilter), // Not necessary for Option 1

                      items: [
                        {'value': 'Daily', 'label': 'Daily'},
                        {'value': 'Weekly', 'label': 'Weekly'},
                        {'value': 'Monthly', 'label': 'Monthly'},
                        {'value': 'Yearly', 'label': 'Yearly'}
                      ].map((category) {
                        return new DropdownMenuItem(
                            value: category['value'],
                            child: Text(
                              category['label'].toString(),
                              style: TextStyle(
                                color: textGreyColor,
                                fontFamily: 'SegoeUI',
                                fontSize: 14,
                              ),
                            ));
                      }).toList(),
                      value: hintFilter,
                      onChanged: (newValue) {
                        hintFilter = newValue.toString();
                        if (newValue.toString() == "Weekly") {
                          setState(() {
                            selectedDateTime = DateTime.now();
                          });
                          data = [];
                          var now = new DateTime.now();
                          var formatter = new DateFormat('d MMM');

                          final date = DateTime.now();
                          DateTime getDate(DateTime d) =>
                              DateTime(d.year, d.month, d.day);

                          print('Date: $date');
                          print(
                              'Start of week: ${getDate(date.subtract(Duration(days: date.weekday - 1)))}');
                          print(
                              'End of week: ${getDate(date.add(Duration(days: DateTime.daysPerWeek - date.weekday)))}');
                          startDate = getDate(
                              date.subtract(Duration(days: date.weekday - 1)));
                          endDate = getDate(date.add(Duration(
                              days: DateTime.daysPerWeek - date.weekday)));
                          print('startDate ${startDate}');
                          print('endDate ${endDate}');
                          getProducts(startDate, endDate);

                          if (stock) {
                            getStock(startDate, endDate, '', 0);
                          }
                          if (expiry) {
                            getExpiry(13, '', 0);
                          }

                          sale = 0;

                          weekDate =
                              "${formatter.format(getDate(date.subtract(Duration(days: date.weekday - 1))))} - ${formatter.format(getDate(date.add(Duration(days: DateTime.daysPerWeek - date.weekday))))}";

                          for (var item in SalesDataDump) {
                            var itemDate =
                                DateTime.parse(item["sDate"].toString());

                            if (itemDate.compareTo(startDate) > 0 &&
                                itemDate.compareTo(endDate) < 0) {
                              highSale = item["netAmount"] > highSale
                                  ? item["netAmount"]
                                  : highSale;

                              sale = sale +
                                  double.parse(item["netAmount"].toString());

                              print(item["sDate"]);
                              print(item["netAmount"]);
                              print(DateFormat('EEE').format(
                                  DateTime.parse(item["sDate"].toString())));
                              String dayThis = DateFormat('EEE').format(
                                  DateTime.parse(item["sDate"].toString()));

                              /// e.g Thursday
                              String match1 = DateFormat('yyyy-MM-dd')
                                  .format(DateTime.now());
                              String match2 = DateFormat('yyyy-MM-dd').format(
                                  DateTime.parse(item["sDate"].toString()));

                              /// e.g Thursday
                              data.add(_ChartData(
                                  dayThis, item["netAmount"], kPrimaryColor));
                            }
                            if (itemDate == startDate || itemDate == endDate) {
                              highSale = item["netAmount"] > highSale
                                  ? item["netAmount"]
                                  : highSale;

                              sale = sale +
                                  double.parse(item["netAmount"].toString());
                              print(item["sDate"]);
                              print(item["netAmount"]);
                              print(DateFormat('EEEE').format(
                                  DateTime.parse(item["sDate"].toString())));

                              /// e.g Thursday
                              String dayThis = DateFormat('EEE').format(
                                  DateTime.parse(item["sDate"].toString()));

                              /// e.g Thursday
                              String match1 = DateFormat('yyyy-MM-dd')
                                  .format(DateTime.now());
                              String match2 = DateFormat('yyyy-MM-dd').format(
                                  DateTime.parse(item["sDate"].toString()));

                              /// e.g Thursday
                              data.add(_ChartData(
                                  dayThis, item["netAmount"], kPrimaryColor));
                            }
                          }
                          setState(() {
                            showThisDate = weekDate;
                            weekly = true;
                            yearly = false;
                            monthly = false;
                            daily = false;
                          });
                        }
                        if (newValue.toString() == "Yearly") {
                          dataMonth = [];
                          var now = new DateTime.now();
                          var formatter = new DateFormat('d MMM');

                          final date = DateTime.now();
                          DateTime getDate(DateTime d) =>
                              DateTime(d.year, d.month, d.day);

                          print('Date: $date');
                          print(
                              'Start of week: ${getDate(date.subtract(Duration(days: date.weekday - 1)))}');
                          print(
                              'End of week: ${getDate(date.add(Duration(days: DateTime.daysPerWeek - date.weekday)))}');
                          startDate =
                              getDate(DateTime.parse("${date.year}-01-01"));
                          endDate =
                              getDate(DateTime.parse("${date.year}-12-31"));
                          print('startDate ${startDate}');
                          print('endDate ${endDate}');

                          if (stock) {
                            getStock(startDate, endDate, '', 0);
                          }
                          if (expiry) {
                            getExpiry(12, '', 0);
                          }

                          weekDate = "${date.year}";
                          showThisDate = weekDate;
                          sale = 0;

                          for (var item in SalesDataDump) {
                            var itemDate =
                                DateTime.parse(item["sDate"].toString());

                            if (itemDate.compareTo(startDate) > 0 &&
                                itemDate.compareTo(endDate) < 0) {
                              highSale = item["netAmount"] > highSale
                                  ? item["netAmount"]
                                  : highSale;

                              sale = sale +
                                  double.parse(item["netAmount"].toString());

                              print(item["sDate"]);
                              print(item["netAmount"]);
                              print(DateFormat('MMM').format(
                                  DateTime.parse(item["sDate"].toString())));
                              String dayThis = DateFormat('yyy').format(
                                  DateTime.parse(item["sDate"].toString()));

                              /// e.g Thursday
                              String match1 =
                                  DateFormat('yyy').format(DateTime.now());
                              String match2 = DateFormat('yyy').format(
                                  DateTime.parse(item["sDate"].toString()));
                              print('mm');
                              print(match1);
                              print(match2);

                              /// e.g Thursday
                              dataMonth.add(_ChartData(
                                  dayThis, item["netAmount"], kPrimaryColor));
                            }
                            if (itemDate == startDate || itemDate == endDate) {
                              highSale = item["netAmount"] > highSale
                                  ? item["netAmount"]
                                  : highSale;

                              sale = sale +
                                  double.parse(item["netAmount"].toString());
                              print(item["sDate"]);
                              print(item["netAmount"]);
                              print(DateFormat('MMM').format(
                                  DateTime.parse(item["sDate"].toString())));

                              /// e.g Thursday
                              String dayThis = DateFormat('yyy').format(
                                  DateTime.parse(item["sDate"].toString()));

                              /// e.g Thursday
                              String match1 =
                                  DateFormat('yyy').format(DateTime.now());
                              String match2 = DateFormat('yyy').format(
                                  DateTime.parse(item["sDate"].toString()));

                              /// e.g Thursday
                              dataMonth.add(_ChartData(
                                  dayThis, item["netAmount"], kPrimaryColor));
                            }
                          }

                          print('highSale year ${highSale}');
                          setState(() {
                            yearly = true;
                            weekly = false;
                            monthly = false;
                            daily = false;
                          });
                        }
                        if (newValue.toString() == "Monthly") {
                          dataDaily = [];
                          var now = new DateTime.now();
                          var formatter = new DateFormat('d MMM');

                          final date = DateTime.now();
                          DateTime getDate(DateTime d) =>
                              DateTime(d.year, d.month, d.day);

                          print('Date: $date');
                          print(
                              'Start of week: ${getDate(date.subtract(Duration(days: date.weekday - 1)))}');
                          print(
                              'End of week: ${getDate(date.add(Duration(days: DateTime.daysPerWeek - date.weekday)))}');

                          var beginningNextMonth = (now.month < 12)
                              ? new DateTime(now.year, now.month + 1, 1)
                              : new DateTime(now.year + 1, 1, 1);
                          var lastDay = beginningNextMonth
                              .subtract(new Duration(days: 1))
                              .day;

                          startDate = getDate(
                              DateTime.parse("${date.year}-${date.month}-01"));
                          endDate = getDate(DateTime.parse(
                              "${date.year}-${date.month}-${lastDay}"));
                          highSale = 100;
                          print('startDate ${startDate}');
                          print('endDate ${endDate}');
                          getProducts(startDate, endDate);

                          if (stock) {
                            getStock(startDate, endDate, '', 0);
                          }
                          if (expiry) {
                            getExpiry(1, '', 0);
                          }

                          weekDate = "${date.month}";
                          var show = DateTime.parse(startDate.toString());
                          showThisDate = DateFormat('MMMM yyyy').format(show);
                          sale = 0;

                          for (var item in SalesDataDump) {
                            var itemDate =
                                DateTime.parse(item["sDate"].toString());

                            if (itemDate.compareTo(startDate) > 0 &&
                                itemDate.compareTo(endDate) < 0) {
                              highSale = item["netAmount"] > highSale
                                  ? item["netAmount"]
                                  : highSale;

                              sale = sale +
                                  double.parse(item["netAmount"].toString());

                              print(item["sDate"]);
                              print(item["netAmount"]);
                              print(DateFormat('dd').format(
                                  DateTime.parse(item["sDate"].toString())));
                              String dayThis = DateFormat('MMM').format(
                                  DateTime.parse(item["sDate"].toString()));

                              /// e.g Thursday
                              String match1 =
                                  DateFormat('yyyy-MM').format(DateTime.now());
                              String match2 = DateFormat('yyyy-MM').format(
                                  DateTime.parse(item["sDate"].toString()));

                              /// e.g Thursday
                              dataDaily.add(_ChartData(
                                  dayThis, item["netAmount"], kPrimaryColor));
                            }
                            if (itemDate == startDate || itemDate == endDate) {
                              highSale = item["netAmount"] > highSale
                                  ? item["netAmount"]
                                  : highSale;

                              sale = sale +
                                  double.parse(item["netAmount"].toString());
                              print(item["sDate"]);
                              print(item["netAmount"]);
                              print(DateFormat('dd').format(
                                  DateTime.parse(item["sDate"].toString())));

                              /// e.g Thursday
                              String dayThis = DateFormat('MMM').format(
                                  DateTime.parse(item["sDate"].toString()));

                              /// e.g Thursday
                              String match1 =
                                  DateFormat('yyyy-MM').format(DateTime.now());
                              String match2 = DateFormat('yyyy-MM').format(
                                  DateTime.parse(item["sDate"].toString()));

                              /// e.g Thursday
                              dataDaily.add(_ChartData(
                                  dayThis, item["netAmount"], kPrimaryColor));
                            }
                          }

                          print('highSale year ${highSale}');
                          setState(() {
                            yearly = false;
                            weekly = false;
                            monthly = true;
                            daily = false;
                          });
                        }

                        if (newValue.toString() == "Daily") {
                          var now = new DateTime.now();
                          var formatter = new DateFormat('d MMM');
                          dataDaily = [];
                          dailyTime = DateTime.now();

                          print('dailt time ${dailyTime}');

                          final date = DateTime.now();
                          DateTime getDate(DateTime d) =>
                              DateTime(d.year, d.month, d.day);

                          print('Date: $date');
                          print(
                              'Start of week: ${getDate(date.subtract(Duration(days: date.weekday - 1)))}');
                          print(
                              'End of week: ${getDate(date.add(Duration(days: DateTime.daysPerWeek - date.weekday)))}');

                          var beginningNextMonth = (now.month < 12)
                              ? new DateTime(now.year, now.month + 1, 1)
                              : new DateTime(now.year + 1, 1, 1);
                          var lastDay = beginningNextMonth
                              .subtract(new Duration(days: 1))
                              .day;

                          // startDate = getDate(
                          //     DateTime.parse("${date.year}-${date.month}-01"));
                          // endDate = getDate(DateTime.parse(
                          //     "${date.year}-${date.month}-${lastDay}"));

                          startDate = getDate(DateTime.now()
                              .subtract(Duration(days: date.weekday - 1)));
                          endDate = getDate(DateTime.now().add(Duration(
                              days: DateTime.daysPerWeek - date.weekday)));
                          getProducts(date, date);
                          getStock(date, date, '', 0);
                          getExpiry(13, '', 0);

                          highSale = 100;
                          print('startDate ${startDate}');
                          print('endDate ${endDate}');

                          weekDate = DateFormat('dd MMM yyy').format(date);
                          showThisDate = weekDate;
                          sale = 0;

                          for (var item in SalesDataDump) {
                            var itemDate =
                                DateTime.parse(item["sDate"].toString());

                            if (itemDate.compareTo(startDate) > 0 &&
                                itemDate.compareTo(endDate) < 0) {
                              highSale = item["netAmount"] > highSale
                                  ? item["netAmount"]
                                  : highSale;

                              print(item["sDate"]);
                              print(item["netAmount"]);
                              print(DateFormat('dd').format(
                                  DateTime.parse(item["sDate"].toString())));
                              String dayThis = DateFormat('dd').format(
                                  DateTime.parse(item["sDate"].toString()));

                              /// e.g Thursday
                              String match1 =
                                  DateFormat('yyyy-MM-dd').format(dailyTime);
                              String match2 = DateFormat('yyyy-MM-dd').format(
                                  DateTime.parse(item["sDate"].toString()));
                              if (match1 == match2) {
                                sale = item["netAmount"];
                              }

                              /// e.g Thursday
                              dataDaily.add(_ChartData(
                                  dayThis,
                                  item["netAmount"],
                                  match1 == match2
                                      ? kPrimaryColor
                                      : Color(0xffcde0e7)));
                            }
                            if (itemDate == startDate || itemDate == endDate) {
                              highSale = item["netAmount"] > highSale
                                  ? item["netAmount"]
                                  : highSale;

                              sale = sale +
                                  double.parse(item["netAmount"].toString());
                              print(item["sDate"]);
                              print(item["netAmount"]);
                              print(DateFormat('dd').format(
                                  DateTime.parse(item["sDate"].toString())));

                              /// e.g Thursday
                              String dayThis = DateFormat('dd').format(
                                  DateTime.parse(item["sDate"].toString()));

                              /// e.g Thursday
                              String match1 = DateFormat('yyyy-MM-dd')
                                  .format(DateTime.now());
                              String match2 = DateFormat('yyyy-MM-dd').format(
                                  DateTime.parse(item["sDate"].toString()));
                              if (match1 == match2) {
                                sale = item["netAmount"];
                              }

                              /// e.g Thursday
                              dataDaily.add(_ChartData(
                                  dayThis,
                                  item["netAmount"],
                                  match1 == match2
                                      ? kPrimaryColor
                                      : Color(0xffcde0e7)));
                            }
                          }

                          print('highSale year ${highSale}');
                          setState(() {
                            yearly = false;
                            weekly = false;
                            monthly = false;
                            daily = true;
                          });
                        }
                      },
                      decoration: new InputDecoration(
                        isDense: true,
                        border: new OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: Color(0xffE6E6E6)),
                          borderRadius: const BorderRadius.all(
                            const Radius.circular(5.0),
                          ),
                        ),
                        enabledBorder: new OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: Color(0xffE6E6E6)),
                          borderRadius: const BorderRadius.all(
                            const Radius.circular(5.0),
                          ),
                        ),
                        filled: true,
                        hintStyle: new TextStyle(
                            color: textGreyColor, fontFamily: 'SegoeUI'),
                        fillColor: Colors.white70,
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: kPrimaryColor),
                          borderRadius: const BorderRadius.all(
                            const Radius.circular(5.0),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            showHideGraph
                ? Column(
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.02,
                      ),
                      RichText(
                        text: new TextSpan(
                          // Note: Styles for TextSpans must be explicitly defined.
                          // Child text spans will inherit styles from parent
                          style: new TextStyle(
                            fontSize: 14.0,
                            color: Colors.black,
                          ),
                          children: <TextSpan>[
                            new TextSpan(
                                text: '${sale.toStringAsFixed(0)}',
                                style: new TextStyle(
                                    fontSize: 18, fontFamily: 'PoppinsBold')),
                            // new TextSpan(
                            //     text: sale.toStringAsFixed(0),
                            //     style: TextStyle(
                            //         fontSize: 20,
                            //         fontFamily: 'PoppinsRegular',
                            //         color: textGreyColor)),
                          ],
                        ),
                      ),
                      RichText(
                        text: new TextSpan(
                          // Note: Styles for TextSpans must be explicitly defined.
                          // Child text spans will inherit styles from parent
                          style: new TextStyle(
                            fontSize: 14.0,
                            color: Colors.black,
                          ),
                          children: <TextSpan>[
                            new TextSpan(
                                text: '${showThisDate}',
                                style: new TextStyle(
                                    color: Colors.grey,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.02,
                      ),
                      Container(
                        height: MediaQuery.of(context).size.height * 0.25,
                        child: SfCartesianChart(
                            enableAxisAnimation: true,
                            primaryXAxis: CategoryAxis(
                                majorGridLines: MajorGridLines(width: 0),
                                //Hide the axis line of x-axis
                                axisLine: AxisLine(width: 0),
                                interval: 1),
                            primaryYAxis: NumericAxis(
                              numberFormat: NumberFormat.compact(),
                              minimum: 0, maximum: highSale,
                              interval: highSale < 200 ? 100 : 2000,
                              majorGridLines: MajorGridLines(width: 0),
                              //Hide the axis line of x-axis
                              axisLine: AxisLine(width: 0),
                            ),
                            tooltipBehavior: _tooltip,
                            plotAreaBorderWidth: 0,
                            legend: Legend(isVisible: false),
                            series: <ChartSeries<_ChartData, String>>[
                              ColumnSeries<_ChartData, String>(
                                  dataSource: weekly
                                      ? data
                                      : yearly
                                          ? dataMonth
                                          : monthly
                                              ? dataDaily
                                              : daily
                                                  ? dataDaily
                                                  : [],
                                  xValueMapper: (_ChartData data, _) => data.x,
                                  yValueMapper: (_ChartData data, _) => data.y,
                                  pointColorMapper: (_ChartData data, _) =>
                                      data.color,
                                  name: 'Week',
                                  color: weekly ? kPrimaryColor : Colors.red)
                            ]),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.0175,
                      ),
                      Container(
                        width: width * 0.9,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            RawMaterialButton(
                              onPressed: () async {
                                // sale = sale - 50;
                                // var formatter = new DateFormat('d MMM');
                                // selectedDateTime =
                                //     selectedDateTime.subtract(Duration(days: 7));

                                // final date = selectedDateTime;
                                // DateTime getDate(DateTime d) =>
                                //     DateTime(d.year, d.month, d.day);

                                // print('Date: $date');
                                // print(
                                //     'Start of week: ${getDate(date.subtract(Duration(days: date.weekday - 1)))}');
                                // print(
                                //     'End of week: ${getDate(date.add(Duration(days: DateTime.daysPerWeek - date.weekday)))}');

                                // setState(() {
                                //   weekDate =
                                //       "${formatter.format(getDate(date.subtract(Duration(days: date.weekday - 1))))} - ${formatter.format(getDate(date.add(Duration(days: DateTime.daysPerWeek - date.weekday))))}";
                                // });
                                // print(weekDate);

                                data = [];
                                var formatter = new DateFormat('d MMM');

                                if (weekly) {
                                  selectedDateTime = selectedDateTime
                                      .subtract(Duration(days: 7));
                                  print('selectedDateTime ${selectedDateTime}');
                                  final date = selectedDateTime;
                                  DateTime getDate(DateTime d) =>
                                      DateTime(d.year, d.month, d.day);

                                  print('Date: $date');
                                  print(
                                      'Start of week: ${getDate(date.subtract(Duration(days: date.weekday - 1)))}');
                                  print(
                                      'End of week: ${getDate(date.add(Duration(days: DateTime.daysPerWeek - date.weekday)))}');

                                  print(weekDate);

                                  startDate = getDate(date.subtract(
                                      Duration(days: date.weekday - 1)));
                                  endDate = getDate(date.add(Duration(
                                      days: DateTime.daysPerWeek -
                                          date.weekday)));

                                  sale = 0.0;
                                  getProducts(startDate, endDate);

                                  for (var item in SalesDataDump) {
                                    var itemDate = DateTime.parse(
                                        item["sDate"].toString());

                                    if (itemDate.compareTo(startDate) > 0 &&
                                        itemDate.compareTo(endDate) < 0) {
                                      highSale = item["netAmount"] > highSale
                                          ? item["netAmount"]
                                          : highSale;

                                      sale = sale +
                                          double.parse(
                                              item["netAmount"].toString());
                                      print(item["sDate"]);
                                      print(item["netAmount"]);
                                      print(DateFormat('EEE').format(
                                          DateTime.parse(
                                              item["sDate"].toString())));
                                      String dayThis = DateFormat('EEE').format(
                                          DateTime.parse(
                                              item["sDate"].toString()));

                                      /// e.g Thursday
                                      String match1 = DateFormat('yyyy-MM-dd')
                                          .format(DateTime.now());
                                      String match2 = DateFormat('yyyy-MM-dd')
                                          .format(DateTime.parse(
                                              item["sDate"].toString()));

                                      /// e.g Thursday
                                      data.add(_ChartData(dayThis,
                                          item["netAmount"], kPrimaryColor));
                                    }
                                    if (itemDate == startDate ||
                                        itemDate == endDate) {
                                      highSale = item["netAmount"] > highSale
                                          ? item["netAmount"]
                                          : highSale;

                                      sale = sale +
                                          double.parse(
                                              item["netAmount"].toString());
                                      print(item["sDate"]);
                                      print(selectedDateTime);
                                      print(item["netAmount"]);
                                      print(DateFormat('EEEE').format(
                                          DateTime.parse(
                                              item["sDate"].toString())));

                                      /// e.g Thursday
                                      String dayThis = DateFormat('EEE').format(
                                          DateTime.parse(
                                              item["sDate"].toString()));

                                      /// e.g Thursday
                                      String match1 = DateFormat('yyyy-MM-dd')
                                          .format(DateTime.now());
                                      String match2 = DateFormat('yyyy-MM-dd')
                                          .format(DateTime.parse(
                                              item["sDate"].toString()));

                                      /// e.g Thursday
                                      data.add(_ChartData(dayThis,
                                          item["netAmount"], kPrimaryColor));
                                    }
                                  }
                                  setState(() {
                                    weekDate =
                                        "${formatter.format(startDate)} - ${formatter.format(endDate)}";
                                    showThisDate = weekDate;
                                  });
                                }

                                if (yearly) {
                                  dataMonth = [];
                                  var now = new DateTime.now();
                                  var formatter = new DateFormat('d MMM');

                                  final date = DateTime.now();
                                  DateTime getDate(DateTime d) =>
                                      DateTime(d.year, d.month, d.day);

                                  print('Date: $date');
                                  print(
                                      'Start of week: ${getDate(date.subtract(Duration(days: date.weekday - 1)))}');
                                  print(
                                      'End of week: ${getDate(date.add(Duration(days: DateTime.daysPerWeek - date.weekday)))}');
                                  startDate = getDate(DateTime.parse(
                                      "${int.parse(weekDate) - 1}-01-01"));
                                  endDate = getDate(DateTime.parse(
                                      "${int.parse(weekDate) - 1}-12-31"));
                                  print('startDate ${startDate}');
                                  print('endDate ${endDate}');
                                  getProducts(startDate, endDate);

                                  sale = 0;
                                  getProducts(startDate, endDate);
                                  for (var item in SalesDataDump) {
                                    var itemDate = DateTime.parse(
                                        item["sDate"].toString());

                                    if (itemDate.compareTo(startDate) > 0 &&
                                        itemDate.compareTo(endDate) < 0) {
                                      highSale = item["netAmount"] > highSale
                                          ? item["netAmount"]
                                          : highSale;

                                      sale = sale +
                                          double.parse(
                                              item["netAmount"].toString());

                                      print(item["sDate"]);
                                      print(item["netAmount"]);
                                      print(DateFormat('MMM').format(
                                          DateTime.parse(
                                              item["sDate"].toString())));
                                      String dayThis = DateFormat('yyy').format(
                                          DateTime.parse(
                                              item["sDate"].toString()));

                                      /// e.g Thursday
                                      String match1 = DateFormat('yyyy')
                                          .format(DateTime.now());
                                      String match2 = DateFormat('yyyy').format(
                                          DateTime.parse(
                                              item["sDate"].toString()));
                                      print('mm');
                                      print(match1);
                                      print(match2);

                                      /// e.g Thursday
                                      dataMonth.add(_ChartData(dayThis,
                                          item["netAmount"], kPrimaryColor));
                                    }
                                    if (itemDate == startDate ||
                                        itemDate == endDate) {
                                      highSale = item["netAmount"] > highSale
                                          ? item["netAmount"]
                                          : highSale;

                                      sale = sale +
                                          double.parse(
                                              item["netAmount"].toString());
                                      print(item["sDate"]);
                                      print(item["netAmount"]);
                                      print(DateFormat('MMM').format(
                                          DateTime.parse(
                                              item["sDate"].toString())));

                                      /// e.g Thursday
                                      String dayThis = DateFormat('yyy').format(
                                          DateTime.parse(
                                              item["sDate"].toString()));

                                      /// e.g Thursday
                                      String match1 = DateFormat('yyyy')
                                          .format(DateTime.now());
                                      String match2 = DateFormat('yyyy').format(
                                          DateTime.parse(
                                              item["sDate"].toString()));

                                      /// e.g Thursday
                                      dataMonth.add(_ChartData(dayThis,
                                          item["netAmount"], kPrimaryColor));
                                    }
                                  }

                                  print('highSale year ${highSale}');
                                  setState(() {
                                    weekDate = "${int.parse(weekDate) - 1}";
                                    showThisDate = weekDate;

                                    yearly = true;
                                    weekly = false;
                                  });
                                }

                                if (monthly) {
                                  dataDaily = [];
                                  var now = new DateTime.now();
                                  var formatter = new DateFormat('d MMM');

                                  final date = DateTime.now();
                                  DateTime getDate(DateTime d) =>
                                      DateTime(d.year, d.month, d.day);

                                  var setDate = int.parse(weekDate) - 1;
                                  String sendDate = "";
                                  if (setDate.toString().length == 1) {
                                    sendDate = "0${setDate.toString()}";
                                  } else {
                                    sendDate = setDate.toString();
                                  }

                                  print('sendDate: $sendDate');
                                  print(
                                      'Start of week: ${getDate(date.subtract(Duration(days: date.weekday - 1)))}');
                                  print(
                                      'End of week: ${getDate(date.add(Duration(days: DateTime.daysPerWeek - date.weekday)))}');

                                  startDate = getDate(DateTime.parse(
                                      "${date.year}-${sendDate}-01"));
                                  endDate = DateTime(
                                      date.year, int.parse(sendDate) + 1, 0);
                                  highSale = 100;
                                  getProducts(startDate, endDate);

                                  print('startDate ${startDate}');
                                  print('endDate ${endDate}');
                                  sale = 0;
                                  getProducts(startDate, endDate);
                                  for (var item in SalesDataDump) {
                                    var itemDate = DateTime.parse(
                                        item["sDate"].toString());

                                    if (itemDate.compareTo(startDate) > 0 &&
                                        itemDate.compareTo(endDate) < 0) {
                                      highSale = item["netAmount"] > highSale
                                          ? item["netAmount"]
                                          : highSale;

                                      sale = sale +
                                          double.parse(
                                              item["netAmount"].toString());

                                      print(item["sDate"]);
                                      print(item["netAmount"]);
                                      print(DateFormat('dd').format(
                                          DateTime.parse(
                                              item["sDate"].toString())));
                                      String dayThis = DateFormat('MMM').format(
                                          DateTime.parse(
                                              item["sDate"].toString()));

                                      /// e.g Thursday
                                      String match1 = DateFormat('yyyy-MM')
                                          .format(DateTime.now());
                                      String match2 = DateFormat('yyyy-MM')
                                          .format(DateTime.parse(
                                              item["sDate"].toString()));

                                      /// e.g Thursday
                                      dataDaily.add(_ChartData(dayThis,
                                          item["netAmount"], kPrimaryColor));
                                    }
                                    if (itemDate == startDate ||
                                        itemDate == endDate) {
                                      highSale = item["netAmount"] > highSale
                                          ? item["netAmount"]
                                          : highSale;

                                      sale = sale +
                                          double.parse(
                                              item["netAmount"].toString());
                                      print(item["sDate"]);
                                      print(item["netAmount"]);
                                      print(DateFormat('dd').format(
                                          DateTime.parse(
                                              item["sDate"].toString())));

                                      /// e.g Thursday
                                      String dayThis = DateFormat('MMM').format(
                                          DateTime.parse(
                                              item["sDate"].toString()));

                                      /// e.g Thursday
                                      String match1 = DateFormat('yyyy-MM')
                                          .format(DateTime.now());
                                      String match2 = DateFormat('yyyy-MM')
                                          .format(DateTime.parse(
                                              item["sDate"].toString()));

                                      /// e.g Thursday
                                      dataDaily.add(_ChartData(dayThis,
                                          item["netAmount"], kPrimaryColor));
                                    }
                                  }

                                  print('highSale year ${highSale}');
                                  setState(() {
                                    weekDate = weekDate == "1"
                                        ? "12"
                                        : "${int.parse(weekDate) - 1}";
                                    var show =
                                        DateTime.parse(startDate.toString());
                                    showThisDate =
                                        DateFormat('MMMM yyyy').format(show);
                                  });
                                  print('weekDate ${weekDate}');
                                }

                                if (daily) {
                                  dataDaily = [];
                                  print('daily');
                                  var now = new DateTime.now();
                                  var formatter = new DateFormat('d MMM');

                                  final date = DateTime.now();
                                  print('dailt time 2 ${dailyTime}');

                                  dailyTime =
                                      dailyTime.subtract(Duration(days: 1));
                                  print(dailyTime);

                                  var takeThis = dailyTime;

                                  DateTime getDate(DateTime d) =>
                                      DateTime(d.year, d.month, d.day);

                                  startDate = getDate(takeThis.subtract(
                                      Duration(days: takeThis.weekday - 1)));
                                  endDate = getDate(takeThis.add(Duration(
                                      days: DateTime.daysPerWeek -
                                          takeThis.weekday)));

                                  highSale = 100;
                                  print('startDate ${startDate}');
                                  print('endDate ${endDate}');
                                  sale = 0;
                                  getProducts(dailyTime, dailyTime);
                                  for (var item in SalesDataDump) {
                                    var itemDate = DateTime.parse(
                                        item["sDate"].toString());

                                    if (itemDate.compareTo(startDate) > 0 &&
                                        itemDate.compareTo(endDate) < 0) {
                                      highSale = item["netAmount"] > highSale
                                          ? item["netAmount"]
                                          : highSale;

                                      print(item["sDate"]);
                                      print(item["netAmount"]);
                                      print(DateFormat('dd').format(
                                          DateTime.parse(
                                              item["sDate"].toString())));
                                      String dayThis = DateFormat('dd').format(
                                          DateTime.parse(
                                              item["sDate"].toString()));

                                      /// e.g Thursday
                                      String match1 = DateFormat('yyyy-MM-dd')
                                          .format(dailyTime);
                                      String match2 = DateFormat('yyyy-MM-dd')
                                          .format(DateTime.parse(
                                              item["sDate"].toString()));
                                      if (match1 == match2) {
                                        sale = item["netAmount"];
                                      }

                                      /// e.g Thursday
                                      dataDaily.add(_ChartData(
                                          dayThis,
                                          item["netAmount"],
                                          match1 == match2
                                              ? kPrimaryColor
                                              : Color(0xffcde0e7)));
                                    }
                                    if (itemDate == startDate ||
                                        itemDate == endDate) {
                                      highSale = item["netAmount"] > highSale
                                          ? item["netAmount"]
                                          : highSale;

                                      print(item["sDate"]);
                                      print(item["netAmount"]);
                                      print(DateFormat('dd').format(
                                          DateTime.parse(
                                              item["sDate"].toString())));

                                      /// e.g Thursday
                                      String dayThis = DateFormat('dd').format(
                                          DateTime.parse(
                                              item["sDate"].toString()));

                                      /// e.g Thursday
                                      String match1 = DateFormat('yyyy-MM-dd')
                                          .format(dailyTime);
                                      String match2 = DateFormat('yyyy-MM-dd')
                                          .format(DateTime.parse(
                                              item["sDate"].toString()));
                                      if (match1 == match2) {
                                        sale = item["netAmount"];
                                      }

                                      /// e.g Thursday
                                      dataDaily.add(_ChartData(
                                          dayThis,
                                          item["netAmount"],
                                          match1 == match2
                                              ? kPrimaryColor
                                              : Color(0xffcde0e7)));
                                    }
                                  }

                                  print('highSale year ${highSale}');
                                  setState(() {
                                    weekDate = DateFormat('dd MMM yyyy')
                                        .format(dailyTime);
                                    showThisDate = weekDate;
                                  });
                                  print('weekDate ${weekDate}');
                                }
                              },
                              constraints: BoxConstraints(),
                              elevation: 2.0,
                              fillColor: kPrimaryColor,
                              child: Icon(
                                Icons.keyboard_arrow_left_sharp,
                                size: 26.0,
                                color: Colors.white,
                              ),
                              padding: EdgeInsets.all(7.0),
                              shape: CircleBorder(),
                            ),
                            Text(showThisDate,
                                style: TextStyle(
                                    fontFamily: 'PoppinsMedium',
                                    fontSize: 18,
                                    color: Colors.black)),
                            RawMaterialButton(
                              onPressed: () async {
                                if (weekly) {
                                  final date = selectedDateTime;
                                  DateTime getDate(DateTime d) =>
                                      DateTime(d.year, d.month, d.day);

                                  print('week');

                                  var todayEndendDate = getDate(DateTime.now()
                                      .add(Duration(
                                          days: DateTime.daysPerWeek -
                                              DateTime.now().weekday)));

                                  var checkDate = getDate(date.add(Duration(
                                      days: DateTime.daysPerWeek -
                                          date.weekday)));
                                  print('week');
                                  print(todayEndendDate);
                                  print(checkDate);
                                  print(
                                      todayEndendDate.compareTo(checkDate) > 0);

                                  if (todayEndendDate.compareTo(checkDate) >
                                      0) {
                                    data = [];
                                    var formatter = new DateFormat('d MMM');

                                    selectedDateTime =
                                        selectedDateTime.add(Duration(days: 7));

                                    final date = selectedDateTime;
                                    DateTime getDate(DateTime d) =>
                                        DateTime(d.year, d.month, d.day);

                                    print('Date: $date');
                                    print(
                                        'Start of week: ${getDate(date.subtract(Duration(days: date.weekday - 1)))}');
                                    print(
                                        'End of week: ${getDate(date.add(Duration(days: DateTime.daysPerWeek - date.weekday)))}');

                                    print(weekDate);

                                    startDate = getDate(date.subtract(
                                        Duration(days: date.weekday - 1)));
                                    endDate = getDate(date.add(Duration(
                                        days: DateTime.daysPerWeek -
                                            date.weekday)));

                                    getProducts(startDate, endDate);
                                    sale = 0.0;
                                    for (var item in SalesDataDump) {
                                      var itemDate = DateTime.parse(
                                          item["sDate"].toString());

                                      if (itemDate.compareTo(startDate) > 0 &&
                                          itemDate.compareTo(endDate) < 0) {
                                        highSale = item["netAmount"] > highSale
                                            ? item["netAmount"]
                                            : highSale;

                                        sale = sale +
                                            double.parse(
                                                item["netAmount"].toString());
                                        print(item["sDate"]);
                                        print(selectedDateTime);
                                        print(item["netAmount"]);
                                        print(DateFormat('EEE').format(
                                            DateTime.parse(
                                                item["sDate"].toString())));
                                        String dayThis = DateFormat('EEE')
                                            .format(DateTime.parse(
                                                item["sDate"].toString()));

                                        String match1 = DateFormat('yyyy-MM-dd')
                                            .format(DateTime.now());
                                        String match2 = DateFormat('yyyy-MM-dd')
                                            .format(DateTime.parse(
                                                item["sDate"].toString()));

                                        /// e.g Thursday
                                        data.add(_ChartData(dayThis,
                                            item["netAmount"], kPrimaryColor));
                                      }
                                      if (itemDate == startDate ||
                                          itemDate == endDate) {
                                        highSale = item["netAmount"] > highSale
                                            ? item["netAmount"]
                                            : highSale;

                                        sale = sale +
                                            double.parse(
                                                item["netAmount"].toString());
                                        print(item["sDate"]);
                                        print(selectedDateTime);

                                        print(item["netAmount"]);
                                        print(DateFormat('EEEE').format(
                                            DateTime.parse(
                                                item["sDate"].toString())));

                                        /// e.g Thursday
                                        String dayThis = DateFormat('EEE')
                                            .format(DateTime.parse(
                                                item["sDate"].toString()));

                                        String match1 = DateFormat('yyyy-MM-dd')
                                            .format(DateTime.now());
                                        String match2 = DateFormat('yyyy-MM-dd')
                                            .format(DateTime.parse(
                                                item["sDate"].toString()));

                                        /// e.g Thursday
                                        data.add(_ChartData(dayThis,
                                            item["netAmount"], kPrimaryColor));
                                      }
                                    }

                                    setState(() {
                                      weekDate =
                                          "${formatter.format(getDate(date.subtract(Duration(days: date.weekday - 1))))} - ${formatter.format(getDate(date.add(Duration(days: DateTime.daysPerWeek - date.weekday))))}";
                                      showThisDate = weekDate;
                                    });
                                  }
                                }

                                if (yearly) {
                                  var now = new DateTime.now();
                                  var formatter = new DateFormat('yyyy');
                                  String formattedDate = formatter.format(now);

                                  print(int.parse(formattedDate.toString()));
                                  print(int.parse(weekDate) + 1);
                                  print(int.parse(formattedDate.toString()) >=
                                      int.parse(weekDate) + 1);

                                  if (int.parse(formattedDate.toString()) >=
                                      int.parse(weekDate) + 1) {
                                    dataMonth = [];
                                    var now = new DateTime.now();
                                    var formatter = new DateFormat('d MMM');

                                    final date = DateTime.now();
                                    DateTime getDate(DateTime d) =>
                                        DateTime(d.year, d.month, d.day);

                                    print('Date: $date');
                                    print(
                                        'Start of week: ${getDate(date.subtract(Duration(days: date.weekday - 1)))}');
                                    print(
                                        'End of week: ${getDate(date.add(Duration(days: DateTime.daysPerWeek - date.weekday)))}');
                                    startDate = getDate(DateTime.parse(
                                        "${int.parse(weekDate) + 1}-01-01"));
                                    endDate = getDate(DateTime.parse(
                                        "${int.parse(weekDate) + 1}-12-31"));
                                    print('startDate ${startDate}');
                                    print('endDate ${endDate}');
                                    sale = 0;
                                    getProducts(startDate, endDate);
                                    for (var item in SalesDataDump) {
                                      var itemDate = DateTime.parse(
                                          item["sDate"].toString());

                                      if (itemDate.compareTo(startDate) > 0 &&
                                          itemDate.compareTo(endDate) < 0) {
                                        highSale = item["netAmount"] > highSale
                                            ? item["netAmount"]
                                            : highSale;

                                        sale = sale +
                                            double.parse(
                                                item["netAmount"].toString());

                                        print(item["sDate"]);
                                        print(item["netAmount"]);
                                        print(DateFormat('MMM').format(
                                            DateTime.parse(
                                                item["sDate"].toString())));
                                        String dayThis = DateFormat('yyy')
                                            .format(DateTime.parse(
                                                item["sDate"].toString()));

                                        /// e.g Thursday
                                        String match1 = DateFormat('yyyy')
                                            .format(DateTime.now());
                                        String match2 = DateFormat('yyyy')
                                            .format(DateTime.parse(
                                                item["sDate"].toString()));

                                        /// e.g Thursday
                                        dataMonth.add(_ChartData(dayThis,
                                            item["netAmount"], kPrimaryColor));
                                      }
                                      if (itemDate == startDate ||
                                          itemDate == endDate) {
                                        highSale = item["netAmount"] > highSale
                                            ? item["netAmount"]
                                            : highSale;

                                        sale = sale +
                                            double.parse(
                                                item["netAmount"].toString());
                                        print(item["sDate"]);
                                        print(item["netAmount"]);
                                        print(DateFormat('MMM').format(
                                            DateTime.parse(
                                                item["sDate"].toString())));

                                        /// e.g Thursday
                                        String dayThis = DateFormat('yyy')
                                            .format(DateTime.parse(
                                                item["sDate"].toString()));

                                        /// e.g Thursday
                                        String match1 = DateFormat('yyyy')
                                            .format(DateTime.now());
                                        String match2 = DateFormat('yyyy')
                                            .format(DateTime.parse(
                                                item["sDate"].toString()));

                                        /// e.g Thursday
                                        dataMonth.add(_ChartData(dayThis,
                                            item["netAmount"], kPrimaryColor));
                                      }
                                    }

                                    print('highSale year ${highSale}');
                                    setState(() {
                                      weekDate = "${int.parse(weekDate) + 1}";
                                      showThisDate = weekDate;
                                    });
                                  }
                                }
                                if (monthly) {
                                  var now = new DateTime.now();
                                  var formatter = new DateFormat('yyyy-MM-dd');
                                  String formattedDate = formatter.format(now);
                                  print(formattedDate);

                                  var startCheck =
                                      DateTime.parse(formattedDate);

                                  DateTime getDate(DateTime d) =>
                                      DateTime(d.year, d.month, d.day);

                                  var setDate = int.parse(weekDate) + 1;
                                  String sendDate = "";
                                  if (setDate.toString().length == 1) {
                                    sendDate = "0${setDate.toString()}";
                                  } else {
                                    sendDate = setDate.toString();
                                  }

                                  print(startCheck);

                                  var endCheck = DateTime(DateTime.now().year,
                                      int.parse(sendDate) + 1, 0);
                                  print(endCheck);

                                  print(endCheck.compareTo(startCheck) > 0);
                                  print(startCheck.compareTo(endCheck) > 0);

                                  if (startCheck.compareTo(endCheck) > 0) {
                                    dataDaily = [];
                                    var now = new DateTime.now();
                                    var formatter = new DateFormat('d MMM');

                                    final date = DateTime.now();
                                    DateTime getDate(DateTime d) =>
                                        DateTime(d.year, d.month, d.day);

                                    var setDate = int.parse(weekDate) + 1;
                                    String sendDate = "";
                                    if (setDate.toString().length == 1) {
                                      sendDate = "0${setDate.toString()}";
                                    } else {
                                      sendDate = setDate.toString();
                                    }

                                    print('sendDate: $sendDate');
                                    print(
                                        'Start of week: ${getDate(date.subtract(Duration(days: date.weekday - 1)))}');
                                    print(
                                        'End of week: ${getDate(date.add(Duration(days: DateTime.daysPerWeek - date.weekday)))}');

                                    startDate = getDate(DateTime.parse(
                                        "${date.year}-${sendDate}-01"));
                                    endDate = DateTime(
                                        date.year, int.parse(sendDate) + 1, 0);
                                    highSale = 100;
                                    print('startDate ${startDate}');
                                    print('endDate ${endDate}');
                                    sale = 0;
                                    getProducts(startDate, endDate);
                                    for (var item in SalesDataDump) {
                                      var itemDate = DateTime.parse(
                                          item["sDate"].toString());

                                      if (itemDate.compareTo(startDate) > 0 &&
                                          itemDate.compareTo(endDate) < 0) {
                                        highSale = item["netAmount"] > highSale
                                            ? item["netAmount"]
                                            : highSale;

                                        sale = sale +
                                            double.parse(
                                                item["netAmount"].toString());

                                        print(item["sDate"]);
                                        print(item["netAmount"]);
                                        print(DateFormat('dd').format(
                                            DateTime.parse(
                                                item["sDate"].toString())));
                                        String dayThis = DateFormat('MMM')
                                            .format(DateTime.parse(
                                                item["sDate"].toString()));

                                        /// e.g Thursday
                                        String match1 = DateFormat('yyyy-MM')
                                            .format(DateTime.now());
                                        String match2 = DateFormat('yyyy-MM')
                                            .format(DateTime.parse(
                                                item["sDate"].toString()));

                                        /// e.g Thursday
                                        dataDaily.add(_ChartData(dayThis,
                                            item["netAmount"], kPrimaryColor));
                                      }
                                      if (itemDate == startDate ||
                                          itemDate == endDate) {
                                        highSale = item["netAmount"] > highSale
                                            ? item["netAmount"]
                                            : highSale;

                                        sale = sale +
                                            double.parse(
                                                item["netAmount"].toString());
                                        print(item["sDate"]);
                                        print(item["netAmount"]);
                                        print(DateFormat('dd').format(
                                            DateTime.parse(
                                                item["sDate"].toString())));

                                        /// e.g Thursday
                                        String dayThis = DateFormat('MMM')
                                            .format(DateTime.parse(
                                                item["sDate"].toString()));

                                        /// e.g Thursday
                                        String match1 = DateFormat('yyyy-MM')
                                            .format(DateTime.now());
                                        String match2 = DateFormat('yyyy-MM')
                                            .format(DateTime.parse(
                                                item["sDate"].toString()));

                                        /// e.g Thursday
                                        dataDaily.add(_ChartData(dayThis,
                                            item["netAmount"], kPrimaryColor));
                                      }
                                    }

                                    print('highSale year ${highSale}');
                                    setState(() {
                                      weekDate = weekDate == "12"
                                          ? "1"
                                          : "${int.parse(weekDate) + 1}";

                                      var show =
                                          DateTime.parse(startDate.toString());
                                      showThisDate =
                                          DateFormat('MMMM yyyy').format(show);
                                    });
                                    print('weekDate ${weekDate}');
                                  }
                                }
                                if (daily) {
                                  DateTime ssTime =
                                      dailyTime.add(Duration(days: 1));

                                  print(DateTime.now().compareTo(ssTime) > 0);

                                  if (DateTime.now().compareTo(ssTime) > 0) {
                                    dataDaily = [];
                                    print('daily');
                                    var now = new DateTime.now();
                                    var formatter = new DateFormat('d MMM');

                                    final date = DateTime.now();
                                    print(dailyTime);

                                    dailyTime =
                                        dailyTime.add(Duration(days: 1));
                                    print(dailyTime);

                                    var takeThis = dailyTime;

                                    DateTime getDate(DateTime d) =>
                                        DateTime(d.year, d.month, d.day);

                                    startDate = getDate(takeThis.subtract(
                                        Duration(days: takeThis.weekday - 1)));
                                    endDate = getDate(takeThis.add(Duration(
                                        days: DateTime.daysPerWeek -
                                            takeThis.weekday)));

                                    highSale = 100;
                                    print('startDate ${startDate}');
                                    print('endDate ${endDate}');
                                    sale = 0;
                                    getProducts(dailyTime, dailyTime);
                                    for (var item in SalesDataDump) {
                                      var itemDate = DateTime.parse(
                                          item["sDate"].toString());

                                      if (itemDate.compareTo(startDate) > 0 &&
                                          itemDate.compareTo(endDate) < 0) {
                                        highSale = item["netAmount"] > highSale
                                            ? item["netAmount"]
                                            : highSale;

                                        print(item["sDate"]);
                                        print(item["netAmount"]);
                                        print(DateFormat('dd').format(
                                            DateTime.parse(
                                                item["sDate"].toString())));
                                        String dayThis = DateFormat('dd')
                                            .format(DateTime.parse(
                                                item["sDate"].toString()));

                                        /// e.g Thursday
                                        String match1 = DateFormat('yyyy-MM-dd')
                                            .format(dailyTime);
                                        String match2 = DateFormat('yyyy-MM-dd')
                                            .format(DateTime.parse(
                                                item["sDate"].toString()));
                                        if (match1 == match2) {
                                          sale = item["netAmount"];
                                        }

                                        /// e.g Thursday
                                        dataDaily.add(_ChartData(
                                            dayThis,
                                            item["netAmount"],
                                            match1 == match2
                                                ? kPrimaryColor
                                                : Color(0xffcde0e7)));
                                      }
                                      if (itemDate == startDate ||
                                          itemDate == endDate) {
                                        highSale = item["netAmount"] > highSale
                                            ? item["netAmount"]
                                            : highSale;

                                        print(item["sDate"]);
                                        print(item["netAmount"]);
                                        print(DateFormat('dd').format(
                                            DateTime.parse(
                                                item["sDate"].toString())));

                                        /// e.g Thursday
                                        String dayThis = DateFormat('dd')
                                            .format(DateTime.parse(
                                                item["sDate"].toString()));

                                        /// e.g Thursday
                                        String match1 = DateFormat('yyyy-MM-dd')
                                            .format(dailyTime);
                                        String match2 = DateFormat('yyyy-MM-dd')
                                            .format(DateTime.parse(
                                                item["sDate"].toString()));
                                        if (match1 == match2) {
                                          sale = item["netAmount"];
                                        }

                                        /// e.g Thursday
                                        dataDaily.add(_ChartData(
                                            dayThis,
                                            item["netAmount"],
                                            match1 == match2
                                                ? kPrimaryColor
                                                : Color(0xffcde0e7)));
                                      }
                                    }

                                    print('highSale year ${highSale}');
                                    setState(() {
                                      weekDate = DateFormat('dd MMM yyyy')
                                          .format(dailyTime);
                                      showThisDate = weekDate;
                                    });
                                    print('weekDate ${weekDate}');
                                  }
                                }
                              },
                              constraints: BoxConstraints(),
                              elevation: 2.0,
                              fillColor: kPrimaryColor,
                              child: Icon(
                                Icons.keyboard_arrow_right_sharp,
                                size: 26.0,
                                color: Colors.white,
                              ),
                              padding: EdgeInsets.all(7.0),
                              shape: CircleBorder(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                : Container(),

            SizedBox(
              height: MediaQuery.of(context).size.height * 0.02,
            ),
            showHideGraph
                ? Column(
                    children: [
                      Container(
                        width: width * 0.9,
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: Text('Top 10 Product',
                              textAlign: TextAlign.center,
                              style: new TextStyle(
                                fontSize: 21,
                                fontWeight: FontWeight.w500,
                              )),
                        ),
                      ),
                      SizedBox(
                        height: 11,
                      ),

                      // Container(
                      //   width: width * 0.9,
                      //   decoration: BoxDecoration(
                      //       color: Color(0xfffECF0F1),
                      //       borderRadius: BorderRadius.all(Radius.circular(10))),
                      //   child: Padding(
                      //     padding: const EdgeInsets.all(10.0),
                      //     child: Column(
                      //       children: [
                      //         Row(
                      //           crossAxisAlignment: CrossAxisAlignment.center,
                      //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      //           children: [
                      //             Column(
                      //               crossAxisAlignment: CrossAxisAlignment.start,
                      //               children: [
                      //                 Text('Panadol',
                      //                     textAlign: TextAlign.center,
                      //                     style: new TextStyle(
                      //                       fontSize: 18,
                      //                       fontWeight: FontWeight.w400,
                      //                     )),
                      //                 SizedBox(
                      //                   height: 7,
                      //                 ),
                      //                 LinearPercentIndicator(
                      //                     animationDuration: 1500,
                      //                     animation: true,
                      //                     trailing: Text(" 310"),
                      //                     width: width * 0.6,
                      //                     lineHeight: 9.0,
                      //                     percent: 0.7,
                      //                     progressColor: kPrimaryColor,
                      //                     backgroundColor: Color(0xffcde0e7))
                      //               ],
                      //             ),
                      //             Icon(
                      //               Icons.keyboard_arrow_right_sharp,
                      //               size: 40.0,
                      //               color: textGreyColor,
                      //             ),
                      //           ],
                      //         ),
                      //         SizedBox(
                      //           height: 11,
                      //         ),
                      //         Row(
                      //           crossAxisAlignment: CrossAxisAlignment.center,
                      //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      //           children: [
                      //             Column(
                      //               crossAxisAlignment: CrossAxisAlignment.start,
                      //               children: [
                      //                 Text('Dispirin',
                      //                     textAlign: TextAlign.center,
                      //                     style: new TextStyle(
                      //                       fontSize: 18,
                      //                       fontWeight: FontWeight.w400,
                      //                     )),
                      //                 SizedBox(
                      //                   height: 7,
                      //                 ),
                      //                 LinearPercentIndicator(
                      //                     animationDuration: 1500,
                      //                     animation: true,
                      //                     trailing: Text(" 421"),
                      //                     width: width * 0.6,
                      //                     lineHeight: 9.0,
                      //                     percent: 0.6,
                      //                     progressColor: kPrimaryColor,
                      //                     backgroundColor: Color(0xffcde0e7))
                      //               ],
                      //             ),
                      //             Icon(
                      //               Icons.keyboard_arrow_right_sharp,
                      //               size: 40.0,
                      //               color: textGreyColor,
                      //             ),
                      //           ],
                      //         ),
                      //         SizedBox(
                      //           height: 11,
                      //         ),
                      //         Row(
                      //           crossAxisAlignment: CrossAxisAlignment.center,
                      //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      //           children: [
                      //             Column(
                      //               crossAxisAlignment: CrossAxisAlignment.start,
                      //               children: [
                      //                 Text('Cerelac',
                      //                     textAlign: TextAlign.center,
                      //                     style: new TextStyle(
                      //                       fontSize: 18,
                      //                       fontWeight: FontWeight.w400,
                      //                     )),
                      //                 SizedBox(
                      //                   height: 7,
                      //                 ),
                      //                 LinearPercentIndicator(
                      //                     animationDuration: 1500,
                      //                     animation: true,
                      //                     trailing: Text(" 100"),
                      //                     width: width * 0.6,
                      //                     lineHeight: 9.0,
                      //                     percent: 0.7,
                      //                     progressColor: kPrimaryColor,
                      //                     backgroundColor: Color(0xffcde0e7))
                      //               ],
                      //             ),
                      //             Icon(
                      //               Icons.keyboard_arrow_right_sharp,
                      //               size: 40.0,
                      //               color: textGreyColor,
                      //             ),
                      //           ],
                      //         )
                      //       ],
                      //     ),
                      //   ),
                      // )
                    ],
                  )
                : Container(),
            showHideGraph
                ? Container(
                    decoration: BoxDecoration(
                        color: Color(0xfffECF0F1),
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                    width: width * 0.9,
                    child: ListView.builder(
                      itemCount: productShow.length,
                      shrinkWrap: true,
                      scrollDirection: Axis.vertical,
                      physics: ScrollPhysics(),
                      itemBuilder: (context, index) {
                        return Container(
                          width: width * 0.9,
                          child: Padding(
                            padding: const EdgeInsets.only(
                              right: 10,
                              left: 10,
                              top: 10,
                            ),
                            child: Column(
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                            expense
                                                ? productShow[index]
                                                        ['accountName']
                                                    .toString()
                                                : productShow[index]['itemName']
                                                    .toString(),
                                            textAlign: TextAlign.center,
                                            style: new TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w400,
                                            )),
                                      ],
                                    ),
                                    Text(
                                        expense
                                            ? productShow[index]['amount']
                                                .toStringAsFixed(0)
                                            : productShow[index]['qty'] != null
                                                ? productShow[index]['qty']
                                                    .toStringAsFixed(0)
                                                : "",
                                        textAlign: TextAlign.center,
                                        style: new TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w400,
                                        )),
                                    // Icon(
                                    //   Icons.keyboard_arrow_right_sharp,
                                    //   size: 40.0,
                                    //   color: textGreyColor,
                                    // ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );

                        //   return Padding(
                        // padding: EdgeInsets.only(top: 13),
                        //     child: Container(
                        //         width: width * 0.8,
                        //         decoration: BoxDecoration(
                        //           color: Color(0xffDCEEFC),
                        //           borderRadius: BorderRadius.circular(10),
                        //         ),
                        //         child: Padding(
                        //           padding: const EdgeInsets.all(13.0),
                        //           child: Column(
                        //             children: [
                        //               Text(productShow[index]['qty'].toString(),
                        //                   style: new TextStyle(
                        //                       fontSize: 19,
                        //                       fontWeight: FontWeight.w700,
                        //                       color: Color(0xff2D587B))),
                        //               Text(productShow[index]['itemName'].toString(),
                        //                   textAlign: TextAlign.center,
                        //                   style: new TextStyle(
                        //                       fontSize: 18,
                        //                       fontWeight: FontWeight.w400,
                        //                       color: Color(0xff2D587B)))
                        //             ],
                        //           ),
                        //         ),
                        //       ),
                        //   )
                        //  ;
                      },
                    ),
                  )
                : Container(),

            // stock
            //     ? Container(
            //         width: width * 0.9,
            //         child: Row(
            //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //           children: [
            //             Container(
            //               width: width * 0.275,
            //               decoration: BoxDecoration(
            //                 color: Color(0xffFDECED),
            //                 borderRadius: BorderRadius.circular(10),
            //               ),
            //               child: Padding(
            //                 padding: const EdgeInsets.all(13.0),
            //                 child: Column(
            //                   children: [
            //                     Text(stockData.length.toString(),
            //                         style: new TextStyle(
            //                             fontSize: 18,
            //                             fontWeight: FontWeight.w700,
            //                             color: Color(0xffE44450))),
            //                     Text('Total\nItem',
            //                         textAlign: TextAlign.center,
            //                         style: new TextStyle(
            //                             fontSize: 18,
            //                             fontWeight: FontWeight.w400,
            //                             color: Color(0xffE44450)))
            //                   ],
            //                 ),
            //               ),
            //             ),
            //             Container(
            //               width: width * 0.275,
            //               decoration: BoxDecoration(
            //                 color: Color(0xffF8F2E4),
            //                 borderRadius: BorderRadius.circular(10),
            //               ),
            //               child: Padding(
            //                 padding: const EdgeInsets.all(13.0),
            //                 child: Column(
            //                   children: [
            //                     Text(TotalIn.toStringAsFixed(0),
            //                         style: new TextStyle(
            //                             fontSize: 18,
            //                             fontWeight: FontWeight.w700,
            //                             color: Color(0xffCCA755))),
            //                     Text('Total\nItem In',
            //                         textAlign: TextAlign.center,
            //                         style: new TextStyle(
            //                             fontSize: 18,
            //                             fontWeight: FontWeight.w400,
            //                             color: Color(0xffCCA755)))
            //                   ],
            //                 ),
            //               ),
            //             ),
            //             Container(
            //               width: width * 0.275,
            //               decoration: BoxDecoration(
            //                 color: Color(0xffF8F2E4),
            //                 borderRadius: BorderRadius.circular(10),
            //               ),
            //               child: Padding(
            //                 padding: const EdgeInsets.all(13.0),
            //                 child: Column(
            //                   children: [
            //                     Text(TotalOut.toStringAsFixed(0),
            //                         style: new TextStyle(
            //                             fontSize: 18,
            //                             fontWeight: FontWeight.w700,
            //                             color: Color(0xffCCA755))),
            //                     Text('Total\nItem Out',
            //                         textAlign: TextAlign.center,
            //                         style: new TextStyle(
            //                             fontSize: 18,
            //                             fontWeight: FontWeight.w400,
            //                             color: Color(0xffCCA755)))
            //                   ],
            //                 ),
            //               ),
            //             ),
            //           ],
            //         ),
            //       )
            //     : Container(),

            SizedBox(
              height: stock ? 10 : 0,
            ),

            stock
                ? Container(
                    width: width * 0.9,
                    child: TextFormField(
                      controller: searchController,
                      onChanged: (value) {
                        setState(() {
                          searchString = value;
                        });

                        TotalIn = 0.0;
                        TotalOut = 0.0;

                        if (searchString.length > 1) {
                          for (var i = 0; i < stockData.length; i++) {
                            if (stockData[i]['itemName']
                                    .toString()
                                    .toLowerCase()
                                    .contains(searchString.toLowerCase()) ||
                                stockData[i]['itemName']
                                    .toString()
                                    .toUpperCase()
                                    .contains(searchString.toUpperCase())) {
                              setState(() {
                                TotalIn = 0.0;
                                TotalOut = 0.0;
                                var remaining = stockData[i]['itemIN'] -
                                    stockData[i]['itemOut'];
                                TotalIn = TotalIn + stockData[i]['itemIN'];
                                TotalOut = TotalOut + stockData[i]['itemOut'];

                                TotalRemaining = remaining;
                              });
                            }
                          }
                        } else {
                          for (var i = 0; i < stockData.length; i++) {
                            setState(() {
                              var remaining = stockData[i]['itemIN'] -
                                  stockData[i]['itemOut'];
                              TotalIn = TotalIn + stockData[i]['itemIN'];
                              TotalOut = TotalOut + stockData[i]['itemOut'];

                              TotalRemaining = remaining;
                            });
                          }
                        }
                      },
                      decoration: new InputDecoration(
                        suffixIcon: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8.0),
                              color: Color(0xffcde0e7), // Button color
                            ),
                            child: InkWell(
                              splashColor: Colors.red, // Splash color
                              onTap: () {
                                showModalBottomSheet(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.only(
                                          topLeft: const Radius.circular(20.0),
                                          topRight:
                                              const Radius.circular(20.0)),
                                    ),
                                    isScrollControlled: true,
                                    context: context,
                                    builder: (context) {
                                      String searchString2 = "";
                                      return StatefulBuilder(builder:
                                          (BuildContext context,
                                              StateSetter setStatee) {
                                        return Container(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.8,
                                          child: Column(
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 8),
                                                child: Container(
                                                  width: 40,
                                                  height: 8,
                                                  decoration: new BoxDecoration(
                                                      color: kPrimaryColor,
                                                      borderRadius:
                                                          new BorderRadius.all(
                                                              Radius.circular(
                                                                  10.0))),
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(13.0),
                                                child: Container(
                                                  width: double.infinity,
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      RichText(
                                                        text: new TextSpan(
                                                          // Note: Styles for TextSpans must be explicitly defined.
                                                          // Child text spans will inherit styles from parent
                                                          style: new TextStyle(
                                                            fontSize: 16.0,
                                                            color: Colors.black,
                                                          ),
                                                          children: <TextSpan>[
                                                            new TextSpan(
                                                                text: 'Select ',
                                                                style: new TextStyle(
                                                                    fontSize:
                                                                        17,
                                                                    fontFamily:
                                                                        'PoppinsMedium')),
                                                            new TextSpan(
                                                                text: 'Item',
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        17,
                                                                    fontFamily:
                                                                        'PoppinsRegular',
                                                                    color:
                                                                        textGreyColor)),
                                                          ],
                                                        ),
                                                      ),
                                                      GestureDetector(
                                                          onTap: () {
                                                            Navigator.pop(
                                                                context);
                                                          },
                                                          child: Icon(
                                                            Icons
                                                                .close_outlined,
                                                            color:
                                                                kPrimaryColor,
                                                          ))
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(13),
                                                child: Container(
                                                  child: TextFormField(
                                                    onChanged: (value) {
                                                      print(value);
                                                      setStatee(() {
                                                        searchString2 = value;
                                                      });
                                                    },
                                                    decoration:
                                                        new InputDecoration(
                                                      labelText: "Search",
                                                      labelStyle: TextStyle(
                                                          color: textGreyColor,
                                                          fontFamily:
                                                              'SegoeUI'),
                                                      filled: true,
                                                      fillColor: Colors.white,
                                                      focusedBorder:
                                                          OutlineInputBorder(
                                                        borderRadius:
                                                            new BorderRadius
                                                                .circular(10),
                                                        borderSide: BorderSide(
                                                            color:
                                                                kPrimaryColor,
                                                            width: 1.0),
                                                      ),
                                                      enabledBorder:
                                                          OutlineInputBorder(
                                                        borderRadius:
                                                            new BorderRadius
                                                                .circular(10),
                                                        borderSide: BorderSide(
                                                            color: Color(
                                                                0xffE6E6E6),
                                                            width: 1.0),
                                                      ),

                                                      border:
                                                          new OutlineInputBorder(
                                                        borderRadius:
                                                            new BorderRadius
                                                                .circular(10),
                                                        borderSide:
                                                            new BorderSide(
                                                                color: Color(
                                                                    0xffE6E6E6)),
                                                      ),
                                                      //fillColor: Colors.green
                                                    ),
                                                    keyboardType: TextInputType
                                                        .emailAddress,
                                                    style: new TextStyle(
                                                        fontFamily: "SegoeUI",
                                                        color: kPrimaryColor),
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                child: new ListView.builder(
                                                  itemCount: stockData.length,
                                                  shrinkWrap: true,
                                                  scrollDirection:
                                                      Axis.vertical,
                                                  physics: ScrollPhysics(),
                                                  itemBuilder:
                                                      (context, index) {
                                                    return stockData[index]
                                                                ['itemName']
                                                            .toString()
                                                            .toLowerCase()
                                                            .contains(searchString2
                                                                .toLowerCase())
                                                        ? Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                        .only(
                                                                    bottom: 10,
                                                                    left: 15,
                                                                    right: 15),
                                                            child: Container(
                                                              child:
                                                                  GestureDetector(
                                                                onTap:
                                                                    () async {
                                                                  setState(() {
                                                                    searchController
                                                                        .text = stockData[index]
                                                                            [
                                                                            'itemName']
                                                                        .toString();
                                                                    searchString =
                                                                        stockData[index]['itemName']
                                                                            .toString();
                                                                  });
                                                                  print(
                                                                      searchString);
                                                                  print(
                                                                      searchController
                                                                          .text);
                                                                  Navigator.pop(
                                                                      context);

                                                                  // if (weekly) {
                                                                  //   print(
                                                                  //       'week');
                                                                  //   selectedDateTime =
                                                                  //       DateTime
                                                                  //           .now();
                                                                  //   data = [];
                                                                  //   var now =
                                                                  //       new DateTime
                                                                  //           .now();
                                                                  //   var formatter =
                                                                  //       new DateFormat(
                                                                  //           'd MMM');

                                                                  //   final date =
                                                                  //       DateTime
                                                                  //           .now();
                                                                  //   DateTime getDate(
                                                                  //           DateTime
                                                                  //               d) =>
                                                                  //       DateTime(
                                                                  //           d.year,
                                                                  //           d.month,
                                                                  //           d.day);

                                                                  //   print(
                                                                  //       'Date: $date');
                                                                  //   print(
                                                                  //       'Start of week: ${getDate(date.subtract(Duration(days: date.weekday - 1)))}');
                                                                  //   print(
                                                                  //       'End of week: ${getDate(date.add(Duration(days: DateTime.daysPerWeek - date.weekday)))}');
                                                                  //   startDate = getDate(date.subtract(Duration(
                                                                  //       days: date.weekday -
                                                                  //           1)));
                                                                  //   endDate = getDate(date.add(Duration(
                                                                  //       days: DateTime.daysPerWeek -
                                                                  //           date.weekday)));
                                                                  //   print(
                                                                  //       'startDate ${startDate}');
                                                                  //   print(
                                                                  //       'endDate ${endDate}');
                                                                  //   await getStock(
                                                                  //       startDate,
                                                                  //       endDate,
                                                                  //       medList[index]['itemName']
                                                                  //           .toString(),
                                                                  //       medList[index]
                                                                  //           [
                                                                  //           'itemId']);
                                                                  // }
                                                                  // if (daily) {
                                                                  //   print(
                                                                  //       'day');
                                                                  //   selectedDateTime =
                                                                  //       DateTime
                                                                  //           .now();
                                                                  //   var now =
                                                                  //       new DateTime
                                                                  //           .now();
                                                                  //   var formatter =
                                                                  //       new DateFormat(
                                                                  //           'd MMM');

                                                                  //   final date =
                                                                  //       DateTime
                                                                  //           .now();
                                                                  //   DateTime getDate(
                                                                  //           DateTime
                                                                  //               d) =>
                                                                  //       DateTime(
                                                                  //           d.year,
                                                                  //           d.month,
                                                                  //           d.day);

                                                                  //   print(
                                                                  //       'Date: $date');
                                                                  //   print(
                                                                  //       'Start of week: ${getDate(date.subtract(Duration(days: date.weekday - 1)))}');
                                                                  //   print(
                                                                  //       'End of week: ${getDate(date.add(Duration(days: DateTime.daysPerWeek - date.weekday)))}');
                                                                  //   startDate = getDate(date.subtract(Duration(
                                                                  //       days: date.weekday -
                                                                  //           1)));
                                                                  //   endDate = getDate(date.add(Duration(
                                                                  //       days: DateTime.daysPerWeek -
                                                                  //           date.weekday)));
                                                                  //   print(
                                                                  //       'startDate ${startDate}');
                                                                  //   print(
                                                                  //       'endDate ${endDate}');

                                                                  //   getStock(
                                                                  //       startDate,
                                                                  //       endDate,
                                                                  //       medList[index]['itemName']
                                                                  //           .toString(),
                                                                  //       medList[index]
                                                                  //           [
                                                                  //           'itemId']);
                                                                  // }
                                                                  // if (yearly) {
                                                                  //   dataMonth =
                                                                  //       [];
                                                                  //   var now =
                                                                  //       new DateTime
                                                                  //           .now();
                                                                  //   var formatter =
                                                                  //       new DateFormat(
                                                                  //           'd MMM');

                                                                  //   final date =
                                                                  //       DateTime
                                                                  //           .now();
                                                                  //   DateTime getDate(
                                                                  //           DateTime
                                                                  //               d) =>
                                                                  //       DateTime(
                                                                  //           d.year,
                                                                  //           d.month,
                                                                  //           d.day);

                                                                  //   print(
                                                                  //       'Date: $date');
                                                                  //   print(
                                                                  //       'Start of week: ${getDate(date.subtract(Duration(days: date.weekday - 1)))}');
                                                                  //   print(
                                                                  //       'End of week: ${getDate(date.add(Duration(days: DateTime.daysPerWeek - date.weekday)))}');
                                                                  //   startDate =
                                                                  //       getDate(
                                                                  //           DateTime.parse("${date.year}-01-01"));
                                                                  //   endDate = getDate(
                                                                  //       DateTime.parse(
                                                                  //           "${date.year}-12-31"));
                                                                  //   print(
                                                                  //       'startDate ${startDate}');
                                                                  //   print(
                                                                  //       'endDate ${endDate}');
                                                                  //   getStock(
                                                                  //       startDate,
                                                                  //       endDate,
                                                                  //       medList[index]['itemName']
                                                                  //           .toString(),
                                                                  //       medList[index]
                                                                  //           [
                                                                  //           'itemId']);
                                                                  // }
                                                                  // if (monthly) {
                                                                  //   var now =
                                                                  //       new DateTime
                                                                  //           .now();
                                                                  //   var formatter =
                                                                  //       new DateFormat(
                                                                  //           'd MMM');

                                                                  //   final date =
                                                                  //       DateTime
                                                                  //           .now();
                                                                  //   DateTime getDate(
                                                                  //           DateTime
                                                                  //               d) =>
                                                                  //       DateTime(
                                                                  //           d.year,
                                                                  //           d.month,
                                                                  //           d.day);

                                                                  //   print(
                                                                  //       'Date: $date');
                                                                  //   print(
                                                                  //       'Start of week: ${getDate(date.subtract(Duration(days: date.weekday - 1)))}');
                                                                  //   print(
                                                                  //       'End of week: ${getDate(date.add(Duration(days: DateTime.daysPerWeek - date.weekday)))}');

                                                                  //   var beginningNextMonth = (now.month <
                                                                  //           12)
                                                                  //       ? new DateTime(
                                                                  //           now
                                                                  //               .year,
                                                                  //           now.month +
                                                                  //               1,
                                                                  //           1)
                                                                  //       : new DateTime(
                                                                  //           now.year +
                                                                  //               1,
                                                                  //           1,
                                                                  //           1);
                                                                  //   var lastDay = beginningNextMonth
                                                                  //       .subtract(new Duration(
                                                                  //           days:
                                                                  //               1))
                                                                  //       .day;

                                                                  //   startDate =
                                                                  //       getDate(
                                                                  //           DateTime.parse("${date.year}-${date.month}-01"));
                                                                  //   endDate = getDate(
                                                                  //       DateTime.parse(
                                                                  //           "${date.year}-${date.month}-${lastDay}"));
                                                                  //   highSale =
                                                                  //       100;
                                                                  //   print(
                                                                  //       'startDate ${startDate}');
                                                                  //   print(
                                                                  //       'endDate ${endDate}');
                                                                  //   getStock(
                                                                  //       startDate,
                                                                  //       endDate,
                                                                  //       medList[index]['itemName']
                                                                  //           .toString(),
                                                                  //       medList[index]
                                                                  //           [
                                                                  //           'itemId']);
                                                                  // }
                                                                },
                                                                // onTap: widget.onPressed,
                                                                child: Stack(
                                                                    children: [
                                                                      Container(
                                                                        width: double
                                                                            .infinity,
                                                                        padding:
                                                                            EdgeInsets.all(15.0),
                                                                        margin: EdgeInsets.only(
                                                                            bottom:
                                                                                15.0),
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          borderRadius:
                                                                              BorderRadius.circular(12.0),
                                                                          border:
                                                                              Border.all(
                                                                            color:
                                                                                kPrimaryColor,
                                                                            width:
                                                                                1.0,
                                                                          ),
                                                                        ),
                                                                        child:
                                                                            Column(
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.start,
                                                                          children: [
                                                                            RichText(
                                                                              text: new TextSpan(
                                                                                // Note: Styles for TextSpans must be explicitly defined.
                                                                                // Child text spans will inherit styles from parent
                                                                                style: new TextStyle(
                                                                                  fontSize: 14.0,
                                                                                  color: Colors.black,
                                                                                ),
                                                                                children: <TextSpan>[
                                                                                  new TextSpan(text: 'Item Name : ', style: new TextStyle(fontSize: 11, fontFamily: 'PoppinsBold')),
                                                                                  new TextSpan(text: stockData[index]['itemName'], style: TextStyle(fontSize: 11, fontFamily: 'PoppinsMedium', color: textGreyColor)),
                                                                                ],
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    ]),
                                                              ),
                                                            ),
                                                          )
                                                        : Container();
                                                  },
                                                ),
                                              )
                                            ],
                                          ),
                                        );
                                      });
                                    });
                              },
                              child: Icon(
                                Icons.search_outlined,
                                color: kPrimaryColor,
                                size: 25,
                              ),
                            ),
                          ),
                        ),
                        labelText: "Search",
                        labelStyle: TextStyle(
                            color: textGreyColor, fontFamily: 'PoppinsRegular'),
                        filled: true,
                        fillColor: Colors.white,
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: kPrimaryColor, width: 1.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Color(0xffE6E6E6), width: 1.0),
                        ),

                        border: new OutlineInputBorder(
                          borderSide: new BorderSide(color: Color(0xffE6E6E6)),
                        ),
                        //fillColor: Colors.green
                      ),
                      keyboardType: TextInputType.emailAddress,
                      style: new TextStyle(
                          fontFamily: "PoppinsRegular", color: kPrimaryColor),
                    ),
                  )
                : Container(),

            SizedBox(
              height: stock ? 10 : 0,
            ),

            stock
                ? Container(
                    decoration: BoxDecoration(
                        color: Color(0xfffECF0F1),
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                    width: width * 0.9,
                    child: Padding(
                      padding: const EdgeInsets.only(
                          right: 10, left: 10, top: 7, bottom: 7),
                      child: Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: width * 0.4,
                                    child: Text('Item Name   ',
                                        textAlign: TextAlign.left,
                                        style: new TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        )),
                                  ),
                                ],
                              ),
                              Container(
                                width: width * 0.1,
                                child: Text(" OP",
                                    textAlign: TextAlign.right,
                                    style: new TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    )),
                              ),
                              Container(
                                width: width * 0.1,
                                child: Text(" IN",
                                    textAlign: TextAlign.right,
                                    style: new TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    )),
                              ),
                              Container(
                                width: width * 0.1,
                                child: Text(" OUT",
                                    textAlign: TextAlign.right,
                                    style: new TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    )),
                              ),
                              Container(
                                width: width * 0.1,
                                child: Text(' BL',
                                    textAlign: TextAlign.right,
                                    style: new TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    )),
                              ),

                              // Icon(
                              //   Icons.keyboard_arrow_right_sharp,
                              //   size: 40.0,
                              //   color: textGreyColor,
                              // ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  )
                : Container(),

            SizedBox(
              height: stock ? 10 : 0,
            ),
            stock
                ? Container(
                    decoration: BoxDecoration(
                        color: Color(0xfffECF0F1),
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                    width: width * 0.9,
                    child: ListView.builder(
                      itemCount: stockData.length,
                      shrinkWrap: true,
                      scrollDirection: Axis.vertical,
                      physics: ScrollPhysics(),
                      itemBuilder: (context, index) {
                        var remaining = stockData[index]['itemIN'] -
                            stockData[index]['itemOut'];

                        TotalIn = TotalIn + stockData[index]['itemIN'];
                        TotalOut = TotalOut + stockData[index]['itemOut'];

                        TotalRemaining = remaining;

                        return stockData[index]['itemName']
                                    .toString()
                                    .toLowerCase()
                                    .contains(searchString.toLowerCase()) ||
                                stockData[index]['itemName']
                                    .toString()
                                    .toUpperCase()
                                    .contains(searchString.toUpperCase())
                            ? GestureDetector(
                                onTap: () {
                                  print('open hseet');
                                  showModalBottomSheet(
                                      context: context,
                                      builder: (builder) {
                                        return new Container(
                                          height: 200.0,
                                          color: Colors
                                              .transparent, //could change this to Color(0xFF737373),
                                          //so you don't have to change MaterialApp canvasColor
                                          child: new Container(
                                              decoration: new BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      new BorderRadius.only(
                                                          topLeft: const Radius
                                                              .circular(10.0),
                                                          topRight: const Radius
                                                              .circular(10.0))),
                                              child: Column(
                                                children: [
                                                  Container(
                                                    color: Color(0xfff5f6fb),
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: Center(
                                                          child: Text(
                                                        "Item Details.",
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                            decoration:
                                                                TextDecoration
                                                                    .none,
                                                            fontFamily:
                                                                'PoppinsRegular',
                                                            fontSize: 15,
                                                            color: Color(
                                                                0xff8f9ba8)),
                                                      )),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            13.0),
                                                    child: Column(
                                                      children: [
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            RichText(
                                                              text:
                                                                  new TextSpan(
                                                                // Note: Styles for TextSpans must be explicitly defined.
                                                                // Child text spans will inherit styles from parent
                                                                style:
                                                                    new TextStyle(
                                                                  fontSize:
                                                                      14.0,
                                                                  color: Colors
                                                                      .black,
                                                                ),
                                                                children: <
                                                                    TextSpan>[
                                                                  new TextSpan(
                                                                      text:
                                                                          'Item In : ',
                                                                      style:
                                                                          new TextStyle(
                                                                        fontSize:
                                                                            15,
                                                                        fontWeight:
                                                                            FontWeight.w600,
                                                                      )),
                                                                  new TextSpan(
                                                                      text:
                                                                          '${stockData[index]['itemIN'].toString()}',
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              15,
                                                                          fontWeight: FontWeight
                                                                              .w400,
                                                                          color:
                                                                              textGreyColor)),
                                                                ],
                                                              ),
                                                            ),
                                                            RichText(
                                                              text:
                                                                  new TextSpan(
                                                                // Note: Styles for TextSpans must be explicitly defined.
                                                                // Child text spans will inherit styles from parent
                                                                style:
                                                                    new TextStyle(
                                                                  fontSize:
                                                                      14.0,
                                                                  color: Colors
                                                                      .black,
                                                                ),
                                                                children: <
                                                                    TextSpan>[
                                                                  new TextSpan(
                                                                      text:
                                                                          'Item Out : ',
                                                                      style:
                                                                          new TextStyle(
                                                                        fontSize:
                                                                            15,
                                                                        fontWeight:
                                                                            FontWeight.w600,
                                                                      )),
                                                                  new TextSpan(
                                                                      text:
                                                                          '${stockData[index]['itemOut'].toString()}',
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              15,
                                                                          fontWeight: FontWeight
                                                                              .w400,
                                                                          color:
                                                                              textGreyColor)),
                                                                ],
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            RichText(
                                                              text:
                                                                  new TextSpan(
                                                                // Note: Styles for TextSpans must be explicitly defined.
                                                                // Child text spans will inherit styles from parent
                                                                style:
                                                                    new TextStyle(
                                                                  fontSize:
                                                                      15.0,
                                                                  color: Colors
                                                                      .black,
                                                                ),
                                                                children: <
                                                                    TextSpan>[
                                                                  new TextSpan(
                                                                      text:
                                                                          'Balance: ',
                                                                      style:
                                                                          new TextStyle(
                                                                        fontSize:
                                                                            15,
                                                                        fontWeight:
                                                                            FontWeight.w600,
                                                                      )),
                                                                  new TextSpan(
                                                                      text:
                                                                          '${stockData[index]['balance'].toString()}',
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              15,
                                                                          fontWeight: FontWeight
                                                                              .w400,
                                                                          color:
                                                                              textGreyColor)),
                                                                ],
                                                              ),
                                                            ),
                                                            RichText(
                                                              text:
                                                                  new TextSpan(
                                                                // Note: Styles for TextSpans must be explicitly defined.
                                                                // Child text spans will inherit styles from parent
                                                                style:
                                                                    new TextStyle(
                                                                  fontSize:
                                                                      14.0,
                                                                  color: Colors
                                                                      .black,
                                                                ),
                                                                children: <
                                                                    TextSpan>[
                                                                  new TextSpan(
                                                                      text:
                                                                          'Batch : ',
                                                                      style:
                                                                          new TextStyle(
                                                                        fontSize:
                                                                            15,
                                                                        fontWeight:
                                                                            FontWeight.w600,
                                                                      )),
                                                                  new TextSpan(
                                                                      text:
                                                                          '${stockData[index]['batchNo'].toString()}',
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              15,
                                                                          fontWeight: FontWeight
                                                                              .w400,
                                                                          color:
                                                                              textGreyColor)),
                                                                ],
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            RichText(
                                                              text:
                                                                  new TextSpan(
                                                                // Note: Styles for TextSpans must be explicitly defined.
                                                                // Child text spans will inherit styles from parent
                                                                style:
                                                                    new TextStyle(
                                                                  fontSize:
                                                                      14.0,
                                                                  color: Colors
                                                                      .black,
                                                                ),
                                                                children: <
                                                                    TextSpan>[
                                                                  new TextSpan(
                                                                      text:
                                                                          'Item Code: ',
                                                                      style:
                                                                          new TextStyle(
                                                                        fontSize:
                                                                            15,
                                                                        fontWeight:
                                                                            FontWeight.w600,
                                                                      )),
                                                                  new TextSpan(
                                                                      text:
                                                                          '${stockData[index]['itemCode'].toString()}',
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              15,
                                                                          fontWeight: FontWeight
                                                                              .w400,
                                                                          color:
                                                                              textGreyColor)),
                                                                ],
                                                              ),
                                                            ),
                                                            RichText(
                                                              text:
                                                                  new TextSpan(
                                                                // Note: Styles for TextSpans must be explicitly defined.
                                                                // Child text spans will inherit styles from parent
                                                                style:
                                                                    new TextStyle(
                                                                  fontSize:
                                                                      14.0,
                                                                  color: Colors
                                                                      .black,
                                                                ),
                                                                children: <
                                                                    TextSpan>[
                                                                  new TextSpan(
                                                                      text:
                                                                          'Exp Date : ',
                                                                      style:
                                                                          new TextStyle(
                                                                        fontSize:
                                                                            15,
                                                                        fontWeight:
                                                                            FontWeight.w600,
                                                                      )),
                                                                  new TextSpan(
                                                                      text:
                                                                          '${stockData[index]['expiryDate'].toString()}',
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              15,
                                                                          fontWeight: FontWeight
                                                                              .w400,
                                                                          color:
                                                                              textGreyColor)),
                                                                ],
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            RichText(
                                                              text:
                                                                  new TextSpan(
                                                                // Note: Styles for TextSpans must be explicitly defined.
                                                                // Child text spans will inherit styles from parent
                                                                style:
                                                                    new TextStyle(
                                                                  fontSize:
                                                                      14.0,
                                                                  color: Colors
                                                                      .black,
                                                                ),
                                                                children: <
                                                                    TextSpan>[
                                                                  new TextSpan(
                                                                      text:
                                                                          'Item Name : ',
                                                                      style:
                                                                          new TextStyle(
                                                                        fontSize:
                                                                            15,
                                                                        fontWeight:
                                                                            FontWeight.w600,
                                                                      )),
                                                                  new TextSpan(
                                                                      text:
                                                                          '${stockData[index]['itemName'].toString()}',
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              15,
                                                                          fontWeight: FontWeight
                                                                              .w400,
                                                                          color:
                                                                              textGreyColor)),
                                                                ],
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  )
                                                ],
                                              )),
                                        );
                                      });
                                },
                                child: Container(
                                  width: width * 0.9,
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        right: 10, left: 10, top: 10),
                                    child: Column(
                                      children: [
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                  width: width * 0.4,
                                                  child: Text(
                                                      stockData[index]
                                                              ['itemName']
                                                          .toString(),
                                                      textAlign: TextAlign.left,
                                                      style: new TextStyle(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                      )),
                                                ),
                                              ],
                                            ),
                                             Container(
                                              width: width * 0.1,
                                              child: Text(
                                                  stockData[index]['openingQty'] !=
                                                          null
                                                      ? stockData[index]
                                                              ['openingQty']
                                                          .toStringAsFixed(0)
                                                      : "",
                                                  textAlign: TextAlign.right,
                                                  style: new TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w400,
                                                  )),
                                            ),
                                           
                                            Container(
                                              width: width * 0.1,
                                              child: Text(
                                                  stockData[index]['itemIN'] !=
                                                          null
                                                      ? stockData[index]
                                                              ['itemIN']
                                                          .toStringAsFixed(0)
                                                      : "",
                                                  textAlign: TextAlign.right,
                                                  style: new TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w400,
                                                  )),
                                            ),
                                           
                                            Container(
                                              width: width * 0.1,
                                              child: Text(
                                                  stockData[index]['itemOut'] !=
                                                          null
                                                      ? stockData[index]
                                                              ['itemOut']
                                                          .toStringAsFixed(0)
                                                      : "",
                                                  textAlign: TextAlign.right,
                                                  style: new TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w400,
                                                  )),
                                            ),
                                            Container(
                                              width: width * 0.1,
                                              child: Text(
                                                  stockData[index]['balance']
                                                      .toStringAsFixed(0),
                                                  textAlign: TextAlign.right,
                                                  style: new TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w400,
                                                  )),
                                            ),

                                            // Icon(
                                            //   Icons.keyboard_arrow_right_sharp,
                                            //   size: 40.0,
                                            //   color: textGreyColor,
                                            // ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              )
                            : Container();

                        //   return Padding(
                        // padding: EdgeInsets.only(top: 13),
                        //     child: Container(
                        //         width: width * 0.8,
                        //         decoration: BoxDecoration(
                        //           color: Color(0xffDCEEFC),
                        //           borderRadius: BorderRadius.circular(10),
                        //         ),
                        //         child: Padding(
                        //           padding: const EdgeInsets.all(13.0),
                        //           child: Column(
                        //             children: [
                        //               Text(productShow[index]['qty'].toString(),
                        //                   style: new TextStyle(
                        //                       fontSize: 19,
                        //                       fontWeight: FontWeight.w700,
                        //                       color: Color(0xff2D587B))),
                        //               Text(productShow[index]['itemName'].toString(),
                        //                   textAlign: TextAlign.center,
                        //                   style: new TextStyle(
                        //                       fontSize: 18,
                        //                       fontWeight: FontWeight.w400,
                        //                       color: Color(0xff2D587B)))
                        //             ],
                        //           ),
                        //         ),
                        //       ),
                        //   )
                        //  ;
                      },
                    ),
                  )
                : Container(),

            expiry
                ? Container(
                    width: width * 0.9,
                    child: TextFormField(
                      controller: searchExpiryController,
                      onChanged: (value) {
                        setState(() {
                          searchExpiryString = value;
                        });
                      },
                      decoration: new InputDecoration(
                        suffixIcon: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8.0),
                              color: Color(0xffcde0e7), // Button color
                            ),
                            child: InkWell(
                              splashColor: Colors.red, // Splash color
                              onTap: () {
                                showModalBottomSheet(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.only(
                                          topLeft: const Radius.circular(20.0),
                                          topRight:
                                              const Radius.circular(20.0)),
                                    ),
                                    isScrollControlled: true,
                                    context: context,
                                    builder: (context) {
                                      String searchString2 = "";
                                      return StatefulBuilder(builder:
                                          (BuildContext context,
                                              StateSetter setStatee) {
                                        return Container(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.8,
                                          child: Column(
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 8),
                                                child: Container(
                                                  width: 40,
                                                  height: 8,
                                                  decoration: new BoxDecoration(
                                                      color: kPrimaryColor,
                                                      borderRadius:
                                                          new BorderRadius.all(
                                                              Radius.circular(
                                                                  10.0))),
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(13.0),
                                                child: Container(
                                                  width: double.infinity,
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      RichText(
                                                        text: new TextSpan(
                                                          // Note: Styles for TextSpans must be explicitly defined.
                                                          // Child text spans will inherit styles from parent
                                                          style: new TextStyle(
                                                            fontSize: 16.0,
                                                            color: Colors.black,
                                                          ),
                                                          children: <TextSpan>[
                                                            new TextSpan(
                                                                text: 'Select ',
                                                                style: new TextStyle(
                                                                    fontSize:
                                                                        17,
                                                                    fontFamily:
                                                                        'PoppinsMedium')),
                                                            new TextSpan(
                                                                text: 'Item',
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        17,
                                                                    fontFamily:
                                                                        'PoppinsRegular',
                                                                    color:
                                                                        textGreyColor)),
                                                          ],
                                                        ),
                                                      ),
                                                      GestureDetector(
                                                          onTap: () {
                                                            Navigator.pop(
                                                                context);
                                                          },
                                                          child: Icon(
                                                            Icons
                                                                .close_outlined,
                                                            color:
                                                                kPrimaryColor,
                                                          ))
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(13),
                                                child: Container(
                                                  child: TextFormField(
                                                    onChanged: (value) {
                                                      print(value);
                                                      setStatee(() {
                                                        searchString2 = value;
                                                      });
                                                    },
                                                    decoration:
                                                        new InputDecoration(
                                                      labelText: "Search",
                                                      labelStyle: TextStyle(
                                                          color: textGreyColor,
                                                          fontFamily:
                                                              'SegoeUI'),
                                                      filled: true,
                                                      fillColor: Colors.white,
                                                      focusedBorder:
                                                          OutlineInputBorder(
                                                        borderRadius:
                                                            new BorderRadius
                                                                .circular(10),
                                                        borderSide: BorderSide(
                                                            color:
                                                                kPrimaryColor,
                                                            width: 1.0),
                                                      ),
                                                      enabledBorder:
                                                          OutlineInputBorder(
                                                        borderRadius:
                                                            new BorderRadius
                                                                .circular(10),
                                                        borderSide: BorderSide(
                                                            color: Color(
                                                                0xffE6E6E6),
                                                            width: 1.0),
                                                      ),

                                                      border:
                                                          new OutlineInputBorder(
                                                        borderRadius:
                                                            new BorderRadius
                                                                .circular(10),
                                                        borderSide:
                                                            new BorderSide(
                                                                color: Color(
                                                                    0xffE6E6E6)),
                                                      ),
                                                      //fillColor: Colors.green
                                                    ),
                                                    keyboardType: TextInputType
                                                        .emailAddress,
                                                    style: new TextStyle(
                                                        fontFamily: "SegoeUI",
                                                        color: kPrimaryColor),
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                child: new ListView.builder(
                                                  itemCount: expiryData.length,
                                                  shrinkWrap: true,
                                                  scrollDirection:
                                                      Axis.vertical,
                                                  physics: ScrollPhysics(),
                                                  itemBuilder:
                                                      (context, index) {
                                                    return expiryData[index]
                                                                ['itemName']
                                                            .toString()
                                                            .toLowerCase()
                                                            .contains(searchString2
                                                                .toLowerCase())
                                                        ? Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                        .only(
                                                                    bottom: 10,
                                                                    left: 15,
                                                                    right: 15),
                                                            child: Container(
                                                              child:
                                                                  GestureDetector(
                                                                onTap:
                                                                    () async {
                                                                  setState(() {
                                                                    searchExpiryController
                                                                        .text = expiryData[index]
                                                                            [
                                                                            'itemName']
                                                                        .toString();
                                                                    searchExpiryString =
                                                                        expiryData[index]['itemName']
                                                                            .toString();
                                                                  });
                                                                  print(
                                                                      searchString);
                                                                  print(
                                                                      searchController
                                                                          .text);
                                                                  Navigator.pop(
                                                                      context);

                                                                  // if (weekly) {
                                                                  //   print(
                                                                  //       'week');
                                                                  //   selectedDateTime =
                                                                  //       DateTime
                                                                  //           .now();
                                                                  //   data = [];
                                                                  //   var now =
                                                                  //       new DateTime
                                                                  //           .now();
                                                                  //   var formatter =
                                                                  //       new DateFormat(
                                                                  //           'd MMM');

                                                                  //   final date =
                                                                  //       DateTime
                                                                  //           .now();
                                                                  //   DateTime getDate(
                                                                  //           DateTime
                                                                  //               d) =>
                                                                  //       DateTime(
                                                                  //           d.year,
                                                                  //           d.month,
                                                                  //           d.day);

                                                                  //   print(
                                                                  //       'Date: $date');
                                                                  //   print(
                                                                  //       'Start of week: ${getDate(date.subtract(Duration(days: date.weekday - 1)))}');
                                                                  //   print(
                                                                  //       'End of week: ${getDate(date.add(Duration(days: DateTime.daysPerWeek - date.weekday)))}');
                                                                  //   startDate = getDate(date.subtract(Duration(
                                                                  //       days: date.weekday -
                                                                  //           1)));
                                                                  //   endDate = getDate(date.add(Duration(
                                                                  //       days: DateTime.daysPerWeek -
                                                                  //           date.weekday)));
                                                                  //   print(
                                                                  //       'startDate ${startDate}');
                                                                  //   print(
                                                                  //       'endDate ${endDate}');
                                                                  //   await getStock(
                                                                  //       startDate,
                                                                  //       endDate,
                                                                  //       medList[index]['itemName']
                                                                  //           .toString(),
                                                                  //       medList[index]
                                                                  //           [
                                                                  //           'itemId']);
                                                                  // }
                                                                  // if (daily) {
                                                                  //   print(
                                                                  //       'day');
                                                                  //   selectedDateTime =
                                                                  //       DateTime
                                                                  //           .now();
                                                                  //   var now =
                                                                  //       new DateTime
                                                                  //           .now();
                                                                  //   var formatter =
                                                                  //       new DateFormat(
                                                                  //           'd MMM');

                                                                  //   final date =
                                                                  //       DateTime
                                                                  //           .now();
                                                                  //   DateTime getDate(
                                                                  //           DateTime
                                                                  //               d) =>
                                                                  //       DateTime(
                                                                  //           d.year,
                                                                  //           d.month,
                                                                  //           d.day);

                                                                  //   print(
                                                                  //       'Date: $date');
                                                                  //   print(
                                                                  //       'Start of week: ${getDate(date.subtract(Duration(days: date.weekday - 1)))}');
                                                                  //   print(
                                                                  //       'End of week: ${getDate(date.add(Duration(days: DateTime.daysPerWeek - date.weekday)))}');
                                                                  //   startDate = getDate(date.subtract(Duration(
                                                                  //       days: date.weekday -
                                                                  //           1)));
                                                                  //   endDate = getDate(date.add(Duration(
                                                                  //       days: DateTime.daysPerWeek -
                                                                  //           date.weekday)));
                                                                  //   print(
                                                                  //       'startDate ${startDate}');
                                                                  //   print(
                                                                  //       'endDate ${endDate}');

                                                                  //   getStock(
                                                                  //       startDate,
                                                                  //       endDate,
                                                                  //       medList[index]['itemName']
                                                                  //           .toString(),
                                                                  //       medList[index]
                                                                  //           [
                                                                  //           'itemId']);
                                                                  // }
                                                                  // if (yearly) {
                                                                  //   dataMonth =
                                                                  //       [];
                                                                  //   var now =
                                                                  //       new DateTime
                                                                  //           .now();
                                                                  //   var formatter =
                                                                  //       new DateFormat(
                                                                  //           'd MMM');

                                                                  //   final date =
                                                                  //       DateTime
                                                                  //           .now();
                                                                  //   DateTime getDate(
                                                                  //           DateTime
                                                                  //               d) =>
                                                                  //       DateTime(
                                                                  //           d.year,
                                                                  //           d.month,
                                                                  //           d.day);

                                                                  //   print(
                                                                  //       'Date: $date');
                                                                  //   print(
                                                                  //       'Start of week: ${getDate(date.subtract(Duration(days: date.weekday - 1)))}');
                                                                  //   print(
                                                                  //       'End of week: ${getDate(date.add(Duration(days: DateTime.daysPerWeek - date.weekday)))}');
                                                                  //   startDate =
                                                                  //       getDate(
                                                                  //           DateTime.parse("${date.year}-01-01"));
                                                                  //   endDate = getDate(
                                                                  //       DateTime.parse(
                                                                  //           "${date.year}-12-31"));
                                                                  //   print(
                                                                  //       'startDate ${startDate}');
                                                                  //   print(
                                                                  //       'endDate ${endDate}');
                                                                  //   getStock(
                                                                  //       startDate,
                                                                  //       endDate,
                                                                  //       medList[index]['itemName']
                                                                  //           .toString(),
                                                                  //       medList[index]
                                                                  //           [
                                                                  //           'itemId']);
                                                                  // }
                                                                  // if (monthly) {
                                                                  //   var now =
                                                                  //       new DateTime
                                                                  //           .now();
                                                                  //   var formatter =
                                                                  //       new DateFormat(
                                                                  //           'd MMM');

                                                                  //   final date =
                                                                  //       DateTime
                                                                  //           .now();
                                                                  //   DateTime getDate(
                                                                  //           DateTime
                                                                  //               d) =>
                                                                  //       DateTime(
                                                                  //           d.year,
                                                                  //           d.month,
                                                                  //           d.day);

                                                                  //   print(
                                                                  //       'Date: $date');
                                                                  //   print(
                                                                  //       'Start of week: ${getDate(date.subtract(Duration(days: date.weekday - 1)))}');
                                                                  //   print(
                                                                  //       'End of week: ${getDate(date.add(Duration(days: DateTime.daysPerWeek - date.weekday)))}');

                                                                  //   var beginningNextMonth = (now.month <
                                                                  //           12)
                                                                  //       ? new DateTime(
                                                                  //           now
                                                                  //               .year,
                                                                  //           now.month +
                                                                  //               1,
                                                                  //           1)
                                                                  //       : new DateTime(
                                                                  //           now.year +
                                                                  //               1,
                                                                  //           1,
                                                                  //           1);
                                                                  //   var lastDay = beginningNextMonth
                                                                  //       .subtract(new Duration(
                                                                  //           days:
                                                                  //               1))
                                                                  //       .day;

                                                                  //   startDate =
                                                                  //       getDate(
                                                                  //           DateTime.parse("${date.year}-${date.month}-01"));
                                                                  //   endDate = getDate(
                                                                  //       DateTime.parse(
                                                                  //           "${date.year}-${date.month}-${lastDay}"));
                                                                  //   highSale =
                                                                  //       100;
                                                                  //   print(
                                                                  //       'startDate ${startDate}');
                                                                  //   print(
                                                                  //       'endDate ${endDate}');
                                                                  //   getStock(
                                                                  //       startDate,
                                                                  //       endDate,
                                                                  //       medList[index]['itemName']
                                                                  //           .toString(),
                                                                  //       medList[index]
                                                                  //           [
                                                                  //           'itemId']);
                                                                  // }
                                                                },
                                                                // onTap: widget.onPressed,
                                                                child: Stack(
                                                                    children: [
                                                                      Container(
                                                                        width: double
                                                                            .infinity,
                                                                        padding:
                                                                            EdgeInsets.all(15.0),
                                                                        margin: EdgeInsets.only(
                                                                            bottom:
                                                                                15.0),
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          borderRadius:
                                                                              BorderRadius.circular(12.0),
                                                                          border:
                                                                              Border.all(
                                                                            color:
                                                                                kPrimaryColor,
                                                                            width:
                                                                                1.0,
                                                                          ),
                                                                        ),
                                                                        child:
                                                                            Column(
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.start,
                                                                          children: [
                                                                            RichText(
                                                                              text: new TextSpan(
                                                                                // Note: Styles for TextSpans must be explicitly defined.
                                                                                // Child text spans will inherit styles from parent
                                                                                style: new TextStyle(
                                                                                  fontSize: 14.0,
                                                                                  color: Colors.black,
                                                                                ),
                                                                                children: <TextSpan>[
                                                                                  new TextSpan(text: 'Item Name : ', style: new TextStyle(fontSize: 11, fontFamily: 'PoppinsBold')),
                                                                                  new TextSpan(text: expiryData[index]['itemName'], style: TextStyle(fontSize: 11, fontFamily: 'PoppinsMedium', color: textGreyColor)),
                                                                                ],
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    ]),
                                                              ),
                                                            ),
                                                          )
                                                        : Container();
                                                  },
                                                ),
                                              )
                                            ],
                                          ),
                                        );
                                      });
                                    });
                              },
                              child: Icon(
                                Icons.search_outlined,
                                color: kPrimaryColor,
                                size: 25,
                              ),
                            ),
                          ),
                        ),
                        labelText: "Search",
                        labelStyle: TextStyle(
                            color: textGreyColor, fontFamily: 'PoppinsRegular'),
                        filled: true,
                        fillColor: Colors.white,
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: kPrimaryColor, width: 1.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Color(0xffE6E6E6), width: 1.0),
                        ),

                        border: new OutlineInputBorder(
                          borderSide: new BorderSide(color: Color(0xffE6E6E6)),
                        ),
                        //fillColor: Colors.green
                      ),
                      keyboardType: TextInputType.emailAddress,
                      style: new TextStyle(
                          fontFamily: "PoppinsRegular", color: kPrimaryColor),
                    ),
                  )
                : Container(),

            SizedBox(
              height: expiry ? 10 : 0,
            ),

            expiry
                ? Container(
                    decoration: BoxDecoration(
                        color: Color(0xfffECF0F1),
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                    width: width * 0.9,
                    child: Padding(
                      padding: const EdgeInsets.only(
                          right: 10, left: 10, top: 7, bottom: 7),
                      child: Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: width * 0.6,
                                    child: Text('   Item Name   ',
                                        textAlign: TextAlign.left,
                                        style: new TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        )),
                                  ),
                                ],
                              ),
                              Container(
                                width: width * 0.25,
                                child: Text(" Batch",
                                    textAlign: TextAlign.right,
                                    style: new TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    )),
                              ),

                              // Icon(
                              //   Icons.keyboard_arrow_right_sharp,
                              //   size: 40.0,
                              //   color: textGreyColor,
                              // ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  )
                : Container(),

            SizedBox(
              height: 10,
            ),
            expiry
                ? Container(
                    decoration: BoxDecoration(
                        color: Color(0xfffECF0F1),
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                    width: width * 0.9,
                    child: ListView.builder(
                      itemCount: expiryData.length,
                      shrinkWrap: true,
                      scrollDirection: Axis.vertical,
                      physics: ScrollPhysics(),
                      itemBuilder: (context, index) {
                        return expiryData[index]['itemName']
                                    .toString()
                                    .toLowerCase()
                                    .contains(
                                        searchExpiryString.toLowerCase()) ||
                                expiryData[index]['itemName']
                                    .toString()
                                    .toUpperCase()
                                    .contains(searchExpiryString.toUpperCase())
                            ? GestureDetector(
                                child: Container(
                                  width: width * 0.9,
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        right: 10, left: 10, top: 10),
                                    child: Column(
                                      children: [
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                  width: width * 0.6,
                                                  child: Text(
                                                      expiryData[index]
                                                              ['itemName']
                                                          .toString(),
                                                      textAlign: TextAlign.left,
                                                      style: new TextStyle(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                      )),
                                                ),
                                              ],
                                            ),
                                            Container(
                                              width: width * 0.25,
                                              child: Text(
                                                  expiryData[index]
                                                              ['expiryDate'] !=
                                                          null
                                                      ? expiryData[index]
                                                              ['expiryDate']
                                                          .toString()
                                                      : "",
                                                  textAlign: TextAlign.right,
                                                  style: new TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w400,
                                                  )),
                                            ),

                                            // Icon(
                                            //   Icons.keyboard_arrow_right_sharp,
                                            //   size: 40.0,
                                            //   color: textGreyColor,
                                            // ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              )
                            : Container();

                        //   return Padding(
                        // padding: EdgeInsets.only(top: 13),
                        //     child: Container(
                        //         width: width * 0.8,
                        //         decoration: BoxDecoration(
                        //           color: Color(0xffDCEEFC),
                        //           borderRadius: BorderRadius.circular(10),
                        //         ),
                        //         child: Padding(
                        //           padding: const EdgeInsets.all(13.0),
                        //           child: Column(
                        //             children: [
                        //               Text(productShow[index]['qty'].toString(),
                        //                   style: new TextStyle(
                        //                       fontSize: 19,
                        //                       fontWeight: FontWeight.w700,
                        //                       color: Color(0xff2D587B))),
                        //               Text(productShow[index]['itemName'].toString(),
                        //                   textAlign: TextAlign.center,
                        //                   style: new TextStyle(
                        //                       fontSize: 18,
                        //                       fontWeight: FontWeight.w400,
                        //                       color: Color(0xff2D587B)))
                        //             ],
                        //           ),
                        //         ),
                        //       ),
                        //   )
                        //  ;
                      },
                    ),
                  )
                : Container(),
            // SizedBox(
            //   height: MediaQuery.of(context).size.height * 0.02,
            // ),

            // Column(
            //   children: [
            //     Container(
            //       width: width * 0.9,
            //       child: Align(
            //         alignment: Alignment.topLeft,
            //         child: Text('Most Used',
            //             textAlign: TextAlign.center,
            //             style: new TextStyle(
            //               fontSize: 21,
            //               fontWeight: FontWeight.w500,
            //             )),
            //       ),
            //     ),
            //     SizedBox(
            //       height: 11,
            //     ),
            //     Container(
            //       width: width * 0.9,
            //       decoration: BoxDecoration(
            //           color: Color(0xfffECF0F1),
            //           borderRadius: BorderRadius.all(Radius.circular(10))),
            //       child: Padding(
            //         padding: const EdgeInsets.all(10.0),
            //         child: Column(
            //           children: [
            //             Row(
            //               crossAxisAlignment: CrossAxisAlignment.center,
            //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //               children: [
            //                 Column(
            //                   crossAxisAlignment: CrossAxisAlignment.start,
            //                   children: [
            //                     Text('Expense',
            //                         textAlign: TextAlign.center,
            //                         style: new TextStyle(
            //                           fontSize: 18,
            //                           fontWeight: FontWeight.w400,
            //                         )),
            //                     SizedBox(
            //                       height: 7,
            //                     ),
            //                     LinearPercentIndicator(
            //                         animationDuration: 1500,
            //                         animation: true,
            //                         width: width * 0.7,
            //                         lineHeight: 9.0,
            //                         percent: 0.5,
            //                         progressColor: kPrimaryColor,
            //                         backgroundColor: Color(0xffcde0e7))
            //                   ],
            //                 ),
            //                 Icon(
            //                   Icons.keyboard_arrow_right_sharp,
            //                   size: 40.0,
            //                   color: textGreyColor,
            //                 ),
            //               ],
            //             ),
            //             SizedBox(
            //               height: 11,
            //             ),
            //             Row(
            //               crossAxisAlignment: CrossAxisAlignment.center,
            //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //               children: [
            //                 Column(
            //                   crossAxisAlignment: CrossAxisAlignment.start,
            //                   children: [
            //                     Text('Sale',
            //                         textAlign: TextAlign.center,
            //                         style: new TextStyle(
            //                           fontSize: 18,
            //                           fontWeight: FontWeight.w400,
            //                         )),
            //                     SizedBox(
            //                       height: 7,
            //                     ),
            //                     LinearPercentIndicator(
            //                         animationDuration: 1500,
            //                         animation: true,
            //                         width: width * 0.7,
            //                         lineHeight: 9.0,
            //                         percent: 0.7,
            //                         progressColor: kPrimaryColor,
            //                         backgroundColor: Color(0xffcde0e7))
            //                   ],
            //                 ),
            //                 Icon(
            //                   Icons.keyboard_arrow_right_sharp,
            //                   size: 40.0,
            //                   color: textGreyColor,
            //                 ),
            //               ],
            //             ),
            //             SizedBox(
            //               height: 11,
            //             ),
            //             Row(
            //               crossAxisAlignment: CrossAxisAlignment.center,
            //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //               children: [
            //                 Column(
            //                   crossAxisAlignment: CrossAxisAlignment.start,
            //                   children: [
            //                     Text('Sale',
            //                         textAlign: TextAlign.center,
            //                         style: new TextStyle(
            //                           fontSize: 18,
            //                           fontWeight: FontWeight.w400,
            //                         )),
            //                     SizedBox(
            //                       height: 7,
            //                     ),
            //                     LinearPercentIndicator(
            //                         animationDuration: 1500,
            //                         animation: true,
            //                         width: width * 0.7,
            //                         lineHeight: 9.0,
            //                         percent: 0.7,
            //                         progressColor: kPrimaryColor,
            //                         backgroundColor: Color(0xffcde0e7))
            //                   ],
            //                 ),
            //                 Icon(
            //                   Icons.keyboard_arrow_right_sharp,
            //                   size: 40.0,
            //                   color: textGreyColor,
            //                 ),
            //               ],
            //             )
            //           ],
            //         ),
            //       ),
            //     )

            //   ],
            // ),

            // SizedBox(
            //   height: MediaQuery.of(context).size.height * 0.0175,
            // ),

            SizedBox(
              height: MediaQuery.of(context).size.height * 0.02,
            ),
          ],
        ),
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  void _modalBottomSheetMenu() {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    int filterRange = 0;
    showModalBottomSheet(
        context: context,
        builder: (builder) {
          return new Container(
            height: height * 0.3,
            color: Colors.transparent, //could change this to Color(0xFF737373),
            //so you don't have to change MaterialApp canvasColor
            child: new Container(
                decoration: new BoxDecoration(
                    color: Colors.white,
                    borderRadius: new BorderRadius.only(
                        topLeft: const Radius.circular(10.0),
                        topRight: const Radius.circular(10.0))),
                child: Column(
                  children: [
                    Container(
                      color: Color(0xfff5f6fb),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Center(
                            child: Text(
                          "Filter data will change automatically.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              decoration: TextDecoration.none,
                              fontFamily: 'PoppinsRegular',
                              fontSize: 15,
                              color: Color(0xff8f9ba8)),
                        )),
                      ),
                    ),
                    Align(
                      alignment: Alignment.topLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 13, top: 13),
                        child: RichText(
                          text: new TextSpan(
                            // Note: Styles for TextSpans must be explicitly defined.
                            // Child text spans will inherit styles from parent
                            style: new TextStyle(
                              fontSize: 16.0,
                              color: Colors.black,
                            ),
                            children: <TextSpan>[
                              new TextSpan(
                                  text: 'Select ',
                                  style: new TextStyle(
                                      fontSize: 18,
                                      fontFamily: 'PoppinsMedium')),
                              new TextSpan(
                                  text: 'Date Range',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontFamily: 'PoppinsRegular',
                                      color: Color(0xff626567))),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Row(children: [
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              filterRange = 0;
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(left: 12),
                            child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12.0),
                                  border: Border.all(
                                    color: filterRange == 0
                                        ? kPrimaryColor
                                        : Colors.grey,
                                    width: filterRange == 0 ? 2.0 : 1.0,
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Center(
                                    child: Text('Day',
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                          fontFamily: 'PoppinsRegular',
                                          color: kPrimaryColor,
                                        )),
                                  ),
                                )),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              filterRange = 1;
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(left: 12),
                            child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12.0),
                                  border: Border.all(
                                    color: filterRange == 1
                                        ? kPrimaryColor
                                        : Colors.grey,
                                    width: filterRange == 1 ? 2.0 : 1.0,
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Center(
                                    child: Text('Month',
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                          fontFamily: 'PoppinsRegular',
                                          color: kPrimaryColor,
                                        )),
                                  ),
                                )),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              filterRange = 2;
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(left: 12),
                            child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12.0),
                                  border: Border.all(
                                    color: filterRange == 2
                                        ? kPrimaryColor
                                        : Colors.grey,
                                    width: filterRange == 2 ? 2.0 : 1.0,
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Center(
                                    child: Text('Year',
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                          fontFamily: 'PoppinsRegular',
                                          color: kPrimaryColor,
                                        )),
                                  ),
                                )),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              filterRange = 4;
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(left: 12),
                            child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12.0),
                                  border: Border.all(
                                    color: filterRange == 4
                                        ? kPrimaryColor
                                        : Colors.grey,
                                    width: filterRange == 4 ? 2.0 : 1.0,
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Center(
                                    child: Text('Week',
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                          fontFamily: 'PoppinsRegular',
                                          color: kPrimaryColor,
                                        )),
                                  ),
                                )),
                          ),
                        ),
                      ]),
                    ),
                    Align(
                      alignment: Alignment.topLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 13, top: 13),
                        child: RichText(
                          text: new TextSpan(
                            // Note: Styles for TextSpans must be explicitly defined.
                            // Child text spans will inherit styles from parent
                            style: new TextStyle(
                              fontSize: 16.0,
                              color: Colors.black,
                            ),
                            children: <TextSpan>[
                              new TextSpan(
                                  text: 'Select ',
                                  style: new TextStyle(
                                      fontSize: 18,
                                      fontFamily: 'PoppinsMedium')),
                              new TextSpan(
                                  text: 'Location',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontFamily: 'PoppinsRegular',
                                      color: Color(0xff626567))),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Container(
                        width: width * 0.9,
                        child: DropdownButtonFormField(
                          hint: Text(
                              'Select Location'), // Not necessary for Option 1

                          items: [
                            {'value': '1', 'label': 'Location 1'}
                          ].map((category) {
                            return new DropdownMenuItem(
                                value: category['value'],
                                child: Text(
                                  category['label'].toString(),
                                  style: TextStyle(
                                      fontSize: 14,
                                      color: textGreyColor,
                                      fontFamily: 'SegoeUI'),
                                ));
                          }).toList(),
                          onChanged: (newValue) {},
                          decoration: new InputDecoration(
                            isDense: true,
                            border: new OutlineInputBorder(
                              borderSide:
                                  const BorderSide(color: Color(0xffE6E6E6)),
                              borderRadius: const BorderRadius.all(
                                const Radius.circular(5.0),
                              ),
                            ),
                            enabledBorder: new OutlineInputBorder(
                              borderSide:
                                  const BorderSide(color: Color(0xffE6E6E6)),
                              borderRadius: const BorderRadius.all(
                                const Radius.circular(5.0),
                              ),
                            ),
                            filled: true,
                            hintStyle: new TextStyle(
                                color: textGreyColor, fontFamily: 'SegoeUI'),
                            fillColor: Colors.white70,
                            focusedBorder: OutlineInputBorder(
                              borderSide:
                                  const BorderSide(color: kPrimaryColor),
                              borderRadius: const BorderRadius.all(
                                const Radius.circular(5.0),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                )),
          );
        });
  }
}

class _ChartData {
  _ChartData(this.x, this.y, this.color);

  final String x;
  final double y;
  final Color? color;
}
