import 'package:my_gallery/modules/widgets/style/style.dart';
import 'package:flutter/material.dart';


class AITestDialog extends StatelessWidget {
  final void Function(int index)? tapCallBack;

  AITestDialog({this.tapCallBack});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Container(
          height: 400,
          width: MediaQuery.of(context).size.width - 76,
          decoration: _boxDecoration(),
          child: Column(
            children: <Widget>[
              Expanded(child: ListView(
                children: [
                  Padding(padding: EdgeInsets.only(top: 24),),
                  Container(
                    height: 72,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    child: OutlineButton(
                      borderSide: BorderSide(color: Color(0xfff8fafe), width: 2.0),
                      disabledBorderColor: Colors.white,
                      highlightedBorderColor: Color(0xff4ad880),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      child: Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(image: AssetImage("static/images/ai_test_dialog_level_1.png")),
                        ),
                      ),
                      onPressed: (){
                        tapCallBack!(0);
                      },
                    ),
                  ),

                  Container(
                    height: 72,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    child: OutlineButton(
                      borderSide: BorderSide(color: Color(0xfff8fafe), width: 2.0),
                      disabledBorderColor: Colors.white,
                      highlightedBorderColor: Color(0xff4ad880),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      child: Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(image: AssetImage("static/images/ai_test_dialog_level_2.png")),
                        ),
                      ),
                      onPressed: (){
                        tapCallBack!(1);
                      },
                    ),
                  ),

                  Container(
                    height: 72,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    child: OutlineButton(
                      borderSide: BorderSide(color: Color(0xfff8fafe), width: 2.0),
                      disabledBorderColor: Colors.white,
                      highlightedBorderColor: Color(0xff4ad880),
                      child: Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(image: AssetImage("static/images/ai_test_dialog_level_3.png")),
                        ),
                      ),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      onPressed: (){
                        tapCallBack!(2);
                      },
                    ),
                  ),

                  Padding(padding: EdgeInsets.only(left: 40, right: 40, top: 30), child: InkWell(
                    child: Container(
                      alignment: Alignment.center,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Color(MyColors.white),
                        gradient: LinearGradient(
                          colors: [
                            Color(0xff80c3f5),
                            Color(0xff73b2f3)
                          ],
                        ),
                        borderRadius:
                        BorderRadius.all(Radius.circular(20.0)), //设置圆角
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                              color: Color(0x466A99FF),
                              offset: Offset(0, 1),
                              blurRadius: 11.0,
                              spreadRadius: 2.0)
                        ],
                      ),
                      child: Text("开始答题",style: TextStyle(fontSize: 16, color: Colors.white),),
                    ),
                    onTap: (){
                      tapCallBack!(3);
                    },
                  ),),

                  Padding(padding: EdgeInsets.only(left: 40, right: 40, top: 15), child: InkWell(
                    child: Container(
                      alignment: Alignment.center,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Color(MyColors.white),
                        gradient: LinearGradient(
                          colors: [
                            Color(0xfff8d368),
                            Color(0xfff4c261)
                          ],
                        ),
                        borderRadius:
                        BorderRadius.all(Radius.circular(20.0)), //设置圆角
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                              color: Color(0x466A99FF),
                              offset: Offset(0, 1),
                              blurRadius: 11.0,
                              spreadRadius: 2.0)
                        ],
                      ),
                      child: Text("先学习 再答题",style: TextStyle(fontSize: 16, color: Colors.white),),
                    ),
                    onTap: (){
                      tapCallBack!(4);
                    },
                  ),),

                ],
              ),),
            ],
          ),
        ),
      ),
    );
  }

  BoxDecoration _boxDecoration() {
    return BoxDecoration(
      color:Color(MyColors.white),
      borderRadius: BorderRadius.all(
        Radius.circular(6),
      ),
      boxShadow: [
        BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.26),
            offset: Offset(0, 1),
            blurRadius: 11.0,
            spreadRadius: 2.0)
      ],
    );
  }
}
