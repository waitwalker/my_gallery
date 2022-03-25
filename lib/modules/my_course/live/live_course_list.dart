import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:lpinyin/lpinyin.dart';
import 'package:my_gallery/common/dao/original_dao/course_dao_manager.dart';
import 'package:my_gallery/common/dao/original_dao/video_dao.dart';
import 'package:my_gallery/common/network/error_code.dart';
import 'package:my_gallery/common/singleton/singleton_manager.dart';
import 'package:my_gallery/common/tools/get_grade/grade_utils.dart';
import 'package:my_gallery/event/http_error_event.dart';
import 'package:my_gallery/model/live_schedule_model.dart';
import 'package:my_gallery/model/self_study_record.dart';
import 'package:my_gallery/model/video_url_model.dart';
import 'package:my_gallery/modules/my_course/live/live_teaching_material_list_page.dart';
import 'package:my_gallery/modules/my_course/wisdom_study/scroll_to_index/scroll_to_index.dart';
import 'package:my_gallery/common/const/api_const.dart';
import 'package:my_gallery/common/network/network_manager.dart';
import 'package:my_gallery/modules/personal/settings/wifi_only_check_widget.dart';
import 'package:my_gallery/modules/widgets/loading/list_type_loading_placehold_widget.dart';
import 'package:my_gallery/modules/widgets/player/local_video_play_widget.dart';
import 'package:my_gallery/modules/widgets/style/style.dart';
import 'package:my_gallery/modules/widgets/empty_placeholder/empty_placeholder_widget.dart';
import 'package:my_gallery/common/tools/date/eye_protection_timer.dart';
import 'package:my_gallery/common/logger/logger.dart';
import 'package:my_gallery/common/tools/screen_adapt/screen_utils.dart';
import 'package:my_gallery/common/tools/share_preference/share_preference.dart';
import 'package:async/async.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:umeng_plugin/umeng_plugin.dart';
import '../../widgets/webviews/common_webview_page.dart';
import 'video_play_page.dart';
import '../../widgets/webviews/microcourse_webview.dart';


///
/// @name PlayBackLiveListPage
/// @description 直播课列表页面
/// @author waitwalker
/// @date 2020-01-10
///
// ignore: must_be_immutable
class LiveCourseList extends StatefulWidget {
  var courseId;

  int i;
  int? gradeId;
  int? subjectId;
  AsyncMemoizer memoizer = AsyncMemoizer();

  ScrollController? scrollController;
  LiveListRecord? record;

  bool? useRecord;
  bool previewMode;
  bool isSenior;

  LiveCourseList(this.i, this.memoizer,
      {this.courseId,
        this.gradeId,
        this.subjectId,
        this.scrollController,
        this.previewMode = false,
        this.record,
        this.isSenior = true,
      });

  @override
  _LiveCourseListState createState() => _LiveCourseListState();
}

class _LiveCourseListState extends State<LiveCourseList> with WifiOnlyCheckWidget {
  Map<int, dynamic> courseStatus = <int, dynamic>{};
  Map<String, int> idIndex = <String, int>{};
  DataEntity? detailData;

  AutoScrollController? controller;
  AutoScrollController? outerController;
  LiveListRecord? record;

  bool created = false;

  int? get lastResId => record!.id as int?;

  List<ListEntity> courses = [];
  AsyncMemoizer? _memoizer;


  late StreamController streamController;
  // 用于发射事件
  StreamSink<Map> get streamSink => streamController.sink as StreamSink<Map<dynamic, dynamic>>;
  // 用于接收事件
  Stream<Map> get streamData => streamController.stream as Stream<Map<dynamic, dynamic>>;
  Map<String, int> progressMap = {};

  // 是否正在下载
  bool isLoading = false;
  int? currentIndex = 500000;
  CancelToken? cancelToken;
  bool isDispose = false;

  String? currentFullPath;
  int? itemCurrentIndex;

  List<num?> courseIdList = [];

  @override
  void initState() {
    isDispose = false;
    streamController = StreamController<Map>.broadcast();
    record = widget.record != null
        ? widget.record
        : LiveListRecord(type: 1, id: -1, subjectId: widget.subjectId, gradeId: widget.gradeId);
    outerController = widget.scrollController as AutoScrollController?;
    controller = AutoScrollController();
    _memoizer = widget.memoizer;

    UmengPlugin.beginPageView("专题讲解");


    ///
    /// @name eventBus
    /// @description event 监听事件
    /// @parameters []
    /// @return void
    /// @author waitwalker
    /// @date 2020-01-14
    ///
    ErrorCode.eventBus.on<dynamic>().listen((e) {
      if (mounted) {

        print("网络错误message:${e.message}");

        if (e is HttpErrorEvent && e.code == ErrorCode.NETWORK_ERROR && e.message == "网络已断开") {

          if (cancelToken != null) {
            cancelToken!.cancel();
            cancelToken = null;
          }
          if (currentFullPath != null) {
            // 下载失败 移除本地
            _deleteFailedFile("$currentFullPath");
            if (isDispose) {
              return;
            }
            // 页面销毁回调处理
            print("error:下载错误");
            isLoading = false;
            currentIndex = 5000000;
            streamSink.add(
                {"value":"下载",
                  "index":itemCurrentIndex
                });

            itemCurrentIndex = 5000001;
            currentFullPath = null;
          }
        }
      }
    });

    super.initState();
    // 初中用户弹框提示
    _juniorShowAlert();
  }

  ///
  /// @description 初中用户显示弹框提示
  /// @param
  /// @return
  /// @author waitwalker
  /// @time 2021/8/11 15:29
  ///
  _juniorShowAlert() async{
    int juniorAlertCount = SharedPrefsUtils.get("juniorAlertCount", 0);
    if (!widget.isSenior && juniorAlertCount < 6) {
      Future.delayed(Duration(seconds: 1),(){
        showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    height: ScreenUtil().setHeight(360),
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
                                  SharedPrefsUtils.put("juniorAlertCount", juniorAlertCount + 1);
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
                            height: 280,
                            child: Padding(padding: EdgeInsets.only(left: 8, right: 8),
                              child: Text(" “专题精讲”栏目教学形式调整的通知\n"
                                  "亲爱的同学："
                                  "原定针对初中三个年级的暑假第二、三期“专题精讲”课程，即日起调整为高清点播的形式，登录方式不变，请周知。"
                                  "高清点播版“专题精讲”课程的教学计划和原来的设计一致、内容一致、质量一致，同时还具备了学习时间灵活、学习进度可调节等更适合自主学习的功能，可以更好的满足同学们不同的学习需求"
                                  "祝同学们：健康成长，学习进步！\n"
                                  "\n北京四中网校教学部"
                                  "\n2021年8月12日", textAlign: TextAlign.left,),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            });
      });
    }
  }

  @override
  void dispose() {
    isDispose = true;
    _memoizer = null;
    if (cancelToken != null) {
      cancelToken!.cancel();
    }
    streamController.close();
    UmengPlugin.endPageView("专题讲解");
    super.dispose();
  }

  ///
  /// @name saveRecord
  /// @description 保存记录
  /// @parameters
  /// @return
  /// @author waitwalker
  /// @date 2020/7/23
  ///
  void saveRecord() {
    if (widget.previewMode) return;
    if (record != null && record!.id != null && record!.type != null && record!.title!.isNotEmpty) {
      debugLog(record.toString(), tag: 'save');
      record!.studyTime = DateTime.now().millisecondsSinceEpoch;
      record!.time = record!.studyTime;
      SharedPrefsUtils.put('record', record.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(MyColors.background),
      child: detailData != null
          ? _builderContentWidget()
          : FutureBuilder(
        builder: _futureBuilder,
        future: _getDetail(),
      ),
    );
  }

  ///
  /// @name _futureBuilder
  /// @description future Builder
  /// @parameters
  /// @return
  /// @author waitwalker
  /// @date 2020/7/23
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
        if (snapshot.hasError) return Text('Error: ${snapshot.error}');

        var liveDetailModel = snapshot.data.model as LiveScheduleModel?;
        detailData = liveDetailModel?.data;
        if (detailData == null) {
          return EmptyPlaceholderPage(assetsPath: 'static/images/empty.png', message: '没有数据');
        }
        if (liveDetailModel!.code == 1 && detailData != null) {
          for(int i = 0; i < detailData!.list!.length; i++) {
            ListEntity listEntity = detailData!.list![i];
            listEntity.itemIndex = i;
            courses.add(listEntity);
          }
          return _builderContentWidget();
        }
        return EmptyPlaceholderPage(assetsPath: 'static/images/empty.png', message: '${liveDetailModel.msg}');
      default:
        return EmptyPlaceholderPage(assetsPath: 'static/images/empty.png', message: '没有数据');
    }
  }

  _initScrollToIndex() {
    var scrollToViewport = () => SchedulerBinding.instance!.endOfFrame.then((d) {
      controller!
          .scrollToIndex(record!.id as int?,
          duration: Duration(seconds: 1),
          preferPosition: AutoScrollPosition.middle)
          .then((_) {
        controller!.highlight(record!.id as int?,
            highlightDuration: Duration(seconds: 3));
      });
    });
    record != null && courses.indexWhere((item) => item.courseId == record!.id) != -1 ?
    scrollToViewport() :
    // ignore: unnecessary_statements
    null;
  }

  ///
  /// @name buildHeader
  /// @description 构建顶部 班级二维码
  /// @parameters
  /// @return
  /// @author waitwalker
  /// @date 2020/7/23
  ///
  buildHeader() {
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          InkWell(
              child: Container(
                width: ScreenUtil.getInstance().setWidth(156),
                height: ScreenUtil.getInstance().setHeight(50),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(6.0)), //设置圆角
                  image: DecorationImage(image: AssetImage('static/images/live_card.png')),
                ),
                child: Text('班级群', style: textStyleLargeWhiteMedium),
              ),
              onTap: _onPressClassGroup),
          // const SizedBox(width: 16),
          InkWell(
              child: Container(
                width: ScreenUtil.getInstance().setWidth(156),
                height: ScreenUtil.getInstance().setHeight(50),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(6.0)), //设置圆角
                  image: DecorationImage(image: AssetImage('static/images/live_card.png')),
                ),
                child: Text('资料包', style: textStyleLargeWhiteMedium),
              ),
              onTap: () {
                courseIdList.clear();
                var courseIds = _loadCourseIds();
                print("courseIds:$courseIds");
                Navigator.of(context).push(MaterialPageRoute(builder: (context){
                  return LiveMaterialListPage(courseIds, isSenior: widget.isSenior, courseIdList:courseIdList);
                }));
              }),
        ]);
  }

  ///
  /// @name _loadCourseIds
  /// @description 生成course id
  /// @parameters
  /// @return
  /// @author waitwalker
  /// @date 2020-01-13
  ///
  _loadCourseIds() {
    if (detailData!.list != null && detailData!.list!.length > 0) {
      String courseIds = "";
      detailData!.list!.forEach((ListEntity value){
        courseIdList.add(value.liveCourseId);
        courseIds = courseIds + "," + "${value.liveCourseId}";
      });
      courseIds = courseIds.substring(1);
      return courseIds;
    } else {
      return null;
    }
  }

  ///
  /// @name _onPressClassGroup
  /// @description 班级群点击回调
  /// @parameters
  /// @return
  /// @author waitwalker
  /// @date 2020/7/23
  ///
  void _onPressClassGroup() {
    if (detailData!.classCode == null) {
      Fluttertoast.showToast(msg: '没有班级二维码');
      return;
    }
    showDialog<String>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('二维码'),
          contentPadding: EdgeInsets.all(0),
          content: SizedBox(
            height: 150,
            child: Image.network(detailData!.classCode!),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('保存'),
              onPressed: () {
                _onImageSaveButtonPressed(detailData!.classCode);
              },
            ),
          ],
        );
      },
    );
  }

  ///
  /// @name _onImageSaveButtonPressed
  /// @description 保存按钮回调
  /// @parameters
  /// @return
  /// @author waitwalker
  /// @date 2020/7/23
  ///
  void _onImageSaveButtonPressed(qrUrl) async {
    if (Platform.isIOS) {
      var response = await Dio().get(
          qrUrl,
          options: Options(responseType: ResponseType.bytes));
      print("${Uint8List.fromList(response.data)}");
      Navigator.of(context).pop();
      final result = await ImageGallerySaver.saveImage(
          Uint8List.fromList(response.data),
          quality: 98,
          name: "class_qrcode");
      print(result);
      Fluttertoast.showToast(msg: '班级二维码已保存至相册');
    } else {

      // 设置文件存储路径
      String localPath = await _findLocalPath() + '/qr_images';
      final savedDirT = Directory(localPath);
      bool hasExisted = savedDirT.existsSync();
      if (!hasExisted) {
        savedDirT.createSync();
      }

      // 获取文件后缀(扩展名)
      var suffixLast = qrUrl.split('.').last;

      // 年级学科名称
      String gradeSubjectName = PinyinHelper.getPinyin("${gradeSample[widget.gradeId!]}${subjectSample[widget.subjectId!]}", separator: "-");

      // 当前时间戳
      String currentTime = DateTime.now().millisecondsSinceEpoch.toString();

      // 文件名
      var filename = '$gradeSubjectName-$currentTime.$suffixLast';
      // 完整路径
      String fullPathT = "$localPath/$filename";
      print("文件路径名称:$fullPathT");

      try {
        await Dio().download(qrUrl, fullPathT, onReceiveProgress: (receivedBytes, totalBytes) {
          print("totalBytes:$totalBytes\nreceive:$receivedBytes");

          if (receivedBytes == totalBytes) {
            Navigator.of(context).pop();
            var savedFile = Uri.decodeFull(fullPathT);
            Fluttertoast.showToast(msg: '班级二维码已保存至${fullPathT == null || fullPathT.length < 1 ? "设备" : savedFile}');
          }
        });
      } catch (e) {
        Navigator.of(context).pop();
      }
      print("存储完成");
    }
  }

  ///
  /// @name _builderContentWidget
  /// @description 构建content
  /// @parameters
  /// @return
  /// @author waitwalker
  /// @date 2020/7/23
  ///
  Widget _builderContentWidget() {
    if (!this.created) {
      this.created = true;
      _initScrollToIndex();
    }
    return StreamBuilder(stream: streamData, builder: (BuildContext context, AsyncSnapshot snapshot){
      Map? map = snapshot.data;
      return Column(
        children: <Widget>[
          const SizedBox(height: 10),
          _buildHeader(),
          Flexible(
              child: ListView.builder(
                controller: controller,
                padding: EdgeInsets.only(bottom: 16),
                itemBuilder: (BuildContext context, int index) => builderCardItem(map, context, index, controller),
                itemCount: courses.length,
              ))
        ],
      );
    });
  }

  ///
  /// @description 构建顶部资料包
  /// @param 
  /// @return 
  /// @author waitwalker
  /// @time 2021/8/11 15:16
  ///
  _buildHeader() {
    if (widget.isSenior) {
      if (widget.i != 2) {
        return Container(child: buildHeader(), padding: EdgeInsets.symmetric(horizontal: 16));
      } else {
        return Container();
      }
    } else {
      return Container(child: buildHeader(), padding: EdgeInsets.symmetric(horizontal: 16));
    }
  }

  ///
  /// @name builderCardItem
  /// @description 构建卡片item
  /// @parameters
  /// @return
  /// @author waitwalker
  /// @date 2020/7/23
  ///
  Widget builderCardItem(Map? map,BuildContext context, int index, ScrollController? controller) {
    var item = courses.elementAt(index);
    return DiagnosisAutoScrollTag(
        key: ValueKey(index),
        controller: controller as AutoScrollController?,
        index: item.courseId as int?,
        highlightColor: Color(MyColors.primaryValue).withOpacity(1),
        child: Stack(
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(left: 16, top: 12, right: 16),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(4.0)),
                  color: Colors.white,
                  boxShadow: [BoxShadow(color: Color(MyColors.shadow), offset: Offset(0, 2), blurRadius: 10.0, spreadRadius: 2.0)],
                ),
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(item.courseName!, style: TextStyle(fontSize: SingletonManager.sharedInstance!.screenWidth > 500.0 ? 19 : 17, color: Color(MyColors.title_black), fontWeight: FontWeight.bold)),
                    SizedBox(height: widget.isSenior ? 6 : 1),
                    Text(widget.isSenior ? item.startTime.toString() : "", style: TextStyle(fontSize: SingletonManager.sharedInstance!.screenWidth > 500.0 ? 13 : 11, color: Color(MyColors.txt_time)),),
                    SizedBox(height: 8),
                    Row(
                      children: <Widget>[
                        ClipOval(
                            child: Container(
                              color: Colors.black12,
                              child: item.teacherPic == null
                                  ? Image.asset('static/images/avatar.png', width: 28, height: 28)
                                  : Image.network(item.teacherPic!, width: 38, height: 38),
                            )),
                        SizedBox(width: 12),
                        Text(item.showName!)
                      ],
                    ),
                    if ((!widget.previewMode || (widget.previewMode && index == 0)) && item.stateId == 2)
                      ..._buildBottomRow(map,item, index),
                  ],
                ),
              ),
            ),
            if (widget.previewMode && index != 0)
              Positioned(bottom: 16, right: 32,
                child: Icon(Icons.lock, size: 20, color: Color(0xFFD5DAEB)),
              ),
            if ((!widget.previewMode || (widget.previewMode && index == 0)) &&
                item.stateId != 2)
              Positioned(
                bottom: 20,
                right: 30,
                child: InkWell(
                  child: Opacity(
                    child: Container(
                      height: 24, width: 80,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(color: const Color(0xFFFF8585),
                        borderRadius: BorderRadius.all(Radius.circular(12),),),
                      child: Text(item.stateId == 1 ? '进入直播' : '未开始', style: textStyle12WhiteBold),
                    ),
                    opacity: item.stateId == 1 ? 1.0 : 0.4,
                  ),
                  onTap: () {
                    if (item.stateId == 1) {
                      record!.id = item.courseId;
                      record!.title = item.courseName;
                      record!.courseId = item.liveCourseId;
                      record!.subjectId = widget.subjectId;
                      record!.gradeId = widget.gradeId;
                      record!.tabIndex = widget.i;
                      saveRecord();

                      var token = NetworkManager.getAuthorization();
                      var url = '${APIConst.liveHost}?utoken=$token&rcourseid=${item.liveCourseId}&ocourseId=${item.courseId}&roomid=${item.partnerRoomId}';
                      // 需求：护眼模式，直播不计时
                      EyeProtectionTimer.pauseTimer();
                      Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => CommonWebviewPage(initialUrl: url, title: item.courseName,)))
                          .then((_) => EyeProtectionTimer.startEyeProtectionTimer(context));
                    } else {
                      Fluttertoast.showToast(msg: '暂未开始');
                    }
                  },
                ),
              ),
            if ((!widget.previewMode || (widget.previewMode && index == 0)) &&
                item.stateId == 1)
              Positioned(
                  top: 28, right: 16,
                  child: Container(width: 40, height: 18,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(gradient: LinearGradient(colors: [Color(0xFFFFDE63), Color(0xFFFF9C78)]), color: Color(MyColors.primaryValue),
                      borderRadius: BorderRadius.only(topLeft: Radius.circular(9), bottomLeft: Radius.circular(9), topRight: Radius.circular(0), bottomRight: Radius.circular(0)),),
                    child: Text('Live', style: textStyle10White),
                  )),
          ],
        ));
  }

  ///
  /// @name _onTapPlayback
  /// @description 回放点击回调
  /// @parameters
  /// @return
  /// @author waitwalker
  /// @date 2020/7/23
  ///
  Future _onTapPlayback(ListEntity course) async {
    record!.id = course.courseId;
    record!.title = course.courseName;
    record!.courseId = course.liveCourseId;
    record!.subjectId = widget.subjectId;
    record!.gradeId = widget.gradeId;
    record!.tabIndex = widget.i;
    saveRecord();
    // 如果视频缓存还没有生成,用网页播放cc的链接
    if (course.hdResourceId! < 1) {
      var token = NetworkManager.getAuthorization();
      var url = '${APIConst.backHost}?token=$token&rcourseid=${course.liveCourseId}&ocourseId=${course.courseId}&roomid=${course.partnerRoomId}';
      Navigator.of(context).push(MaterialPageRoute(
          builder: (BuildContext context) => CommonWebviewPage(initialUrl: url, title: widget.isSenior ? '直播回放' : "播放",)));
      return;
    }
    var videoUrl = await VideoDao.getVideoUrl(course.courseId.toString());
    var model = videoUrl.model as VideoUrlModel;
    if (model.code != 1) {
      Fluttertoast.showToast(msg: model.msg!);
      return;
    }

    // local first
    var mp4Url = model.data!.videoUrl!;

    // 获取地址
    var _localPath = (await _findLocalPath()) + '/video';
    final savedDir = Directory(_localPath);
    bool hasExisted = savedDir.existsSync();
    if (!hasExisted) {
      savedDir.createSync();
    }

    // 课程名称
    String? courseName = course.courseName;

    // 将video url 以"/" 拆分成数组
    List list = mp4Url.split("/");

    var suffixLast = mp4Url.split('.').last;
    // 文件hash值
    String fileHashString = "${list[3]}";

    // 文件名
    var filename = '$fileHashString.$suffixLast';

    // 完整路径
    String fullPath = "$_localPath/$filename";
    print("文件路径名称:$fullPath");

    File file = File("$fullPath");
    bool isExist = await file.exists();
    if (isExist) {
      if (currentIndex == course.itemIndex && isLoading) {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (BuildContext context) => VideoPlayPage(
                model.data!.playVideoUrl ?? mp4Url,
                resourceId: model.data!.resourceId,
                courseId: model.data!.onlineCourseId,
                title: model.data!.onlineCourseName)));
        return;
      }

      Fluttertoast.showToast(msg: '视频已下载，播放不消耗流量', gravity: ToastGravity.CENTER);
      Navigator.of(context).push(MaterialPageRoute(builder: (_) {
        return LocalVideoPlayWidget(fullPath, title: courseName,);
      }));
      return;
    } else {
      Navigator.of(context).push(MaterialPageRoute(
          builder: (BuildContext context) => VideoPlayPage(
              mp4Url,
              resourceId: model.data!.resourceId,
              courseId: model.data!.onlineCourseId,
              title: model.data!.onlineCourseName)));
      return;
    }
  }


  _getDetail() => _memoizer!.runOnce(() => CourseDaoManager.liveScheduleNew(subjectId: widget.subjectId, gradeId: widget.gradeId, typeId: widget.i));

  ///使用dio 下载文件
  _downloadFile(ListEntity item, int index) async {

    // 1. 获取权限
    var isPermission = await _checkPermission();
    if (!isPermission) {
      Fluttertoast.showToast(msg: '权限不足');
      return;
    }

    // 2.获取视频下载链接
    var videoUrl = await VideoDao.getVideoUrl(item.courseId.toString());
    var model = videoUrl.model as VideoUrlModel?;

    // 3.判断是否是否已经下载过了
    if (model != null && model.code == 1) {
      checkWifiOnly(context, _startDownload,[model.data!.videoUrl, item]);
    } else if (model != null) {
      Fluttertoast.showToast(msg: model.msg!);
    } else {
      Fluttertoast.showToast(msg: '获取下载地址失败');
    }
  }

  ///
  /// @name _startDownload
  /// @description 开始下载
  /// @parameters
  /// @return
  /// @author waitwalker
  /// @date 2020/7/23
  ///
  _startDownload(String videoUrl, ListEntity item) async {
    // 获取地址
    var _localPath = (await _findLocalPath()) + '/video';
    final savedDir = Directory(_localPath);
    bool hasExisted = savedDir.existsSync();
    if (!hasExisted) {
      savedDir.createSync();
    }

    // 课程名称
    String? courseName = item.courseName;

    // 将video url 以"/" 拆分成数组
    List list = videoUrl.split("/");
    var suffixLast = videoUrl.split('.').last;

    // 文件hash值
    String fileHashString = "${list[3]}";

    // 文件名
    var filename = '$fileHashString.$suffixLast';

    // 完整路径
    String fullPath = "$_localPath/$filename";
    print("文件路径名称:$fullPath");

    File file = File("$fullPath");
    bool isExist = await file.exists();
    if (isExist) {
      // 点击当前正在下载的index
      if (currentIndex == item.itemIndex) {
        Fluttertoast.showToast(msg: "该视频正在缓存中");
        return;
      } else {
        Fluttertoast.showToast(msg: "该视频已下载");
        return;
      }
    } else {
      if (isLoading) {
        Fluttertoast.showToast(msg: "其他视频缓存中,请稍后!");
        return;
      }
      currentFullPath = fullPath;
      itemCurrentIndex = item.itemIndex;

      // 存储课程名称
      SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
      sharedPreferences.setString(fileHashString, courseName!);

      Dio dio = Dio();
      cancelToken = CancelToken();
      Response response = await dio.download(videoUrl, "$fullPath", cancelToken: cancelToken, onReceiveProgress: (received, total) {
        if (total != -1) {
          String current = (received / total * 100).toStringAsFixed(0) + "%";
          currentIndex = item.itemIndex;
          ///当前下载的百分比例
          print("当前视频下载进度: "+(received / total * 100).toStringAsFixed(0) + "%");
          isLoading = true;
          if (current.contains("100")) {
            isLoading = false;
            current = "已下载";
            currentIndex = 5000000;
          }
          ListEntity listEntity = item;
          listEntity.progress = current;

          streamSink.add(
              {"value":current,
                "index":listEntity.itemIndex
              });
        }
      }).catchError((error){
        // 下载失败 移除本地
        _deleteFailedFile("$fullPath");
        if (isDispose) {
          return null;
        }
        // 页面销毁回调处理
        print("error:下载错误");
        isLoading = false;
        currentIndex = 5000000;
        streamSink.add(
            {"value":"下载",
              "index":item.itemIndex
            });
      });
      print("response:$response");
    }
  }

  ///
  /// @name _deleteFailedFile
  /// @description 下载失败 删除文件
  /// @parameters
  /// @return
  /// @author waitwalker
  /// @date 2020/7/23
  ///
  _deleteFailedFile(String filePath) async {
    File file = File(filePath);
    bool isExist = await file.exists();
    if (isExist) {
      file.deleteSync();
    }
  }

  ///
  /// @name 获取存储目录
  /// @description
  /// @parameters
  /// @return
  /// @author waitwalker
  /// @date 2020/7/23
  ///
  Future<String> _findLocalPath() async {
    final directory = Platform.isAndroid
        ? await (getExternalStorageDirectory() as FutureOr<Directory>)
        : await getApplicationDocumentsDirectory();
    return directory.path;
  }

  ///
  /// @name 获取权限
  /// @description
  /// @parameters
  /// @return
  /// @author waitwalker
  /// @date 2020/7/23
  ///
  Future<bool> _checkPermission() async {
    if (Platform.isAndroid) {
      PermissionStatus permission = await Permission.storage.status;
      if (permission != PermissionStatus.granted) {
        Map<Permission, PermissionStatus> permissions =
        await [Permission.storage].request();
        if (permissions[Permission.storage] == PermissionStatus.granted) {
          return true;
        }
      } else {
        return true;
      }
    } else {
      return true;
    }
    return false;
  }

  ///
  /// @name _buildBottomRow
  /// @description 下载,作业,回放等底部栏
  /// @parameters
  /// @return
  /// @author waitwalker
  /// @date 2020/7/23
  ///
  _buildBottomRow(Map? map,ListEntity item, int index) {
    return <Widget>[
      const SizedBox(height: 8),
      Container(height: 0.5, color: Color(0xFFD8D8D8)),
      const SizedBox(height: 12),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          // const SizedBox(width: 25),
          if (item.workStatus! >= 1)
            Expanded(
              child: InkWell(
                child: Container(
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Icon(MyIcons.HOMEWORK, size: SingletonManager.sharedInstance!.screenWidth > 500.0 ? 16 : 14, color: Color(MyColors.shadow2)),
                      const SizedBox(width: 4),
                      Text(widget.isSenior? '作业':"练习", style: TextStyle(fontSize: SingletonManager.sharedInstance!.screenWidth > 500.0 ? 16 : 14, color: Color(MyColors.shadow2),),),
                    ],
                  ),
                ),
                onTap: (){
                  if (item.workStatus ==1) {
                    _onTapHomework(item);
                  } else {
                    Fluttertoast.showToast(msg: widget.isSenior? "作业未开始" : "练习未开始",gravity: ToastGravity.CENTER);
                  }
                },
              ),
            ),
          if (item.workStatus! >= 1)
            Container(width: 0.5, height: 20, color: Color(0xFFD8D8D8)),
          if (item.hdResourceId! > 0)
            Expanded(
              child: InkWell(
                child: Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Icon(MyIcons.NEW_DOWNLOAD, size: SingletonManager.sharedInstance!.screenWidth > 500.0 ? 16 : 14, color: Color(MyColors.shadow2),),
                      const SizedBox(width: 2),
                      buildText(map, index),
                    ],
                  ),
                ),
                //onTap: () => _onTapDownload(item, index),
                onTap: ()=>_downloadFile(item, index),
              ),
            ),
          if (item.hdResourceId! > 0)
            Container(width: 0.5, height: 20, color: Color(0xFFD8D8D8)),
          // const SizedBox(width: 25),
          Expanded(
            child: InkWell(
              child: Container(
                alignment: Alignment.center,
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Icon(MyIcons.LIVE,
                      size: SingletonManager.sharedInstance!.screenWidth > 500.0 ? 16 : 14, color: Color(MyColors.shadow2),),
                    const SizedBox(width: 4),
                    Text(widget.isSenior ? '回放' : "播放", style: TextStyle(fontSize: SingletonManager.sharedInstance!.screenWidth > 500.0 ? 16 : 14, color: Color(MyColors.shadow2),),),
                  ],
                ),
              ),
              onTap: () => _onTapPlayback(item),
            ),
          ),
        ],
      ),
    ];
  }

  ///
  /// @name buildText
  /// @description 下载显示处理
  /// @parameters
  /// @return
  /// @author waitwalker
  /// @date 2020/7/23
  ///
  buildText(Map? map, int index) {
    if (map == null) {
      return Text('下载', style: TextStyle(fontSize: SingletonManager.sharedInstance!.screenWidth > 500.0 ? 16 : 14, color: Color(MyColors.shadow2),),);
    } else {
      int? currentIndex = map["index"];
      if (currentIndex != index) {
        return Text('下载', style: TextStyle(fontSize: SingletonManager.sharedInstance!.screenWidth > 500.0 ? 16 : 14, color: Color(MyColors.shadow2),),);
      } else {
        String value = map["value"];
        return Text(value, style: TextStyle(fontSize: SingletonManager.sharedInstance!.screenWidth > 500.0 ? 16 : 14, color: Color(MyColors.shadow2),),);
      }
    }
  }

  ///
  /// @name _onTapHomework
  /// @description 作业按钮点击回调
  /// @parameters
  /// @return
  /// @author waitwalker
  /// @date 2020/7/23
  ///
  _onTapHomework(ListEntity item) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) {
      var token = NetworkManager.getAuthorization();
      var url = '${APIConst.practiceHost}/homework.html?token=$token&livecourseid=${item.courseId}';
      return MicrocourseWebPage(
        initialUrl: url,
        resourceId: item.courseId,
        resourceName: item.courseName,
      );
    }));
  }
}
