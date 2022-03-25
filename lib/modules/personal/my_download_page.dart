import 'dart:async';
import 'dart:io';
import 'package:my_gallery/common/locale/localizations.dart';
import 'package:my_gallery/common/singleton/singleton_manager.dart';
import 'package:my_gallery/common/tools/share_preference/share_preference.dart';
import 'package:my_gallery/modules/personal/settings/wifi_only_check_widget.dart';
import 'package:my_gallery/modules/widgets/webviews/common_webview_page.dart';
import 'package:my_gallery/modules/widgets/pdf/pdf_page.dart';
import 'package:my_gallery/modules/widgets/style/style.dart';
import 'package:my_gallery/modules/widgets/empty_placeholder/empty_placeholder_widget.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../widgets/player/local_video_play_widget.dart';


///
/// @name MyDownloadPage
/// @description 我的下载
/// @author waitwalker
/// @date 2020-01-10
///
class MyDownloadPage extends StatefulWidget {
  @override
  _MyDownloadPageState createState() => _MyDownloadPageState();
}

class _MyDownloadPageState extends State<MyDownloadPage> with WifiOnlyCheckWidget {

  List<FileSystemEntity> pdfFiles = [];
  List<FileSystemEntity> videoFiles = [];

  @override
  void initState() {
    initOfficeData();
    initMediaData();
    super.initState();
  }



  ///
  /// @description 初始化文档类型数据 包括pdf & doc等
  /// @param
  /// @return
  /// @author waitwalker
  /// @time 3/15/21 3:42 PM
  ///
  Future<void> initOfficeData() async {
    final dir = Platform.isAndroid
        ? await (getExternalStorageDirectory() as FutureOr<Directory>)
        : await getApplicationDocumentsDirectory();
    var pdf = Directory(p.join(dir.path, 'pdf'));
    if (pdf.existsSync()) {
      pdfFiles = pdf.listSync();
      pdfFiles.sort((FileSystemEntity a,FileSystemEntity b) => b.path.compareTo(a.path));
      setState(() {});
    }
  }

  ///
  /// @description 初始化媒体类型数据 主要是视频
  /// @param 
  /// @return 
  /// @author waitwalker
  /// @time 3/15/21 3:42 PM
  ///
  Future<void> initMediaData() async {
    final dir = Platform.isAndroid
        ? await (getExternalStorageDirectory() as FutureOr<Directory>)
        : await getApplicationDocumentsDirectory();
    var video = Directory(p.join(dir.path, 'video'));
    if (video.existsSync()) {
      videoFiles = video.listSync();
      videoFiles.sort((FileSystemEntity a,FileSystemEntity b) => b.path.compareTo(a.path));
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    var length = (videoFiles.length) + (pdfFiles.length);
    return Scaffold(
      appBar: AppBar(
        elevation: 1.0,
        title: Text(MTTLocalization.of(context)!.currentLocalized!.myDownloadPageNavigatorTitle!),
        backgroundColor: Colors.white,
        centerTitle: Platform.isIOS ? true : false,
      ),
      body: builderContent(length)
    );
  }

  ///
  /// @description 绘制body
  /// @param 
  /// @return 
  /// @author waitwalker
  /// @time 3/15/21 3:46 PM
  ///
  builderContent(int length) {
    if(length == 0) {
      return EmptyPlaceholderPage(assetsPath: 'static/images/empty.png', message: '没有数据',);
    } else {
      return Container(
        padding: EdgeInsets.all(5),
        child: ListView.builder(itemBuilder: _buildItem, itemCount: length,),);
    }
  }

  ///
  /// @description 绘制卡片item
  /// @param 
  /// @return 
  /// @author waitwalker
  /// @time 3/15/21 3:46 PM
  ///
  Widget _buildItem(BuildContext context, int index) {
    if (index < videoFiles.length) {
      return _builderVideoItem(index);
    } else {
      return _builderOfficeItem(index - videoFiles.length);
    }
  }

  ///
  /// @name 绘制视频
  /// @description
  /// @parameters
  /// @return
  /// @author waitwalker
  /// @date 2020/7/22
  ///
  InkWell _builderVideoItem(int index) {
    var filePath = videoFiles.elementAt(index).path;
    // hash + .mp4
    String basename = p.basename(filePath);

    // hashValue
    String hashValue = basename.replaceAll(".mp4", "");

    // courseName
    var courseName = SharedPrefsUtils.getString(hashValue, "课程名称")! + ".mp4";

    File f = File(filePath);
    String fileLength = f.existsSync()
        ? (f.lengthSync() / (1024 * 1024)).toStringAsFixed(1)
        : '0';

    Image image = Image.asset("static/images/mp4_cover.png", width: 104, height: 69, fit: BoxFit.fitWidth);

    return InkWell(
      child: Row(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          image,
          Padding(
              padding: EdgeInsets.only(
                left: 12,
              )),
          Expanded(
            child: Container(
              padding: EdgeInsets.only(top: 2, right: 5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(courseName, style: textStyleContent333),
                  Padding(padding: EdgeInsets.only(top: 0)),
                  Text(" ", style: textStyleSub999),
                  Padding(padding: EdgeInsets.only(top: 5)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text('${fileLength}M', style: textStyleSub999),
                      InkWell(
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 2, horizontal: 4),
                          child: Text("已完成", style: textStyle12666),
                          decoration: new BoxDecoration(border: Border.all(color: Color(MyColors.background)), borderRadius: const BorderRadius.all(const Radius.circular(4.0)),),
                        ),
                        //onTap: () => _onTapBtn(task),
                      ),
                    ],
                  ),
                  Divider()
                ],
              ),
            ),
          )
        ],
      ),
      onTap: () => _previewVideo(filePath, courseName),
      onLongPress: () => _deleteVideo(filePath),
    );
  }

  ///
  /// @description 打开视频回调
  /// @param
  /// @return
  /// @author waitwalker
  /// @time 3/15/21 3:43 PM
  ///
  _previewVideo(String path, String title) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) {
      return LocalVideoPlayWidget(path, title: title,);
    }));
  }

  ///
  /// @name _deleteVideo
  /// @description 删除PDF回调
  /// @parameters
  /// @return
  /// @author waitwalker
  /// @date 2020-01-13
  ///
  _deleteVideo(String path) async{
    File file = File(path);
    bool exist = await file.exists();
    if (exist) {
      showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Text('确定删除文件？'),
            actions: <Widget>[
              TextButton(
                child: Text('确定'),
                onPressed: () {
                  file.deleteSync();

                  // hash + .mp4
                  String basename = p.basename(path);

                  // hashValue
                  String hashValue = basename.replaceAll(".mp4", "");

                  // 删除课程名称缓存
                  SharedPrefsUtils.remove(hashValue);

                  initMediaData();
                  Navigator.of(context).pop(true);
                  setState(() {

                  });
                },
              ),
              TextButton(
                child: Text('取消'),
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
              ),
            ],
          );
        },
      ).then((del) async {
      });
    } else {
      Fluttertoast.showToast(msg: "文件不存在!",gravity: ToastGravity.CENTER);
    }
  }

  ///
  /// @description 绘制文档类型item
  /// @param 
  /// @return 
  /// @author waitwalker
  /// @time 3/15/21 3:41 PM
  ///
  Widget _builderOfficeItem(int i) {
    var image = Image.asset('static/images/pdf_cover.png', width: 104, height: 69, fit: BoxFit.fitWidth);
    var pdf = pdfFiles.elementAt(i).path;
    var basename = p.basename(pdf);
    bool isPDF = basename.contains(".pdf");
    String fullURL = "无";
    String downloadURL = "";
    List list = basename.split("+");
    if (list.length > 2) {
      fullURL = SharedPrefsUtils.get(list[2], "无");
      downloadURL = SharedPrefsUtils.get(list[2] + "ett", "无");
    }
    File f = File(pdf);
    String fileLength = f.existsSync() ? (f.lengthSync() / (1024 * 1024)).toStringAsFixed(1) : '0';
    return InkWell(
      child: Row(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          image,
          Padding(padding: EdgeInsets.only(left: 12,)),
          Expanded(
            child: Container(
              padding: EdgeInsets.only(top: 2, right: 5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(basename, style: textStyleContent333, maxLines: 2, overflow: TextOverflow.ellipsis,),
                  Padding(padding: EdgeInsets.only(top: 0)),
                  Text(" ", style: textStyleSub999),
                  Padding(padding: EdgeInsets.only(top: 5)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text('${fileLength}M', style: textStyleSub999),
                      Container(
                        padding: EdgeInsets.symmetric(vertical: 2, horizontal: 4),
                        child: Text('已完成', style: textStyle12666),
                        decoration: BoxDecoration(border: Border.all(color: Color(MyColors.background)), borderRadius: BorderRadius.all( Radius.circular(4.0)),
                        ),
                      ),
                    ],
                  ),
                  Divider()
                ],
              ),
            ),
          )
        ],
      ),
      onTap: () => _previewFile(pdf, isPDF, fullURl: fullURL, downloadURL: downloadURL, title: basename),
      onLongPress: () => _deleteFile(pdf),
    );
  }

  ///
  /// @description 预览文档文件
  /// @param
  /// @return
  /// @author waitwalker
  /// @time 2020/11/10 11:37 AM
  ///
  _previewFile(String path, bool isPDF, {String? fullURl,String? downloadURL, String? title}) async {
    if (isPDF) {
      if (SingletonManager.sharedInstance!.isGuanKong!) {
        if (title!.contains("智领错题报告")) {
          Navigator.of(context).push(MaterialPageRoute(builder: (_) {
            return PDFPage(path, title: p.basename(path),);
          }));
        } else {
          Navigator.of(context).push(MaterialPageRoute(builder: (_) {
            return CommonWebviewPage(initialUrl: fullURl, downloadUrl: downloadURL, title: title, pageType: 31,);
          }));
        }
      } else {
        Navigator.of(context).push(MaterialPageRoute(builder: (_) {
          return PDFPage(path, title: p.basename(path),);
        }));
      }
    } else {
      Navigator.of(context).push(MaterialPageRoute(builder: (_) {
        return CommonWebviewPage(initialUrl: fullURl, downloadUrl: downloadURL, title: title, pageType: 31,);
      }));
    }
  }

  ///
  /// @name _deleteFile
  /// @description 删除文件回调
  /// @parameters
  /// @return
  /// @author waitwalker
  /// @date 2020-01-13
  ///
  _deleteFile(String filePath) async{
    File file = File(filePath);
    bool exist = await file.exists();
    if (exist) {
      showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Text('确定删除文件？'),
            actions: <Widget>[
              TextButton(
                child: Text('确定'),
                onPressed: () {
                  file.deleteSync();
                  initOfficeData();
                  Navigator.of(context).pop(true);
                  setState(() {

                  });
                },
              ),
              TextButton(
                child: Text('取消'),
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
              ),
            ],
          );
        },
      ).then((del) async {
      });
    } else {
      Fluttertoast.showToast(msg: "文件不存在!",gravity: ToastGravity.CENTER);
    }
  }


  
  @override
  void dispose() {
    super.dispose();
  }


}
