import 'package:flutter/material.dart';

class DashboardCards extends StatelessWidget {
  final Color IconColor;
  final Color IconBgColor;
  final String Numbers;
  final String Texts;

  const DashboardCards(
      {Key? key,
      required this.IconColor,
      required this.IconBgColor,
      required this.Numbers,
      required this.Texts})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.33),
            spreadRadius: 5,
            blurRadius: 7,
            offset: Offset(0, 3), // changes position of shadow
          ),
        ],
        borderRadius: BorderRadius.circular(15),
      ),
      width: MediaQuery.of(context).size.width * 0.33,
      child: Padding(
        padding: const EdgeInsets.all(11.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: IconBgColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Icon(Icons.shopping_cart_outlined,
                        size: 27, color: IconColor),
                  ),
                ),
                Text(
                  Numbers,
                  textAlign: TextAlign.start,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                )
              ],
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.005,
            ),
            Align(
                alignment: Alignment.bottomRight,
                child: Text(
                  Texts,
                  textAlign: TextAlign.end,
                ))
          ],
        ),
      ),
    );
  }
}
