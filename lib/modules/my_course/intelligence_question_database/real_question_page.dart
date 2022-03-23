import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:gzx_dropdown_menu/gzx_dropdown_menu.dart';
import 'package:my_gallery/common/const/api_const.dart';
import 'package:my_gallery/common/dao/manager/dao_manager.dart';
import 'package:my_gallery/common/network/error_code.dart';
import 'package:my_gallery/common/network/network_manager.dart';
import 'package:my_gallery/common/network/response.dart';
import 'package:my_gallery/common/singleton/singleton_manager.dart';
import 'package:my_gallery/event/http_error_event.dart';
import 'package:my_gallery/modules/my_course/intelligence_question_database/real_question_answer_record_page.dart';
import 'package:my_gallery/modules/my_course/intelligence_question_database/real_question_model.dart';
import 'package:my_gallery/modules/widgets/webviews/common_webview_page.dart';
import 'package:my_gallery/modules/widgets/empty_placeholder/empty_placeholder_widget.dart';
import 'package:my_gallery/modules/widgets/loading/list_type_loading_placehold_widget.dart';
import 'package:async/async.dart';

class SortCondition {
  String? name;
  bool? isSelected;
  var value;
  SortCondition({this.name, this.isSelected, this.value});
}

///
/// @description 历年真题页面
/// @author waitwalker
/// @time 3/30/21 1:47 PM
///
class RealQuestionPage extends StatefulWidget {
  final int? courseId;
  final int? subjectId;
  final int? gradeId;
  RealQuestionPage({this.courseId, this.gradeId, this.subjectId});
  @override
  _RealQuestionPageState createState() => _RealQuestionPageState();
}

class _RealQuestionPageState extends State<RealQuestionPage> {
  List<String?> _dropDownHeaderItemStrings = ['第一学期', '期中', '2020-2021'];
  List<SortCondition> _semesterSortConditions = [];
  List<SortCondition> _typeSortConditions = [];
  List<SortCondition> _yearSortConditions = [];
  late SortCondition _selectSemesterSortCondition;
  late SortCondition _selectTypeSortCondition;
  late SortCondition _selectYearSortCondition;
  GZXDropdownMenuController _dropdownMenuController = GZXDropdownMenuController();
  int? currentSemester = 1;
  int? currentType = 5;
  String? currentYear = "2020-2021";

  late AsyncMemoizer memoizer;

  var _scaffoldKey = new GlobalKey<ScaffoldState>();
  GlobalKey _stackKey = GlobalKey();

  String _dropdownMenuChange = '';
  AppBar? appBar;
  List<Data>? dataSource = [];

  @override
  void initState() {
    super.initState();
    memoizer = AsyncMemoizer();
    _semesterSortConditions.add(SortCondition(name: '第一学期', isSelected: true, value: 1));
    _semesterSortConditions.add(SortCondition(name: '第二学期', isSelected: false, value: 2));
    _selectSemesterSortCondition = _semesterSortConditions[0];

    /// 初三
    if (widget.gradeId == 4) {
      _typeSortConditions.add(SortCondition(name: '期中', isSelected: true, value: 5));
      _typeSortConditions.add(SortCondition(name: '期末', isSelected: false, value: 6));
      _typeSortConditions.add(SortCondition(name: '中考模拟', isSelected: false, value: 7));
      _typeSortConditions.add(SortCondition(name: '中考真题', isSelected: false, value: 1));
    } else if (widget.gradeId == 1) {
      /// 高三
      _typeSortConditions.add(SortCondition(name: '期中', isSelected: true, value: 5));
      _typeSortConditions.add(SortCondition(name: '期末', isSelected: false, value: 6));
      _typeSortConditions.add(SortCondition(name: '高考模拟', isSelected: false, value: 8));
      _typeSortConditions.add(SortCondition(name: '高考真题', isSelected: false, value: 2));
    } else {
      /// 其他年级
      _typeSortConditions.add(SortCondition(name: '期中', isSelected: true, value: 5));
      _typeSortConditions.add(SortCondition(name: '期末', isSelected: false, value: 6));
    }
    _selectTypeSortCondition = _typeSortConditions[0];

    _yearSortConditions.add(SortCondition(name: '2020-2021', isSelected: true, value: "2020-2021"));
    _yearSortConditions.add(SortCondition(name: '2019-2020', isSelected: false, value: "2019-2020"));
    _yearSortConditions.add(SortCondition(name: '2018-2019', isSelected: false, value: "2018-2019"));
    _yearSortConditions.add(SortCondition(name: '2017-2018', isSelected: false, value: "2017-2018"));
    _yearSortConditions.add(SortCondition(name: '2016-2017', isSelected: false, value: "2016-2017"));
    _yearSortConditions.add(SortCondition(name: '2015-2016', isSelected: false, value: "2015-2016"));
    _yearSortConditions.add(SortCondition(name: '2014-2015', isSelected: false, value: "2014-2015"));
    _selectYearSortCondition = _yearSortConditions[0];

    /// event 监听事件
    ErrorCode.eventBus.on<dynamic>().listen((event) {
      if (event is HttpErrorEvent) {
        HttpErrorEvent errorEvent = event;
        if (errorEvent.message == "可以刷新" && errorEvent.code == 200) {
          Future.delayed(Duration(seconds: 5),(){
            setState(() {
              memoizer = AsyncMemoizer();
              if (this.mounted) {
                setState(() {});
              }
            });
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    appBar = AppBar(
      backgroundColor: Colors.white,
      title: Text("历年真题"),
      elevation: 0,
    );
    return Scaffold(
      key: _scaffoldKey,
      appBar: appBar,
      backgroundColor: Colors.white,
      body: Stack(
        key: _stackKey,
        children: <Widget>[
          Column(
            children: <Widget>[
              // 下拉菜单头部
              Container(
                child: GZXDropDownHeader(
                  // 下拉的头部项，目前每一项，只能自定义显示的文字、图标、图标大小修改
                  items: [
                    GZXDropDownHeaderItem(_dropDownHeaderItemStrings[0]!),
                    GZXDropDownHeaderItem(_dropDownHeaderItemStrings[1]!),
                    GZXDropDownHeaderItem(_dropDownHeaderItemStrings[2]!,),
                  ],
                  // GZXDropDownHeader对应第一父级Stack的key
                  stackKey: _stackKey,
                  // controller用于控制menu的显示或隐藏
                  controller: _dropdownMenuController,
                  // 当点击头部项的事件，在这里可以进行页面跳转或openEndDrawer
                  onItemTap: (index) {

                  },
                  // 头部的高度
                  height: 44,
                  // 头部背景颜色
                  //color: Colors.blue,
                  // 头部边框宽度
                  borderWidth: 0,
//                // 头部边框颜色
//                borderColor: Color(0xFFeeede6),
//                // 分割线高度
//                dividerHeight: 20,
//                // 分割线颜色
//                dividerColor: Color(0xFFeeede6),
//                // 文字样式
                  style: TextStyle(color: Color(0xFF999999), fontSize: 13),
//                // 下拉时文字样式
                  dropDownStyle: TextStyle(
                    fontSize: 13,
                    color: Color(0xff2E96FF),
                  ),
                  // 图标大小
                  iconSize: 20,
                  // 图标颜色
                  iconColor: Color(0xFF999999),
                  // 下拉时图标颜色
                  iconDropDownColor: Color(0xFF2E96FF),
                ),
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                        color: Color(0xffB2C1D9),
                        offset: Offset(0, 1),
                        blurRadius: 6.0,
                        spreadRadius: 0),
                  ],
                ),
              ),
              Padding(padding: EdgeInsets.only(top: 16)),
              _buildBodyFuture(),
              Padding(padding: EdgeInsets.only(top: 16)),
            ],
          ),
          // 下拉菜单
          GZXDropDownMenu(
            // controller用于控制menu的显示或隐藏
            controller: _dropdownMenuController,
            // 下拉菜单显示或隐藏动画时长
            animationMilliseconds: 200,
            dropdownMenuChanging: (isShow, index) {
              setState(() {
                _dropdownMenuChange = '(正在${isShow ? '显示' : '隐藏'}$index)';
                print(_dropdownMenuChange);
              });
            },
            dropdownMenuChanged: (isShow, index) {
              setState(() {
                _dropdownMenuChange = '(已经${isShow ? '显示' : '隐藏'}$index)';
                print(_dropdownMenuChange);
              });
            },
            // 下拉菜单，高度自定义，你想显示什么就显示什么，完全由你决定，你只需要在选择后调用_dropdownMenuController.hide();即可
            menus: [
              GZXDropdownMenuBuilder(
                  dropDownHeight: 40.0 * _semesterSortConditions.length / 2.0 + (SingletonManager.sharedInstance!.isPadDevice? 80 : 30),
                  dropDownWidget: _buildConditionListWidget(_semesterSortConditions, 2, (value) {
                    _selectSemesterSortCondition = value;
                    _dropDownHeaderItemStrings[0] = _selectSemesterSortCondition.name;
                    _dropdownMenuController.hide();
                    currentSemester = _selectSemesterSortCondition.value;
                    setState(() {
                      memoizer = AsyncMemoizer();
                      if (this.mounted) {
                        setState(() {});
                      }
                    });
                  })),
              GZXDropdownMenuBuilder(
                  dropDownHeight: 40.0 * _typeSortConditions.length  / 2.0 +
                      (SingletonManager.sharedInstance!.isPadDevice? 80 :
                      (widget.gradeId == 4 || widget.gradeId == 1) ? 50 : 30),
                  dropDownWidget: _buildConditionListWidget(_typeSortConditions, 2,  (value) {
                    _selectTypeSortCondition = value;
                    _dropDownHeaderItemStrings[1] = _selectTypeSortCondition.name;
                    _dropdownMenuController.hide();
                    currentType = _selectTypeSortCondition.value;
                    setState(() {
                      memoizer = AsyncMemoizer();
                      if (this.mounted) {
                        setState(() {});
                      }
                    });
                  })),
              GZXDropdownMenuBuilder(
                  dropDownHeight: 40.0 * _yearSortConditions.length / 3.0 + (SingletonManager.sharedInstance!.isPadDevice? 140 : 50),
                  dropDownWidget: _buildConditionListWidget(_yearSortConditions, 3, (value) {
                    _selectYearSortCondition = value;
                    _dropDownHeaderItemStrings[2] = _selectYearSortCondition.name;
                    _dropdownMenuController.hide();
                    currentYear = _selectYearSortCondition.value;
                    setState(() {
                      memoizer = AsyncMemoizer();
                      if (this.mounted) {
                        setState(() {});
                      }
                    });
                  })),
            ],
          ),
        ],
      ),
    );
  }

  ///
  /// @description 构建选择条件列表:1)学期;2)类型;3)年份
  /// @param 
  /// @return 
  /// @author waitwalker
  /// @time 3/30/21 3:37 PM
  ///
  _buildConditionListWidget(items, columns, void itemOnTap(SortCondition sortCondition)) {
    return Padding(padding: EdgeInsets.only(
      left: 16, top: 16, right: 16,),
      child: Column(
        children: [
          Expanded(
            child: GridView.builder(
              itemBuilder: (BuildContext context, int index){
                SortCondition goodsSortCondition = items[index];
                return InkWell(
                  child: Container(
                    alignment: Alignment.center,
                    child: Text(
                      goodsSortCondition.name!,
                      style: TextStyle(
                        fontSize: 12,
                        color: goodsSortCondition.isSelected! ? Color(0xff2E96FF) : Color(0xff666666),
                      ),
                    ),
                    decoration: BoxDecoration(
                      color: Color(0xffF5F5F5),
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                  onTap: (){
                    for (var value in items) {
                      value.isSelected = false;
                    }
                    goodsSortCondition.isSelected = true;
                    itemOnTap(goodsSortCondition);
                  },
                );
              },
              itemCount: items.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 4.5, ///宽高比
              ),
            ),
          ),
        ],
      ),
    );
  }

  ///
  /// @description 构建body widget
  /// @param
  /// @return
  /// @author waitwalker
  /// @time 12/3/20 9:39 AM
  ///
  Widget _buildBodyFuture() {
    return FutureBuilder(
      builder: _futureBuilder,
      future: _realQuestionFetchData(widget.subjectId, widget.gradeId, currentSemester, currentType, currentYear),
    );
  }

  ///
  /// @description 获取数据
  /// @param
  /// @return
  /// @author waitwalker
  /// @time 12/3/20 9:47 AM
  ///
  _realQuestionFetchData(subjectId, gradeId, semester, type, year) =>
      memoizer.runOnce(() => _fetchData(subjectId, gradeId, semester, type, year));

  ///
  /// @description 获取教材版本&列表数据
  /// @param
  /// @return
  /// @author waitwalker
  /// @time 12/3/20 9:44 AM
  ///
  _fetchData(subjectId, gradeId, semester, type, year) async {
    return DaoManager.fetchRealQuestionData(subjectId, gradeId, semester, type, year);
  }


  ///
  /// @description 刷新方法添加
  /// @param
  /// @return
  /// @author waitwalker
  /// @time 2020/11/5 3:10 PM
  ///
  Future<Null> _realQuestionOnRefresh() async{
    memoizer = AsyncMemoizer();
    if (this.mounted) {
      setState(() {});
    }
  }

  ///
  /// @description 根据future响应构建widget
  /// @param
  /// @return
  /// @author waitwalker
  /// @time 12/3/20 9:40 AM
  ///
  Widget _futureBuilder(BuildContext context, AsyncSnapshot snapshot) {
    switch (snapshot.connectionState) {
      case ConnectionState.none:
        return Text('还没有开始网络请求');
      case ConnectionState.active:
        return Text('ConnectionState.active');
      case ConnectionState.waiting:
        return Center(
          child: LoadingListWidget(),
        );
      case ConnectionState.done:
        if (snapshot.hasError) {
          return _placeholderPage();
        }

        var res = snapshot.data;
        ResponseData? responseData = res as ResponseData?;
        if (res != null && responseData!.result) {
          RealQuestionModel realQuestionModel = responseData.model as RealQuestionModel;
          if (realQuestionModel.data != null && realQuestionModel.data!.length > 0) {
            dataSource = realQuestionModel.data;
            return _realQuestionBuildList(realQuestionModel.data);
          } else {
            return _placeholderPage();
          }
        } else {
          return _placeholderPage();
        }
        return _placeholderPage();
      default:
        return _placeholderPage();
    }
  }

  ///
  /// @description 没有数据占位页
  /// @param
  /// @return 
  /// @author waitwalker
  /// @time 4/7/21 2:52 PM
  ///
  _placeholderPage() {
    return EmptyPlaceholderPage(assetsPath: 'static/images/no_data_placeholder.png', message: '当前没有真题', fontSize: 15,);
  }

  ///
  /// @description 构建列表
  /// @param
  /// @return
  /// @author waitwalker
  /// @time 12/3/20 9:40 AM
  ///
  Widget _realQuestionBuildList(List<Data>? data) {
    double statusBarHeight = MediaQuery.of(context).padding.top;
    double appBarHeight = appBar!.preferredSize.height;
    return (data != null && data.isNotEmpty) ?
    /// 数据不为空 展示列表页
    Container(
      height: MediaQuery.of(context).size.height - appBarHeight - statusBarHeight - 80,
      child: Column(
        children: [
          Expanded(
            child: EasyRefresh(
              child: ListView.separated(
                separatorBuilder: (BuildContext context, int index) =>
                    Divider(color: Colors.transparent, height: 12),
                itemBuilder: _itemBuilder,
                itemCount: data.length + 1,
              ),
              firstRefresh: false,
              onRefresh: _realQuestionOnRefresh,
              header: ClassicalHeader(
                textColor: Color(0xff2E96FF),
                infoColor: Color(0xff2E96FF),
                refreshText: "下拉刷新",
                refreshingText: "正在刷新...",
                refreshedText: "刷新完成",
                refreshFailedText: "刷新失败",
                refreshReadyText: "松手刷新",
                noMoreText: "没有更多",
                infoText: "加载时间${DateTime.now().hour}:${DateTime.now().minute > 9 ? DateTime.now().minute :"0" + "${DateTime.now().minute}" }",
              ),
              onLoad: null,
            ),
          )
        ],
      ),
    ) :
    /// 数据为空 展示占位页
    EmptyPlaceholderPage(assetsPath: 'static/images/empty.png', message: '没有数据');
  }

  ///
  /// @description 卡片地址
  /// @param 
  /// @return 
  /// @author waitwalker
  /// @time 3/30/21 3:50 PM
  ///
  Widget _itemBuilder(BuildContext context, int index){
    if (index <= dataSource!.length - 1) {
      Data currentData = dataSource![index];
      return InkWell(
        onTap: (){

        },
        child: Padding(
          padding: EdgeInsets.only(left: 16, right: 16),
          child: Container(
            height: 107,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                    color: Color(0x99B2C1D9),
                    offset: Offset(0, 2.5),
                    blurRadius: 10.0,
                    spreadRadius: 0),
              ],
            ),
            child: Column(
              children: [
                Padding(padding: EdgeInsets.only(top: 12),),
                Padding(padding: EdgeInsets.only(left: 14, right: 14),
                  child: Text("${currentData.paperName}", style: TextStyle(fontSize: 15, color: Colors.black), maxLines: 2,),
                ),
                Padding(padding: EdgeInsets.only(top: 12),),
                _answerWidget(currentData),
              ],
            ),
          ),
        ),
      );
    } else {
      return Padding(padding: EdgeInsets.only(top: 20));
    }
  }

  ///
  /// @description 作答按钮组件
  /// @param
  /// @return 
  /// @author waitwalker
  /// @time 4/7/21 2:33 PM
  ///
  _answerWidget(Data currentData) {
    if (currentData.isSubmit == 0) {
      return Padding(padding: EdgeInsets.only(left: 14, right: 14),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            InkWell(
              child: Container(
                alignment: Alignment.center,
                width: 70,
                height: 26,
                decoration: BoxDecoration(
                  color: Color(0xff2E96FF),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text("开始答题", style: TextStyle(fontSize: 12, color: Colors.white),),
              ),
              onTap: (){
                Navigator.of(context).push(MaterialPageRoute(builder: (_) {
                  var url = APIConst.realQuestionPractice;
                  var token = NetworkManager.getAuthorization();
                  String fullURL = '$url?token=$token&realpaperid=${currentData.realPaperId}&papername=${currentData.paperName}&subjectid=${widget.subjectId}&courseid=${widget.courseId}';
                  fullURL = fullURL.replaceAll(" ", "");
                  return CommonWebviewPage(
                    paperName: currentData.paperName,
                    realPaperId: currentData.realPaperId,
                    title: currentData.paperName,
                    initialUrl: fullURL,
                    pageType: 42,
                    courseId: widget.courseId,
                  );
                })).then((v) {
                  memoizer = AsyncMemoizer();
                  if (this.mounted) {
                    setState(() {});
                  }
                });
              },
            ),
          ],
        ),
      );
    } else {
      return Padding(padding: EdgeInsets.only(left: 14, right: 14),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            InkWell(
              child: Container(
                alignment: Alignment.center,
                width: 70,
                height: 26,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Color(0xff6C90B5), width: 0.5)
                ),
                child: Text("再次答题", style: TextStyle(fontSize: 12, color: Color(0xff6C90B5)),),
              ),
              onTap: (){
                Navigator.of(context).push(MaterialPageRoute(builder: (_) {
                  var url = APIConst.realQuestionPractice;
                  var token = NetworkManager.getAuthorization();
                  String fullURL = '$url?token=$token&realpaperid=${currentData.realPaperId}&papername=${currentData.paperName}&subjectid=${widget.subjectId}&courseid=${widget.courseId}';
                  fullURL = fullURL.replaceAll(" ", "");
                  return CommonWebviewPage(
                    paperName: currentData.paperName,
                    realPaperId: currentData.realPaperId,
                    title: currentData.paperName,
                    initialUrl: fullURL,
                    pageType: 42,
                    courseId: widget.courseId,
                  );
                })).then((v) {
                  memoizer = AsyncMemoizer();
                  if (this.mounted) {
                    setState(() {});
                  }
                });
              },
            ),
            Padding(padding: EdgeInsets.only(left: 12),),
            InkWell(
              child: Container(
                alignment: Alignment.center,
                width: 70,
                height: 26,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Color(0xff2E96FF), width: 0.5)
                ),
                child: Text("查看结果", style: TextStyle(fontSize: 12, color: Color(0xff2E96FF)),),
              ),
              onTap: (){
                Navigator.of(context).push(MaterialPageRoute(builder: (_) {
                  return RealQuestionAnswerRecordPage(realPaperId: currentData.realPaperId, paperName: currentData.paperName, subjectId: widget.subjectId, courseId: widget.courseId,);
                })).then((v) {
                  memoizer = AsyncMemoizer();
                  if (this.mounted) {
                    setState(() {});
                  }
                });
              },
            ),
          ],
        ),
      );
    }
  }
}