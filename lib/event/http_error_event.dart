
///
/// @description 网络请求事件封装
/// @author waitwalker
/// @time 2021/5/7 14:45
///
class HttpErrorEvent {
  final int? code;

  final String message;

  HttpErrorEvent(this.code, this.message);
}
