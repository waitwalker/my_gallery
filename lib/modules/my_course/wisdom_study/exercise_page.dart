import 'package:my_gallery/model/micro_course_resource_model.dart';
import 'package:my_gallery/common/const/api_const.dart';
import 'package:my_gallery/common/network/network_manager.dart';
import 'package:my_gallery/modules/my_course/wisdom_study/exercise_record_page.dart';
import 'package:my_gallery/modules/my_plan/my_plan_model.dart';
import 'package:my_gallery/modules/widgets/webviews/microcourse_webview.dart';
import 'package:my_gallery/modules/widgets/style/style.dart';
import 'package:flutter/material.dart';

///
/// @name ExercisePage
/// @description 练习页面
/// @author waitwalker
/// @date 2020-01-11
///
// ignore: must_be_immutable
class ExercisePage extends StatefulWidget {
  MicroCourseResourceDataEntity? data;
  var courseCardCourseId;

  bool fromCollegeEntrance;
  // 1, 微视频，2,AB测试
  int type;
  Tasks? task;
  int? materialid;
  int? nodeid;
  int? level;
  int? isdiagnosis;
  ExercisePage(this.data, this.courseCardCourseId, {this.type = 1,this.fromCollegeEntrance = false, this.task, this.isdiagnosis, this.level, this.nodeid, this.materialid});

  @override
  _ExercisePageState createState() => _ExercisePageState();
}

class _ExercisePageState extends State<ExercisePage> with SingleTickerProviderStateMixin {

  @override
  void initState() {
    super.initState();
  }

  buildContent() {
    return Expanded(
        child: Stack(
      alignment: Alignment.center,
      children: <Widget>[
        Positioned(
          child: InkWell(
            child: Text('查看练习记录', style: textStyleHintPrimary),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (_) {
                return ExerciseRecordPage(widget.data!.resouceId,
                    type: widget.type);
              }));
            },
          ),
          top: 15,
          right: 15,
        ),
        Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Center(
                child: Image.asset('static/images/img_studying.png',
                    width: 170, height: 170),
              ),
              Padding(padding: EdgeInsets.only(top: 24)),
              Container(
                width: 210,
                child: Wrap(
                  children: <Widget>[
                    Text('为了检测你对知识的掌握程度， 请认真完成', style: textStyleNormal666)
                  ],
                ),
              ),
              Padding(padding: EdgeInsets.only(top: 150)),
            ]),

        Positioned(
          bottom: 10,
          child: Container(
            width: 285,
            child: ElevatedButton(
              style: ButtonStyle(
                shape: ButtonStyleButton.allOrNull<RoundedRectangleBorder>(RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4.0)))),
                backgroundColor: ButtonStyleButton.allOrNull<Color>(Color(0xff6B8DFF)),
              ),
              child: Text(
                '马上练习',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.white,
                  fontWeight: FontWeight.normal,
                ),
              ),
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (_) {
                  var token = NetworkManager.getAuthorization();
                  var resourceId = widget.data!.resouceId;
                  var courseId;
                  if (widget.fromCollegeEntrance == true) {
                    courseId = 0;
                  } else {
                    courseId = widget.courseCardCourseId;
                  }
                  var url;
                  if (widget.task == null) {
                    url ='${APIConst.practiceHost}/practice.html?token=$token&resourceid=$resourceId&courseId=$courseId';
                    if (widget.isdiagnosis != null) {
                      url ='${APIConst.practiceHost}/practice.html?token=$token&resourceid=$resourceId&courseId=$courseId&isdiagnosis=${widget.isdiagnosis}&materialid=${widget.materialid}&nodeid=${widget.nodeid}&level=${widget.level}';
                    }
                  } else {
                    url ='${APIConst.practiceHost}/practice.html?token=$token&resourceid=$resourceId&taskid=${widget.task!.taskId}&courseId=${widget.task!.cardCourseId ?? 0}';
                  }
                  return MicrocourseWebPage(
                    actionT: 1,
                    initialUrl: url,
                    resourceId: widget.data!.resouceId,
                    resourceName: widget.data!.resourceName,
                    task: widget.task,
                    isdiagnosis: widget.isdiagnosis,
                    level: widget.level,
                    materialid: widget.materialid,
                    nodeid: widget.nodeid,
                  );
                }));
              },
            ),
          ),
        )
      ],
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(height: 10, color: Color(MyColors.background)),
        buildContent()
      ],
    );
  }
}
