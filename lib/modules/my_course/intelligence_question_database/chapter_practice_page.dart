import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:my_gallery/common/const/api_const.dart';
import 'package:my_gallery/common/dao/manager/dao_manager.dart';
import 'package:my_gallery/common/dao/original_dao/material_dao.dart';
import 'package:my_gallery/common/network/network_manager.dart';
import 'package:my_gallery/common/redux/app_state.dart';
import 'package:my_gallery/common/singleton/singleton_manager.dart';
import 'package:my_gallery/common/logger/logger.dart';
import 'package:my_gallery/common/tools/share_preference/share_preference.dart';
import 'package:my_gallery/model/material_model.dart';
import 'package:my_gallery/model/wisdom_model.dart';
import 'package:my_gallery/model/self_study_record.dart';
import 'package:my_gallery/modules/my_course/ai_test/ai_webview_page.dart';
import 'package:my_gallery/modules/my_course/choose_material_version/choose_material_page.dart';
import 'package:my_gallery/modules/my_course/wisdom_study/scroll_to_index/new_scroll_to_index.dart';
import 'package:my_gallery/modules/widgets/expanded_listview/chapter_expanded_listview.dart';
import 'package:my_gallery/modules/widgets/empty_placeholder/empty_placeholder_widget.dart';
import 'package:my_gallery/modules/widgets/loading/list_type_loading_placehold_widget.dart';
import 'package:my_gallery/modules/widgets/style/style.dart';
import 'package:async/async.dart';
import 'package:redux/redux.dart';

// ignore: must_be_immutable
class ChapterPracticePage extends StatefulWidget {

  final int type = 2;
  var courseId;
  var subjectId;
  var gradeId;
  var memoizer;

  /// 预览模式，适用于未激活用户，只能看第一条，默认为用户打开
  var previewMode;

  /// 上部当前选中的tab
  String? currentValue;

  ChapterAutoScrollController? scrollController;

  /// 学习记录=>滚动到具体位置
  /// 记录用户点击的资源条目以及所有父列表的条目
  Record? record;

  bool useRecord;

  ChapterPracticePage(this.courseId, this.subjectId, this.gradeId, {this.memoizer, this.scrollController,
    this.record,
    this.previewMode = false,
    this.useRecord = false,
  });

  @override
  State<StatefulWidget> createState() {
    return _ChapterPracticeState();
  }
}

class _ChapterPracticeState extends State<ChapterPracticePage> {
  AsyncMemoizer? memoizer;
  List<DataEntity>? detailData;
  ResourceIdListEntity? selectedRes;
  SelfStudyRecord? record;

  int? get lastResId => record?.id as int?;
  ChapterAutoScrollController? controller;
  ChapterAutoScrollController? outerController;

  /// 是否预览
  bool? previewMode;

  @override
  void initState() {
    super.initState();
    pageContext = context;
    outerController = widget.scrollController;
    controller = ChapterAutoScrollController();
    previewMode = widget.previewMode;
    if (!previewMode!) {
      _loadLocalStudyRecord();
    }
    memoizer = widget.memoizer ?? AsyncMemoizer();
  }

  @override
  dispose() {
    if (record != null) {
      record!.subjectId = widget.subjectId;
      record!.gradeId = widget.gradeId;
      saveRecord(record);
    }
    memoizer = null;
    super.dispose();
  }

  _getData(subjectId, gradeId, type) =>
      memoizer!.runOnce(() => _getAll(subjectId, gradeId, type));


  /// 读取本地历史学习记录
  _loadLocalStudyRecord() {
    var s = widget.useRecord ? SharedPrefsUtils.getString('chapter_record', '')! : '';
    Map<String, dynamic>? map;
    try {
      map = jsonDecode(s);
    } on Exception catch (e) {
      print("异常:$e");
    }
    if (map == null || !map.containsKey('type')) {
      record = SelfStudyRecord(type: 3, subjectId: widget.subjectId, gradeId: widget.gradeId, firstId: -1, secondId: -1, thirdId: -1, nodeName: "");
      return;
    }

    if (map['type'] == 3) {
      record = SelfStudyRecord.fromJson(map);
    } else {
      record = SelfStudyRecord(type: 3, subjectId: widget.subjectId, gradeId: widget.gradeId, firstId: -1, secondId: -1, thirdId: -1, nodeName: "");
    }
  }

  @override
  Widget build(BuildContext context) {
    return StoreBuilder(builder: (BuildContext context, Store<AppState> store) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text("章节练习"),
        ),
        body: _buildWidget(),
      );
    });
  }

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
        if (snapshot.hasError) return Text('Error: ${snapshot.error}');
        var material = snapshot.data['material'];
        var list = snapshot.data['list'];
        var model = list.model as WisdomModel?;
        var materialModel = material as MaterialDataEntity?;
        detailData = model?.data;
        if (detailData == null) {
          return EmptyPlaceholderPage(assetsPath: 'static/images/empty.png', message: '没有数据');
        }
        if (model!.code == 1 && detailData != null) {
          return _buildList(materialModel, detailData!);
        }
        return Column(
          children: [
            Container(
                height: 74,
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: _chapterBuildChooseMaterial(materialModel)),
            EmptyPlaceholderPage(assetsPath: 'static/images/empty.png', message: '没有数据'),
          ],
        );
      default:
        return EmptyPlaceholderPage(assetsPath: 'static/images/empty.png', message: '没有数据');
    }
  }

  Widget _buildWidget() {
    return FutureBuilder(
      builder: _futureBuilder,
      future: _getData(widget.subjectId, widget.gradeId, widget.type),
    );
  }

  ///
  /// @description 构建外层列表
  /// @param
  /// @return 
  /// @author waitwalker
  /// @time 4/7/21 2:55 PM
  ///
  Widget _buildList(MaterialDataEntity? materialModel, List<DataEntity> data) {

    /// 这个函数，用来自动滚动到树形菜单的某一项，滚动距离通过计算得出，不同屏幕有误差
    var scrollToViewport = () =>
        SchedulerBinding.instance!.addPostFrameCallback((d) {
          debugLog('++++++++$d');
          int listTileHeight = 44;
          int firstIndex =
          detailData!.indexWhere((item) => item.nodeId == record?.firstId);
          if (firstIndex == -1) return;
          int secondIndex = detailData![firstIndex]
              .nodeList
              ?.indexWhere((item) => item.nodeId == record?.secondId) ??
              -1;
          int thirdIndex = secondIndex == -1
              ? -1
              : detailData![firstIndex]
              .nodeList![secondIndex]
              .nodeList
              ?.indexWhere((item) => item.nodeId == record?.thirdId) ??
              -1;

          var lastList = secondIndex == -1
              ? detailData![firstIndex]
              : thirdIndex == -1
              ? detailData![firstIndex].nodeList![secondIndex]
              : detailData![firstIndex]
              .nodeList![secondIndex]
              .nodeList![thirdIndex];

          int resIndex = lastList.resourceIdList!
              .indexWhere((item) => item.resId == record?.id);
          double lines = (firstIndex + 1) * (listTileHeight + 10.0) +
              (secondIndex + 1 + thirdIndex + 1) * listTileHeight +
              (resIndex) * 64 + 20 - 74; // 悬浮在顶部的选择教材栏的高度，需要减去，防止覆盖到当前高亮条目
          controller!.animateTo(lines,
              duration: Duration(seconds: 1), curve: Curves.ease);
          controller!.highlight(record?.firstId as int?);
        });
    record != null && detailData!.indexWhere((i) => record?.firstId == i.nodeId) != -1 ?
    scrollToViewport() :
    // ignore: unnecessary_statements
    null;
    return Column(
      children: <Widget>[
        Divider(height: 0.5),
        materialModel == null
            ? const SizedBox()
            : Stack(alignment: Alignment.bottomCenter, children: <Widget>[
          Positioned(
              child: Container(
                height: 32,
                color: Colors.white,
              )),
          Container(
              height: 74,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: _chapterBuildChooseMaterial(materialModel))
        ]),
        Flexible(
          flex: 1,
          child: ListView.separated(
            itemCount: data.length,
            controller: controller,
            separatorBuilder: (BuildContext context, int index) => Divider(color: Colors.transparent, height: 2),
            itemBuilder: (BuildContext context, int index) => EntryItem(
                data[index],
                selectedItem: this.selectedRes,
                scrollController: widget.scrollController,
                previewMode: widget.previewMode,
                firstItem: index == 0,
                record: record,
                itemOnPress: (dataEntity){
                  print("current index:$index");
                  DataEntity currentDataEntity = data[index];
                  record!.firstId = currentDataEntity.nodeId;
                  if (dataEntity?.level == 2) {
                    for (int i = 0; i < currentDataEntity.nodeList!.length; i++) {
                      DataEntity tmpDataEntity = currentDataEntity.nodeList![i];
                      if (tmpDataEntity.nodeId == dataEntity?.nodeId) {
                        record!.secondId = dataEntity?.nodeId;
                        record!.thirdId = -1;
                      }
                    }
                  }

                  if (dataEntity?.level == 3) {
                    for (int i = 0; i < currentDataEntity.nodeList!.length; i++) {
                      DataEntity tmpDataEntity = currentDataEntity.nodeList![i];
                      if (tmpDataEntity.nodeList != null && tmpDataEntity.nodeList!.length > 0) {
                        for (int j = 0; j < tmpDataEntity.nodeList!.length; j++) {
                          DataEntity thirdLevelDataEntity = tmpDataEntity.nodeList![j];
                          if (thirdLevelDataEntity.nodeId == dataEntity?.nodeId) {
                            record!.secondId = tmpDataEntity.nodeId;
                            record!.thirdId = thirdLevelDataEntity.nodeId;
                          }
                        }
                      }
                    }
                  }
                  record!.id = -1;
                  record!.courseId = -1;
                  record!.title = dataEntity?.nodeName;
                  if (record != null) {
                    saveRecord(record);
                    debugLog(record);
                    setState(() {});
                  }
                  print("点击了知识点或者节了");

                  Navigator.of(context).push(MaterialPageRoute(builder: (_) {
                    var token = NetworkManager.getAuthorization();
                    var versionId = materialModel!.defVersionId;
                    var subjectId = materialModel.subjectId;

                    var url = APIConst.chapter;
                    String fullURL = '$url?token=$token&subjectid=${widget.subjectId}&pointid=${dataEntity?.nodeId}&cname=${dataEntity?.nodeName}&courseid=${widget.courseId}';
                    /// 跳转到AI详情页面
                    return AIWebPage(
                      currentDirId: dataEntity?.nodeId.toString(),
                      versionId: versionId.toString(),
                      subjectId: subjectId.toString(),
                      initialUrl: fullURL,
                      title: dataEntity?.nodeName,
                      showTimeCount: false,
                    );
                  })).then((_) {
                    setState(() {
                      memoizer = memoizer = AsyncMemoizer();
                    });
                  });
                }
            ),
          ),
        )
      ],
    );
  }

  ///
  /// @description 章节/复习模式选择教材版本
  /// @param
  /// @return
  /// @author waitwalker
  /// @time 3/11/21 1:49 PM
  ///
  Container _chapterBuildChooseMaterial(MaterialDataEntity? materialModel) {
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
                  style: TextStyle(color: Colors.black, fontSize: SingletonManager.sharedInstance!.screenWidth > 500.0 ? 18 : 14, fontWeight: FontWeight.w600))),
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
                  Text('切换', style: TextStyle(fontSize: SingletonManager.sharedInstance!.screenWidth > 500.0 ? 13 : 11, color: Color(0xFF384A69)))
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
                widget.memoizer = memoizer = AsyncMemoizer();
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

  ///
  /// @description 获取所有数据
  /// @param
  /// @return
  /// @author waitwalker
  /// @time 4/13/21 4:18 PM
  ///
  _getAll(subjectId, gradeId, type) async {
    var response = await MaterialDao.material(subjectId, gradeId, type);
    if (response.result && response.model.code == 1) {
      var materialId = (response.model as MaterialModel).data!.defMaterialId;
      var materialModel = response.model.data;
      if (this.mounted) {
        setState(() {});
      }
      return DaoManager.fetchIntelligenceChapterList(materialId).then((t) => {'material': materialModel, 'list': t});
    }
    return Future.error('获取教材信息失败');
  }
}

typedef void OnPress(item, [DataEntity? parent]);
typedef void ItemOnPressCallBack(DataEntity? dataEntity);
BuildContext? pageContext;

/// Displays one Entry. If the entry has children then it's displayed
/// with an ExpansionTile.
/// 文档 https://flutterchina.club/catalog/samples/expansion-tile-sample/
// ignore: must_be_immutable
class EntryItem extends StatelessWidget {
  ItemOnPressCallBack? itemOnPress;
  final DataEntity entry;

  var selectedItem;
  ChapterAutoScrollController? scrollController;

  SelfStudyRecord? record;
  bool? previewMode;
  bool firstItem;

  /// 构造方法
  EntryItem(this.entry, {this.selectedItem, this.scrollController, this.record, this.firstItem = false, this.previewMode = false, this.itemOnPress});

  Widget _buildTiles(DataEntity root, {bool isFirst = false}) {
    if (root.level == 3) {
      return _buildResourceList(root, root.level as int,
        title: root.nodeName!,
        selectedItem: selectedItem,
        record: record,
        previewMode: previewMode!,
        isFirst: isFirst,
        itemOnPress: itemOnPress,
        scrollController: scrollController,
      );
    }

    /// 每一行，如果不是资源，是如下递归生成的树形菜单，
    /// [isFirst]，用于判断当前行是否是第一行，
    /// 注意，不只是当前行是第一行，他的上一层列表项，也必须是第一行
    /// 最终实现，第一章第一节第一知识点，下面的前2个资源免费体验
    List<Widget> children = root.nodeList
        ?.map((m) => _buildTiles(m, isFirst: root.nodeList!.indexOf(m) == 0&&isFirst))
        ?.toList() ??
        [];
    if (children.length == 0) {
      /// 章和节的直属资源
      if (root.resourceIdList?.isNotEmpty ?? false) {
        return _buildResourceList(root, root.level as int,
            title: root.nodeName!,
            selectedItem: selectedItem,
            record: record,
            previewMode: previewMode!,
            isFirst: isFirst,
            itemOnPress: itemOnPress,
            scrollController: scrollController);
      }
    } else if ((root.resourceIdList?.length ?? 0) != 0) {
      var buildResourceList = _buildResourceList(root, root.level as int,
          title: root.level == 1 ? '本章复习' : '本节复习',
          selectedItem: selectedItem,
          record: record,
          previewMode: previewMode!,
          itemOnPress: itemOnPress,
          scrollController: scrollController);
      children.add(buildResourceList);
    }
    Color color;
    bool expandOrNot = (previewMode! && isFirst) || (record?.firstId == root.nodeId || record?.secondId == root.nodeId || record?.thirdId == root.nodeId);
    color = expandOrNot ? Colors.orangeAccent : Colors.black;
    return ChapterAutoScrollTag(
      index: root.nodeId as int?,
      controller: scrollController,
      highlightColor: Color(MyColors.primaryValue),
      key: PageStorageKey<DataEntity>(root),
      child: Padding(
        padding: EdgeInsets.only(left: (root.level! - 1) * 10.0),
        child: InkWell(
          child: ChapterExpandedList(
            initiallyExpanded: expandOrNot,
            dataEntity: root,
            itemOnPress: itemOnPress,
            key: PageStorageKey<DataEntity>(root),
            title: Expanded(
              child: Text(
                root.nodeName!,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: color, fontSize: SingletonManager.sharedInstance!.screenWidth > 500.0 ? 18 : 14),
              ),
            ),
            children: children,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: _buildTiles(entry, isFirst: firstItem),
    );
  }
}

/// 资源列表，是树形列表的最里层
/// 树分4层，章 - 节 - 知识点 - 资源
/// 但是，并非所有资源都在知识点下，
/// 接口的数据，章、节都有直属资源，所以接口的数据，还需要简单洗一下：
/// 章下的资源，叫本章复习；节的叫本节复习
Widget _buildResourceList(DataEntity root, int level,
    {String title = '本节复习',
      selectedItem,
      ChapterAutoScrollController? scrollController,
      SelfStudyRecord? record,
      bool isFirst = false,
      ItemOnPressCallBack? itemOnPress,
      bool previewMode = false}) {
  if (level < 1 || level > 3) {
    throw FormatException('level must in [1,2,3]!');
  }

  bool expanded = (previewMode && isFirst) || (root.nodeId == record!.thirdId);
  Color color;
  color = expanded ? Colors.orangeAccent : Colors.black;
  Widget resWidget = Container(
    padding: EdgeInsets.only(left: 1 * 10.0),
    child: ChapterExpandedList(
      initiallyExpanded: expanded,
      key: PageStorageKey<DataEntity>(root),
      itemOnPress: itemOnPress,
      dataEntity: root,
      title: Expanded(
        child: Text(
          title,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: color, fontSize: SingletonManager.sharedInstance!.screenWidth > 500.0 ? 18 : 14),
        ),
      ),
      children: [],
    ),
  );
  return resWidget;
}

void saveRecord(record) {
  if (record != null && record.id != null && record.subjectId != null && record.gradeId != null && record.type != null && (record.title?.isNotEmpty ?? false)) {
    record.type = 3;
    debugLog(record.toString(), tag: 'save');
    SharedPrefsUtils.put('chapter_record', record.toString());
  }
}

