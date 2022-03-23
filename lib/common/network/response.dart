///
/// @description 网络请求数据响应
/// @author waitwalker
/// @time 3/22/21 2:20 PM
///
class ResponseData {
  var data;
  bool result;
  int? code;
  var headers;
  var model;

  ResponseData(this.data, this.result, this.code, {this.headers, this.model});
}
