import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';

/// @fileName refresh_custom.dart
/// @description 下拉刷新 刷新header统一配置，其他参数可选
/// @date 2022/3/24 2:07 下午
/// @author LiuChuanan
class RefreshCustom extends StatelessWidget {
  /// 控制器
  final EasyRefreshController? controller;

  /// 刷新回调(null为不开启刷新)
  final OnRefreshCallback? onRefresh;

  /// 加载回调(null为不开启加载)
  final OnLoadCallback? onLoad;

  /// 是否开启控制结束刷新
  final bool enableControlFinishRefresh;

  /// 是否开启控制结束加载
  final bool enableControlFinishLoad;

  /// 任务独立(刷新和加载状态独立)
  final bool taskIndependence;

  /// Header
  final Header header;
  final int headerIndex;

  /// Footer
  final Footer? footer;

  /// 子组件构造器
  final EasyRefreshChildBuilder? builder;

  /// 子组件
  final Widget? child;

  /// 首次刷新
  final bool firstRefresh;

  /// 首次刷新组件
  /// 不设置时使用header
  final Widget? firstRefreshWidget;

  /// 空视图
  /// 当不为null时,只会显示空视图
  /// 保留[headerIndex]以上的内容
  final Widget? emptyWidget;

  /// 顶部回弹(Header的overScroll属性优先，且onRefresh和header都为null时生效)
  final bool topBouncing;

  /// 底部回弹(Footer的overScroll属性优先，且onLoad和footer都为null时生效)
  final bool bottomBouncing;

  /// CustomListView Key
  final Key? listKey;

  /// 滚动行为
  final ScrollBehavior? behavior;

  /// Slivers集合
  final List<Widget>? slivers;

  /// 列表方向
  final Axis scrollDirection;

  /// 反向
  final bool reverse;
  final ScrollController? scrollController;
  final bool? primary;
  final bool shrinkWrap;
  final Key? center;
  final double anchor;
  final double? cacheExtent;
  final int? semanticChildCount;
  final DragStartBehavior dragStartBehavior;
  RefreshCustom(
      {Key? key,
        this.controller,
        this.onRefresh,
        this.onLoad,
        this.enableControlFinishRefresh = false,
        this.enableControlFinishLoad = false,
        this.taskIndependence = false,
        this.scrollController,
        this.footer,
        this.firstRefresh = false,
        this.firstRefreshWidget,
        this.headerIndex = 0,
        this.emptyWidget,
        this.topBouncing = true,
        this.bottomBouncing = true,
        this.behavior,
        required this.child,})
      : scrollDirection = Axis.vertical,
        reverse = false,
        builder = null,
        primary = null,
        shrinkWrap = false,
        center = null,
        anchor = 0.0,
        cacheExtent = null,
        slivers = null,
        semanticChildCount = null,
        dragStartBehavior = DragStartBehavior.start,
        listKey = null,
        header = BezierCircleCustomHeader(
        ),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return EasyRefresh(
      controller: controller,
      child: child,
      onRefresh: onRefresh,
      onLoad: onLoad,
      header: header,
      footer: footer,
      emptyWidget: emptyWidget,
      enableControlFinishLoad: enableControlFinishLoad,
      enableControlFinishRefresh: enableControlFinishRefresh,
      taskIndependence: taskIndependence,
      firstRefresh: firstRefresh,
      firstRefreshWidget: firstRefreshWidget,
      headerIndex: headerIndex,
      topBouncing: topBouncing,
      bottomBouncing: bottomBouncing,
      behavior: behavior,
      scrollController: scrollController,
    );
  }
}

/// 弹出圆圈Header
class BezierCircleCustomHeader extends Header {
  /// Key
  final Key? key;

  /// 颜色
  final Color? color;

  /// 背景颜色
  final Color? backgroundColor;

  final LinkHeaderNotifier linkNotifier = LinkHeaderNotifier();

  BezierCircleCustomHeader({
    this.key,
    this.color = Colors.white,
    this.backgroundColor = Colors.blue,
    bool enableHapticFeedback = false,
  }) : super(
    extent: 80.0,
    triggerDistance: 80.0,
    float: false,
    enableHapticFeedback: enableHapticFeedback,
    enableInfiniteRefresh: false,
    completeDuration: const Duration(seconds: 1),
  );

  @override
  Widget contentBuilder(
      BuildContext context,
      RefreshMode refreshState,
      double pulledExtent,
      double refreshTriggerPullDistance,
      double refreshIndicatorExtent,
      AxisDirection axisDirection,
      bool float,
      Duration? completeDuration,
      bool enableInfiniteRefresh,
      bool success,
      bool noMore) {
    // 不能为水平方向以及反向
    assert(axisDirection == AxisDirection.down,
    'Widget can only be vertical and cannot be reversed');
    linkNotifier.contentBuilder(
        context,
        refreshState,
        pulledExtent,
        refreshTriggerPullDistance,
        refreshIndicatorExtent,
        axisDirection,
        float,
        completeDuration,
        enableInfiniteRefresh,
        success,
        noMore);
    return BezierCircleCustomHeaderWidget(
      key: key,
      color: color,
      backgroundColor: backgroundColor,
      linkNotifier: linkNotifier,
    );
  }
}

/// 弹出小球组件
class BezierCircleCustomHeaderWidget extends StatefulWidget {
  /// 颜色
  final Color? color;

  /// 背景颜色
  final Color? backgroundColor;

  final LinkHeaderNotifier linkNotifier;

  const BezierCircleCustomHeaderWidget({
    Key? key,
    this.color,
    this.backgroundColor,
    required this.linkNotifier,
  }) : super(key: key);

  @override
  BezierCircleCustomHeaderWidgetState createState() {
    return BezierCircleCustomHeaderWidgetState();
  }
}

class BezierCircleCustomHeaderWidgetState extends State<BezierCircleCustomHeaderWidget>
    with TickerProviderStateMixin<BezierCircleCustomHeaderWidget> {
  RefreshMode get _refreshState => widget.linkNotifier.refreshState;

  double get _pulledExtent => widget.linkNotifier.pulledExtent;

  double get _indicatorExtent => widget.linkNotifier.refreshIndicatorExtent;

  bool get _noMore => widget.linkNotifier.noMore;

  // 回弹动画
  late AnimationController _backController;
  late Animation<double> _backAnimation;
  final double _backAnimationLength = 110.0;
  double _backAnimationPulledExtent = 0.0;
  bool _showBackAnimation = false;

  set showBackAnimation(bool value) {
    if (_showBackAnimation != value) {
      _showBackAnimation = value;
      if (_showBackAnimation) {
        _backAnimationPulledExtent = _pulledExtent - _indicatorExtent;
        _backAnimation = Tween(
            begin: 0.0,
            end: _backAnimationLength + _backAnimationPulledExtent)
            .animate(_backController);
        _backController.reset();
        _backController.forward();
      }
    }
  }

  // 弹出圆圈动画
  bool _toggleCircle = false;

  set toggleCircle(bool value) {
    if (_toggleCircle != value) {
      _toggleCircle = value;
      if (_toggleCircle) {
        Future.delayed(const Duration(milliseconds: 400), () {
          if (mounted) {
            setState(() {
              _progressValue = null;
            });
          }
        });
      }
    }
  }

  // 环形进度
  double? _progressValue = 0.0;

  @override
  void initState() {
    super.initState();
    // 回弹动画
    _backController = AnimationController(
        duration: const Duration(milliseconds: 600), vsync: this);
    _backAnimation =
        Tween(begin: 0.0, end: _backAnimationLength).animate(_backController);
  }

  @override
  void dispose() {
    _backController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_noMore) {
      return Container();
    }
    // 启动回弹动画
    if (_refreshState == RefreshMode.armed) {
      showBackAnimation = true;
    } else if (_refreshState == RefreshMode.refreshed) {
      if (_progressValue == null) {
        _progressValue = 1.0;
        Future.delayed(const Duration(milliseconds: 200), () {
          if (mounted && _toggleCircle) {
            setState(() {
              _progressValue = 0.0;
              toggleCircle = false;
            });
          }
        });
      }
    } else if (_refreshState == RefreshMode.done) {
      _progressValue = 0.0;
      toggleCircle = false;
    } else if (_refreshState == RefreshMode.inactive) {
      showBackAnimation = false;
      _progressValue = 0.0;
      toggleCircle = false;
    }
    return Stack(
      children: <Widget>[
        Positioned(
          bottom: 0.0,
          left: 0.0,
          right: 0.0,
          child: Column(
            children: <Widget>[
              Container(
                height: _indicatorExtent,
                width: double.infinity,
                color: widget.backgroundColor,
                child: Stack(
                  children: <Widget>[
                    Positioned(
                      bottom: -40.0,
                      left: 0.0,
                      right: 0.0,
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: AnimatedContainer(
                          alignment: Alignment.center,
                          margin: EdgeInsets.only(
                              bottom: _toggleCircle ? 65.0 : 0.0),
                          duration: const Duration(milliseconds: 400),
                          width: 30.0,
                          height: 30.0,
                          decoration: BoxDecoration(
                            color: widget.color,
                            borderRadius:
                            const BorderRadius.all(Radius.circular(15.0)),
                          ),
                        ),
                      ),
                    ),
                    Center(
                      child: CircularProgressIndicator(
                        value: _progressValue,
                        strokeWidth: 2.0,
                        valueColor: AlwaysStoppedAnimation(widget.color),
                      ),
                    ),
                    AnimatedBuilder(
                      animation: _backAnimation,
                      builder: (context, child) {
                        double offset = 0.0;
                        if (_backAnimation.value >=
                            _backAnimationPulledExtent) {
                          var animationValue =
                              _backAnimation.value - _backAnimationPulledExtent;
                          if (animationValue > 0 && animationValue != 110.0) {
                            toggleCircle = true;
                          }
                          if (animationValue <= 30.0) {
                            offset = animationValue;
                          } else if (animationValue > 30.0 &&
                              animationValue <= 50.0) {
                            offset = (20.0 - (animationValue - 30.0)) * 3 / 2;
                          } else if (animationValue > 50.0 &&
                              animationValue < 65.0) {
                            offset = animationValue - 50.0;
                          } else if (animationValue > 65.0) {
                            offset = (45.0 - (animationValue - 65.0)) / 3;
                          }
                        }
                        return ClipPath(
                          clipper: _CircleCustomPainter(offset: offset, up: false),
                          child: child,
                        );
                      },
                      child: Container(
                        color: widget.color,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: double.infinity,
                height: _pulledExtent > _indicatorExtent
                    ? _pulledExtent - _indicatorExtent
                    : 0.0,
                child: ClipPath(
                  clipper: _CircleCustomPainter(
                    offset: _showBackAnimation
                        ? _backAnimation.value < _backAnimationPulledExtent
                        ? _backAnimationPulledExtent - _backAnimation.value
                        : 0.0
                        : (_pulledExtent > _indicatorExtent &&
                        _refreshState != RefreshMode.refresh &&
                        _refreshState != RefreshMode.refreshed &&
                        _refreshState != RefreshMode.done
                        ? _pulledExtent - _indicatorExtent
                        : 0.0),
                    up: true,
                  ),
                  child: Container(
                    color: widget.backgroundColor,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// 圆面切割
class _CircleCustomPainter extends CustomClipper<Path> {
  final double offset;
  final bool up;

  _CircleCustomPainter({required this.offset, required this.up});

  @override
  Path getClip(Size size) {
    final path = Path();
    if (!up) {
      path.moveTo(0.0, size.height);
    }
    path.cubicTo(
        0.0,
        up ? 0.0 : size.height,
        size.width / 2,
        up ? offset * 2 : size.height - offset * 2,
        size.width,
        up ? 0.0 : size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper oldClipper) {
    return oldClipper != this;
  }
}


/// @fileName RefreshExample.dart
/// @description 演示刷新
/// @date 2022/3/24 2:03 下午
/// @author LiuChuanan
class RefreshExample extends StatefulWidget {
  final String title;
  const RefreshExample({Key? key, required this.title}) : super(key: key);

  @override
  _RefreshExampleState createState() {
    return _RefreshExampleState();
  }
}

class _RefreshExampleState extends State<RefreshExample> {
  late EasyRefreshController _controller;

  @override
  void initState() {
    super.initState();
    _controller = EasyRefreshController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("EasyRefresh"),
        ),
        body: RefreshCustom(
          enableControlFinishRefresh: false,
          enableControlFinishLoad: true,
          controller: _controller,
          onRefresh: () async {
            await Future.delayed(const Duration(seconds: 2), () {
              setState(() {

              });
              _controller.resetLoadState();
            });
          },
          child: _buildGrid(),
        ),
    );
  }

  /// methodName _buildSliver
  /// description sliver组件
  /// date 2022/3/24 2:04 下午
  /// author LiuChuanan
  // _buildSliver() {
  //   return CustomScrollView(
  //     slivers: [
  //       SliverAppBar(
  //         floating: _floating,
  //         snap: _snap,
  //         pinned: _pinned,
  //         expandedHeight: 260,
  //         elevation: 0,
  //         flexibleSpace: FlexibleSpaceBar(
  //           title: Text(_title, style: TextStyle(fontSize: 20, color: Colors.red, fontWeight: FontWeight.bold),),
  //           background: Image.network("http://img1.mukewang.com/5c18cf540001ac8206000338.jpg",
  //             fit: BoxFit.cover,
  //           ),
  //         ),
  //       ),
  //       renderWidget(),
  //       SliverList(delegate: SliverChildBuilderDelegate((context, index){
  //         //
  //         return Padding(padding: EdgeInsets.only(left: 20, bottom: 10, right: 20),
  //           child: Container(
  //             decoration: BoxDecoration(
  //               color: Colors.orange.withOpacity(0.6),
  //               borderRadius: BorderRadius.circular(10),
  //             ),
  //             height: 44,
  //             child: Text("$index",style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold,),),
  //           ),
  //         );
  //       },childCount: 30,)),
  //     ],
  //   );
  // }

  /// methodName _buildGrid
  /// description 常规组件
  /// date 2022/3/24 2:04 下午
  /// author LiuChuanan
  _buildGrid() {
    return GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          mainAxisSpacing: 20,
          crossAxisSpacing: 20,
        ),
        itemCount: 100,
        itemBuilder: (context, index){
          return SizedBox(height: 44, child: Text("$index"),);
        });
  }
  // int currentIndex = 1;
  // bool _floating = true;
  // bool _snap = false;
  // bool _pinned = false;
  // String _title = "Floating";

  // Widget renderWidget() {
  //   return SliverToBoxAdapter(
  //     child: InkWell(
  //       child: Padding(padding: EdgeInsets.only(bottom: 10),
  //         child: Container(
  //           alignment: Alignment.center,
  //           height: 80,
  //           color: Colors.green,
  //           child: Text("切换", style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),),
  //         ),
  //       ),
  //       onTap: (){
  //         currentIndex++;
  //         if (currentIndex > 3) {
  //           currentIndex = 1;
  //         }
  //         if (currentIndex == 1) {
  //           _floating = true;
  //           _snap = false;
  //           _pinned = false;
  //           _title = "Floating";
  //         } else if (currentIndex == 2) {
  //           _floating = true;
  //           _snap = true;
  //           _pinned = false;
  //           _title = "Snap";
  //         } else {
  //           _floating = false;
  //           _snap = false;
  //           _pinned = true;
  //           _title = "Pinned";
  //         }
  //         setState(() {
  //
  //         });
  //       },
  //     ),
  //   );
  // }
}

