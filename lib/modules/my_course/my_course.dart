import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:device_info/device_info.dart';
import 'package:my_gallery/common/config/config.dart';
import 'package:my_gallery/common/dao/manager/dao_manager.dart';
import 'package:my_gallery/common/dao/original_dao/common_api.dart';
import 'package:my_gallery/common/dao/original_dao/course_dao_manager.dart';
import 'package:my_gallery/common/redux/config_reducer.dart';
import 'package:my_gallery/common/singleton/singleton_manager.dart';
import 'package:my_gallery/event/card_activate_event.dart';
import 'package:my_gallery/model/review_status_model.dart' hide DataEntity;
import 'package:my_gallery/modules/my_course/activity_course/activity_entrance_model.dart';
import 'package:my_gallery/model/my_course_model.dart';
import 'package:my_gallery/model/self_study_record.dart';
import 'package:my_gallery/model/user_info_model.dart' hide DataEntity;
import 'package:my_gallery/modules/my_course/junior_activity/junior_grade_page.dart';
import 'package:my_gallery/modules/my_course/wisdom_study/scroll_to_index/scroll_to_index.dart';
import 'package:my_gallery/common/network/error_code.dart';
import 'package:my_gallery/common/network/network_manager.dart';
import 'package:my_gallery/common/network/response.dart';
import 'package:my_gallery/common/redux/app_state.dart';
import 'package:my_gallery/modules/my_course/activity_course/activity_course.dart';
import 'package:my_gallery/modules/my_course/wisdom_study/wisdom_study_list_page.dart';
import 'package:my_gallery/modules/personal/error_book/error_book_subject_list_page.dart';
import 'package:my_gallery/modules/personal/unit_test/unit_test_page.dart';
import 'package:my_gallery/modules/my_course/subject_detail_page.dart';
import 'package:my_gallery/modules/widgets/style/style.dart';
import 'package:my_gallery/modules/widgets/empty_placeholder/empty_placeholder_widget.dart';
import 'package:my_gallery/common/tools/get_grade/grade_utils.dart';
import 'package:my_gallery/common/logger/logger.dart';
import 'package:my_gallery/common/tools/screen_adapt/screen_utils.dart';
import 'package:my_gallery/common/tools/share_preference/share_preference.dart';
import 'package:async/async.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:package_info/package_info.dart';
import 'package:redux/redux.dart';
import 'package:screen/screen.dart';
import 'package:umeng_plugin/umeng_plugin.dart';
import 'package:wakelock/wakelock.dart';
import '../widgets/webviews/common_webview_page.dart';
import 'micro_activity/micro_activity_page.dart';
import 'live/live_page.dart';
import 'class_schedule/class_schedule_page.dart';
import '../widgets/loading/list_type_loading_placehold_widget.dart';

import 'package:flutter_ume/flutter_ume.dart'; // UME 框架
import 'package:flutter_ume_kit_ui/flutter_ume_kit_ui.dart'; // UI 插件包
import 'package:flutter_ume_kit_perf/flutter_ume_kit_perf.dart'; // 性能插件包
import 'package:flutter_ume_kit_show_code/flutter_ume_kit_show_code.dart'; // 代码查看插件包
import 'package:flutter_ume_kit_device/flutter_ume_kit_device.dart'; // 设备信息插件包
import 'package:flutter_ume_kit_console/flutter_ume_kit_console.dart'; // debugPrint 插件包
import 'package:flutter_ume_kit_dio/flutter_ume_kit_dio.dart'; // Dio 网络请求调试工具

///
/// @description 我的课程页面
/// @author waitwalker
/// @time 2021/5/7 10:46
///
class MyCoursePage extends StatefulWidget {
  MyCoursePage({Key? key}) : super(key: key);
  _MyCoursePageState createState() => _MyCoursePageState();
}

class _MyCoursePageState extends State<MyCoursePage> {
  /// 智领卡只有4个学科：[数学，英语，物理，化学]，id分别对应：[2, 3, 4, 5]
  final List<int> zhiLingSubjects = [2, 3, 4, 5];
  List<DataEntity>? courseData;
  bool disconnected = false;

  // 智领卡片数据
  List<DataEntity>? get courseDataZL => courseData?.where((i) => zhiLingSubjects.contains(i.subjectId))?.toList();

  // 智学卡片数据
  List<DataEntity>? get courseDataZX => courseData?.where((i) => !zhiLingSubjects.contains(i.subjectId))?.toList();
  AsyncMemoizer memoizer = AsyncMemoizer();
  AsyncMemoizer memoizerRecommend = AsyncMemoizer();
  AsyncMemoizer memoizerSelfStudy = AsyncMemoizer();
  AsyncMemoizer memoizerLive = AsyncMemoizer();
  Record? record;
  late bool hideHistory;

  /// 是否正在加载
  bool isPageLoading = false;

  ReviewStatusModel? config;

  // 是否有智领权限 默认没有权限 展示免费活动页
  bool hasZhiLingAuth = false;

  @override
  void initState() {
    super.initState();


    // 开启屏幕长亮
    Wakelock.enable();

    Screen.keepOn(true);

    if (SingletonManager.sharedInstance!.isHaveLoadedAlert == false) {
      isPageLoading = true;
      Future.delayed(Duration(seconds: 1),(){
        setState(() {
          isPageLoading = false;
        });
        _pageLoadMethod();
      });
    } else {
      isPageLoading = false;
      _pageLoadMethod();
    }
  }

  ///
  /// @description 页面加载的一些方法
  /// @param
  /// @return
  /// @author waitwalker
  /// @time 12/21/20 9:59 AM
  ///
  _pageLoadMethod() async {
    hideHistory = false;

    /// 当进入到首页的时候 将是否出现过401置为false,也就是没有出现过401
    SingletonManager.sharedInstance!.hasOccur = false;

    /// 加载已学习记录
    _loadStudyRecordData();

    /// 获取激活状态
    _getConfig();

    /// 延迟5s 加载活动课
    if (SingletonManager.sharedInstance!.isHaveLoadedAlert == false) {
      Future.delayed(Duration(seconds: 2), () {
        if (SingletonManager.sharedInstance!.shouldShowActivityCourse) {
          //fetchActivity();
        }
      });
      SingletonManager.sharedInstance!.isHaveLoadedAlert = true;
    }

    /// 先查有没有弹过 如果已经弹过了,就不弹了;没弹过,再弹
    fetchUpgrade();

    ErrorCode.eventBus.on<dynamic>().listen((e) {
      if (e is CardActivateEvent) {
        debugLog('@@@@@@@@@@@===>CODE RECEIVE');
        memoizer = AsyncMemoizer();
        setState(() {});
      }
    });

    // 获取设备信息
    deviceInfo();
  }


  /// 获取升年级信息
  Future fetchUpgrade() async {
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

    /// 如果没有弹过弹框&时间处于7.15-8.15之内
    if (SingletonManager.sharedInstance!.shouldShowChangePassword) {
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  height: ScreenUtil().setHeight(240),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          GestureDetector(
                              child: Icon(Icons.close, color: Colors.white),
                              onTap: () async {
                                Navigator.pop(context);
                                SingletonManager.sharedInstance!.shouldShowChangePassword = false;
                                ResponseData responseData = await DaoManager.fetchChangePasswordHintData();
                                print(responseData);
                              }),
                          Padding(padding: EdgeInsets.only(right: SingletonManager.sharedInstance!.screenWidth > 500.0 ? 30 : 10)),
                        ],
                      ),
                      Padding(padding: EdgeInsets.only(top: 10, left: 20, right: 20),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(6.0)),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                  color: Color(0x66B2C1D9),
                                  offset: Offset(3, 4),
                                  blurRadius: 10.0,
                                  spreadRadius: 2.0)
                            ],
                          ),
                          alignment: Alignment.center,
                          height: 80,
                          child: Padding(padding: EdgeInsets.only(left: 10, right: 10),
                            child: Text("您的密码已经3个月未修改,为了保障账户安全,建议您定期修改密码"),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          });
    }
  }

  ///
  /// @name deviceInfo
  /// @description 获取iOS平台设备信息
  /// @parameters
  /// @return
  /// @author waitwalker
  /// @date 2020/5/28
  ///
  deviceInfo() async {
    if (Platform.isIOS) {
      DeviceInfoPlugin plugin = DeviceInfoPlugin();
      IosDeviceInfo iosDeviceInfo = await plugin.iosInfo;
      SingletonManager.sharedInstance!.deviceName = iosDeviceInfo.name;
    }
  }

  ///
  /// @name _getConfig
  /// @description 获取app当前审核状态状态
  /// @parameters
  /// @return
  /// @author waitwalker
  /// @date 2020/5/7
  ///
  Future _getConfig() async {
    SingletonManager.sharedInstance!.reviewStatus = 0;
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    var versionName = packageInfo.version;
    var response = await CommonServiceDao.configs(ver: versionName);
    if (response.result) {
      config = response.model as ReviewStatusModel?;
      SingletonManager.sharedInstance!.reviewStatus = config!.data!.ia as int?;
      _getStore().dispatch(UpdateConfigAction(config));
    }
  }

  Store<AppState> _getStore() {
    return StoreProvider.of<AppState>(context);
  }

  @override
  Widget build(BuildContext context) {
    /// 获取屏幕宽高
    SingletonManager.sharedInstance!.screenWidth = MediaQuery.of(context).size.width;
    SingletonManager.sharedInstance!.screenHeight = MediaQuery.of(context).size.height;
    return StoreBuilder(builder: (BuildContext context, Store<AppState> store) {
      UserInfoModel userInfoModel = store.state.userInfo!;
      SingletonManager.sharedInstance!.userData = userInfoModel.data;
      if (isPageLoading) {
        return Scaffold(
          appBar: AppBar(
            elevation: 1,
            title: Text(''),
            backgroundColor: Colors.white,
            centerTitle: false,
            actions: <Widget>[
              TextButton(
                child: Row(
                  children: <Widget>[

                  ],
                ),
                onPressed: () {
                  var courses = courseData;
                  Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) =>
                      ClassSchedulePage(
                        subjectId: courses?.first?.subjectId,
                        courseId: courses?.first?.subjectId,),),);
                },
              )
            ],
          ),
          backgroundColor: Color(MyColors.background),
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      } else {
        // 是否有智领权限 没有权限 显示免费活动页
        if (!SingletonManager.sharedInstance!.zhiLingAuthority) {
          var token = NetworkManager.getAuthorization();
          String url = Config.DEBUG ? "http://huodongt.etiantian.com/activity01/zhongkaom.html?token=" : "https://huodong.etiantian.com/freeweb/indexm.html?token=";
          String fullUrl = "$url$token";
          return CommonWebviewPage(initialUrl: fullUrl, title: "北京四中网校-服务公益-实践公益-不忘初心", showBack: true,);
        } else {
          return Scaffold(
            appBar: AppBar(
              elevation: 1,
              title: Text('我的课程'),
              backgroundColor: Colors.white,
              centerTitle: false,
              actions: <Widget>[
                TextButton(
                  child: Row(
                    children: <Widget>[
                      Icon(MyIcons.SCHEDULE, color: Colors.black87,),
                      Padding(padding: EdgeInsets.only(left: 8)),
                      Text('Flu', style: TextStyle(color: Colors.black87),)
                    ],
                  ),
                  onPressed: () async {
                    var courses = courseData;
                    // Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => ClassSchedulePage(subjectId: courses?.first?.subjectId, courseId: courses?.first?.subjectId)));
                    // Navigator.push(context, MaterialPageRoute(builder: (context){
                    //   return FluApp();
                    // }));

                    // PluginManager.instance                                 // 注册插件
                    //   ..register(WidgetInfoInspector())
                    //   ..register(WidgetDetailInspector())
                    //   ..register(ColorSucker())
                    //   ..register(AlignRuler())
                    //   ..register(ColorPicker())                            // 新插件
                    //   ..register(TouchIndicator())                         // 新插件
                    //   ..register(Performance())
                    //   ..register(ShowCode())
                    //   ..register(MemoryInfoPage())
                    //   ..register(CpuInfoPage())
                    //   ..register(DeviceInfoPanel())
                    //   ..register(Console());
                    //   //..register(DioInspector(dio: dio));                  // 传入你的 Dio 实例
                    // // flutter_ume 0.3.0 版本之后
                    // runApp(UMEWidget(child: FluApp(), enable: true));
                    //runApp(FluApp());
                  },
                )
              ],
            ),
            backgroundColor: Color(MyColors.background),
            body: RefreshIndicator(
              child: _buildSingleChildScrollView(),
              onRefresh: _onRefresh,
            ),
            /// 上次作答记录
            floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
            floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
            floatingActionButton: (record != null && !hideHistory)
                ? InkWell(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Stack(
                  children: <Widget>[
                    _buildFloatCard(),
                    Positioned(
                      right: 0,
                      top: 0,
                      child: InkWell(
                        child: Container(
                          child: Icon(Icons.close, size: 15), width: 30, height: 30,),
                        onTap: () {
                          hideHistory = true;
                          setState(() {});
                        },
                      ),
                    )
                  ],
                ),
              ),
              onTap: _toHistory,
            )
                : Container(),
          );
        }
      }
    });
  }

  ///
  /// @name _buildSingleChildScrollView
  /// @description 构建scrollview
  /// @parameters
  /// @return
  /// @author waitwalker
  /// @date 2019-12-23
  ///
  SingleChildScrollView _buildSingleChildScrollView() {
    return SingleChildScrollView(
      physics: BouncingScrollPhysics(),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: disconnected
            ? EmptyPlaceholderPage(onPress: _onRefresh)
            : Column(
          children: <Widget>[
            if (SingletonManager.sharedInstance!.unitTestAuthority)
              /// 构建不同课类型 子Widget
              buildIndicatorRow('质检消错'),
            if (SingletonManager.sharedInstance!.unitTestAuthority)
              const SizedBox(height: 12),
            if (SingletonManager.sharedInstance!.unitTestAuthority)
              buildUnitTestErrorBook(),
            if (SingletonManager.sharedInstance!.unitTestAuthority)
              const SizedBox(height: 20),

            /// 构建不同课类型 子Widget
            buildIndicatorRow('智领课'),
            const SizedBox(height: 12),
            buildZLFuture(),
            const SizedBox(height: 20),

            buildIndicatorRow('北京四中网校暑期公益助学计划'),
            const SizedBox(height: 12),
            buildJuniorCourse(),
            const SizedBox(height: 20),

            buildIndicatorRow('中国联通·北京四中网校名师课堂'),
            const SizedBox(height: 12),
            buildUnionCourse(),
            const SizedBox(height: 20),

            buildIndicatorRow('活动课'),
            const SizedBox(height: 12),
            buildActivityCourse(),
            const SizedBox(height: 20),

            buildIndicatorRow('智学课'),
            const SizedBox(height: 12),
            buildZXFuture(),
            const SizedBox(height: 20),

            if (record != null && !hideHistory) SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Container _buildFloatCard() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        image: DecorationImage(
          alignment: Alignment.center,
          fit: BoxFit.fill,
          image: AssetImage('static/images/bg_pop_up_learning_history.png'),),
        borderRadius: BorderRadius.all(Radius.circular(4.0)), //设置圆角
        boxShadow: [
          BoxShadow(
            color: Color(MyColors.shadow),
            offset: Offset(0, 2),
            blurRadius: 10.0,
            spreadRadius: 2.0,),
        ],
      ),
      // width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.symmetric(horizontal: 14),
      child: Container(
          height: 68,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SizedBox(width: (SingletonManager.sharedInstance!.screenWidth > 500.0) ? 130.0 : 60.0),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text('上次学到', style: textStyle12primaryLight),
                        SizedBox(height: 9),
                        Text('${record!.title}', style: textStyleTitle, maxLines: 1)
                      ]),
                  flex: 1),
              InkWell(
                child: Container(
                  alignment: Alignment.center,
                  height: SingletonManager.sharedInstance!.screenWidth > 500.0 ? 30 : 24,
                  width: SingletonManager.sharedInstance!.screenWidth > 500.0 ? 80 : 62,
                  child: Text('继续学习', style: TextStyle(color: Colors.white, fontSize: SingletonManager.sharedInstance!.screenWidth > 500.0 ? 14 : 11),),
                  decoration: ShapeDecoration(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(4))),
                      shadows: <BoxShadow>[
                        BoxShadow(
                            color: Color(0x46F7B71D),
                            offset: Offset(0, 0),
                            blurRadius: 10.0,
                            spreadRadius: 0.0)
                      ],
                      color: Color(MyColors.btn_solid)),
                ),
                onTap: _toHistory,
              ),
              const SizedBox(width: 26),
            ],
          )),
    );
  }

  ///
  /// @description 加载学习记录
  /// @param
  /// @return 
  /// @author waitwalker
  /// @time 4/1/21 3:14 PM
  ///
  _loadStudyRecordData() {
    var pStr = SharedPrefsUtils.getString('record', '')!;
    var diagnosisStr = SharedPrefsUtils.getString('diagnosis_record', '');
    if (pStr.isEmpty && diagnosisStr!.isEmpty) {
      return;
    }

    if (pStr.length > 0 && diagnosisStr!.length > 0) {
      /// 章节练习/复习/专题讲解等学习记录
      Record firstRecord = Record.fromJson(jsonDecode(pStr));
      /// 诊学练测学习记录
      Record secondRecord = Record.fromJson(jsonDecode(diagnosisStr));

      /// 判断哪个学习记录更新一点
      if (firstRecord.time != null && secondRecord.time != null && firstRecord.time! < secondRecord.time!) {
        record = Record.fromJson(jsonDecode(diagnosisStr));
      } else {
        record = Record.fromJson(jsonDecode(pStr));
      }
    } else if (pStr.length > 0) {
      record = Record.fromJson(jsonDecode(pStr));
    } else if (diagnosisStr!.length > 0) {
      record = Record.fromJson(jsonDecode(diagnosisStr));
    }
  }

  ///
  /// @name buildZLFuture
  /// @description 智领课列表
  /// @parameters
  /// @return
  /// @author waitwalker
  /// @date 2019-12-23
  ///
  buildZLFuture() {
    return FutureBuilder(
      builder: (BuildContext context, AsyncSnapshot snapshot) =>
          _futureBuilder(context, snapshot, false),
      future: _getData(),
    );
  }

  ///
  /// @name buildZXCourseList
  /// @description 构建智学课
  /// @parameters
  /// @return
  /// @author waitwalker
  /// @date 2019-12-23
  ///
  buildZXFuture() {
    return FutureBuilder(
      builder: _futureBuilder,
      future: _getData(),
    );
  }

  // 获取学科所有数据
  _getData() {
    return memoizer.runOnce(CourseDaoManager.newCourses);
  }


  Row buildIndicatorRow(String title) {
    return Row(
      children: <Widget>[
        Indicator(width: 4, height: 14),
        const SizedBox(width: 8),
        Text(title, style: TextStyle(fontSize: SingletonManager.sharedInstance!.screenWidth > 500.0 ? 18 : 15 , fontWeight: FontWeight.bold, color: Colors.black))
      ],
    );
  }

  ///
  /// @name _futureBuilder
  /// @description 智领课/智学课future builder
  /// @parameters
  /// @return
  /// @author waitwalker
  /// @date 2019-12-23
  ///
  Widget _futureBuilder(BuildContext context, AsyncSnapshot snapshot,
      [bool isZL = true]) {
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
        if (snapshot.hasError) return Text('Error: ${snapshot.error}');
        if (!snapshot.hasData) return Text('没有数据');
        if (snapshot.data.model == null) {
          return EmptyPlaceholderPage(
              assetsPath: 'static/images/empty.png',
              message: '请求超时',
              onPress: _onRefresh);
        }
        var liveDetailModel = snapshot.data.model as MyCourseModel;
        courseData = liveDetailModel.data;
        if (courseData == null) return Text('没有数据');
        courseData = liveDetailModel.data;
        return isZL ? _buildZLList() : _buildZXList();
      default:
        return EmptyPlaceholderPage(
            assetsPath: 'static/images/empty.png', message: '没有数据');
    }
  }

  bool isLoading = false;
  Future<void> _onRefresh() async {
    if (isLoading) {
      return;
    }
    ConnectivityResult result = await Connectivity().checkConnectivity();
    if (result == ConnectivityResult.none) {
      return;
    }
    setState(() {
      isLoading = true;
    });

    setState(() {
      isLoading = false;
      memoizer = AsyncMemoizer();
      memoizerRecommend = AsyncMemoizer();
      disconnected = false;
    });
  }

  ///
  /// @name _buildZLList
  /// @description 构建智领列表
  /// @parameters
  /// @return
  /// @author waitwalker
  /// @date 2019-12-23
  ///
  Widget _buildZLList() {
    return GridView.builder(
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: courseDataZX?.length ?? 0,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.8),
      itemBuilder: (BuildContext context, int index) =>
          _buildZLZXItem(context, index, courseDataZX),
    );
  }

  ///
  /// @name _buildZXList
  /// @description 构建智学列表
  /// @parameters
  /// @return
  /// @author waitwalker
  /// @date 2019-12-23
  ///
  Widget _buildZXList() {
    return GridView.builder(
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemBuilder: (BuildContext context, int index) =>
          _buildZLZXItem(context, index, courseDataZL),
      itemCount: courseDataZL?.length ?? 0,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.8),
    );
  }

  ///
  /// @name _buildZLZXItem
  /// @description 构建智领智学单个卡片item 上面有年级横向滚动Widget
  /// @parameters
  /// @return
  /// @author waitwalker
  /// @date 2020/6/9
  ///
  Widget _buildZLZXItem(BuildContext context, int index, List<DataEntity>? courseData) {

    List<GradesEntity>? gradesInfoList;
    if (SingletonManager.sharedInstance!.isPadDevice) {
      var item = courseData!.elementAt(index);
      var imgPath;
      var bgColor;
      var noGrade = item.grades == null || item.grades!.isEmpty;
      if (item.subjectId == 1) {
        imgPath = 'static/images/image_courses_language.png';
        bgColor = 0xFF65D2FE;
      } else if (item.subjectId == 2) {
        imgPath = 'static/images/image_courses_math.png';
        bgColor = 0xFFFFCE65;
      } else if (item.subjectId == 3) {
        imgPath = 'static/images/image_courses_english.png';
        bgColor = 0xFFFDAD58;
      } else if (item.subjectId == 4) {
        imgPath = 'static/images/image_courses_physics.png';
        bgColor = 0xFFAA91FF;
      } else if (item.subjectId == 5) {
        imgPath = 'static/images/image_courses_chemistry.png';
        bgColor = 0xFF9191FF;
      } else if (item.subjectId == 6) {
        imgPath = 'static/images/image_courses_history.png';
        bgColor = 0xFF8AACFF;
      } else if (item.subjectId == 7) {
        imgPath = 'static/images/image_courses_biology.png';
        bgColor = 0xFF9ADE4D;
      } else if (item.subjectId == 8) {
        imgPath = 'static/images/image_courses_geography.png';
        bgColor = 0xFF5B9EFF;
      } else if (item.subjectId == 9) {
        imgPath = 'static/images/image_courses_politics.png';
        bgColor = 0xFF9191FF;
      } else {
        imgPath = 'static/images/image_courses_science.png';
        bgColor = 0xFF80E06C;
      }
      var gradeIds;
      if (noGrade) {
        gradeIds = <int>[];
      } else {
        gradesInfoList = item.grades;
        gradeIds = item.grades!.map((g) => g.gradeId as int?).toList(); // gradeSample[item.grades?.elementAt(0)?.gradeId] ?? '';
      }
      Widget card;
      print("屏幕宽度: ${MediaQuery.of(context).size.width}");
      print("屏幕高度: ${MediaQuery.of(context).size.height}");

      double topHeight = 65;
      if (Platform.isIOS) {
        if (MediaQuery.of(context).size.height < 735.0) {
          topHeight = 58.0;
        } else if (MediaQuery.of(context).size.height > 735.0 && MediaQuery.of(context).size.height < 811.0) {
          topHeight = 73.0;
        } else if (MediaQuery.of(context).size.height > 811.0 && MediaQuery.of(context).size.height < 895.0) {
          topHeight = 65.0;
        } else if (MediaQuery.of(context).size.height > 895.0 &&  MediaQuery.of(context).size.height <= 1023.0) {
          topHeight = 75.0;
        }  else if (MediaQuery.of(context).size.height > 1023.0 &&  MediaQuery.of(context).size.height <= 1079.0) {
          topHeight = 150;
        } else if (MediaQuery.of(context).size.height > 1079.0 &&  MediaQuery.of(context).size.height <= 1193.0) {
          topHeight = 165;
        } else if (MediaQuery.of(context).size.height > 1193.0 &&  MediaQuery.of(context).size.height <= 1290.0) {
          topHeight = 170;
        } else if (MediaQuery.of(context).size.height > 1365.0) {
          topHeight = 210;
        }
      } else {
        if (MediaQuery.of(context).size.height < 735.0) {
          topHeight = 58.0;
        } else if (MediaQuery.of(context).size.height > 735.0 && MediaQuery.of(context).size.height < 811.0) {
          topHeight = 60.0;
        } else if (MediaQuery.of(context).size.height > 811.0 && MediaQuery.of(context).size.height < 895.0) {
          topHeight = 70.0;
        } else if (MediaQuery.of(context).size.height > 895.0 &&  MediaQuery.of(context).size.height <= 1023.0) {
          topHeight = 115.0;
        } else if (MediaQuery.of(context).size.height > 1023.0) {
          topHeight = 160;
        }
      }

      var normal = Container(
        child: Container(
            height: 270,
            width: (MediaQuery.of(context).size.width - 16 * 3.0) / 2.0,
            decoration: BoxDecoration(
              color: Color(bgColor),
              borderRadius: BorderRadius.all(Radius.circular(6.0)),
            ),
            child: Stack(
              children: <Widget>[
                Positioned.directional(
                  end: ScreenUtil.getInstance().setWidth(12),
                  top: SingletonManager.sharedInstance!.screenWidth> 500.0 ? ScreenUtil.getInstance().setWidth(28) : ScreenUtil.getInstance().setWidth(22),
                  textDirection: TextDirection.ltr,
                  child: Container(width: 64, height: 64, child: Image.asset(imgPath, width: 64, height: 64, fit: BoxFit.contain)),),
                Positioned.directional(
                    start: ScreenUtil.getInstance().setWidth(14),
                    top: ScreenUtil.getInstance().setWidth(10),
                    textDirection: TextDirection.ltr,
                    child: Text('${subjectSample[item.subjectId as int]}', style: TextStyle(fontSize: SingletonManager.sharedInstance!.screenWidth > 500.0 ? 22 : 16, color: Colors.white, fontWeight: FontWeight.bold))),
                Padding(padding: EdgeInsets.only(top: topHeight,left: 10),
                  child: Container(
                    height: SingletonManager.sharedInstance!.screenWidth > 500 ? 26 : 18,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      reverse: false,
                      child: Row(children: buildTag(item.grades?.map((g) => gradeSample[g.gradeId as int])?.toList())),
                    ),
                  ),
                ),
              ],
            )),
      );
      if (noGrade) {
        card = Stack(
          children: <Widget>[
            normal,
            Positioned.directional(
                top: 0,
                end: 0,
                textDirection: TextDirection.ltr,
                child: Container(
                    width: 64,
                    height: 36,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFFEA615F), Color(0xFFFF9074)],
                      ),
                      borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20.0), topRight: Radius.circular(6.0)),
                    ),
                    child:
                    Container(child: Text('体验', style: TextStyle(fontSize: SingletonManager.sharedInstance!.screenWidth > 500 ? 20 : 12, color: Colors.white))))),
          ],
        );
      } else {
        card = normal;
      }
      return InkWell(
        child: card,
        onTap: () => _onSubjectTap(gradeIds, item.subjectId as int?, gradesInfo: gradesInfoList),
      );
    } else {
      var item = courseData!.elementAt(index);
      var imgPath;
      var bgColor;
      var noGrade = item.grades == null || item.grades!.isEmpty;
      if (item.subjectId == 1) {
        imgPath = 'static/images/image_courses_language.png';
        bgColor = 0xFF65D2FE;
      } else if (item.subjectId == 2) {
        imgPath = 'static/images/image_courses_math.png';
        bgColor = 0xFFFFCE65;
      } else if (item.subjectId == 3) {
        imgPath = 'static/images/image_courses_english.png';
        bgColor = 0xFFFDAD58;
      } else if (item.subjectId == 4) {
        imgPath = 'static/images/image_courses_physics.png';
        bgColor = 0xFFAA91FF;
      } else if (item.subjectId == 5) {
        imgPath = 'static/images/image_courses_chemistry.png';
        bgColor = 0xFF9191FF;
      } else if (item.subjectId == 6) {
        imgPath = 'static/images/image_courses_history.png';
        bgColor = 0xFF8AACFF;
      } else if (item.subjectId == 7) {
        imgPath = 'static/images/image_courses_biology.png';
        bgColor = 0xFF9ADE4D;
      } else if (item.subjectId == 8) {
        imgPath = 'static/images/image_courses_geography.png';
        bgColor = 0xFF5B9EFF;
      } else if (item.subjectId == 9) {
        imgPath = 'static/images/image_courses_politics.png';
        bgColor = 0xFF9191FF;
      } else {
        imgPath = 'static/images/image_courses_science.png';
        bgColor = 0xFF80E06C;
      }
      var gradeIds;
      if (noGrade) {
        gradeIds = <int>[];
      } else {
        gradesInfoList = item.grades;
        gradeIds = item.grades!.map((g) => g.gradeId as int?).toList(); // gradeSample[item.grades?.elementAt(0)?.gradeId] ?? '';
      }
      Widget card;
      print("屏幕宽度: ${MediaQuery.of(context).size.width}");
      print("屏幕高度: ${MediaQuery.of(context).size.height}");

      double topHeight = 65;
      if (Platform.isIOS) {
        if (MediaQuery.of(context).size.height < 735.0) {
          topHeight = 58.0;
        } else if (MediaQuery.of(context).size.height > 735.0 && MediaQuery.of(context).size.height < 811.0) {
          topHeight = 73.0;
        } else if (MediaQuery.of(context).size.height > 811.0 && MediaQuery.of(context).size.height < 895.0) {
          topHeight = 65.0;
        } else if (MediaQuery.of(context).size.height > 895.0 &&  MediaQuery.of(context).size.height <= 1023.0) {
          topHeight = 75.0;
        } else if (MediaQuery.of(context).size.height > 1023.0) {
          topHeight = 160;
        }
      } else {
        if (MediaQuery.of(context).size.height < 735.0) {
          topHeight = 58.0;
        } else if (MediaQuery.of(context).size.height > 735.0 && MediaQuery.of(context).size.height < 811.0) {
          topHeight = 60.0;
        } else if (MediaQuery.of(context).size.height > 811.0 && MediaQuery.of(context).size.height < 895.0) {
          topHeight = 65.0;
        } else if (MediaQuery.of(context).size.height > 895.0 &&  MediaQuery.of(context).size.height <= 1023.0) {
          topHeight = 75.0;
        } else if (MediaQuery.of(context).size.height > 1023.0) {
          topHeight = 160;
        }
      }

      var normal = Container(
        child: Container(
            height: 200,
            width: (MediaQuery.of(context).size.width - 16 * 3.0) / 2.0,
            decoration: BoxDecoration(
              color: Color(bgColor),
              borderRadius: BorderRadius.all(Radius.circular(6.0)),
            ),
            child: Stack(
              children: <Widget>[
                Positioned.directional(
                  end: ScreenUtil.getInstance().setWidth(12),
                  top: SingletonManager.sharedInstance!.screenWidth> 500.0 ? ScreenUtil.getInstance().setWidth(28) : ScreenUtil.getInstance().setWidth(22),
                  textDirection: TextDirection.ltr,
                  child: Container(width: 44, height: 44, child: Image.asset(imgPath, width: 44, height: 44, fit: BoxFit.contain)),),
                Positioned.directional(
                    start: ScreenUtil.getInstance().setWidth(14),
                    top: ScreenUtil.getInstance().setWidth(10),
                    textDirection: TextDirection.ltr,
                    child: Text('${subjectSample[item.subjectId as int]}', style: TextStyle(fontSize: SingletonManager.sharedInstance!.screenWidth > 500.0 ? 22 : 16, color: Colors.white, fontWeight: FontWeight.bold))),
                Padding(padding: EdgeInsets.only(top: topHeight,left: 10),
                  child: Container(
                    height: SingletonManager.sharedInstance!.screenWidth > 500 ? 25 : 18,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      reverse: false,
                      child: Row(children: buildTag(item.grades?.map((g) => gradeSample[g.gradeId as int])?.toList())),
                    ),
                  ),
                ),
              ],
            )),
      );
      if (noGrade) {
        card = Stack(
          children: <Widget>[
            normal,
            Positioned.directional(
                top: 0,
                end: 0,
                textDirection: TextDirection.ltr,
                child: Container(
                    width: 44,
                    height: 22,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFFEA615F), Color(0xFFFF9074)],
                      ),
                      borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20.0), topRight: Radius.circular(6.0)),
                    ),
                    child:
                    Container(child: Text('体验', style: TextStyle(fontSize: SingletonManager.sharedInstance!.screenWidth > 500 ? 18 : 12, color: Colors.white))))),
          ],
        );
      } else {
        card = normal;
      }
      return InkWell(
        child: card,
        onTap: () => _onSubjectTap(gradeIds, item.subjectId as int?, gradesInfo: gradesInfoList),
      );
    }
  }

  List<Widget> buildTag(List<String?>? grades) {
    if (SingletonManager.sharedInstance!.isPadDevice) {
      nameTag(String? name) {
        if (name == null || name.isEmpty) return Container();
        return Container(
            padding: EdgeInsets.only(right: 8),
            child: Container(
                width: SingletonManager.sharedInstance!.screenWidth > 500 ? 65 : 32,
                // height: 14,
                alignment: Alignment.center,
                // padding:  EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: Color(MyColors.shadow),
                  borderRadius: BorderRadius.all(Radius.circular(15.0)),
                ),
                child: Text(name, style: TextStyle(fontSize: SingletonManager.sharedInstance!.screenWidth > 500 ? 18 : 12, color: Colors.white, fontWeight: FontWeight.bold))));
      }

      if (grades == null || grades.isEmpty) return [Container()];
      return grades.map((g) => nameTag(g)).toList();
    } else {
      nameTag(String? name) {
        if (name == null || name.isEmpty) return Container();
        return Container(
            padding: EdgeInsets.only(right: 4),
            child: Container(
                width: SingletonManager.sharedInstance!.screenWidth > 500 ? 45 : 32,
                // height: 14,
                alignment: Alignment.center,
                // padding:  EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: Color(MyColors.shadow),
                  borderRadius: BorderRadius.all(Radius.circular(7.0)),
                ),
                child: Text(name, style: TextStyle(fontSize: SingletonManager.sharedInstance!.screenWidth > 500 ? 16 : 12, color: Colors.white, fontWeight: FontWeight.bold))));
      }

      if (grades == null || grades.isEmpty) return [Container()];
      return grades.map((g) => nameTag(g)).toList();
    }
  }

  ///
  /// @name buildJuniorCourse
  /// @description 北京四中网校暑期公益助学计划
  /// @parameters
  /// @return
  /// @author waitwalker
  /// @date 2020-08-11
  ///
  buildJuniorCourse() {
    return InkWell(
        onTap: () {
          var token = NetworkManager.getAuthorization();
          String url = Config.DEBUG ? "http://huodongt.etiantian.com/activity01/zhongkaom.html?token=" : "https://huodong.etiantian.com/activity02/01m.html?token=";
          String fullUrl = "$url$token";
          Navigator.of(context).push(MaterialPageRoute(builder: (_) {
            return CommonWebviewPage(initialUrl: fullUrl, title: "北京四中网校暑期公益助学计划",);
          }));
        },
        child: Container(
          height: ScreenUtil.getInstance().setWidth(155),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(6.0)),
              image: DecorationImage(
                  image: AssetImage('static/images/junior_banner_entrance.png'),
                  fit: BoxFit.fill)),
        ));
  }

  ///
  /// @name buildUnionCourse
  /// @description 联通活动课程
  /// @parameters
  /// @return
  /// @author waitwalker
  /// @date 2020-08-11
  ///
  buildUnionCourse() {
    return InkWell(
        onTap: () {
          var token = NetworkManager.getAuthorization();
          String url = Config.DEBUG ? "http://huodongt.etiantian.com/activity01/zhongkaom.html?token=" : "https://huodong.etiantian.com/liantong/indexm.html?token=";
          String fullUrl = "$url$token";
          Navigator.of(context).push(MaterialPageRoute(builder: (_) {
            return CommonWebviewPage(initialUrl: fullUrl, title: "中国联通·北京四中网校名师课堂",);
          }));
        },
        child: Container(
          height: ScreenUtil.getInstance().setWidth(155),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(4.0)),
              image: DecorationImage(
                  image: AssetImage('static/images/u_banner_entrance.png'),
                  fit: BoxFit.fill)),
        ));
  }

  ///
  /// @name buildActivityCourse
  /// @description 活动课入口
  /// @parameters
  /// @return
  /// @author waitwalker
  /// @date 2019-12-23
  ///
  buildActivityCourse() {
    return InkWell(
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (BuildContext context) => ActivityCourse()));
        },
        child: Container(
          height: ScreenUtil.getInstance().setWidth(75),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(4.0)),
              image: DecorationImage(image: AssetImage('static/images/image_courses_activity.png'), fit: BoxFit.fill)),
        ));
  }

  ///
  /// @name buildUnitTestErrorBook
  /// @description 质检消错错题本入口
  /// @parameters
  /// @return
  /// @author waitwalker
  /// @date 2019-12-23
  ///
  buildUnitTestErrorBook() {
    return Container(
      child: Row(
        children: [
          InkWell(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (_) =>
                    ErrorBookSubjectListPage(title:"质检消错错题", fromUnitTest: true,)));
              },
              child: Container(
                height: 56,
                width: (MediaQuery.of(context).size.width - 32 - 15) / 2,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(7.0)),
                  color: Color(0xff67D0FF),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset("static/images/unit_test_error_book_icon.png",width: 30, height: 30,),
                    Padding(padding: EdgeInsets.only(left: 5)),
                    Text("开始消错", style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),),
                  ],
                ),
              )),

          Padding(padding: EdgeInsets.only(left: 15)),
          InkWell(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) =>
                        UnitTestListPage()));
              },
              child: Container(
                height: 56,
                width: (MediaQuery.of(context).size.width - 32 - 15) / 2,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(7.0)),
                  color: Color(0xffFFB85D),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset("static/images/unit_test_icon.png",width: 30, height: 30,),
                    Padding(padding: EdgeInsets.only(left: 5)),
                    Text("举一反三", style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),),
                  ],
                ),
              )),

        ],
      ),
    );
  }

  void _onSubjectTap(List<int> gradeIdsList, int? subjectId, {List<GradesEntity>? gradesInfo}) {
    bool isZL = zhiLingSubjects.contains(subjectId);

    // 智领课3 智学课2
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return SubjectDetailPage(
        gradeIds: gradeIdsList,
        subjectId: subjectId,
        hiddenCard: false,
        cardType: isZL ? 3 : 2,
        gradesInfoList: gradesInfo,
      );
    })).then(_refreshLocalHistory);
  }

  Future fetchActivity() async {
    ResponseData activityInfo = await CourseDaoManager.activityInfo();
    if (activityInfo.model != null) {
      var model = activityInfo.model as ActivityEntranceModel;
      if (model.code == 1 && model.data != null) {
        var data = model.data!;
        if (data.isOpen == 1) {
          if (data.picture != null) {
            showDialog(
                context: context,
                barrierDismissible: true,
                builder: (context) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          GestureDetector(
                              child: Icon(Icons.close, color: Colors.white),
                              onTap: () {
                                Navigator.pop(context);
                              }),
                          Padding(padding: EdgeInsets.only(right: SingletonManager.sharedInstance!.screenWidth > 500.0 ? 30 : 10)),
                        ],
                      ),
                      Padding(padding: EdgeInsets.only(top: 10)),
                      GestureDetector(
                          child: Padding(padding: EdgeInsets.only(left: 10,right: 10,), child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image(image: NetworkImage(data.picture!), fit: BoxFit.fill),
                          ),),
                          onTap: (){
                            if (data.url == null || data.url!.isEmpty) {
                              Navigator.pop(context);
                              /*
                                * 1.普通活动课
                                * 2.高考冲刺活动课
                                * 3.初中活动课
                                * */
                              int? a = data.tagType;
                              if (a == 1) {
                                Navigator.of(context).push(
                                    MaterialPageRoute(builder: (BuildContext context) => ActivityCourse()));
                              } else if (a == 2) {
                                Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => MicroActivityPage(
                                  Config.DEBUG ? 10031312455 : 100289535008,
                                  title: "高考冲刺课",
                                )));
                              } else if (a == 3) {
                                Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => JuniorGradePage()));
                              } else {
                                Fluttertoast.showToast(msg: "活动课还没开始!");
                              }
                            } else {
                              Navigator.pop(context);
                              var token = NetworkManager.getAuthorization();
                              String fullUrl = "${data.url}?token=$token";
                              Navigator.of(context).push(MaterialPageRoute(builder: (_) {
                                return CommonWebviewPage(initialUrl: fullUrl, title: data.description,);
                              }));
                            }
                          }
                      )
                    ],
                  );
                });
          }
        }
      }
    }
  }

  ///
  /// @name _toHistory
  /// @description 跳转到作答记录
  /// @parameters
  /// @return
  /// @author waitwalker
  /// @date 2019-12-23
  ///
  void _toHistory() {
    UmengPlugin.logEvent('to_history', label: 'click');
    if (record != null && record!.type == 1) {
      var pStr = SharedPrefsUtils.getString('record', '')!;
      record = LiveListRecord.fromJson(jsonDecode(pStr));
      Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => LivePage(
              subjectId: record!.subjectId as int?,
              gradeId: record!.gradeId as int?,
              record: record as LiveListRecord?)))
          .then(_refreshLocalHistory);
    } else if (record != null &&(record!.type == 2 || record!.type == 11)) {
      var value = SharedPrefsUtils.get("currentValue", "1");
      Navigator.push(context, MaterialPageRoute(builder: (context){
        return WisdomStudyListPage(record!.courseId as int?, record!.subjectId as int?, record!.gradeId as int?, currentValue: value, useRecord: true, scrollController: AutoScrollController(),);
      })).then(_refreshLocalHistory);
    }
  }

  FutureOr _refreshLocalHistory(value) {
    _loadStudyRecordData();
    setState(() {});
  }
}

typedef void OnPress();

class Indicator extends StatelessWidget {
  final double? width;
  final double? height;
  final Color? color;

  const Indicator({Key? key, this.width, this.height, this.color})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: color ?? const Color(MyColors.primaryValue),
        borderRadius:
        BorderRadius.all(Radius.circular(min<double>(width!, height!)/ 2)), //设置圆角
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: color ?? const Color(MyColors.primaryValue),
            blurRadius: 4.0,
            spreadRadius: 0.0,
            offset: Offset(0.0, 2.0),
          ),
        ],
      ),
    );
  }
}

