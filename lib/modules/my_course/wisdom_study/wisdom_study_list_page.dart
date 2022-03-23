import 'dart:convert';
import 'dart:io';
import 'package:flutter_advanced_segment/flutter_advanced_segment.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:keframe/frame_separate_widget.dart';
import 'package:my_gallery/common/dao/original_dao/analysis.dart';
import 'package:my_gallery/common/dao/original_dao/course_dao_manager.dart';
import 'package:my_gallery/common/dao/original_dao/material_dao.dart';
import 'package:my_gallery/common/singleton/singleton_manager.dart';
import 'package:my_gallery/model/material_model.dart';
import 'package:my_gallery/model/micro_course_resource_model.dart';
import 'package:my_gallery/model/wisdom_model.dart';
import 'package:my_gallery/model/self_study_record.dart';
import 'package:my_gallery/modules/my_course/choose_material_version/choose_material_page.dart';
import 'package:my_gallery/modules/my_course/wisdom_study/scroll_to_index/scroll_to_index.dart';
import 'package:my_gallery/common/redux/app_state.dart';
import 'package:my_gallery/modules/my_course/wisdom_study/test_paper_page.dart';
import 'package:my_gallery/modules/my_course/wisdom_study/video_play_widget.dart';
import 'package:my_gallery/modules/widgets/alert/activity_alert.dart';
import 'package:my_gallery/modules/widgets/webviews/common_webview_page.dart';
import 'package:my_gallery/modules/widgets/expanded_listview/expanded_listview.dart';
import 'package:my_gallery/modules/widgets/loading/list_type_loading_placehold_widget.dart';
import 'package:my_gallery/modules/widgets/empty_placeholder/empty_placeholder_widget.dart';
import 'package:my_gallery/common/logger/logger.dart';
import 'package:my_gallery/common/tools/share_preference/share_preference.dart';
import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:my_gallery/modules/widgets/pdf/pdf_page.dart';
import 'package:my_gallery/modules/widgets/style/style.dart';
import 'package:my_gallery/modules/widgets/expanded_listview/wisdom_expanded_listview.dart';
import 'package:redux/redux.dart';
import 'package:umeng_plugin/umeng_plugin.dart';
import 'hd_video_page.dart';
import 'knowledge_guide_list_page.dart';
import 'micro_course_page.dart';


/// 智慧学习 打复习标签页面
/// 这个页面几经改变，有些复杂，修改的时候，注意一下功能
/// 1、record用于记录当前学习的资源
/// 因为是树形菜单，所以record记录了资源的各级父节点
/// 退出到首页，会显示一个飘窗，显示上次学习的课程资源
/// 点击飘窗，直接跳到本页面，打开上次学到的位置，沿途节点都需要展开
/// 还要滚动到改资源
/// 2、预览。如果是没有买卡的用户，前版本是不能到本页的
/// 现在可以了。要求第一章第一节第一知识点下面的前两个资源可以免费看
/// 其他的加锁，点击弹框提示用户咨询客服
///
/// @name WisdomStudyPage
/// @description 智慧学习页面
/// @author waitwalker
/// @date 2020-01-10
///

///
/// @name WisdomStudyListCourseStructurePage
/// @description 智慧学习页面 诊学练测模式
/// @author waitwalker
/// @date 2020-01-10
///
// ignore: must_be_immutable
class WisdomStudyListPage extends StatefulWidget {
  final int type = 2;
  final int? courseId;
  final int? subjectId;
  final int? gradeId;
  AsyncMemoizer? memoizer;

  /// 预览模式，适用于未激活用户，只能看第一条，默认为用户打开
  final bool previewMode;

  /// 上部当前选中的tab
  final String? currentValue;

  final AutoScrollController? scrollController;

  /// 学习记录=>滚动到具体位置
  /// 记录用户点击的资源条目以及所有父列表的条目
  final Record? record;

  final bool useRecord;

  WisdomStudyListPage(this.courseId, this.subjectId, this.gradeId,
      {this.memoizer,
        this.scrollController,
        this.record,
        this.previewMode = false,
        this.useRecord = false,
        this.currentValue = "1",
      });

  @override
  State<StatefulWidget> createState() {
    return _WisdomStudyListPageState();
  }
}

class _WisdomStudyListPageState extends State<WisdomStudyListPage> {
  AsyncMemoizer? memoizer1;
  AsyncMemoizer? memoizer2;
  List<DataEntity>? detailData;
  ResourceIdListEntity? selectedRes;
  SelfStudyRecord? recordValue;
  SelfStudyRecord? diagnosisRecord;

  int? get lastResId => recordValue?.id as int?;
  AutoScrollController? controller;
  AutoScrollController? outerController;

  AutoScrollController? diagnosisController;
  AutoScrollController? diagnosisOuterController;

  ScrollController? scrollController;

  String? _value = "1";

  /// 是否预览
  late bool previewMode;
  double currentOffset = 0.0;
  AdvancedSegmentController? _segmentController;
  @override
  void initState() {
    super.initState();
    _value = widget.currentValue;
    _segmentController = AdvancedSegmentController(_value!);
    _segmentController!.addListener(() {

      print("_segmentController value:${_segmentController!.value}");
      Map<String, dynamic> map = {
        "currentPage" : _segmentController!.value,
        "subjectId" : "${widget.subjectId}",
        "gradeId" : "${widget.gradeId}"
      };
      SharedPrefsUtils.put("wisdomPage", JsonEncoder().convert(map));
      if (_segmentController!.value == "1") {
        widget.memoizer = memoizer1 = AsyncMemoizer();
      } else {
        widget.memoizer = memoizer2 = AsyncMemoizer();
      }
      if (this.mounted) {
        setState(() {
          _value = _segmentController!.value;
          _loadLocalStudyRecord();
        });
      }

    });
    reviewPageContext = context;
    outerController = widget.scrollController;
    controller = AutoScrollController();

    diagnosisOuterController = AutoScrollController();
    diagnosisController = AutoScrollController();
    previewMode = widget.previewMode;
    if (!previewMode) {
      _loadLocalStudyRecord();
    }
    UmengPlugin.beginPageView("智慧学习");
    memoizer1 = widget.memoizer ?? AsyncMemoizer();
    memoizer2 = widget.memoizer ?? AsyncMemoizer();

    scrollController = ScrollController();
    scrollController!.addListener(() {
      print("当前滚动范围:${scrollController!.offset}");
      currentOffset = scrollController!.offset;
      SingletonManager.sharedInstance!.currentOffset = scrollController!.offset;
    });
  }

  @override
  dispose() {
    if (recordValue != null && _value != "1") {
      recordValue!.subjectId = widget.subjectId;
      recordValue!.gradeId = widget.gradeId;
      chapterReviewSaveRecord(recordValue);
    }
    UmengPlugin.endPageView("智慧学习");
    memoizer1 = null;
    memoizer2 = null;
    scrollController!.dispose();
    controller!.dispose();
    outerController!.dispose();
    super.dispose();
  }

  ///
  /// @description 加载本地学习记录
  /// @author waitwalker
  /// @time 3/23/21 9:49 AM
  ///
  _loadLocalStudyRecord() {
    if (_value == "1") {
      var s = widget.useRecord ? SharedPrefsUtils.getString('diagnosis_record', '')! : '';
      Map<String, dynamic>? map;
      try {
        map = jsonDecode(s);
      } on Exception catch (e) {
        print("异常:$e");
      }
      if (map == null || !map.containsKey('type')) {
        diagnosisRecord = SelfStudyRecord(type: 11, subjectId: widget.subjectId, gradeId: widget.gradeId);
        return;
      }

      if (map['type'] == 11) {
        diagnosisRecord = SelfStudyRecord.fromJson(map);
      } else {
        diagnosisRecord = SelfStudyRecord(type: 11, subjectId: widget.subjectId, gradeId: widget.gradeId);
      }
    } else {
      var s = widget.useRecord ? SharedPrefsUtils.getString('record', '')! : '';
      Map<String, dynamic>? map;
      try {
        map = jsonDecode(s);
      } on Exception catch (e) {
        print("异常:$e");
      }
      if (map == null || !map.containsKey('type')) {
        recordValue = SelfStudyRecord(type: 2, subjectId: widget.subjectId, gradeId: widget.gradeId);
        return;
      }

      if (map['type'] == 2) {
        recordValue = SelfStudyRecord.fromJson(map);
      } else {
        recordValue = SelfStudyRecord(type: 2, subjectId: widget.subjectId, gradeId: widget.gradeId);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return StoreBuilder(builder: (BuildContext context, Store<AppState> store) {
      return Scaffold(
        appBar: AppBar(
            title: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  child: AdvancedSegment(
                    borderRadius: BorderRadius.all(Radius.circular(6.0)),
                    backgroundColor: Color(0xff85B9FF),
                    sliderOffset: 0,
                    activeStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xff579EFF),
                      fontSize: SingletonManager.sharedInstance!.isPadDevice ? null : Platform.isIOS ? 12 : 12
                    ),
                    inactiveStyle: TextStyle(
                        color: Colors.white,
                        fontSize: SingletonManager.sharedInstance!.isPadDevice ? null : Platform.isIOS ? 12 : 12
                    ),
                    controller: _segmentController,
                    segments: {
                      '1': '诊学练测',
                      '2': '智慧启航',
                      '3': '创新优学',
                    },
                  ),
                  height: 30,
                ),
              ],
            ),
            backgroundColor: Color(0xff579EFF),
            leading: IconButton(
                icon: Icon(Platform.isIOS ? Icons.arrow_back_ios : Icons.arrow_back, color: Colors.white,),
                onPressed: (){
                  Navigator.pop(context);
            }),
            elevation: 0,
            centerTitle: true,
            actions: <Widget>[
              _rightAction(),
            ]),
        body: _buildBodyFuture(),
        backgroundColor: _value == "1" ? Color(0xff579EFF) : Colors.white,
      );
    });
  }

  ///
  /// @description 
  /// @param 
  /// @return 
  /// @author waitwalker
  /// @time 3/11/21 2:51 PM
  ///
  Widget _rightAction() {
    if (_value == "1") {
      return Row(
        children: [
          InkWell(
            child: Image(image: AssetImage("static/images/wisdom_help_icon.png"), width: 16, height: 16, fit: BoxFit.fill,),
            onTap: (){
              showDialog(
                  context: context,
                  builder: _diagnosisDialogBuilder);
            },
          ),
          Padding(padding: EdgeInsets.only(left: 16)),
        ],
      );
    } else {
      return Row(
        children: [
          InkWell(
            child: Image(image: AssetImage("static/images/icon_learn.png"), width: 16, height: 16, fit: BoxFit.fill,),
            onTap: (){
              _toDoc();
            },
          ),
          Padding(padding: EdgeInsets.only(left: 16)),
        ],
      );
    }
  }

  ///
  /// @description 跳转到知识导学
  /// @param
  /// @return 
  /// @author waitwalker
  /// @time 3/11/21 3:50 PM
  ///
  void _toDoc() {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) {
      return KnowledgeGuideListPage(widget.gradeId, widget.subjectId);
    }));
  }

  /// 400电话弹框
  Widget _diagnosisDialogBuilder(BuildContext context) {
    return CommonAlert(
      height: 140,
      title: "课程进度说明",
      subTitle: "根据课程下包含的每节进度取平均值。",
      tapCallBack: () {
        Navigator.of(context).pop();
      },
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
    if (_value == "1") {
      return FutureBuilder(
        builder: _diagnosisFutureBuilder,
        future: _diagnosisFetchData(widget.subjectId, widget.gradeId, widget.type),
      );
    } else {
      return FutureBuilder(
        builder: _chapterFutureBuilder,
        future: _chapterFetchData(widget.subjectId, widget.gradeId, widget.type),
      );
    }
  }

  ///
  /// @description 获取数据
  /// @param
  /// @return
  /// @author waitwalker
  /// @time 12/3/20 9:47 AM
  ///
  _diagnosisFetchData(subjectId, gradeId, type) =>
      memoizer1!.runOnce(() => _diagnosisFetchWisdomData(subjectId, gradeId, type));

  ///
  /// @description 获取教材版本&列表数据
  /// @param
  /// @return
  /// @author waitwalker
  /// @time 12/3/20 9:44 AM
  ///
  _diagnosisFetchWisdomData(subjectId, gradeId, type) async {
    var response = await MaterialDao.material(subjectId, gradeId, type);
    if (response.result && response.model.code == 1) {
      if (response.model != null && response.model.data != null) {
        var materialId = (response.model as MaterialModel).data!.defMaterialId;
        var materialModel = response.model.data;
        if (this.mounted) {
          setState(() {});
        }
        /// 获取列表数据
        return CourseDaoManager.wisdomListFetchCourseStructure(materialId)
            .then((t) => {'material': materialModel, 'list': t});
      } else {
        return Future.error('教材ID为空');
      }
    }
    return Future.error('获取教材信息失败');
  }

  ///
  /// @description 根据future响应构建widget
  /// @param
  /// @return
  /// @author waitwalker
  /// @time 12/3/20 9:40 AM
  ///
  Widget _diagnosisFutureBuilder(BuildContext context, AsyncSnapshot snapshot) {
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
          if (snapshot.error == "教材ID为空") {
            return EmptyPlaceholderPage(assetsPath: 'static/images/empty.png', message: '没有数据');
          } else {
            return Text('Error: ${snapshot.error}');
          }
        }

        var material = snapshot.data['material'];
        var list = snapshot.data['list'];
        var model = list.model as WisdomModel?;
        var materialModel = material as MaterialDataEntity?;
        detailData = model?.data;
        if (detailData!= null && detailData!.isEmpty) {
          return Column(
            children: [
              Container(height: 80, color: Colors.transparent,
                child: _diagnosisBuildChooseMaterial(materialModel),),
              EmptyPlaceholderPage(assetsPath: 'static/images/empty.png', message: '没有数据'),
            ],
          );
        }
        if (model!= null && model.code != null && model.code == 1 && detailData!.isNotEmpty) {
          /// 如果是体验模式, 将前两条数据置为体验
          if (widget.previewMode) {
            DataEntity dataEntity = detailData![0];
            if (dataEntity.nodeList!.isNotEmpty) {
              DataEntity firstEntity = dataEntity.nodeList!.first;
              firstEntity.previewModeCanTap = true;
              dataEntity.nodeList![0] = firstEntity;
              if (dataEntity.nodeList!.length > 1) {
                DataEntity secondEntity = dataEntity.nodeList![1];
                secondEntity.previewModeCanTap = true;
                dataEntity.nodeList![1] = secondEntity;
              }
            } else {
              dataEntity.previewModeCanTap = true;
            }
            detailData![0] = dataEntity;
          }
          return _diagnosisBuildList(materialModel, detailData);
        }
        return EmptyPlaceholderPage(assetsPath: 'static/images/empty.png', message: '没有数据');
      default:
        return EmptyPlaceholderPage(assetsPath: 'static/images/empty.png', message: '没有数据');
    }
  }

  ///
  /// @description 处理诊学练测学习记录
  /// @author waitwalker
  /// @time 3/23/21 10:59 AM
  ///
  void _loadDiagnosisHistoryStudyRecord() {
    var recordString = SharedPrefsUtils.getString('diagnosis_record', '')!;
    SelfStudyRecord selfStudyRecord;
    if (recordString.isEmpty) {
      diagnosisRecord = SelfStudyRecord(
          id: 100,
          nodeName: "",
          firstId: 100,
          secondId: 100,
          title: "",
          thirdId: 100,
          type: 2,
          gradeId: 100,
          subjectId: 100,
          currentOffset: 0.0,
          currentIndex: 1100,
          courseId: 100);
    } else {
      if (_value == "1") {
        selfStudyRecord = SelfStudyRecord.fromJson(jsonDecode(recordString));
        if (selfStudyRecord.type == 11) {
          if (selfStudyRecord.gradeId == widget.gradeId && selfStudyRecord.subjectId == widget.subjectId) {
            diagnosisRecord = SelfStudyRecord.fromJson(jsonDecode(recordString));
          } else {
            selfStudyRecord.currentIndex = 1100;
            diagnosisRecord = selfStudyRecord;
          }
        } else {
          diagnosisRecord = SelfStudyRecord(
              id: 100,
              nodeName: "",
              firstId: 100,
              secondId: 100,
              title: "",
              thirdId: 100,
              type: 2,
              gradeId: 100,
              subjectId: 100,
              currentOffset: 0.0,
              currentIndex: 1100,
              courseId: 100);
        }
      }
    }
  }

  ///
  /// @description 构建列表
  /// @param
  /// @return
  /// @author waitwalker
  /// @time 12/3/20 9:40 AM
  ///
  Widget _diagnosisBuildList(MaterialDataEntity? materialModel, List<DataEntity>? data) {
    _loadDiagnosisHistoryStudyRecord();
    if (diagnosisRecord!.currentIndex! > 5 && diagnosisRecord!.currentIndex! < 1000) {
      Future.delayed(Duration(milliseconds: 800),(){
        print("滚动的距离:${diagnosisRecord!.currentOffset}");
        scrollController!.animateTo(diagnosisRecord!.currentOffset!, duration: Duration(milliseconds: 200), curve: Curves.ease);
      });
    }

    if (data != null && data.isNotEmpty && data.length > 0) {
      data.add(DataEntity());
    }

    return Column(
      children: <Widget>[
        (data != null && data.isNotEmpty) ?
        /// 数据不为空 展示列表页
        Expanded(
          child: EasyRefresh(
            child: ListView.separated(
              controller: scrollController,
              separatorBuilder: (BuildContext context, int index) =>
                  Divider(color: Colors.transparent, height: index == 0 ? 0 : 16),
              itemBuilder: (BuildContext context, int index) {
                if (index == 0) {
                  return materialModel == null ?
                  SizedBox() :
                  Container(height: 80, color: Colors.transparent,
                    child: _diagnosisBuildChooseMaterial(materialModel),);
                } else {
                  if (index == data.length) {
                    return Container(height: 40,);
                  }
                  return FrameSeparateWidget(child: DiagnosisEntryItem(
                    data[index - 1],
                    currentIndex: index - 1,
                    courseId: widget.courseId,
                    subjectId: widget.subjectId,
                    gradeId: widget.gradeId,
                    materialModel: materialModel,
                    selectedItem: this.selectedRes,
                    scrollController: diagnosisOuterController,
                    previewMode: widget.previewMode,
                    firstItem: index == 0,
                    record: diagnosisRecord,
                    currentOffset: currentOffset,
                    callBack: (value){
                      print("页面返回了");
                      widget.memoizer = memoizer1 = AsyncMemoizer();
                      if (this.mounted) {
                        setState(() {
                        });
                      }
                    },
                    onPress: (clickedItem, [parent]) async {
                      debugLog('---->');
                    },
                  ));
                  return DiagnosisEntryItem(
                    data[index - 1],
                    currentIndex: index - 1,
                    courseId: widget.courseId,
                    subjectId: widget.subjectId,
                    gradeId: widget.gradeId,
                    materialModel: materialModel,
                    selectedItem: this.selectedRes,
                    scrollController: diagnosisOuterController,
                    previewMode: widget.previewMode,
                    firstItem: index == 0,
                    record: diagnosisRecord,
                    currentOffset: currentOffset,
                    callBack: (value){
                      print("页面返回了");
                      widget.memoizer = memoizer1 = AsyncMemoizer();
                      if (this.mounted) {
                        setState(() {
                        });
                      }
                    },
                    onPress: (clickedItem, [parent]) async {
                      debugLog('---->');
                    },
                  );
                }
              },
              itemCount: data.length + 1,
            ),
            firstRefresh: false,
            onRefresh: _diagnosisOnRefresh,
            header: ClassicalHeader(
              textColor: Colors.white,
              infoColor: Colors.white,
              refreshText: "下拉刷新",
              refreshingText: "正在刷新...",
              refreshedText: "刷新完成",
              refreshFailedText: "刷新失败",
              refreshReadyText: "松手刷新",
              noMoreText: "没有更多",
              infoText: "加载时间${DateTime.now().hour}:${DateTime.now().minute > 9 ?
              DateTime.now().minute :"0" + "${DateTime.now().minute}" }",
            ),
            onLoad: null,
          ),
        ) :
        /// 数据为空 展示占位页
        EmptyPlaceholderPage(assetsPath: 'static/images/empty.png', message: '没有数据')
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
  Future<Null> _diagnosisOnRefresh() async{
    widget.memoizer = memoizer1 = AsyncMemoizer();
    if (this.mounted) {
      setState(() {});
    }
  }

  ///
  /// @description 构建选择教材
  /// @param
  /// @return
  /// @author waitwalker
  /// @time 12/3/20 9:41 AM
  ///
  Widget _diagnosisBuildChooseMaterial(MaterialDataEntity? materialModel) {
    String materialTitle = '${materialModel?.defAbbreviation} - ${materialModel?.defMaterialName}';
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(padding: EdgeInsets.only(left: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(padding: EdgeInsets.only(top: 3)),
              Container(child: Text(materialTitle,
                overflow: TextOverflow.ellipsis,
                maxLines: (SingletonManager.sharedInstance!.screenWidth < 500.0 && materialTitle.length > 15) ? 2 : 1,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: SingletonManager.sharedInstance!.screenWidth > 500.0 ? 22 :
                    materialTitle.length > 15 ? 11 :
                    materialTitle.length > 11 ? 12.5 :
                    materialTitle.length > 9 ? 14 : 15.5,
                    fontWeight: FontWeight.w600),),
                width: MediaQuery.of(context).size.width - 220,),
              Padding(padding: EdgeInsets.only(top: SingletonManager.sharedInstance!.screenWidth > 500.0 ? 4 : 8)),
              InkWell(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 6),
                  width: SingletonManager.sharedInstance!.isPadDevice ? 120 : 85,
                  height: SingletonManager.sharedInstance!.isPadDevice ? 30 : 24,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(13.0)),
                    color: Colors.transparent,
                    border: Border.all(color: Color.fromRGBO(255, 255, 255, 0.25), width: 0.5),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Image(
                        image: AssetImage("static/images/wisdom_change_material_icon.png"),
                        width: SingletonManager.sharedInstance!.screenWidth > 500.0 ? 15 : 11,
                        height: SingletonManager.sharedInstance!.screenWidth > 500.0 ? 15 : 11,),
                      const SizedBox(width: 5),
                      Text('切换教材',
                          style: TextStyle(
                              fontSize: SingletonManager.sharedInstance!.screenWidth > 500.0 ? 18 : 12,
                              color: Colors.white))
                    ],
                  ),
                ),
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (_) {
                    return ChooseMaterialPage(
                      subjectId: widget.subjectId,
                      gradeId: widget.gradeId,
                      type: widget.type,
                      materialId: materialModel?.defMaterialId,
                      materialDataEntity: materialModel,
                    );
                  })).then((v) {
                    widget.memoizer = memoizer1 = AsyncMemoizer();
                    if (this.mounted) {
                      setState(() {});
                    }
                  });
                },
              ),
            ],),
        ),
        Padding(padding: EdgeInsets.only(right: 32),
          child: Image(image: AssetImage("static/images/wisdom_top_icon.png"), width: 164, height: 80,),
        ),
      ],
    );
  }

  ///
  /// @description 获取章节/复习模式数据
  /// @param
  /// @return
  /// @author waitwalker
  /// @time 3/11/21 1:48 PM
  ///
  _chapterFetchData(subjectId, gradeId, type) =>
      memoizer2!.runOnce(() => _chapterFetchAllData(subjectId, gradeId, type));

  _chapterFetchAllData(subjectId, gradeId, type) async {
    var response = await MaterialDao.material(subjectId, gradeId, type);
    if (response.result && response.model.code == 1) {
      if (response.model != null && response.model.data != null) {
        var materialId = (response.model as MaterialModel).data!.defMaterialId;
        var materialModel = response.model.data;
        if (this.mounted) {
          setState(() {});
        }
        if (_value == "2") {
          /// 获取列表数据
          return CourseDaoManager.wisdomListFetch(materialId)
              .then((t) => {'material': materialModel, 'list': t});
        } else {
          return CourseDaoManager.wisdomReviewListFetch(materialId,1)
              .then((t) => {'material': materialModel, 'list': t});
        }
      } else {
        return Future.error('教材ID为空');
      }
    }
    return Future.error('获取教材信息失败');
  }

  ///
  /// @description 根据请求结果构建视图
  /// @param
  /// @return
  /// @author waitwalker
  /// @time 3/11/21 1:48 PM
  ///
  Widget _chapterFutureBuilder(BuildContext context, AsyncSnapshot snapshot) {
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
          if (snapshot.error == "教材ID为空") {
            return EmptyPlaceholderPage(assetsPath: 'static/images/empty.png', message: '没有数据');
          } else {
            return Text('Error: ${snapshot.error}');
          }
        }

        var material = snapshot.data['material'];
        var list = snapshot.data['list'];
        var model = list.model as WisdomModel?;
        var materialModel = material as MaterialDataEntity?;
        detailData = model?.data;
        if (detailData == null || detailData!.isEmpty) {
          return Column(
            children: [
              Container(
                  height: 74,
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: _chapterBuildChooseMaterial(materialModel)),
              EmptyPlaceholderPage(assetsPath: 'static/images/empty.png', message: '没有数据'),
            ],
          );
        }
        if (model!.code == 1 && detailData != null) {
          return _fetchBuildList(materialModel, detailData);
        }
        return Expanded(child: Text('什么也没有呢'));
      default:
        return EmptyPlaceholderPage(assetsPath: 'static/images/empty.png', message: '没有数据');
    }
  }

  ///
  /// @description 构建章节/复习模式列表数据
  /// @param
  /// @return
  /// @author waitwalker
  /// @time 3/11/21 1:48 PM
  ///
  Widget _fetchBuildList(MaterialDataEntity? materialModel, List<DataEntity>? data) {

    print("是否正在审核:${SingletonManager.sharedInstance!.reviewStatus}");

    /// 这个函数，用来自动滚动到树形菜单的某一项，滚动距离通过计算得出，不同屏幕有误差
    var scrollToViewport = () =>
        SchedulerBinding.instance!.addPostFrameCallback((d) {
          debugLog('++++++++$d');
          int listTileHeight = 44;
          int firstIndex =
          detailData!.indexWhere((item) => item.nodeId == recordValue?.firstId);
          if (firstIndex == -1) return;
          int secondIndex = detailData![firstIndex].nodeList
              ?.indexWhere((item) => item.nodeId == recordValue?.secondId) ??
              -1;
          int thirdIndex = secondIndex == -1
              ? -1
              : detailData![firstIndex].nodeList![secondIndex].nodeList
              ?.indexWhere((item) => item.nodeId == recordValue?.thirdId) ??
              -1;

          var lastList = secondIndex == -1
              ? detailData![firstIndex]
              : thirdIndex == -1
              ? detailData![firstIndex].nodeList![secondIndex]
              : detailData![firstIndex].nodeList![secondIndex].nodeList![thirdIndex];

          int resIndex = lastList.resourceIdList!
              .indexWhere((item) => item.resId == recordValue?.id);
          double lines = (firstIndex + 1) * (listTileHeight + 10.0) +
              (secondIndex + 1 + thirdIndex + 1) * listTileHeight +
              (resIndex) * 64 + 20 - 74; // 悬浮在顶部的选择教材栏的高度，需要减去，防止覆盖到当前高亮条目
          controller!.animateTo(lines, duration: Duration(seconds: 1), curve: Curves.ease);
          controller!.highlight(recordValue?.firstId as int?);
          // });
        });
    recordValue != null && detailData!.indexWhere((i) => recordValue?.firstId == i.nodeId) != -1
        ? scrollToViewport()
        // ignore: unnecessary_statements
        : null;
    return Column(
      children: <Widget>[
        Divider(height: 0.5),
        materialModel == null ?
        const SizedBox()
            : Stack(alignment: Alignment.bottomCenter,
            children: <Widget>[
              _buildTestHintWidget(),
              // 选择教材版本
              Container(
                height: 74,
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: _chapterBuildChooseMaterial(materialModel),
              ),
            ]),
        (data != null && data.length > 0) ?
        Flexible(
          flex: 1,
          child: ListView.separated(
            controller: controller,
            separatorBuilder: (BuildContext context, int index) =>
                Divider(color: Colors.transparent, height: 2),
            itemBuilder: (BuildContext context, int index) => ChapterEntryItem(
                data[index],
                selectedItem: this.selectedRes,
                scrollController: widget.scrollController,
                previewMode: widget.previewMode,
                firstItem: index == 0,
                chapterRecord: recordValue, onPress: (clickedItem, [parent]) async {
              debugLog('---->');
              if (clickedItem is DataEntity) {
                await _chapterFetchChildren(clickedItem, materialModel!);
              } else if (clickedItem is ResourceIdListEntity) {
                selectedRes = clickedItem;
                recordValue?.id = clickedItem.resId;
                recordValue?.firstId = data[index].nodeId;
                recordValue?.courseId = widget.courseId;
                debugLog(recordValue);
                setState(() {});
                AnalysisDao.log(materialModel!.defMaterialId, parent!.nodeId, clickedItem.resType, clickedItem.resId);
                SharedPrefsUtils.putString("currentValue", _value!);
                if (clickedItem.resType == 3) {
                  /// 测验 卷子
                  Navigator.of(context).push(MaterialPageRoute(builder: (_) {
                    return TestPaperPage(
                      clickedItem,
                      courseId: widget.courseId,
                      materialid: materialModel.defMaterialId as int?,
                      nodeid: parent.nodeId as int?,
                      level: parent.level as int?,);
                  })).then((v) {
                    widget.memoizer = memoizer2 = AsyncMemoizer();
                    if (this.mounted) {
                      setState(() {});
                    }
                  });
                } else if (clickedItem.resType == 2) {
                  /// 微课
                  var microCourseResourceInfo = await CourseDaoManager.getMicroCourseResourceInfo(clickedItem.resId);
                  if (microCourseResourceInfo.result) {
                    MicroCourseResourceModel model = microCourseResourceInfo.model as MicroCourseResourceModel;
                    _chapterToMicroCourse(
                        model.data,
                        widget.courseId,
                        parent.nodeName,
                        dataEntity: parent,
                        materialModel: materialModel);
                  }
                } else if (clickedItem.resType == 1 ||
                    clickedItem.resType == 4 ||
                    clickedItem.resType == 6) {
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
                            from: parent.nodeName,
                            videoInfo: VideoInfo(
                              videoUrl: resourceInfo.model.data.videoUrl,
                              videoDownloadUrl: resourceInfo.model.data.downloadVideoUrl,
                              imageUrl: resourceInfo.model.data.imageUrl,
                              resName: resourceInfo.model.data.resourceName,
                              resId: resourceInfo.model.data.resouceId.toString(),
                              courseId: widget.courseId.toString(),
                            ));
                      })).then((v) {
                        widget.memoizer = memoizer2 = AsyncMemoizer();
                        if (this.mounted) {
                          setState(() {});
                        }
                      });
                    } else {
                      /// 导学 文档
                      var model = resourceInfo.model;
                      if (model.data.literatureDownUrl.endsWith('.pdf') &&
                          !SingletonManager.sharedInstance!.isGuanKong!) {
                        /// 调到PDF预览页
                        Navigator.of(context).push(MaterialPageRoute(builder: (_) {
                          return PDFPage(
                            model.data.literatureDownUrl,
                            title: model.data.resourceName,
                            fromZSDX: true,
                            resId: model.data.resouceId.toString(),
                            officeURL: model.data.literaturePreviewUrl,);
                        })).then((v) {
                          widget.memoizer = memoizer2 = AsyncMemoizer();
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
                          widget.memoizer = memoizer2 = AsyncMemoizer();
                          if (this.mounted) {
                            setState(() {});
                          }
                        });
                      }
                    }
                  } else {
                    Fluttertoast.showToast(msg: resourceInfo.model?.msg ?? '获取资源失败');
                  }
                }
              }
            }),
            itemCount: data.length,
          ),) :
        EmptyPlaceholderPage(assetsPath: 'static/images/empty.png', message: '没有数据')
      ],
    );
  }

  ///
  /// @description 处理审核期的显示状态
  /// @param 
  /// @return 
  /// @author waitwalker
  /// @time 3/19/21 3:44 PM
  ///
  _buildTestHintWidget() {
    if (_value == "2") {
      return Positioned(child: Container(height: 32, color: Colors.white,));
    } else {
      /// 如果iOS平台处于正在审核
      if (SingletonManager.sharedInstance!.reviewStatus != null &&
          SingletonManager.sharedInstance!.reviewStatus == 1 &&
          Platform.isIOS) {
        return Positioned(child: Container(height: 32, color: Colors.white,));
      } else {
        return Positioned(
          child: Container(
            height: 105,
            color: Colors.white,
            child: Padding(
              padding: EdgeInsets.only(top: 10),
              child: Text("创新优学提供复习课程(目前试用阶段)"
              ),
            ),
            alignment: Alignment.topCenter,
          ),
        );
      }
    }
  }

  ///
  /// @description 章节/复习模式选择教材版本
  /// @param
  /// @return
  /// @author waitwalker
  /// @time 3/11/21 1:49 PM
  ///
  Container _chapterBuildChooseMaterial(MaterialDataEntity? materialModel) {
    return Container(
      padding: EdgeInsets.only(left: 15, right: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(
          Radius.circular(6),
        ),
        boxShadow: [
          BoxShadow(
              color: Color(MyColors.shadow),
              offset: Offset(0, 2),
              blurRadius: 10.0,
              spreadRadius: 2.0)
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          materialModel == null
              ? Container()
              : Expanded(
              child: Text(
                '${materialModel.defAbbreviation} - ${materialModel.defMaterialName}',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: SingletonManager.sharedInstance!.screenWidth > 500.0 ? 18 : 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
          ),
          InkWell(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 6),
              width: 75,
              height: 24,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(12.0)),
                color: Color(0xffF4F5F8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(MyIcons.SWITCH, size: 11, color: Color(0xFFA3ABBB)),
                  const SizedBox(width: 5),
                  Text('切换',
                      style: TextStyle(
                          fontSize: SingletonManager.sharedInstance!.screenWidth > 500.0 ? 13 : 11,
                          color: Color(0xFF384A69)))
                ],
              ),
            ),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (_) {
                return ChooseMaterialPage(
                  subjectId: widget.subjectId,
                  gradeId: widget.gradeId,
                  type: widget.type,
                  materialId: materialModel?.defMaterialId,
                  materialDataEntity: materialModel,
                );
              })).then((v) {
                widget.memoizer = memoizer2 = AsyncMemoizer();
                if (this.mounted) {
                  setState(() {});
                }
              });
            },
          ),
        ],
      ),
    );
  }

  ///
  /// @description 获取章节/复习模式子控件数据
  /// @param
  /// @return
  /// @author waitwalker
  /// @time 3/11/21 1:49 PM
  ///
  Future _chapterFetchChildren(clickedItem, MaterialDataEntity materialModel) async {
    var response = await CourseDaoManager.wisdomChapterChildList(
        materialModel.defVersionId,
        materialModel.defMaterialId,
        clickedItem.level + 1,
        clickedItem.nodeId);
    if (response.result && response.model != null && response.model.code == 1) {
      var model = (response.model as WisdomModel);
      clickedItem.nodeList = model.data;
      if (this.mounted) {
        setState(() {});
      }
    }
  }

  ///
  /// @description 跳转到微课详情
  /// @param 
  /// @return 
  /// @author waitwalker
  /// @time 3/11/21 1:55 PM
  ///
  void _chapterToMicroCourse(
      MicroCourseResourceDataEntity? data,
      dynamic courseId,
      String? nodeName, {
        DataEntity? dataEntity,
        MaterialDataEntity? materialModel}) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) {
      return MicroCoursePage(
        data,
        courseId: courseId,
        from: nodeName,
        nodeid: dataEntity!.nodeId as int?,
        level: dataEntity.level as int?,
        isdiagnosis: 0,
        materialid: materialModel!.defMaterialId as int?,
      );
    })).then((v) {
      widget.memoizer = memoizer2 = AsyncMemoizer();
      if (this.mounted) {
        setState(() {});
      }
    });
  }
}

///
/// @description 诊学练测模式 点击回调
/// @param 
/// @return 
/// @author waitwalker
/// @time 3/11/21 1:55 PM
///
typedef void DiagnosisOnPress(item, [DataEntity? parent]);
typedef void DiagnosisCallBack(value);

/// Displays one Entry. If the entry has children then it's displayed
/// with an ExpansionTile.
/// 文档 https://flutterchina.club/catalog/samples/expansion-tile-sample/
// ignore: must_be_immutable
class DiagnosisEntryItem extends StatelessWidget {
  DiagnosisOnPress? onPress;
  DiagnosisCallBack? callBack;
  final DataEntity entry;

  var selectedItem;
  AutoScrollController? scrollController;

  SelfStudyRecord? record;
  bool previewMode;
  bool firstItem;
  MaterialDataEntity? materialModel;
  var courseId;
  var subjectId;
  var gradeId;
  int? currentIndex;
  double? currentOffset;
  DiagnosisEntryItem(this.entry, {
    this.currentOffset,
    this.callBack,
    this.onPress,
    this.selectedItem,
    this.scrollController,
    this.record,
    this.firstItem = false,
    this.previewMode = false,
    this.materialModel,
    this.courseId,
    this.subjectId,
    this.gradeId,
    this.currentIndex});

  /// 构建item
  Widget _diagnosisBuildTiles(
      DataEntity root,
      DiagnosisOnPress? onPress, {
        bool isFirst = false,
        bool isLast = false}) {
    print("当前节点所属层级:${root.level}");
    print("当前节点名称:${root.nodeName}");

    /// 点击回调函数
    DiagnosisOnPress _onPress = (m, [p]) {
      root.level == 1 ? record?.firstId = root.nodeId :
      root.level == 2 ? record?.secondId = root.nodeId :
      root.level == 3 ? record?.thirdId = root.nodeId :
      // ignore: unnecessary_statements
      null;
      onPress!(m, p);
    };

    Color firstColor = Colors.black;
    if (root.level == 1 && currentIndex == record!.currentIndex) {
      firstColor = Color(MyColors.primaryValue);
    } else {
      firstColor = Colors.black;
    }

    Color secondColor = Color(0xff333333);
    if (root.level == 2 && root.nodeName == record!.nodeName) {
      secondColor = Color(MyColors.primaryValue);
    } else {
      secondColor = Color(0xff333333);
    }

    /// 构建子节点
    /// 每一行，如果不是资源，是如下递归生成的树形菜单，
    /// [isFirst]，用于判断当前行是否是第一行，
    /// 注意，不只是当前行是第一行，他的上一层列表项，也必须是第一行
    /// 最终实现，第一章第一节第一知识点，下面的前2个资源免费体验
    List<Widget> children = root.nodeList?.map((m) =>
        _diagnosisBuildTiles(
            m,
            _onPress,
            isFirst: root.nodeList!.indexOf(m) == 0&&isFirst,
            isLast: root.nodeList!.indexOf(m) == root.nodeList!.length - 1))?.toList()
        ?? [];

    if (children.length == 0) {
      /// 章和节的直属资源
      if (root.resourceIdList?.isNotEmpty ?? false) {
        return _diagnosisBuildResourceList(root, root.level as int,
            onPress: _onPress,
            title: root.nodeName!,
            selectedItem: selectedItem,
            record: record,
            previewMode: previewMode,
            isFirst: isFirst,
            scrollController: scrollController);
      }
    } else if ((root.resourceIdList?.length ?? 0) != 0) {
      var buildResourceList = _diagnosisBuildResourceList(root, root.level as int,
          onPress: _onPress,
          title: root.level == 1 ? '本章复习' : '本节复习',
          selectedItem: selectedItem,
          record: record,
          previewMode: previewMode,
          scrollController: scrollController);
      children.add(buildResourceList);
    }

    /// 是否展开
    bool expandOrNot = (previewMode && isFirst) || (record?.firstId == root.nodeId || record?.secondId == root.nodeId || record?.thirdId == root.nodeId) || (record!.currentIndex == currentIndex);

    /// 真正构建的地方
    /// AutoScrollTag 用来实现滚动到指定位置
    return DiagnosisAutoScrollTag(
      color: Colors.transparent,
      index: root.nodeId as int?,
      controller: scrollController,
      highlightColor: Colors.transparent,
      key: PageStorageKey<DataEntity>(root),
      child: Padding(
        padding: EdgeInsets.only(left: (root.level! - 1) * 0.0),
        child: InkWell(
          child: WisdomExpandedList(
            currentOffset: currentOffset,
            callBack: callBack,
            currentIndex: currentIndex,
            subjectId: subjectId,
            gradeId: gradeId,
            courseId: courseId,
            materialModel: materialModel,
            previewMode: previewMode,
            isLast: isLast,
            isChapter: root.level == 1 ? true : false,
            isWisdom: true,
            initiallyExpanded: expandOrNot,
            key: PageStorageKey<DataEntity>(root),
            dataEntity: root,
            title: Expanded(
              child: Text(
                root.level == 1 ? "第${currentIndex! + 1}课  " + root.nodeName!: root.nodeName!,
                overflow: TextOverflow.ellipsis,
                style: root.level == 1 ? TextStyle(color: firstColor, fontSize: SingletonManager.sharedInstance!.screenWidth > 500.0 ? 24 : 16, fontWeight: FontWeight.bold) : TextStyle(color: secondColor, fontSize: SingletonManager.sharedInstance!.screenWidth > 500.0 ? 18 : 14),
              ),
            ),
            children: children,
          ),
          onTap: () => onPress!(root),
        ),
      ),
    );
  }

  /// 构建
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: _diagnosisBuildTiles(entry, onPress, isFirst: firstItem),
    );
  }
}


/// 构建真实节点
/// 资源列表，是树形列表的最里层
/// 树分4层，章 - 节 - 知识点 - 资源
/// 但是，并非所有资源都在知识点下，
/// 接口的数据，章、节都有直属资源，所以接口的数据，还需要简单洗一下：
/// 章下的资源，叫本章复习；节的叫本节复习
Widget _diagnosisBuildResourceList(
    DataEntity root,
    int level, {
      String title = '本节复习',
      DiagnosisOnPress? onPress,
      selectedItem,
      AutoScrollController? scrollController,
      SelfStudyRecord? record,
      bool isFirst = false,
      bool previewMode = false}) {

  List<ResourceIdListEntity> list = root.resourceIdList!;
  if (level < 1 || level > 3) {
    throw FormatException('level must in [1,2,3]!');
  }
  bool expanded = (previewMode && isFirst) ||
      (list.where((l) => l.resId == record?.id).toList().isNotEmpty);

  print("level2节点名称:$title");

  /// 构建资源widget 四种
  Widget resWidget = Container(
    padding: EdgeInsets.only(left: 1 * 0.0),
    child: WisdomExpandedList(
      initiallyExpanded: expanded,
      key: PageStorageKey<DataEntity>(root),
      dataEntity: root,
      title: Expanded(
        child: Text(
          title, overflow: TextOverflow.ellipsis,
          style: TextStyle(
              color: Colors.black,
              fontSize: SingletonManager.sharedInstance!.screenWidth > 500.0 ? 18 : 14),
        ),
      ),
      children: list.map<Widget>((l) => reviewResBuilder(
        l,
        index: list.indexOf(l),
        isLast: list.indexOf(l) == list.length - 1,
        scrollController: scrollController,
        previewMode: previewMode,
        isFirst: isFirst,
        record: record,
        onPress: (node, [p]) {
          if (record != null) {
            if (node is DataEntity) {
              record.reset();
              node.level == 1
                  ? record.firstId = node.nodeId
                  : node.level == 2
                  ? record.secondId = node.nodeId
                  : node.level == 3
                  ? record.thirdId = node.nodeId
                  : record.thirdId = -1;
              record.title = node.nodeName;
            } else if (node is ResourceIdListEntity) {
              record.id = node.resId;
              record.title = node.resName;
            }
            diagnosisSaveRecord(record);
          }
          onPress!(node, root);
        },
      ))
          .toList(),
    ),
  );
  return resWidget;
}

///
/// @description 章节模式保存学习记录
/// @param
/// @return
/// @author waitwalker
/// @time 3/11/21 1:57 PM
///
void diagnosisSaveRecord(record) {
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
    SharedPrefsUtils.put('record', record.toString());
  }
}

///
/// @description 章节模式 点击回调
/// @param 
/// @return 
/// @author waitwalker
/// @time 3/11/21 1:55 PM
///
typedef void ChapterOnPress(item, [DataEntity? parent]);
late BuildContext reviewPageContext;

/// Displays one Entry. If the entry has children then it's displayed
/// with an ExpansionTile.
/// 文档 https://flutterchina.club/catalog/samples/expansion-tile-sample/
// ignore: must_be_immutable
class ChapterEntryItem extends StatelessWidget {
  ChapterOnPress? onPress;
  final DataEntity entry;
  var selectedItem;
  AutoScrollController? scrollController;
  SelfStudyRecord? chapterRecord;
  bool previewMode;
  bool firstItem;

  ChapterEntryItem(
      this.entry, {
        this.onPress,
        this.selectedItem,
        this.scrollController,
        this.chapterRecord,
        this.firstItem = false,
        this.previewMode = false});

  /// 构建item
  Widget _buildTiles(DataEntity root, ChapterOnPress? onPress, {bool isFirst = false}) {

    print("当前节点所属层级:${root.level}");
    print("当前节点名称:${root.nodeName}");

    /// 点击回调函数
    ChapterOnPress _onPress = (m, [p]) {
      root.level == 1 ? chapterRecord?.firstId = root.nodeId :
      root.level == 2 ? chapterRecord?.secondId = root.nodeId :
      root.level == 3 ? chapterRecord?.thirdId = root.nodeId : chapterRecord?.thirdId = -1;
      onPress!(m, p);
    };

    /// 构建资源类型widget
    if (root.level == 3) {
      return _buildResourceList(
          root,
          root.level as int,
          title: root.nodeName!,
          onPress: _onPress,
          selectedItem: selectedItem,
          record: chapterRecord,
          previewMode: previewMode,
          isFirst: isFirst,
          scrollController: scrollController);
    }

    /// 构建子节点
    /// 每一行，如果不是资源，是如下递归生成的树形菜单，
    /// [isFirst]，用于判断当前行是否是第一行，
    /// 注意，不只是当前行是第一行，他的上一层列表项，也必须是第一行
    /// 最终实现，第一章第一节第一知识点，下面的前2个资源免费体验
    List<Widget> children = root.nodeList?.map((m) => _buildTiles(m, _onPress, isFirst: root.nodeList!.indexOf(m) == 0&&isFirst))?.toList() ?? [];

    /// 如果章/或者节下没有知识点
    if (children.length == 0) {
      /// 章和节的直属资源 不为空
      if (root.resourceIdList?.isNotEmpty ?? false) {
        return _buildResourceList(
          root,
          root.level as int,
          onPress: _onPress,
          title: root.nodeName!,
          selectedItem: selectedItem,
          record: chapterRecord,
          previewMode: previewMode,
          isFirst: isFirst,
          scrollController: scrollController,
        );
      }
    } else if ((root.resourceIdList?.length ?? 0) != 0) {
      var buildResourceList = _buildResourceList(
        root, root.level as int,
        onPress: _onPress,
        title: root.level == 1 ? '本章复习' : '本节复习',
        selectedItem: selectedItem,
        record: chapterRecord,
        previewMode: previewMode,
        scrollController: scrollController,
      );
      children.add(buildResourceList);
    }

    /// 是否展开
    bool expandOrNot =
        (previewMode && isFirst) ||
        (chapterRecord?.firstId == root.nodeId || chapterRecord?.secondId == root.nodeId || chapterRecord?.thirdId == root.nodeId);

    /// 真正构建的地方
    /// AutoScrollTag 用来实现滚动到指定位置
    return DiagnosisAutoScrollTag(
      index: root.nodeId as int?,
      controller: scrollController,
      highlightColor: Color(MyColors.primaryValue),
      key: PageStorageKey<DataEntity>(root),
      child: Padding(
        padding: EdgeInsets.only(left: (root.level! - 1) * 10.0),
        child: InkWell(
          child: ExpandedList(
            isChapter: root.level == 1 ? true : false,
            isWisdom: true,
            initiallyExpanded: expandOrNot,
            key: PageStorageKey<DataEntity>(root),
            title: Expanded(
              child: Text(
                root.level == 1 ? root.nodeName! : root.nodeName!,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    color: Colors.black,
                    fontSize: SingletonManager.sharedInstance!.screenWidth > 500.0 ? 18 : 14),
              ),
            ),
            children: children,
          ),
          onTap: () => onPress!(root),
        ),
      ),
    );
  }

  /// 构建
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: _buildTiles(entry, onPress, isFirst: firstItem),
    );
  }
}

/// 1微视频、2微课、3AB卷、4文献
///
/// @description 根据资源类型返回对应的资源字符串名称
/// @param
/// @return 
/// @author waitwalker
/// @time 4/16/21 3:32 PM
///
String _chapterResTypeName(int? type) {
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
    case 6:
      resTypeName = '试卷';
      break;
    default:
      resTypeName = '其他';
  }
  return resTypeName;
}

/// 构建真实节点
/// 资源列表，是树形列表的最里层
/// 树分4层，章 - 节 - 知识点 - 资源
/// 但是，并非所有资源都在知识点下，
/// 接口的数据，章、节都有直属资源，所以接口的数据，还需要简单洗一下：
/// 章下的资源，叫本章复习；节的叫本节复习
Widget _buildResourceList(
    DataEntity root,
    int level, {
      String title = '本节复习',
      ChapterOnPress? onPress,
      selectedItem,
      AutoScrollController? scrollController,
      SelfStudyRecord? record,
      bool isFirst = false,
      bool previewMode = false}) {
  List<ResourceIdListEntity> list = root.resourceIdList!;
  if (level < 1 || level > 3) {
    throw FormatException('level must in [1,2,3]!');
  }
  bool expanded = (previewMode && isFirst) || (list.where((l) => l.resId == record?.id).toList().isNotEmpty);
  print("level2节点名称:$title");

  /// 构建资源widget 四种
  Widget resWidget = Container(
    padding: EdgeInsets.only(left: (root.level == 1 && root.nodeList!.isEmpty)? 0.0 : 1 * 10.0),
    child: ExpandedList(
      initiallyExpanded: expanded,
      key: PageStorageKey<DataEntity>(root),
      title: Expanded(
        child: Text(
          title,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
              color: Colors.black,
              fontSize: SingletonManager.sharedInstance!.screenWidth > 500.0 ? 18 : 14),
        ),
      ),
      children: buildChildren(
          list,
          isFirst: isFirst,
          onPress:
          onPress,
          previewMode: previewMode,
          record: record,
          scrollController: scrollController,
          root: root),
    ),
  );
  return resWidget;
}

///
/// @description 构建资源列表
/// @param
/// @return 
/// @author waitwalker
/// @time 4/16/21 2:54 PM
///
List<Widget> buildChildren(
    List<ResourceIdListEntity> list, {
      bool isFirst = false,
      ChapterOnPress? onPress,
      bool previewMode = false,
      SelfStudyRecord? record,
      AutoScrollController? scrollController,
      DataEntity? root}) {
  List<Widget> children = [];
  for(int i = 0; i < list.length; i++) {
    ResourceIdListEntity l = list[i];
    children.add(reviewResBuilder(
      l,
      index: i,
      isLast: i == list.length - 1,
      scrollController: scrollController,
      previewMode: previewMode,
      isFirst: isFirst,
      record: record,
      onPress: (node, [p]) {
        if (record != null) {
          if (node is DataEntity) {
            record.reset();
            node.level == 1 ? record.firstId = node.nodeId :
            node.level == 2 ? record.secondId = node.nodeId :
            node.level == 3 ? record.thirdId = node.nodeId : record.thirdId = -1;
            record.title = node.nodeName;
          } else if (node is ResourceIdListEntity) {
            record.id = node.resId;
            record.title = node.resName;
          }
          chapterReviewSaveRecord(record);
        }
        onPress!(node, root);
      },
    ));
  }
  return children;
}

/// 资源的一条，每一条qi前，有一个timeline，第一条，最后一条特殊处理
///
/// @description 构建具体资源Widget
/// @param
/// @return
/// @author waitwalker
/// @time 4/16/21 3:14 PM
///
Widget reviewResBuilder(
    ResourceIdListEntity l, {
      bool isFirst = false,
      ChapterOnPress? onPress,
      int? index,
      bool isLast = false,
      bool previewMode = false,
      SelfStudyRecord? record,
      AutoScrollController? scrollController}) {
  return Container(
    width: double.infinity,
    // height: 60,
    padding: EdgeInsets.only(left: 2 * 10.0),
    child: Row(
      children: <Widget>[
        timeLine(isFirst: index == 0, isLast: isLast, selected: record?.id == l.resId),
        Expanded(
          child: Container(
            padding: EdgeInsets.only(left: 2 * 10.0),
            child: ListTile(
                contentPadding: EdgeInsets.only(right: 20),
                selected: record?.id == l.resId,
                dense: true,
                title: Text(l.resName!),
                subtitle: Text(_chapterResTypeName(l.resType as int?),
                    style: TextStyle(
                        color: Color(0xFFA9C6DE),
                        fontSize: SingletonManager.sharedInstance!.screenWidth > 500.0 ? 16 : 12)),
                trailing: previewMode ? (index! < 2 && isFirst) ? _tryTag() : _lockTag() :
                l.studyStatus != 1 ? null : Text('已学', style: textStyle12primaryLight),
                onTap: onPress == null ? null :
                (previewMode && (index! >= 2 || !isFirst)) ?
                () {
                  showDialog(
                      context: reviewPageContext,
                      builder: _dialogBuilder);
                } :
                () => onPress(l),
              ),
          ),
        )
      ],
    ),
  );
}

/// 时间轴
Widget timeLine({bool isFirst = false, bool isLast = false, bool selected = false}) {
  return Container(
    height: 64,
    child: Column(
      children: <Widget>[
        Expanded(
          flex: 1,
          child: Container(
            color: isFirst ? Colors.transparent : Color(MyColors.line),
            width: 2,
          ),
        ),
        Container(
          width: 10,
          height: 10,
          decoration: new BoxDecoration(
            border: Border.all(
              color: Color(selected ? MyColors.primaryValue : MyColors.line),
              width: 2.0,
            ),
            boxShadow: selected
                ? [
              BoxShadow(
                  color: Color(MyColors.primaryValue),
                  offset: Offset(0, 0),
                  blurRadius: 10.0,
                  spreadRadius: 0.0)
            ]
                : null,
            shape: BoxShape.circle,
          ),
        ),
        Expanded(
          flex: 2,
          child: Container(
            color: isLast ? Colors.transparent : Color(MyColors.line),
            width: 2,
          ),
        )
      ],
    ),
  );
}

///
/// @description 章节模式保存学习记录
/// @param 
/// @return 
/// @author waitwalker
/// @time 3/11/21 1:57 PM
///
void chapterReviewSaveRecord(record) {
  if (record != null &&
      record.id != null &&
      record.subjectId != null &&
      record.gradeId != null &&
      record.type != null &&
      (record.title?.isNotEmpty ?? false)) {
    debugLog(record.toString(), tag: 'save');
    record.type = 2;
    record.studyTime = DateTime.now().millisecondsSinceEpoch;
    record.time = record.studyTime;
    SharedPrefsUtils.put('record', record.toString());
  }
}

Widget _lockTag() {
  return Icon(Icons.lock, size: 20);
}

Container _tryTag() {
  return Container(
      width: 38,
      height: 20,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(4.0)),
        border: Border.all(
          color: Color(0xFF6B8DFF),
        ),
      ),
      child: Text('体验', style: textStyle11Blue));
}

Widget _dialogBuilder(BuildContext context) {
  return ActivityCourseAlert(
    tapCallBack: () {
      Navigator.of(context).pop();
    },
  );
}

