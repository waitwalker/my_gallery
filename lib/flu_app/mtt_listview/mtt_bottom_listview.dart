import 'package:flutter/material.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'dart:math' as math;
import 'hover_util.dart';

const double kHoverItemDefaultHeight = 40;

class MTTBottomListView extends StatefulWidget {
  MTTBottomListView({
    Key? key,
    required this.data,
    required this.itemCount,
    required this.itemBuilder,
    this.itemScrollController,
    this.itemPositionsListener,
    this.hoverItemBuilder,
    this.hoverItemHeight = kHoverItemDefaultHeight,
    this.hoverPosition,
    this.physics,
    this.padding,
  }) : super(key: key);

  final List<HoverAbstractModel> data;

  /// Number of items the [itemBuilder] can produce.
  final int itemCount;

  /// Called to build children for the list with
  /// 0 <= index < itemCount.
  final IndexedWidgetBuilder itemBuilder;

  /// Controller for jumping or scrolling to an item.
  final ItemScrollController? itemScrollController;

  /// Notifier that reports the items laid out in the list after each frame.
  final ItemPositionsListener? itemPositionsListener;

  final IndexedWidgetBuilder? hoverItemBuilder;

  final double hoverItemHeight;

  final Offset? hoverPosition;

  /// How the scroll view should respond to user input.
  ///
  /// For example, determines how the scroll view continues to animate after the
  /// user stops dragging the scroll view.
  ///
  /// See [ScrollView.physics].
  final ScrollPhysics? physics;

  /// The amount of space by which to inset the children.
  final EdgeInsets? padding;

  @override
  _MTTBottomListViewState createState() => _MTTBottomListViewState();
}

class _MTTBottomListViewState extends State<MTTBottomListView> {
  /// Controller to scroll or jump to a particular item.
  ItemScrollController? itemScrollController;

  /// Listener that reports the position of items when the list is scrolled.
  ItemPositionsListener? itemPositionsListener;

  @override
  void initState() {
    super.initState();
    itemScrollController =
        widget.itemScrollController ?? ItemScrollController();
    itemPositionsListener =
        widget.itemPositionsListener ?? ItemPositionsListener.create();
  }

  @override
  void dispose() {
    super.dispose();
  }

  /// build hover widget.
  Widget _builderHoverWidget(BuildContext context) {
    if (widget.hoverItemBuilder == null) {
      return Container();
    }
    return ValueListenableBuilder<Iterable<ItemPosition>>(
      valueListenable: itemPositionsListener!.itemPositions,
      builder: (ctx, positions, child) {
        if (positions.isEmpty || widget.itemCount == 0) {
          return Container();
        }
        ItemPosition itemPosition = positions
            .where((ItemPosition position) => position.itemTrailingEdge > 0)
            .reduce((ItemPosition min, ItemPosition position) =>
        position.itemTrailingEdge < min.itemTrailingEdge
            ? position
            : min);
        if (itemPosition.itemLeadingEdge > 0) return Container();
        int index = itemPosition.index;
        double left = 0;
        double top = 0;
        if (index < widget.itemCount) {
          if (widget.hoverPosition != null) {
            left = widget.hoverPosition!.dx;
            top = widget.hoverPosition!.dy;
          } else {
            int next = math.min(index + 1, widget.itemCount - 1);
            HoverAbstractModel bean = widget.data[next];
            if (bean.shouldShowHover) {
              double height =
                  context.findRenderObject()?.paintBounds?.height ?? 0;
              double topTemp = itemPosition.itemTrailingEdge * height;
              top = math.min(widget.hoverItemHeight, topTemp) -
                  widget.hoverItemHeight;
            }
          }
        } else {
          index = 0;
        }
        return Positioned(
          left: left,
          top: top,
          child: widget.hoverItemBuilder!(ctx, index),
        );
      },
    );
  }

  Widget _builderItem(BuildContext context, int index) {
    HoverAbstractModel bean = widget.data[index];
    if (!bean.shouldShowHover || widget.hoverItemBuilder == null) {
      return widget.itemBuilder(context, index);
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        widget.hoverItemBuilder!(context, index),
        widget.itemBuilder(context, index),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        widget.itemCount == 0
            ? Container()
            : ScrollablePositionedList.builder(
          itemCount: widget.itemCount,
          itemBuilder: (context, index) => _builderItem(context, index),
          itemScrollController: itemScrollController,
          itemPositionsListener: itemPositionsListener,
          physics: widget.physics,
          padding: widget.padding,
        ),
        _builderHoverWidget(context),
      ],
    );
  }
}
