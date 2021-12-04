import 'package:blr_medical/Helpers/colors.dart';
import 'package:blr_medical/Helpers/data.dart';
import 'package:blr_medical/main.dart';
import 'dart:convert';


import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flash/flash.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController userPassword = new TextEditingController();
  final TextEditingController userNumber = new TextEditingController();
  bool _passwordVisible = false;
  late String token_id;
  bool remember = true;
  var _LocationList = [];

  loginClick() async {
    print(userNumber.text);
    print(userPassword.text);

    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Center(
              child: SpinKitWave(
                  color: kPrimaryColor, type: SpinKitWaveType.center));
        });

    var map = new Map<String, dynamic>();
    var url = Uri.parse('${DomainGlobal}/api/Authentication');
    print(url);

    Map data = {'identity': userNumber.text, 'password': userPassword.text};
    //encode Map to JSON
    var body = json.encode(data);

    var response = await http.post(url,
        headers: {"Content-Type": "application/json"}, body: body);
    print("${response.statusCode}");
    print("${response.body}");
    print('debug1');

    var respondedData = json.decode(response.body.toString());

    if (respondedData['succeed']) {
      print('debug2');
      print(respondedData['data']['token'].toString());
      tokenGlobal = respondedData['data']['token'].toString();
      sdlId = respondedData['data']['user']['userId'];


      print('debug 64)');
      Navigator.pop(context);
      print('debug 66)');

  
Navigator.of(context).push(MaterialPageRoute(builder: (context) => MainPage()));



      print('debug 72)');
    } else {
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

      Navigator.pop(context);
    }
  }

  @override
  void initState() {}

  @override
  Widget build(BuildContext context) {
    double statusBarHeight = MediaQuery.of(context).padding.top;
    double Height = MediaQuery.of(context).size.height;
    double Width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Color(0xffF7F9F9),
      body: SingleChildScrollView(
        child: Container(
          height: Height * 1,
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: kPrimaryColor,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(60.0),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: Height * 0.18,
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 7, right: 7),
                          child: Container(
                            child: Text('Bright Pharmacy',
                                style: TextStyle(
                                    fontFamily: 'PoppinsBold',
                                    
                                    fontSize: 28,
                                    color: Colors.white)),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: Height * 0.12,
                    ),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: Text('Login',
                            style: TextStyle(
                                fontFamily: 'PoppinsBold',
                                fontSize: 25,
                                color: Colors.white)),
                      ),
                    ),
                    SizedBox(
                      height: Height * 0.05,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    // borderRadius: BorderRadius.only(
                    //     topRight: Radius.circular(30.0),
                    //     topLeft: Radius.circular(30.0)),
                  ),
                  child: Column(
                    children: [
                      SizedBox(
                        height: Height * 0.07,
                      ),
                      Center(
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              SizedBox(
                                height: Height * 0.03,
                              ),
                              Container(
                                height: Height * 0.08,
                                width: Width * 0.9,
                                child: TextFormField(
                                  controller: userNumber,
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return 'Please enter a valid email';
                                    }
                                    return null;
                                  },
                                  keyboardType: TextInputType.emailAddress,
                                  style: TextStyle(
                                      fontSize: 15,
                                      color: kPrimaryColor,
                                      fontFamily: 'PoppinsRegular'),
                                  decoration: new InputDecoration(
                                    errorStyle: TextStyle(
                                      color: kPrimaryColor,
                                    ),
                                    border: new OutlineInputBorder(
                                      borderSide: const BorderSide(
                                          color: Color(0xffbdbdbd), width: 1),
                                      borderRadius: const BorderRadius.all(
                                        const Radius.circular(10.0),
                                      ),
                                    ),
                                    enabledBorder: new OutlineInputBorder(
                                      borderSide: const BorderSide(
                                          color: Color(0xffbdbdbd), width: 1),
                                      borderRadius: const BorderRadius.all(
                                        const Radius.circular(10.0),
                                      ),
                                    ),
                                    hintStyle: new TextStyle(
                                        color: Color(0xffbdbdbd),
                                        fontFamily: 'PoppinsRegular'),
                                    hintText: "Email",
                                    labelStyle: new TextStyle(
                                        color: kPrimaryColor,
                                        fontFamily: 'PoppinsRegular'),
                                    labelText: 'Email',
                                    fillColor: Colors.white,
                                    filled: true,
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(
                                          color: kPrimaryColor, width: 1),
                                      borderRadius: const BorderRadius.all(
                                        const Radius.circular(10.0),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: Height * 0.02,
                              ),
                              Container(
                                  width: Width * 0.9,
                                  height: Height * 0.08,
                                  child: TextFormField(
                                    controller: userPassword,

                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return 'Please enter a password';
                                      }
                                      return null;
                                    },
                                    obscureText:
                                        !_passwordVisible, //This will obscure text dynamically
                                    style: TextStyle(
                                        color: kPrimaryColor,
                                        fontFamily: 'PoppinsRegular'),
                                    decoration: new InputDecoration(
                                      errorStyle: TextStyle(
                                        color: kPrimaryColor,
                                      ),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          // Based on passwordVisible state choose the icon
                                          _passwordVisible
                                              ? Icons.visibility
                                              : Icons.visibility_off,
                                          color: kPrimaryColor,
                                        ),
                                        onPressed: () {
                                          // Update the state i.e. toogle the state of passwordVisible variable
                                          setState(() {
                                            _passwordVisible =
                                                !_passwordVisible;
                                          });
                                        },
                                      ),
                                      border: new OutlineInputBorder(
                                        borderSide: const BorderSide(
                                            color: Colors.grey, width: 1.25),
                                        borderRadius: const BorderRadius.all(
                                          const Radius.circular(10.0),
                                        ),
                                      ),
                                      hintStyle: new TextStyle(
                                          color: Color(0xffbdbdbd),
                                          fontFamily: 'PoppinsRegular'),
                                      hintText: "Password",
                                      labelText: "Password",
                                      labelStyle: new TextStyle(
                                          color: kPrimaryColor,
                                          fontFamily: 'PoppinsRegular'),
                                      fillColor: Colors.white,
                                      filled: true,
                                      enabledBorder: new OutlineInputBorder(
                                        borderSide: const BorderSide(
                                            color: Color(0xffbdbdbd), width: 1),
                                        borderRadius: const BorderRadius.all(
                                          const Radius.circular(10.0),
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                            color: kPrimaryColor, width: 1),
                                        borderRadius: const BorderRadius.all(
                                          const Radius.circular(10.0),
                                        ),
                                      ),
                                    ),
                                  )),
                             
                              // Container(
                              //   width: Width * 0.9,
                              //   child: Row(
                              //     children: [
                              //       Text(
                              //         'Remember Me',
                              //         textAlign: TextAlign.end,
                              //         style: TextStyle(
                              //             color: Color(0xff7c7c7c),
                              //             fontFamily: 'PoppinsRegular',
                              //             fontSize: 14),
                              //       ),
                              //       Transform.scale(
                              //         scale: .7,
                              //         child: CupertinoSwitch(
                              //           activeColor: kPrimaryColor,
                              //           value: remember,
                              //           onChanged: (value) async {
                              //             setState(() {
                              //               remember = value;
                              //             });
                              //           },
                              //         ),
                              //       ),
                              //     ],
                              //   ),
                              // ),
                              // SizedBox(
                              //   height: Height * 0.005,
                              // ),
                            ],
                          ),
                        ),
                      ),
                       SizedBox(
                                height: Height * 0.005,
                              ),
                      Center(
                        child: GestureDetector(
                          onTap: () {
                            final isValid = _formKey.currentState!.validate();
                            if (isValid) {
                              loginClick();
                            }
                          },
                          child: Container(
                            height: Height * 0.07,
                            width: Width * 0.9,
                            decoration: BoxDecoration(
                              color: kPrimaryColor,
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(10),
                                  topRight: Radius.circular(10),
                                  bottomLeft: Radius.circular(10),
                                  bottomRight: Radius.circular(10)),
                            ),
                            child: Center(
                                child: Text(
                              'Login',
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'PoppinsRegular',
                                  color: Colors.white),
                            )),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: Height * 0.02,
                      ),
                      // GestureDetector(
                      //   onTap: () async {},
                      //   child: Padding(
                      //     padding: const EdgeInsets.only(right: 17),
                      //     child: Align(
                      //         alignment: Alignment.centerRight,
                      //         child: Text(
                      //           'Change config ?',
                      //           textAlign: TextAlign.end,
                      //           style: TextStyle(
                      //             color: Color(0xff7c7c7c),
                      //             fontFamily: 'PoppinsRegular',
                      //           ),
                      //         )),
                      //   ),
                      // ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
