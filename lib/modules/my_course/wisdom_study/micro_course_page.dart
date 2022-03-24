import 'dart:io';
import 'dart:ui';
import 'package:my_gallery/common/dao/original_dao/course_dao_manager.dart';
import 'package:my_gallery/common/singleton/singleton_manager.dart';
import 'package:my_gallery/model/micro_course_resource_model.dart';
import 'package:my_gallery/model/resource_info_model.dart';
import 'package:my_gallery/modules/my_plan/my_plan_model.dart';
import 'package:my_gallery/modules/widgets/webviews/common_webview_page.dart';
import 'package:my_gallery/modules/widgets/pdf/pdf_page.dart';
import 'package:my_gallery/common/redux/app_state.dart';
import 'package:my_gallery/modules/widgets/player/ctrl_menu.dart';
import 'package:my_gallery/modules/my_course/wisdom_study/exercise_page.dart';
import 'package:my_gallery/modules/my_course/wisdom_study/video_play_widget.dart';
import 'package:my_gallery/modules/widgets/style/style.dart';
import 'package:my_gallery/common/logger/logger.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import 'package:videoplayer/video_player.dart';


/// 微课页面
/// 视频横屏自动全屏，竖屏自动退出
/// 页面初始化，打开横竖屏限制，随系统转动
/// 页面销毁，关闭横屏，强制竖屏
/// 取消手动全屏按钮
///
/// @name MicroCoursePage
/// @description 微课页面
/// @author waitwalker
/// @date 2020-01-10
///
// ignore: must_be_immutable
class MicroCoursePage extends StatefulWidget {
  MicroCourseResourceDataEntity? data;
  var courseId;
  String? from;
  bool fromCollegeEntrance;
  bool hideXueAn;
  Tasks? task;

  int? materialid;
  int? nodeid;
  int? level;
  int? isdiagnosis;

  MicroCoursePage(this.data, {this.courseId, this.from,this.fromCollegeEntrance = false, this.hideXueAn = false, this.task, this.materialid, this.nodeid, this.level, this.isdiagnosis});

  @override
  _MicroCoursePageState createState() => _MicroCoursePageState();
}

class _MicroCoursePageState extends State<MicroCoursePage>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  VideoPlayerController? _videoPlayerController1;
  ChewieController? _chewieController;

  var _videoPlayerControllerWillDispose;
  var _chewieControllerWillDispose;

  // 播放列表相关变量
  String? videoUrlNew;

  @override
  void didChangeMetrics() {
    if (!mounted || index != 0 || _chewieController == null) {
      return;
    }
    double width = window.physicalSize.width;
    double height = window.physicalSize.height;
    if (width > height) {
      !_chewieController!.isFullScreen ? _chewieController?.enterFullScreen() : 
      // ignore: unnecessary_statements
      null;
    } else {
      _chewieController!.isFullScreen ? _chewieController?.exitFullScreen() : 
      // ignore: unnecessary_statements
      null;
    }
  }

  TabController? controller;
  static List tabData = [
    {'text': '看微课', 'icon': new Icon(Icons.language)},
    {'text': '做练习', 'icon': new Icon(Icons.extension)},
  ];
  List<Widget> myTabs = [];

  int index = 0;

  @override
  void initState() {
    super.initState();
    videoUrlNew = widget.data!.videoUrl;
    controller = new TabController(initialIndex: 0, vsync: this, length: 2);
    for (int i = 0; i < tabData.length; i++) {
      myTabs.add(new Tab(text: tabData[i]['text']));
    }
    controller!.addListener(() {
      if (controller!.indexIsChanging) {
        _onTabChange();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_chewieController == null) {
      _initPlayer();
    }
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp
    ]);
    _videoPlayerController1!.dispose();
    _chewieController!.dispose();
    restoreOrientationSettings();
    super.dispose();
  }

  void initVideo(
      {String? url,
      bool autoPlay = false,
      bool backgroundPlay = false,
      Duration? startAt}) {
    // video
    debugLog('视频地址: $url');
    _videoPlayerController1 = VideoPlayerController.network(
        url ?? widget.data!.videoUrl!, backgroundPlay: backgroundPlay);
    _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController1!,
        aspectRatio: 16 / 9,
        autoPlay: autoPlay,
        looping: false,
        startAt: startAt,
        allowFullScreen: true,
        allowMuting: false,
        customControls: MenuMaterialControls(title: widget.data!.resourceName),
        deviceOrientationsAfterFullScreen: [
          DeviceOrientation.portraitUp,
        ],
        autoInitialize: true,
        placeholder: Center(
          child: Image.network(widget.data!.imageUrl!, fit: BoxFit.fitHeight),
        ));
  }

  Store<AppState> _getStore() {
    return StoreProvider.of(context);
  }

  @override
  Widget build(BuildContext context) {
    return StoreBuilder(builder: (BuildContext context, Store<AppState> store) {
      return NotificationListener(
        onNotification: (dynamic notification) {
          if (notification is ChangeVideoSourceNotification) {
            var lineId = notification.lineId;
            print('收到通知 $lineId');
            _initPlayer();
          } else if (notification is PlayBackgroundNotification) {
            _videoPlayerController1!.backgroundPlay = notification.backgroundPlay;
          }
          return true;
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text(widget.data?.resourceName ?? '微课'),
            elevation: 1,
            backgroundColor: Colors.white,
            centerTitle: Platform.isIOS ? true : false,
            actions: <Widget>[
              _buildXueAnWidget(),
            ],
          ),
          body: Column(
            children: <Widget>[
              TabBar(
                  controller: controller,
                  indicatorColor: Color(MyColors.primaryValue),
                  indicatorSize: TabBarIndicatorSize.label,
                  labelStyle: textStyleTabUnselected,
                  labelColor: Color(MyColors.primaryValue),
                  unselectedLabelColor: Color(MyColors.black999),
                  tabs: myTabs),
              Expanded(
                child: IndexedStack(
                  index: index,
                  children: <Widget>[
                    Container(
                      child: Column(
                        children: <Widget>[
                          _chewieController == null
                              ? Center(child: CircularProgressIndicator())
                              : VideoPlayWidget(
                              chewieController: _chewieController!,
                              title: widget.data!.resourceName,
                              from: widget.from,
                              videoInfo: VideoInfo(
                                videoUrl: videoUrlNew,
                                imageUrl: widget.data!.imageUrl,
                                resName: widget.data!.resourceName,
                                resId: widget.data!.resouceId.toString(),
                                courseId: widget.courseId.toString(),
                              )),
                          // 播放列表, 需要的时候打开
                          //Expanded(child: _playListWidget()),
                        ],
                      ),
                    ),
                    ExercisePage(widget.data, widget.courseId,fromCollegeEntrance: widget.fromCollegeEntrance, task: widget.task, isdiagnosis: widget.isdiagnosis, level: widget.level, nodeid: widget.nodeid, materialid: widget.materialid,)
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  ///
  /// @name _buildXueAnWidget
  /// @description 构建学案Widget
  /// @parameters
  /// @return
  /// @author waitwalker
  /// @date 2020/5/12
  ///
  _buildXueAnWidget() {
    // 隐藏学案
    if (widget.data!.planUrlList == null || widget.data!.planUrlList!.length == 0) {
      return Container();
    } else {
      return Center(
        child: InkWell(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Text('学案', style: textStyleNormal),
          ),
          onTap: () {
            _chewieController!.pause();
            restoreOrientationSettings();
            var previewOfficeUrl = widget.data!.planUrlList![0].previewPlanUrl;
            var downloadUrl = widget.data!.planUrlList![0].dowPlanUrl!;
            if (downloadUrl.endsWith('.pdf') && !SingletonManager.sharedInstance!.isGuanKong!) {
              /// 调到PDF预览页
              Navigator.of(context).push(MaterialPageRoute(builder: (_) {
                return PDFPage(downloadUrl, title: widget.data!.resourceName, fromZSDX: true, resId: "${widget.data?.resouceId}", officeURL: previewOfficeUrl,);
              }));
            } else {
              Navigator.of(context).push(MaterialPageRoute(builder: (_) {
                return CommonWebviewPage(
                  initialUrl: previewOfficeUrl,
                  downloadUrl: downloadUrl,
                  title: widget.data!.resourceName,
                  pageType: 3,
                  resId: "${widget.data?.resouceId}",
                );
              }));
            }
          },
        ),
      );
    }
  }

  void _onTabChange() {
    index = controller!.index;
    if (index != 0) {
      _videoPlayerController1!.pause();
      restoreOrientationSettings();
    } else if (index == 0) {
      initOrientationSettings();
    }
    setState(() {});
  }

  Future initOrientationSettings() async {
    WidgetsBinding.instance!.addObserver(this);
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
  }

  Future restoreOrientationSettings() async {
    WidgetsBinding.instance!.removeObserver(this);
    await SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp,DeviceOrientation.portraitDown]);
  }

  Future _initPlayer() async {
    var videoUrl;
    var appInfo = _getStore().state.appInfo!;
    if (appInfo.line == null || appInfo.line!.lineId == 101) {
      videoUrl = widget.data!.videoUrl;
    } else {
      var resultData = await CourseDaoManager.getResourceInfo(widget.data!.resouceId,
          lineId: appInfo.line!.lineId as int?);
      var ok = resultData.result &&
          resultData.model != null &&
          resultData.model.code == 1;
      if (ok) {
        var model = resultData.model as ResourceInfoModel;
        videoUrl = model.data!.videoUrl;
      } else {
        videoUrl = widget.data!.videoUrl;
      }
    }
    // video
    if (_videoPlayerController1 != null) {
      _videoPlayerController1!.pause();
      _videoPlayerControllerWillDispose = _videoPlayerController1;
    }
    if (_chewieController != null) {
      _chewieControllerWillDispose = _chewieController;
    }
    initVideo(
        url: videoUrl,
        backgroundPlay: appInfo.backgroundPlay ?? false,
        autoPlay: _chewieController != null,
        startAt: await _chewieController?.videoPlayerController?.position);
    setState(() {});

    // _chewieControllerWillDispose?.dispose();
    // initOrientationSettings();
  }


  @override
  void didUpdateWidget(MicroCoursePage oldWidget) {
    _chewieControllerWillDispose?.dispose();
    _videoPlayerControllerWillDispose?.dispose();
    super.didUpdateWidget(oldWidget);
  }
}

class ChangeVideoSourceNotification extends Notification {
  int? lineId;

  ChangeVideoSourceNotification(this.lineId);
}

class PlayBackgroundNotification extends Notification {
  bool backgroundPlay;

  PlayBackgroundNotification(this.backgroundPlay);
}
