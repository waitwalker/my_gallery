import 'package:my_gallery/modules/widgets/style/style.dart';
import 'package:flutter/material.dart';


class AITestBackDialog extends StatelessWidget {
  final void Function(int index)? tapCallBack;

  AITestBackDialog({this.tapCallBack});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Container(
          height: 272,
          width: MediaQuery.of(context).size.width - 76,
          decoration: _boxDecoration(),
          child: Column(
            children: <Widget>[
              Container(
                height: 150,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10)),
                  image: DecorationImage(image: AssetImage("static/images/ai_test_back_top.png"), fit: BoxFit.fill),
                  color: Colors.red
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 19),
                child: Text(
                  "要退出答题了吗？",
                  style: TextStyle(
                      fontSize: 14,
                      color: Color(0xff4F5962)),
                ),
              ),

              Padding(padding: EdgeInsets.only(top: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    InkWell(
                      child: Container(
                        alignment: Alignment.center,
                        height: 44,
                        width: 120,
                        decoration: BoxDecoration(
                          color: Color(MyColors.white),
                          border: Border.all(color: Color(0xffDCDCDC), width: 1.0),
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
                        child: Text("去意已决",style: TextStyle(fontSize: 16, color: Color(0xff4F5962)),),
                      ),
                      onTap: (){
                        tapCallBack!(0);
                      },
                    ),
                    Padding(padding: EdgeInsets.only(left: 10),),
                    InkWell(
                      child: Container(
                        alignment: Alignment.center,
                        height: 44,
                        width: 120,
                        decoration: BoxDecoration(
                          color: Color(MyColors.white),
                          gradient: LinearGradient(
                            colors: [
                              Color(0xff5EB3F9),
                              Color(0xff6BC4FA)
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
                        child: Text("继续练习",style: TextStyle(fontSize: 16, color: Colors.white),),
                      ),
                      onTap: (){
                        tapCallBack!(1);
                      },
                    ),
                  ],
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }

  BoxDecoration _boxDecoration() {
    return BoxDecoration(
      color: Color(MyColors.white),
      borderRadius: BorderRadius.all(
        Radius.circular(10),
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
