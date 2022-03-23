import 'dart:io';
import 'package:my_gallery/common/dao/manager/dao_manager.dart';
import 'package:my_gallery/common/const/api_const.dart';
import 'package:my_gallery/common/network/network_manager.dart';
import 'package:my_gallery/modules/my_course/intelligence_question_database/real_question_answer_record_model.dart';
import 'package:my_gallery/modules/widgets/webviews/common_webview_page.dart';
import 'package:my_gallery/modules/widgets/style/style.dart';
import 'package:my_gallery/modules/widgets/empty_placeholder/empty_placeholder_widget.dart';
import 'package:async/async.dart';
import 'package:flutter/material.dart';


///
/// @name RealQuestionAnswerRecordPage
/// @description 历年真题练习记录页面
/// @author waitwalker
/// @date 2020-01-11
///
class RealQuestionAnswerRecordPage extends StatefulWidget {

  /// 学科id
  final num? subjectId;
  /// 课id
  final num? courseId;
  /// 试卷名称
  final String? paperName;
  /// 试卷id
  final num? realPaperId;
  RealQuestionAnswerRecordPage({this.realPaperId, this.paperName, this.subjectId, this.courseId});
  @override
  _RealQuestionAnswerRecordPageState createState() => _RealQuestionAnswerRecordPageState();
}

class _RealQuestionAnswerRecordPageState extends State<RealQuestionAnswerRecordPage> {
  late AsyncMemoizer _memoizer;

  List<Data>? dataSource = [];
  @override
  void initState() {
    _memoizer = AsyncMemoizer();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('练习记录'),
        elevation: 1.0,
        backgroundColor: Colors.white,
        centerTitle: Platform.isIOS ? true : false,
      ),
      body: FutureBuilder(builder: _futureBuilder, future: _fetchData()),
    );
  }

  ///
  /// @description 构建请求状态Widget
  /// @param
  /// @return
  /// @author waitwalker
  /// @time 4/8/21 8:56 AM
  ///
  Widget _futureBuilder(BuildContext context, AsyncSnapshot snapshot) {
    switch (snapshot.connectionState) {
      case ConnectionState.done:
        if (snapshot.hasError) {
          return EmptyPlaceholderPage();
        }
        if (!snapshot.data.result) {
          return EmptyPlaceholderPage();
        }
        var model = snapshot.data.model as RealQuestionAnswerRecordModel;
        dataSource = model.data;
        if (dataSource!.length == 0 || dataSource == null) {
          return EmptyPlaceholderPage();
        }
        return _builderBody();
        break;
      case ConnectionState.none:
        return Text('还没有开始网络请求');
      case ConnectionState.active:
        return Text('ConnectionState.active');
      case ConnectionState.waiting:
        return Center(
          child: CircularProgressIndicator(),
        );
      default:
        return EmptyPlaceholderPage();
    }
  }

  ///
  /// @description 获取作答记录数据
  /// @param
  /// @return
  /// @author waitwalker
  /// @time 4/8/21 8:55 AM
  ///
  _fetchData() {
    return _memoizer.runOnce(() => DaoManager.fetchRealQuestionRecordData(widget.realPaperId));
  }

  ///
  /// @description 构建主体
  /// @param
  /// @return
  /// @author waitwalker
  /// @time 4/7/21 4:14 PM
  ///
  Widget _builderBody() {
    return ListView.builder(
      itemBuilder: _itemBuilder,
      itemCount: dataSource!.length,
    );
  }

  ///
  /// @description 构建单个卡片
  /// @param
  /// @return
  /// @author waitwalker
  /// @time 4/8/21 8:56 AM
  ///
  Widget _itemBuilder(BuildContext context, int index) {
    Data item = dataSource![index];
    return Column(children: <Widget>[
      Divider(
        height: 1,
      ),
      ListTile(
        leading: Icon(
          MyIcons.ANSWER_CARD,
          size: 20.0,
        ),
        title: Text(item.paperName!, style: textStyleContent333),
        trailing: Icon(
          MyIcons.ARROW_R,
          size: 16.0,
        ),
        onTap: () async {
          Navigator.of(context).push(MaterialPageRoute(builder: (_) {
            var url = APIConst.realQuestionReport;
            var token = NetworkManager.getAuthorization();
            String fullURL = '$url?token=$token&realpaperid=${widget.realPaperId}&creatpaperid=${item.paperId}&papername=${item.paperName}';
            fullURL = fullURL.replaceAll(" ", "");
            return CommonWebviewPage(
              paperName: widget.paperName,
              realPaperId: widget.realPaperId,
              subjectId: widget.subjectId as int?,
              title: widget.paperName,
              initialUrl: fullURL,
              pageType: 43,
            );
          })).then((v) {
            _memoizer = AsyncMemoizer();
            if (this.mounted) {
              setState(() {});
            }
          });
        },
      ),
    ]);
  }
}
