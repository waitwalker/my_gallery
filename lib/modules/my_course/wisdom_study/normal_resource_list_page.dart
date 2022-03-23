import 'dart:async';
import 'dart:io';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:my_gallery/common/const/api_const.dart';
import 'package:my_gallery/common/dao/original_dao/analysis.dart';
import 'package:my_gallery/common/network/network_manager.dart';
import 'package:my_gallery/common/logger/logger.dart';
import 'package:my_gallery/common/tools/share_preference/share_preference.dart';
import 'package:my_gallery/model/material_model.dart';
import 'package:my_gallery/model/micro_course_resource_model.dart';
import 'package:my_gallery/model/wisdom_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:my_gallery/common/dao/original_dao/course_dao_manager.dart';
import 'package:my_gallery/common/network/response.dart';
import 'package:my_gallery/common/singleton/singleton_manager.dart';
import 'package:my_gallery/model/self_study_record.dart';
import 'package:my_gallery/modules/my_course/ai_test/ai_webview_page.dart';
import 'package:my_gallery/modules/my_course/wisdom_study/test_paper_page.dart';
import 'package:my_gallery/modules/my_course/wisdom_study/video_play_widget.dart';
import 'package:my_gallery/modules/my_course/wisdom_study/wisdom_resource_model.dart';
import 'package:my_gallery/modules/widgets/alert/activity_alert.dart';
import 'package:my_gallery/modules/widgets/webviews/common_webview_page.dart';
import 'package:my_gallery/modules/widgets/empty_placeholder/empty_placeholder_widget.dart';
import 'package:my_gallery/modules/widgets/loading/list_type_loading_placehold_widget.dart';
import 'package:async/async.dart';
import 'package:my_gallery/modules/widgets/webviews/microcourse_webview.dart';
import 'package:my_gallery/modules/widgets/pdf/pdf_page.dart';
import 'hd_video_page.dart';
import 'micro_course_page.dart';

class NormalResourceListPage extends StatefulWidget {
  final DataEntity dataEntity;
  final bool isLast;
  final int? currentIndex;
  final double? currentOffset;
  final MaterialDataEntity? materialModel;
  final int? courseId;
  final int? subjectId;
  final int? gradeId;
  NormalResourceListPage(this.dataEntity, {this.currentOffset, this.isLast = false, this.materialModel, this.courseId, this.subjectId, this.gradeId, this.currentIndex = 0});
  @override
  State<StatefulWidget> createState() {
    return _NormalResourceListState();
  }
}

class _NormalResourceListState extends State<NormalResourceListPage> {
  /// 页面逻辑
  /// 1.是第一次进来
  /// 1.1 诊没有做过, 诊学练测都是未开始状态.  学练测都不能点击
  /// 1.2 诊做过了(可能在章节模式下做过了,不管是否满分), 如果诊完成了(满分),测展开,否则学展开. 学练测都可以点击
  /// 2. 不是第一次进来, 完成状态依据学练测所学状态, 所有默认全部展开.  都可以点击
  ///

  /// 点击资源log接口传参逻辑&h5链接传参逻辑
  /// 1.诊学练测模式
  /// 1.1 诊 是微课下一个三道题练习log接口传参:patternType=2; h5链接传参:isdiagnosis=1&materialid=&nodeid=&level=
  /// 1.2 学 下微课log接口传参:patternType=1; h5链接传参:isdiagnosis=0&materialid=&nodeid=&level=
  /// 1.3 练 下log接口传参:patternType=1;
  /// 1.4 测 下练习(AB卷)log接口传参:patternType=1; h5链接传参materialid=&nodeid=&level=
  ///
  /// 2.平铺模式
  /// 微课下一个三道题练习log接口传参:patternType=0; h5链接传参:isdiagnosis=0&materialid=&nodeid=&level=
  /// 练习(AB卷)log接口传参:patternType=0; h5链接传参materialid=&nodeid=&level=
  /// 其他资源类型类型log接口传参:patternType=0
  ///
  /// 原有章节模式
  /// 微课下一个三道题练习log接口传参:patternType=0; h5链接传参:isdiagnosis=0&materialid=&nodeid=&level=
  /// 练习(AB卷)log接口传参:patternType=0; h5链接传参materialid=&nodeid=&level=
  /// 其他资源类型类型log接口传参:patternType=0
  ///
  /// 全时自习室
  /// 微课下一个三道题练习h5链接传参taskid=
  /// 练习(AB卷)h5链接传参taskid=

  /// 组高度
  double sectionHeight = 82.0;
  /// 诊学练测组之间的间距
  double sectionMargin = 16.0;
  /// 原点宽高
  double dotHeightWidth = 8.0;
  /// 原点颜色
  Color dotColor = Color(0xff2E96FF);
  /// 行高
  double rowHeight = 50.0;
  /// 时间轴上 间距
  double timelineMargin = 10.0;
  /// 时间轴线宽
  double timelineWidth = 1.0;
  /// 时间轴线颜色
  Color timelineColor = Color(0xffEFEFEF);

  /// 数据源
  WisdomResourceModel? resourceModel;

  /// 以下字段控制诊学练测的展开与关闭 是否可以点击不是由以下字段控制
  bool diagnosisIsOpened = false;
  bool studyIsOpened = false;
  bool practiceIsOpened = false;
  bool testIsOpened = false;

  /// 是否是诊学练测模式
  bool isDiagnosisMode = false;

  AsyncMemoizer? memoizer;
  AppBar? appBar;

  /// 是否根据数据源去刷新
  bool shouldAccordToDataSource = true;

  /// 首次进入点击学练测提示语
  String toastHint = "不要着急，先点击“诊”的图标，了解一下自己实力吧！";

  /// 是否显示弹框提示
  bool shouldShowAlertHint = false;

  bool shouldShowAlert = true;

  Timer? _timer;  // 定义一个变量，在页面销毁时需要用到，如果在定时器内部已经销毁了，可以不需要

  @override
  void initState() {
    super.initState();
    shouldAccordToDataSource = true;
    memoizer = AsyncMemoizer();

    myTimer();

  }

  myTimer() {  // 定义一个函数，将定时器包裹起来
    _timer = Timer.periodic(Duration(milliseconds: 1000), (t) {
      if (SingletonManager.sharedInstance!.shouldRefresh && SingletonManager.sharedInstance!.isCurrentPage) {
        shouldAccordToDataSource = true;
        memoizer = AsyncMemoizer();
        if (this.mounted) {
          setState(() {});
          SingletonManager.sharedInstance!.shouldRefresh = false;
          SingletonManager.sharedInstance!.isCurrentPage = false;
        }
      }
    });
  }


  @override
  dispose() {
    memoizer = null;
    if (_timer != null) {   // 页面销毁时触发定时器销毁
      if (_timer!.isActive) {  // 判断定时器是否是激活状态
        _timer!.cancel();
      }
    }
    super.dispose();
  }

  ///
  /// @description 进度弹框提醒
  /// @param
  /// @return
  /// @author waitwalker
  /// @time 12/14/20 9:22 AM
  ///
  Widget _dialogBuilder(BuildContext context) {
    return CommonAlert(
      height: isDiagnosisMode ? 180 : 140,
      title: "进度说明",
      subTitle: isDiagnosisMode ? "1.根据该课的已学资源数量计算进度,最高到90%\n2.测验里的试卷,任意一卷答题全对,进度直接为100%" : "根据该课的已学资源数量计算进度,最高到100%",
      tapCallBack: () {
        Navigator.of(context).pop();
      },
    );
  }

  Widget _diagnosisDialogBuilder(BuildContext context) {

    return DiagnosisAlert(
      subTitle: "已经有进度，看来你已经学过相关知识了啊，为了方便进一步了解知识的掌握情况，先来测一下吧，放心吧~很快的O(∩_∩)O",
      backgroundTapCallBack: (){
        Navigator.of(context).pop();
      },
      tapCallBack: () {
        Navigator.of(context).pop();
        List<ResourceList> diaList = resourceModel!.data!.diagnosis!.resourceList!;
        ResourceList data = diaList.first;
        AnalysisDao.log(widget.materialModel!.defMaterialId, widget.dataEntity.nodeId, data.resType, data.resId, patternType: 2);
        saveRecord(SelfStudyRecord(id: widget.dataEntity.nodeId, type: 2, gradeId: widget.materialModel!.gradeId, subjectId: widget.materialModel!.subjectId, courseId: widget.courseId, title: data.resName, currentIndex: widget.currentIndex, nodeName: widget.dataEntity.nodeName, currentOffset: widget.currentOffset));
        Navigator.of(context).push(MaterialPageRoute(builder: (_) {
          SharedPrefsUtils.putString("currentValue", "1");
          SingletonManager.sharedInstance!.isCurrentPage = true;
          shouldShowAlert = false;
          var token = NetworkManager.getAuthorization();
          var resourceId = data.resId;
          var courseId = widget.courseId;
          var url ='${APIConst.practiceHost}/practice.html?token=$token&resourceid=$resourceId&courseId=$courseId&isdiagnosis=1&materialid=${widget.materialModel!.defMaterialId}&nodeid=${widget.dataEntity.nodeId}&level=${widget.dataEntity.level! + 1}';
          return MicrocourseWebPage(
            actionT: 1,
            initialUrl: url,
            resourceId: resourceId,
            resourceName: data.resName,
            level: widget.dataEntity.level! + 1 as int?,
            materialid: widget.materialModel!.defMaterialId as int?,
            isdiagnosis: 1,
            nodeid: widget.dataEntity.nodeId as int?,
          );
        })).then((v) {

        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    appBar = AppBar(
      elevation: 0,
      title: Text("", style: TextStyle(color: Colors.white),),
      backgroundColor: Color(0xff579EFF),
      leading: IconButton(icon: Icon(Platform.isIOS ? Icons.arrow_back_ios : Icons.arrow_back, color: Colors.white,), onPressed: (){
        Navigator.pop(context);
      }),
      actions: <Widget>[
        Row(
          children: [
            InkWell(
              child: Image(image: AssetImage("static/images/wisdom_help_icon.png"), width: 16, height: 16, fit: BoxFit.fill,),
              onTap: (){
                showDialog(
                    context: context,
                    builder: _dialogBuilder);
              },
            ),
            Padding(padding: EdgeInsets.only(right: 26)),
          ],
        ),
      ],
    );

    return Scaffold(
      appBar: appBar,
      backgroundColor: Color(0xff579EFF),
      body: _buildBodyFuture(),
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
    Map map = {};
    return FutureBuilder(
      builder: _futureBuilder,
      future: _fetchData(map),
    );
  }


  ///
  /// @description 获取数据
  /// @param
  /// @return
  /// @author waitwalker
  /// @time 12/3/20 9:47 AM
  ///
  _fetchData(map) =>
      memoizer!.runOnce(() => _fetchWisdomData(map));

  ///
  /// @description 获取教材版本&列表数据
  /// @param
  /// @return
  /// @author waitwalker
  /// @time 12/3/20 9:44 AM
  ///
  _fetchWisdomData(Map map) async {
    return CourseDaoManager.wisdomResourceFetchCourseStructure(mapToQuery(
        { "nodeId":"${widget.dataEntity.nodeId}",
          "materialId":"${widget.materialModel!.defMaterialId}",
          "versionId":"${widget.materialModel!.defVersionId}",
          "lastPointStatus":"${widget.isLast ? 1 : 0}",
        }
        ));
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
          return EmptyPlaceholderPage(assetsPath: 'static/images/empty.png', message: '没有数据');
        }

        var data = snapshot.data as ResponseData;
        if (data.code == 200) {
          resourceModel = data.model as WisdomResourceModel?;
          print("是否第一次进入:${resourceModel!.data?.intoStatus}");
          print("是否展开学:${resourceModel!.data!.study?.labelOpen}");
          print("是否展开测:${resourceModel!.data!.test?.labelOpen}");
          if (resourceModel != null && resourceModel!.code! > 0 && resourceModel!.data != null) {
            return _buildListBody(resourceModel!);
          } else {
            return EmptyPlaceholderPage(assetsPath: 'static/images/empty.png', message: '没有数据');
          }
        } else {
          return EmptyPlaceholderPage(assetsPath: 'static/images/empty.png', message: '没有数据');
        }
        break;
      default:
        return EmptyPlaceholderPage(assetsPath: 'static/images/empty.png', message: '没有数据');
    }
  }

  ///
  /// @description 构建列表
  /// @param 
  /// @return 
  /// @author waitwalker
  /// @time 12/4/20 1:59 PM
  ///
  _buildListBody(WisdomResourceModel model) {
    double statusBarHeight = MediaQuery.of(context).padding.top;
    double appBarHeight = appBar!.preferredSize.height;
    var progress = resourceModel!.data!.progress!;
    String p = resourceModel!.data!.progress == 0 ? "0" : resourceModel!.data!.progress.toString();
    String progressTitle = p + "%";
    if (resourceModel!.data != null && shouldAccordToDataSource && resourceModel!.data!.diagnosis != null) {
      shouldAccordToDataSource = false;
      isDiagnosisMode = true;
      // 第一次进入
      if (resourceModel!.data!.intoStatus == 1) {
        /// 如果诊已经完成了, 默认展开测
        if (resourceModel!.data!.diagnosis!.labelStatus != null && resourceModel!.data!.diagnosis!.labelStatus == 2) {
          studyIsOpened = false;
          practiceIsOpened = false;
          testIsOpened = true;
        } else if (resourceModel!.data!.diagnosis!.labelStatus != null && resourceModel!.data!.diagnosis!.labelStatus == 1) {
          /// 如果诊没有完成, 展开学
          studyIsOpened = true;
          practiceIsOpened = false;
          testIsOpened = false;
        } else {
          /// 如果诊没有做,不可展开
          studyIsOpened = false;
          practiceIsOpened = false;
          testIsOpened = false;
        }
        if (resourceModel!.data!.progress! > 0) {
          shouldShowAlertHint = true;
        } else {
          shouldShowAlertHint = false;
        }
      } else {
        /// 不是第一次进入
        shouldShowAlertHint = false;
        studyIsOpened = resourceModel!.data!.study!.labelOpen == 1 ? true : false;
        practiceIsOpened = false;
        testIsOpened = resourceModel!.data!.test!.labelOpen == 1 ? true : false;
      }
    } else {
      shouldShowAlertHint = false;
      isDiagnosisMode = false;
    }

    Future.delayed(Duration(seconds: 1),(){
      if (shouldShowAlertHint && shouldShowAlert) {
        showDialog(
            context: context,
            builder: _diagnosisDialogBuilder);
      }

    });
    return Column(
      children: [
        Container(
          height: 102,
          width: MediaQuery.of(context).size.width,
          color: Color(0xff579EFF),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                height: 82,
                width: MediaQuery.of(context).size.width - 32,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(7.5),
                  boxShadow: [
                    BoxShadow(
                        color: Color(0xcc273F66),
                        offset: Offset(0, 2.5),
                        blurRadius: 10.0,
                        spreadRadius: 0.0)
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Padding(padding: EdgeInsets.only(left: 16),
                            child: Container(
                              child: Text(
                                widget.dataEntity.nodeName!,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(color: Colors.black, fontSize: SingletonManager.sharedInstance!.screenWidth > 500.0 ? 18 : 16, fontWeight: FontWeight.bold),
                                maxLines: 1,
                              ),
                              width: MediaQuery.of(context).size.width - 32 - 32 - 32 - 32 - 12 - 5,
                            ),
                          ),
                          Padding(padding: EdgeInsets.only(left: 15, right: 16),
                            child: Text(progressTitle, style: TextStyle(color: Color(0xff222222), fontSize: 16, fontWeight: FontWeight.bold),),
                          ),
                        ]),
                    Padding(padding: EdgeInsets.only(top: 8)),
                    /// 完成度进度条
                    Container(
                      height: 9,
                      child: Stack(
                        children: [
                          Positioned(child: Container(
                            width: MediaQuery.of(context).size.width - 32 - 32,
                            height: 9,
                            decoration: BoxDecoration(
                              color: Color(0xffEDF0F7),
                              borderRadius: BorderRadius.circular(5.5),
                            ),
                          )),
                          Positioned(child: Container(
                            width: (MediaQuery.of(context).size.width - 32 - 32) * progress / 100.0,
                            height: 9,
                            decoration: BoxDecoration(
                              color: progress >= 75.0 ?
                              Color(0xffF5A55C) : progress >= 50.0 ?
                              Color(0xffFCC849) : progress >= 25.0 ?
                              Color(0xff4EE7C8) :
                              Color(0xff4BADFF),
                              borderRadius: BorderRadius.circular(5.5),
                            ),
                          )),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        /// 带圆角
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(topLeft: Radius.circular(25)),
            color: Colors.white,
          ),
          height: MediaQuery.of(context).size.height - appBarHeight - statusBarHeight - 102,
          child: Padding(
            padding: EdgeInsets.only(top: 20),
            child: Column(
              children: [
                Expanded(
                  child: EasyRefresh(
                    child: !(model.data!.ordinary != null && model.data!.ordinary!.resourceList!.isNotEmpty) ? _buildDiagnosisListWidget() : _buildOrdinaryListWidget(),
                    firstRefresh: false,
                    onRefresh: _onRefresh,
                    header: ClassicalHeader(
                      textColor: Color(0xff579EFF),
                      infoColor: Color(0xff579EFF),
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
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
  
  ///
  /// @description 刷新方法添加
  /// @param
  /// @return
  /// @author waitwalker
  /// @time 2020/11/5 3:10 PM
  ///
  Future<Null> _onRefresh() async{
    shouldShowAlert = true;
    shouldAccordToDataSource = true;
    memoizer = AsyncMemoizer();
    if (this.mounted) {
      setState(() {});
    }
  }

  ///
  /// @description 绘制诊学练测列表容器
  /// @param 
  /// @return 
  /// @author waitwalker
  /// @time 12/14/20 8:56 AM
  ///
  _buildDiagnosisListWidget() {
    return ListView(children: [
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// 左边间距
          Padding(padding: EdgeInsets.only(left: 12)),
          /// 左侧时间轴
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              /// 诊 原点距离上部位置
              Padding(padding: EdgeInsets.only(top: (sectionHeight - dotHeightWidth) / 2 )),

              /// 诊 原点位置
              _buildDiagnosisTimelineDotWidget(resourceModel!.data!.diagnosis!.resourceList, 1),

              Padding(padding: EdgeInsets.only(top: timelineMargin)),
              
              /// 诊下部线段
              Container(
                height: (diagnosisIsOpened ?
                (sectionHeight - dotHeightWidth) / 2 - timelineMargin +  resourceModel!.data!.diagnosis!.resourceList!.length* rowHeight :
                (sectionHeight - dotHeightWidth) / 2 - timelineMargin) + sectionMargin,
                width: timelineWidth,
                color: timelineColor,
              ),

              /// 学上部线段
              Container(
                height: (sectionHeight - dotHeightWidth) / 2 - timelineMargin,
                width: timelineWidth,
                color: timelineColor,
              ),

              Padding(padding: EdgeInsets.only(top: timelineMargin)),

              /// 学 原点位置
              _buildDiagnosisTimelineDotWidget(resourceModel!.data!.study!.resourceList, 2),

              Padding(padding: EdgeInsets.only(top: timelineMargin)),

              /// 学下部线段
              Container(
                height: (studyIsOpened ?
                (sectionHeight - dotHeightWidth) / 2 - timelineMargin +  resourceModel!.data!.study!.resourceList!.length * rowHeight :
                (sectionHeight - dotHeightWidth) / 2 - timelineMargin) + sectionMargin,
                width: timelineWidth,
                color: timelineColor,
              ),

              /// 练上部线段
              Container(
                height: (sectionHeight - dotHeightWidth) / 2 - timelineMargin,
                width: timelineWidth,
                color: timelineColor,
              ),

              Padding(padding: EdgeInsets.only(top: timelineMargin)),

              /// 练 原点位置
              _buildDiagnosisTimelineDotWidget(resourceModel!.data!.practice!.resourceList, 3),

              Padding(padding: EdgeInsets.only(top: timelineMargin)),

              /// 练下部线段
              Container(
                height: (practiceIsOpened ?
                (sectionHeight - dotHeightWidth) / 2 - timelineMargin +  resourceModel!.data!.practice!.resourceList!.length * rowHeight :
                (sectionHeight - dotHeightWidth) / 2 - timelineMargin) + sectionMargin,
                width: timelineWidth,
                color: timelineColor,
              ),

              /// 测上部线段
              Container(
                height: (sectionHeight - dotHeightWidth) / 2 - timelineMargin,
                width: timelineWidth,
                color: timelineColor,
              ),

              Padding(padding: EdgeInsets.only(top: timelineMargin)),

              /// 测 原点位置
              _buildDiagnosisTimelineDotWidget(resourceModel!.data!.test!.resourceList, 4),

              Padding(padding: EdgeInsets.only(top: 10)),
            ],
          ),
          Padding(padding: EdgeInsets.only(left: 12)),
          
          /// 绘制诊学练测 section列表
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// 诊section&点击事件
              _buildDiagnosisSectionList(resourceModel!.data!.diagnosis!.resourceList!, 1, diagnosisIsOpened),
              Container(height: sectionMargin, width: MediaQuery.of(context).size.width - 48, color: Colors.transparent,),

              /// 学section&点击事件
              _buildDiagnosisSectionList(resourceModel!.data!.study!.resourceList!, 2, studyIsOpened),
              Container(height: sectionMargin, width: MediaQuery.of(context).size.width - 48, color: Colors.transparent,),
              
              /// 练section&点击事件
              _buildDiagnosisSectionList(resourceModel!.data!.practice!.resourceList!, 3, practiceIsOpened),
              Container(height: sectionMargin, width: MediaQuery.of(context).size.width - 48, color: Colors.transparent,),

              /// 测section&点击事件
              _buildDiagnosisSectionList(resourceModel!.data!.test!.resourceList!, 4, testIsOpened),
              Container(height: sectionMargin, width: MediaQuery.of(context).size.width - 48, color: Colors.transparent,),
            ],
          ),
        ],
      ),
    ],
    );
  }

  ///
  /// @description 构建诊学练测时间轴上原点样式
  /// @param
  /// @return
  /// @author waitwalker
  /// @time 12/4/20 2:13 PM
  ///
  _buildDiagnosisTimelineDotWidget(List<ResourceList>? listData, int type) {
    if (resourceModel!.data!.intoStatus == 1) {
      return Container(
        width: dotHeightWidth,
        height: dotHeightWidth,
        decoration: BoxDecoration(
            border: Border.all(width: 2, color: Color(0xffEFEFEF)),
            borderRadius: BorderRadius.circular(dotHeightWidth / 2.0)
        ),
      );
    } else {
      if (type == 1) {
        if (listData!.isNotEmpty) {
          if (resourceModel!.data!.diagnosis!.labelStatus == 2) {
            return Container(
              width: dotHeightWidth,
              height: dotHeightWidth,
              decoration: BoxDecoration(
                  color: dotColor,
                  borderRadius: BorderRadius.circular(dotHeightWidth / 2.0)
              ),
            );
          } else {
            return Container(
              width: dotHeightWidth,
              height: dotHeightWidth,
              decoration: BoxDecoration(
                  border: Border.all(width: 2, color: Color(0xffEFEFEF)),
                  borderRadius: BorderRadius.circular(dotHeightWidth / 2.0)
              ),
            );
          }
        } else {
          return Container(
            width: dotHeightWidth,
            height: dotHeightWidth,
            decoration: BoxDecoration(
                border: Border.all(width: 2, color: Color(0xffEFEFEF)),
                borderRadius: BorderRadius.circular(dotHeightWidth / 2.0)
            ),
          );
        }

      } else if (type == 2) {
        /// 说明诊还没有做 学 练 测不让做,显示未开始
        if (resourceModel!.data!.study!.labelStatus == 2) {
          return Container(
            width: dotHeightWidth,
            height: dotHeightWidth,
            decoration: BoxDecoration(
                color: dotColor,
                borderRadius: BorderRadius.circular(dotHeightWidth / 2.0)
            ),
          );
        } else {
          return Container(
            width: dotHeightWidth,
            height: dotHeightWidth,
            decoration: BoxDecoration(
                border: Border.all(width: 2, color: Color(0xffEFEFEF)),
                borderRadius: BorderRadius.circular(dotHeightWidth / 2.0)
            ),
          );
        }
      } else if (type == 3) {

        /// 说明诊还没有做 学 练 测不让做,显示未开始
        if (resourceModel!.data!.practice!.labelStatus == 2) {
          return Container(
            width: dotHeightWidth,
            height: dotHeightWidth,
            decoration: BoxDecoration(
                color: dotColor,
                borderRadius: BorderRadius.circular(dotHeightWidth / 2.0)
            ),
          );
        } else {
          return Container(
            width: dotHeightWidth,
            height: dotHeightWidth,
            decoration: BoxDecoration(
                border: Border.all(width: 2, color: Color(0xffEFEFEF)),
                borderRadius: BorderRadius.circular(dotHeightWidth / 2.0)
            ),
          );
        }
      } else {
        /// 说明诊还没有做 学 练 测不让做,显示未开始
        if (resourceModel!.data!.test!.labelStatus == 2) {
          return Container(
            width: dotHeightWidth,
            height: dotHeightWidth,
            decoration: BoxDecoration(
                color: dotColor,
                borderRadius: BorderRadius.circular(dotHeightWidth / 2.0)
            ),
          );
        } else {
          return Container(
            width: dotHeightWidth,
            height: dotHeightWidth,
            decoration: BoxDecoration(
                border: Border.all(width: 2, color: Color(0xffEFEFEF)),
                borderRadius: BorderRadius.circular(dotHeightWidth / 2.0)
            ),
          );
        }
      }
    }
  }

  ///
  /// @description 绘制诊学练测section列表 包括section&点击后展开的item
  /// @param 
  /// @return 
  /// @author waitwalker
  /// @time 12/14/20 9:02 AM
  ///
  _buildDiagnosisSectionList(List<ResourceList> listData, int type, bool isOpened) {
    double openHeight = listData.length * rowHeight + sectionHeight;
    return InkWell(
      child: Padding(padding: EdgeInsets.only(left: 0, right: 16),
        child: Container(
          height: isOpened ? openHeight : sectionHeight,
          width: MediaQuery.of(context).size.width - 48,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                  color: Color(0x99B2C1D9),
                  offset: Offset(0, 2.5),
                  blurRadius: 10.0,
                  spreadRadius: 0.0)
            ],
          ),
          child: Column(
            children: [
              _buildDiagnosisSectionWidget(listData, type),
              if (isOpened) Column(children: _buildDiagnosisSectionItemWidget(listData, type),)
            ],
          ),
        ),),
      onTap: (){
        /// section的点击事件
        shouldAccordToDataSource = false;
        if (type == 1) {
          List<ResourceList> diaList = resourceModel!.data!.diagnosis!.resourceList!;
          ResourceList data = diaList.first;
          AnalysisDao.log(widget.materialModel!.defMaterialId, widget.dataEntity.nodeId, data.resType, data.resId, patternType: 2);
          saveRecord(SelfStudyRecord(id: widget.dataEntity.nodeId, type: 2, gradeId: widget.materialModel!.gradeId, subjectId: widget.materialModel!.subjectId, courseId: widget.courseId, title: data.resName, currentIndex: widget.currentIndex, nodeName: widget.dataEntity.nodeName, currentOffset: widget.currentOffset));
          Navigator.of(context).push(MaterialPageRoute(builder: (_) {
            SharedPrefsUtils.putString("currentValue", "1");
            SingletonManager.sharedInstance!.isCurrentPage = true;
            var token = NetworkManager.getAuthorization();
            var resourceId = data.resId;
            var courseId = widget.courseId;
            var url ='${APIConst.practiceHost}/practice.html?token=$token&resourceid=$resourceId&courseId=$courseId&isdiagnosis=1&materialid=${widget.materialModel!.defMaterialId}&nodeid=${widget.dataEntity.nodeId}&level=${widget.dataEntity.level! + 1}';
            return MicrocourseWebPage(
              actionT: 1,
              initialUrl: url,
              resourceId: resourceId,
              resourceName: data.resName,
              level: widget.dataEntity.level! + 1 as int?,
              materialid: widget.materialModel!.defMaterialId as int?,
              isdiagnosis: 1,
              nodeid: widget.dataEntity.nodeId as int?,
            );
          })).then((v) {

          });
        } else if (type == 2) {
          /// 当第一次进来的时候诊没有做  说明其他都不能点击
          if (resourceModel!.data!.intoStatus == 1 && resourceModel!.data!.diagnosis!.labelStatus == 0) {
            Fluttertoast.showToast(msg: toastHint);
            return;
          }

          studyIsOpened = !isOpened;
        } else if (type == 3) {
          if (resourceModel!.data!.intoStatus == 1 && resourceModel!.data!.diagnosis!.labelStatus == 0) {
            Fluttertoast.showToast(msg: toastHint);
            return;
          }

          ResourceList resourceList = resourceModel!.data!.practice!.resourceList!.first;
          AnalysisDao.log(widget.materialModel!.defMaterialId, widget.dataEntity.nodeId, 5, resourceList.resId, patternType: 1);
          saveRecord(SelfStudyRecord(id: widget.dataEntity.nodeId, type: 2, gradeId: widget.materialModel!.gradeId, subjectId: widget.materialModel!.subjectId, courseId: widget.courseId, title: resourceList.resName, currentIndex: widget.currentIndex, nodeName: widget.dataEntity.nodeName, currentOffset: widget.currentOffset));
          if (resourceList.aiNodeId != null) {
            SharedPrefsUtils.putString("currentValue", "1");
            Navigator.of(context).push(MaterialPageRoute(builder: (_) {
              var token = NetworkManager.getAuthorization();
              var versionId = widget.materialModel!.defVersionId;
              var subjectId = widget.materialModel!.subjectId;
              var nodeId = resourceList.aiNodeId;
              var url = '${APIConst.practiceHost}/ai.html?token=$token&versionid=$versionId&currentdirid=$nodeId&subjectid=$subjectId&courseid=${widget.courseId}';
              /// 跳转到AI详情页面
              return AIWebPage(
                currentDirId: nodeId.toString(),
                versionId: versionId.toString(),
                subjectId: subjectId.toString(),
                initialUrl: url,
                title: resourceList.resName,
              );
            })).then((_) {
              shouldAccordToDataSource = true;
              memoizer = AsyncMemoizer();
              if (this.mounted) {
                setState(() {});
              }
            });
          }

        } else if (type == 4) {
          if (resourceModel!.data!.intoStatus == 1 && resourceModel!.data!.diagnosis!.labelStatus == 0) {
            Fluttertoast.showToast(msg: toastHint);
            return;
          }
          testIsOpened = !isOpened;
        }

        setState(() {

        });
      },
    );
  }

  /// 诊学练测 section数据源
  Map _dataMap = {
    1:{
      "imagePath":"static/images/resource_diagnosis_icon.png",
      "title":"诊 DIAGNOSE",
      "subTitle":"了解知识短板，掌握弱项",
    },
    2:{
      "imagePath":"static/images/resource_study_icon.png",
      "title":"学 LEARN",
      "subTitle":"查漏补缺，精准提高",
    },
    3:{
      "imagePath":"static/images/resource_practice_icon.png",
      "title":"练 EXERCISE",
      "subTitle":"巩固练习，百炼成钢",
    },
    4:{
      "imagePath":"static/images/resource_test_icon.png",
      "title":"测 TEST",
      "subTitle":"检查知识，验证自己",
    },
  };

  ///
  /// @description 绘制诊学练测模式 section组件
  /// @param 
  /// @return 
  /// @author waitwalker
  /// @time 12/14/20 8:54 AM
  ///
  _buildDiagnosisSectionWidget(List<ResourceList> listData, int type) {
    Map map = _dataMap[type];
    String imagePath = map["imagePath"];
    String title = map["title"];
    String subTitle = map["subTitle"];
    return Container(
      height: sectionHeight,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(padding: EdgeInsets.only(left: 16),
            child: Row(children: [
              Image(image: AssetImage(imagePath), width: 44, height: 44, fit: BoxFit.fill,),
              Padding(padding: EdgeInsets.only(left: 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black),),
                    Padding(padding: EdgeInsets.only(top: 3)),
                    Text(subTitle, style: TextStyle(fontSize: 12, color: Color(0xff222222)),),
                  ],
                ),
              ),
            ],),
          ),
          _buildDiagnosisSectionFinishStatusWidget(listData, type),
        ],
      ),
    );
  }

  ///
  /// @description 绘制诊学练测模式下section 尾部完成状态
  /// @param 
  /// @return 
  /// @author waitwalker
  /// @time 12/14/20 8:53 AM
  ///
  _buildDiagnosisSectionFinishStatusWidget(List<ResourceList> listData, int type) {
    if (type == 1) {
      if (resourceModel!.data!.diagnosis!.labelStatus == 2) {
        return Padding(padding: EdgeInsets.only(right: 15),
          child: Image(image: AssetImage("static/images/wisdom_resource_finish.png"), width: 48, height: 48, fit: BoxFit.fill,),
        );
      } else if (resourceModel!.data!.diagnosis!.labelStatus == 1) {
        return Padding(padding: EdgeInsets.only(right: 15),
          child: Text("进行中", style: TextStyle(fontSize: 12, color: Color(0xff222222)),),
        );
      } else {
        return Padding(padding: EdgeInsets.only(right: 15),
          child: Text("马上开始", style: TextStyle(fontSize: 14, color: Color(0xff4BADFF), fontWeight: FontWeight.bold)),
        );
      }

    } else if (type == 2) {
      /// 第一次进入 显示未开始
      if (resourceModel!.data!.intoStatus == 1) {
        return Padding(padding: EdgeInsets.only(right: 15),
          child: Icon(Icons.lock, size: 20),
        );
      } else {
        /// 不是第一次进来 根据完成状态显示
        if (resourceModel!.data!.study!.labelStatus == 2) {
          return Padding(padding: EdgeInsets.only(right: 15),
            child: Image(image: AssetImage("static/images/wisdom_resource_finish.png"), width: 48, height: 48, fit: BoxFit.fill,),
          );
        } else if (resourceModel!.data!.study!.labelStatus == 1) {
          return Padding(padding: EdgeInsets.only(right: 15),
            child: Text("进行中", style: TextStyle(fontSize: 12, color: Color(0xff222222)),),
          );
        } else {
          return Padding(padding: EdgeInsets.only(right: 15),
            child: Text("未开始", style: TextStyle(fontSize: 12, color: Color(0xffB1B1B1)),),
          );
        }
      }

    } else if (type == 3) {
      /// 第一次进入 显示未开始
      if (resourceModel!.data!.intoStatus == 1) {
        return Padding(padding: EdgeInsets.only(right: 15),
          child: Icon(Icons.lock, size: 20),
        );
      } else {
        /// 不是第一次进来 根据完成状态显示
        if (resourceModel!.data!.practice!.labelStatus == 2) {
          return Padding(padding: EdgeInsets.only(right: 15),
            child: Image(image: AssetImage("static/images/wisdom_resource_finish.png"), width: 48, height: 48, fit: BoxFit.fill,),
          );
        } else if (resourceModel!.data!.practice!.labelStatus == 1) {
          return Padding(padding: EdgeInsets.only(right: 15),
            child: Text("进行中", style: TextStyle(fontSize: 12, color: Color(0xff222222)),),
          );
        } else {
          return Padding(padding: EdgeInsets.only(right: 15),
            child: Text("未开始", style: TextStyle(fontSize: 12, color: Color(0xffB1B1B1)),),
          );
        }
      }
    } else {
      /// 第一次进入 显示未开始
      if (resourceModel!.data!.intoStatus == 1) {
        return Padding(padding: EdgeInsets.only(right: 15),
          child: Icon(Icons.lock, size: 20),
        );
      } else {
        /// 不是第一次进来 根据完成状态显示
        if (resourceModel!.data!.test!.labelStatus == 2) {
          return Padding(padding: EdgeInsets.only(right: 15),
            child: Image(image: AssetImage("static/images/wisdom_resource_finish.png"), width: 48, height: 48, fit: BoxFit.fill,),
          );
        } else if (resourceModel!.data!.test!.labelStatus == 1) {
          return Padding(padding: EdgeInsets.only(right: 15),
            child: Text("进行中", style: TextStyle(fontSize: 12, color: Color(0xff222222)),),
          );
        } else {
          return Padding(padding: EdgeInsets.only(right: 15),
            child: Text("未开始", style: TextStyle(fontSize: 12, color: Color(0xffB1B1B1)),),
          );
        }
      }
    }
  }

  ///
  /// @description 构建诊学练测模式 section展开后item组件
  /// @param 
  /// @return 
  /// @author waitwalker
  /// @time 12/14/20 9:08 AM
  ///
  List<Widget> _buildDiagnosisSectionItemWidget(List<ResourceList> listData, int type) {
    List<Widget> children = [];
    for(int i =0; i < listData.length; i++){
      ResourceList currentData = listData[i];
      children.add(
        InkWell(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: (listData.length == i + 1 )? BorderRadius.only(bottomLeft: Radius.circular(5), bottomRight: Radius.circular(5)) : BorderRadius.circular(0),
            ),
            width: MediaQuery.of(context).size.width- 40,
            height: rowHeight,
            child: i == 0? Column(children: [
              Padding(padding: EdgeInsets.only(top: 0.5)),
              Container(height: 0.5, color: Color(0xffEBEBEB),),
              Container(height: 49,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Padding(padding: EdgeInsets.only(left: 16)),
                        Container(height: 5, width: 5, decoration: BoxDecoration(color: type == 2 ? Color(0xff4BADFF): type == 3 ? Color(0xff4EE7C8) : Color(0xffFCA642), borderRadius: BorderRadius.circular(10)),),
                        Padding(padding: EdgeInsets.only(left: 8)),
                        Container(
                          width: MediaQuery.of(context).size.width - 200,
                          child: Text(currentData.resName!, style: TextStyle(fontSize: currentData.resName!.length > 15 && !SingletonManager.sharedInstance!.isPadDevice ? 9 : 13, color: Color(0xff333333)), maxLines: 1, overflow: TextOverflow.ellipsis,),
                        ),
                      ],
                    ),

                    Row(
                      children: [
                        Padding(padding: EdgeInsets.only(left: 5, right: 3),
                          child: currentData.studyStatus == 1 ? SizedBox(width: 32, height: 10, child: Image(image: AssetImage("static/images/wisdom_all_finish_icon.png"), width: 7, height: 5, fit: BoxFit.fitHeight,),) :
                          currentData.studyStatus == 2 ? Container(width: 32, height: 16,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Color(0xffDFEFFF),
                              borderRadius: BorderRadius.circular(2),
                            ),
                            child: Text("推荐", style: TextStyle(fontSize: 11, color: Color(0xff2E96FF)),),): Container(),
                        ),

                        Padding(padding: EdgeInsets.only(left: 5, right: 10),
                          child: Container(
                            alignment: Alignment.center,
                            width: 32,
                            height: 18,
                            decoration: BoxDecoration(
                              color: Color(0xffF5F5F5),
                              borderRadius: BorderRadius.circular(2),
                            ),
                            child: Text(_getResTypeName(currentData.resType as int?), style: TextStyle(fontSize: 11, color: Color(0xff888888)),),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],) :
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Padding(padding: EdgeInsets.only(left: 16)),
                    Container(height: 5, width: 5, decoration: BoxDecoration(color: type == 2 ? Color(0xff4BADFF): type == 3 ? Color(0xff4EE7C8) : Color(0xffFCA642), borderRadius: BorderRadius.circular(10)),),
                    Padding(padding: EdgeInsets.only(left: 8)),
                    Container(
                      width: MediaQuery.of(context).size.width - 200,
                      child: Text(currentData.resName!, style: TextStyle(fontSize: currentData.resName!.length > 15 && !SingletonManager.sharedInstance!.isPadDevice ? 9 : 13, color: Color(0xff333333)), maxLines: 1, overflow: TextOverflow.ellipsis,),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Padding(padding: EdgeInsets.only(left: 5, right: 3),
                      child: currentData.studyStatus == 1 ? SizedBox(width: 32, height: 10, child: Image(image: AssetImage("static/images/wisdom_all_finish_icon.png"), width: 7, height: 5, fit: BoxFit.fitHeight,),) :
                      currentData.studyStatus == 2 ? Container(width: 32, height: 16,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Color(0xffDFEFFF),
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: Text("推荐", style: TextStyle(fontSize: 11, color: Color(0xff2E96FF)),),): Container(),
                    ),

                    Padding(padding: EdgeInsets.only(left: 5, right: 10),
                      child: Container(
                        alignment: Alignment.center,
                        width: 32,
                        height: 18,
                        decoration: BoxDecoration(
                          color: Color(0xffF5F5F5),
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: Text(_getResTypeName(currentData.resType as int?), style: TextStyle(fontSize: 11, color: Color(0xff888888)),),
                      ),
                    ),

                  ],
                ),
              ],
            ),
          ),
          onTap: (){
            print("点击了诊学练测资源");
            _resourceTapAction(currentData, shouldAddPara: true, patternType: 1);
          },
        ),
      );
    }
    return children;
  }

  ///
  /// @description 构建平铺模式下列表
  /// @param 
  /// @return 
  /// @author waitwalker
  /// @time 12/14/20 8:51 AM
  ///
  _buildOrdinaryListWidget() {
    return ListView(children: [
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          /// 间距 12
          Padding(padding: EdgeInsets.only(left: 12)),
          /// 时间轴 8
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: _buildOrdinaryTimelineWidgets(resourceModel!.data!.ordinary!.resourceList!),
          ),
          /// 间距 12
          Padding(padding: EdgeInsets.only(left: 12)),

          Column(
            children: _buildOrdinaryItemWidget(resourceModel!.data!.ordinary!.resourceList!),
          ),
        ],
      ),
    ],
    );
  }

  ///
  /// @description 构建平铺模式下时间轴
  /// @param
  /// @return
  /// @author waitwalker
  /// @time 12/14/20 8:52 AM
  ///
  List<Widget> _buildOrdinaryTimelineWidgets(List<ResourceList> listData) {
    List<Widget> children = [];
    for(int i =0; i < listData.length; i++){
      ResourceList currentData = listData[i];
      children.add(Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          /// 上部线段
          Container(
            height: (sectionHeight - dotHeightWidth) / 2 - timelineMargin,
            width: timelineWidth,
            color: i == 0 ? Colors.transparent : timelineColor,
          ),

          Padding(padding: EdgeInsets.only(top: timelineMargin)),

          /// 原点位置
          currentData.studyStatus == 1 ?  Container(
            width: dotHeightWidth,
            height: dotHeightWidth,
            decoration: BoxDecoration(
                color: dotColor,
                borderRadius: BorderRadius.circular(dotHeightWidth / 2.0)
            ),
          ) : Container(
            width: dotHeightWidth,
            height: dotHeightWidth,
            decoration: BoxDecoration(
                border: Border.all(width: 2, color: Color(0xffEFEFEF)),
                borderRadius: BorderRadius.circular(dotHeightWidth / 2.0)
            ),
          ),

          Padding(padding: EdgeInsets.only(top: timelineMargin)),

          /// 下部线段
          Container(
            height: (sectionHeight - dotHeightWidth) / 2 - timelineMargin,
            width: timelineWidth,
            color: i == listData.length - 1 ? Colors.transparent : timelineColor,
          ),

          Container(height: sectionMargin, width: timelineWidth, color: i == listData.length - 1 ? Colors.transparent : timelineColor,),
        ],
      ),);
    }
    return children;
  }

  ///
  /// @description 构建平铺模式单个item组件
  /// @param
  /// @return
  /// @author waitwalker
  /// @time 12/4/20 3:12 PM
  ///
  List<Widget> _buildOrdinaryItemWidget(List<ResourceList> listData) {
    List<Widget> children = [];
    for(int i =0; i < listData.length; i++){
      ResourceList diagnosisList = listData[i];
      children.add(
        InkWell(
          child: Column(
            children: [
              Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(7.5),
                    boxShadow: [
                      BoxShadow(
                          color: Color(0x99B2C1D9),
                          offset: Offset(0, 2.5),
                          blurRadius: 10.0,
                          spreadRadius: 0.0)
                    ],
                  ),
                  width: MediaQuery.of(context).size.width- 48,
                  height: sectionHeight,
                  child: Row(
                    children: [
                      Padding(padding: EdgeInsets.only(left: 16), child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width - 48 - 48 - 16 - 15 - 15,
                            child: Text(diagnosisList.resName!,
                              style: TextStyle(
                                  fontSize: 16,
                                  color: Color(0xff222222),
                                  fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,),
                          ),
                          Padding(padding: EdgeInsets.only(top: 4)),
                          Text(_getResTypeName(diagnosisList.resType as int?), style: TextStyle(fontSize: 14, color: Color(0xff333333),),),
                        ],),),
                      Padding(padding: EdgeInsets.only(left: 15, right: 15),
                        child: diagnosisList.studyStatus == 1 ?
                        Image(
                          image: AssetImage("static/images/wisdom_resource_finish.png"),
                          width: 48, height: 48, fit: BoxFit.fill,) : Container(),
                      ),
                    ],
                  )),
              Padding(padding: EdgeInsets.only(top: sectionMargin)),
            ],
          ),
          onTap: () async {
            /// 点击了资源
            print("点击了平铺资源");
            _resourceTapAction(diagnosisList, shouldAddPara: true);

          },
        ),
      );
    }
    return children;
  }

  ///
  /// @description 资源点击事件 跳转到资源详情
  /// @param
  /// @return
  /// @author waitwalker
  /// @time 12/4/20 3:29 PM
  ///
  _resourceTapAction(ResourceList currentData, {bool shouldAddPara = false, int patternType = 0}) async{
    SharedPrefsUtils.putString("currentValue", "1");
    AnalysisDao.log(
        widget.materialModel!.defMaterialId,
        widget.dataEntity.nodeId,
        currentData.resType,
        currentData.resId,
        patternType: patternType);
    ResourceIdListEntity clickedItem = ResourceIdListEntity();
    clickedItem.studyStatus = currentData.studyStatus;
    clickedItem.resId = currentData.resId;
    clickedItem.resName = currentData.resName;
    clickedItem.resType = currentData.resType;
    clickedItem.srcABPaperQuesIds = currentData.srcABPaperQuesIds;
    saveRecord(SelfStudyRecord(
        id: widget.dataEntity.nodeId,
        type: 2,
        gradeId: widget.materialModel!.gradeId,
        subjectId: widget.materialModel!.subjectId,
        courseId: widget.courseId,
        title: clickedItem.resName,
        currentIndex: widget.currentIndex,
        nodeName: widget.dataEntity.nodeName,
        currentOffset: widget.currentOffset));
    if (currentData.resType == 3) {
      /// 测验 AB卷
      if (shouldAddPara) {
        Navigator.of(context).push(MaterialPageRoute(builder: (_) {
          return TestPaperPage(
            clickedItem,
            courseId: widget.courseId,
            materialid: widget.materialModel!.defMaterialId as int?,
            nodeid: widget.dataEntity.nodeId as int?,
            level: widget.dataEntity.level! + 1 as int?,);
        })).then((v) {
          shouldAccordToDataSource = true;
          memoizer = AsyncMemoizer();
          if (this.mounted) {
            setState(() {});
          }
        });
      } else {
        Navigator.of(context).push(MaterialPageRoute(builder: (_) {
          return TestPaperPage(clickedItem, courseId: widget.courseId,);
        })).then((v) {
          shouldAccordToDataSource = true;
          memoizer = AsyncMemoizer();
          if (this.mounted) {
            setState(() {});
          }
        });
      }
    } else if (clickedItem.resType == 2) {
      /// 微课
      var microCourseResourceInfo = await CourseDaoManager.getMicroCourseResourceInfo(clickedItem.resId);
      if (microCourseResourceInfo.result) {
        MicroCourseResourceModel model = microCourseResourceInfo.model as MicroCourseResourceModel;
        _toMicroCourse(model.data, widget.courseId, clickedItem.resName, shouldAddPara);
      }
    } else if (clickedItem.resType == 1 || clickedItem.resType == 4) {
      /// 高清课
      var resourceInfo = await CourseDaoManager.getResourceInfo(clickedItem.resId);
      if (resourceInfo.result && resourceInfo.model != null && resourceInfo.model.code == 1) {

        if (clickedItem.resType == 1) {
          // 微视频/高清
          Navigator.of(context).push(MaterialPageRoute(builder: (_) {
            return HDVideoPage(
                source: resourceInfo.model.data.videoUrl,
                title: clickedItem.resName,
                coverUrl: resourceInfo.model.data.imageUrl,
                from: clickedItem.resName,
                videoInfo: VideoInfo(
                  videoUrl: resourceInfo.model.data.videoUrl,
                  videoDownloadUrl: resourceInfo.model.data.downloadVideoUrl,
                  imageUrl: resourceInfo.model.data.imageUrl,
                  resName: resourceInfo.model.data.resourceName,
                  resId: resourceInfo.model.data.resouceId.toString(),
                  courseId: widget.courseId.toString(),
                ));
          })).then((v) {
            shouldAccordToDataSource = true;
            memoizer = AsyncMemoizer();
            if (this.mounted) {
              setState(() {});
            }
          });
        } else {
          /// 导学 文档
          var model = resourceInfo.model;
          if (model.data.literatureDownUrl.endsWith('.pdf') && !SingletonManager.sharedInstance!.isGuanKong!) {
            /// 调到PDF预览页
            Navigator.of(context).push(MaterialPageRoute(builder: (_) {
              return PDFPage(
                model.data.literatureDownUrl,
                title: model.data.resourceName,
                fromZSDX: true,
                resId: model.data.resouceId.toString(),
                officeURL: model.data.literaturePreviewUrl,);
            })).then((v) {
              shouldAccordToDataSource = true;
              memoizer = AsyncMemoizer();
              if (this.mounted) {
                setState(() {});
              }
            });
          } else {
            Navigator.of(context).push(MaterialPageRoute(builder: (_) {
              return CommonWebviewPage(
                initialUrl: resourceInfo.model.data.literaturePreviewUrl,
                downloadUrl: resourceInfo.model.data.literatureDownUrl,
                title: clickedItem.resName,
                pageType: 3,
                resId: "${model.data.resouceId}",
              );
            })).then((v) {
              shouldAccordToDataSource = true;
              memoizer = AsyncMemoizer();
              if (this.mounted) {
                setState(() {});
              }
            });
          }
        }
      } else {
        Fluttertoast.showToast(msg: resourceInfo.model?.msg ?? '获取资源失败');
      }
    } else {
      if (currentData.aiNodeId != null) {
        Navigator.of(context).push(MaterialPageRoute(builder: (_) {
          var token = NetworkManager.getAuthorization();
          var versionId = widget.materialModel!.defVersionId;
          var subjectId = widget.materialModel!.subjectId;
          var nodeId = currentData.aiNodeId;
          var url = '${APIConst.practiceHost}/ai.html?token=$token&versionid=$versionId&currentdirid=$nodeId&subjectid=$subjectId&courseid=${widget.courseId}';
          /// 跳转到AI详情页面
          return AIWebPage(
            currentDirId: nodeId.toString(),
            versionId: versionId.toString(),
            subjectId: subjectId.toString(),
            initialUrl: url,
            title: currentData.resName,
          );
        })).then((_) {
          shouldAccordToDataSource = true;
          memoizer = AsyncMemoizer();
          if (this.mounted) {
            setState(() {});
          }
        });
      }
    }
  }

  ///
  /// @description 章节模式保存学习记录
  /// @param
  /// @return
  /// @author waitwalker
  /// @time 3/11/21 1:57 PM
  ///
  void saveRecord(record) {
    if (record != null &&
        record.id != null &&
        record.subjectId != null &&
        record.gradeId != null &&
        record.type != null &&
        (record.title?.isNotEmpty ?? false)) {
      debugLog(record.toString(), tag: 'save');
      record.type = 11;
      record.studyTime = DateTime.now().millisecondsSinceEpoch;
      record.time = record.studyTime;
      SharedPrefsUtils.put('diagnosis_record', record.toString());
    }
  }

  /// 跳转到微课详情
  void _toMicroCourse(MicroCourseResourceDataEntity? data, dynamic courseId, String? nodeName, bool shouldAddPara) {
    if (shouldAddPara) {
      Navigator.of(context).push(MaterialPageRoute(builder: (_) {
        return MicroCoursePage(
          data,
          courseId: courseId,
          from: nodeName,
          nodeid: widget.dataEntity.nodeId as int?,
          level: widget.dataEntity.level! + 1 as int?,
          isdiagnosis: 0,
          materialid: widget.materialModel!.defMaterialId as int?,);
      })).then((v) {
        shouldAccordToDataSource = true;
        memoizer = AsyncMemoizer();
        if (this.mounted) {
          setState(() {});
        }
      });
    } else {
      Navigator.of(context).push(MaterialPageRoute(builder: (_) {
        return MicroCoursePage(data, courseId: courseId, from: nodeName);
      })).then((v) {
        shouldAccordToDataSource = true;
        memoizer = AsyncMemoizer();
        if (this.mounted) {
          setState(() {});
        }
      });
    }
  }

  /// 1微视频、2微课、3AB卷、4文献
  String _getResTypeName(int? type) {
    var resTypeName;
    switch (type) {
      case 1:
        resTypeName = '微课';
        break;
      case 2:
        resTypeName = '微课';
        break;
      case 3:
        resTypeName = '测验';
        break;
      case 4:
        resTypeName = '导学';
        break;
      default:
        resTypeName = '其他';
    }
    return resTypeName;
  }


}