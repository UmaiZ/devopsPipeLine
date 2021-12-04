import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;

class SideAccount extends StatefulWidget {
  @override
  _SideAccountState createState() => _SideAccountState();
}

class _SideAccountState extends State<SideAccount> {
  @override
  void initState() {
    super.initState();

    getImi();
  }

  bool loading = true;
 late String mobile;
 late String email;
 late String address;
 late String numberplate;
 late String carName;
 late String engineNumber;
 late String chassisNumber;
 late String namE;
 late String odometer;

  getImi() async {
    final storage = new FlutterSecureStorage();

    String imi = await storage.read(key: "imei");
    print('showimi');
    print(imi);

    var map = new Map<String, dynamic>();

    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Center(
              child: SpinKitWave(
                  color: Color(0xff01a8dd), type: SpinKitWaveType.center));
        });


    var url =
        'http://api.igiinsurance.com.pk:8888/drive_api/my_account.php?imei=${imi}';
    print(url);
    http.Response res = await http.get(
      Uri.parse(url),
      headers: <String, String>{'token': 'c66026133e80d4960f0a5b7d418a4d08'},
    );
    var data = json.decode(res.body.toString());
    print(data);
    print(data[0]['mobile']);

    if (data[0]['mobile'].toString().length >= 1) {
      Navigator.pop(context);
      loading = false;

      setState(() {
        mobile = data[0]['mobile'].toString();
        email = data[0]['contact_email'].toString();
        address = data[0]['address'].toString();
        numberplate = data[0]['number plate'].toString();
        carName = data[0]['car name'].toString();
        engineNumber = data[0]['vehicle engine'].toString();
        chassisNumber = data[0]['vehicle chassis'].toString();
        namE = data[0]['contact name'].toString();
        odometer = data[0]['odometer'].toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    var data;
    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Icon(Icons.arrow_back, color: Color(0xff01a8dd),)),
        centerTitle: true,

        backgroundColor: Colors.white,
        elevation: 1,
        title: Text(
          'Account',
          style: TextStyle(fontFamily: 'PoppinsBold', color: Color(0xff01a8dd)),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          color: Colors.white,
          child: Column(
            children: [
              Container(
                color: Colors.grey[400],
                width: double.infinity,
                height: height * 0.3,
                child: Center(
                    child: Text(
                      loading == false ? namE : '....',
                      style: TextStyle(
                        fontSize: 25,
                        color: Colors.white,
                        fontFamily: 'PoppinsMedium',
                      ),
                    )),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    Image.asset(
                      'images/call-icon@2x.png',
                      height: height * 0.045,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            loading == false ? mobile : '....',
                            style: TextStyle(
                              fontSize: 17,
                              fontFamily: 'PoppinsRegular',
                            ),
                          ),
                          SizedBox(
                            height: height * 0.007,
                          ),
                          Text(
                            'Mobile',
                            style: TextStyle(
                                fontSize: 17,
                                fontFamily: 'PoppinsRegular',
                                color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              Container(
                height: height * 0.001,
                color: Colors.grey,
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    Image.asset(
                      'images/contact-us-icon-sc@2x.png',
                      height: height * 0.045,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            loading == false ? email : '....',
                            style: TextStyle(
                              fontSize: 17,
                              fontFamily: 'PoppinsRegular',
                            ),
                          ),
                          SizedBox(
                            height: height * 0.007,
                          ),
                          Text(
                            'Personal',
                            style: TextStyle(
                                fontSize: 17,
                                fontFamily: 'PoppinsRegular',
                                color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              Container(
                height: height * 0.001,
                color: Colors.grey,
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    Image.asset(
                      'images/Filters-Smoth Copy 4@2x.png',
                      height: height * 0.045,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: width * 0.65,
                            child: Text(
                              loading == false ? 'address' : '....',
                              style: TextStyle(
                                fontSize: 17,
                                fontFamily: 'PoppinsRegular',
                              ),
                            ),
                          ),
                          SizedBox(
                            height: height * 0.007,
                          ),
                          Text(
                            'Address',
                            style: TextStyle(
                                fontSize: 17,
                                fontFamily: 'PoppinsRegular',
                                color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              Container(
                height: height * 0.001,
                color: Colors.grey,
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    Image.asset(
                      'images/driving-events@2x.png',
                      height: height * 0.045,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            loading == false ? carName : '....',
                            style: TextStyle(
                              fontSize: 17,
                              fontFamily: 'PoppinsRegular',
                            ),
                          ),
                          SizedBox(
                            height: height * 0.007,
                          ),
                          Text(
                            'Car Name',
                            style: TextStyle(
                                fontSize: 17,
                                fontFamily: 'PoppinsRegular',
                                color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              Container(
                height: height * 0.001,
                color: Colors.grey,
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    Image.asset(
                      'images/plate-number@2x.png',
                      height: height * 0.045,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            loading == false ? numberplate : '....',
                            style: TextStyle(
                              fontSize: 16,
                              fontFamily: 'PoppinsRegular',
                            ),
                          ),
                          SizedBox(
                            height: height * 0.007,
                          ),
                          Text(
                            'Number Plate',
                            style: TextStyle(
                                fontSize: 17,
                                fontFamily: 'PoppinsRegular',
                                color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              Container(
                height: height * 0.001,
                color: Colors.grey,
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    Image.asset(
                      'images/engine-number@2x.png',
                      height: height * 0.045,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            loading == false ? engineNumber : '....',
                            style: TextStyle(
                              fontSize: 17,
                              fontFamily: 'PoppinsRegular',
                            ),
                          ),
                          SizedBox(
                            height: height * 0.007,
                          ),
                          Text(
                            'Engine No',
                            style: TextStyle(
                                fontSize: 17,
                                fontFamily: 'PoppinsRegular',
                                color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              Container(
                height: height * 0.001,
                color: Colors.grey,
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    Image.asset(
                      'images/mTag@2x.png',
                      height: height * 0.045,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            loading == false ? chassisNumber : '....',
                            style: TextStyle(
                              fontSize: 17,
                              fontFamily: 'PoppinsRegular',
                            ),
                          ),
                          SizedBox(
                            height: height * 0.007,
                          ),
                          Text(
                            'Chassis No',
                            style: TextStyle(
                                fontSize: 17,
                                fontFamily: 'PoppinsRegular',
                                color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              Container(
                height: height * 0.001,
                color: Colors.grey,
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    Image.asset(
                      'images/odometer@2x.png',
                      height: height * 0.045,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            loading == false ? odometer : '....',
                            style: TextStyle(
                              fontSize: 17,
                              fontFamily: 'PoppinsRegular',
                            ),
                          ),
                          SizedBox(
                            height: height * 0.007,
                          ),
                          Text(
                            'Odometer Reading',
                            style: TextStyle(
                                fontSize: 17,
                                fontFamily: 'PoppinsRegular',
                                color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              Container(
                height: height * 0.001,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
