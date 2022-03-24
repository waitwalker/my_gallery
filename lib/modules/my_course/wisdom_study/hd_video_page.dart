import 'dart:io';
import 'dart:ui';
import 'package:my_gallery/common/dao/manager/dao_manager.dart';
import 'package:my_gallery/common/dao/original_dao/course_dao_manager.dart';
import 'package:my_gallery/model/resource_info_model.dart';
import 'package:my_gallery/modules/my_course/wisdom_study/micro_course_page.dart';
import 'package:my_gallery/common/redux/app_state.dart';
import 'package:my_gallery/modules/my_course/wisdom_study/video_play_widget.dart';
import 'package:my_gallery/common/logger/logger.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:my_gallery/modules/my_plan/my_plan_model.dart';
import 'package:redux/redux.dart';
import 'package:videoplayer/video_player.dart';
import '../../widgets/player/ctrl_menu.dart';

///
/// @name HDVideoPage
/// @description 高清课页面
/// @author waitwalker
/// @date 2020-01-10
///
class HDVideoPage extends StatefulWidget {
  final String? source;
  final String? from;
  final String? coverUrl;
  final String? title;
  final VideoInfo? videoInfo;
  final Tasks? task;

  HDVideoPage(
      {required this.source,
      this.coverUrl,
      this.title,
      this.videoInfo,
      this.from,
      this.task
      });

  @override
  _HDVideoPageState createState() => _HDVideoPageState();
}

class _HDVideoPageState extends State<HDVideoPage> with WidgetsBindingObserver {
  VideoPlayerController? _videoPlayerController1;
  ChewieController? _chewieController;

  var _videoPlayerControllerWillDispose;

  var _chewieControllerWillDispose;

  @override
  void initState() {
    super.initState();
    // initVideo();
    // initOrientationSettings();
    _taskStudyStateFetch();
  }

  ///
  /// @description 提交任务学习记录
  /// @param
  /// @return
  /// @author waitwalker
  /// @time 11/13/20 3:57 PM
  ///
  _taskStudyStateFetch() async{
    if (widget.task != null && widget.task!.isFinish == 0) {
      await DaoManager.fetchMyPlanTaskFinishLog(widget.task!.taskId, widget.task!.resourceId);
    }
  }

  @override
  void dispose() {
     restoreOrientationSettings();
    _chewieController!.dispose();
    _videoPlayerController1!.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_chewieController == null) {
      _initPlayer();
    }
  }

  Store<AppState> _getStore() {
    return StoreProvider.of(context);
  }

  Future _initPlayer() async {
    var videoUrl;
    var appInfo = _getStore().state.appInfo!;
    if (appInfo.line == null || appInfo.line!.lineId == 101) {
      videoUrl = widget.source;
    } else {
      var resultData = await CourseDaoManager.getResourceInfo(widget.videoInfo!.resId,
          lineId: appInfo.line!.lineId as int?);
      var ok = resultData.result &&
          resultData.model != null &&
          resultData.model.code == 1;
      if (ok) {
        var model = resultData.model as ResourceInfoModel;
        videoUrl = model.data!.videoUrl;
      } else {
        videoUrl = widget.source;
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
  }

  void initVideo(
      {String? url,
      bool autoPlay = false,
      bool backgroundPlay = false,
      Duration? startAt}) {
    // video
    debugLog('视频地址: $url');
    _videoPlayerController1 = VideoPlayerController.network(url ?? widget.source!, backgroundPlay: backgroundPlay);
    _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController1!,
        aspectRatio: 16 / 9,
        autoPlay: autoPlay,
        looping: false,
        startAt: startAt,
        allowFullScreen: true,
        allowMuting: false,
        customControls: MenuMaterialControls(title: widget.title),
         deviceOrientationsAfterFullScreen: [
           DeviceOrientation.portraitUp
         ],
        autoInitialize: true,
        placeholder: Center(
          child: Image.network(widget.coverUrl!, fit: BoxFit.fitHeight),
        ));
  }

  @override
  void didUpdateWidget(HDVideoPage oldWidget) {
    _chewieControllerWillDispose?.dispose();
    _videoPlayerControllerWillDispose?.dispose();
    super.didUpdateWidget(oldWidget);
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
        child: _build(context),
      );
    });
  }

  Widget _build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        title: Text(widget.title ?? '高清课'),
        backgroundColor: Colors.white,
        centerTitle: Platform.isIOS ? true : false,
      ),
      body: Container(
        child: Center(
          child: Column(
            children: <Widget>[
              _chewieController == null
                  ? Center(child: CircularProgressIndicator())
                  : VideoPlayWidget(
                      chewieController: _chewieController!,
                      title: widget.title ?? '',
                      from: widget.from,
                      videoInfo: widget.videoInfo,
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Future initOrientationSettings() async {
    WidgetsBinding.instance!.addObserver(this);
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  Future restoreOrientationSettings() async {
    WidgetsBinding.instance!.removeObserver(this);
    await SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp,DeviceOrientation.portraitDown]);
  }

  @override
  void didChangeMetrics() {
    if (!mounted) {
      return;
    }
    if (_chewieController == null) {
      return;
    }
    double width = window.physicalSize.width;
    double height = window.physicalSize.height;
    if (width > height) {
      !_chewieController!.isFullScreen
          ? _chewieController?.enterFullScreen()
          : null;
    } else {
      _chewieController!.isFullScreen
          ? _chewieController?.exitFullScreen()
          : null;
    }
  }
}
