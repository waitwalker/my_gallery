import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:my_gallery/common/dao/original_dao/analysis.dart';
import 'package:my_gallery/common/network/error_code.dart';
import 'package:my_gallery/common/tools/date/time_utils.dart';
import 'package:my_gallery/event/http_error_event.dart';
import 'package:my_gallery/modules/personal/settings/wifi_only_check_widget.dart';
import 'package:my_gallery/modules/widgets/style/style.dart';
import 'package:my_gallery/common/logger/logger.dart';
import 'package:chewie/chewie.dart';
// ignore: implementation_imports
import 'package:chewie/src/chewie_player.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:videoplayer/video_player.dart';

///
/// @name VideoPlayWidget
/// @description 视频播放组件 微课&高清课播放时用到
/// @author waitwalker
/// @date 2020-01-11
///
// ignore: must_be_immutable
class VideoPlayWidget extends StatefulWidget {
  ChewieController chewieController;
  String? title;
  String? from;

  VideoInfo? videoInfo;
  String? subtitle;

  VideoPlayWidget({required this.chewieController,
        required this.title,
        this.videoInfo,
        this.from,
    this.subtitle,
  })
      : assert(chewieController != null);

  @override
  State<StatefulWidget> createState() {
    return _VideoPlayWidgetState();
  }
}

class _VideoPlayWidgetState extends State<VideoPlayWidget> with WifiOnlyCheckWidget {
  VideoPlayerController get _videoPlayerController1 =>
      widget.chewieController.videoPlayerController;
  late VoidCallback listener;
  int? logId = 0;
  int lastPos = -1;

  late StreamController streamController;
  // 用于发射事件
  StreamSink<Map> get streamSink => streamController.sink as StreamSink<Map<dynamic, dynamic>>;
  // 用于接收事件
  Stream<Map> get streamData => streamController.stream as Stream<Map<dynamic, dynamic>>;

  late StreamSubscription streamSubscription;
  Map<String, int> progressMap = {};
  // 是否正在下载
  bool isLoading = false;
  CancelToken? cancelToken;
  bool isDispose = false;

  String? currentFullPath;
  int? itemCurrentIndex;

  @override
  void initState() {
    super.initState();
    isDispose = false;
    streamController = StreamController<Map>.broadcast();
    streamSubscription = streamController.stream.listen((event) {
      print("event:$event");
    });

    streamSubscription.onDone(() {
      print("stream监听完成");
    });

    _videoPlayerController1.addListener(() {
      var initialized = _videoPlayerController1.value.initialized;
      if (initialized) {
        setState(() {});
      }
    });

    listener = () async {
      if (!mounted) {
        return;
      }
      if (widget.videoInfo!.resId != null && widget.videoInfo!.courseId != null) {
        if (_videoPlayerController1.value.position == null ||
            _videoPlayerController1.value.duration == null) {
          return;
        }
        var pos = _videoPlayerController1.value.position.inSeconds;
        var dur = _videoPlayerController1.value.duration!.inSeconds;
        if (pos <= lastPos) {
          return;
        }
        lastPos = pos;
        debugLog(dur);
        debugLog(pos);
        if (pos % 5 == 0) {
          await reportVideoProgress(pos, dur);
        }
      }
    };
    _videoPlayerController1.addListener(listener);

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

  }

  @override
  dispose() {
    isDispose = true;
    if (cancelToken != null) cancelToken!.cancel();
    streamController.close();
    streamSink.close();
    super.dispose();
  }

  Future reportVideoProgress(int pos, int dur) async {
    var reportVideo = await AnalysisDao.reportVideo(
        resId: widget.videoInfo!.resId,
        refId: widget.videoInfo!.courseId,
        logId: logId,
        videoDuration: dur,
        isViewEnd: pos == dur ? 1 : 0);
    if (logId == 0 &&
        reportVideo.result &&
        reportVideo.model != null &&
        reportVideo.model.code == 1 &&
        reportVideo.model.data != null) {
      logId = reportVideo.model.data.logId;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(MyColors.choseLine),
      child: StreamBuilder(stream: streamData, builder: (BuildContext context, AsyncSnapshot snapshot){
        Map? map = snapshot.data;
        return Column(
          children: <Widget>[
            Chewie(controller: widget.chewieController,),
            Divider(height: 0.5),
            InkWell(
              child: Container(
                  color: Colors.white,
                  width: MediaQuery.of(context).size.width,
                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          SizedBox(
                            width: MediaQuery.of(context).size.width - 120,
                            child: Text(widget.title ?? '', style: textStyleContent333, overflow: TextOverflow.ellipsis),
                          ),
                          Text( '${widget.subtitle ?? "微课" }  |  ${toHMS(widget.chewieController.videoPlayerController.value.duration?.inMicroseconds ?? 0)}', style: textStyleSub999),
                        ],
                      ),
                      builderDownloadWidget(map),
                    ],
                  )),
              onTap: () {},
            ),
          ],
        );
      }),
    );
  }

  builderDownloadWidget(Map? map) {
    if (map == null) {
      return InkWell(
        child: Icon(MyIcons.DOWNLOAD, size: 26),
        onTap: _downloadAction,
      );
    } else {
      String value = map["value"];
      return InkWell(
        child: Row(
          children: <Widget>[
            Text(value),
            Padding(padding: EdgeInsets.only(right: 10),),
            Icon(MyIcons.DOWNLOAD, size: 26),
          ],
        ),
        onTap: _downloadAction,
      );
    }
  }

  ///
  /// @name _downloadAction
  /// @description 下载点击事件
  /// @parameters
  /// @return
  /// @author waitwalker
  /// @date 2020/7/23
  ///
  _downloadAction() async {
    String? videoUrl = widget.videoInfo?.videoUrl;
    String? videoDownloadUrl = widget.videoInfo?.videoDownloadUrl;
    String? imageUrl = widget.videoInfo?.imageUrl;
    print("imageUrl:$imageUrl");
    String? resName = widget.videoInfo?.resName;
    if (widget.videoInfo == null) {
      Fluttertoast.showToast(msg: 'video info null warning');
      videoUrl = widget.chewieController.videoPlayerController.dataSource;
    }
    if (videoUrl == null || videoUrl.isEmpty) {
      Fluttertoast.showToast(msg: 'video url is null err');
      return;
    }
    if (!videoUrl.endsWith('.mp4') && videoDownloadUrl == null) {
      Fluttertoast.showToast(msg: '获取资源失败');
    } else
      //await _download(videoDownloadUrl ?? videoUrl, imageUrl, resName);
      _downloadFile(videoDownloadUrl ?? videoUrl, resName);
  }

  ///使用dio 下载文件
  _downloadFile(String videoUrl, String? courseName) async {
    // 1. 获取权限
    var isPermission = await _checkPermission();
    if (!isPermission) {
      Fluttertoast.showToast(msg: '权限不足');
      return;
    }

    checkWifiOnly(context, _startDownload,[videoUrl, courseName]);
  }

  ///
  /// @name _startDownload
  /// @description 开始下载
  /// @parameters
  /// @return
  /// @author waitwalker
  /// @date 2020/7/23
  ///
  _startDownload(String videoUrl, String courseName) async {
    // 获取地址
    var _localPath = (await _findLocalPath()) + '/video';
    final savedDir = Directory(_localPath);
    bool hasExisted = savedDir.existsSync();
    if (!hasExisted) {
      savedDir.createSync();
    }

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
      if (isLoading) {
        Fluttertoast.showToast(msg: "视频缓存中,请稍后!");
        return;
      }
      Fluttertoast.showToast(msg: "该视频已下载");
      streamSink.add(
          {"value":"已下载",
          });
      return;
    } else {
      if (isLoading) {
        Fluttertoast.showToast(msg: "视频缓存中,请稍后!");
        return;
      }

      currentFullPath = fullPath;

      // 存储课程名称
      SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
      sharedPreferences.setString(fileHashString, courseName);

      Dio dio = Dio();
      cancelToken = CancelToken();
      Response response = await dio.download(videoUrl, fullPath, cancelToken: cancelToken, onReceiveProgress: (received, total) {
        if (total != -1) {

          String current = (received / total * 100).toStringAsFixed(0) + "%";
          ///当前下载的百分比例
          print("当前视频下载进度: "+(received / total * 100).toStringAsFixed(0) + "%");
          isLoading = true;
          if (current.contains("100")) {
            isLoading = false;
            current = "已下载";
          }
          streamSink.add({"value":current,});

          // if (current.contains("50")) {
          //   streamSubscription.cancel();
          // }
        }
      }).catchError((error){
        // 下载失败 移除本地
        _deleteFailedFile("$_localPath/$filename");
        if (isDispose) {
          return null;
        }
        // 页面销毁回调处理
        print("error:下载错误");
        isLoading = false;
        streamSink.add(
            {"value":"",
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

  Future<String> _findLocalPath() async {
    final directory = Platform.isAndroid
        ? await (getExternalStorageDirectory() as FutureOr<Directory>)
        : await getApplicationDocumentsDirectory();
    return directory.path;
  }

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
}

class VideoInfo {
  final String? videoUrl;
  final String? videoDownloadUrl;
  final String? imageUrl;
  final String? resName;
  final String? resId;
  final String? courseId;

  const VideoInfo(
      {required this.videoUrl,
        this.imageUrl,
        this.resName,
        this.resId,
        this.courseId,
        this.videoDownloadUrl});
}
