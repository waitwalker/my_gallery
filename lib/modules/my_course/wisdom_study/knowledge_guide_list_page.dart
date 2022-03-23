import 'dart:io';
import 'package:my_gallery/common/dao/original_dao/course_dao_manager.dart';
import 'package:my_gallery/common/dao/original_dao/material_dao.dart';
import 'package:my_gallery/common/singleton/singleton_manager.dart';
import 'package:my_gallery/model/document_model.dart';
import 'package:my_gallery/modules/widgets/webviews/common_webview_page.dart';
import 'package:my_gallery/modules/widgets/style/style.dart';
import 'package:my_gallery/modules/widgets/empty_placeholder/empty_placeholder_widget.dart';
import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../widgets/pdf/pdf_page.dart';

///
/// @name KnowledgeGuideListPage
/// @description 知识导学列表页面
/// @author waitwalker
/// @date 2020-01-11
///
class KnowledgeGuideListPage extends StatefulWidget {
  final int? subjectId;
  final int? gradeId;
  final String? title;

  KnowledgeGuideListPage(this.gradeId, this.subjectId, {this.title});

  @override
  _KnowledgeGuideListPageState createState() => _KnowledgeGuideListPageState();
}

class _KnowledgeGuideListPageState extends State<KnowledgeGuideListPage> {
  AsyncMemoizer? _memoizer;
  List<DataEntity>? detailData;

  @override
  void initState() {
    _memoizer = AsyncMemoizer();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _memoizer = null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? '知识导学'),
        elevation: 1,
        backgroundColor: Colors.white,
        centerTitle: Platform.isIOS ? true : false,
      ),
      body: FutureBuilder(builder: _futureBuilder, future: _fetchData()),
    );
  }

  Widget _futureBuilder(BuildContext context, AsyncSnapshot snapshot) {
    switch (snapshot.connectionState) {
      case ConnectionState.done:
        if (snapshot.data == null || snapshot.data.model == null) {
          return EmptyPlaceholderPage();
        }
        var model = snapshot.data.model as DocumentModel;
        detailData = model.data;
        if (detailData == null || detailData!.length == null || detailData!.length == 0) {
          return EmptyPlaceholderPage();
        }
        return _createView();
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
        return Text('unknown error');
    }
  }

  _fetchData() {
    return _memoizer!.runOnce(() => MaterialDao.getMaterialDocuments(
        gradeId: widget.gradeId.toString(),
        subjectId: widget.subjectId.toString()));
  }

  Widget _createView() {
    return ListView.builder(
      itemBuilder: _itemBuilder,
      itemCount: detailData!.length,
    );
  }

  Widget _itemBuilder(BuildContext context, int index) {
    var item = detailData!.elementAt(index);
    return ListTile(
      leading: Icon(MyIcons.DOCUMENT),
      title: Text(item.resName!),
      trailing: Icon(
        MyIcons.ARROW_R,
        size: 15,
      ),
      onTap: () async {
        var resourceInfo = await CourseDaoManager.getResourceInfo(item.resId);

        if (resourceInfo.result &&
            resourceInfo.model != null &&
            resourceInfo.model.code == 1) {
          // 文档
          var model = resourceInfo.model;
          if (model.data.literatureDownUrl.endsWith('.pdf') && !SingletonManager.sharedInstance!.isGuanKong!) {
            Navigator.of(context).push(MaterialPageRoute(builder: (_) {
              return PDFPage(model.data.literatureDownUrl,
                  title: model.data.resourceName,
                  fromZSDX: true,
                  officeURL: model.data.literaturePreviewUrl,
                  resId: model.data.resouceId.toString());
            }));
          } else {
            Navigator.of(context).push(MaterialPageRoute(builder: (_) {
              return CommonWebviewPage(
                initialUrl: resourceInfo.model.data.literaturePreviewUrl,
                downloadUrl: resourceInfo.model.data.literatureDownUrl,
                title: item.resName,
                pageType: 3,);
            }));
          }
        } else {
          Fluttertoast.showToast(msg: resourceInfo.model?.msg ?? '获取资源失败');
        }
      },
    );
  }
}
