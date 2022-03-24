import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:my_gallery/common/const/api_const.dart';
import 'package:my_gallery/common/dao/manager/dao_manager.dart';
import 'package:my_gallery/common/dao/original_dao/course_dao_manager.dart';
import 'package:my_gallery/common/network/network_manager.dart';
import 'package:my_gallery/common/network/response.dart';
import 'package:my_gallery/common/singleton/singleton_manager.dart';
import 'package:my_gallery/common/tools/date/eye_protection_timer.dart';
import 'package:my_gallery/model/micro_course_resource_model.dart';
import 'package:my_gallery/model/wisdom_model.dart';
import 'package:my_gallery/modules/my_course/wisdom_study/hd_video_page.dart';
import 'package:my_gallery/modules/my_course/wisdom_study/micro_course_page.dart';
import 'package:my_gallery/modules/my_course/wisdom_study/test_paper_page.dart';
import 'package:my_gallery/modules/my_course/wisdom_study/video_play_widget.dart';
import 'package:my_gallery/modules/my_plan/my_plan_model.dart';
import 'package:my_gallery/modules/widgets/webviews/common_webview_page.dart';
import 'package:my_gallery/modules/widgets/empty_placeholder/empty_placeholder_widget.dart';
import 'package:my_gallery/modules/widgets/pdf/pdf_page.dart';
import 'package:flutter/material.dart';
import 'package:gzx_dropdown_menu/gzx_dropdown_menu.dart';

///
/// @description 全时自习室页面
/// @author waitwalker
/// @time 11/19/20 10:21 AM
///
class MyPlanPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MyPlanState();
  }
}

class _MyPlanState extends State<MyPlanPage> with AutomaticKeepAliveClientMixin{

  @override
  bool get wantKeepAlive => true;

  bool _isLoading = true;

  List<String?> _dropDownHeaderItemStrings = [];
  var _scaffoldKey = new GlobalKey<ScaffoldState>();
  GlobalKey _stackKey = GlobalKey();
  List<Data> _subjectsSortConditions = [];
  List<Plans>? _plansSortConditions = [];
  late Data _selectSubjectSortCondition;
  Plans? _selectPlanSortCondition;
  GZXDropdownMenuController _dropdownMenuController = GZXDropdownMenuController();
  String _dropdownMenuChange = '';

  /// 是否是高中
  bool isSenior = (SingletonManager.sharedInstance!.userData!.gradeId! > 0 &&
      SingletonManager.sharedInstance!.userData!.gradeId! <= 3) ? true : false;
  /// group id 客服id
  int? currentGroupId = 0;
  /// 是否点击了要咨询的学科
  bool isTappedSubject = false;

  /// 客服组数据
  List<Map<String, dynamic>> staffSections = [];

  /// 悬浮按钮  暂时未启用
  // static OverlayEntry _overlayEntry;

  /// 调用七鱼channel
  MethodChannel channel = const MethodChannel("com.etiantian/im_service");

  // 是否有错误
  bool hasError = false;
  // 是否有数据
  bool hasData = false;

  /// 是否正在显示
  bool isCurrentShowing = false;
  
  /// 是否正在隐藏
  bool isHiding = false;

  /// 上次点击的导航栏学科索引
  int lastIndex = 0;
  /// 上次点击的导航栏学科id
  int? lastSubjectId = 0;
  /// 总共学科数量
  int totalSubjects = 0;

  // 资源类型
  Map<dynamic,Map<String, String>> resourceMap = {
    1:{
      "resourceType": "高清",
      "imagePath": "static/images/hd_video_icon.png",},
    2:{
      "resourceType": "微课",
      "imagePath": "static/images/micro_video_icon.png",},
    3:{
      "resourceType": "练习",
      "imagePath": "static/images/practice_icon.png",},
    4:{
      "resourceType": "导学",
      "imagePath": "static/images/guide_icon.png",},
    5:{
      "resourceType": "直播",
      "imagePath": "static/images/live_icon.png",},
    6:{
      "resourceType": "试卷",
      "imagePath": "static/images/test_paper_icon.png",},
  };

  @override
  void initState() {
    var currentTime = DateTime.now().millisecondsSinceEpoch;
    var shouldAlertBeginTime = 1626296400000;

    var shouldAlertEndTime = 1629043200000;
    // 时间大于7月15号05点,小于8月15日24时入口显示,并且首页弹框允许弹
    // 调试时间11:15--11:45
    if (currentTime >= shouldAlertBeginTime && currentTime < shouldAlertEndTime) {
      SingletonManager.sharedInstance!.shouldShowDegradeEntrance = true;
    } else {
      SingletonManager.sharedInstance!.shouldShowDegradeEntrance = false;
    }
    /// 全局悬浮按钮
    // Future.delayed(Duration(seconds: 1),(){
    //   _overlayEntry?.remove();
    //   _overlayEntry = null;
    //   _overlayEntry = OverlayEntry(builder: (context) {
    //     return AppFloatBox();
    //   });
    //   Overlay.of(context).insert(_overlayEntry);
    // });

    _fetchMyPlanData();
    super.initState();
  }

  ///
  /// @description 获取数据
  /// @param
  /// @return
  /// @author waitwalker
  /// @time 2020/11/6 11:13 AM
  ///
  _fetchMyPlanData() async{
    ResponseData responseData = await DaoManager.fetchMyPlanData({});
    if (responseData.code == 200) {
      MyPlanModel? myPlanModel = responseData.model;
      if (myPlanModel != null && myPlanModel.code! > 0) {
        if (myPlanModel.data != null) {
          totalSubjects = myPlanModel.data!.length;
          _selectSubjectSortCondition = myPlanModel.data![0];
          _selectSubjectSortCondition.isSelected = true;
          _selectPlanSortCondition = myPlanModel.data![0].plans![0];
          _selectPlanSortCondition!.isSelected = true;
          _dropDownHeaderItemStrings.add(_selectSubjectSortCondition.subjectName);
          _dropDownHeaderItemStrings.add(_selectPlanSortCondition!.planName);
          _subjectsSortConditions.addAll(myPlanModel.data!);
          _plansSortConditions!.addAll(myPlanModel.data![0].plans!);
          _isLoading = false;
          hasError = false;
          hasData = true;
          setState(() {

          });
        } else {
          _isLoading = false;
          hasError = false;
          hasData = false;
          setState(() {

          });
        }
      } else {
        _isLoading = false;
        hasError = true;
        hasData = false;
        setState(() {

        });
      }
    } else {
      _isLoading = false;
      hasError = true;
      hasData = false;
      setState(() {

      });
    }
  }

  @override
  // ignore: must_call_super
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text("全时自习室"),
          elevation: 1,
          backgroundColor: Colors.white,
        ),
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator(),),
      );
    } else {
      /// 没有错误 && 有数据
      if (!hasError && hasData) {
        return Scaffold(
          key: _scaffoldKey,
          appBar: AppBar(
            backgroundColor: Color(0xff538AF1),
            elevation: 0,
            actions: [
              Padding(
                padding: EdgeInsets.only(left: 16,),
                child: Container(
                  alignment: Alignment.center,
                  width: MediaQuery.of(context).size.width - 16 - 10 - 18 - 5 - 30 - 16,
                  child: _buildSubjectList(_subjectsSortConditions, (value){
                    _selectSubjectSortCondition = value;
                    _selectPlanSortCondition!.isSelected = false;
                    _plansSortConditions = _selectSubjectSortCondition.plans;
                    _selectPlanSortCondition = _plansSortConditions![0];
                    _selectPlanSortCondition!.isSelected = true;
                    _dropDownHeaderItemStrings[1] = _selectPlanSortCondition!.planName;
                    if (isCurrentShowing) {
                      _dropdownMenuController.hide();
                    }
                    setState(() {});
                  }),
                ),
              ),
              
              Padding(padding: EdgeInsets.only(left: 10, right: 16, bottom: 6),
                child: InkWell(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Image.asset("static/images/plan_answer_question_icon.png", fit: BoxFit.fill, width: 18, height: 18,),
                      Padding(padding: EdgeInsets.only(left: 5)),
                      Text("答疑", style: TextStyle(fontSize: 14, color: Colors.white),),
                    ],
                  ),
                  onTap: (){
                    staffSections = (SingletonManager.sharedInstance!.userData!.gradeId! > 0 &&
                        SingletonManager.sharedInstance!.userData!.gradeId! <= 3)  ?
                    [
                      {
                        "isSelected":false,
                        "name": "化学",
                        "groupId": 480549904,
                      },
                      {
                        "isSelected":false,
                        "name": "数学",
                        "groupId": 480543254,
                      },
                      {
                        "isSelected":false,
                        "name": "物理",
                        "groupId": 480547027,
                      },
                      {
                        "isSelected":false,
                        "name": "英语",
                        "groupId": 480547867,
                      },
                    ] :
                    [
                      {
                        "isSelected":false,
                        "name": "化学",
                        "groupId": 480548880,
                      },
                      {
                        "isSelected":false,
                        "name": "数学",
                        "groupId": 480547865,
                      },
                      {
                        "isSelected":false,
                        "name": "物理",
                        "groupId": 480544220,
                      },
                      {
                        "isSelected":false,
                        "name": "英语",
                        "groupId": 480546231,
                      },

                      // {
                      //   "isSelected":false,
                      //   "name": "教师",
                      //   "groupId": 480538348,
                      // },

                    ];

                    for(int i = 0; i<staffSections.length; i++){
                      Map currentMap = staffSections[i];
                      currentMap["isSelected"] = false;
                    }
                    print("年级id:${SingletonManager.sharedInstance!.userData!.gradeId}");
                    isTappedSubject = false;
                    if (SingletonManager.sharedInstance!.isGuanKong! || SingletonManager.sharedInstance!.isPadDevice) {
                      showDialog(
                        useSafeArea: false,
                        barrierDismissible: true,
                        context: context,
                        builder: (context){
                          return StatefulBuilder(builder: (context, setS){
                            return Scaffold(
                              backgroundColor: Colors.transparent,
                              body: MediaQuery.removePadding(removeTop: true, removeBottom: true, context: context, child: InkWell(
                                child: Center(
                                  child: Container(
                                    width: MediaQuery.of(context).size.width - 100, height: 380,
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(11.5)
                                    ),
                                    child: Column(
                                      children: [
                                        Container(
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.only(topLeft: Radius.circular(11.5), topRight: Radius.circular(11.5)),
                                            image: DecorationImage(image: AssetImage("static/images/answer_question_top_icon.png"), fit: BoxFit.fill),
                                          ),
                                          child: Text("选择答疑科目", style: TextStyle(fontSize: 18, color: Color(0xffF9F9F9)),),
                                          height: 58,
                                          width: MediaQuery.of(context).size.width - 40,
                                        ),
                                        Padding(padding: EdgeInsets.only(left: 24, right: 24, top: 20),
                                          child: Container(
                                            height: 220,
                                            child: Column(
                                              children: [
                                                Expanded(
                                                  child: GridView.builder(
                                                    itemCount: staffSections.length,
                                                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                                      crossAxisCount: 2,
                                                      // 左右间隔
                                                      crossAxisSpacing: 15.0,
                                                      // 上下间隔
                                                      mainAxisSpacing: 16.0,
                                                      //宽高比
                                                      childAspectRatio: 7 / 2,
                                                    ),
                                                    itemBuilder: (context, index) {
                                                      Map map = staffSections[index];
                                                      bool isSelected = map["isSelected"];
                                                      return InkWell(child:
                                                      Container(alignment: Alignment.center, width: 10, height: 40, child:
                                                      Text("${map["name"]}", style: TextStyle(fontSize: 15, color: isSelected ? Color(0xff579EFF) : Color(0xff666666), fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),),
                                                        decoration: BoxDecoration(
                                                            color: isSelected ? Color(0xffEDF5FF): Color(0xffF4F4F4),
                                                            borderRadius: BorderRadius.circular(4)
                                                        ),
                                                      ),
                                                        onTap: () async {
                                                          for(int i = 0; i<staffSections.length; i++){
                                                            Map currentMap = staffSections[i];
                                                            currentMap["isSelected"] = false;
                                                          }
                                                          map["isSelected"] = true;
                                                          currentGroupId = map["groupId"];
                                                          staffSections[index] = map as Map<String, dynamic>;
                                                          isTappedSubject = true;
                                                          setS((){});
                                                        },);
                                                    },
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),

                                        Padding(padding: EdgeInsets.only(left: 28, right: 28, top: Platform.isIOS ? 12 : 12),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              InkWell(
                                                child: Container(
                                                  alignment: Alignment.center,
                                                  width: (MediaQuery.of(context).size.width - 50 - 28 * 2 - 25 - 50) / 2.0,
                                                  height: 36,
                                                  decoration: BoxDecoration(
                                                    border: Border.all(color: Color(0xff999999), width: 0.5),
                                                    color: Colors.white,
                                                    borderRadius: BorderRadius.circular(19),
                                                  ),
                                                  child: Text("取消", style: TextStyle(fontSize:16, color: Color(0xff999999),),),
                                                ),
                                                onTap: (){
                                                  Navigator.of(context).pop();
                                                },
                                              ),
                                              InkWell(
                                                child: Container(
                                                  alignment: Alignment.center,
                                                  width: (MediaQuery.of(context).size.width - 50 - 28 * 2 - 25 - 50) / 2.0,
                                                  height: 36,
                                                  decoration: BoxDecoration(
                                                    color: Color(0xff579EFF),
                                                    borderRadius: BorderRadius.circular(19),
                                                  ),
                                                  child: Text("确定", style: TextStyle(fontSize:16, color: Colors.white,),),
                                                ),
                                                onTap: () async{
                                                  if (isTappedSubject) {
                                                    Navigator.of(context).pop();
                                                    var parameter = [
                                                      {"key":"userName","value":SingletonManager.sharedInstance!.userData!.userName},
                                                      {"key":"real_name","value":SingletonManager.sharedInstance!.userData!.userName},
                                                      {"key":"userId","value":SingletonManager.sharedInstance!.userData!.userId}
                                                    ];
                                                    var result = await channel.invokeMethod("pushIM",
                                                      {
                                                        "parameter":parameter,
                                                        "uid":SingletonManager.sharedInstance!.userData!.userId,
                                                        "groupId":currentGroupId
                                                      },
                                                    );
                                                    print("$result");
                                                  } else {
                                                    Fluttertoast.showToast(msg: "请先选择答疑科目");
                                                  }
                                                },
                                              ),
                                            ],
                                          ),
                                        ),

                                      ],
                                    ),
                                  ),
                                ),
                                onTap: (){

                                },
                              ), ),
                            );
                          });
                        },
                      );
                    } else {
                      showDialog(
                        useSafeArea: false,
                        barrierDismissible: true,
                        context: context,
                        builder: (context){
                          return StatefulBuilder(builder: (context, setS){
                            return Scaffold(
                              backgroundColor: Colors.transparent,
                              body: MediaQuery.removePadding(removeTop: true, removeBottom: true, context: context, child: InkWell(
                                child: Center(
                                  child: Container(
                                    width: MediaQuery.of(context).size.width - 100, height: Platform.isIOS ? 270 : 260,
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(11.5)
                                    ),
                                    child: Column(
                                      children: [
                                        Container(
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.only(topLeft: Radius.circular(11.5), topRight: Radius.circular(11.5)),
                                            image: DecorationImage(image: AssetImage("static/images/answer_question_top_icon.png"), fit: BoxFit.fill),
                                          ),
                                          child: Text("选择答疑科目", style: TextStyle(fontSize: 18, color: Color(0xffF9F9F9)),),
                                          height: 58,
                                          width: MediaQuery.of(context).size.width - 40,
                                        ),
                                        Padding(padding: EdgeInsets.only(left: 24, right: 24, top: 20),
                                          child: Container(
                                            height:Platform.isIOS ? 120 : 110,
                                            child: Column(
                                              children: [
                                                Expanded(
                                                  child: GridView.builder(
                                                    itemCount: staffSections.length,
                                                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                                      crossAxisCount: 2,
                                                      // 左右间隔
                                                      crossAxisSpacing: 15.0,
                                                      // 上下间隔
                                                      mainAxisSpacing: 16.0,
                                                      //宽高比
                                                      childAspectRatio: 5 / 2,
                                                    ),
                                                    itemBuilder: (context, index) {
                                                      Map map = staffSections[index];
                                                      bool isSelected = map["isSelected"];
                                                      return InkWell(child:
                                                      Container(alignment: Alignment.center, width: 10, height: 40, child:
                                                      Text("${map["name"]}", style: TextStyle(fontSize: 15, color: isSelected ? Color(0xff579EFF) : Color(0xff666666), fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),),
                                                        decoration: BoxDecoration(
                                                            color: isSelected ? Color(0xffEDF5FF): Color(0xffF4F4F4),
                                                            borderRadius: BorderRadius.circular(4)
                                                        ),
                                                      ),
                                                        onTap: () async {
                                                          for(int i = 0; i<staffSections.length; i++){
                                                            Map currentMap = staffSections[i];
                                                            currentMap["isSelected"] = false;
                                                          }
                                                          map["isSelected"] = true;
                                                          currentGroupId = map["groupId"];
                                                          staffSections[index] = map as Map<String, dynamic>;
                                                          isTappedSubject = true;
                                                          setS((){

                                                          });
                                                        },);
                                                    },
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),

                                        Padding(padding: EdgeInsets.only(left: 28, right: 28, top: Platform.isIOS ? 12 : 12),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              InkWell(
                                                child: Container(
                                                  alignment: Alignment.center,
                                                  width: (MediaQuery.of(context).size.width - 50 - 28 * 2 - 25 - 50) / 2.0,
                                                  height: 36,
                                                  decoration: BoxDecoration(
                                                    border: Border.all(color: Color(0xff999999), width: 0.5),
                                                    color: Colors.white,
                                                    borderRadius: BorderRadius.circular(19),
                                                  ),
                                                  child: Text("取消", style: TextStyle(fontSize:16, color: Color(0xff999999),),),
                                                ),
                                                onTap: (){
                                                  Navigator.of(context).pop();
                                                },
                                              ),
                                              InkWell(
                                                child: Container(
                                                  alignment: Alignment.center,
                                                  width: (MediaQuery.of(context).size.width - 50 - 28 * 2 - 25 - 50) / 2.0,
                                                  height: 36,
                                                  decoration: BoxDecoration(
                                                    color: Color(0xff579EFF),
                                                    borderRadius: BorderRadius.circular(19),
                                                  ),
                                                  child: Text("确定", style: TextStyle(fontSize:16, color: Colors.white,),),
                                                ),
                                                onTap: () async{
                                                  if (isTappedSubject) {
                                                    Navigator.of(context).pop();
                                                    var parameter = [
                                                      {"key":"userName","value":SingletonManager.sharedInstance!.userData!.userName},
                                                      {"key":"real_name","value":SingletonManager.sharedInstance!.userData!.userName},
                                                      {"key":"userId","value":SingletonManager.sharedInstance!.userData!.userId}
                                                    ];
                                                    var result = await channel.invokeMethod("pushIM",
                                                      {
                                                        "parameter":parameter,
                                                        "uid":SingletonManager.sharedInstance!.userData!.userId,
                                                        "groupId":currentGroupId
                                                      },
                                                    );
                                                    print("$result");
                                                  } else {
                                                    Fluttertoast.showToast(msg: "请先选择答疑科目");
                                                  }
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                onTap: (){

                                },
                              ), ),
                            );
                          });
                        },
                      );
                    }
                  },
                ),
              ),
            ],
          ),
          backgroundColor: Colors.white,
          body: Stack(
            key: _stackKey,
            children: <Widget>[
              Column(
                children: <Widget>[
                  Expanded(
                    child: EasyRefresh(
                      child: ListView.builder(
                          itemCount: _selectPlanSortCondition!.tasks!.length + 1,
                          itemBuilder: (BuildContext context, int index) {
                            if (index == 0) {
                              return Column(
                                children: [
                                  Container(
                                    width: MediaQuery.of(context).size.width,
                                    height: 174,
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                          image: AssetImage("static/images/plan_top_background.png",),
                                          fit: BoxFit.fill
                                      ),
                                    ),
                                    child: Column(
                                      children: [
                                        Padding(padding: EdgeInsets.only(top: 17)),
                                        // 下拉菜单头部
                                        GZXDropDownHeader(
                                          // 下拉的头部项，目前每一项，只能自定义显示的文字、图标、图标大小修改
                                          items: [
                                            //GZXDropDownHeaderItem(_dropDownHeaderItemStrings[0]),
                                            GZXDropDownHeaderItem(
                                              _dropDownHeaderItemStrings[1]!,
                                              style: TextStyle(color: Colors.white, fontSize: _dropDownHeaderItemStrings[1]!.length > 19 ? 18 : 24),
                                            ),
                                          ],
                                          // GZXDropDownHeader对应第一父级Stack的key
                                          stackKey: _stackKey,
                                          // controller用于控制menu的显示或隐藏
                                          controller: _dropdownMenuController,
                                          // 当点击头部项的事件，在这里可以进行页面跳转或openEndDrawer
                                          onItemTap: (index) {

                                          },
                                          // 头部的高度
                                          height: 44,
                                          // 头部背景颜色
                                          color: Colors.transparent,
                                          // 头部边框宽度
                                          borderWidth: 1.0,
                                          // 头部边框颜色
                                          borderColor: Colors.transparent,
                                          // 文字样式
                                          style: TextStyle(color: Colors.white, fontSize: 24),
                                          // 下拉时文字样式
                                          dropDownStyle: TextStyle(color: Colors.white, fontSize: 24),
                                          // 图标大小
                                          iconSize: 24,
                                          // 图标颜色
                                          iconColor: Color(0xFFffffff),
                                          // 下拉时图标颜色
                                          iconDropDownColor: Color(0xFFffffff),
                                        ),

                                        Padding(
                                          padding: EdgeInsets.only(top: 0.5, left: 73, right: 73),
                                          child: Container(
                                            child: Text(_selectPlanSortCondition!.planDesc!, style: TextStyle(fontSize: 12, color: Color(0xffC9F3FF),), maxLines: 4, overflow: TextOverflow.ellipsis,),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(padding: EdgeInsets.only(top: 20),),
                                ],
                              );
                            } else {
                              Tasks task = _selectPlanSortCondition!.tasks![index - 1];
                              Map map = resourceMap[task.resourceType]!;
                              return InkWell(
                                child: Padding(
                                  padding: EdgeInsets.only(left: 16, right: 16),
                                  child: Column(
                                    children: [
                                      Container(
                                        height: 90,
                                        width: MediaQuery.of(context).size.width - 32,
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(8),
                                            boxShadow: [BoxShadow(color: Color(0xffB2C1D9), offset: Offset(0, 2), blurRadius: 10.0, spreadRadius: 0.0),]
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Padding(
                                              padding: EdgeInsets.only(top: 12, left: 16, right: 16),
                                              child: Text(task.resourceName!, style: TextStyle(fontSize: task.resourceName!.length > 18 ? 12 : 16 , color: Color(0xff555555)), maxLines: 1, overflow: TextOverflow.ellipsis,),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.only(top: 23),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Padding(
                                                    padding: EdgeInsets.only(left: 16),
                                                    child: Row(
                                                      children: [
                                                        Image(image: AssetImage(map["imagePath"]), width: 27, height: 27,),
                                                        Padding(
                                                          padding: EdgeInsets.only(left: 8),
                                                          child: Text(map["resourceType"], style: TextStyle(fontSize: 12, color: Color(0xff222222)),),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding: EdgeInsets.only(right: 16),
                                                    child: Row(
                                                      children: [
                                                        Text(task.planTime!, style: TextStyle(fontSize: 12, color: Color(0xff888888))),
                                                        Padding(
                                                          padding: EdgeInsets.only(left: 20),
                                                          child: Text(task.isFinish == 1 ? "已学" : "未学", style: TextStyle(fontSize: 12, color: task.isFinish == 1 ? Color(0xff888888) : Color(0xff2E96FF)),),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Padding(padding: EdgeInsets.only(top: 16)),
                                    ],
                                  ),
                                ),
                                onTap: (){
                                  print("点击的任务:${task.resourceName}");
                                  _handleTapAction(task);
                                },
                              );
                            }
                          }),
                      firstRefresh: false,
                      onRefresh: _onRefresh,
                      header: ClassicalHeader(
                          refreshText: "下拉刷新",
                          refreshingText: "正在刷新...",
                          refreshedText: "刷新完成",
                          refreshFailedText: "刷新失败",
                          refreshReadyText: "松手刷新",
                          noMoreText: "没有更多",
                          infoText: "加载时间${DateTime.now().hour}:${DateTime.now().minute > 9 ? DateTime.now().minute :"0" + "${DateTime.now().minute}" }"
                      ),
                      onLoad: null,
                    ),
                  ),
                ],
              ),

              // 下拉菜单
              GZXDropDownMenu(
                // controller用于控制menu的显示或隐藏
                controller: _dropdownMenuController,
                // 下拉菜单显示或隐藏动画时长
                animationMilliseconds: 200,
                dropdownMenuChanging: (isShow, index) {
                  setState(() {
                    _dropdownMenuChange = '(正在${isShow ? '显示' : '隐藏'}$index)';
                    print(_dropdownMenuChange);
                  });
                },
                dropdownMenuChanged: (isShow, index) {
                    isCurrentShowing = isShow;
                  setState(() {
                    _dropdownMenuChange = '(已经${isShow ? '显示' : '隐藏'}$index)';
                    print(_dropdownMenuChange);
                  });
                },
                // 下拉菜单，高度自定义，你想显示什么就显示什么，完全由你决定，你只需要在选择后调用_dropdownMenuController.hide();即可
                menus: [
                  GZXDropdownMenuBuilder(
                      dropDownHeight: _plansSortConditions!.length < 10 ? 40.0 * _plansSortConditions!.length + 10.0 : 300,
                      dropDownWidget: _buildPlanTitleListView(_plansSortConditions, (value) {
                        _selectPlanSortCondition = value;
                        _dropDownHeaderItemStrings[1] = _selectPlanSortCondition!.planName;
                        _dropdownMenuController.hide();
                        setState(() {});
                      })),
                ],
              ),
            ],
          ),
        );
      } else {
        /// 有错误
        if (hasError) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.white,
              title: Text("全时自习室"),
              elevation: 1,
            ),
            backgroundColor: Colors.white,
            body: EmptyPlaceholderPage(assetsPath: 'static/images/empty.png', message: '没有数据',),
          );
        } else {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.white,
              title: Text("全时自习室"),
              elevation: 0,
            ),
            backgroundColor: Colors.white,
            body: Center(
              child: Container(
                child: InkWell(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image(image: AssetImage("static/images/plan_no_data_placeholder.png"), width: 217, height: 142,),
                      Padding(
                        padding: EdgeInsets.only(top: 9),
                        child: Text("暂时没有计划，和老师联系一下吧！", style: TextStyle(fontSize: 15, color: Color(0xff666666)),),
                      ),
                    ],
                  ),
                  onTap: (){
                    _fetchMyPlanData();
                  },
                ),
              ),
            ),
          );
        }
      }
    }
  }

  ///
  /// @description 刷新方法添加
  /// @param
  /// @return
  /// @author waitwalker
  /// @time 2020/11/5 3:10 PM
  ///
  Future<Null> _onRefresh() async{
    ResponseData responseData = await DaoManager.fetchMyPlanData({});
    if (responseData.code == 200) {
      MyPlanModel? myPlanModel = responseData.model;
      if (myPlanModel != null && myPlanModel.data != null && myPlanModel.code! > 0) {

        for(int i = 0; i<myPlanModel.data!.length; i++) {
          Data currentData = myPlanModel.data![i];
          if (lastSubjectId != 0 && lastSubjectId == currentData.subjectId) {
            lastIndex = i;
          }
        }

        if (totalSubjects != myPlanModel.data!.length) {
          lastIndex = 0;
          lastSubjectId = 0;
          totalSubjects = myPlanModel.data!.length;
        }

        _selectSubjectSortCondition = myPlanModel.data![lastIndex];
        _selectSubjectSortCondition.isSelected = true;
        if (_selectPlanSortCondition != null) _selectPlanSortCondition!.isSelected = false;
        _selectPlanSortCondition = myPlanModel.data![lastIndex].plans![0];
        _selectPlanSortCondition!.isSelected = true;
        _dropDownHeaderItemStrings.clear();
        _dropDownHeaderItemStrings.add(_selectSubjectSortCondition.subjectName);
        _dropDownHeaderItemStrings.add(_selectPlanSortCondition!.planName);
        _subjectsSortConditions.clear();
        _plansSortConditions!.clear();
        _subjectsSortConditions.addAll(myPlanModel.data!);
        _plansSortConditions!.addAll(myPlanModel.data![lastIndex].plans!);
        setState(() {
          return null;
        });
      } else {
        Fluttertoast.showToast(msg: myPlanModel!.msg ?? "请稍后重试");
        return null;
      }
    } else {
      return null;
    }
  }

  ///
  /// @description 学科横向列表
  /// @param
  /// @return
  /// @author waitwalker
  /// @time 2020/11/4 4:45 PM
  ///
  _buildSubjectList(items, void itemOnTap(Data sortCondition)) {
    return ListView.builder(scrollDirection: Axis.horizontal, itemBuilder: (BuildContext context, int index) {
      Data subjectData = _subjectsSortConditions[index];
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Padding(padding: EdgeInsets.only(top: 25)),
          Padding(padding: EdgeInsets.only(right: 28,),
            child: Column(
              children: [
                InkWell(
                  child: Text("${subjectData.subjectName}",style: TextStyle(fontSize:subjectData.isSelected ? 18 : 16,color: subjectData.isSelected ? Color(0xffFFFFFF) : Color(0xffCEE8FF)),),
                  onTap: () {
                    print("点击当前学科:${subjectData.subjectName}");
                    for (var value in items) {
                      value.isSelected = false;
                    }
                    lastSubjectId = subjectData.subjectId;
                    subjectData.isSelected = true;
                    itemOnTap(subjectData);
                  },
                ),
                if (subjectData.isSelected)
                  Container(
                    alignment: Alignment.centerLeft,
                    height: 3,
                    width: 36,
                    decoration: BoxDecoration(
                      color: Color(0xff49CBFF),
                      borderRadius: BorderRadius.circular(1.75),
                    ),
                  ),
              ],
            ),
          ),

        ],
      );
    }, itemCount: _subjectsSortConditions.length,);
  }
  
  ///
  /// @description 构建选择计划列表
  /// @param 
  /// @return 
  /// @author waitwalker
  /// @time 2020/11/4 4:47 PM
  ///
  _buildPlanTitleListView(items, void itemOnTap(Plans sortCondition)) {
    return Container(
      height: 300,
      child: Column(children: [
        Expanded(child: ListView.separated(
          shrinkWrap: true,
          scrollDirection: Axis.vertical,
          itemCount: items.length,
          // item 的个数
          separatorBuilder: (BuildContext context, int index) => Divider(height: 1.0),
          // 添加分割线
          itemBuilder: (BuildContext context, int index) {
            Plans planData = items[index];
            return GestureDetector(
              onTap: () {
                for (var value in items) {
                  value.isSelected = false;
                }
                planData.isSelected = true;
                itemOnTap(planData);
              },
              child: Container(
                height: 40,
                child: Row(
                  children: <Widget>[
                    SizedBox(
                      width: 16,
                    ),
                    Expanded(
                      child: Text(
                        planData.planName!,
                        style: TextStyle(color: planData.isSelected ? Color(0xff2E96FF) : Color(0xffB0BACB),),
                      ),
                    ),
                    planData.isSelected
                        ? Icon(Icons.check, color: planData.isSelected ? Color(0xff2E96FF) : Color(0xffB0BACB), size: 18,)
                        : SizedBox(),
                    SizedBox(width: 16,),
                  ],
                ),
              ),
            );
          },
        )),
      ],),
    );
  }

  ///
  /// @description 处理点击事件
  /// @param
  /// @return
  /// @author waitwalker
  /// @time 2020/11/6 10:01 AM
  ///
  _handleTapAction(Tasks task) async{
    /// 高清任务 || 导学任务
    if (task.resourceType == 1 || task.resourceType == 4 || task.resourceType == 6) {
      /// 高清课 暂时写死 调试接口的时候 撤回
      var resourceInfo = await CourseDaoManager.getResourceInfo(task.resourceId);
      if (resourceInfo.result && resourceInfo.model != null && resourceInfo.model.code == 1) {
        if (task.resourceType == 1) {
          // 微视频/高清 已加学习状态
          Navigator.of(context).push(MaterialPageRoute(builder: (_) {
            return HDVideoPage(
              task: task,
              source: resourceInfo.model.data.videoUrl,
              title: task.resourceName,
              coverUrl: resourceInfo.model.data.imageUrl,
              videoInfo: VideoInfo(
                videoUrl: resourceInfo.model.data.videoUrl,
                videoDownloadUrl: resourceInfo.model.data.downloadVideoUrl,
                imageUrl: resourceInfo.model.data.imageUrl,
                resName: resourceInfo.model.data.resourceName,
                resId: resourceInfo.model.data.resouceId.toString(),
                courseId: (task.cardCourseId ?? 0).toString(),
                ),);
          })).then((value) {
            _onRefresh();
          });
        } else {
          /// 导学 文档
          var model = resourceInfo.model;
          if (task.resourceType == 6) {
            Navigator.of(context).push(MaterialPageRoute(builder: (_) {
              return CommonWebviewPage(
                initialUrl: resourceInfo.model.data.literaturePreviewUrl,
                downloadUrl: resourceInfo.model.data.literatureDownUrl,
                title: task.resourceName,
                pageType: 3,
                resId: "${model.data.resouceId}",
                task: task,
              );
            })).then((value) {
              _onRefresh();
            });
          } else {
            if (model.data.literatureDownUrl.endsWith('.pdf') && !SingletonManager.sharedInstance!.isGuanKong!) {
              /// 调到PDF预览页
              Navigator.of(context).push(MaterialPageRoute(builder: (_) {
                return PDFPage(model.data.literatureDownUrl, title: model.data.resourceName, fromZSDX: true, resId: model.data.resouceId.toString(), task: task,);
              })).then((value) {
                _onRefresh();
              });
            } else {
              Navigator.of(context).push(MaterialPageRoute(builder: (_) {
                return CommonWebviewPage(
                  initialUrl: resourceInfo.model.data.literaturePreviewUrl,
                  downloadUrl: resourceInfo.model.data.literatureDownUrl,
                  title: task.resourceName,
                  pageType: 3,
                  resId: "${model.data.resouceId}",
                  task: task,
                );
              })).then((value) {
                _onRefresh();
              });
            }
          }
        }
      } else {
        Fluttertoast.showToast(msg: resourceInfo.model?.msg ?? '获取资源失败');
      }
    } else if (task.resourceType == 2) {
      /// 微课任务 560746
      var microCourseResourceInfo = await CourseDaoManager.getMicroCourseResourceInfo(task.resourceId);
      if (microCourseResourceInfo.result) {
        MicroCourseResourceModel model = microCourseResourceInfo.model as MicroCourseResourceModel;
        if (model.data != null) {
          Navigator.of(context).push(MaterialPageRoute(builder: (_) {
            return MicroCoursePage(model.data, task: task,);
          })).then((value) {
            _onRefresh();
          });
        } else {
          Fluttertoast.showToast(msg: "暂时没有数据");
        }
      }
    } else if (task.resourceType == 3) {
      // 练习任务
      // 这里需要一些参数 调试的时候确定是跳转到练习中转页面还是直接跳到详情页面
      ResourceIdListEntity idListEntity = ResourceIdListEntity(resId: task.resourceId, resName: task.resourceName, resType: task.resourceType, srcABPaperQuesIds: task.questionIds, studyStatus: task.isFinish);
      Navigator.of(context).push(MaterialPageRoute(builder: (_) {
        return TestPaperPage(idListEntity, courseId: task.cardCourseId, task: task,);
      })).then((value) {
        _onRefresh();
      });
    } else if (task.resourceType == 5) {
      // 直播任务
      var token = NetworkManager.getAuthorization();
      var url = '${APIConst.liveHost}?utoken=$token&rcourseid=${task.liveCourseId}&ocourseId=${task.courseId}&roomid=${task.roomId}';
      // 需求：护眼模式，直播不计时
      EyeProtectionTimer.pauseTimer();
      Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => CommonWebviewPage(initialUrl: url, title: task.resourceName, task: task,)))
          .then((_) {
        EyeProtectionTimer.startEyeProtectionTimer(context);
        _onRefresh();
      });
    }
  }


  @override
  void dispose() {
    super.dispose();
  }

}


/// 应用全局悬浮框
class AppFloatBox extends StatefulWidget {
  @override
  _AppFloatBoxState createState() => _AppFloatBoxState();
}

class _AppFloatBoxState extends State<AppFloatBox> {
  Offset offset = Offset(10, kToolbarHeight + 100);

  /// 调用七鱼channel
  MethodChannel channel = const MethodChannel("com.etiantian/im_service");
  Offset _calOffset(Size size, Offset offset, Offset nextOffset) {
    double dx = 0;
    if (offset.dx + nextOffset.dx <= 0) {
      dx = 0;
    } else if (offset.dx + nextOffset.dx >= (size.width - 50)) {
      dx = size.width - 50;
    } else {
      dx = offset.dx + nextOffset.dx;
    }
    double dy = 0;
    if (offset.dy + nextOffset.dy >= (size.height - 100)) {
      dy = size.height - 100;
    } else if (offset.dy + nextOffset.dy <= kToolbarHeight) {
      dy = kToolbarHeight;
    } else {
      dy = offset.dy + nextOffset.dy;
    }
    return Offset(
      dx,
      dy,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        highlightColor: Colors.transparent,
        appBarTheme: AppBarTheme.of(context).copyWith(
          brightness: Brightness.dark,
        ),
      ),
      child: Positioned(
        left: offset.dx,
        top: offset.dy,
        child: GestureDetector(
          onPanUpdate: (detail) {
            setState(() {
              offset = _calOffset(MediaQuery.of(context).size, offset, detail.delta);
            });
          },
          onTap: () async{
            var parameter = [
              {"key":"userName","value":SingletonManager.sharedInstance!.userData!.userName},
              {"key":"real_name","value":SingletonManager.sharedInstance!.userData!.userName},
              {"key":"userId","value":SingletonManager.sharedInstance!.userData!.userId}
            ];
            var result = await channel.invokeMethod("pushIM", {"parameter":parameter,
              "uid":SingletonManager.sharedInstance!.userData!.userId});
            print("$result");
          },
          onPanEnd: (detail) {},
          child: Container(
            height: 50,
            width: 50,
            color: Colors.blueAccent,
            child: Text(
              "Box",
              style: TextStyle(
                fontSize: 20,
                color: Colors.black,
                decoration: TextDecoration.none,
              ),
            ),
          ),
        ),
      ),
    );
  }
}