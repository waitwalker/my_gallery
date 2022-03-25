import 'dart:io';
import 'dart:math';
import 'package:my_gallery/common/singleton/singleton_manager.dart';
import 'package:my_gallery/common/tools/screen_adapt/screen_utils.dart';
import 'package:my_gallery/model/self_study_record.dart';
import 'package:my_gallery/modules/widgets/style/style.dart';
import 'package:my_gallery/common/logger/logger.dart';
import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'live_course_list.dart';


///
/// @name LivePage
/// @description 专题讲解详情页面
/// @author waitwalker
/// @date 2019-12-26
///
// ignore: must_be_immutable
class LivePage extends StatefulWidget {
  int? gradeId;
  int? subjectId;
  int? courseId;
  LiveListRecord? record;
  num tabIndex;
  bool previewMode;

  LivePage(
      {this.subjectId,
        this.gradeId,
        this.record,
        this.tabIndex = 0,
        this.courseId,
        this.previewMode = false});

  @override
  _LivePageState createState() => _LivePageState();
}

class _LivePageState extends State<LivePage>
    with TickerProviderStateMixin {
  TabController? _tabController;

  List<Widget> tabPages = [];
  AsyncMemoizer _memoizer = AsyncMemoizer();
  AsyncMemoizer _memoizer1 = AsyncMemoizer();
  AsyncMemoizer _memoizer2 = AsyncMemoizer();
  int? tabIndex;

  // 是否是高中 1,2,3
  bool isSenior = true;

  @override
  void initState() {
    isSenior = widget.gradeId! > 0 && widget.gradeId! < 4;
    tabIndex = widget.record != null ? widget.record!.tabIndex as int? : widget.tabIndex as int?;
    _tabController = TabController(vsync: this, length: 3, initialIndex: tabIndex!);
    _tabController!.addListener(() {
      _onTabChange(_tabController!.index);
    });
    super.initState();
    //_juniorShowAlert();
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('专题讲解'),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: Platform.isIOS ? true : false,
      ),
      backgroundColor: Color(MyColors.background),
      body: _builderWidget(),
    );
  }

  ///
  /// @description 构建子控件 高中和初中长得不一样
  /// @param 
  /// @return 
  /// @author waitwalker
  /// @time 2021/8/11 09:09
  ///
  _builderWidget() {
    if (isSenior) {
      return Container(
          child: Column(
            children: <Widget>[
              Container(
                padding: EdgeInsets.only(bottom: 5),
                child: Container(
                  child: TabBar(
                    indicatorColor: Color(MyColors.primaryLightValue),
                    indicatorSize: TabBarIndicatorSize.label,
                    indicatorWeight: 4,
                    labelPadding: EdgeInsets.only(bottom: 7),
                    unselectedLabelColor: Color(MyColors.black999),
                    labelColor: Color(MyColors.primaryLightValue),
                    controller: _tabController,
                    tabs: <Widget>[
                      Text(' 当期 ', style: TextStyle(fontSize: SingletonManager.sharedInstance!.screenWidth > 500.0 ? 18 : 14),),
                      Text(' 预告 ', style: TextStyle(fontSize: SingletonManager.sharedInstance!.screenWidth > 500.0 ? 18 : 14),),
                      Text(' 回放 ', style: TextStyle(fontSize: SingletonManager.sharedInstance!.screenWidth > 500.0 ? 18 : 14),),
                    ],
                  ),
                  decoration: _boxDecoration(),
                ),
              ),
              Expanded(
                child: TabBarView(controller: _tabController, children: <Widget>[
                  LiveCourseList(0, _memoizer,
                      isSenior: isSenior,
                      gradeId: widget.gradeId,
                      subjectId: widget.subjectId,
                      courseId: widget.courseId,
                      previewMode: widget.previewMode,
                      record: (widget.record?.tabIndex ?? -1) == 0
                          ? widget.record
                          : null),
                  LiveCourseList(1, _memoizer1,
                      isSenior: isSenior,
                      gradeId: widget.gradeId,
                      subjectId: widget.subjectId,
                      courseId: widget.courseId,
                      previewMode: widget.previewMode,
                      record: (widget.record?.tabIndex ?? -1) == 1
                          ? widget.record
                          : null),
                  LiveCourseList(2, _memoizer2,
                      gradeId: widget.gradeId,
                      isSenior: isSenior,
                      subjectId: widget.subjectId,
                      courseId: widget.courseId,
                      previewMode: widget.previewMode,
                      record: (widget.record?.tabIndex ?? -1) == 2
                          ? widget.record
                          : null),
                ]),
              ),
            ],
          ));
    } else {
      return LiveCourseList(2, _memoizer2,
          gradeId: widget.gradeId,
          subjectId: widget.subjectId,
          courseId: widget.courseId,
          previewMode: widget.previewMode,
          isSenior: isSenior,
          record: (widget.record?.tabIndex ?? -1) == 2
              ? widget.record
              : null);
    }
  }

  BoxDecoration _boxDecoration() {
    return BoxDecoration(
      color: Colors.white,
      boxShadow: [
        BoxShadow(color: Color(0x0F000000), offset: Offset(0, 4), blurRadius: 4.0, spreadRadius: 0.0)
      ],
    );
  }

  Container buildTab(String name, {bool selected = false}) {
    return Container(
      width: 76,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          if (selected)
            Positioned(
              bottom: 0,
              child: tabIndicator(width: 44, height: 4),
            ),
          Text(name, style: selected ? textStyleSubLarge333Bold : textStyleSubLarge333),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _tabController!.dispose();
  }

  void _onTabChange(int index) {
    debugLog('$index');
    tabIndex = index;
    setState(() {});
  }

  tabIndicator({required double width, required double height}) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: const Color(MyColors.primaryValue),
        borderRadius:
        BorderRadius.all(Radius.circular(min(width, height) / 2)), //设置圆角
      ),
    );
  }
}
