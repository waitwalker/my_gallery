import 'dart:io';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:my_gallery/common/const/api_const.dart';
import 'package:my_gallery/common/dao/manager/dao_manager.dart';
import 'package:my_gallery/common/network/network_manager.dart';
import 'package:my_gallery/common/network/response.dart';
import 'package:my_gallery/modules/personal/unit_test/unit_test_model.dart';
import 'package:my_gallery/modules/widgets/webviews/common_webview_page.dart';
import 'package:my_gallery/modules/widgets/style/style.dart';
import 'package:my_gallery/modules/widgets/empty_placeholder/empty_placeholder_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:my_gallery/common/tools/get_grade/grade_utils.dart';


///
/// @name UnitTestListPage
/// @description 质检消错列表
/// @author waitwalker
/// @date 2020-01-11
///
class UnitTestListPage extends StatefulWidget {

  UnitTestListPage();
  @override
  State<StatefulWidget> createState() {
    return _UnitTestListState();
  }
}

class _UnitTestListState extends State<UnitTestListPage> {
  List <PaperList>? testPaperList;
  UnitTestModel? unitTestModel;
  bool isLoading  = true;
  int currentPage = 1;
  int pageSize = 8;
  bool haveMoreData = true;
  ScrollController? _controller;

  @override
  void initState() {
    haveMoreData = true;
    _controller = ScrollController();
    _fetchData();
    super.initState();
  }

  // @override
  // Widget build(BuildContext context) {
  //   return Container(
  //     color: Color(MyColors.background),
  //     child: testPaperList != null ? _buildWidget() : FutureBuilder(builder: _builder, future: _fetchMaterialData(),),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("质检消错"),
        backgroundColor: Colors.white,
      ),
      body: isLoading ? Center(child: CircularProgressIndicator(),) : Container(
        color: Color(MyColors.background),
        child: (testPaperList != null && testPaperList!.length != 0) ? Padding(padding: EdgeInsets.only(top: 15), child: EasyRefresh(
          child: ListView.builder(itemBuilder: _itemBuilder, itemCount: testPaperList!.length, controller: _controller,),
          firstRefresh: true,
          onRefresh: _onRefresh,
          header: ClassicalHeader(
              refreshText: "下拉刷新",
              refreshingText: "正在刷新...",
              refreshedText: "刷新完成",
              refreshFailedText: "刷新失败",
              refreshReadyText: "松手刷新",
              noMoreText: "没有更多",
              infoText: "加载时间${DateTime.now().hour}:${DateTime.now().minute > 9 ? DateTime.now().minute :"0" + "${DateTime.now().minute}" }"
          ),
          footer: ClassicalFooter(
              loadedText: "加载完成",
              noMoreText: "没有更多数据",
              loadingText: "正在加载...",
              loadReadyText: "上拉加载",
              loadFailedText: "加载失败",
              loadText: "上拉加载更多",
              infoText: "加载时间${DateTime.now().hour}:${DateTime.now().minute > 9 ? DateTime.now().minute :"0" + "${DateTime.now().minute}" }"
          ),
          onLoad: haveMoreData ? _onLoadMore : null,
        ),) : EmptyPlaceholderPage(
            assetsPath: 'static/images/empty.png', message: '没有数据'),
      ),
    );
  }

  ///
  /// @description 首次加载数据
  /// @param
  /// @return
  /// @author waitwalker
  /// @time 2020/10/29 10:49 AM
  ///
  void _fetchData() async {
    haveMoreData = true;
    ResponseData responseData = await DaoManager.fetchUnitTestPaperList({"pageSize": pageSize, "currentPage": currentPage});
    isLoading = false;
    if (responseData != null && responseData.result) {
      if (responseData.code == 200) {
        if (responseData.model != null) {
          var testPaperModel = responseData.model as UnitTestModel?;
          if (testPaperList != null && testPaperList!.length >0) testPaperList!.clear();
          testPaperList = testPaperModel?.dataSource?.paperList;
        } else {
          testPaperList = null;
        }
      } else {
        testPaperList = null;
      }
    } else {
      testPaperList = null;
    }
    setState(() {

    });
  }


  ///
  /// @description 刷新数据
  /// @param
  /// @return
  /// @author waitwalker
  /// @time 2020/10/12 4:30 PM
  ///
  Future<Null> _onRefresh() async{
    haveMoreData = true;
    // 重置当前页
    currentPage = 1;
    ResponseData responseData = await DaoManager.fetchUnitTestPaperList({"pageSize": pageSize, "currentPage": currentPage});
    if (responseData != null && responseData.result) {
      if (responseData.code == 200) {
        if (responseData.model != null) {
          var testPaperModel = responseData.model as UnitTestModel?;
          unitTestModel = testPaperModel;
          setState(() {
            if (testPaperList!.length >0) testPaperList!.clear();
            testPaperList = testPaperModel?.dataSource?.paperList;
            return null;
          });
        } else {
          setState(() {
            testPaperList = null;
            return null;
          });
        }
      } else {
        setState(() {
          testPaperList = null;
          return null;
        });
      }
    } else {
      setState(() {
        testPaperList = null;
        return null;
      });
    }
  }

  ///
  /// @description 刷新数据
  /// @param
  /// @return
  /// @author waitwalker
  /// @time 2020/10/12 4:30 PM
  ///
  Future<Null> _onLoadMore() async{
    if (currentPage < unitTestModel!.dataSource!.totalPage!) {
      currentPage++;
      ResponseData responseData = await DaoManager.fetchUnitTestPaperList({"pageSize": pageSize, "currentPage": currentPage});
      if (responseData != null && responseData.result) {
        if (responseData.code == 200) {
          if (responseData.model != null) {
            var testPaperModel = responseData.model as UnitTestModel?;
            setState(() {
              if (testPaperModel!.dataSource!.paperList!.isNotEmpty) {
                testPaperList!.addAll(testPaperModel!.dataSource!.paperList!);
              }
              return null;
            });
          } else {
            setState(() {
              return null;
            });
          }
        } else {
          setState(() {
            return null;
          });
        }
      } else {
        setState(() {
          return null;
        });
      }
    } else {
      setState(() {
        haveMoreData = false;
        return null;
      });
      Fluttertoast.showToast(msg: "没有更多数据了~", gravity: ToastGravity.CENTER);
    }
  }

  Widget _itemBuilder(BuildContext context, int index) {
    PaperList model = testPaperList![index];
    return Padding(padding: EdgeInsets.only(left: 16, right: 16,),
      child: InkWell(
        child: Column(
          children: [
            Container(
              height: Platform.isIOS ? (model.taskStatus == 3 ? 190 : 135) : (model.taskStatus == 3 ? 190 : 140),
              width: MediaQuery.of(context).size.width - 32,
              decoration: BoxDecoration(
                color: Color(0xffFFFFFF),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [BoxShadow(
                    color: Color(0x3F000000),
                    offset: Offset(0, 2),
                    blurRadius: 2.0,
                    spreadRadius: 1)],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        alignment: Alignment.center,
                        width: 60,
                        height: 24,
                        child: Text(model.taskStatus == 1 ? "未开始" : model.taskStatus == 2 ? "进行中" : "已结束", style: TextStyle(fontSize: 13, color: Colors.white, fontWeight: FontWeight.bold), maxLines: 1, ),
                        decoration: BoxDecoration(
                          color: model.taskStatus == 1 ? Color.fromRGBO(255, 141, 98, 1) : model.taskStatus == 2 ? Color.fromRGBO(60, 192, 160, 1) : Color.fromRGBO(0, 145, 203, 1),
                          borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(8.0),
                              topRight: Radius.circular(8.0)),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 0,left: 15),
                    child: Text(model.taskName!, style: TextStyle(fontSize: 16, color: Color(0xff3B3838), fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis,),
                  ),

                  Padding(
                    padding: EdgeInsets.only(top: 8,left: 15),
                    child: Container(
                      alignment: Alignment.center,
                      height: 20,
                      width: 105,
                      decoration: BoxDecoration(
                        color: Color.fromRGBO(225, 242, 254, 1),
                        borderRadius: BorderRadius.all(Radius.circular(8.0),
                        ),
                      ),
                      child: Text(grades[model.gradeId!]! + "·" + subjectSample[model.subjectId!]!, style: TextStyle(fontSize: 12, color: Color(0xff3B3838),), maxLines: 1, overflow: TextOverflow.ellipsis,),
                    ),
                  ),

                  Padding(
                    padding: EdgeInsets.only(top: 12, left: 15, right: 15),
                    child: Text("开始时间: ${model.startTime}",style: TextStyle(fontSize: 11, color: Color(0xff888888)),),
                  ),

                  Padding(
                    padding: EdgeInsets.only(top: 5, left: 15, right: 15),
                    child: Text("结束时间: ${model.endTime}",style: TextStyle(fontSize: 11, color: Color(0xff888888)),),
                  ),
                  if (model.taskStatus == 3)
                    Padding(padding: EdgeInsets.only(top: 10)),
                  if (model.taskStatus == 3)
                    Container(height: 0.5,color: Color(0xffECECEC),),
                  if (model.taskStatus == 3)
                    _buildBottomContainer(model),
                ],
              ),
            ),
            Padding(padding: EdgeInsets.only(top: 18)),
          ],
        ),
        onTap: model.taskStatus == 3 ? (){
          _navigateToDetail(model);
        } : (){
          Fluttertoast.showToast(msg: "任务还未结束!");
        },
      ),
    );
  }

  ///
  /// @description 质检消错卡片布局
  /// @param
  /// @return
  /// @author waitwalker
  /// @time 2020/10/29 9:29 AM
  ///
  _buildBottomContainer(PaperList model) {
    return Padding(
      padding: EdgeInsets.only(top: 10, left: 25, right: 25),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            alignment: Alignment.center,
            height: 32,
            width: MediaQuery.of(context).size.width - 2 * 25 - 32,
            child: Text((model.isPaid == 1 && model.reportState == 1) ? "名师答疑" : "查看详情" , style: TextStyle(fontSize: 14, color: Color(0xffFFFFFF)),),
            decoration: BoxDecoration(
              color: (model.isPaid == 1 && model.reportState == 1) ? Color(0xffEF5C59) : Color(0xff4499dd),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ],
      ),
    );
  }

  _navigateToDetail(PaperList model) {
    print("质检消错查看详情");
    var url = APIConst.unitTestDetail;
    var token = NetworkManager.getAuthorization();
    String fullURL = '$url?token=$token&taskid=${model.taskId}&paperid=${model.paperId}';
    Navigator.push(context, MaterialPageRoute(builder: (context){
      return CommonWebviewPage(initialUrl:fullURL, title: model.taskName, pageType: 21,);
    }));
  }

}