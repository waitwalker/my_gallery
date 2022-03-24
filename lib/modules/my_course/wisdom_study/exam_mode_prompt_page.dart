import 'package:my_gallery/common/singleton/singleton_manager.dart';
import 'package:my_gallery/model/wisdom_model.dart';
import 'package:my_gallery/modules/my_course/wisdom_study/exam_mode_page.dart';
import 'package:my_gallery/modules/widgets/style/style.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

///
/// @name ExamModePromptPage
/// @description 考试模式 三步走页面
/// @author waitwalker
/// @date 2020-02-18
///
// ignore: must_be_immutable
class ExamModePromptPage extends StatefulWidget {
  ResourceIdListEntity data;
  var courseCardCourseId;
  final String title;

  ExamModePromptPage(this.data, this.courseCardCourseId,this.title);
  @override
  State<StatefulWidget> createState() {
    return _ExamModePromptState();
  }
}

class _ExamModePromptState extends State<ExamModePromptPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Expanded(child: ListView(
            children: <Widget>[
              /// 三步走
              Padding(padding: EdgeInsets.only(top: 41)),

              Center(
                child: Container(
                  child: Wrap(
                    children: <Widget>[
                      Image.asset('static/images/exam_prompt_top.png',width: 194,height: 40,fit: BoxFit.fill,),
                    ],
                  ),
                ),
              ),

              /// 下载试卷并打印
              Padding(padding: EdgeInsets.only(top: 47)),
              Padding(padding: EdgeInsets.only(left: 25,right: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          child: Wrap(
                            children: <Widget>[
                              Text('Step 01', style: TextStyle(color: Color(0xd16B8DFF),fontSize: SingletonManager.sharedInstance!.screenWidth > 500.0 ? 16 : 12,fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ),
                        Padding(padding: EdgeInsets.only(top: 5)),
                        Container(
                          child: Wrap(
                            children: <Widget>[
                              Text('下载试卷并打印', style: TextStyle(color: Color(0xff5179FF),fontSize: SingletonManager.sharedInstance!.screenWidth > 500.0 ? 18 : 14,fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ),
                        Padding(padding: EdgeInsets.only(top: 15)),

                        SizedBox(
                          height: 32,
                          width: SingletonManager.sharedInstance!.screenWidth > 500.0 ? 130 : 115,
                          child: ElevatedButton(
                            style: ButtonStyle(
                              shape: ButtonStyleButton.allOrNull<RoundedRectangleBorder>(RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4.0)))),
                              backgroundColor: MaterialStateProperty.resolveWith<Color?>(
                                    (Set<MaterialState> states) {
                                  if (states.contains(MaterialState.pressed))
                                    return Color(0xff6B8DFF);
                                  else if (states.contains(MaterialState.disabled))
                                    return Color(MyColors.ccc);
                                  return null; // Use the component's default.
                                },
                              ),
                            ),
                            child: Text(
                              '下载试卷打印',
                              style: TextStyle(
                                fontSize: SingletonManager.sharedInstance!.screenWidth > 500.0 ? 15 : 12,
                                color: Colors.white,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                            onPressed: (){
                              Fluttertoast.showToast(msg: "下载试卷");
                            },
                          ),
                        ),
                      ],
                    ),
                    Image.asset('static/images/exam_prompt_1.png', width: 144, height: 144),
                  ],
                ),
              ),

              /// 开始考试
              Padding(padding: EdgeInsets.only(top: 3)),
              Padding(padding: EdgeInsets.only(left: 20,right: 25),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Image.asset('static/images/exam_prompt_2.png', width: 144, height: 144),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          child: Wrap(
                            children: <Widget>[
                              Text('Step 02', style: TextStyle(color: Color(0xd16B8DFF),fontSize: SingletonManager.sharedInstance!.screenWidth > 500.0 ? 16 : 12,fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ),
                        Padding(padding: EdgeInsets.only(top: 5)),
                        Container(
                          child: Wrap(
                            children: <Widget>[
                              Text('点击开始考试，开始做\n打印的试卷', style: TextStyle(color: Color(0xff5179FF),fontSize: SingletonManager.sharedInstance!.screenWidth > 500.0 ? 18 : 14,fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ),
                        Padding(padding: EdgeInsets.only(top: 15)),

                        SizedBox(
                          height: 32,
                          width: 115,
                          child: ElevatedButton(
                            style: ButtonStyle(
                              shape: ButtonStyleButton.allOrNull<RoundedRectangleBorder>(RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4.0)))),
                              backgroundColor: MaterialStateProperty.resolveWith<Color?>(
                                    (Set<MaterialState> states) {
                                  if (states.contains(MaterialState.pressed))
                                    return Color(0xff6B8DFF);
                                  else if (states.contains(MaterialState.disabled))
                                    return Color(MyColors.ccc);
                                  return null; // Use the component's default.
                                },
                              ),
                            ),
                            child: Text(
                              '开始考试',
                              style: TextStyle(
                                fontSize: SingletonManager.sharedInstance!.screenWidth > 500.0 ? 15 : 12,
                                color: Colors.white,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context){
                                return ExamModePage(widget.data,widget.courseCardCourseId);
                              }));
                            },
                          ),
                        ),
                      ],
                    ),

                  ],
                ),
              ),

              /// 点击结束提交答案
              Padding(padding: EdgeInsets.only(top: 44)),
              Padding(padding: EdgeInsets.only(left: 20,right: 25),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          child: Wrap(
                            children: <Widget>[
                              Text('Step 03', style: TextStyle(color: Color(0xd16B8DFF),fontSize: SingletonManager.sharedInstance!.screenWidth > 500.0 ? 16 : 12,fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ),
                        Padding(padding: EdgeInsets.only(top: 5)),
                        Container(
                          child: Wrap(
                            children: <Widget>[
                              Text('点击结束答题，提交答案', style: TextStyle(color: Color(0xff5179FF),fontSize: SingletonManager.sharedInstance!.screenWidth > 500.0 ? 18 : 14,fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ),
                        Padding(padding: EdgeInsets.only(top: 11,),),

                        SizedBox(
                          height: SingletonManager.sharedInstance!.screenWidth > 500.0 ? 160 : 129,
                          width: MediaQuery.of(context).size.width - 22 - 25,
                          child: Image.asset('static/images/exam_prompt_3.png',fit: BoxFit.fill,),
                        ),

                      ],
                    ),

                  ],
                ),
              ),
              Padding(padding: EdgeInsets.only(top: 44)),
            ],
          )),
        ],
      ),
    );
  }
}