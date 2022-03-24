import 'dart:async';
import 'dart:io';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:my_gallery/common/dao/original_dao/course_dao_manager.dart';
import 'package:my_gallery/common/locale/localizations.dart';
import 'package:my_gallery/common/redux/app_state.dart';
import 'package:my_gallery/common/singleton/singleton_manager.dart';
import 'package:my_gallery/common/tools/image_compress/image_compress.dart';
import 'package:my_gallery/common/tools/date/timer_tool.dart';
import 'package:my_gallery/model/error_book_model.dart';
import 'package:my_gallery/common/const/api_const.dart';
import 'package:my_gallery/common/network/network_manager.dart';
import 'package:my_gallery/modules/personal/error_book/unit_test/testpaper_list_page.dart';
import 'package:my_gallery/modules/personal/error_book/upload_error/errorbook_item_list_page.dart';
import 'package:my_gallery/modules/widgets/webviews/common_webview_page.dart';
import 'package:my_gallery/modules/widgets/loading/loading_dialog.dart';
import 'package:my_gallery/modules/widgets/style/style.dart';
import 'package:my_gallery/modules/widgets/empty_placeholder/empty_placeholder_widget.dart';
import 'package:my_gallery/modules/widgets/row/setting_row.dart';
import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../widgets/loading/list_type_loading_placehold_widget.dart';
import 'upload_error/edit_error_item_page.dart';
import 'package:redux/redux.dart';


///
/// @name ErrorBookSubjectListPage
/// @description 错题本学科列表页面
/// @author waitwalker
/// @date 2020-01-11
///
// ignore: must_be_immutable
class ErrorBookSubjectListPage extends StatefulWidget {
  /// 显示拍照上传按钮
  bool showCamera;
  bool fromShuXiao;
  bool fromUnitTest;
  String? title;
  ErrorBookSubjectListPage({this.showCamera = false, this.fromShuXiao = false, this.fromUnitTest = false, this.title = "错题本"});

  @override
  State<StatefulWidget> createState() {
    return _ErrorBookSubjectListPageState();
  }
}

class _ErrorBookSubjectListPageState extends State<ErrorBookSubjectListPage> with WidgetsBindingObserver {
  AsyncMemoizer _memoizer = AsyncMemoizer();
  File? croppedFile;
  TimerTool? _timerTool;
  bool haveCameraPermission = true;

  @override
  void initState() {
    WidgetsBinding.instance!.addObserver(this);
    _startCountDown();
    /// 错题本学科列表请求权限处理,只有上传错题的会请求
    if (widget.showCamera) {
      requestCameraPermission();
    }
    super.initState();
  }

  requestCameraPermission() async{
    /// 申请结果
    PermissionStatus permission = await Permission.camera.status;

    if (permission == PermissionStatus.granted) {
      haveCameraPermission = true;
    } else {
      haveCameraPermission = false;
    }
  }

  ///
  /// @name 倒计时
  /// @description
  /// @parameters
  /// @return
  /// @author waitwalker
  /// @date 2020-01-15
  ///
  void _startCountDown() {
    _timerTool = TimerTool(mTotalTime: 24 * 60 * 60 * 1000);
    _timerTool!.setOnTimerTickCallback((int? tick) {

      if (SingletonManager.sharedInstance!.errorBookCameraState == 1){
        setState(() {
          SingletonManager.sharedInstance!.errorBookCameraState = 0;
          _memoizer = AsyncMemoizer();
        });
      } else if (SingletonManager.sharedInstance!.errorBookCameraState == 2) {
        setState(() {
          SingletonManager.sharedInstance!.errorBookCameraState = 0;
          _memoizer = AsyncMemoizer();
        });
        takePhoto();
      } else if (SingletonManager.sharedInstance!.shouldRefreshUnitTestSubjectList == true) {
        setState(() {
          SingletonManager.sharedInstance!.shouldRefreshUnitTestSubjectList = false;
          _memoizer = AsyncMemoizer();
        });
      }

    });
    _timerTool!.startCountDown();
  }

  takePhoto() async {
    final picker = ImagePicker();
    var image = await (picker.getImage(source: ImageSource.camera) as FutureOr<PickedFile>);
    doCrop(image.path).then((f) {
      if (f == null) return;
      Navigator.push(context, MaterialPageRoute(builder: (context){
        return EditErrorItemPage(image: croppedFile);
      })).then((value) => (){
        print("$value");
      });
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    if (_timerTool != null) _timerTool!.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused) {
      // went to Background
      print("回到后台");
    }
    if (state == AppLifecycleState.resumed) {
      // came back to Foreground
      print("回到前台");
    }
  }

  @override
  Widget build(BuildContext context) {
    return StoreBuilder(builder: (BuildContext context, Store<AppState> store){
      return Scaffold(
          appBar: AppBar(
            title: Text(widget.title!),
            elevation: 1.0,
            backgroundColor: Colors.white,
            centerTitle: Platform.isIOS ? true : false,
          ),
          body: Stack(alignment: Alignment.center, children: <Widget>[
            FutureBuilder(
              future: _getSubjectList(),
              builder: _builder,
            ),
            if (widget.showCamera)
              Positioned.directional(
                bottom: 20,
                textDirection: TextDirection.ltr,
                child: InkWell(
                    child: _buildCamera(),
                    onTap: () {
                      requestPermission();
                    }),
              ),

            if (widget.fromUnitTest)
              Positioned.directional(
                bottom: 20,
                textDirection: TextDirection.ltr,
                child: Container(height: 30, child: Text("如果未参加考试，相关试题不汇总到错题本", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),),),
              ),
          ]));
    });

  }

  Future requestPermission() async {
    if (haveCameraPermission) {
      SingletonManager.sharedInstance!.errorBookCameraState = 0;
      print("权限申请通过");
      final picker = ImagePicker();
      var image = await (picker.getImage(source: ImageSource.camera) as FutureOr<PickedFile>);
      int originalLength = await File(image.path).length();
      print("未压缩之前图片大小:${originalLength / 1024.0 / 1024.0}MB");

      showLoadingDialog(context,message: "处理中...");

      /// 自己封装的压缩图片算法
     // File compressedFile = await ImageCompressManager.compressImage(File(image.path));
     // int scaleImageSize = await compressedFile.length();
     // print("压缩图片的原生尺寸:${scaleImageSize / 1024.0 / 1024.0}MB");
     // if (compressedFile == null) {
     //   Navigator.pop(context);
     // }

      /// 纯粹压缩图片质量
      File compressedFile = await ImageCompressManager.compressImageQuality(File(image.path));
      int scaleImageSize = await compressedFile.length();
      print("压缩之后图片大小:${scaleImageSize / 1024.0 / 1024.0}MB");

      doCrop(compressedFile.path).then((f) {
        Navigator.pop(context);
        if (f == null) return;
        Navigator.push(context, MaterialPageRoute(builder: (context){
          return EditErrorItemPage(image: croppedFile);
        })).then((value) => (){
          print("$value");
        });
      });
    } else {
      print("权限申请被拒绝");
      Fluttertoast.showToast(msg: "请允许拍照权限后再重试");
    }
  }

  ///
  /// @description 裁剪图片
  /// @param
  /// @return
  /// @author waitwalker
  /// @time 3/26/21 9:52 AM
  ///
  doCrop(String image) async {
    croppedFile = await ImageCropper().cropImage(
        sourcePath: image,
        aspectRatioPresets: [
          CropAspectRatioPreset.square,
          CropAspectRatioPreset.ratio3x2,
          CropAspectRatioPreset.original,
          CropAspectRatioPreset.ratio4x3,
          CropAspectRatioPreset.ratio16x9
        ],
        androidUiSettings: AndroidUiSettings(
            toolbarTitle: '剪切图片',
            toolbarColor: Colors.blue,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        iosUiSettings: IOSUiSettings(
          minimumAspectRatio: 1.0,
        ));
    return croppedFile;
  }


  Column _buildCamera() {
    return Column(children: <Widget>[
      Container(
          height: 56,
          width: 56,
          decoration: new BoxDecoration(
            color: Color(0xFF6B8DFF),
            //用一个BoxDecoration装饰器提供背景图片
            borderRadius: BorderRadius.all(Radius.circular(28.0)),
            boxShadow: [
              BoxShadow(
                  color: Color(0x66A1A1A1),
                  offset: Offset(0, -2),
                  blurRadius: 4.0,
                  spreadRadius: 0.0)
            ],
          ),
          child: Icon(MyIcons.CAMERA, color: Colors.white)),
      const SizedBox(height: 8),
      Text(MTTLocalization.of(context)!.currentLocalized!.errorBookPageTakePhoto!, style: TextStyle(fontSize: 10, color: Color(MyColors.black333))),
    ]);
  }

  _getSubjectList() =>
      _memoizer.runOnce(() => CourseDaoManager.fetchErrorBookSubjectList(
          widget.showCamera ? ErrorBookType.CAMERA :
          widget.fromShuXiao ? ErrorBookType.SHUXIAO :
          widget.fromUnitTest ? ErrorBookType.UNITTEST
              : ErrorBookType.WEB));

  Widget _builder(BuildContext context, AsyncSnapshot snapshot) {
    switch (snapshot.connectionState) {
      case ConnectionState.none:
        return Text('还没有开始网络请求');
      case ConnectionState.active:
        return Text('ConnectionState.active');
      case ConnectionState.waiting:
        return Center(child: LoadingListWidget(),);
      case ConnectionState.done:
        if (snapshot.hasError) return Text('Error: ${snapshot.error}');
        var model = snapshot.data.model as ErrorBookModel?;
        if (model?.data == null) {
          return EmptyPlaceholderPage(assetsPath: 'static/images/empty.png', message: MTTLocalization.of(context)!.currentLocalized!.commonNoData);
        }
        if (model!.code == 1 && model.data != null) {
          if (model.data!.length ==0) return EmptyPlaceholderPage(assetsPath: 'static/images/empty.png', message: MTTLocalization.of(context)!.currentLocalized!.commonNoData);
          return _buildList(model.data!);
        }
        return Expanded(child: Text('什么也没有呢'));
      default:
        return EmptyPlaceholderPage(assetsPath: 'static/images/empty.png', message: MTTLocalization.of(context)!.currentLocalized!.commonNoData);
    }
  }

  ///
  /// @name _onPressSubject
  /// @description 跳转到原生错题本详情
  /// @parameters
  /// @return
  /// @author lca
  /// @date 2019-12-20
  ///
  _onPressSubject(int? subjectId, String? subjectName) {
    print('PRESSED $subjectId');
    if (widget.showCamera) {
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => ErrorBookItemListPage(subjectId: subjectId)))
          .then((_) {
        setState(() {
          _memoizer = AsyncMemoizer();
        });
      });
    } else {
      if (widget.fromUnitTest) {
        Navigator.of(context).push(MaterialPageRoute(builder: (_) {
          return TestPaperListPage(subjectId, subjectName: subjectName);
        }));
      } else {
        /// 跳转到网页错题本详情 数校和网校
        Navigator.of(context).push(MaterialPageRoute(builder: (_) {
          var url = widget.fromShuXiao
              ? APIConst.errorBookShuXiao
              : APIConst.errorBook;
          var token = NetworkManager.getAuthorization();
          return CommonWebviewPage(
            initialUrl: '$url?token=$token&subjectid=$subjectId',
            subjectId: subjectId,
            fromShuXiao: widget.fromShuXiao,
            pageType: 1,
          );
        }));
      }

    }
  }

  _buildCount(int? cnt) {
    return Container(
        child: Text('$cnt', style: textStyleHint),
        padding: EdgeInsets.only(right: 10));
  }

  _buildList(List<DataEntity> data) {
    return Column(
      children: <Widget>[
        ...data.map(_buildItem).expand((l) => l),
      ],
    );
  }

  List<Widget> _buildItem(DataEntity l) {
    return [
      Divider(height: 0.5, color: Colors.black12),
      SettingRow(
        l.subjectName,
        textStyle: TextStyle(fontSize: SingletonManager.sharedInstance!.screenWidth > 500.0 ? 18 : 16, color: Color(MyColors.black333)),
        icon: _subjectIdIconMapping(l.subjectId as int?),
        rightCustomWidget: _buildCount(l.cnt as int?),
        onPress: () => _onPressSubject(l.subjectId as int?, l.subjectName),
      ),
    ];
  }

  _subjectIdIconMapping(int? sid) {
    switch (sid) {
      case 1:
        return MyIcons.SUBJECT_YuWen;
      case 2:
        return MyIcons.SUBJECT_ShuXue;
      case 3:
        return MyIcons.SUBJECT_YingYu;
      case 4:
        return MyIcons.SUBJECT_WuLi;
      case 5:
        return MyIcons.SUBJECT_HuaXue;
      case 6:
        return MyIcons.SUBJECT_ShengWu;
      case 7:
        return MyIcons.SUBJECT_ZhengZhi;
      case 8:
        return MyIcons.SUBJECT_LiShi;
      case 9:
        return MyIcons.SUBJECT_DiLi;
      case 10:
        return Icons.equalizer;
      default:
        return Icons.error;
    }
  }
}
