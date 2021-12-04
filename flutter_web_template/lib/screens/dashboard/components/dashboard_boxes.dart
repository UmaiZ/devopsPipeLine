import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_web_template/const.dart';

import '../../../responsive.dart';

class DashboardBoxes extends StatelessWidget {
  const DashboardBoxes({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Size _size = MediaQuery.of(context).size;
    return Column(
      children: [
        // Row(
        //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //   children: [
        //     Text(
        //       "My Files",
        //       style: Theme.of(context).textTheme.subtitle1,
        //     ),
        //     ElevatedButton.icon(
        //       style: TextButton.styleFrom(
        //         padding: EdgeInsets.symmetric(
        //           horizontal: defaultPadding * 1.5,
        //           vertical:
        //               defaultPadding / (Responsive.isMobile(context) ? 2 : 1),
        //         ),
        //       ),
        //       onPressed: () {},
        //       icon: Icon(Icons.add),
        //       label: Text("Add New"),
        //     ),
        //   ],
        // ),
        SizedBox(height: defaultPadding),
        Responsive(
          mobile: FileInfoCardGridView(
            crossAxisCount: _size.width < 650 ? 2 : 4,
            childAspectRatio: _size.width < 650 ? 1.3 : 1,
          ),
          tablet: FileInfoCardGridView(),
          desktop: FileInfoCardGridView(
            childAspectRatio: _size.width < 1400 ? 1.1 : 1.4,
          ),
        ),
      ],
    );
  }
}

class FileInfoCardGridView extends StatelessWidget {
  const FileInfoCardGridView({
    Key? key,
    this.crossAxisCount = 4,
    this.childAspectRatio = 2,
  }) : super(key: key);

  final int crossAxisCount;
  final double childAspectRatio;


  @override
  Widget build(BuildContext context) {
      print('childAspectRatio ${childAspectRatio}');

    return GridView.builder(
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: 4,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: defaultPadding,
        mainAxisSpacing: defaultPadding,
        childAspectRatio: childAspectRatio,
      ),
      itemBuilder: (context, index) => Container(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white
          ),
          height: 50,
          width: 100,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 85.0,
                width: 85.0,
                decoration: const BoxDecoration(
                  color: kSecondaryColor,
                  borderRadius: BorderRadius.all(Radius.circular(50)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SvgPicture.asset(
                    "assets/icon/dashboard_1_icon  .svg",
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('75',  style: Theme.of(context).textTheme.headline1,),
                  Text('Total Orders', style: Theme.of(context).textTheme.bodyText1,)
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
