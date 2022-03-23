import 'dart:convert';
import 'dart:io';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:my_gallery/common/locale/localizations.dart';
import 'package:redux/redux.dart';
import 'package:my_gallery/common/dao/original_dao/course_dao_manager.dart';
import 'package:my_gallery/common/dao/manager/dao_manager.dart';
import 'package:my_gallery/common/redux/app_state.dart';
import 'package:my_gallery/common/singleton/singleton_manager.dart';
import 'package:my_gallery/model/login_model.dart';
import 'package:my_gallery/model/errorbook_list_model.dart';
import 'package:my_gallery/model/ett_pdf_model.dart';
import 'package:my_gallery/common/const/api_const.dart';
import 'package:my_gallery/common/network/response.dart';
import 'package:my_gallery/modules/widgets/loading/loading_view.dart';
import 'package:my_gallery/modules/widgets/pdf/pdf_page.dart';
import 'package:my_gallery/modules/widgets/style/style.dart';
import 'package:my_gallery/modules/widgets/empty_placeholder/empty_placeholder_widget.dart';
import 'package:my_gallery/common/tools/get_grade/grade_utils.dart';
import 'package:my_gallery/common/logger/logger.dart';
import 'package:my_gallery/common/tools/share_preference/share_preference.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:my_gallery/modules/widgets/loading/list_type_loading_placehold_widget.dart';
import 'package:async/async.dart';
import 'errorbook_detail_page.dart';


///
/// @name ErrorBookDetailPage
/// @description 上传错题错题本卡片列表页
/// @author waitwalker
/// @date 2020-01-11
///
// ignore: must_be_immutable
class ErrorBookItemListPage extends StatefulWidget {
  var subjectId;

  ErrorBookItemListPage({Key? key, this.subjectId}) : super(key: key);

  _ErrorBookItemListPageState createState() => _ErrorBookItemListPageState();
}

class _ErrorBookItemListPageState extends State<ErrorBookItemListPage> {
  AsyncMemoizer _memoizer = AsyncMemoizer();
  ScrollController? _scrollController;
  bool selectMode = false;

  DataEntity? detailData;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController!.addListener(() {
      debugLog(_scrollController!.position.extentAfter);
    });
  }

  _toggle() {
    setState(() {
      selectMode = !selectMode;
    });
  }



  @override
  Widget build(BuildContext context) {
    return StoreBuilder(builder: (BuildContext context, Store<AppState> store){
      Map subjects = {
        1: MTTLocalization.of(context)!.currentLocalized!.commonChinese,
        2: MTTLocalization.of(context)!.currentLocalized!.commonMathematics,
        3: MTTLocalization.of(context)!.currentLocalized!.commonEnglish,
        4: MTTLocalization.of(context)!.currentLocalized!.commonPhysical,
        5: MTTLocalization.of(context)!.currentLocalized!.commonChemistry,
        6: MTTLocalization.of(context)!.currentLocalized!.commonHistory,
        7: MTTLocalization.of(context)!.currentLocalized!.commonBiology,
        8: MTTLocalization.of(context)!.currentLocalized!.commonGeography,
        9: MTTLocalization.of(context)!.currentLocalized!.commonPolitics,
        10: '科学',
      };
      String? title = subjects[widget.subjectId];
      return Scaffold(
        appBar: AppBar(
            title: Text(title ?? "错题本"),
            backgroundColor: Colors.white,
            centerTitle: Platform.isIOS ? true : false,
            elevation: 1,
            actions: <Widget>[
              TextButton(
                child: Text(selectMode ? MTTLocalization.of(context)!.currentLocalized!.errorBookPageCancel! : MTTLocalization.of(context)!.currentLocalized!.errorBookPageChoose!),
                onPressed: () {
                  _toggle();
                },
              ),
            ]),
        backgroundColor: Color(MyColors.background),
        body: Stack(children: <Widget>[
          Container(
              padding: EdgeInsets.symmetric(vertical: 16, horizontal: 14),
              child: _buildBody()),
          if (selectMode)
            Positioned.directional(
              bottom: 0,
              end: 0,
              start: 0,
              textDirection: TextDirection.ltr,
              child: Container(
                // width: double.infinity,
                  height: 60,
                  color: Colors.white,
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        InkWell(
                          child: Container(
                            height: 39,
                            width: 85,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              // color: Color(0xFF6B8DFF),
                              borderRadius: BorderRadius.all(
                                Radius.circular(4),
                              ),
                              border: Border.all(
                                color: Color(0xFFFF665F),
                              ),
                            ),
                            child: Text('删除', style: TextStyle(fontSize: 12, color: Color(0xFFFF665F))),
                          ),
                          onTap: _onDeleteTask,
                        ),
                        const SizedBox(width: 12),
                        InkWell(
                            child: Container(
                              height: 39,
                              width: 165,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(color: Color(0xFF6B8DFF), borderRadius: BorderRadius.all(Radius.circular(4),),),
                              child: Text('已选 ${_selectedCount()} 题，生成试卷', style: textStyle12WhiteBold),
                            ),
                            onTap: _submitAndGetPdf),
                        const SizedBox(width: 12),
                      ])),
            ),
        ]),
      );
    });
  }

  _buildBody() {
    return FutureBuilder(builder: _builder, future: _getDetail(),);
  }

  _getDetail() => _memoizer.runOnce(() => CourseDaoManager.errorbookList(currentPage: 1, pageSize: 1000, subjectId: widget.subjectId));

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

        var errorBookModel = snapshot.data.model as ErrorbookListModel?;
        detailData = errorBookModel?.data;
        if (detailData == null) {
          return EmptyPlaceholderPage(assetsPath: 'static/images/empty.png', message: '没有数据');
        }
        if (errorBookModel!.code == 1 && detailData != null) {
          return _buildList();
        }
        return EmptyPlaceholderPage(assetsPath: 'static/images/empty.png', message: '${errorBookModel.msg}');
      default:
        return EmptyPlaceholderPage(assetsPath: 'static/images/empty.png', message: '没有数据');
    }
  }

  Widget _buildList() {
    double imageHeight = 120.0;
    if (SingletonManager.sharedInstance!.screenHeight > 1000) {
      imageHeight = 350;
    }
    return GridView.builder(
      controller: _scrollController,
      itemCount: detailData!.list!.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 8 / 9.0),
      itemBuilder: (BuildContext context, int index) {
        ListEntity item = detailData!.list![index];
        print("原图：${item.photoUrl}");
        print("缩略图：${item.smallPhotoUrl}");
        String imageURL = (item.smallPhotoUrl != null && item.smallPhotoUrl!.isNotEmpty) ? item.smallPhotoUrl! : item.photoUrl!;
        return InkWell(
            child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4.0),
                ),
                child: Stack(children: <Widget>[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        // width: 160,
                        height: imageHeight,
                        decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(4.0)),
                          image: DecorationImage(
                            image: NetworkImage(imageURL),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(10.0, 10, 10, 0),
                        child: Text(item.uploadTime!, style: textStyle11999),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(10.0, 5, 10, 0),
                        child: Text(item.wrongReason!,
                            style: textStyle13TitleBlackMid),
                      ),
                    ],
                  ),
                  Positioned(
                    left: 10,
                    top: 10,
                    child: Container(
                        alignment: Alignment.topCenter,
                        child: Text(
                            gradeSample.entries
                                .where((kv) => kv.key == item.gradeId)
                                .single
                                .value,
                            style: textStyle10White),
                        height: 16,
                        width: 32,
                        decoration: _boxDecoration()),
                  ),
                  if (selectMode)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: InkWell(
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: ClipOval(
                              child: Container(
                                  width: 18.5,
                                  height: 18.5,
                                  alignment: Alignment.center,
                                  color: item.selected
                                      ? Color(0xFF6B8DFF)
                                      : Color(0XFFD8D8D8),
                                  child: Icon(MyIcons.RIGHT,
                                      color: Colors.white, size: 9))),
                        ),
                        onTap: () => _onSelectTask(item),
                      ),
                    ),
                ])),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (_) {
                return ErrorBookDetailPage(reasonId: item.wrongPhotoId);
              }));
            });
      },
    );
  }

  _onDeleteTask() {
    var countToDel = _selectedCount();
    if (countToDel == 0) {
      Fluttertoast.showToast(msg: '请先选择错题');
      return;
    }
    showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Text('确定删除错题？'),
          actions: <Widget>[
            TextButton(
              child: Text('确定'),
              onPressed: () {
                Navigator.of(context).pop(true);
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
    ).then((agree) async {
      if (agree!) {
        var listToDel = detailData!.list!.where((i) => i.selected).toList();
        var ids = listToDel.map((i) => i.wrongPhotoId).join(',');
        CourseDaoManager.delErrorBook(wrongPhotoIds: ids).then((response) {
          if (response.result) {
            detailData!.list!.removeWhere((i) => i.selected);
            setState(() {});
          } else {
            Fluttertoast.showToast(msg: '删除失败');
          }
        });
      }
    });
  }

  BoxDecoration _boxDecoration() {
    return BoxDecoration(
      color: Color(0xFF6B8DFF),
      borderRadius: BorderRadius.all(
        Radius.circular(2),
      ),
    );
  }

  _onSelectTask(ListEntity item) {
    setState(() {
      item.selected = !item.selected;
    });
  }

  _selectedCount() {
    return detailData?.list?.where((i) => i.selected)?.toList()?.length ?? 0;
  }

  void _submitAndGetPdf() async {
    var countToDel = _selectedCount();
    if (countToDel == 0) {
      Fluttertoast.showToast(msg: '请先选择错题');
      return;
    }

    if (countToDel > 10) {
      Fluttertoast.showToast(msg: '拍照错题一次最多选10题，你选的太多啦。');
      return;
    }


    var listToDel = detailData!.list!.where((i) => i.selected).toList();
    var ids = listToDel.map((i) => i.wrongPhotoId).join(',');

    /// 显示加载圈
    _showLoading();

    // 查询token
    String authorizationCode = await getAuthorization();
    ResponseData responseData = await DaoManager.fetchPDFURL({
      "questionIds":ids,
      "questionType":3,
      "subjectId":widget.subjectId,
      "accessToken":authorizationCode
    });

    print("data:$responseData");

    /// 移除加载圈
    _hideLoading();

    if (responseData != null && responseData.model != null) {
      ETTPDFModel pdfModel = responseData.model;
      if (pdfModel.type == "success" && pdfModel.msg == "成功") {
        print("url: ${pdfModel.data!.previewUrl}");
        Navigator.of(context).push(MaterialPageRoute(builder: (context){
          return PDFPage(pdfModel.data!.previewUrl,title: pdfModel.data!.presentationName);
        })).then((value){
          setState(() {
            selectMode = false;
          });
        });
      } else {
        Fluttertoast.showToast(msg: '您的作业被小怪兽吃了，再生成一次吧。',gravity: ToastGravity.CENTER);
      }
    } else {
      Fluttertoast.showToast(msg: '您的作业被小怪兽吃了，再生成一次吧。',gravity: ToastGravity.CENTER);
    }
  }

  ///获取授权token
  static getAuthorization() {
    var json = SharedPrefsUtils.getString(APIConst.LOGIN_JSON, '{}')!;
    var ccLoginModel = LoginModel.fromJson(jsonDecode(json));
    String? token = ccLoginModel.access_token;
    if (token == null) {
      String basic = APIConst.basicToken;
      if (basic == null) {
        //提示输入账号密码
      } else {
        //通过 basic 去获取token，获取到设置，返回token
        return "Basic $basic";
      }
    } else {
      return token;
    }
  }

  ///
  /// @name _showLoading 显示加载圈
  /// @description
  /// @parameters
  /// @return
  /// @author waitwalker
  /// @date 2019-12-31
  ///
  _showLoading() {
    /// 1.上传所选的题目id
    /// 2.获取组装完的pdf文档
    /// 3.刷一下当前页面状态
    showDialog(context: context,
      barrierDismissible: false,
      builder: (context) {
        return LoadingView();
      },
    );
  }

  ///
  /// @name _hideLoading
  /// @description 隐藏加载圈
  /// @parameters
  /// @return
  /// @author waitwalker
  /// @date 2019-12-31
  ///
  _hideLoading() {
    Navigator.pop(context);
  }

}
