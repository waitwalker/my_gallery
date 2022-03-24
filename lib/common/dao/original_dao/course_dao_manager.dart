import 'dart:convert';
import 'package:my_gallery/model/ab_test_model.dart';
import 'package:my_gallery/model/ai_model.dart';
import 'package:my_gallery/model/ai_score_model.dart';
import 'package:my_gallery/model/base_model.dart';
import 'package:my_gallery/model/error_book_model.dart';
import 'package:my_gallery/model/errorbook_detail_model.dart';
import 'package:my_gallery/model/errorbook_list_model.dart';
import 'package:my_gallery/model/live_detail_model.dart';
import 'package:my_gallery/model/live_schedule_model.dart';
import 'package:my_gallery/model/message_detail_model.dart';
import 'package:my_gallery/model/message_list_model.dart';
import 'package:my_gallery/model/micro_course_resource_model.dart';
import 'package:my_gallery/modules/my_course/activity_course/activity_entrance_model.dart';
import 'package:my_gallery/model/my_course_model.dart';
import 'package:my_gallery/model/order_list_model.dart';
import 'package:my_gallery/model/resource_info_model.dart';
import 'package:my_gallery/model/wisdom_model.dart';
import 'package:my_gallery/model/wisdom_child_list_model.dart';
import 'package:my_gallery/model/subject_detail_model.dart';
import 'package:my_gallery/model/unread_count_model.dart';
import 'package:my_gallery/common/const/api_const.dart';
import 'package:my_gallery/common/network/network_manager.dart';
import 'package:my_gallery/common/network/response.dart';
import 'package:dio/dio.dart';
import 'package:meta/meta.dart';
import 'package:my_gallery/modules/my_course/wisdom_study/wisdom_resource_model.dart';

class CourseDaoManager {

  static liveDetail(String courseId) async {
    var url = APIConst.kBaseServerURL +
        'api-study-service/api/course/online/info?onlineCourseId=$courseId';
    var response = await NetworkManager.netFetch(url, null, null, null);
    if (response.result) {
      var courseList = LiveDetailModel.fromJson(response.data);

      response.model = courseList;
    }
    return response;
  }

  /// 课程表
  /// http://int.etiantian.com:39804/display/zz/NEW-ETT-API-09-V1.0
  static Future<ResponseData> liveSchedule(var startTime, var endTime) async {
    var url = APIConst.kBaseServerURL +
        'api-study-service/api/course/online/info?startTime=$startTime&endTime=$endTime';
    var response = await NetworkManager.netFetch(url, null, null, null);
    if (response.result) {
      var courseList = LiveDetailModel.fromJson(response.data);

      response.model = courseList;
    }
    return response;
  }

  /// 智慧学习 章 节 知识点 资源。
  /// 4级列表分层请求
  /// type=1，章节，附带资源
  /// type=2，节，附带资源
  /// type=3，知识点，附带资源
  /// http://192.168.10.8:8090/display/zz/NEW-ETT-API-20-V2.0
  static Future<ResponseData> wisdomChapterChildList(versionId, materialId, type,
      [nodeId]) async {
    var url =
        APIConst.kBaseServerURL + 'api-service-course-wx/wx-chapter/tree';
    var map = {
      'versionId': versionId.toString(),
      'materialId': materialId.toString(),
      'type': type.toString()
    };
    if (nodeId != null) {
      map['nodeId'] = nodeId!.toString();
    }
    var query = mapToQuery(map);
    url += '?$query';
    var response = await NetworkManager.netFetch(url, null, null, null);
    if (response.result) {
      var courseList = WisdomChildListModel.fromJson(response.data);
      response.model = courseList;
    }
    return response;
  }

  /// http://192.168.10.8:8090/display/zz/NEW-ETT-API-33-V2.0
  ///
  /// @description 智慧学习列表 目前用这个
  /// @param 
  /// @return 
  /// @author waitwalker
  /// @time 2020/11/11 5:15 PM
  ///
  static Future<ResponseData> wisdomListFetch(materialId) async {
    var url = APIConst.kBaseServerURL + 'api-service-course-wx/wx-chapter/node/points';

    var map = {'materialId': materialId.toString()};
    var query = mapToQuery(map);
    url += '?$query';
    var response = await NetworkManager.netFetch(url, null, null, null);
    if (response.result) {
      var courseList = WisdomModel.fromJson(response.data);
      response.model = courseList;
    }
    return response;
  }

  /// http://192.168.10.8:8090/display/zz/NEW-ETT-API-33-V2.0
  ///
  /// @description 智慧学习列表
  /// @param
  /// @return
  /// @author waitwalker
  /// @time 2020/11/11 5:15 PM
  ///
  static Future<ResponseData> wisdomReviewListFetch(materialId, isReview) async {
    var url = APIConst.kBaseServerURL +
        'api-service-course-wx/wx-chapter/node/points';
    var map = {
      'materialId': materialId.toString(),
      'isReview' : isReview.toString(),
    };
    var query = mapToQuery(map);
    url += '?$query';
    var response = await NetworkManager.netFetch(url, null, null, null);
    if (response.result) {
      var courseList = WisdomModel.fromJson(response.data);
      response.model = courseList;
    }
    return response;
  }

  ///
  /// @description 智慧学习列表
  /// @param
  /// @return
  /// @author waitwalker
  /// @time 2020/11/11 5:15 PM
  ///
  static Future<ResponseData> wisdomListFetchCourseStructure(materialId) async {
    // var url = "http://192.168.10.63:7300/mock/5f45ba0acaaf03283394c249/base/wisdom/list";
    var url = APIConst.kBaseServerURL + 'api-service-course-wx/wx-chapter/node/points/tree';
    var map = {'materialId': materialId.toString()};
    var query = mapToQuery(map);
    url += '?$query';
    var response = await NetworkManager.netFetch(url, null, null, null);
    if (response.result) {
      var courseList = WisdomModel.fromJson(response.data, canMinus: true);
      response.model = courseList;
    }
    return response;
  }

  ///
  /// @description 智慧学习列表
  /// @param
  /// @return
  /// @author waitwalker
  /// @time 2020/11/11 5:15 PM
  ///
  static Future<ResponseData> wisdomResourceFetchCourseStructure(para) async {
    // var url = "http://192.168.10.63:7300/mock/5f45ba0acaaf03283394c249/base/detail";
    var url = APIConst.kBaseServerURL + 'api-service-course-wx/wx-chapter/node/points/resource';
    url += '?$para';
    var response = await NetworkManager.netFetch(url, null, null, null);
    if (response.result) {
      var courseList = WisdomResourceModel.fromJson(response.data);
      response.model = courseList;
    }
    return response;
  }

  /// http://192.168.10.8:8090/display/shuzixiaoyuan/JIAOXUE-SERVICE-API-253
  static Future<ResponseData> aiStudyList(materialId) async {
    var url = APIConst.kBaseServerURL +
        'api-service-general-wx/student-class/chapters';
    var map = {'materialId': materialId.toString()};
    var query = mapToQuery(map);
    url += '?$query';
    var response = await NetworkManager.netFetch(url, null, null, null);
    if (response.result) {
      var courseList = AiModel.fromJson(response.data);
      response.model = courseList;
    }
    return response;
  }

  ///
  /// @description 获取资源信息
  /// @param 
  /// @return 
  /// @author waitwalker
  /// @time 2020/11/11 11:52 AM
  ///
  static Future<ResponseData> getResourceInfo(resourceId, {int? lineId}) async {
    var url = APIConst.kBaseServerURL + 'api-resource-service/api/resources/';
    url = '$url$resourceId';
    if (lineId != null) {
      url += '?lineId=$lineId';
    }
    var response = await NetworkManager.netFetch(url, null, null, null);
    if (response.result) {
      var courseList = ResourceInfoModel.fromJson(response.data);
      response.model = courseList;
    }
    return response;
  }

  static Future<ResponseData> getMicroCourseResourceInfo(resourceId) async {
    var url =
        APIConst.kBaseServerURL + 'api-resource-service/api/resources/wk/';
    url = '$url$resourceId';
    var response = await NetworkManager.netFetch(url, null, null, null);
    if (response.result) {
      var courseList = MicroCourseResourceModel.fromJson(response.data);
      response.model = courseList;
    }
    return response;
  }

  static Future<ResponseData> getExerciseHistory(resourceId,
      {bool fromMicroCourse = true}) async {
    var url;
    var map = <String, String>{};
    if (fromMicroCourse) {
      url = APIConst.kBaseServerURL + 'api-study-service/api/papers/list';
      map['resourceId'] = resourceId.toString();
    } else {
      // ab测试
      url = APIConst.kBaseServerURL + 'api-study-service/api/ab-papers/list';
      map['srcAbPaperId'] = resourceId.toString();
    }
    var query = mapToQuery(map);
    url += '?$query';
    var response = await NetworkManager.netFetch(url, null, null, null);
    if (response.result) {
      var courseList = AbTestModel.fromJson(response.data);
      response.model = courseList;
    }
    return response;
  }

  static Future<ResponseData> getOrderList() async {
    var url = APIConst.kBaseServerURL +
        'api-study-service/api/card/user/course/card';
    var response = await NetworkManager.netFetch(url, null, null, null);
    if (response.result) {
      var courseList = OrderListModel.fromJson(response.data);
      response.model = courseList;
    }
    return response;
  }

  static Future<ResponseData> feedback(
      {required String courseId,
      String courseType = '3',
      required String content,
      String? contact,
      String? deviceType,
      String? systemVersion,
      String? appVersion}) async {
    var url = APIConst.kBaseServerURL + 'api-study-service/api/feedbacks';
    var body = jsonEncode({
      "courseId": courseId,
      "courseType": courseType,
      "content": content,
      "contact": contact,
      "deviceType": deviceType,
      "systemVersion": systemVersion,
      "appVersion": appVersion
    });
    var headers = {'content-type': 'application/json'};
    var response =
        await NetworkManager.netFetch(url, body, headers, Options(method: 'POST'));
    if (response.result) {
      var model = BaseModel.fromJson(response.data);
      response.model = model;
    }
    return response;
  }

  /// 打分，评分，rating
  /// courseType: 不传，默认反馈的是课程卡下的课程，类型为3
  /// typeId: 1 评价课程 2 评价老师
  static Future<ResponseData> rating(
      {required String courseId,
      String courseType = '3',
      String typeId = '1',
      required String score}) async {
    var url = APIConst.kBaseServerURL + 'api-study-service/api/evaluates';
    var body = jsonEncode({
      "courseId": courseId,
      "courseType": courseType,
      "typeId": typeId,
      "score": score
    });
    var headers = {'content-type': 'application/json'};
    var response =
        await NetworkManager.netFetch(url, body, headers, Options(method: 'POST'));
    if (response.result) {
      var model = BaseModel.fromJson(response.data);
      response.model = model;
    }
    return response;
  }

  /// 新版首页学科列表
  /// See http://int.etiantian.com:39804/display/zz/NEW-ETT-API-64-V1.1  这个是9个学科
  /// http://int.etiantian.com:39804/display/zz/NEW-ETT-API-65-V2.3  这个是10个学科
  static Future<ResponseData> newCourses() async {
    var url = APIConst.kBaseServerURL + 'api-study-service/api/course/v2.3/courses';
    var response = await NetworkManager.netFetch(url, null, null, null);
    if (response.result) {
      var model = MyCourseModel.fromJson(response.data);
      response.model = model;
    }
    return response;
  }

  /// http://int.etiantian.com:39804/display/zz/NEW-ETT-API-65-V2.1
  /// cardType: 1: 普通卡，和courseId配合使用
  /// cardType: 2: 智领卡，和gradeId，subjectId配合使用
  /// cardType: 3: 智学卡，和gradeId，subjectId配合使用
  static subjectDetail({int? gradeId, int? subjectId, num? courseId, int? cardType = 2}) async {
    var url = APIConst.kBaseServerURL + 'api-study-service/api/course/v2.1/courses/grade/subject';
    var map;
    if (courseId == null) {
      map = {
        'gradeId': gradeId.toString(),
        'subjectId': subjectId.toString(),
        'cardType': cardType.toString(),
      };
    } else {
      map = {'cardType': cardType.toString(), 'courseId': courseId.toString()};
    }
    var query = mapToQuery(map);
    url += '?$query';
    var response = await NetworkManager.netFetch(url, null, null, null);
    if (response.result) {
      var courseList = SubjectDetailModel.fromJson(response.data);
      response.model = courseList;
    }
    return response;
  }

  /// http://int.etiantian.com:39804/display/zz/NEW-ETT-API-66-V2.1
  /// 专题讲解列表
  /// [typeId] 0=当前 1=预告 2=回放
  static Future<ResponseData> liveScheduleNew(
      {required int? gradeId, required int? subjectId, int? typeId}) async {
    var url = APIConst.kBaseServerURL + 'api-study-service/api/lives/plans';
    var body = jsonEncode(
        {"gradeId": gradeId, "subjectId": subjectId, "typeId": typeId});
    var headers = {'content-type': 'application/json'};
    var response =
        await NetworkManager.netFetch(url, body, headers, Options(method: 'POST'));
    if (response.result) {
      var model = LiveScheduleModel.fromJson(response.data);
      response.model = model;
    }
    return response;
  }

  /// http://int.etiantian.com:39804/display/zz/NEW-ETT-API-68-V2.1
  static Future<ResponseData> activityInfo() async {
    var url = APIConst.kBaseServerURL + 'api-study-service/api/activity/prompt';
    var response = await NetworkManager.netFetch(url, null, null, null);
    if (response.result) {
      var model = ActivityEntranceModel.fromJson(response.data);
      response.model = model;
    }
    return response;
  }

  /// http://int.etiantian.com:39804/display/zz/NEW-ETT-API-68-V2.1
  static Future<ResponseData> fetchUpgradeInfo() async {
    var url = APIConst.kBaseServerURL + 'api-study-service/api/activity/prompt';
    var response = await NetworkManager.netFetch(url, null, null, null);
    if (response.result) {
      var model = ActivityEntranceModel.fromJson(response.data);
      response.model = model;
    }
    return response;
  }

  static Future<ResponseData> aiScore(
      {required String? currentDirId,
      required String? subjectId,
      required String? versionId,
      int classId = -1,
      int taskId = -1}) async {
    var url =
        APIConst.kBaseServerURL + 'api-service-honeycomb/intelligentsia/v2';
    var body = jsonEncode({
      "currentDirId": currentDirId,
      "subjectId": subjectId,
      "versionId": versionId,
      "classId": classId,
      "taskId": taskId,
    });
    var headers = {'content-type': 'application/json'};
    var response =
        await NetworkManager.netFetch(url, body, headers, Options(method: 'POST'));
    if (response.result) {
      var model = AiScoreModel.fromJson(response.data);
      response.model = model;
    }
    return response;
  }

  /// 保存错题本
  /// http://192.168.10.8:8090/display/zz/NEW-ETT-API-80-V1.2.4
  static Future<ResponseData> saveErrorBook({
    required int gradeId,
    required int subjectId,
    required String wrongReason,
    required String? photoUrl,
  }) async {
    var url =
        APIConst.kBaseServerURL + 'api-study-service/api/wrong-notebook/photo';
    var body = jsonEncode({
      "gradeId": gradeId,
      "subjectId": subjectId,
      "wrongReason": wrongReason,
      "photoUrl": photoUrl,
    });
    var headers = {'content-type': 'application/json'};
    var response =
        await NetworkManager.netFetch(url, body, headers, Options(method: 'POST'));
    if (response.result) {
      var model = AiScoreModel.fromJson(response.data);
      response.model = model;
    }
    return response;
  }

  /// http://192.168.10.8:8090/display/zz/NEW-ETT-API-76-V1.2.4
  static messageList({int? pageSize, int? currentPage}) async {
    var url = APIConst.kBaseServerURL + 'api-study-service/api/message/user';
    var map = {
      'pageSize': pageSize.toString(),
      'currentPage': currentPage.toString(),
    };
    var query = mapToQuery(map);
    url += '?$query';
    var response = await NetworkManager.netFetch(url, null, null, null);
    if (response.result) {
      var courseList = MessageListModel.fromJson(response.data);

      response.model = courseList;
    }
    return response;
  }

  /// http://192.168.10.8:8090/display/zz/NEW-ETT-API-78-V1.2.4
  static setMessageStatus({int? msgId, int? status}) async {
    var url =
        APIConst.kBaseServerURL + 'api-study-service/api/message/user/lable';
    var map = {
      'msgId': msgId.toString(),
      'lableStatus': status.toString(),
    };
    var query = mapToQuery(map);
    url += '?$query';
    var response = await NetworkManager.netFetch(url, null, null, Options(method: 'PUT'));
    if (response.result) {
      var model = BaseModel.fromJson(response.data);

      response.model = model;
    }
    return response;
  }

  /// http://192.168.10.8:8090/display/zz/NEW-ETT-API-81-V1.2.4
  /// 错题本列表
  static errorbookList(
      {int? pageSize, int? currentPage, int? gradeId, int? subjectId}) async {
    var url =
        APIConst.kBaseServerURL + 'api-study-service/api/wrong-notebook/photo';
    var map = {
      'pageSize': pageSize.toString(),
      'currentPage': currentPage.toString(),
      'subjectId': subjectId.toString(),
    };
    if (gradeId != null) {
      map['gradeId'] = gradeId.toString();
    }
    var query = mapToQuery(map);
    url += '?$query';
    var response = await NetworkManager.netFetch(url, null, null, null);
    if (response.result) {
      var courseList = ErrorbookListModel.fromJson(response.data);

      response.model = courseList;
    }
    return response;
  }

  /// 错题本详情
  /// http://192.168.10.8:8090/display/zz/NEW-ETT-API-84-V1.2.4
  static errorBookDetail({int? wrongPhotoId}) async {
    var url = APIConst.kBaseServerURL +
        'api-study-service/api/wrong-notebook/photo/info';
    var map = {
      'wrongPhotoId': wrongPhotoId.toString(),
    };
    var query = mapToQuery(map);
    url += '?$query';
    var response = await NetworkManager.netFetch(url, null, null, null);
    if (response.result) {
      var courseList = ErrorbookDetailModel.fromJson(response.data);

      response.model = courseList;
    }
    return response;
  }

  /// 未读消息数
  /// http://192.168.10.8:8090/display/zz/NEW-ETT-API-83-V1.2.4
  static unreadMsgCount() async {
    var url = APIConst.kBaseServerURL + 'api-study-service/api/message/unread';

    var response = await NetworkManager.netFetch(url, null, null, null);
    if (response.result) {
      var courseList = UnreadCountModel.fromJson(response.data);

      response.model = courseList;
    }
    return response;
  }

  /// 删除错题
  /// http://int.etiantian.com:39804/display/zz/NEW-ETT-API-85-V1.2.4
  static delErrorBook({String? wrongPhotoIds}) async {
    var url =
        APIConst.kBaseServerURL + 'api-study-service/api/wrong-notebook/photo';
    url += '?wrongPhotoIds=$wrongPhotoIds';
    var response =
        await NetworkManager.netFetch(url, null, null, Options(method: 'DELETE'));
    if (response.result) {
      var courseList = UnreadCountModel.fromJson(response.data);

      response.model = courseList;
    }
    return response;
  }

  /// 错题生成pdf
  /// http://int.etiantian.com:39804/display/zz/NEW-ETT-API-91-V1.2.6
  static getPdf({String? wrongPhotoIds}) async {
    var url =
        APIConst.kBaseServerURL + 'api-study-service/api/wrong-notebook/pdf/';
    url += '?wrongPhotoIds=$wrongPhotoIds';
    var response =
        await NetworkManager.netFetch(url, null, null, Options(method: 'DELETE'));
    if (response.result) {
      var courseList = UnreadCountModel.fromJson(response.data);

      response.model = courseList;
    }
    return response;
  }

  /// http://192.168.10.8:8090/display/zz/NEW-ETT-API-76-V1.2.4
  static messageDetail({int? msgId}) async {
    var url = APIConst.kBaseServerURL + 'api-study-service/api/message';
    url += '?msgId=$msgId';
    var response = await NetworkManager.netFetch(url, null, null, null);
    if (response.result) {
      var courseList = MessageDetailModel.fromJson(response.data);

      response.model = courseList;
    }
    return response;
  }

  /// 获取错题本学科统计列表
  /// http://192.168.10.8:8090/display/zz/NEW-ETT-API-61-V2.0  /// 系统错题
  /// http://192.168.10.8:8090/display/zz/NEW-ETT-API-82-V1.2.4   /// 拍照上传学科列表
  /// http://int.etiantian.com:39804/display/zz/NEW-ETT-API-86-V1.2.5 /// 数校错题
  /// http://int.etiantian.com:39804/display/zz/DYZJ-CTB-API-01-V1.0 /// 质检消错错题
  static Future<ResponseData> fetchErrorBookSubjectList(ErrorBookType type) async {
    var url = APIConst.kBaseServerURL +
        (type == ErrorBookType.CAMERA ? 'api-study-service/api/wrong-notebook/photo/subjects' :
        type == ErrorBookType.SHUXIAO ? 'api-study-service/api/wrong-notebook/school/subjects' :
        type == ErrorBookType.UNITTEST ? 'api-dyzj-service/api/wrong/notebook/subjects'
                : 'api-study-service/api/wrong-notebook/subjects');

    var response = await NetworkManager.netFetch(url, null, null, Options(method: 'GET'));
    if (response.result) {
      var model = ErrorBookModel.fromJson(response.data);
      response.model = model;
    }
    return response;
  }
}

/// [WEB]     网页错题
/// [CAMERA]  拍照错题
/// [SHUXIAO] 数校错题
/// [UNITTEST] 质检消错错题
enum ErrorBookType { WEB, SHUXIAO, CAMERA, UNITTEST }
