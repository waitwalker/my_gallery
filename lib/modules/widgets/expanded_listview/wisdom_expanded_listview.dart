// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:my_gallery/common/singleton/singleton_manager.dart';
import 'package:my_gallery/common/tools/share_preference/share_preference.dart';
import 'package:my_gallery/model/material_model.dart';
import 'package:my_gallery/model/wisdom_model.dart';
import 'package:my_gallery/model/self_study_record.dart';
import 'package:my_gallery/modules/my_course/wisdom_study/normal_resource_list_page.dart';
import 'package:my_gallery/modules/my_course/wisdom_study/wisdom_study_list_page.dart';
import 'package:my_gallery/modules/widgets/style/style.dart';

import '../alert/activity_alert.dart';
const Duration _kExpand = Duration(milliseconds: 100);

/// A single-line [ListTile] with a trailing button that expands or collapses
/// the tile to reveal or hide the [children].
///
/// This widget is typically used with [ListView] to create an
/// "expand / collapse" list entry. When used with scrolling widgets like
/// [ListView], a unique [PageStorageKey] must be specified to enable the
/// [WisdomExpandedList] to save and restore its expanded state when it is scrolled
/// in and out of view.
///
/// See also:
///
///  * [ListTile], useful for creating expansion tile [children] when the
///    expansion tile represents a sublist.
///  * The "Expand/collapse" section of
///    <https://material.io/guidelines/components/lists-controls.html>.
class WisdomExpandedList extends StatefulWidget {
  /// Creates a single-line [ListTile] with a trailing button that expands or collapses
  /// the tile to reveal or hide the [children]. The [initiallyExpanded] property must
  /// be non-null.
  const WisdomExpandedList({
    Key? key,
    this.leading,
    required this.title,
    this.backgroundColor,
    this.onExpansionChanged,
    this.children = const <Widget>[],
    this.trailing,
    this.initiallyExpanded = false,
    this.isChapter = false,
    this.isWisdom = false,
    this.rowHeight = 44,
    this.canTap = true,
    this.dataEntity,
    this.isLast = false,
    this.previewMode = false,
    this.materialModel,
    this.gradeId,
    this.subjectId,
    this.courseId,
    this.currentIndex,
    this.callBack,
    this.currentOffset
  })  : assert(initiallyExpanded != null),
        super(key: key);

  final DataEntity? dataEntity;
  final double rowHeight;
  final double? currentOffset;
  final bool isChapter;
  final bool isWisdom;
  final bool canTap;
  final bool isLast;
  final bool previewMode;
  final MaterialDataEntity? materialModel;
  final int? courseId;
  final int? subjectId;
  final int? gradeId;
  final int? currentIndex;
  final DiagnosisCallBack? callBack;

  /// A widget to display before the title.
  ///
  /// Typically a [CircleAvatar] widget.
  final Widget? leading;

  /// The primary content of the list item.
  ///
  /// Typically a [Text] widget.
  final Widget title;

  /// Called when the tile expands or collapses.
  ///
  /// When the tile starts expanding, this function is called with the value
  /// true. When the tile starts collapsing, this function is called with
  /// the value false.
  final ValueChanged<bool>? onExpansionChanged;

  /// The widgets that are displayed when the tile expands.
  ///
  /// Typically [ListTile] widgets.
  final List<Widget> children;

  /// The color to display behind the sublist when expanded.
  final Color? backgroundColor;

  /// A widget to display instead of a rotating arrow icon.
  final Widget? trailing;

  /// Specifies if the list tile is initially expanded (true) or collapsed (false, the default).
  final bool initiallyExpanded;

  @override
  _WisdomExpandedListState createState() => _WisdomExpandedListState();
}

class _WisdomExpandedListState extends State<WisdomExpandedList>
    with SingleTickerProviderStateMixin {
  static final Animatable<double> _easeInTween =
  CurveTween(curve: Curves.easeIn);

  final ColorTween _borderColorTween = ColorTween();
  final ColorTween _headerColorTween = ColorTween();
  final ColorTween _iconColorTween = ColorTween();
  final ColorTween _backgroundColorTween = ColorTween();

  late AnimationController _controller;
  late Animation<double> _heightFactor;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: _kExpand, vsync: this);
    _heightFactor = _controller.drive(_easeInTween);

    _isExpanded =
        PageStorage.of(context)?.readState(context) ?? widget.initiallyExpanded;
    if (_isExpanded) _controller.value = 1.0;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    print("是否可点击:${widget.canTap}");
    DataEntity dataEntity = widget.dataEntity!;
    if (dataEntity.nodeList!.isNotEmpty) {
      setState(() {
        _isExpanded = !_isExpanded;
        if (_isExpanded) {
          _controller.forward();
        } else {
          _controller.reverse().then<void>((void value) {
            if (!mounted) return;
            setState(() {
              // Rebuild without widget.children.
            });
          });
        }
        PageStorage.of(context)?.writeState(context, _isExpanded);
      });
      if (widget.onExpansionChanged != null)
        widget.onExpansionChanged!(_isExpanded);
    }

    print("dataEntity");
    /// 点击二级目录直接触发相关事件
    if (dataEntity != null && dataEntity.nodeList!.isEmpty && dataEntity.resourceIdList!.isEmpty) {
      SharedPrefsUtils.putString("currentValue", "1");
      saveRecord(SelfStudyRecord(
          id: widget.dataEntity!.nodeId,
          type: 2,
          gradeId: widget.materialModel!.gradeId,
          subjectId: widget.materialModel!.subjectId,
          courseId: widget.courseId,
          title: widget.dataEntity!.nodeName,
          currentIndex: widget.currentIndex,
          nodeName: widget.dataEntity!.nodeName,
          currentOffset: SingletonManager.sharedInstance!.currentOffset));
      /// 非体验模式
      if (!widget.previewMode) {
        Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context){
          return NormalResourceListPage(
            dataEntity,
            currentOffset: SingletonManager.sharedInstance!.currentOffset,
            currentIndex: widget.currentIndex,
            isLast: widget.isLast,
            materialModel: widget.materialModel,
            subjectId: widget.subjectId,
            courseId: widget.courseId,
            gradeId: widget.gradeId,);
        })).then(widget.callBack!);
      } else {
        if (dataEntity.previewModeCanTap!) {
          Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context){
            return NormalResourceListPage(
              dataEntity,
              currentOffset: SingletonManager.sharedInstance!.currentOffset,
              currentIndex: widget.currentIndex,
              isLast: widget.isLast,
              materialModel: widget.materialModel,
              subjectId: widget.subjectId,
              courseId: widget.courseId,
              gradeId: widget.gradeId,);
          })).then(widget.callBack!);
        } else {
          showDialog(
              context: context,
              builder: _dialogBuilder);
        }
      }
    }
  }

  ///
  /// @description 章节模式保存学习记录
  /// @param
  /// @return
  /// @author waitwalker
  /// @time 3/11/21 1:57 PM
  ///
  void saveRecord(record) {
    if (record != null &&
        record.id != null &&
        record.subjectId != null &&
        record.gradeId != null &&
        record.type != null &&
        (record.title?.isNotEmpty ?? false)) {
      record.type = 11;
      record.studyTime = DateTime.now().millisecondsSinceEpoch;
      record.time = record.studyTime;
      SharedPrefsUtils.put('diagnosis_record', record.toString());
    }
  }

  /// 400电话弹框
  Widget _dialogBuilder(BuildContext context) {
    return ActivityCourseAlert(
      tapCallBack: () {
        Navigator.of(context).pop();
      },
    );
  }

  Widget _buildChildren(BuildContext context, Widget? child) {
    return Container(
        decoration: BoxDecoration(
          color: Color(0xff579EFF),
        ),
        child: InkWell(
            child: buildChild(child),
            onTap: _handleTap,
        ),
    );
  }
  
  buildChild(Widget? child) {
    String p;
    String progress;
    p = widget.dataEntity!.progress ==0 ? "0" : widget.dataEntity!.progress.toString();
    progress = p + "%";
    if (widget.dataEntity!.level == 1) {
    return Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Padding(padding: EdgeInsets.only(left: 16, right: 16), child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: (widget.dataEntity!.nodeList!.isEmpty) ?
              BorderRadius.circular(7.5) :
              (!_isExpanded ? BorderRadius.circular(7.5) : BorderRadius.only(topLeft: Radius.circular(7.5), topRight: Radius.circular(7.5))),
              boxShadow: [
                BoxShadow(
                    color: Color.fromRGBO(0, 0, 0, 0.40),
                    offset: Offset(0, 2.5),
                    blurRadius: 10.0,
                    spreadRadius: 0.0)
              ],
            ),
            height: SingletonManager.sharedInstance!.isPadDevice ? 120 : 82,
            padding: EdgeInsets.only(left: 16, right: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      widget.title,
                      Text(
                        progress,
                        style: TextStyle(
                            color: Color(0xff222222),
                            fontSize: SingletonManager.sharedInstance!.isPadDevice ? 20 : 16,
                            fontWeight: FontWeight.bold),),
                    ]),
                Padding(padding: EdgeInsets.only(top: 8)),
                /// 完成度进度条
                Container(
                  height: SingletonManager.sharedInstance!.isPadDevice ? 15 : 9,
                  child: Stack(
                    children: [
                      Positioned(child: Container(
                        width: MediaQuery.of(context).size.width - 32 - 32,
                        height: SingletonManager.sharedInstance!.isPadDevice ? 15 : 9,
                        decoration: BoxDecoration(
                          color: Color(0xffEDF0F7),
                          borderRadius: BorderRadius.circular(15.5),
                        ),
                      )),
                      Positioned(child: Container(
                        width: (MediaQuery.of(context).size.width - 32 - 32) * widget.dataEntity!.progress! / 100.0,
                        height: SingletonManager.sharedInstance!.isPadDevice ? 15 : 9,
                        decoration: BoxDecoration(
                          color: widget.dataEntity!.progress! >= 75.0 ?
                          Color(0xffF5A55C) : widget.dataEntity!.progress! >= 50.0 ?
                          Color(0xffFCC849) : widget.dataEntity!.progress! >= 25.0 ?
                          Color(0xff4EE7C8) :
                          Color(0xff4BADFF),
                          borderRadius: BorderRadius.circular(15.5),
                        ),
                      )),
                    ],
                  ),
                ),
              ],
            ),),),
          ClipRect(
            child: Align(
              heightFactor: _heightFactor.value,
              child: child,
            ),
          ),
        ],
      );
    } else {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Padding(padding: EdgeInsets.only(left: 16, right: 16), child: Container(
              decoration: BoxDecoration(
                borderRadius:
                widget.isLast ?
                BorderRadius.only(
                    bottomRight: Radius.circular(7.5),
                    bottomLeft: Radius.circular(7.5)) :
                BorderRadius.circular(0) ,
                color: Colors.white,
              ),
              height: 44,
              padding: EdgeInsets.only(left: 16, right: 16),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Container(width: 5,height: 5,
                      decoration: BoxDecoration(
                        color: Color(0xffFCA642),
                        borderRadius: BorderRadius.circular(4)
                      ),
                    ),
                    Padding(padding: EdgeInsets.only(left: 8)),
                    widget.title,

                    /// 如果不是体验模式,展示完成度,超过100%显示图标
                    !widget.previewMode ?
                    (widget.dataEntity!.progress! > 99.9 ?
                    Image(
                      image: AssetImage("static/images/wisdom_all_finish_icon.png"),
                      width: 18, height: 14, fit: BoxFit.fill,) :
                    Text(progress,
                      style: TextStyle(
                          color: Color(0xff222222),
                        fontSize: SingletonManager.sharedInstance!.screenWidth > 500.0 ? 17 : 13),)) :
                    widget.dataEntity!.previewModeCanTap! ? Container(
                        width: 38, height: 20, alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(4.0)),
                          border: Border.all(color: Color(0xFF6B8DFF),),),
                        child: Text('体验', style: textStyle11Blue)) : Icon(Icons.lock, size: 20),

                  ])),),
          ClipRect(
            child: Align(
              heightFactor: _heightFactor.value,
              child: child,
            ),
          ),
        ],
      );
    }
  }

  @override
  void didChangeDependencies() {
    final ThemeData theme = Theme.of(context);
    _borderColorTween..end = theme.dividerColor;
    _headerColorTween
      ..begin = theme.textTheme.subtitle1!.color
      ..end = theme.accentColor;
    _iconColorTween
      ..begin = theme.unselectedWidgetColor
      ..end = theme.accentColor;
    _backgroundColorTween..end = widget.backgroundColor;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final bool closed = !_isExpanded && _controller.isDismissed;
    return AnimatedBuilder(
      animation: _controller.view,
      builder: _buildChildren,
      child: closed ? null : Column(children: widget.children),
    );
  }
}
