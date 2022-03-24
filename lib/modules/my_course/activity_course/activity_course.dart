import 'dart:io';
import 'package:my_gallery/common/config/config.dart';
import 'package:my_gallery/common/dao/original_dao/activity_course_dao.dart';
import 'package:my_gallery/common/network/network_manager.dart';
import 'package:my_gallery/common/singleton/singleton_manager.dart';
import 'package:my_gallery/model/activity_course_model.dart';
import 'package:my_gallery/modules/my_course/junior_activity/junior_grade_page.dart';
import 'package:my_gallery/modules/my_course/micro_activity/micro_activity_page.dart';
import 'package:my_gallery/modules/widgets/webviews/common_webview_page.dart';
import 'package:my_gallery/modules/widgets/loading/list_type_loading_placehold_widget.dart';
import 'package:my_gallery/modules/widgets/style/style.dart';
import 'package:my_gallery/modules/widgets/alert/activity_alert.dart';
import 'package:my_gallery/modules/widgets/empty_placeholder/empty_placeholder_widget.dart';
import 'package:my_gallery/common/tools/screen_adapt/screen_utils.dart';
import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'activity_course_detail_page.dart';

///
/// @name ActivityCourse
/// @description 活动课
/// @author waitwalker
/// @date 2020-01-10
///
class ActivityCourse extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ActivityCourseState();
  }
}

class _ActivityCourseState extends State<ActivityCourse> {
  AsyncMemoizer memoizer = AsyncMemoizer();

  /// 活动课数据
  List<DataEntity>? dataSource;

  /// 活动课列表
  List<RegisterCourseListEntity>? registerCourseList;

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
        "活动课",
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
          return Text('Error: 没有数据');
        var activityCourseModel = snapshot.data.model as ActivityCourseModel;
        dataSource = activityCourseModel.data;
        if (dataSource == null || dataSource!.isEmpty)
          return EmptyPlaceholderPage(
              assetsPath: 'static/images/empty.png', message: '没有数据');
        registerCourseList = dataSource![0].registerCourseList;
        // 2021高考高分突围课
        registerCourseList!.insert(0, RegisterCourseListEntity());
        // 李雄阅读
        registerCourseList!.insert(0, RegisterCourseListEntity());
        // 复课衔接
        registerCourseList!.insert(0, RegisterCourseListEntity());

        // 高考冲刺
        //registerCourseList.insert(0, RegisterCourseListEntity());
        // 联通
        //registerCourseList.insert(0, RegisterCourseListEntity());
        if (registerCourseList == null) return Text('Error: 没有数据');
        return _builderListView();
      default:
        return EmptyPlaceholderPage(
            assetsPath: 'static/images/empty.png', message: '没有数据');
    }
  }

  /// 获取数据
  refresh() {
    setState(() {
      memoizer = AsyncMemoizer();
    });
  }

  _loadData(List<int> grades) {
    return memoizer.runOnce(() => ActivityCourseDao.fetch(grades));
  }

  Widget _builderListView() {
    return ListView.builder(
      itemBuilder: _itemBuilder,
      itemCount: registerCourseList!.length,
    );
  }

  /// 活动课图片
  List<String> tmpImages = [
    "static/images/img_activity_banner01.png",
    "static/images/img_activity_banner02.png",
    "static/images/img_activity_banner03.png"
  ];

  List<String> staticImages = [
    "static/images/c_entrance_home_banner_2021.png", //高分突围课
    "static/images/r_home_banner.png", //理性阅读
    "static/images/j_home_banner.png", //复课衔接
  ];

  /// 单个item
  Widget _itemBuilder(BuildContext context, int index) {

    // 前面几个的点击事件
    if (index < 3) {
      return GestureDetector(
        child: Padding(
          padding: EdgeInsets.only(top: 16, left: 16, right: 16),
          child: Hero(
              tag: 'hero_$index',
              child: Container(
                height: SingletonManager.sharedInstance!.screenHeight > 1000 ? ScreenUtil.getInstance().setHeight(156) :ScreenUtil.getInstance().setHeight(136),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(6.0)),
                    image: DecorationImage(
                        image: AssetImage(staticImages[index]), fit: BoxFit.fill)),
              )),
        ),
        onTap: () {
          if (index == 5000) {
            //Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => UnionGradePage()));
            var token = NetworkManager.getAuthorization();
            String url = Config.DEBUG ? "http://huodongt.etiantian.com/activity01/zhongkaom.html?token=" : "https://huodong.etiantian.com/liantong/indexm.html?token=";
            String fullUrl = "$url$token";
            Navigator.of(context).push(MaterialPageRoute(builder: (_) {
              return CommonWebviewPage(initialUrl: fullUrl, title: "中国联通·北京四中网校名师课堂",);
            }));
          } else if (index == 1) {
            var token = NetworkManager.getAuthorization();
            String url = Config.DEBUG ? "http://huodongt.etiantian.com/activity01/zhongkaom.html?token=" : "https://huodong.etiantian.com/activity01/zhongkaom.html?token=";
            String fullUrl = "$url$token";
            Navigator.of(context).push(MaterialPageRoute(builder: (_) {
              return CommonWebviewPage(initialUrl: fullUrl, title: "中考阅读活动课",
              );
            }));
          } else if (index == 2) {
            Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => JuniorGradePage()));
          } else if (index == 0) {
            var token = NetworkManager.getAuthorization();
            String url = Config.DEBUG ? "http://huodongt.etiantian.com/gaokao/2021/indexm.html?token=" : "http://huodong.etiantian.com/gaokao/2021/indexm.html?token=";
            String fullUrl = "$url$token";
            Navigator.of(context).push(MaterialPageRoute(builder: (_) {
              return CommonWebviewPage(initialUrl: fullUrl, title: "2021高考高分突围课",);
            }));
          }
        },
      );
    } else {
      var course = registerCourseList![index];
      String imagePath = course.courseCover ?? tmpImages[1];
      return GestureDetector(
        child: Padding(
          padding: EdgeInsets.only(top: 16, left: 16, right: 16),
          child: Hero(
              tag: 'hero_$index',
              child: Container(
                height: SingletonManager.sharedInstance!.screenHeight > 1000 ? ScreenUtil.getInstance().setHeight(156) :ScreenUtil.getInstance().setHeight(136),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(6.0)),
                    image: DecorationImage(
                        image: (course.courseCover == null ? AssetImage(imagePath) : NetworkImage(imagePath)) as ImageProvider<Object>, fit: BoxFit.fill)),
              )),
        ),
        onTap: () {
          var allowDetail = course.activityCourseSwitchStatus == 1;
          if (allowDetail) {
            if (course.registerCourseId == 100373643326) {
              var token = NetworkManager.getAuthorization();
              String url = Config.DEBUG ? "http://huodongt.etiantian.com/activity01/mobile10.html?token=" : "https://huodong.etiantian.com/activity01/mobile10.html?token=";
              String fullUrl = "$url$token";
              Navigator.of(context).push(MaterialPageRoute(builder: (_) {
                return CommonWebviewPage(initialUrl: fullUrl, title: "小升初暑期课程--语文",);
              }));
            } else if (course.registerCourseId == 100371858410) {
              var token = NetworkManager.getAuthorization();
              String url = Config.DEBUG ? "http://huodongt.etiantian.com/activity01/mobile11.html?token=" : "https://huodong.etiantian.com/activity01/mobile11.html?token=";
              String fullUrl = "$url$token";
              Navigator.of(context).push(MaterialPageRoute(builder: (_) {
                return CommonWebviewPage(initialUrl: fullUrl, title: "小升初暑期课程--数学",);
              }));
            } else if (course.registerCourseId == 100371845516) {
              var token = NetworkManager.getAuthorization();
              String url = Config.DEBUG ? "http://huodongt.etiantian.com/activity01/mobile12.html?token=" : "https://huodong.etiantian.com/activity01/mobile12.html?token=";
              String fullUrl = "$url$token";
              Navigator.of(context).push(MaterialPageRoute(builder: (_) {
                return CommonWebviewPage(initialUrl: fullUrl, title: "小升初暑期课程--英语",);
              }));
            } else {
              Navigator.of(context).push(MaterialPageRoute(builder: (_) {
                return ActivityCourseDetailPage(
                    courses: course.courseList,
                    courseId: course.registerCourseId.toString(),
                    showAll: course.signUp == 1,
                    courseContent: course.courseContent,
                    banner: imagePath,
                    index: index);
              }));
            }
          } else {
            showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) {
                  return ActivityCourseAlert(
                    tapCallBack: () {
                      Navigator.of(context).pop();
                    },
                  );
                });
          }
        },
      );
    }
  }
}
