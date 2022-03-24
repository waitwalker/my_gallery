import 'dart:io';
import 'package:my_gallery/common/dao/manager/dao_manager.dart';
import 'package:my_gallery/common/network/error_code.dart';
import 'package:my_gallery/common/tools/screen_adapt/screen_utils.dart';
import 'package:my_gallery/event/card_activate_event.dart';
import 'package:my_gallery/modules/my_course/activity_course/college_entrance_model.dart';
import 'package:my_gallery/modules/widgets/empty_placeholder/empty_placeholder_widget.dart';
import 'package:my_gallery/modules/widgets/loading/list_type_loading_placehold_widget.dart';
import 'package:my_gallery/modules/widgets/style/style.dart';
import 'package:flutter/material.dart';
import 'package:async/async.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'micro_activity_detail_page.dart';

///
/// @name MicroActivityPage
/// @description 微课类型活动课
/// @author waitwalker
/// @date 2020-03-16
///
class MicroActivityPage extends StatefulWidget {
  final String title;
  final int tagId;
  MicroActivityPage(this.tagId,{this.title = "活动课"});

  @override
  State<StatefulWidget> createState() {
    return _MicroActivityState();
  }
}

class _MicroActivityState extends State<MicroActivityPage> with WidgetsBindingObserver{

  AsyncMemoizer memoizer = AsyncMemoizer();

  /// 活动课数据
  List<Data?>? dataSource;

  /// 活动课列表
  List subjectList = [];
  List<RegisterCourseList>? registerCourseList;

  @override
  void initState() {
    WidgetsBinding.instance!.addObserver(this);

    ErrorCode.eventBus.on().listen((e) {
      if (e is CollegeEntranceEvent) {
        CollegeEntranceEvent currentE = e;
        print("点击高考冲刺微课: ${currentE.message}");
        memoizer = AsyncMemoizer();
        setState(() {

        });
      }
    });
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(MicroActivityPage oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  void deactivate() {
    var bool = ModalRoute.of(context)!.isCurrent;

    if (bool) {
      print('返回主页');
    }

    super.deactivate();
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);

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

      setState(() {
        memoizer = AsyncMemoizer();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(),
      body: _future(),
    );
  }

  /// 导航栏
  _appBar() {
    return AppBar(
      title: Text(
        widget.title,
        style: TextStyle(fontSize: 20, color: MyColors.normalTextColor),
      ),
      backgroundColor: Color(MyColors.white),
      elevation: 1,

      ///阴影高度
      titleSpacing: 0,
      centerTitle: Platform.isIOS ? true : false,
    );
  }

  /// body
  _future() {
    return FutureBuilder(
      builder: _futureBuilder,
      future: _loadData([11]),
    );
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
        print(snapshot);

        if (snapshot.hasError)
          return EmptyPlaceholderPage(message: '网络请求失败', onPress: refresh);
        if (!snapshot.hasData || snapshot.data.model == null)
          return EmptyPlaceholderPage(assetsPath: 'static/images/empty.png', message: '没有数据');
        var activityCourseModel = snapshot.data.model as CollegeEntranceModel;
        dataSource = activityCourseModel.data;
        if (dataSource == null || dataSource!.isEmpty)
          return EmptyPlaceholderPage(assetsPath: 'static/images/empty.png', message: '没有数据');
        if (subjectList.length > 0) subjectList.clear();
        for (int i = 0; i< dataSource!.length; i++) {
          subjectList.add(dataSource![i]!.registerCourseList);
        }
        if (subjectList == null) return EmptyPlaceholderPage(assetsPath: 'static/images/empty.png', message: '没有数据');
        return _builderListView();
      default:
        return EmptyPlaceholderPage(assetsPath: 'static/images/empty.png', message: '没有数据');
    }
  }

  /// 获取数据
  refresh() {
    setState(() {
      memoizer = AsyncMemoizer();
    });
  }

  _loadData(List<int> grades) {
    return memoizer.runOnce(() => DaoManager.fetchCollegeEntrance({"tagId": widget.tagId}));
    //return memoizer.runOnce(() => ActivityCourseDao.fetch(grades));
  }

  Widget _builderListView() {
    return ListView.builder(
      itemBuilder: _itemBuilderContext,
      itemCount: subjectList.length,
    );
  }

  /// 活动课图片
  List<String> tmpImages = [
    "static/images/img_activity_banner01.png",
    "static/images/img_activity_banner02.png",
    "static/images/img_activity_banner03.png"
  ];

  /// 单个item
  Widget _itemBuilderContext(BuildContext context, int index) {
    var registerList = subjectList[index];
    String? imagePath;
    var registerCourse;
    if (registerList.length >0 ) {
      registerCourse = registerList[0];
      if (registerCourse.courseCover != null) {
        imagePath = registerCourse.courseCover;
      } else {
        imagePath = null;
      }
    } else {
      imagePath = null;
    }

    return GestureDetector(
      child: Padding(
        padding: EdgeInsets.only(top: 16, left: 16, right: 16),
        child: Hero(
            tag: 'hero_$index',
            child: Container(
              height: ScreenUtil.getInstance().setHeight(136),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(6.0)),
                  image: DecorationImage(image: (imagePath == null ? AssetImage(tmpImages[1]) : NetworkImage(imagePath)) as ImageProvider<Object>, fit: BoxFit.fill),),
            )),
      ),
      onTap: () {
        if (registerCourse != null) {
          Navigator.of(context).push(MaterialPageRoute(builder: (_) {
            return MicroActivityDetailPage(
                courses: registerCourse?.courseList,
                showAll: registerCourse?.signUp == 1,
                courseContent: registerCourse?.courseContent,
                banner: imagePath,
                index: index,
                title: widget.title,
            );
          })).then((value) => (){
            setState(() {
              memoizer = AsyncMemoizer();
            });
          });
        } else {
          Fluttertoast.showToast(msg: "没有相关课程!");
        }

      },
    );
  }

}

