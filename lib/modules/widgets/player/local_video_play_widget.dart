import 'dart:io';
import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:my_gallery/common/dao/original_dao/course_dao_manager.dart';
import 'package:my_gallery/model/resource_info_model.dart';
import 'package:my_gallery/modules/my_course/wisdom_study/micro_course_page.dart';
import 'package:my_gallery/common/redux/app_state.dart';
import 'package:my_gallery/common/logger/logger.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import 'package:videoplayer/video_player.dart';
import 'ctrl.dart';

///
/// @name LocalVideoPlayWidget
/// @description 本地视频播放组件
/// @author waitwalker
/// @date 2020-01-11
///
// ignore: must_be_immutable
class LocalVideoPlayWidget extends StatefulWidget {
  String source;

  var resourceId;
  var courseId;

  var title;

  LocalVideoPlayWidget(this.source, {this.resourceId, this.courseId, this.title});

  @override
  _LocalVideoPlayWidgetState createState() => _LocalVideoPlayWidgetState(source);
}

class _LocalVideoPlayWidgetState extends State<LocalVideoPlayWidget> with WidgetsBindingObserver {
  var source;
  VideoPlayerController? controller;

  ChewieController? _chewieController;

  _LocalVideoPlayWidgetState(this.source);

  @override
  void initState() {
    // WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    controller!.dispose();
    _chewieController!.dispose();
    // WidgetsBinding.instance.removeObserver(this);
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
      var resultData = await CourseDaoManager.getResourceInfo(widget.resourceId,
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
    initVideo(
        url: videoUrl,
        autoPlay: false,
        backgroundPlay: appInfo.backgroundPlay ?? false);
    setState(() {});
    // initOrientationSettings();
  }

  void initVideo(
      {required String url, bool autoPlay = false, bool backgroundPlay = false}) {
    // video
    debugLog('视频地址: $url');
    Uri uri = Uri.parse(url);
    bool isLocal = false;
    if (uri.isScheme('http') || uri.isScheme('https')) {
      isLocal = false;
      controller = VideoPlayerController.network(url ?? source, backgroundPlay: backgroundPlay);
    } else {
      isLocal = true;
      controller = VideoPlayerController.file(File(url ?? source), backgroundPlay: backgroundPlay);
    }
    _chewieController = ChewieController(
      videoPlayerController: controller!,
      aspectRatio: 16 / 9,
      autoPlay: autoPlay,
      looping: false,
      allowFullScreen: true,
      allowMuting: false,
      customControls: MaterialControls(title: widget.title ?? '', isLocalPlay: isLocal,),
       deviceOrientationsAfterFullScreen: [
         DeviceOrientation.portraitUp,
       ],
      autoInitialize: true,
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      controller!.pause();
    } else if (state == AppLifecycleState.resumed) {
      controller!.pause();
    }
    super.didChangeAppLifecycleState(state);
  }

  @override
  Widget build(BuildContext context) {
    return StoreBuilder(builder: (BuildContext context, Store<AppState> store) {
      return NotificationListener(
        onNotification: (dynamic notification) {
          if (notification is ChangeVideoSourceNotification) {
            var lineId = notification.lineId;
            print('收到通知 $lineId');
            CourseDaoManager.getResourceInfo(widget.resourceId, lineId: lineId)
                .then((resultData) {
              var ok = resultData.result &&
                  resultData.model != null &&
                  resultData.model.code == 1;
              if (ok) {
                var model = resultData.model as ResourceInfoModel;
                var newUrl = model.data!.videoUrl;

                var bgPlay = controller!.backgroundPlay;
                var cController = _chewieController!;
                var vController = controller;
                cController.pause();
                _chewieController = null;
                setState(() {
                  initVideo(
                      url: newUrl!, autoPlay: true, backgroundPlay: bgPlay);
                  setState(() {});
                  Future.delayed(Duration(seconds: 1), () {
                    cController.dispose();
                    vController!.dispose();
                  });
                });
              }
            });
          } else if (notification is PlayBackgroundNotification) {
            controller!.backgroundPlay = notification.backgroundPlay;
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
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(widget.title ?? ''),
      ),
      body: Center(
        child: Home(_chewieController),
      ),
    );
  }
}

// ignore: must_be_immutable
class Home extends StatelessWidget {
  ChewieController? _chewieController;

  Home(this._chewieController);

  @override
  Widget build(BuildContext context) {
    Widget child;
    if (_chewieController != null) {
      child = new Chewie(
        controller: _chewieController!,
      );
    } else {
      child = Text(
        '视频地址不存在',
        style: TextStyle(color: Colors.white),
      );
    }
    return Container(
      color: Colors.black,
      child: Center(
        child: child,
      ),
    );
  }
}
