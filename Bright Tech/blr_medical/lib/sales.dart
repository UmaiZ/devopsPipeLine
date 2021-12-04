import 'package:flash/flash.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:blr_medical/Helpers/data.dart';
import 'package:intl/intl.dart';
import 'package:blr_medical/Helpers/colors.dart';
import 'package:flutter/material.dart';

class SalesScreen extends StatefulWidget {
  @override
  _SalesScreenState createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> {
  final TextEditingController startDate = new TextEditingController();
  final TextEditingController endDate = new TextEditingController();

  var SalesList = [];
  String searchString = "";

  String TotalBil = "";
  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      this.getActivity();
    });
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

    var url = Uri.parse('${DomainGlobal}/api/Report/customerReport');
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
        SalesList = respondedData['data'];
                  Navigator.pop(context);

                  double sum = 0;
                  for (var i = 0; i < SalesList.length; i++) {
                    print(SalesList[i]['totalAmount']);
                    sum += SalesList[i]['totalAmount'];
                  }
                  //

                  TotalBil = sum.toStringAsFixed(1);

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
    }
  }



  @override
  Widget build(BuildContext context) {
    double Width = MediaQuery.of(context).size.width;
    double Height = MediaQuery.of(context).size.height;
    double Status = MediaQuery.of(context).padding.top;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        title: Text('Sales',
                                style: TextStyle(
                                    fontFamily: 'PoppinsMedium',
                                    
                                    fontSize: 21,
                                    color: Colors.white)),
        automaticallyImplyLeading: false,
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            height: Height * 0.02,
          ),
                      Container(
              padding: const EdgeInsets.only(top: 10),
              width: Width * 0.9,
              child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                GestureDetector(
                  onTap: () async {
                    setState(() {
                      filterRange = 0;
                    });

                    DateTime selectedDate = DateTime.now();
                    String startDate =
                        DateFormat("yyyy-MM-d").format(selectedDate).toString();

                    String endDate =
                        DateFormat("yyyy-MM-d").format(selectedDate).toString();
                    Map body = {
                      "fromDate": startDate,
                      "tillDate": endDate,
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
                                  color: kPrimaryColor,
                                  type: SpinKitWaveType.center));
                        });

                    var url = Uri.parse('${DomainGlobal}/api/Report/customerReport');
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
                            SalesList = respondedData['data'];
                  Navigator.pop(context);

                  double sum = 0;
                  for (var i = 0; i < SalesList.length; i++) {
                    print(SalesList[i]['totalAmount']);
                    sum += SalesList[i]['totalAmount'];
                  }
                  //

                  TotalBil = sum.toStringAsFixed(1);
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
                                    topLeft: Radius.circular(8),
                                    topRight: Radius.circular(8)),
                                boxShadows: kElevationToShadow[8],
                                backgroundGradient: RadialGradient(
                                  colors: [
                                    Color(0xffdcf6ff),
                                    Color(0xffdcf6ff)
                                  ],
                                  center: Alignment.topLeft,
                                ),
                                onTap: () => controller.dismiss(),
                                forwardAnimationCurve: Curves.easeInCirc,
                                reverseAnimationCurve: Curves.bounceIn,
                                child: DefaultTextStyle(
                                  style: TextStyle(color: Colors.white),
                                  child: FlashBar(
                                    content: Text(
                                        respondedData['message'].toString(),
                                        style: TextStyle(
                                            fontFamily: 'PoppinsRegular',
                                            color: kPrimaryColor,
                                            fontSize: 17)),
                                    primaryAction: TextButton(
                                      onPressed: () => controller.dismiss(),
                                      child: Icon(Icons.close_outlined,
                                          color: kPrimaryColor),
                                    ),
                                  ),
                                ),
                              );
                            });
                      }
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(left: 0),
                    child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12.0),
                          border: Border.all(
                            color:
                                filterRange == 0 ? kPrimaryColor : Colors.grey,
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
                  onTap: () async {
                    setState(() {
                      filterRange = 1;
                    });
                    DateTime selectedDate = DateTime.now();

                    String startDate =
                        DateFormat("yyyy-MM-d").format(selectedDate).toString();

                    String endDate =
                        DateFormat("yyyy-MM-d").format(selectedDate).toString();
                    var now = new DateTime.now();
                    var beginningNextMonth = (now.month < 12)
                        ? new DateTime(now.year, now.month + 1, 1)
                        : new DateTime(now.year + 1, 1, 1);
                    var lastDay =
                        beginningNextMonth.subtract(new Duration(days: 1)).day;

                    print(lastDay); // 28 for February

                    Map body = {
                      "fromDate":
                          '${selectedDate.year}-${selectedDate.month}-1',
                      "tillDate":
                          '${selectedDate.year}-${selectedDate.month}-${lastDay}',
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
                                  color: kPrimaryColor,
                                  type: SpinKitWaveType.center));
                        });

                    var url = Uri.parse('${DomainGlobal}/api/Report/customerReport');
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
                            SalesList = respondedData['data'];
                  Navigator.pop(context);

                  double sum = 0;
                  for (var i = 0; i < SalesList.length; i++) {
                    print(SalesList[i]['totalAmount']);
                    sum += SalesList[i]['totalAmount'];
                  }
                  //

                  TotalBil = sum.toStringAsFixed(1);
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
                                    topLeft: Radius.circular(8),
                                    topRight: Radius.circular(8)),
                                boxShadows: kElevationToShadow[8],
                                backgroundGradient: RadialGradient(
                                  colors: [
                                    Color(0xffdcf6ff),
                                    Color(0xffdcf6ff)
                                  ],
                                  center: Alignment.topLeft,
                                ),
                                onTap: () => controller.dismiss(),
                                forwardAnimationCurve: Curves.easeInCirc,
                                reverseAnimationCurve: Curves.bounceIn,
                                child: DefaultTextStyle(
                                  style: TextStyle(color: Colors.white),
                                  child: FlashBar(
                                    content: Text(
                                        respondedData['message'].toString(),
                                        style: TextStyle(
                                            fontFamily: 'PoppinsRegular',
                                            color: kPrimaryColor,
                                            fontSize: 17)),
                                    primaryAction: TextButton(
                                      onPressed: () => controller.dismiss(),
                                      child: Icon(Icons.close_outlined,
                                          color: kPrimaryColor),
                                    ),
                                  ),
                                ),
                              );
                            });
                      }
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(left: 12),
                    child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12.0),
                          border: Border.all(
                            color:
                                filterRange == 1 ? kPrimaryColor : Colors.grey,
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
                  onTap: () async {
                    setState(() {
                      filterRange = 4;
                    });

                    DateTime selectedDate = DateTime.now();
                    String startDate = DateFormat("yyyy-MM-d")
                        .format(selectedDate.subtract(Duration(days: 7)))
                        .toString();

                    String endDate =
                        DateFormat("yyyy-MM-d").format(selectedDate).toString();
                    Map body = {
                      "fromDate": startDate,
                      "tillDate": endDate,
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
                                  color: kPrimaryColor,
                                  type: SpinKitWaveType.center));
                        });

                    var url = Uri.parse('${DomainGlobal}/api/Report/customerReport');
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
                            SalesList = respondedData['data'];
                  Navigator.pop(context);

                  double sum = 0;
                  for (var i = 0; i < SalesList.length; i++) {
                    print(SalesList[i]['totalAmount']);
                    sum += SalesList[i]['totalAmount'];
                  }
                  //

                  TotalBil = sum.toStringAsFixed(1);
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
                                    topLeft: Radius.circular(8),
                                    topRight: Radius.circular(8)),
                                boxShadows: kElevationToShadow[8],
                                backgroundGradient: RadialGradient(
                                  colors: [
                                    Color(0xffdcf6ff),
                                    Color(0xffdcf6ff)
                                  ],
                                  center: Alignment.topLeft,
                                ),
                                onTap: () => controller.dismiss(),
                                forwardAnimationCurve: Curves.easeInCirc,
                                reverseAnimationCurve: Curves.bounceIn,
                                child: DefaultTextStyle(
                                  style: TextStyle(color: Colors.white),
                                  child: FlashBar(
                                    content: Text(
                                        respondedData['message'].toString(),
                                        style: TextStyle(
                                            fontFamily: 'PoppinsRegular',
                                            color: kPrimaryColor,
                                            fontSize: 17)),
                                    primaryAction: TextButton(
                                      onPressed: () => controller.dismiss(),
                                      child: Icon(Icons.close_outlined,
                                          color: kPrimaryColor),
                                    ),
                                  ),
                                ),
                              );


                              
                            });
                      }
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(left: 12),
                    child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12.0),
                          border: Border.all(
                            color:
                                filterRange == 4 ? kPrimaryColor : Colors.grey,
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
                GestureDetector(
                  onTap: () async {
                    setState(() {
                      filterRange = 2;
                    });

                    DateTime selectedDate = DateTime.now();
                    String startDate =
                        DateFormat("yyyy-MM-d").format(selectedDate).toString();

                    String endDate =
                        DateFormat("yyyy-MM-d").format(selectedDate).toString();
                    Map body = {
                      "fromDate": "${selectedDate.year}-01-01",
                      "tillDate": "${selectedDate.year}-12-31",
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
                                  color: kPrimaryColor,
                                  type: SpinKitWaveType.center));
                        });

                    var url = Uri.parse('${DomainGlobal}/api/Report/customerReport');
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
                          SalesList = respondedData['data'];
                  Navigator.pop(context);

                  double sum = 0;
                  for (var i = 0; i < SalesList.length; i++) {
                    print(SalesList[i]['totalAmount']);
                    sum += SalesList[i]['totalAmount'];
                  }
                  ////

                  TotalBil = sum.toStringAsFixed(1);

                          
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
                                    topLeft: Radius.circular(8),
                                    topRight: Radius.circular(8)),
                                boxShadows: kElevationToShadow[8],
                                backgroundGradient: RadialGradient(
                                  colors: [
                                    Color(0xffdcf6ff),
                                    Color(0xffdcf6ff)
                                  ],
                                  center: Alignment.topLeft,
                                ),
                                onTap: () => controller.dismiss(),
                                forwardAnimationCurve: Curves.easeInCirc,
                                reverseAnimationCurve: Curves.bounceIn,
                                child: DefaultTextStyle(
                                  style: TextStyle(color: Colors.white),
                                  child: FlashBar(
                                    content: Text(
                                        respondedData['message'].toString(),
                                        style: TextStyle(
                                            fontFamily: 'PoppinsRegular',
                                            color: kPrimaryColor,
                                            fontSize: 17)),
                                    primaryAction: TextButton(
                                      onPressed: () => controller.dismiss(),
                                      child: Icon(Icons.close_outlined,
                                          color: kPrimaryColor),
                                    ),
                                  ),
                                ),
                              );
                            });
                      }
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(left: 12),
                    child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12.0),
                          border: Border.all(
                            color:
                                filterRange == 2 ? kPrimaryColor : Colors.grey,
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
              ]),
            ),

            SizedBox(
              height: MediaQuery.of(context).size.height * 0.02,
            ),

          Align(
            alignment: Alignment.center,
            child: Container(
              width: Width * 0.9,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: Width * 0.35,
                    child: TextFormField(
                      controller: startDate,
                      decoration: new InputDecoration(
                        suffixIcon: IconButton(
                          onPressed: () async {
                            DateTime selectedDate = DateTime.now();

                            final DateTime? picked = await showDatePicker(
                                context: context,
                                initialDate: selectedDate,
                                firstDate: DateTime(2013, 1),
                                lastDate: DateTime(2027, 12));
                            if (picked != null && picked != selectedDate)
                              setState(() {
                                //print(picked);
                                //print(DateFormat("yyyy-MM-d")
                                // .format(picked)
                                // .toString());
                                startDate.text = DateFormat("yyyy-MM-d")
                                    .format(picked)
                                    .toString();
                                FocusScope.of(context)
                                    .requestFocus(FocusNode());
                              });
                          },
                          icon: Icon(
                            Icons.date_range_outlined,
                            color: Color(0xffbdbdbd),
                          ),
                        ),
                        labelText: "From Date",
                        labelStyle: TextStyle(
                            color: textGreyColor, fontFamily: 'SegoeUI'),
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
                          borderRadius: new BorderRadius.circular(10),
                          borderSide: new BorderSide(color: Color(0xffE6E6E6)),
                        ),
                        //fillColor: Colors.green
                      ),
                      keyboardType: TextInputType.number,
                      style: new TextStyle(
                          fontFamily: "SegoeUI", color: kPrimaryColor),
                    ),
                  ),
                  Container(
                    width: Width * 0.35,
                    child: TextFormField(
                      controller: endDate,
                      decoration: new InputDecoration(
                        suffixIcon: IconButton(
                          onPressed: () async {
                            DateTime selectedDate = DateTime.now();

                            final DateTime? picked = await showDatePicker(
                                context: context,
                                initialDate: selectedDate,
                                firstDate: DateTime(2013, 1),
                                lastDate: DateTime(2027, 12));
                            if (picked != null && picked != selectedDate)
                              setState(() {
                                //print(picked);
                                //print(DateFormat("yyyy-MM-d")
                                // .format(picked)
                                // .toString());
                                endDate.text = DateFormat("yyyy-MM-d")
                                    .format(picked)
                                    .toString();
                                FocusScope.of(context)
                                    .requestFocus(FocusNode());
                              });
                          },
                          icon: Icon(
                            Icons.date_range_outlined,
                            color: Color(0xffbdbdbd),
                          ),
                        ),
                        labelText: "To Date",
                        labelStyle: TextStyle(
                            color: textGreyColor, fontFamily: 'SegoeUI'),
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
                          borderRadius: new BorderRadius.circular(10),
                          borderSide: new BorderSide(color: Color(0xffE6E6E6)),
                        ),
                        //fillColor: Colors.green
                      ),
                      keyboardType: TextInputType.number,
                      style: new TextStyle(
                          fontFamily: "SegoeUI", color: kPrimaryColor),
                    ),
                  ),
                 RawMaterialButton(
    onPressed: () async {
              if(startDate.text == "" && endDate.text == "")
{
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
                              topLeft: Radius.circular(8),
                              topRight: Radius.circular(8)),
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
                              content: Text('Please select start and end date',
                                  style: TextStyle(
                                      fontFamily: 'PoppinsRegular',
                                      color: kPrimaryColor,
                                      fontSize: 17)),
                              primaryAction: TextButton(
                                onPressed: () => controller.dismiss(),
                                child: Icon(Icons.close_outlined,
                                    color: kPrimaryColor),
                              ),
                            ),
                          ),
                        );
                      });
               
              }
              else{
              Map body = {
                "fromDate": startDate.text,
                "tillDate": endDate.text,
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
                            color: kPrimaryColor,
                            type: SpinKitWaveType.center));
                  });

              var url = Uri.parse('${DomainGlobal}/api/Report/customerReport');
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
                  SalesList = respondedData['data'];
                  Navigator.pop(context);

                  double sum = 0;
                  for (var i = 0; i < SalesList.length; i++) {
                    print(SalesList[i]['totalAmount']);
                    sum += SalesList[i]['totalAmount'];
                  }
                  //

                  TotalBil = sum.toStringAsFixed(1);
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
                              topLeft: Radius.circular(8),
                              topRight: Radius.circular(8)),
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
                                child: Icon(Icons.close_outlined,
                                    color: kPrimaryColor),
                              ),
                            ),
                          ),
                        );
                      });
                }}
                else{
                Navigator.pop(context);
              }
              }
              
            },
          
  constraints: BoxConstraints(),
  elevation: 2.0,
  fillColor: kPrimaryColor,
  child: Icon(
    Icons.check_outlined,
    size: 26.0,
    color: Colors.white,
  ),
  padding: EdgeInsets.all(7.0),
  shape: CircleBorder(),
),
       
                ],
              ),
            ),
          ),
          SizedBox(
            height: Height * 0.02,
          ),
   
          SalesList.length > 0
              ? Container(
                  width: Width * 0.9,
                  child: TextFormField(
                    onChanged: (value) {
                      setState(() {
                        searchString = value;
                      });
                    },
                    decoration: new InputDecoration(
                      suffixIcon: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.0),
                            color: Color(0xffCFDFF7), // Button color
                          ),
                          child: InkWell(
                            splashColor: Colors.red, // Splash color
                            onTap: () {},
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
            height: Height * 0.02,
          ),
          SalesList.length > 0
              ? Container(
                  width: Width * 0.9,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: Width * 0.4,
                        decoration: BoxDecoration(
                          color: Color(0xffFDECED),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(13.0),
                          child: Column(
                            children: [
                              Text(SalesList.length.toString(),
                                  style: new TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xffE44450))),
                              Text('Total Invoices',
                                  style: new TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w400,
                                      color: Color(0xffE44450)))
                            ],
                          ),
                        ),
                      ),
                      Container(
                        width: Width * 0.4,
                        decoration: BoxDecoration(
                          color: Color(0xffF8F2E4),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(13.0),
                          child: Column(
                            children: [
                              Text(TotalBil,
                                  style: new TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xffCCA755))),
                              Text('Total Sale',
                                  style: new TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w400,
                                      color: Color(0xffCCA755)))
                            ],
                          ),
                        ),
                      ),
                      // Container(
                      //   width: Width * 0.275,
                      //   decoration: BoxDecoration(
                      //     color: Color(0xffDCEEFC),
                      //     borderRadius: BorderRadius.circular(10),
                      //   ),
                      //   child: Padding(
                      //     padding: const EdgeInsets.all(13.0),
                      //     child: Column(
                      //       children: [
                      //         Text('100',
                      //             style: new TextStyle(
                      //                 fontSize: 18,
                      //                 fontFamily: 'PoppinsMedium',
                      //                 color: Color(0xff2D587B))),
                      //         Text('Signup',
                      //             style: new TextStyle(
                      //                 fontSize: 18,
                      //                 fontFamily: 'PoppinsMedium',
                      //                 color: Color(0xff2D587B)))
                      //       ],
                      //     ),
                      //   ),
                      // )
                    ],
                  ),
                )
              : Container(),
          SizedBox(
            height: Height * 0.02,
          ),
          Expanded(
            child: Container(
              width: Width * 0.9,
              child: ListView.builder(
                itemCount: SalesList.length,
                shrinkWrap: true,
                scrollDirection: Axis.vertical,
                physics: ScrollPhysics(),
                itemBuilder: (context, index) {
                  String formattedDate = DateFormat('dd MMM, yyyy').format(
                      DateTime.parse(
                          SalesList[index]['invoiceDate'].toString()));

                  return SalesList[index]['invoiceNo']
                              .toString()
                              .toLowerCase()
                              .contains(searchString.toLowerCase()) ||
                          SalesList[index]['invoiceNo']
                              .toString()
                              .toUpperCase()
                              .contains(searchString.toUpperCase())
                      ? Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Container(
                            width: Width * 0.9,
                            child: Card(
                              elevation: 2,
                              color: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
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
                                                new TextSpan(
                                                    text: 'Invoice # : ',
                                                    style: new TextStyle(
                                                        fontSize: 12,
                                                        fontFamily:
                                                            'PoppinsBold')),
                                                new TextSpan(
                                                    text:
                                                        '${SalesList[index]['invoiceNo']}',
                                                    style: TextStyle(
                                                        fontSize: 12,
                                                        fontFamily:
                                                            'PoppinsRegular',
                                                        color: textGreyColor)),
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
                                                    text: 'Date : ',
                                                    style: new TextStyle(
                                                        fontSize: 12,
                                                        fontFamily:
                                                            'PoppinsBold')),
                                                new TextSpan(
                                                    text: '${formattedDate}',
                                                    style: TextStyle(
                                                        fontSize: 12,
                                                        fontFamily:
                                                            'PoppinsRegular',
                                                        color: textGreyColor)),
                                              ],
                                            ),
                                          )
                                        ]),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
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
                                                new TextSpan(
                                                    text: 'Total Amount : ',
                                                    style: new TextStyle(
                                                        fontSize: 12,
                                                        fontFamily:
                                                            'PoppinsBold')),
                                                new TextSpan(
                                                    text:
                                                        '${SalesList[index]['totalAmount'].toString()}',
                                                    style: TextStyle(
                                                        fontSize: 12,
                                                        fontFamily:
                                                            'PoppinsRegular',
                                                        color: textGreyColor)),
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
                                                    text: 'Discount : ',
                                                    style: new TextStyle(
                                                        fontSize: 12,
                                                        fontFamily:
                                                            'PoppinsBold')),
                                                new TextSpan(
                                                    text:
                                                        '${SalesList[index]['discountValue'].toString()}',
                                                    style: TextStyle(
                                                        fontSize: 12,
                                                        fontFamily:
                                                            'PoppinsRegular',
                                                        color: textGreyColor)),
                                              ],
                                            ),
                                          )
                                        ]),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
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
                                                new TextSpan(
                                                    text: 'Discount % : ',
                                                    style: new TextStyle(
                                                        fontSize: 12,
                                                        fontFamily:
                                                            'PoppinsBold')),
                                                new TextSpan(
                                                    text:
                                                        '${SalesList[index]['discountPercentage'].toString()}',
                                                    style: TextStyle(
                                                        fontSize: 12,
                                                        fontFamily:
                                                            'PoppinsRegular',
                                                        color: textGreyColor)),
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
                                                    text: 'Net Bill : ',
                                                    style: new TextStyle(
                                                        fontSize: 12,
                                                        fontFamily:
                                                            'PoppinsBold')),
                                                new TextSpan(
                                                    text:
                                                        '${SalesList[index]['totalAmount'].toString()}',
                                                    style: TextStyle(
                                                        fontSize: 12,
                                                        fontFamily:
                                                            'PoppinsRegular',
                                                        color: textGreyColor)),
                                              ],
                                            ),
                                          )
                                        ]),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
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
                                                new TextSpan(
                                                    text: 'Description : ',
                                                    style: new TextStyle(
                                                        fontSize: 12,
                                                        fontFamily:
                                                            'PoppinsBold')),
                                                new TextSpan(
                                                    text:
                                                        '${SalesList[index]['particular'].toString()}',
                                                    style: TextStyle(
                                                        fontSize: 12,
                                                        fontFamily:
                                                            'PoppinsRegular',
                                                        color: textGreyColor)),
                                              ],
                                            ),
                                          ),
                                        ]),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        )
                      : Container();

                  ;
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
