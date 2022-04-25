import 'dart:math';

import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';
import 'package:my_gallery/modules/flu_app/config/k_printer.dart';

/// @fileName custom_game.dart
/// @description 游戏Flame
/// @date 2022/4/24 16:42
/// @author LiuChuanan
/// FlameGame 生命周期方法
/// 游戏初次添加到 Flutter 的 Widget 树时会回调 onGameResize, 然后依次回调 onLoad、onMount ，之后将循环调用 update 和 render 方法，当游戏从 Flutter 的 Widget 树中移除时调用 onRemove 方法。
/// 当游戏画布大小发生改变时会回调 onGameResize 方法，可以再该方法里重新初始化游戏里相关元素的大小和位置。
/// onLoad 在整个 FlameGame 的生命周期里只会调用一次，而其他生命周期方法都可能会多次调用，所以我们可以在 onLoad 中进行游戏的一些初始化工作。
class CustomGame extends FlameGame {


  final Paint paint = Paint()..color = Color.fromARGB(255, 35, 35, 38);
  final Path canvasPath = Path();


  @override
  void onGameResize(Vector2 canvasSize) {
    super.onGameResize(canvasSize);
    kPrinter("1游戏初次添加到Flutter的Widget树时会回调onGameResize方法");
  }

  @override
  Future<void>? onLoad() {
    kPrinter("2然后依次调用onLoad方法，onLoad方法在整个FlameGame的生命周期里只会调用一次，而其他的生命周期方法可能会多次调用，所以可以在onLoad方法进行游戏的一些初始化工作");
    canvasPath.addRect(Rect.fromLTWH(0, 0, canvasSize.x, canvasSize.y));
    return super.onLoad();
  }

  @override
  void onMount() {
    super.onMount();
    kPrinter("3然后依次调用onMount方法");
  }


  /// methodName render
  /// description render方法用于渲染，有一个参数canvas，我们可以在render方法里通过canvas绘制我们想要的游戏内容
  /// date 2022/4/24 16:28
  /// author LiuChuanan
  @override
  void render(Canvas canvas){
    super.render(canvas);
    kPrinter("CustomGame printer");
    canvas.drawPath(canvasPath, paint);
  }

  /// methodName update
  /// description 用于游戏更新 dt参数表示时间间隔，单位是秒，即间隔多久调用一次update和render方法
  /// date 2022/4/24 16:27
  /// author LiuChuanan
  @override
  void update(double dt) {
    super.update(dt);
    kPrinter("CustomGame update");
  }

  @override
  void onRemove() {
    super.onRemove();
    kPrinter("当游戏从Flutter的Widget树中移除时调用onRemove");
  }


}


class TargetComponent {
  final Vector2 position;
  final Vector2 originPosition;
  final double radius;
  late Paint paint = Paint()..color = Colors.greenAccent;
  late Path path = Path()..addOval(Rect.fromLTWH(position.x - radius, position.y - radius, radius * 2, radius *2));
  TargetComponent({required this.position, this.radius = 20}) : originPosition = Vector2(position.x, position.y);

  void render(Canvas canvas){
    canvas.drawCircle(position.toOffset(), radius, paint);
  }

  void onDragUpdate(int pointerId, DragUpdateInfo info) {
    var eventPosition = info.eventPosition.game;
    position.setValues(eventPosition.x, eventPosition.y);
    _updatePath();
  }

  void resetPosition() {
    position.setValues(originPosition.x, originPosition.y);
    _updatePath();
  }

  void _updatePath() {
    path.reset();
    path.addOval(Rect.fromLTWH(position.x - radius, position.y - radius, radius * 2, radius * 2));
  }

}

class BulletComponent {
  final Vector2 position;
  final double speed;
  final double angle;
  final double radius;
  late Paint paint = Paint()..color = Colors.orangeAccent;
  late Path path = Path()..addOval(Rect.fromLTWH(position.x - radius, position.y - radius, radius * 2, radius * 2));
  BulletComponent({required this.position, this.speed = 5, this.angle = 0, this.radius = 10});

  void render(Canvas canvas) {
    canvas.drawCircle(position.toOffset(), radius, paint);
  }

  void update(double dt) {
    position.setValues(position.x - cos(angle) * speed, position.y - sin(angle) * speed);
    path.reset();
    path.addOval(Rect.fromLTWH(position.x - radius, position.y - radius, radius * 2, radius * 2));
  }
}

class StickGame extends FlameGame with HasDraggables{
  late TargetComponent target;

  bool isDrag = false;


  @override
  onDragStart(int pointerId, DragStartInfo info){
    super.onDragStart(pointerId, info);
    if (target.path.contains(info.eventPosition.game.toOffset())) {
      isDrag = true;
    }
  }

  @override
  void onDragUpdate(int pointerId, DragUpdateInfo info) {
    super.onDragUpdate(pointerId, info);
    var eventPosition = info.eventPosition.game;
    if (eventPosition.x < target.radius ||
        eventPosition.x > canvasSize.x - target.radius ||
        eventPosition.y < target.radius ||
        eventPosition.y > canvasSize.y - target.radius) {
      return;
    }

    if (isDrag) {
      target.onDragUpdate(pointerId, info);
    }
  }

  @override
  void onDragCancel(int pointerId) {
    super.onDragCancel(pointerId);
    isDrag = false;
  }

  @override
  void onDragEnd(int pointerId, DragEndInfo info) {
    super.onDragEnd(pointerId, info);
    isDrag = false;
  }

  @override
  Future<void>? onLoad() {
    target = TargetComponent(position: Vector2(canvasSize.x/2, canvasSize.y/2));
    return super.onLoad();
  }

  @override
  void render(Canvas canvas) {
    target.render(canvas);
    super.render(canvas);
  }
}