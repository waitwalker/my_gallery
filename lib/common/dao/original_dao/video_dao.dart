import 'package:my_gallery/model/video_source_model.dart';
import 'package:my_gallery/model/video_url_model.dart';
import 'package:my_gallery/common/const/api_const.dart';
import 'package:my_gallery/common/network/network_manager.dart';
import 'package:my_gallery/common/network/response.dart';

class VideoDao {
  static Future<ResponseData> getVideoUrl(String courseId) async {
    var url = APIConst.kBaseServerURL + 'api-study-service/api/lives/download?onlineCourseId=$courseId';
    var response = await NetworkManager.netFetch(url, null, null, null);
    if (response.result) {
      var model = VideoUrlModel.fromJson(response.data);
      response.model = model;
    }
    return response;
  }

  /// 获取视频播放源列表
  static Future<ResponseData> getVideoSource() async {
    var url =
        APIConst.kBaseServerURL + 'api-resource-service/api/resources/lines';
    var response = await NetworkManager.netFetch(url, null, null, null);
    if (response.result) {
      var model = VideoSourceModel.fromJson(response.data);
      response.model = model;
    }
    return response;
  }
}
