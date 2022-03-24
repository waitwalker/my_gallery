import 'dart:convert';
import 'dart:io';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:my_gallery/common/const/router_const.dart';
import 'package:my_gallery/common/network/error_code.dart';
import 'package:my_gallery/common/dao/original_dao/course_dao_manager.dart';
import 'package:my_gallery/common/singleton/singleton_manager.dart';
import 'package:my_gallery/common/tools/share_preference/share_preference.dart';
import 'package:my_gallery/event/card_activate_event.dart';
import 'package:my_gallery/model/my_course_model.dart';
import 'package:my_gallery/model/subject_detail_model.dart';
import 'package:my_gallery/model/user_info_model.dart';
import 'package:my_gallery/modules/my_course/intelligence_question_database/intelligence_entrance_page.dart';
import 'package:my_gallery/modules/my_course/wisdom_study/scroll_to_index/scroll_to_index.dart';
import 'package:my_gallery/common/redux/app_state.dart';
import 'package:my_gallery/modules/my_course/ai_test/ai_test_list_page.dart';
import 'package:my_gallery/modules/my_course/live/live_page.dart';
import 'package:my_gallery/modules/my_course/wisdom_study/wisdom_study_list_page.dart';
import 'package:my_gallery/modules/personal/activate_card/activate_card_page.dart';
import 'package:my_gallery/modules/personal/activate_card/activate_card_state_page.dart';
import 'package:my_gallery/modules/widgets/style/style.dart';
import 'package:my_gallery/common/tools/get_grade/grade_utils.dart';
import 'package:my_gallery/common/logger/logger.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import 'ai_test/ai_list_container_page.dart';
import 'live/live_page.dart';


///
/// @name SubjectDetailPage
/// @description 学科详情页面  首页=>学科=>学科详情页面
/// @author waitwalker
/// @date 2020-01-10
///
class SubjectDetailPage extends StatefulWidget {
  final List<int>? gradeIds;
  final int? subjectId;
  final bool hiddenCard;
  final num? cardType;
  final List<GradesEntity>? gradesInfoList;

  SubjectDetailPage({this.gradeIds, this.subjectId, this.hiddenCard = true, this.cardType, this.gradesInfoList});

  @override
  State<StatefulWidget> createState() {
    return _SubjectDetailState(hiddenDownload: true, gradeJoin: "", cardEndTime: "", nextLiveTime: "");
  }
}

class _SubjectDetailState extends State<SubjectDetailPage> {
  /// 学科Id
  int? gradeId;
  // 没有开课的用户，可以预览全部学科，
  // 但是，物理没初一
  // 化学没初二
  List<int>? get gradeIds => widget.gradeIds!.isNotEmpty
      ? widget.gradeIds
      : widget.subjectId == 4
      ? [5, 4, 3, 2, 1]
      : widget.subjectId == 5
      ? [4, 3, 2, 1]
      : widget.subjectId == 10
      ? [6, 5, 4]
      : [6, 5, 4, 3, 2, 1];

  /// 是否隐藏下拉
  bool? hiddenDownload = true;
  bool get previewUser => widget.gradeIds?.isEmpty ?? true;
  bool previewMode = false;

  /// 年级学科
  String? gradeJoin = "";

  /// 卡结束日期
  String? cardEndTime = "";

  /// 下次直播时间
  String? nextLiveTime = "";

  SubjectDetailModel? subjectDetailModel;

  // 是否显示直播卡片入口: 接口返回的showLiveStatus = 1,显示,其他都不显示
  bool showLiveCard = false;

  _SubjectDetailState(
      {this.hiddenDownload,
        this.gradeJoin,
        this.cardEndTime,
        this.nextLiveTime});

  Store<AppState> _getStore() {
    return StoreProvider.of<AppState>(context);
  }

  @override
  void initState() {
    gradeId = gradeIds![0];

    // 不是体验模式
    if (!previewUser) {
      previewMode = false;
      _loadData(gradeId);
    } else {
      previewMode = true;
    }

    /// 体验课,初中直播卡片隐藏,接口中返回的数据是否需要隐藏
    /// 如果不是体验课
    if (widget.gradesInfoList != null) {
      GradesEntity gradesEntity = widget.gradesInfoList![0];
      if (gradesEntity.showLiveStatus != null && gradesEntity.showLiveStatus == 1) {
        showLiveCard = true;
      } else {
        showLiveCard = false;
      }
    } else {
      // 是否是体验 是否初中 是否智领
      // 是初中
      if (gradeId! > 3) {
        showLiveCard = false;
      } else {
        showLiveCard = true;
      }
    }

    super.initState();
  }

  /// 获取学科详情数据
  _loadData(int? grdId) async {
    /// 年级
    String grade = gradeSample[grdId!].toString();

    /// 学科名称
    String subjectName = subjectSample[widget.subjectId!]!;
    gradeJoin = grade + subjectName;
    setState(() {});
    var response = await CourseDaoManager.subjectDetail(gradeId: grdId, subjectId: widget.subjectId, cardType: widget.cardType as int?);
    if (response.result && response.model.code == 1) {
      subjectDetailModel = response.model as SubjectDetailModel?;
      /// 到期时间
      String cardEndTimeStr = subjectDetailModel!.data!.cardEndTime ?? "";

      /// 直播时间
      String nextLiveTimeStr = subjectDetailModel!.data!.nextLiveTime ?? "";
      if (subjectDetailModel!.data!.onlineLabel == 1) {
        previewMode = false;
      } else {
        previewMode = true;
      }

      setState(() {
        if (gradeIds!.length > 1) {
          hiddenDownload = false;
        } else {
          hiddenDownload = true;
        }
        cardEndTime = _cardEndDateFormat(DateTime.tryParse(cardEndTimeStr)!) + "到期";
        if (nextLiveTimeStr.isNotEmpty) {
          nextLiveTime = _liveDateFormat(DateTime.tryParse(nextLiveTimeStr)!);
        }
      });
    } else {
      // toast("获取学科详情数据失败");
      previewMode = true;
    }
  }

  /// 直播课时间格式化
  String _liveDateFormat(DateTime dateTime) {
    String minute =
    dateTime.minute > 9 ? "${dateTime.minute}" : "${dateTime.minute}" + "0";
    String hour =
    dateTime.hour > 9 ? "${dateTime.hour}" : "0" + "${dateTime.hour}";
    return "${dateTime.month}" +
        "月" +
        "${dateTime.day}" +
        "日" +
        " " +
        hour +
        ":" +
        minute;
  }

  /// 卡结束日期格式化
  String _cardEndDateFormat(DateTime dateTime) {
    return "${dateTime.year}" +
        "." +
        "${dateTime.month}" +
        "." +
        "${dateTime.day}";
  }

  @override
  Widget build(BuildContext context) {
    return StoreBuilder(builder: (BuildContext context, Store<AppState> store) {
      return Scaffold(
        appBar: _appBar(),
        backgroundColor: Colors.white,
        body: Column(
          children: <Widget>[
            Expanded(child: ListView(
              children: _buildBodyListWidget(),
            )),
          ],
        ),
      );
    });
  }

  /// 导航栏
  _appBar() {
    return AppBar(
      title: Container(
        child: Row(
          children: _titleChildren(),
        ),
      ),
      backgroundColor: Color(MyColors.white),
      elevation: 1,
      ///阴影高度
      titleSpacing: 0,
      centerTitle: Platform.isIOS ? true : false,
      actions: Platform.isIOS ? ((SingletonManager.sharedInstance!.reviewStatus != null && SingletonManager.sharedInstance!.reviewStatus == 0) ? _renewCard(): <Widget>[Container(),])  : _renewCard(),
    );
  }

  ///
  /// @description 构建navigationBar
  /// @param
  /// @return
  /// @author waitwalker
  /// @time 12/7/20 10:45 AM
  ///
  List<Widget> _titleChildren() {
    if (gradeIds!.length > 1) {
      return <Widget>[
        DropdownButton(
          iconSize: 26,
          hint: Text(gradeSample[gradeId!]!, style: TextStyle(fontSize: 20),),
          underline: Container(),
          items: _getListData(),
          value: gradeId,
          onChanged: (dynamic currentGradeId) {
            gradeId = currentGradeId;
            if (widget.gradesInfoList != null) {
              late GradesEntity selectedGradeEntity;
              for(GradesEntity gradesEntity in widget.gradesInfoList!) {
                if (gradesEntity.gradeId == currentGradeId) {
                  selectedGradeEntity = gradesEntity;
                }
              }
              if (selectedGradeEntity.showLiveStatus != null && selectedGradeEntity.showLiveStatus == 1) {
                showLiveCard = true;
              } else {
                showLiveCard = false;
              }
            } else {
              // 是否是体验 是否初中 是否智领
              // 是初中
              if (gradeId! > 3) {
                showLiveCard = false;
              } else {
                showLiveCard = true;
              }
            }
            _loadData(gradeId);
          },
        ),
      ];
    } else {
      return <Widget>[
        Text(
          gradeJoin!,
          style: TextStyle(fontSize: 20),
        ),
        Padding(padding: EdgeInsets.only(left: 8)),
      ];
    }
  }

  ///
  /// @description 导航栏年级学科下拉菜单
  /// @param
  /// @return
  /// @author waitwalker
  /// @time 12/7/20 10:46 AM
  ///
  List<DropdownMenuItem> _getListData() {
    List<DropdownMenuItem> items = [];
    if (gradeIds!.length < 2) {
      return [];
    }

    for (int i = 0; i < gradeIds!.length; i++) {
      String gradeName = gradeSample[gradeIds![i]].toString();
      String subjectName = subjectSample[widget.subjectId!]!;
      DropdownMenuItem dropdownMenuItem = DropdownMenuItem(
        child: Text(
          gradeName + subjectName,
          style: TextStyle(fontSize: 20),
        ),
        value: gradeIds![i],
      );

      items.add(dropdownMenuItem);
    }
    return items;
  }

  ///
  /// @description 右上角续卡布局
  /// @param
  /// @return
  /// @author waitwalker
  /// @time 12/7/20 10:45 AM
  ///
  _renewCard() {
    if (widget.hiddenCard) {
      return <Widget>[
        /// 续卡
        Container(),
      ];
    } else {
      return <Widget>[
        Container(
          color: Colors.transparent,
          width: 180,
          child: Padding(
            padding: EdgeInsets.only(right: 16),
            child: InkWell(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Padding(padding: EdgeInsets.only(top: 5)),
                  Container(
                    alignment: Alignment.center,
                    height: SingletonManager.sharedInstance!.isPadDevice ? 26 : 16,
                    width: SingletonManager.sharedInstance!.isPadDevice ? 46 : 36,
                    decoration: BoxDecoration(
                      color: Color(0xff3B9EFF),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text("续卡", style: TextStyle(fontSize: SingletonManager.sharedInstance!.isPadDevice ? 16 : 11, color: Colors.white),),
                  ),
                  Padding(padding: EdgeInsets.only(top: 5)),
                  Text(cardEndTime!, style: TextStyle(fontSize: 11, color: Color(0xffb3b3b3)),),
                ],
              ),
              onTap: (){
                var userInfo = _getStore().state.userInfo!;
                if (userInfo.data!.bindingStatus == 1) {
                  Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => userInfo.data!.stateType == 0
                      ? ActivateCardStatePage()
                      : ActivateCardPage())).then((r) {
                    if (r ?? false) {
                      debugLog('@@@@@@@@@@@--->CODE FIRE');
                      ErrorCode.eventBus.fire(CardActivateEvent());
                    }
                  });
                } else {
                  // bind phone
                  Navigator.of(context).pushNamed(RouteConst.bind_phone)
                      .then((r) => (r) != null ? _toActivatePage(userInfo) : null);
                }
              },
            ),
          ),
        ),
      ];
    }
  }

  ///
  /// @description 跳转到激活卡页面
  /// @param
  /// @return
  /// @author waitwalker
  /// @time 12/7/20 10:46 AM
  ///
  void _toActivatePage(UserInfoModel userInfo) {
    Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => userInfo.data!.stateType == 0
        ? ActivateCardStatePage()
        : ActivateCardPage())).then((r) {
      if (r ?? false) {
        debugLog('@@@@@@@@@@@--->CODE FIRE');
        ErrorCode.eventBus.fire(CardActivateEvent());
      }
    });
  }

  ///
  /// @description 构建顶部文本
  /// @param
  /// @return
  /// @author waitwalker
  /// @time 12/7/20 10:27 AM
  ///
  _buildTopWidget() {
    double titleFontSize = SingletonManager.sharedInstance!.isPadDevice ? 23 : 17;
    double subTitleFontSize = SingletonManager.sharedInstance!.isPadDevice ? 20 : 13;
    return Container(
      child: Padding(
        padding: EdgeInsets.only(left: 24, top: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text("欢迎开始今天的高效学习之旅", style: TextStyle(fontSize: titleFontSize, color: Color(0xff222222), fontWeight: FontWeight.bold),maxLines: 1, overflow: TextOverflow.ellipsis,),
            Padding(padding: EdgeInsets.only(top: 5)),
            Text("AI智能助手与四中资深老师陪你一起成长\n每天进步一点点", style: TextStyle(fontSize: subTitleFontSize, color: Color(0xff555555),),maxLines: 2, overflow: TextOverflow.ellipsis,)
          ],),
      ),
    );
  }

  ///
  /// @description 构建AI卡片
  /// @param
  /// @return
  /// @author waitwalker
  /// @time 12/7/20 10:27 AM
  ///
  _buildAICardWidget() {
    return Padding(padding: EdgeInsets.only(left: 16, right: 16, top: 16),
      child: InkWell(
        child: Container(
          height: SingletonManager.sharedInstance!.isPadDevice ? 180 : 104,
          width: MediaQuery.of(context).size.width - 32,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(11),
            gradient: LinearGradient(colors: [
              Color(0xffFFBE3E),
              Color(0xffFFBE3E)
            ]),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(padding: EdgeInsets.only(left: 19),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("AI测试", style: TextStyle(fontWeight: FontWeight.bold, fontSize: SingletonManager.sharedInstance!.isPadDevice ? 24 : 19, color: Colors.white),),
                    Padding(padding: EdgeInsets.only(top: 5)),
                    Text("智能推送，快速高效刷题", style: TextStyle(fontSize: SingletonManager.sharedInstance!.isPadDevice ? 20 : 12, color: Colors.white),),
                  ],),
              ),
              Padding(padding: EdgeInsets.only(right: 26),
                child: Image(image: AssetImage("static/images/subject_ai_icon.png"), width: SingletonManager.sharedInstance!.isPadDevice ? 120 : 80, height: SingletonManager.sharedInstance!.isPadDevice ? 120 : 80, fit: BoxFit.fill,),),
            ],),
        ),
        onTap: (){
          Navigator.of(context).push(MaterialPageRoute(
              builder: (BuildContext context) => AIListContainerPage(
                  innerWidget: AITestListPage(
                    widget.subjectId,
                    gradeId,
                    courseId: subjectDetailModel?.data?.courseId ?? 0,
                    previewMode: previewUser,
                  ),
                  title: 'AI测试')));
        },
      ),
    );
  }

  ///
  /// @description 构建智慧学习卡片
  /// @param
  /// @return
  /// @author waitwalker
  /// @time 12/7/20 10:27 AM
  ///
  _buildWisdomCardWidget() {
    return Padding(padding: EdgeInsets.only(left: 16, right: 16, top: 18),
      child: InkWell(
        child: Container(
          height: SingletonManager.sharedInstance!.isPadDevice ? 180 : 104,
          width: MediaQuery.of(context).size.width - 32,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(11),
            gradient: LinearGradient(colors: [
              Color(0xff3CC7FF),
              Color(0xff3CC7FF),
            ]),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(padding: EdgeInsets.only(left: 19),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("智慧学习", style: TextStyle(fontWeight: FontWeight.bold, fontSize: SingletonManager.sharedInstance!.isPadDevice ? 24 : 19, color: Colors.white),),
                    Padding(padding: EdgeInsets.only(top: 5)),
                    Text("四中老师微课等你学", style: TextStyle(fontSize: SingletonManager.sharedInstance!.isPadDevice ? 20 : 12, color: Colors.white),),
                  ],),
              ),
              Padding(padding: EdgeInsets.only(right: 26),
                child: Image(image: AssetImage("static/images/subject_wisdom_icon.png"), width: SingletonManager.sharedInstance!.isPadDevice ? 120 : 80, height: SingletonManager.sharedInstance!.isPadDevice ? 120 : 80, fit: BoxFit.fill,),),
            ],),
        ),
        onTap: () {
          String wisdomPageValue = SharedPrefsUtils.getString("wisdomPage","")!;
          Map? map;
          String? currentValue = "1";
          if (wisdomPageValue.isNotEmpty && wisdomPageValue.length > 2) {
            map = JsonDecoder().convert(wisdomPageValue);
            print("map:$map");
            String? savedGradeId = map!["gradeId"];
            String? savedSubjectId = map["subjectId"];
            String? savedValue= map["currentPage"];

            /// 根据学习记录 查找之前学习的是诊学练测/智慧启航/创新优学
            if (savedGradeId != null && savedGradeId == "$gradeId" && savedSubjectId != null && savedSubjectId == "${widget.subjectId}") {
              currentValue = savedValue;
            }
          }
          Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context){
            return WisdomStudyListPage(
              subjectDetailModel?.data?.courseId as int? ?? 0,
              widget.subjectId,
              gradeId,
              scrollController: AutoScrollController(),
              useRecord: !previewUser,
              previewMode: previewUser,
              currentValue: currentValue,
            );
          }));
        },
      ),
    );
  }

  ///
  /// @description 构建专题讲解卡片
  /// @param
  /// @return
  /// @author waitwalker
  /// @time 12/7/20 10:27 AM
  ///
  _buildLiveCardWidget() {
    return Padding(padding: EdgeInsets.only(left: 16, right: 16, top: 16),
      child: InkWell(
        child: Container(
          height: SingletonManager.sharedInstance!.isPadDevice ? 180 : 104,
          width: MediaQuery.of(context).size.width - 32,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(11),
            gradient: LinearGradient(colors: [
              Color(0xff6FA8FF),
              Color(0xff6FA8FF)
            ]),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(padding: EdgeInsets.only(left: 19),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("专题讲解", style: TextStyle(fontWeight: FontWeight.bold, fontSize: SingletonManager.sharedInstance!.isPadDevice ? 24 : 19, color: Colors.white),),
                    Padding(padding: EdgeInsets.only(top: 5)),
                    Text("在线学习专题精讲", style: TextStyle(fontSize: SingletonManager.sharedInstance!.isPadDevice ? 20 : 12, color: Colors.white),),
                  ],),
              ),
              Padding(padding: EdgeInsets.only(right: 26),
                child: Image(image: AssetImage("static/images/subject_live_icon.png"), width: SingletonManager.sharedInstance!.isPadDevice ? 120 : 80, height: SingletonManager.sharedInstance!.isPadDevice ? 120 : 80, fit: BoxFit.fill,),),
            ],),
        ),
        onTap: (){
          Navigator.of(context).push(MaterialPageRoute(
              builder: (BuildContext context) => LivePage(
                subjectId: widget.subjectId,
                gradeId: gradeId,
                courseId: subjectDetailModel?.data?.courseId as int? ?? 0,
                previewMode: previewMode,
              )));
        },
      ),
    );
  }

  ///
  /// @description 构建智能题库卡片
  /// @param
  /// @return
  /// @author waitwalker
  /// @time 12/7/20 10:27 AM
  ///
  _buildIntelligenceCardWidget() {
    return Padding(padding: EdgeInsets.only(left: 16, right: 16, top: 18),
      child: InkWell(
        child: Container(
          height: SingletonManager.sharedInstance!.isPadDevice ? 180 : 104,
          width: MediaQuery.of(context).size.width - 32,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(11),
            gradient: LinearGradient(colors: [
              Color(0xff9DDF5C),
              Color(0xff9DDF5C),
            ]),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(padding: EdgeInsets.only(left: 19),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("智能练习", style: TextStyle(fontWeight: FontWeight.bold, fontSize: SingletonManager.sharedInstance!.isPadDevice ? 24 : 19, color: Colors.white),),
                    Padding(padding: EdgeInsets.only(top: 5)),
                    Text("海量试题 自主练习", style: TextStyle(fontSize: SingletonManager.sharedInstance!.isPadDevice ? 20 : 12, color: Colors.white),),
                  ],),
              ),
              Padding(padding: EdgeInsets.only(right: 26),
                child: Image(image: AssetImage("static/images/subject_intelligence_icon.png"), width: SingletonManager.sharedInstance!.isPadDevice ? 120 : 80, height: SingletonManager.sharedInstance!.isPadDevice ? 120 : 80, fit: BoxFit.fill,),),
            ],),
        ),
        onTap: () {
          if (previewUser) {
            Fluttertoast.showToast(msg: "智能题库功能需要开通智领课程权限，请联系客服老师。");
          } else {
            Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context){
              return IntelligenceEntrancePage(
                subjectDetailModel?.data?.courseId as int? ?? 0,
                widget.subjectId,
                gradeId,
                previewMode: false,
              );
            }));
          }
        },
      ),
    );
  }

  ///
  /// @description
  /// @param
  /// @return
  /// @author waitwalker
  /// @time 3/26/21 1:37 PM
  ///
  List<Widget> _buildBodyListWidget() {
    if (widget.cardType == 3) {
      return <Widget>[
        /// 顶部
        _buildTopWidget(),

        // 智慧学习
        _buildWisdomCardWidget(),

        // AI
        _buildAICardWidget(),

        /// 专题讲解
        if (showLiveCard)
          _buildLiveCardWidget(),

        // 智能题库
        _buildIntelligenceCardWidget(),

        SizedBox(height: 40,),
      ];
    } else {
      return <Widget>[

        /// 顶部
        _buildTopWidget(),

        // 智慧学习
        _buildWisdomCardWidget(),

        // AI
        _buildAICardWidget(),

        // 智能组卷等
        _buildIntelligenceCardWidget(),

        if (SingletonManager.sharedInstance!.screenWidth > 500.0)
          SizedBox(height: 80,),
      ];
    }
  }

  @override
  void didChangeDependencies() {
    print("didChangeDependencies");
    super.didChangeDependencies();
  }

  @override
  void deactivate() {
    print("页面即将销毁");
    super.deactivate();
  }

  @override
  void dispose() {
    print("页面销毁");
    super.dispose();
  }
}
