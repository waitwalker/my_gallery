import 'dart:io';
import 'package:my_gallery/common/const/api_const.dart';
import 'package:my_gallery/common/dao/manager/dao_manager.dart';
import 'package:my_gallery/common/network/network_manager.dart';
import 'package:my_gallery/common/network/response.dart';
import 'package:my_gallery/common/singleton/singleton_manager.dart';
import 'package:my_gallery/modules/personal/error_book/unit_test/test_paper_list_model.dart';
import 'package:my_gallery/modules/widgets/webviews/common_webview_page.dart';
import 'package:my_gallery/modules/widgets/loading/list_type_loading_placehold_widget.dart';
import 'package:my_gallery/modules/widgets/style/style.dart';
import 'package:my_gallery/modules/widgets/empty_placeholder/empty_placeholder_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:async/async.dart';


///
/// @name TestPaperListPage
/// @description 错题本错题
/// @author waitwalker
/// @date 2020-01-11
///
class TestPaperListPage extends StatefulWidget {

  final int? subjectId;
  final String? subjectName;
  TestPaperListPage(this.subjectId,{this.subjectName});
  @override
  State<StatefulWidget> createState() {
    return _TestPaperListState();
  }
}

class _TestPaperListState extends State<TestPaperListPage> {
  List <DataSource>?testPaperList;
  AsyncMemoizer _memoizer = AsyncMemoizer();

  ///
  /// @description 刷新数据
  /// @param
  /// @return
  /// @author waitwalker
  /// @time 2020/10/12 4:30 PM
  ///
  Future<Null> _onRefresh() async{
    ResponseData responseData = await DaoManager.fetchErrorBookTestPaperList({"subjectId":widget.subjectId});
    if (responseData != null && responseData.result) {
      if (responseData.code == 200) {

        if (this.mounted && responseData.model != null) {
          var testPaperModel = responseData.model as TestPaperListModel?;
          setState(() {
            if (testPaperList!.length >0) testPaperList!.clear();
            testPaperList = testPaperModel?.data;
            return null;
          });
        } else {
          return null;
        }
      } else {
        return null;
      }
    } else {
      return null;
    }

  }

  @override
  void initState() {
    super.initState();

  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    SingletonManager.sharedInstance!.shouldRefreshUnitTestSubjectList = true;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(MyColors.background),
      child: testPaperList != null ? _buildWidget() : FutureBuilder(builder: _builder, future: _fetchMaterialData(),),
    );
  }

  Widget _builder(BuildContext context, AsyncSnapshot snapshot) {
    switch (snapshot.connectionState) {
      case ConnectionState.none:
        return Text('还没有开始网络请求');
      case ConnectionState.active:
        return Text('ConnectionState.active');
      case ConnectionState.waiting:
        return Scaffold(
          appBar: AppBar(
            title: Text(widget.subjectName!),
            backgroundColor: Colors.white,
          ),
          body: Container(
            child: Center(
              child: LoadingListWidget(),
            ),
          ),
        );
      case ConnectionState.done:
        if (snapshot.hasError) return Text('Error: ${snapshot.error}');

        var testPaperModel = snapshot.data.model as TestPaperListModel?;
        testPaperList = testPaperModel?.data;
        if (testPaperList == null) {
          return _buildNoDataWidget();
        }
        if (testPaperModel!.code == 1 && testPaperList != null) {
          return _buildWidget();
        }
        return EmptyPlaceholderPage(
            assetsPath: 'static/images/empty.png',
            message: '${testPaperModel.msg}');
      default:
        return _buildNoDataWidget();
    }
  }

  Widget _buildWidget() {
    return Scaffold(
      backgroundColor: Color(MyColors.background),
      appBar: AppBar(
        title: Text(widget.subjectName!),
        backgroundColor: Colors.white,
        centerTitle: Platform.isIOS ? true : false,
      ),
      body: Padding(
        padding: EdgeInsets.only(top: 17),
        child: RefreshIndicator(
          child: ListView.builder(itemBuilder: _itemBuilder, itemCount: testPaperList!.length,),
          onRefresh: _onRefresh,),),
    );
  }


  ///
  /// @name _buildNoDataWidget
  /// @description 没有数据占位
  /// @parameters
  /// @return
  /// @author waitwalker
  /// @date 2020-01-13
  ///
  Widget _buildNoDataWidget() {
    return Scaffold(
      backgroundColor: Color(MyColors.background),
      appBar: AppBar(
        title: Text(widget.subjectName!),
        backgroundColor: Colors.white,
        centerTitle: Platform.isIOS ? true : false,
      ),
      body: EmptyPlaceholderPage(
          assetsPath: 'static/images/empty.png', message: '没有数据'),
    );
  }

  Widget _itemBuilder(BuildContext context, int index) {
    DataSource model = testPaperList![index];
    int haveCorrected = model.totalCnt! - model.surplusCnt!;
    bool selected = false;
    if (model.startStatus == 1) {
      selected = true;
    } else {
      selected = false;
    }

    return Padding(padding: EdgeInsets.only(left: 16, right: 16,),
      child: Column(
        children: [
          Container(
              height: Platform.isIOS ? 100 : 100.5,
              width: MediaQuery.of(context).size.width - 32,
              decoration: BoxDecoration(
                color: Color(0xffFFFFFF),
                borderRadius: BorderRadius.circular(7.7),
                boxShadow: [BoxShadow(
                    color: Color(0x3F000000),
                    offset: Offset(0, 2),
                    blurRadius: 2.0,
                    spreadRadius: 1)],
              ),
              child: InkWell(
                child: Padding(padding: EdgeInsets.only(left: 16, right: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(padding: EdgeInsets.only(top: 13)),
                      Text(model.paperName!, style: TextStyle(fontSize: 16, color: Color(0xff3B3838)), maxLines: 1,),
                      Padding(padding: EdgeInsets.only(top: 12)),
                      Container(height: 0.5,color: Color(0xffECECEC),),
                      Padding(padding: EdgeInsets.only(top: 16)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text("错题数量: ${model.totalCnt}",style: TextStyle(fontSize: 15, color: Color(0xff888888)),),
                              Padding(padding: EdgeInsets.only(left: 35)),
                              Text("已消错: $haveCorrected",style: TextStyle(fontSize: 15, color: Color(0xff888888)),),
                            ],
                          ),
                          Container(
                            alignment: Alignment.center,
                            height: 26,
                            width: 95,
                            child: Text(model.totalCnt == (model.totalCnt! - model.surplusCnt!) ? "查看详情" : "开始消错", style: TextStyle(fontSize: 13, color: Color(0xffFFFFFF)),),
                            decoration: BoxDecoration(
                              color: selected ? Color(0xff2E96FF) : Color(0xffC2C9D4),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                onTap: selected ? (){
                  var url = APIConst.errorBookUnitTest;
                  var token = NetworkManager.getAuthorization();
                  String fullURL = '$url?token=$token&subjectid=${widget.subjectId}&taskid=${model.taskId}&paperid=${model.paperId}';
                  Navigator.push(context, MaterialPageRoute(builder: (context){
                    return CommonWebviewPage(initialUrl:fullURL, dataSource: model, pageType: 22,);
                  }));
                } : null,
              ),
          ),
          Padding(padding: EdgeInsets.only(top: 15)),
        ],
      ),
    );
  }

  ///
  /// @name _fetchMaterialData
  /// @description 获取资料包列表
  /// @parameters
  /// @return
  /// @author waitwalker
  /// @date 2020-01-11
  ///
  _fetchMaterialData() {
    return _memoizer.runOnce(()=>DaoManager.fetchErrorBookTestPaperList({"subjectId":widget.subjectId}));
  }

}