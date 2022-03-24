import 'package:event_bus/event_bus.dart';
import 'package:my_gallery/flu_app/isolate/isolate_event.dart';

///
/// @ClassName Isolate借助eventBus发送消息
/// @Description
/// @Author waitwalker
/// @Date 2022/1/25
///
class IsolateFire {
  static final eventBus = EventBus();

  static sendNotify(int code, String? message){
    eventBus.fire(IsolateEvent(code, message));
  }
}