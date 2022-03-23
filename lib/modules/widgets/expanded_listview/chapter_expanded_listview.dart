// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:my_gallery/model/material_model.dart';
import 'package:my_gallery/model/wisdom_model.dart';
import 'package:my_gallery/modules/my_course/intelligence_question_database/chapter_practice_page.dart';

const Duration _kExpand = Duration(milliseconds: 200);

/// A single-line [ListTile] with a trailing button that expands or collapses
/// the tile to reveal or hide the [children].
///
/// This widget is typically used with [ListView] to create an
/// "expand / collapse" list entry. When used with scrolling widgets like
/// [ListView], a unique [PageStorageKey] must be specified to enable the
/// [ChapterExpandedList] to save and restore its expanded state when it is scrolled
/// in and out of view.
///
/// See also:
///
///  * [ListTile], useful for creating expansion tile [children] when the
///    expansion tile represents a sublist.
///  * The "Expand/collapse" section of
///    <https://material.io/guidelines/components/lists-controls.html>.
class ChapterExpandedList extends StatefulWidget {
  /// Creates a single-line [ListTile] with a trailing button that expands or collapses
  /// the tile to reveal or hide the [children]. The [initiallyExpanded] property must
  /// be non-null.
  const ChapterExpandedList({
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
    this.dataEntity,
    this.materialModel,
    this.itemOnPress,
  })  : assert(initiallyExpanded != null),
        super(key: key);

  final bool isChapter;
  final bool isWisdom;
  final ItemOnPressCallBack? itemOnPress;
  final DataEntity? dataEntity;
  final MaterialDataEntity? materialModel;

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
  _ChapterExpandedListState createState() => _ChapterExpandedListState();
}

class _ChapterExpandedListState extends State<ChapterExpandedList>
    with SingleTickerProviderStateMixin {
  static final Animatable<double> _easeOutTween =
  CurveTween(curve: Curves.easeOut);
  static final Animatable<double> _easeInTween =
  CurveTween(curve: Curves.easeIn);

  final ColorTween _borderColorTween = ColorTween();
  final ColorTween _headerColorTween = ColorTween();
  final ColorTween _iconColorTween = ColorTween();
  final ColorTween _backgroundColorTween = ColorTween();

  late AnimationController _controller;
  late Animation<double> _heightFactor;
  late Animation<Color?> _backgroundColor;

  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: _kExpand, vsync: this);
    _heightFactor = _controller.drive(_easeInTween);
    _backgroundColor = _controller.drive(_backgroundColorTween.chain(_easeOutTween));

    _isExpanded = PageStorage.of(context)?.readState(context) ?? widget.initiallyExpanded;
    if (_isExpanded) _controller.value = 1.0;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (widget.dataEntity!.nodeList != null && widget.dataEntity!.nodeList!.length > 0 && (widget.dataEntity!.resourceIdList == null || widget.dataEntity!.resourceIdList!.length == 0)) {
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
    } else {
      widget.itemOnPress!(widget.dataEntity);
    }
  }

  Widget _buildChildren(BuildContext context, Widget? child) {
    return Container(
        decoration: BoxDecoration(
          color: _backgroundColor.value ?? Colors.transparent,
        ),
        child: InkWell(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                _buildAnswerQuestion(),
                ClipRect(
                  child: Align(
                    heightFactor: _heightFactor.value,
                    child: child,
                  ),
                ),
              ],
            ),
          onTap: _handleTap,
        ),
    );
  }

  ///
  /// @description 构建章节练习已做题数量控件
  /// @param 
  /// @return 
  /// @author waitwalker
  /// @time 3/30/21 1:46 PM
  ///
  _buildAnswerQuestion() {
    if (widget.dataEntity!.level! >= 2 && (widget.dataEntity!.nodeList == null || widget.dataEntity!.nodeList!.length == 0)) {
      return Container(
        height: 44,
        padding: EdgeInsets.only(left: 16, right: 16),
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            widget.title,

            // RotationTransition(
            //   turns: _iconTurns,
            //   child: Icon(Icons.expand_more, color: _isExpanded == true ? Color(0xFF5EB4F9) : Color(0xFFC8D0D7)),
            // ),
            // Padding(padding: EdgeInsets.only(left: 10)),
            Row(
              children: [
                Text("${widget.dataEntity!.answerNumber}/", style: TextStyle(fontSize: 10, color: Color(0xffFFB03A),),),
                Text("${widget.dataEntity!.questionsNumber}", style: TextStyle(fontSize: 10),),
              ],
            ),
          ],
        ),
      );
    } else {
      return Container(
        height: 44,
        padding: EdgeInsets.only(left: 16, right: 16),
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            widget.title,
            //Text("${widget.dataEntity.answerNumber} / ${widget.dataEntity.questionsNumber}", style: TextStyle(fontSize: 10),),
          ],
        ),
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
