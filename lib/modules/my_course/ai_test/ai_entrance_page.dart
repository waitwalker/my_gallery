import 'dart:io';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:my_gallery/common/redux/app_state.dart';
import 'package:my_gallery/common/singleton/singleton_manager.dart';
import 'package:my_gallery/common/tools/screen_adapt/screen_utils.dart';
import 'package:my_gallery/model/material_model.dart';
import 'package:my_gallery/modules/widgets/empty_placeholder/empty_placeholder_widget.dart';
import 'package:my_gallery/modules/widgets/loading/list_type_loading_placehold_widget.dart';
import 'package:my_gallery/modules/widgets/style/style.dart';
import 'ai_list_container_page.dart';
import 'ai_test_list_page.dart';
import 'package:my_gallery/common/dao/original_dao/course_dao_manager.dart';
import 'package:my_gallery/model/ai_model.dart';
import 'package:async/async.dart';
import 'package:redux/redux.dart';

///
/// @description AI测试入口页面
/// @author waitwalker
/// @time 2020/8/28 2:49 PM
///
// ignore: must_be_immutable
class AIEntrancePage extends StatefulWidget {

  var title;
  var type = 1;
  var subjectId;
  var gradeId;
  var courseId;
  var memoizer;
  var previewMode;

  AIEntrancePage(this.subjectId, this.gradeId,
      {this.memoizer, this.courseId, this.previewMode, this.title});

  @override
  State<StatefulWidget> createState() {
    return _AIEntranceState();
  }
}

class _AIEntranceState extends State<AIEntrancePage> {
  late AsyncMemoizer memoizer;
  List<Data>? detailData;
  Data? selectedRes;

  /// 中间间距
  double middleMargin = Platform.isIOS ? 16.0 : 16.0;

  /// 中间距离顶部
  double middleTop = Platform.isIOS ? 33.0 : 26.0;

  double middleCircle = Platform.isIOS ? 70.0 : 66.0;

  //'${materialModel?.defAbbreviation} - ${materialModel?.defMaterialName}'

  @override
  void initState() {
    memoizer = widget.memoizer ?? AsyncMemoizer();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StoreBuilder(builder: (BuildContext context, Store<AppState> store) {
      return Scaffold(
        backgroundColor: Color(MyColors.background),
        appBar: AppBar(
          backgroundColor: Color(0xff73b2f3),
          leading: IconButton(icon: Icon(Platform.isIOS ? Icons.arrow_back_ios : Icons.arrow_back, color: Colors.white,), onPressed: (){
            Navigator.pop(context);
          }),
          elevation: 1,
          ///阴影高度
          titleSpacing: 0,
          centerTitle: Platform.isIOS ? true : false,
          title: Text(widget.title ?? "AI测试", style: TextStyle(color: Colors.white),),
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
        return _buildContent();
      default:
        return EmptyPlaceholderPage(assetsPath: 'static/images/empty.png', message: '没有数据');
    }
  }

  Widget _buildWidget() {
    return FutureBuilder(
      builder: _futureBuilder,
      future: _fetchData(),
    );
  }

  _fetchData() {
    return memoizer.runOnce(() => CourseDaoManager.subjectDetail(gradeId: 6, subjectId: widget.subjectId, cardType: 1));
  }

  _buildContent() {
    return Column(
      children: [
        Expanded(child: ListView(
          children: [
            Container(height: 81, padding: EdgeInsets.symmetric(horizontal: 16, vertical: 15), child: _buildChooseMaterial(MaterialDataEntity()),),
            Container( padding: EdgeInsets.symmetric(horizontal: 16), child: _buildTop()),
            Container( padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20), child: _buildMiddle()),
            Container( padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16), child: _buildBottom()),
          ],
        ))
      ],
    );
  }

  // 切换教材
  Container _buildChooseMaterial(MaterialDataEntity materialModel) {
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
              child: Text("人教版-初三下册", overflow: TextOverflow.ellipsis, style: TextStyle(color: Color(0xff384A69), fontSize: SingletonManager.sharedInstance!.screenWidth > 500.0 ? 18 : 16, fontWeight: FontWeight.w600))),
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

              Navigator.of(context).push(MaterialPageRoute(
                  builder: (BuildContext context) => AIListContainerPage(
                      innerWidget: AITestListPage(
                        widget.subjectId,
                        widget.gradeId,
                        courseId: widget.courseId ?? 0,
                        previewMode: widget.previewMode,
                      ),
                      title: widget.title)));
            },
          ),
        ],
      ),
    );
  }

  _buildTop() {
    return InkWell(
      child: Container(
        height: ScreenUtil.getInstance().setHeight(140),
        width: ScreenUtil.getInstance().setWidth(MediaQuery.of(context).size.width - 32),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          image: DecorationImage(image: AssetImage("static/images/ai_entrance_top.png",), fit: BoxFit.fill),
          boxShadow: [
            BoxShadow(
                color: Color(MyColors.shadow),
                offset: Offset(0, 2),
                blurRadius: 10.0,
                spreadRadius: 2.0)
          ],
        ),
      ),
      onTap: (){
        Navigator.of(context).push(MaterialPageRoute(
            builder: (BuildContext context) => AIListContainerPage(
                innerWidget: AITestListPage(
                  widget.subjectId,
                  widget.gradeId,
                  courseId: widget.courseId ?? 0,
                  previewMode: widget.previewMode,
                ),
                title: widget.title)));
      },
    );
  }

  ///
  /// @description 构建中间
  /// @param
  /// @return
  /// @author waitwalker
  /// @time 2020/8/28 2:48 PM
  ///
  _buildMiddle() {
    return Container(
      width: ScreenUtil.getInstance().setWidth(MediaQuery.of(context).size.width - 32),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: (MediaQuery.of(context).size.width - 32 - middleMargin) / 2,
            height: ScreenUtil.getInstance().setHeight(162),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              image: DecorationImage(image: AssetImage("static/images/ai_entrance_middle_left.png",), fit: BoxFit.fill),
              boxShadow: [
                BoxShadow(
                    color: Color(MyColors.shadow),
                    offset: Offset(0, 2),
                    blurRadius: 5.0,
                    spreadRadius: 2.0)
              ],
            ),
            child: Stack(
              children: [

                Positioned(
                  left: 22,
                  top: middleTop,
                  child: Text("掌握度", style: TextStyle(fontSize: 18, color: Color(0xffFFFFFF)),),),

                Positioned(
                  left: 22,
                  bottom: 20,
                  child: Container(
                    alignment: Alignment.center,
                    height: middleCircle,
                    width: middleCircle ,
                    child: Text("199/200",style: TextStyle(color: Colors.white,fontSize: 12),),
                  ),),

                Positioned(
                  left: 22,
                  bottom: 20,
                  child: Container(
                    height: middleCircle,
                    width: middleCircle,
                    child: CustomPaint(
                      painter: AICirclePainter(0.65, middleCircle),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: (MediaQuery.of(context).size.width - 32 - middleMargin) / 2,
                height: ScreenUtil.getInstance().setHeight(73),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  image: DecorationImage(image: AssetImage("static/images/ai_entrance_middle_right_top.png",), fit: BoxFit.fill),
                  boxShadow: [
                    BoxShadow(
                        color: Color(MyColors.shadow),
                        offset: Offset(0, 2),
                        blurRadius: 5.0,
                        spreadRadius: 2.0)
                  ],
                ),
              ),
              Padding(padding: EdgeInsets.only(top: 14)),
              Container(
                width: (MediaQuery.of(context).size.width - 32 - middleMargin) / 2,
                height: ScreenUtil.getInstance().setHeight(73),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  image: DecorationImage(image: AssetImage("static/images/ai_entrance_middle_right_bottom.png",), fit: BoxFit.fill),
                  boxShadow: [
                    BoxShadow(
                        color: Color(MyColors.shadow),
                        offset: Offset(0, 2),
                        blurRadius: 5.0,
                        spreadRadius: 2.0)
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  _buildBottom() {
    return Padding(padding: EdgeInsets.only(left: 10, right: 10),
      child: Container(
        height: ScreenUtil.getInstance().setHeight(63),
        width: MediaQuery.of(context).size.width - 32 - 20,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              height: ScreenUtil.getInstance().setHeight(63),
              width: (MediaQuery.of(context).size.width - 32 - 63 - 20 - 5 - 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
                boxShadow: [
                  BoxShadow(
                      color: Color(MyColors.shadow),
                      offset: Offset(0, 2),
                      blurRadius: 10.0,
                      spreadRadius: 2.0)
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    height: ScreenUtil.getInstance().setHeight(63),
                    width: (MediaQuery.of(context).size.width - 32 - 63 - 20 - 30 - 50 - 5 - 20),
                    child: Padding(padding: EdgeInsets.only(left: 15), child: Text("上次学到 : 一元一次方程的知识点继续 学习吗？", maxLines: 2, style: TextStyle(fontSize: 13, color: Color(0xff4F5962),),),),
                    alignment: Alignment.center,
                  ),
                  Padding(padding: EdgeInsets.only(left: 10)),
                  Container(
                    height: 20,
                    width: 60,
                    alignment: Alignment.center,
                    child: Text("继续做题", style: TextStyle(fontSize: 9, color: Color(0xff63BEF7)),),
                    decoration: BoxDecoration(
                      color: Color(0xffDFF0FC),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: 62,
              width: 62,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(31),
                image: DecorationImage(image: AssetImage("static/images/ai_entrance_bottom_icon.png",), fit: BoxFit.fill),
                boxShadow: [
                  BoxShadow(
                      color: Color(MyColors.shadow),
                      offset: Offset(0, 2),
                      blurRadius: 5.0,
                      spreadRadius: 2.0)
                ],
              ),
            )
          ],
        ),
      ),);
  }
}

class AICirclePainter extends CustomPainter {

  // 弧形所占比例
  final double scale;
  final double centerCircle;

  AICirclePainter(this.scale, this.centerCircle);

  @override
  paint(Canvas canvas, Size size)  {
    // 绘制圆弧 画笔
    Paint paint = Paint()
      ..isAntiAlias = true
      ..color = Color(0xffffffFF)
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 12
      ..style = PaintingStyle.stroke;

    // 绘制圆 画笔
    Paint paint1 = Paint()
      ..isAntiAlias = true
      ..color = Color(0xffC4E882)
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 12
      ..style = PaintingStyle.stroke;
    /// Offset(),横纵坐标偏移
    /// void drawArc(Rect rect, double startAngle, double sweepAngle, bool useCenter, Paint paint)
    /// Rect来确认圆弧的位置, 开始的弧度、结束的弧度、是否使用中心点绘制(圆弧是否向中心闭合)、以及paint.
    final center = Offset(centerCircle / 2.0, centerCircle / 2.0);
    canvas.drawArc(
        Rect.fromCircle(center: center, radius: size.width / 2),
        -pi / 2, 2 * pi, false, paint1);
    canvas.drawArc(
        Rect.fromCircle(center: center, radius: size.width / 2),
        -pi / 2, 2 * pi * scale, false, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}