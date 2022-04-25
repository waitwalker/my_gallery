import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';
import 'package:my_gallery/modules/flu_app/config/k_printer.dart';

/// 游戏引擎Flame简单demo：https://juejin.cn/post/7087575465015115784
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

class TextComponent{
  final Vector2 position;
  String text;
  final Color textColor;
  double textSize;

  final Path path = Path();

  TextComponent({required this.position, required this.text, this.textColor = Colors.white, this.textSize = 40});


  void render(Canvas canvas){
    var textPainter = TextPainter(
        text: TextSpan(
            text: text,
            style: TextStyle(fontSize: textSize, color: textColor)),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr);
    textPainter.layout(); // 进行布局
    textPainter.paint(canvas, Offset(position.x - textPainter.width / 2 , position.y - textPainter.height/2)); // 进行绘制
    path.reset();
    path.addRect(Rect.fromLTWH(position.x - textPainter.width / 2, position.y - textPainter.height/2, textPainter.width, textPainter.height));
  }

}

class StickGame extends FlameGame with HasDraggables, HasTappables{
  late TargetComponent target;
  bool isDrag = false;

  final Paint paint = Paint()..color = const Color.fromARGB(255, 35, 36, 38);

  late Timer timer;
  List<BulletComponent> bullets = [];
  final Random random = Random();

  bool isRunning = false;
  double seconds = 0;

  late TextComponent score;
  late TextComponent restartText;

  final Path canvasPath = Path();
  final Vector2 scorePosition = Vector2(40, 40);

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

    if (isDrag && isRunning) {
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
  void onTapUp(int pointerId, TapUpInfo info) {
    super.onTapUp(pointerId, info);
    if(!isRunning && restartText.path.contains(info.eventPosition.game.toOffset())){
      restart();
    }
  }

  @override
  void onRemove() {
    isRunning = false;
    timer.stop();
    super.onRemove();
  }


  @override
  Future<void>? onLoad() {
    target = TargetComponent(position: Vector2(canvasSize.x/2, canvasSize.y/2));
    score = TextComponent(position: scorePosition.clone(), text: "0", textSize: 30);
    restartText = TextComponent(position: Vector2(canvasSize.x / 2, canvasSize.y / 2), text: "START", textSize: 50);
    timer = Timer(0.1, onTick: (){
      createBullet();
    }, repeat: true);
    return super.onLoad();
  }

  @override
  void render(Canvas canvas) {
    canvas.drawPath(canvasPath, paint);
    for(var bullet in bullets) {
      bullet.render(canvas);
    }
    target.render(canvas);
    score.render(canvas);
    if (!isRunning) {
      restartText.render(canvas);
    }
    super.render(canvas);
  }

  void createBullet() {
    bool isHorizontal = random.nextBool();
    var radius = random.nextInt(10) + 5;
    int x = isHorizontal ? random.nextInt(canvasSize.x.toInt()) : random.nextBool() ? radius : canvasSize.x.toInt() - radius;
    int y = isHorizontal ? random.nextBool() ? radius : canvasSize.y.toInt() - radius : random.nextInt(canvasSize.y.toInt());
    var position = Vector2(x.toDouble(), x - target.position.x);
    var angle = atan2(y - target.position.y, x - target.position.x);
    var speed = seconds/10 + 5;
    bullets.add(BulletComponent(position: position, angle: angle, radius: radius.toDouble(), speed: speed));
  }

  void stop() {
    isRunning = false;
    restartText.text = "RESTART";
    score.position.setValues(restartText.position.x, restartText.position.y - 80);
    score.text = "${seconds.toInt()}s";
    score.textSize = 40;
  }

  void restart() {
    isRunning = true;
    bullets.clear();
    target.resetPosition();
    score.position.setValues(scorePosition.x, scorePosition.y);
    score.textSize = 30;
    seconds = 0;
  }

  @override
  void update(double dt) {
    if (isRunning) {
      seconds += dt;
      score.text = "${seconds.toInt()}s";
      timer.update(dt);
      for (var bullet in bullets) {
         if (collisionCheck(bullet)) {
           stop();
           return;
         } else {
           bullet.update(dt);
         }
      }
    }
    super.update(dt);
  }

  bool collisionCheck(BulletComponent bullet){
    var tempPath = Path.combine(PathOperation.intersect, target.path, bullet.path);
    return tempPath.getBounds().width > 0;
  }

}