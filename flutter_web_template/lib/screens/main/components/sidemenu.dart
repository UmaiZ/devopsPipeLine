import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_web_template/const.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';

class SideMenu extends StatefulWidget {
  const SideMenu({Key? key}) : super(key: key);

  @override
  _SideMenuState createState() => _SideMenuState();
}

class _SideMenuState extends State<SideMenu> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 30, bottom: 15),
            child: SvgPicture.asset(
              "assets/icon/logo.svg",
            ),
          ),
          DrawerListTile(
            intKey: 1,
            title: "Dashboard",
            svgSrc: "assets/icon/home_deactive.svg",
            press: () {
              setState(() {
                sideMenuValue = 1;
              });
            },
          ),
          DrawerListTile(
            intKey: 2,
            title: "Orders",
            svgSrc: "assets/icon/order.svg",
            press: () {
              setState(() {
                sideMenuValue = 2;
              });
            },
          ),
          DrawerListTile(
            intKey: 3,
            title: "Customer",
            svgSrc: "assets/icon/customer.svg",
            press: () {},
          ),
          DrawerListTile(
            intKey: 4,
            title: "Analytics",
            svgSrc: "assets/icon/analytics.svg",
            press: () {},
          ),
          DrawerListTile(
            intKey: 5,
            title: "Review",
            svgSrc: "assets/icon/review.svg",
            press: () {},
          ),
          DrawerListTile(
            intKey: 6,
            title: "Wallet",
            svgSrc: "assets/icon/wallet.svg",
            press: () {},
          ),
     
        ],
      ),
    );
  }
}

class DrawerListTile extends StatelessWidget {
  const DrawerListTile({
    Key? key,
    // For selecting those three line once press "Command+D"
    required this.intKey,
    required this.title,
    required this.svgSrc,
    required this.press,
  }) : super(key: key);

  final String title, svgSrc;
  final VoidCallback press;
  final int intKey;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: press,
      child: Padding(
        padding: const EdgeInsets.only(left: 30, bottom: 13, right: 30),
        child: Container(
            decoration: BoxDecoration(
                color: sideMenuValue == intKey ? kSecondaryColor : null,
                borderRadius: BorderRadius.all(Radius.circular(8))),
            child: Padding(
              padding: const EdgeInsets.all(13.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    svgSrc,
                    height: 18,
                    color: sideMenuValue == intKey ? kPrimaryColor : null,
                  ),
                  SizedBox(
                    width: 13,
                  ),
                  Text(
                    title,
                    style: sideMenuValue == intKey
                        ? TextStyle(
                            fontSize: 18.0,
                            fontFamily: 'Barlow-Bold',
                            color: kPrimaryColor)
                        : Theme.of(context).textTheme.bodyText1,
                  ),
                ],
              ),
            )),
      ),
    );
  }
}
