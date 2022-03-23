import 'package:flutter/material.dart';



class CommonRichTextPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _CommonRichTextState();
  }
}

class _CommonRichTextState extends State<CommonRichTextPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("富文本"),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[

          InkWell(
            child: Text("Easy Rich Text", style: TextStyle(fontSize: 20),),
            onTap: (){
              Navigator.push(context, MaterialPageRoute(builder: (context){
                return CommonEasyRichPage();
              }));
            },
          ),

          Padding(padding: EdgeInsets.only(top: 30)),

//          InkWell(
//            child: Text("Super Rich Text", style: TextStyle(fontSize: 20),),
//            onTap: (){
//              Navigator.push(context, MaterialPageRoute(builder: (context){
//                return CommonSuperRichTextPage();
//              }));
//            },
//          ),

        ],
      ),
    );
  }
}

// ignore: must_be_immutable
class CommonEasyRichPage extends StatelessWidget {
  String str1 = "This is a EasyRichText example. I want blue font. I want bold font. I want italic font. ";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("富文本"),
      ),
      body: Column(
        children: <Widget>[

//          EasyRichText(
//            str1,
//            patternList: [
//              EasyRichTextPattern(
//                targetString: 'blue',
//                style: TextStyle(color: Colors.blue),
//              ),
//              EasyRichTextPattern(
//                targetString: 'bold',
//                style: TextStyle(fontWeight: FontWeight.bold),
//              ),
//              EasyRichTextPattern(
//                targetString: 'italic',
//                style: TextStyle(fontStyle: FontStyle.italic),
//              ),
//            ],
//          ),
        ],
      ),
    );
  }
}