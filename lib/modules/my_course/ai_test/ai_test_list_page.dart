import 'dart:async';
import 'dart:convert';
import 'package:my_gallery/common/dao/original_dao/analysis.dart';
import 'package:my_gallery/common/dao/original_dao/course_dao_manager.dart';
import 'package:my_gallery/common/dao/original_dao/material_dao.dart';
import 'package:my_gallery/common/singleton/singleton_manager.dart';
import 'package:my_gallery/common/logger/logger.dart';
import 'package:my_gallery/common/tools/share_preference/share_preference.dart';
import 'package:my_gallery/model/ai_model.dart';
import 'package:my_gallery/model/material_model.dart';
import 'package:my_gallery/common/const/api_const.dart';
import 'package:my_gallery/common/network/network_manager.dart';
import 'package:my_gallery/common/redux/app_state.dart';
import 'package:my_gallery/model/wisdom_model.dart';
import 'package:my_gallery/model/self_study_record.dart';
import 'package:my_gallery/modules/my_course/choose_material_version/choose_material_page.dart';
import 'package:my_gallery/modules/my_course/wisdom_study/wisdom_study_list_page.dart';
import 'package:my_gallery/modules/widgets/loading/list_type_loading_placehold_widget.dart';
import 'package:my_gallery/modules/widgets/star/star_rating.dart';
import 'package:my_gallery/modules/widgets/style/style.dart';
import 'package:my_gallery/modules/widgets/alert/activity_alert.dart';
import 'package:my_gallery/modules/widgets/empty_placeholder/empty_placeholder_widget.dart';
import 'package:my_gallery/modules/widgets/expanded_listview/expanded_listview.dart';
import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import 'package:umeng_plugin/umeng_plugin.dart';
import 'ai_webview_page.dart';

late BuildContext pageContext;

///
/// @name AITestPage
/// @description AI 测试页面
/// @author waitwalker
/// @date 2020-01-10
///
// ignore: must_be_immutable
class AITestListPage extends StatefulWidget {
  var type = 1;
  var subjectId;
  var gradeId;
  var courseId;
  var memoizer;
  var previewMode;

  AITestListPage(this.subjectId, this.gradeId,
      {this.memoizer, this.courseId, this.previewMode});

  @override
  _AITestListPageState createState() => _AITestListPageState();
}
  
class _AITestListPageState extends State<AITestListPage> {
  AsyncMemoizer? memoizer;
  List<Data>? detailData;
  Data? selectedRes;
  SelfStudyRecord? recordValue;

  @override
  void initState() {
    super.initState();
    pageContext = context;
    memoizer = widget.memoizer ?? AsyncMemoizer();
    UmengPlugin.beginPageView("AI测试");
    if (!widget.previewMode) {
      _loadLocalStudyRecord();
    }
  }

  @override
  void dispose() {
    super.dispose();
    memoizer = null;
    UmengPlugin.endPageView("AI测试");
  }

  _getData(subjectId, gradeId, type) =>
      memoizer!.runOnce(() => _getAll(subjectId, gradeId, type));

  /// 读取本地历史学习记录
  _loadLocalStudyRecord() {
    var s = SharedPrefsUtils.getString('ai_record', '')!;
    Map<String, dynamic>? map;
    try {
      map = jsonDecode(s);
    } on Exception catch (e) {
      print("异常:$e");
    }
    if (map == null || !map.containsKey('type')) {
      recordValue = SelfStudyRecord(
          type: 4,
          subjectId: widget.subjectId,
          gradeId: widget.gradeId,
          firstId: -1,
          secondId: -1,
          thirdId: -1,
          nodeName: "");
      return;
    }

    if (map['type'] == 4) {
    recordValue = SelfStudyRecord.fromJson(map);
    } else {
    recordValue = SelfStudyRecord(
        type: 4,
        subjectId: widget.subjectId,
        gradeId: widget.gradeId,
        firstId: -1,
        secondId: -1,
        thirdId: -1,
        nodeName: "");
    }
  }

  @override
  Widget build(BuildContext context) {
    return StoreBuilder(builder: (BuildContext context, Store<AppState> store) {
      return _buildWidget();
    });
  }

  ///
  /// @description FutureBuilder 请求回调
  /// @param
  /// @return
  /// @author waitwalker
  /// @time 4/20/21 3:50 PM
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
          if (snapshot.error == "教材ID为空") {
            return EmptyPlaceholderPage(assetsPath: 'static/images/empty.png', message: '没有数据');
          } else {
            return Text('Error: ${snapshot.error}');
          }
        }
        var material = snapshot.data['material'];
        var list = snapshot.data['list'];
        var model = list.model as AiModel;
        var materialModel = material as MaterialDataEntity?;
        detailData = model.data;

        if (model.code == 1 && detailData != null && detailData!.length > 0) {
          return _buildList(materialModel, detailData);
        }
        return Column(
          children: [
            Container(
                height: 74,
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: _buildChooseMaterial(materialModel)),
            EmptyPlaceholderPage(assetsPath: 'static/images/empty.png', message: '没有数据'),
          ],
        );
      default:
        return EmptyPlaceholderPage(assetsPath: 'static/images/empty.png', message: '没有数据');
    }
  }

  ///
  /// @description FutureBuilder
  /// @param
  /// @return
  /// @author waitwalker
  /// @time 4/20/21 3:50 PM
  ///
  Widget _buildWidget() {
    return FutureBuilder(
      builder: _futureBuilder,
      future: _getData(widget.subjectId, widget.gradeId, widget.type),
    );
  }

  ///
  /// @description 获取数据
  /// @param
  /// @return
  /// @author waitwalker
  /// @time 4/20/21 3:50 PM
  ///
  _getAll(subjectId, gradeId, type) async {
    var response = await MaterialDao.material(subjectId, gradeId, type);
    if (response.result && response.model.code == 1) {
      if (response.model != null && response.model.data != null) {
        var materialId = (response.model as MaterialModel).data!.defMaterialId;
        var materialModel = response.model.data;
        if (this.mounted) {
          setState(() {});
        }
        return CourseDaoManager.aiStudyList(materialId)
            .then((t) => {'material': materialModel, 'list': t});
      } else {
        return Future.error('教材ID为空');
      }
    }
    return Future.error('获取教材信息失败');
  }

  ///
  /// @description 构建AI列表控件
  /// @param
  /// @return
  /// @author waitwalker
  /// @time 4/20/21 3:49 PM
  ///
  Widget _buildList(MaterialDataEntity? materialModel, List<Data>? data) {
    _loadLocalStudyRecord();
    if (widget.previewMode) {
      /// 章
      Data currentDataEntity = data![0];
      if (currentDataEntity.chapterList != null && currentDataEntity.chapterList!.length > 0) {
        /// 第一个节数据
        Data tmpDataEntity = currentDataEntity.chapterList![0];
        if (tmpDataEntity.chapterList != null && tmpDataEntity.chapterList!.length >= 2) {
          recordValue!.firstItemId = tmpDataEntity.chapterList![0].chapterId;
          recordValue!.secondItemId = tmpDataEntity.chapterList![1].chapterId;
          recordValue!.firstId = currentDataEntity.chapterId;
          recordValue!.secondId = tmpDataEntity.chapterId;
          recordValue!.title = tmpDataEntity.chapterList![0].chapterName;
        } else {
          /// 节下面没有知识点
          if (tmpDataEntity.chapterList != null && tmpDataEntity.chapterList!.length > 0) {
            recordValue!.title = tmpDataEntity.chapterList![0].chapterName;
            recordValue!.firstItemId = tmpDataEntity.chapterList![0].chapterId;
            recordValue!.secondItemId = -1;
            recordValue!.firstId = currentDataEntity.chapterId;
            recordValue!.secondId = -1;
          } else {
            recordValue!.title = tmpDataEntity.chapterName;
            recordValue!.firstItemId = tmpDataEntity.chapterId;
            recordValue!.firstId = currentDataEntity.chapterId;
            if (currentDataEntity.chapterList!.length > 1) {
              Data secondK = currentDataEntity.chapterList![1];
              recordValue!.secondItemId = secondK.chapterId;
              recordValue!.secondId = -1;
            } else {
              recordValue!.secondItemId = -1;
              recordValue!.secondId = -1;
            }
          }
        }
      } else {

      }
    }
    return Column(
      children: <Widget>[
        Divider(height: 0.5),
        materialModel == null
            ? const SizedBox()
            : Stack(alignment: Alignment.bottomCenter, children: <Widget>[
          Positioned(child: Container(height: 32, color: Colors.white,)),
          Container(
              height: 74,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: _buildChooseMaterial(materialModel))
        ]),
        (data != null && data.length > 0) ? Flexible(
          child: ListView.separated(
            itemCount: data.length,
            separatorBuilder: (BuildContext context, int index) => Divider(
                color: Colors.transparent, height: 2),
            itemBuilder: (BuildContext context, int index) {
              return EntryItem(
                  data[index],
                  index: index,
                  record: recordValue,
                  previewMode: widget.previewMode, onPress: (clickedItem, [p]) async {
                    Data currentDataEntity = data[index];
                    recordValue!.firstId = currentDataEntity.chapterId;
                    /// 这个主要记录点击的是哪个  为了展开列表
                    if (clickedItem.level == 2) {
                      for (int i = 0; i < currentDataEntity.chapterList!.length; i++) {
                        Data tmpDataEntity = currentDataEntity.chapterList![i];
                        if (tmpDataEntity.chapterId == clickedItem.chapterId) {
                          recordValue!.secondId = clickedItem.chapterId;
                          recordValue!.thirdId = -1;
                        }
                      }
                    }

                    if (clickedItem.level == 3) {
                      for (int i = 0; i < currentDataEntity.chapterList!.length; i++) {
                        Data tmpDataEntity = currentDataEntity.chapterList![i];
                        if (tmpDataEntity.chapterList != null && tmpDataEntity.chapterList!.length > 0) {
                          for (int j = 0; j < tmpDataEntity.chapterList!.length; j++) {
                            Data thirdLevelDataEntity = tmpDataEntity.chapterList![j];
                            if (thirdLevelDataEntity.chapterId == clickedItem.chapterId) {
                              recordValue!.secondId = tmpDataEntity.chapterId;
                              recordValue!.thirdId = thirdLevelDataEntity.chapterId;
                            }
                          }
                        }
                      }
                    }
                    recordValue!.id = -1;
                    recordValue!.courseId = -1;
                    recordValue!.title = clickedItem.chapterName;
                    if (recordValue != null) {
                      aiSaveRecord(recordValue);
                      setState(() {});
                    }

                    var nodeId = (clickedItem as Data).chapterId;
                    /// ai学习记录
                    AnalysisDao.log(materialModel!.defMaterialId, nodeId, 5, 0);
                    Navigator.of(context).push(MaterialPageRoute(builder: (_) {
                      var token = NetworkManager.getAuthorization();
                      var versionId = materialModel.defVersionId;
                      var subjectId = materialModel.subjectId;
                      var url = '${APIConst.practiceHost}/ai.html?token=$token&versionid=$versionId&currentdirid=$nodeId&subjectid=$subjectId&courseid=${widget.courseId}';
                      /// 跳转到AI详情页面
                      return AIWebPage(
                        currentDirId: nodeId.toString(), 
                        versionId: versionId.toString(), 
                        subjectId: subjectId.toString(), 
                        initialUrl: url, 
                        title: clickedItem.chapterName,
                      );
                    }),).then((_) {
                      setState(() {
                        memoizer = memoizer = AsyncMemoizer();
                      });
                    });
                  },
              );
            },
          ),
        ) : EmptyPlaceholderPage(assetsPath: 'static/images/empty.png', message: '没有数据')
      ],
    );
  }

  ///
  /// @description 切换教材
  /// @param
  /// @return
  /// @author waitwalker
  /// @time 2020/8/31 9:26 AM
  ///
  Container _buildChooseMaterial(MaterialDataEntity? materialModel) {
    return Container(
      padding: EdgeInsets.only(left: 15, right: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(
          Radius.circular(6),
        ),
        boxShadow: [
          BoxShadow(
              color: Color(MyColors.shadow),
              offset: Offset(0, 2),
              blurRadius: 10.0,
              spreadRadius: 2.0)
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          materialModel == null
              ? Container()
              : Expanded(
                  child: Text(
                      '${materialModel.defAbbreviation} - ${materialModel.defMaterialName}',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: SingletonManager.sharedInstance!.screenWidth > 500.0 ? 18 : 14,
                          fontWeight: FontWeight.w600))),
          InkWell(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 6),
              width: 75,
              height: 24,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(12.0)),
                color: Color(0xffF4F5F8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(MyIcons.SWITCH, size: 11, color: Color(0xFFA3ABBB)),
                  const SizedBox(width: 5),
                  Text('切换', style: TextStyle(
                      fontSize: SingletonManager.sharedInstance!.screenWidth > 500.0 ? 13 : 11,
                      color: Color(0xFF384A69)))
                ],
              ),
            ),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (_) {
                return ChooseMaterialPage(
                    subjectId: widget.subjectId,
                    gradeId: widget.gradeId,
                    type: widget.type,
                    materialId: materialModel?.defMaterialId,
                  materialDataEntity: materialModel,
                );
              })).then((v) {
                if (v ?? false) {
                  widget.memoizer = memoizer = AsyncMemoizer();
                  if (this.mounted) {
                    setState(() {});
                  }
                }
              });
            },
          ),
        ],
      ),
    );
  }
}

///
/// @name EntryItem
/// @description 构建章节树组件
/// @author waitwalker
/// @date 2019-12-25
///
// ignore: must_be_immutable
class EntryItem extends StatelessWidget {
  ChapterOnPress? onPress;
  final Data entry;
  bool? previewMode;
  SelfStudyRecord? record;
  var index;

  EntryItem(this.entry, {this.onPress, this.previewMode = false, this.index, this.record});

  Widget _buildTiles(
      Data root, {
        bool selected = false,
        int currentIndex = 0,
        bool isFirst = false,
        bool isLast = false}) {
    // 叶子节点
    if (root.chapterList?.isEmpty ?? true) {
      var rating = root.starNum;
      Color color;
      color = previewMode! ? Color(0xff4F5962):
      (root.chapterName == record!.title ? Colors.orangeAccent : Color(0xff4F5962));
      return InkWell(
          child: Container(
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(6)),
            padding: EdgeInsets.only(left: (root.level == 1 ? 0 : 1) * 10.0),
            child: Padding(padding: EdgeInsets.only(left: root.level == 3 ? 5 : 0),
              child: Row(
                children: [
                  root.level == 3 ?
                  Padding(padding: EdgeInsets.only(left: 10,),
                    child: timeLine(
                        selected: previewMode! ? false : root.chapterName == record!.title,
                        isFirst: isFirst,
                        isLast: isLast),) :
                  Container(),
                  Expanded(child: Container(child: ListTile(
                    key: PageStorageKey<Data>(root),
                    dense: true,
                    selected: selected,
                    title: Text(root.chapterName!, style: TextStyle(fontSize: SingletonManager.sharedInstance!.screenWidth > 500.0 ? 18 : 12, color: color),),
                    trailing: _buildRightWidget(rating, currentIndex: currentIndex, previewMode: previewMode!, recordV: record, data: root),
                  ),),),
                ],
              ),
            ),
          ),
          onTap: () {
            if (previewMode!) {
              if (root.chapterId == record!.firstItemId || root.chapterId == record!.secondItemId) {
                onPress!(root);
              } else {
                showDialog(context: pageContext, builder: _dialogBuilder);
              }
            } else {
              onPress!(root);
            }
          },);
    }

    List<Widget> newChildren = [];
    if (root.chapterList != null && root.chapterList!.length > 0) {
      for(int i = 0; i < root.chapterList!.length; i++) {
        Data data = root.chapterList![i];
        newChildren.add(_buildTiles(
            data,
            currentIndex: i,
            selected: false,
            isFirst: i == 0,
            isLast: i == root.chapterList!.length - 1));
      }
    }

    DataEntity dataEntity = DataEntity();
    dataEntity.nodeName = root.chapterName;
    dataEntity.nodeId = root.chapterId;
    Color color;
    bool expandOrNot = (
        record?.firstId == root.chapterId ||
        record?.secondId == root.chapterId ||
            record?.thirdId == root.chapterId);
    color = previewMode! ? Color(0xff4F5962) :
    expandOrNot ? Colors.orangeAccent : Color(0xff4F5962);

    /// 显示列表
    return Padding(
      padding: EdgeInsets.only(left: (root.level! - 1) * 10.0),
      child: ExpandedList(
        key: PageStorageKey<DataEntity>(dataEntity),
        initiallyExpanded: expandOrNot,
        title: Expanded(
            child: Text(
              root.chapterName!.trim(),
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontSize: SingletonManager.sharedInstance!.screenWidth > 500.0 ? 18 :
                  root.level! < 2 ? 14 : 12, color: color),)),
        children: newChildren,
      ),
    );
  }

  ///
  /// @description 根据预览模式构建体验/五角星等控件
  /// @param
  /// @return
  /// @author waitwalker
  /// @time 4/20/21 3:38 PM
  ///
  _buildRightWidget(
      rating, {
        int currentIndex = 0,
        bool previewMode = false,
        SelfStudyRecord? recordV,
        Data? data}) {
    print("recordV:$recordV");
    if (previewMode) {
      if (data!.chapterId == recordV!.firstItemId || data.chapterId == recordV.secondItemId) {
        return _tryTag();
      } else {
        return _lockTag();
      }
    } else {
      return Container(
        width: 80,
        height: 20,
        child: StarRating(
          size: 20.0,
          rating: rating.toDouble(),
          color: Color(0xffF8D75B),
          borderColor: Color(0xffE7E7E7),
          starCount: 4,),);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: _buildTiles(entry, isFirst: index == 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }
}

///
/// @description 时间轴控件
/// @param
/// @return
/// @author waitwalker
/// @time 4/20/21 3:49 PM
///
Widget timeLine({bool isFirst = false, bool isLast = false, bool selected = false}) {
  return Container(
    height: 64,
    child: Column(
      children: <Widget>[
        Expanded(
          flex: 1,
          child: Container(
            width: 2,
            color: isFirst ? Colors.transparent : Color(MyColors.line),
          ),
        ),
        Container(width: 6, height: 6,
          decoration: BoxDecoration(color: Color(0xffEBEBEB),
            border: Border.all(color: Color(selected ? MyColors.primaryValue : 0xffEBEBEB), width: 2.0,),
            boxShadow: selected
                ? [
              BoxShadow(
                  color: Color(MyColors.primaryValue),
                  offset: Offset(0, 0),
                  blurRadius: 10.0,
                  spreadRadius: 0.0)
            ]
                : null,
            shape: BoxShape.circle,
          ),
        ),
        Expanded(
          flex: 1,
          child: Container(
            color: isLast ? Colors.transparent : Color(MyColors.line),
            width: 1.5,
          ),
        )
      ],
    ),
  );
}

Widget _lockTag() {
  return Icon(Icons.lock, size: 20);
}

Container _tryTag() {
  return Container(
      width: 38,
      height: 20,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(4.0)),
        border: Border.all(
          color: Color(0xFF6B8DFF),
        ),
      ),
      child: Text('体验', style: textStyle11Blue));
}

Widget _dialogBuilder(BuildContext context) {
  return ActivityCourseAlert(
    tapCallBack: () {
      Navigator.of(context).pop();
    },
  );
}

///
/// @description 记录AI学习
/// @param
/// @return
/// @author waitwalker
/// @time 4/20/21 3:49 PM
///
void aiSaveRecord(record) {
  if (record != null &&
      record.id != null &&
      record.subjectId != null &&
      record.gradeId != null &&
      record.type != null &&
      (record.title?.isNotEmpty ?? false)) {
    record.type = 4;
    debugLog(record.toString(), tag: 'save');
    SharedPrefsUtils.put('ai_record', record.toString());
  }
}