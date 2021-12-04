
import 'package:flutter/material.dart';
import 'package:flutter_web_template/const.dart';
import 'package:flutter_web_template/screens/main/components/header.dart';

import 'components/dashboard_boxes.dart';



class DashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(defaultPadding),
        child: Column(
          children: [
            Header(),
            SizedBox(height: defaultPadding),
            DashboardBoxes()
            

          ],
        ),
      ),
    );
  }
}
