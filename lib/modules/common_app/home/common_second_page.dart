import 'dart:math';
import 'package:flutter/material.dart';

import 'common_mask_text_page.dart';
import 'common_rich_text_page.dart';
import 'image_page.dart';

class CommonSecondPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _CommonSecondState();
  }
}

class _CommonSecondState extends State<CommonSecondPage> {
  List<Color> colors = <Color>[];
  int crossAxisCount = 2;
  double crossAxisSpacing = 15.0;
  double mainAxisSpacing = 15.0;
  TextDirection textDirection = TextDirection.ltr;
  int length = 10;
  ScrollController controller = ScrollController();

  List cards = [
    {
      "title":"富文本",
      "page":CommonRichTextPage(),
    },
    {
      "title":"Masked Text",
      "page":CommonMaskTextPage(),
    },
    {
      "title":"图片缓存加载",
      "page":CommonImagePage(),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: const Text('RandomSized'),
      ),
      body: Directionality(
        textDirection: textDirection,
        child: Container(),
//        child: WaterfallFlow.builder(
//          //cacheExtent: 0.0,
//          //reverse: true,
//          padding: const EdgeInsets.all(10.0),
//          gridDelegate: SliverWaterfallFlowDelegateWithFixedCrossAxisCount(
//            crossAxisCount: crossAxisCount,
//            crossAxisSpacing: crossAxisSpacing,
//            mainAxisSpacing: mainAxisSpacing,
//          ),
//          itemBuilder: (BuildContext c, int index) {
//            final Color color = getRandomColor(index);
//            Map map = cards[index];
//            return InkWell(
//              child: Container(
//                decoration: BoxDecoration(
//                    border: Border.all(color: Colors.black),
//                    color: getRandomColor(index)),
//                alignment: Alignment.center,
//                child: Text(
//                  map["title"],
//                  style: TextStyle(
//                      color: color.computeLuminance() < 0.5
//                          ? Colors.white
//                          : Colors.black),
//                ),
//                //height: ((index % 3) + 1) * 100.0,
//              ),
//              onTap: (){
//                Navigator.push(context, MaterialPageRoute(builder: (BuildContext context){
//                  return map["page"];
//                }));
//              },
//            );
//          },
//          //itemCount: 19,
//          itemCount: cards.length,
//        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            // if (textDirection == TextDirection.ltr) {
            //   textDirection = TextDirection.rtl;
            // } else {
            //   textDirection = TextDirection.ltr;
            // }
            //length=0;
            crossAxisCount++;
            //mainAxisSpacing += 5.0;
            //crossAxisSpacing+=5.0;
          });
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Color getRandomColor(int index) {
    if (index >= colors.length) {
      colors.add(Color.fromARGB(255, Random.secure().nextInt(255),
          Random.secure().nextInt(255), Random.secure().nextInt(255)));
    }

    return colors[index];
  }
}
