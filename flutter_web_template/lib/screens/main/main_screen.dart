import 'package:flutter/material.dart';
import 'package:flutter_web_template/const.dart';
import 'package:flutter_web_template/responsive.dart';
import 'package:flutter_web_template/screens/dashboard/dashboard.dart';

import 'components/sidemenu.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: klightColor,
      body: SafeArea(
        child: Row(
          children: [
            if (Responsive.isDesktop(context))
              Expanded(
                // default flex = 1
                child: SideMenu(),
              ),
            Expanded(
              flex: 5,
              child: DashboardScreen(),
            ),
          ],
        ),
      ),
    );
  }
}
