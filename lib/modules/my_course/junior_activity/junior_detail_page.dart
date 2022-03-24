import 'dart:io';
import 'package:my_gallery/common/dao/manager/dao_manager.dart';
import 'package:my_gallery/common/dao/original_dao/analysis.dart';
import 'package:my_gallery/common/dao/original_dao/course_dao_manager.dart';
import 'package:my_gallery/common/network/response.dart';
import 'package:my_gallery/common/tools/screen_adapt/screen_utils.dart';
import 'package:my_gallery/model/micro_course_resource_model.dart';
import 'package:my_gallery/modules/my_course/activity_course/college_entrance_model.dart';
import 'package:my_gallery/modules/my_course/wisdom_study/micro_course_page.dart';
import 'package:my_gallery/modules/widgets/alert/activity_alert.dart';
import 'package:my_gallery/modules/widgets/empty_placeholder/empty_placeholder_widget.dart';
import 'package:my_gallery/modules/widgets/style/style.dart';
import 'package:flutter/material.dart';
import 'package:async/async.dart';
import 'package:path_drawing/path_drawing.dart';

///
/// @name JuniorGradePage
/// @description 复课衔接强化课 详情
/// @author waitwalker
/// @date 2020/5/28
///
class JuniorDetailPage extends StatefulWidget {
  final int? tagId;
  JuniorDetailPage(this.tagId);
  @override
  State<StatefulWidget> createState() {
    return _JuniorDetailState();
  }
}

class _JuniorDetailState extends State<JuniorDetailPage> {
  AsyncMemoizer memoizer = AsyncMemoizer();
  String? title = "活动课";
  // 学科列表
  List<Data?>? subjectList = [];

  // 当前学科下版本
  Data? currentSubject;
  
  // 当前学科版本列表
  List<RegisterCourseList> currentSubjectRegisterCourseList = [];

  // 当前版本下的课
  RegisterCourseList? currentCourse;

  // 课详情列表
  List<CourseList> courseList = [];

  int currentSection = 0;
  int currentRow = 0;

  // 是否正在加载
  bool isLoading = true;
  bool haveData = true;

  int maxLine = 2;

  @override
  void initState() {
    _fetchData();
    super.initState();
  }

  // 加载数据
  _fetchData() async{
    ResponseData responseData = await DaoManager.fetchCollegeEntrance({"tagId": widget.tagId});
    isLoading = false;
    CollegeEntranceModel? activityCourseModel = responseData.model as CollegeEntranceModel?;
    if (activityCourseModel == null || activityCourseModel.data == null || activityCourseModel.data!.length == 0 ) {
      haveData = false;
      setState(() {

      });
      return;
    }
    subjectList = activityCourseModel.data;

    if (subjectList![0]!.registerCourseList == null || subjectList![0]!.registerCourseList!.length == 0) {
      haveData = false;
      setState(() {

      });
      return;
    }

    currentSubject = subjectList![0];

    // 先操作下层级的数据
    currentCourse = currentSubject!.registerCourseList![0];
    currentCourse!.isSelected = true;
    currentSubject!.registerCourseList![0] = currentCourse;

    // 在操作上一层级数据
    currentSubject!.isSelected = true;
    subjectList![0] = currentSubject;
    title = currentCourse!.registerCourseName;
    currentSection = 0;
    setState(() {

    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(),
      body: _buildContentWidget(),
    );
  }

  _buildContentWidget() {
    if (isLoading) {
      return Center(
        child: CircularProgressIndicator(),
      );
    } else {
      if (haveData) {
        return _buildContent();
      } else {
        return EmptyPlaceholderPage(assetsPath: 'static/images/empty.png', message: '没有数据');
      }
    }
  }

  /// 导航栏
  _appBar() {
    return AppBar(
      title: Text(
        title!,
        style: TextStyle(fontSize: 20, color: MyColors.normalTextColor),
      ),
      backgroundColor: Color(MyColors.white),
      elevation: 1,

      ///阴影高度
      titleSpacing: 0,
      centerTitle: Platform.isIOS ? true : false,
    );
  }

  // 构建内容
  _buildContent() {
    return SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(children: <Widget>[
          // 上部图片
          Hero(
            tag: 'hero_${widget.tagId}',
            child: Container(
              height: ScreenUtil.getInstance().setHeight(149),
              decoration: BoxDecoration(image: DecorationImage(image:AssetImage('static/images/j_detail_to.png'), fit: BoxFit.fill,),),
            ),
          ),
          Padding(padding: EdgeInsets.only(top: 20)),
          Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(padding: EdgeInsets.only(top: 10)),
                Padding(padding: EdgeInsets.only(left: 21),
                  child: Text("学科",style: TextStyle(fontSize: 16,color: Color(0xff3A3A3A)),),
                ),
                Container(
                  height: 55,
                  child: _buildSubjectList(),
                ),
                Padding(padding: EdgeInsets.only(top: 0)),
                Padding(padding: EdgeInsets.only(left: 21),
                  child: Text("版本",style: TextStyle(fontSize: 16,color: Color(0xff3A3A3A)),),
                ),
                Container(
                  height: 50,
                  child: _buildRegisterCourseList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Image.asset('static/images/img_activity_detail_label_introduction.png', width: 248, height: 26),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(
                    Radius.circular(0),
                  ),
                  boxShadow: [BoxShadow(color: Color(MyColors.shadow), offset: Offset(0, 2), blurRadius: 10.0, spreadRadius: 2.0)],
                ),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(0),),
                          border: Border.all(width: 2, color: Color(MyColors.courseScheduleCardLight)),
                        ),
                        child: Text(currentCourse!.courseContent!, style: TextStyle(color: Color(MyColors.courseScheduleCardLight), fontSize: 12,), maxLines: maxLine),
                      ),
                      const SizedBox(height: 4),
                      if (maxLine == 2)
                        InkWell(
                            child: Container(alignment: Alignment.center, child: Text('查看更多'),),
                            onTap: () {
                              maxLine = 1000;
                              setState(() {});
                            }),
                    ])),
          ),
          const SizedBox(height: 30),
          Image.asset('static/images/img_activity_detail_label_list.png', width: 248, height: 26),
          _buildList(),
        ]));
  }

  // 学科横向列表
  _buildSubjectList() {
    return Padding(padding: EdgeInsets.only(left: 21,right: 21),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Expanded(child: ListView.builder(scrollDirection: Axis.horizontal,itemBuilder: _subjectItemBuild,itemCount: subjectList!.length,))
        ],
      ),
    );
  }

  Widget _subjectItemBuild(BuildContext context, int index){
    Data subject = subjectList![index]!;
    if (subject.registerCourseList == null || subject.registerCourseList!.length == 0) return Container();
    return Column(
      children: <Widget>[
        Padding(padding: EdgeInsets.only(top: 10)),

        Padding(padding: EdgeInsets.only(right: 13.5,),

          child: Container(
            height: 24,
            child: ElevatedButton(
              onPressed: () {
                print("点击当前学科:${subject.subjectName}");
                // 点击学科的时候先将学科&课程的是否选中清空
                // 将课程默认选中第一个
                // 将学科选中index个
                List<Data?> tmpData = [];
                for(int i = 0; i < subjectList!.length; i++){
                  Data theData = subjectList![i]!;
                  theData.isSelected = false;
                  List<RegisterCourseList> theVersions = [];
                  for(int j = 0; j < theData.registerCourseList!.length; j++) {
                    RegisterCourseList theVersion = theData.registerCourseList![j]!;
                    theVersion.isSelected = false;
                    theVersions.add(theVersion);
                  }
                  tmpData.add(theData);
                }
                subjectList = tmpData;
                currentSubject = subject;
                // 先操作下层级的数据
                currentCourse = currentSubject!.registerCourseList![0];
                currentCourse!.isSelected = true;
                currentSubject!.registerCourseList![0] = currentCourse;

                // 在操作上一层级数据
                currentSubject!.isSelected = true;
                subjectList![index] = currentSubject;

                title = currentCourse!.registerCourseName;
                maxLine = 2;
                currentSection = index;
                setState(() {

                });
              },
              child: Text("${subject.subjectName}",style: TextStyle(fontSize: 13,color: subject.isSelected ? Color(0xffFFFFFF) : Color(0xff3A3A3A)),),
              style: ButtonStyle(
                backgroundColor: ButtonStyleButton.allOrNull<Color>(subject.isSelected ? Color(0xff5E66EB) : Color(0xffF2F7FF)),
              ),
            ),
          ),),
        Padding(padding: EdgeInsets.only(top: 5)),
      ],
    );
  }

  // 版本横向列表
  _buildRegisterCourseList() {
    return Padding(padding: EdgeInsets.only(left: 21,right: 21),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Expanded(child: ListView.builder(scrollDirection: Axis.horizontal,itemBuilder: _registerItemBuild,itemCount: currentSubject!.registerCourseList!.length,))
        ],
      ),
    );
  }

  Widget _registerItemBuild(BuildContext context, int index){
    RegisterCourseList version = currentSubject!.registerCourseList![index]!;
    return Column(
      children: <Widget>[
        Padding(padding: EdgeInsets.only(top: 10)),
        Padding(padding: EdgeInsets.only(right: 13.5,),
          child: Container(
            height: 24,
            child: ElevatedButton(
              style: ButtonStyle(
                backgroundColor: ButtonStyleButton.allOrNull<Color>(version.isSelected ? Color(0xff5E66EB) : Color(0xffF2F7FF)),
              ),
                child: Text(
                  "${version.registerCourseName}",
                  style: TextStyle(
                    fontSize: 13,
                    color: version.isSelected ? Color(0xffFFFFFF) : Color(0xff3A3A3A),),),
                onPressed: (){
              // 课程被点击现将课程对应的选中全部清空
              // 将当前选中课程置为选中状态
              // 刷新课程中index对应的课程
              // 刷新current section对应的学科
              List<RegisterCourseList?> theVersions = [];
              for(int j = 0;j < currentSubject!.registerCourseList!.length; j++){
                RegisterCourseList theVersion = currentSubject!.registerCourseList![j]!;
                theVersion.isSelected = false;
                theVersions.add(theVersion);
              }
              RegisterCourseList currentV = version;
              currentV.isSelected = true;
              theVersions[index] = currentV;
              currentCourse = currentV;
              title = currentCourse!.registerCourseName;
              currentSubject!.registerCourseList = theVersions;
              subjectList![currentSection] = currentSubject;
              setState(() {

              });
            }),
          ),),
        Padding(padding: EdgeInsets.only(top: 5)),
      ],
    );
  }

  _buildList() {
    var courses = currentCourse!.courseList;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(0),), boxShadow: [BoxShadow(color: Color(MyColors.shadow), offset: Offset(0, 2), blurRadius: 10.0, spreadRadius: 2.0),],),
        child: ListView.separated(
          physics: NeverScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(vertical: 16),
          shrinkWrap: true,
          itemCount: courses?.length ?? 0,
          itemBuilder: _itemBuilder,
          separatorBuilder: (BuildContext context, int index) {
            return Container(
                  height: 9,
                  child: CustomPaint(
                      painter: DashPathPainter(
                          path: Path()
                            ..moveTo(0.0, 0.0)
                            ..lineTo(
                                MediaQuery.of(context).size.width - 64, 0.0),
                          painter: Paint()
                            ..style = PaintingStyle.stroke
                            ..strokeWidth = 1.0
                            ..color = Color(MyColors.courseScheduleCardLight))),
                );
            },
        ),
      ),
    );
  }

  Widget _itemBuilder(BuildContext context, int index) {
    return _buildCurrentItem(index);
  }

  _buildCurrentItem(int index) {
    var courses = currentCourse!.courseList!;
    var course = courses[index];
    var show = currentCourse!.signUp == 1 ? true : false;
    int? hasStudy = course.hasStudy;
    if (show == true) {
      return InkWell(
        child: Column(
          children: <Widget>[
            Padding(padding: EdgeInsets.only(left: 16, right: 16, top: 6,bottom: 6),
              child: Container(
                color: Colors.white,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Icon(Icons.check_circle,color: hasStudy == 1 ? Color(0xFFF87F39) : Colors.grey,size: 20,),
                        Padding(padding: EdgeInsets.only(left: 10)),
                        Container(
                          width: MediaQuery.of(context).size.width - 16 * 2 - 20 - 20 - 70,
                          child: Text(
                            courses[index].onlineCourseTitle!,
                            style: TextStyle(color: Color(0xFFF87F39), fontSize: 16,),
                            maxLines: 3,
                          ),
                        ),
                      ],
                    ),

                    Row(
                      children: <Widget>[
                        Icon(Icons.play_circle_filled,size: 20,color: Color(0xffF87F39),),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        onTap: (){
          _onTapItem(course,index: index,courses: courses);
        },
      );
    } else {
      int? isFree = course.isFree;
      return InkWell(
        child: Column(
          children: <Widget>[
            Padding(padding: EdgeInsets.only(left: 16, right: 16, top: 6,bottom: 6),
              child: Container(
                color: Colors.white,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Icon(Icons.check_circle,color: hasStudy == 1 ? Color(0xFFF87F39) : Colors.grey,size: 20,),
                        Padding(padding: EdgeInsets.only(left: 20)),
                        Container(
                          width: MediaQuery.of(context).size.width - 16 * 2 - 20 - 20 - 70,
                          child: Text(
                            courses[index].onlineCourseTitle!,
                            style: TextStyle(color: Color(0xFFF87F39), fontSize: 16,),
                            maxLines: 3,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: <Widget>[
                        Icon(isFree == 1 ? Icons.play_circle_filled : Icons.lock,size: 20,color: Color(0xc8F87F39),),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        onTap: (){
          if (isFree == 1) {
            _onTapItem(course,index: index, courses: courses);
          } else {
            _onTapItemLocked();
          }
        },
      );
    }
  }

  _onTapItemLocked() {
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

  void _onTapItem(CourseList course,{required List<CourseList> courses,required int index}) async {
    /// 微课
    var microCourseResourceInfo = await CourseDaoManager.getMicroCourseResourceInfo(course.resourceId);

    /// 记录已学
    AnalysisDao.log(0, 0, 2, course.resourceId);
    CourseList currentCourse = courses[index];
    if (currentCourse.hasStudy == 0) {
      currentCourse.hasStudy = 1;
      setState(() {

      });
    }
    if (microCourseResourceInfo.result) {
      MicroCourseResourceModel model = microCourseResourceInfo.model as MicroCourseResourceModel;
      _toMicroCourse(model.data, course.onlineCourseId, course.onlineCourseTitle);
    }
  }

  /// 跳转到微课详情
  void _toMicroCourse(
      MicroCourseResourceDataEntity? data, dynamic courseId, String? nodeName) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) {
      return MicroCoursePage(data, courseId: courseId, from: nodeName,fromCollegeEntrance: true,hideXueAn: true,);
    }));
  }
}

class DashPathPainter extends CustomPainter {
  Path? path;

  Paint? painter = Paint()
    ..color = Colors.black
    ..strokeWidth = 1.0
    ..style = PaintingStyle.stroke;

  DashPathPainter({this.path, this.painter});

  @override
  bool shouldRepaint(DashPathPainter oldDelegate) => true;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawPath(
        dashPath(
          path!,
          dashArray: CircularIntervalList<double>(
            <double>[5.0, 2.5],
          ),
        ),
        painter!);
  }
}

final Paint black = Paint()
  ..color = Colors.black
  ..strokeWidth = 1.0
  ..style = PaintingStyle.stroke;