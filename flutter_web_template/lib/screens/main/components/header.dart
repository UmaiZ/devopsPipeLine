import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_web_template/const.dart';

import '../../../responsive.dart';

class Header extends StatelessWidget {
  const Header({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (!Responsive.isDesktop(context))
          IconButton(
            icon: Icon(Icons.menu),
            onPressed: () {
              // context.read<MenuController>().controlMenu
            },
          ),
        // if (!Responsive.isMobile(context))
        //   Text(
        //     "Dashboard",
        //     style: Theme.of(context).textTheme.headline6,
        //   ),
        if (!Responsive.isMobile(context))
          // Spacer(flex: Responsive.isDesktop(context) ? 2 : 1),
          SearchField(),
        Spacer(),

        Container(
          height: 70.0,
          width: 65.0,
          child: Stack(
            children: [
              Align(
                alignment: Alignment.center,
                child: Container(
                  height: 48.0,
                  width: 48.0,
                  decoration: const BoxDecoration(
                    color: Color(0xffd1e6f5),
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: SvgPicture.asset(
                      "assets/icon/notification.svg",
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.topRight,
                child: Container(
                  width: 27.0,
                  height: 27.0,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                      border: Border.all(color: klightColor, width: 3)),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Color(0xff009fe1),
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(3.0),
                      child: Center(
                          child: Text(
                        '10',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontFamily: 'Barlow-Medium'),
                      )),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        Container(
          height: 70.0,
          width: 65.0,
          child: Stack(
            children: [
              Align(
                alignment: Alignment.center,
                child: Container(
                  height: 48.0,
                  width: 48.0,
                  decoration: const BoxDecoration(
                    color: Color(0xffd1e6f5),
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: SvgPicture.asset(
                      "assets/icon/message.svg",
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.topRight,
                child: Container(
                  width: 27.0,
                  height: 27.0,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                      border: Border.all(color: klightColor, width: 3)),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Color(0xff009fe1),
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(3.0),
                      child: Center(
                          child: Text(
                        '10',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontFamily: 'Barlow-Medium'),
                      )),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        Container(
          height: 70.0,
          width: 65.0,
          child: Stack(
            children: [
              Align(
                alignment: Alignment.center,
                child: Container(
                  height: 48.0,
                  width: 48.0,
                  decoration: const BoxDecoration(
                    color: Color(0xffdddee9),
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: SvgPicture.asset(
                      "assets/icon/gift.svg",
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.topRight,
                child: Container(
                  width: 27.0,
                  height: 27.0,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                      border: Border.all(color: klightColor, width: 3)),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Color(0xff5a6d96),
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(3.0),
                      child: Center(
                          child: Text(
                        '10',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontFamily: 'Barlow-Medium'),
                      )),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        Container(
          height: 70.0,
          width: 65.0,
          child: Stack(
            children: [
              Align(
                alignment: Alignment.center,
                child: Container(
                  height: 48.0,
                  width: 48.0,
                  decoration: const BoxDecoration(
                    color: Color(0xfffadadf),
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: SvgPicture.asset(
                      "assets/icon/setting.svg",
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.topRight,
                child: Container(
                  width: 27.0,
                  height: 27.0,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                      border: Border.all(color: klightColor, width: 3)),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Color(0xffff4953),
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(3.0),
                      child: Center(
                          child: Text(
                        '10',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontFamily: 'Barlow-Medium'),
                      )),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          width: 7,
        ),
        Container(
          height: 70.0,
          width: 1.5,
          color: Color(0xffD0D6DE),
        ),
        SizedBox(
          width: 10,
        ),
        Text(
          'Hello, Bot Adam',
          style: Theme.of(context).textTheme.bodyText1,
        ),
        SizedBox(
          width: 10,
        ),

        Container(
          width: 53,
          child: CircleAvatar(
            radius: 50,
            backgroundColor: Color(0xffC4C4C4),
          ),
          decoration: new BoxDecoration(
            shape: BoxShape.circle,
            border: new Border.all(
              color: Colors.white,
              width: 6.0,
            ),
          ),
        ),
      ],
    );
  }
}

class ProfileCard extends StatelessWidget {
  const ProfileCard({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: defaultPadding),
      padding: EdgeInsets.symmetric(
        horizontal: defaultPadding,
        vertical: defaultPadding / 2,
      ),
      decoration: BoxDecoration(
        color: kSecondaryColor,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Image.asset(
            "assets/icon/profile_pic.png",
            height: 38,
          ),
          if (!Responsive.isMobile(context))
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: defaultPadding / 2),
              child: Text("Angelina Jolie"),
            ),
          Icon(Icons.keyboard_arrow_down),
        ],
      ),
    );
  }
}

class SearchField extends StatelessWidget {
  const SearchField({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.4,
      child: TextField(
        decoration: InputDecoration(
          hintText: "Search",
          fillColor: klightSecondColor,
          filled: true,
          border: OutlineInputBorder(
            borderRadius: const BorderRadius.all(Radius.circular(10)),
            borderSide: const BorderSide(color: Color(0xffebebeb), width: 0.5),
          ),
          enabledBorder: new OutlineInputBorder(
            borderRadius: const BorderRadius.all(Radius.circular(10)),
            borderSide: const BorderSide(color: Color(0xffebebeb), width: 0.5),
          ),
          focusedBorder: new OutlineInputBorder(
            borderRadius: const BorderRadius.all(Radius.circular(10)),
            borderSide: const BorderSide(color: Color(0xffebebeb), width: 0.5),
          ),
          suffixIcon: InkWell(
            onTap: () {},
            child: Container(
              padding: EdgeInsets.all(defaultPadding * 0.75),
              margin: EdgeInsets.symmetric(horizontal: defaultPadding / 2),
              child: SvgPicture.asset("assets/icon/Search.svg"),
            ),
          ),
        ),
      ),
    );
  }
}
