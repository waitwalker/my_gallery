//  Copyright (c) 2019 Aleksander Woźniak
//  Licensed under Apache License v2.0
import 'dart:convert';
import 'dart:io';
import 'package:date_format/date_format.dart';
import 'package:my_gallery/common/dao/original_dao/course_dao_manager.dart';
import 'package:my_gallery/common/network/response.dart';
import 'package:my_gallery/model/login_model.dart';
import 'package:my_gallery/model/live_detail_model.dart';
import 'package:my_gallery/modules/my_course/live/live_status_button.dart';
import 'package:my_gallery/common/const/api_const.dart';
import 'package:my_gallery/modules/widgets/webviews/common_webview_page.dart';
import 'package:my_gallery/modules/widgets/empty_placeholder/empty_placeholder_widget.dart';
import 'package:my_gallery/modules/widgets/style/style.dart';
import 'package:my_gallery/common/tools/share_preference/share_preference.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

///
/// @name ClassSchedulePage
/// @description 课程表
/// @author waitwalker
/// @date 2020-01-10
///
class ClassSchedulePage extends StatefulWidget {
  final num? subjectId;
  final num? courseId;
  final String? title;

  ClassSchedulePage({Key? key, this.title, this.subjectId, this.courseId}) : super(key: key);

  @override
  _ClassSchedulePageState createState() => _ClassSchedulePageState();
}

class _ClassSchedulePageState extends State<ClassSchedulePage> with TickerProviderStateMixin {

  List? get _selectedEvents => detailData?.liveCourseResultDTOList?.where(startTimeIsSelectDay)?.toList();
  late AnimationController _animationController;

  DataEntity? detailData;
  DateTime _selectedDay = DateTime.now();
  late DateTime _selectedMonthFirstDay;

  /// 是否正在下载
  bool isLoading = true;
  /// 是否有错误
  bool hasError = false;

  DateTime _focusedDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _selectedMonthFirstDay = _selectedDay;
    _animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 400),);
    _animationController.forward();
    print(daysInMonth(_selectedDay));

    DateTime firstDate = DateTime(_selectedDay.year, _selectedDay.month, 0);
    DateTime lastDate = DateTime(_selectedDay.year, _selectedDay.month, daysInMonth(_selectedDay));
    print(lastDate);
    _fetchSelectMonthData(firstDate, lastDate);
  }

  ///
  /// @description 获取当月天数
  /// @param
  /// @return
  /// @author waitwalker
  /// @time 1/5/21 10:41 AM
  ///
  int daysInMonth(DateTime date){
    var firstDayThisMonth = new DateTime(date.year, date.month, date.day);
    var firstDayNextMonth = new DateTime(firstDayThisMonth.year, firstDayThisMonth.month + 1, firstDayThisMonth.day);
    int days = firstDayNextMonth.difference(firstDayThisMonth).inDays;
    print("当前月:$date, 当前月天数:$days");
    return days;
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("课程表"),
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: Platform.isIOS ? true : false,
      ),
      backgroundColor: Color(MyColors.background),
      body: buildContent(),
    );
  }


  ///
  /// @description 获取选择的当前月数据
  /// @param
  /// @return
  /// @author waitwalker
  /// @time 1/5/21 10:50 AM
  ///
  _fetchSelectMonthData(DateTime firstDate, DateTime lastDate) async {
    ResponseData responseData = await CourseDaoManager.liveSchedule(
        DateFormat('yyyy-MM-dd').format(DateTime(firstDate.year, firstDate.month, firstDate.day)),
        DateFormat('yyyy-MM-dd').format(DateTime(lastDate.year, lastDate.month, lastDate.day)));
    isLoading = false;
    if (responseData.code == 200) {
      var liveDetailModel = responseData.model as LiveDetailModel;
      detailData = liveDetailModel.data;
    } else {
      detailData = null;
    }
    setState(() {

    });
  }

  ///
  /// @description 构建body组件
  /// @param
  /// @return
  /// @author waitwalker
  /// @time 12/18/20 11:10 AM
  ///
  buildContent() {
    int itemCount = (_selectedEvents != null && _selectedEvents!.length > 0) ? (_selectedEvents!.length + 1) : 2;
    return Column(
      children: [
        Expanded(child: ListView.builder(itemBuilder: (BuildContext context, int index){
          /// 正在加载 切换月份的时候会处理
          if (isLoading) {
            if (index == 0) {
              return Padding(
                padding: EdgeInsets.only(left: 16, right: 16, bottom: 16, top: 16),
                child: Container(
                  decoration: _boxDecoration(),
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text('${_selectedMonthFirstDay.month}月', style: TextStyle(fontSize: 24, color: Color(0xff262525)),),
                            Text("${_selectedMonthFirstDay.year}年", style: TextStyle(fontSize: 17, color: Color(0xff262525)),),
                          ],
                        ),
                      ),
                      _buildTableCalendarWithBuilders(),
                    ],
                  ),
                ),
              );
            } else {
              return Padding(padding: EdgeInsets.only(top: 80,), child: Center(child: CircularProgressIndicator(),),);
            }
          } else {
            if (index == 0) {
              return Padding(
                padding: EdgeInsets.only(left: 16, right: 16, bottom: 16, top: 16),
                child: Container(
                  decoration: _boxDecoration(),
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text('${_selectedMonthFirstDay.month}月', style: TextStyle(fontSize: 24, color: Color(0xff262525)),),
                            Text("${_selectedMonthFirstDay.year}年", style: TextStyle(fontSize: 17, color: Color(0xff262525)),),
                          ],
                        ),
                      ),
                      _buildTableCalendarWithBuilders(),
                    ],
                  ),
                ),
              );
            } else {
              if (detailData != null && detailData!.liveCourseResultDTOList != null && detailData!.liveCourseResultDTOList!.isNotEmpty) {
                if (_selectedEvents != null && _selectedEvents!.length > 0) {
                  return _cardItemBuilder(context, index - 1);
                } else {
                  return EmptyPlaceholderPage(assetsPath: 'static/images/empty.png', message: '当天没有课程~', topPadding: 0,);
                }
              } else {
                return EmptyPlaceholderPage(assetsPath: 'static/images/empty.png', message: '当天没有课程~', topPadding: 0,);
              }
            }
          }
        }, itemCount: isLoading ? 2 : itemCount,)),
      ],
    );
  }

  ///
  /// @description 构建日历组件
  /// @param
  /// @return
  /// @author waitwalker
  /// @time 12/18/20 11:10 AM
  ///
  Widget _buildTableCalendarWithBuilders() {
    return TableCalendar<Event>(
      firstDay: kFirstDay,
      lastDay: kLastDay,
      focusedDay: _focusedDay,
      headerVisible: false,
      locale: 'zh_CN',
      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
      eventLoader: (DateTime day) {
        Map<DateTime, List<Event>> arr = Map<DateTime, List<Event>>();
        var b = [Event("123456")];
        detailData?.liveCourseResultDTOList?.forEach((i) {
          arr.addAll({DateFormat('yyyy-MM-dd').parse(i.startTime!): b});
        });
        String dayKey = formatDate(day, [yyyy, "-", mm, "-", dd]);
        DateTime dateTime = DateFormat('yyyy-MM-dd').parse(dayKey);
        List<Event>? listEvent = arr[dateTime];
        if (listEvent != null) {
          return listEvent;
        }

        return [];
      },
      startingDayOfWeek: StartingDayOfWeek.sunday,
      availableGestures: AvailableGestures.all,
      calendarStyle: CalendarStyle(
        outsideDaysVisible: false,
      ),
      daysOfWeekStyle: DaysOfWeekStyle(
        weekdayStyle: TextStyle().copyWith(color: Color(0xFF738598)),
        weekendStyle: TextStyle().copyWith(color: Color(0xFF738598)),
      ),
      headerStyle: HeaderStyle(
        titleCentered: true,
        formatButtonVisible: false,
      ),
      calendarBuilders: CalendarBuilders(
        selectedBuilder: (context, date, _) {
          return FadeTransition(
            opacity: Tween(begin: 0.0, end: 1.0).animate(_animationController),
            child: Container(
              alignment: Alignment.center,
              margin: const EdgeInsets.all(2.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(6.0)),
                shape: BoxShape.rectangle,
                color: Color(0xFF43A4FF),
                boxShadow: [BoxShadow(color: Color(MyColors.shadow), offset: Offset(0, 2), blurRadius: 4.0, spreadRadius: 0.0)],
              ),
              child: Text('${date.day}', style: TextStyle().copyWith(fontSize: 16.0, color: Colors.white),),
            ),
          );
        },
        todayBuilder: (context, date, _) {
          return Container(
            alignment: Alignment.center,
            margin: EdgeInsets.all(2.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(6.0)),
              shape: BoxShape.rectangle,
              color: Color(0xFFF8B739),
              boxShadow: [BoxShadow(color: Color(MyColors.shadow), offset: Offset(0, 2), blurRadius: 4.0, spreadRadius: 0.0)],
            ),
            width: 36,
            height: 36,
            child: Text('${date.day}', style: TextStyle().copyWith(fontSize: 16.0, color: Colors.white),),
          );
        },
        markerBuilder: (context, date, events) {
          if (events.length > 0) {
            return Positioned(bottom: 6, child: _buildEventsMarker(date, events),);
          }
          return Container();
        },
      ),
      onDaySelected: (selectedDay, focusedDay) {
        _onDaySelectedCallBack(selectedDay, focusedDay);
        _animationController.forward(from: 0.0);
      },
      onPageChanged: _onMonthChangedCallBack,
    );
  }

  ///
  /// @description 选择当前日期回调
  /// @param
  /// @return
  /// @author waitwalker
  /// @time 12/18/20 11:06 AM
  ///
  void _onDaySelectedCallBack(DateTime selectedDay, DateTime focusedDay) {
    print('所选日期: $selectedDay');

    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
    });
  }

  ///
  /// @description 月份滚动切换回调
  /// @param
  /// @return
  /// @author waitwalker
  /// @time 12/18/20 11:06 AM
  ///
  void _onMonthChangedCallBack(DateTime focusedDay) {
    print('月份发送切换: $focusedDay');
    isLoading = true;
    _focusedDay = focusedDay;
    DateTime lastDate = DateTime(focusedDay.year, focusedDay.month, daysInMonth(focusedDay));
    _fetchSelectMonthData(focusedDay, lastDate);
    _selectedMonthFirstDay = focusedDay;
    setState(() {

    });
  }

  ///
  /// @description 相关事件处理
  /// @param
  /// @return
  /// @author waitwalker
  /// @time 12/18/20 11:10 AM
  ///
  Widget _buildEventsMarker(DateTime date, List events) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(4.0)),
        shape: BoxShape.rectangle,
        color: events.length > 0 ?  Colors.yellow : Colors.white,
      ),
      width: 10.0,
      height: 3.0,
    );
  }

  ///
  /// @description 课程item 构建
  /// @param
  /// @return
  /// @author waitwalker
  /// @time 12/18/20 11:07 AM
  ///
  Widget _cardItemBuilder(BuildContext context, int index) {
    LiveCourseResultDTOListEntity course = _selectedEvents?.elementAt(index);
    return Padding(
      padding: EdgeInsets.only(left: 16, right: 16, bottom: 16),
      child: GestureDetector(
        child: Container(
          height: 90,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            color: Color(MyColors.white),
            gradient: LinearGradient(
              colors: [
                Color(MyColors.courseScheduleCardMain),
                Color(MyColors.courseScheduleCardLight)
              ],
            ),
            borderRadius: BorderRadius.all(Radius.circular(10.0)), //设置圆角
            boxShadow: <BoxShadow>[BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.2), offset: Offset(0, 2), blurRadius: 10.0, spreadRadius: 2.0)],
          ),
          child: Row(
            children: <Widget>[
              /// 开始结束时间
              Padding(
                padding: EdgeInsets.only(left: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text('${course.startTime!.split(' ').last.substring(0, 5)}', style: TextStyle(fontSize: 15, color: Color(MyColors.white)),),
                    Text('${course.endTime!.split(' ').last.substring(0, 5)}', style: TextStyle(fontSize: 15, color: Color(MyColors.white)),),
                  ],
                ),
              ),

              /// 中间竖线
              Padding(padding: EdgeInsets.only(left: 27,),
                child: Container(
                  decoration: BoxDecoration(color: Color.fromRGBO(255, 255, 255, 0.2951), borderRadius: BorderRadius.all(Radius.circular(2),),),
                  height: 44,
                  width: 2,
                ),
              ),

              /// 课程名称
              Expanded(child: Container(padding: EdgeInsets.only(left: 24, right: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(course.courseName ?? '--', style: TextStyle(fontSize: 12, color: Color(MyColors.white))),
                    Padding(padding: EdgeInsets.only(top: 8)),
                    Text(course.onlineCourseTitle!, style: TextStyle(fontSize: 16, color: Color(MyColors.white)), overflow: TextOverflow.ellipsis,),
                  ],
                ),
              ))
            ],
          ),
        ),
        onTap: () async {
          await onPressLiveBtn(course, context);
        },
      ),
    );
  }

  ///
  /// @description 点击当前课程回调处理
  /// @param
  /// @return
  /// @author waitwalker
  /// @time 12/18/20 11:08 AM
  ///
  Future onPressLiveBtn(
      LiveCourseResultDTOListEntity course, BuildContext context) async {
    if (course.liveState == LiveStatus.not_started.index) {
      Fluttertoast.showToast(msg: '暂未开始，直播开启前30分钟才能进入');
      return;
    }
    var json = SharedPrefsUtils.getString(APIConst.LOGIN_JSON, '{}')!;
    var ccLoginModel = LoginModel.fromJson(jsonDecode(json));

    var liveUrl = '${APIConst.liveHost}?utoken=${ccLoginModel.access_token}&rcourseid=${widget.courseId}&ocourseId=${course.onlineCourseId}&roomid=${course.roomId}';
    var backUrl = '${APIConst.backHost}?token=${ccLoginModel.access_token}&rcourseid=${widget.courseId}&ocourseId=${course.onlineCourseId}&roomid=${course.roomId}';

    var url = course.liveState == LiveStatus.live_over.index ? backUrl : liveUrl;
    Navigator.of(context).push(MaterialPageRoute(
        builder: (BuildContext context) => CommonWebviewPage(initialUrl: url,
              title: course.liveState == LiveStatus.live_over.index ? '直播回放' : '直播',)));
  }

  BoxDecoration _boxDecoration() {
    return BoxDecoration(
      color: Color(MyColors.white),
      borderRadius: BorderRadius.all(
        Radius.circular(6),
      ),
      boxShadow: [
        BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.2),
            offset: Offset(0, 2),
            blurRadius: 10.0,
            spreadRadius: 2.0)
      ],
    );
  }

  bool startTimeIsSelectDay(LiveCourseResultDTOListEntity i) {
    var startTime = DateFormat('yyyy-MM-dd').parse(i.startTime!);
    return _selectedDay.day == startTime.day && _selectedDay.month == startTime.month && _selectedDay.year == startTime.year;
  }
}


///
/// @description Event 类  用于生成当天日期事件
/// @author waitwalker
/// @time 4/19/21 2:03 PM
///
class Event {
  final String title;
  const Event(this.title);
  @override
  String toString() => title;
}

final kNow = DateTime.now();
final kFirstDay = DateTime(kNow.year, kNow.month -36, kNow.day);
final kLastDay = DateTime(kNow.year, kNow.month + 36, kNow.day);

