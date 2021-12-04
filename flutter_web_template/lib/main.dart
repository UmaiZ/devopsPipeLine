import 'package:flutter/material.dart';
import 'package:flutter_web_template/screens/main/main_screen.dart';

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
        primaryColor: Color(0xfff00B074),
        textTheme: const TextTheme(
           headline1: TextStyle(
              fontSize: 25.0,
              fontFamily: 'Barlow-Bold',
              color: Color(0xff464255)),

          bodyText1: TextStyle(
              fontSize: 18.0,
              fontFamily: 'Barlow-Medium',
              color: Color(0xff464255)),
                        bodyText2: TextStyle(
              fontSize: 16.0,
              fontFamily: 'Barlow-Regular',
              color: Color(0xff464255)),
        ),
      ),
      home: MainScreen(),
    );
  }
}
