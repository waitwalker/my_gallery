import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:my_gallery/common/dao/manager/dao_manager.dart';
import 'package:my_gallery/common/network/error_code.dart';
import 'package:my_gallery/common/network/response.dart';
import 'package:my_gallery/common/singleton/singleton_manager.dart';
import 'package:my_gallery/event/http_error_event.dart';
import 'package:my_gallery/modules/widgets/button/wrapped_button.dart';
import 'package:my_gallery/modules/widgets/empty_placeholder/empty_placeholder_widget.dart';
import 'package:my_gallery/modules/widgets/loading/list_type_loading_placehold_widget.dart';
import 'package:async/async.dart';
import 'activated_card_model.dart';

class DegradePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _DegradeState();
  }
}


class _DegradeState extends State<DegradePage> {

  int currentSemester = 1;
  int currentType = 5;
  String currentYear = "2020-2021";
  List<Data>? dataSource = [];
  late AsyncMemoizer memoizer;
  AppBar? appBar;

  @override
  void initState() {
    memoizer = AsyncMemoizer();
    /// event 监听事件
    ErrorCode.eventBus.on<dynamic>().listen((event) {
      if (event is HttpErrorEvent) {
        HttpErrorEvent errorEvent = event;
        if (errorEvent.message == "可以刷新了" && errorEvent.code == 200) {
          Future.delayed(Duration(seconds: 2),(){
            setState(() {
              memoizer = AsyncMemoizer();
              if (this.mounted) {
                setState(() {});
              }
            });
          });
        }
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    appBar = AppBar(
      backgroundColor: Colors.white,
      title: Text("设置年级"),
    );
    return Scaffold(
      appBar: appBar,
      backgroundColor: Colors.white,
      body: Column(
        children: <Widget>[
          _buildBodyFuture(),
        ],
      ),
    );
  }


  ///
  /// @description 构建body widget
  /// @param
  /// @return
  /// @author waitwalker
  /// @time 12/3/20 9:39 AM
  ///
  Widget _buildBodyFuture() {
    return FutureBuilder(
      builder: _futureBuilder,
      future: _realQuestionFetchData(2, 6, currentSemester, currentType, currentYear),
    );
  }

  ///
  /// @description 获取数据
  /// @param
  /// @return
  /// @author waitwalker
  /// @time 12/3/20 9:47 AM
  ///
  _realQuestionFetchData(subjectId, gradeId, semester, type, year) =>
      memoizer.runOnce(() => _fetchData(subjectId, gradeId, semester, type, year));

  ///
  /// @description 获取教材版本&列表数据
  /// @param
  /// @return
  /// @author waitwalker
  /// @time 12/3/20 9:44 AM
  ///
  _fetchData(subjectId, gradeId, semester, type, year) async {
    return DaoManager.fetchActivatedCardData(subjectId, gradeId, semester, type, year);
  }


  ///
  /// @description 刷新方法添加
  /// @param
  /// @return
  /// @author waitwalker
  /// @time 2020/11/5 3:10 PM
  ///
  Future<Null> _realQuestionOnRefresh() async{
    memoizer = AsyncMemoizer();
    if (this.mounted) {
      setState(() {});
    }
  }

  ///
  /// @description 根据future响应构建widget
  /// @param
  /// @return
  /// @author waitwalker
  /// @time 12/3/20 9:40 AM
  ///
  Widget _futureBuilder(BuildContext context, AsyncSnapshot snapshot) {
    switch (snapshot.connectionState) {
      case ConnectionState.none:
        return Text('还没有开始网络请求');
      case ConnectionState.active:
        return Text('ConnectionState.active');
      case ConnectionState.waiting:
        return Center(
          child: LoadingListWidget(),
        );
      case ConnectionState.done:
        if (snapshot.hasError) {
          return _placeholderPage();
        }
        var res = snapshot.data;
        ResponseData? responseData = res as ResponseData?;
        if (res != null && responseData!.result) {
          ActivatedCardModel realQuestionModel = responseData.model as ActivatedCardModel;
          if (realQuestionModel.data != null && realQuestionModel.data!.length > 0) {
            dataSource = realQuestionModel.data;
            return _realQuestionBuildList(realQuestionModel.data);
          } else {
            return _placeholderPage();
          }
        } else {
          return _placeholderPage();
        }
        return _placeholderPage();
      default:
        return _placeholderPage();
    }
  }

  ///
  /// @description 没有数据占位页
  /// @param
  /// @return
  /// @author waitwalker
  /// @time 4/7/21 2:52 PM
  ///
  _placeholderPage() {
    return EmptyPlaceholderPage(assetsPath: 'static/images/no_data_placeholder.png', message: '当前没有数据', fontSize: 15,);
  }

  ///
  /// @description 构建列表
  /// @param
  /// @return
  /// @author waitwalker
  /// @time 12/3/20 9:40 AM
  ///
  Widget _realQuestionBuildList(List<Data>? data) {
    double statusBarHeight = MediaQuery.of(context).padding.top;
    double appBarHeight = appBar!.preferredSize.height;
    return (data != null && data.isNotEmpty) ?
    /// 数据不为空 展示列表页
    Container(
      height: MediaQuery.of(context).size.height - appBarHeight - statusBarHeight,
      child: Column(
        children: [
          Expanded(
            child: EasyRefresh(
              child: ListView.separated(
                separatorBuilder: (BuildContext context, int index) =>
                    Divider(color: Colors.transparent, height: 0),
                itemBuilder: _itemBuilder,
                itemCount: data.length + 1,
              ),
              firstRefresh: false,
              onRefresh: _realQuestionOnRefresh,
              header: ClassicalHeader(
                textColor: Color(0xff2E96FF),
                infoColor: Color(0xff2E96FF),
                refreshText: "下拉刷新",
                refreshingText: "正在刷新...",
                refreshedText: "刷新完成",
                refreshFailedText: "刷新失败",
                refreshReadyText: "松手刷新",
                noMoreText: "没有更多",
                infoText: "加载时间${DateTime.now().hour}:${DateTime.now().minute > 9 ? DateTime.now().minute :"0" + "${DateTime.now().minute}" }",
              ),
              onLoad: null,
            ),
          )
        ],
      ),
    ) :
    /// 数据为空 展示占位页
    EmptyPlaceholderPage(assetsPath: 'static/images/empty.png', message: '没有数据');
  }

  ///
  /// @description 卡片地址
  /// @param
  /// @return
  /// @author waitwalker
  /// @time 3/30/21 3:50 PM
  ///
  Widget _itemBuilder(BuildContext context, int index){
    if (index == 0) {
      return Padding(padding: EdgeInsets.only(top: 12, bottom: 12),
        child: InkWell(
          onTap: (){
          },
          child: Padding(
            padding: EdgeInsets.only(left: 16, right: 16),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                      color: Color(0x99B2C1D9),
                      offset: Offset(0, 2.5),
                      blurRadius: 10.0,
                      spreadRadius: 0),
                ],
              ),
              child: Column(
                children: [
                  Padding(padding: EdgeInsets.only(top: 12),),
                  Padding(padding: EdgeInsets.only(left: 10, right: 10),
                    child: Text("每年7月15--8月15日,可以有一次调整卡对应年级的机会.\n"
                        "点击降级,可以将对应的卡,降低一个年级.仅支持降级操作.", style: TextStyle(fontSize: 15, color: Colors.black),),
                  ),
                  Padding(padding: EdgeInsets.only(left: 10, right: 10),
                    child: Row(
                      children: [
                        Text("注意事项：", style: TextStyle(fontSize: 16, color: Colors.redAccent, fontWeight: FontWeight.w400),),
                      ],
                    ),
                  ),
                  Padding(padding: EdgeInsets.only(left: 10, right: 10),
                    child: Text(
                        "1.仅可修改一次,请谨慎修改.且只能降级操作.\n"
                        "2.仅在7月15--8月15日时间范围内可以改.\n"
                        "3.超过上述时间范围,或者已经修改过一次,请联系客服老师.\n", style: TextStyle(fontSize: 15, color: Colors.black),),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    } else {
      Data currentData = dataSource![index - 1];
      return Padding(padding: EdgeInsets.only(bottom: 12,),
        child: InkWell(
          onTap: (){
          },
          child: Padding(
            padding: EdgeInsets.only(left: 16, right: 16),
            child: Container(
              height: 127,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                      color: Color(0x99B2C1D9),
                      offset: Offset(0, 2.5),
                      blurRadius: 10.0,
                      spreadRadius: 0),
                ],
              ),
              child: Column(
                children: [
                  Padding(padding: EdgeInsets.only(top: 12),),
                  Padding(padding: EdgeInsets.only(left: 20, right: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("名称: ${currentData.courseCardName}", style: TextStyle(fontSize: 18, color: Colors.black, fontWeight: FontWeight.w400),),
                    ],),
                  ),
                  Padding(padding: EdgeInsets.only(left: 20, top: 5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("有效期至: ${currentData.endTime}", style: TextStyle(fontSize: 13, color: Colors.black),),
                      ],),
                  ),

                  Padding(padding: EdgeInsets.only(top: 20),),
                  Padding(padding: EdgeInsets.only(left: 20, right: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(currentData.courseName!, style: TextStyle(fontSize: 16, color: Colors.redAccent, fontWeight: FontWeight.w400),),
                        WrappedButton(
                          height: 30,
                          width: 110,
                          child: Text("降级", style: TextStyle(color: Colors.white),),
                          decoration: BoxDecoration(
                            color: currentData.isModify == 1 && currentData.gradeId != 6 ? Color(0xff2E96FF) : Colors.grey,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          circular: 6,
                          onPressed: currentData.isModify == 1 && currentData.gradeId != 6 ? (){
                            _showDegradeAlert(context, currentData);
                          } : null,
                        ),
                      ],),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
  }


  ///
  /// @description 显示将年级弹框
  /// @param
  /// @return
  /// @author waitwalker
  /// @time 2021/6/25 09:25
  ///
  _showDegradeAlert(BuildContext context, Data currentData) {
    bool isPad = SingletonManager.sharedInstance!.isPadDevice;
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(padding: EdgeInsets.only(left: isPad ? 100 : 20, right: isPad ? 100 : 20), child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                        color: Color(0x66B2C1D9),
                        offset: Offset(3, 4),
                        blurRadius: 10.0,
                        spreadRadius: 2.0)
                  ],
                ),
                height: Platform.isAndroid ? 140 : 135,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(padding: EdgeInsets.only(left: 10, right: 10),
                      child: Text("确认将当前 ${currentData.gradeName} 降级？请谨慎修改。", style: TextStyle(fontSize: 16, color: Colors.black, fontWeight: FontWeight.w700),),
                    ),
                    Padding(padding: EdgeInsets.only(left: 20, right: 20, top: 40),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          WrappedButton(
                            height: 30,
                            width: 110,
                            child: Text("取消", style: TextStyle(color: Colors.white),),
                            decoration: BoxDecoration(
                              color: Color(0xff2E96FF),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            circular: 6,
                            onPressed: () async{
                              Navigator.pop(context);
                            },
                          ),

                          Padding(padding: EdgeInsets.only(left: 50)),

                          WrappedButton(
                            height: 30,
                            width: 110,
                            child: Text("降级", style: TextStyle(color: Colors.white),),
                            decoration: BoxDecoration(
                              color: Color(0xff2E96FF),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            circular: 6,
                            onPressed: () async {
                              Navigator.pop(context);
                              ResponseData response = await DaoManager.fetchDegradedData(
                                currentData.realCardId,
                                currentData.gradeId,
                                currentData.subjectId,
                                currentData.ref,
                                1,
                                currentData.cardId,
                              );
                              ErrorCode.errorHandleFunction(ErrorCode.SUCCESS, '可以刷新了', false);
                              int? code  = response.data["code"];
                              if (code == -1090040001) {
                                Fluttertoast.showToast(
                                  msg: "1. 当前用户已经存在该年级学科的卡，无法重复建卡。\n"
                                      "2. 当前卡中不存在该年级对应的课程，无法切换年级。\n"
                                      "3. 如有其它情况，请联系客服老师解决。",
                                  gravity: ToastGravity.CENTER,
                                  toastLength: Toast.LENGTH_LONG,
                                );
                              } else if (code == 1){
                                Fluttertoast.showToast(msg: "降级成功,请刷新列表查看!",gravity: ToastGravity.CENTER,);
                              }
                            },
                          ),
                        ],),
                    ),
                  ],
                ),
              ),),

            ],
          );
        });
  }
}

