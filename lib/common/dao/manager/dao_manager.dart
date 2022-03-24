import 'dart:convert';
import 'package:my_gallery/common/config/config.dart';
import 'package:my_gallery/common/logger/logger_manager.dart';
import 'package:my_gallery/model/base_model.dart';
import 'package:my_gallery/model/ett_pdf_model.dart';
import 'package:my_gallery/model/live_material_model.dart';
import 'package:my_gallery/common/const/api_const.dart';
import 'package:my_gallery/common/network/response.dart';
import 'package:my_gallery/common/network/network_manager.dart';
import 'package:my_gallery/modules/login/add_card_model.dart';
import 'package:my_gallery/modules/my_course/activity_course/college_entrance_model.dart';
import 'package:my_gallery/model/wisdom_model.dart';
import 'package:my_gallery/model/upload_file_model.dart';
import 'package:date_format/date_format.dart';
import 'package:dio/dio.dart';
import 'package:my_gallery/modules/my_course/intelligence_question_database/real_question_answer_record_model.dart';
import 'package:my_gallery/modules/my_course/intelligence_question_database/real_question_model.dart';
import 'package:my_gallery/modules/my_plan/my_plan_authority_model.dart';
import 'package:my_gallery/modules/my_plan/my_plan_model.dart';
import 'package:my_gallery/modules/personal/degrade/activated_card_model.dart';
import 'package:my_gallery/modules/personal/degrade/degrade_page.dart';
import 'package:my_gallery/modules/personal/degrade/degraded_model.dart';
import 'package:my_gallery/modules/personal/error_book/unit_test/test_paper_list_model.dart';
import 'package:my_gallery/modules/personal/error_book/unit_test/unit_test_authority_model.dart';
import 'package:my_gallery/modules/personal/unit_test/unit_test_model.dart';


class DaoManager {

  ///
  /// @description 修改密码提示处理
  /// @param 
  /// @return 
  /// @author waitwalker
  /// @time 2021/8/5 10:10
  ///
  static Future<ResponseData> fetchChangePasswordHintData() async {
    var url = APIConst.kBaseServerURL + 'api-study-service/api/students/ninety-day/password';
    var response = await NetworkManager.netFetch(url, null, null, Options(method: 'PUT'));
    return response;
  }

  /// http://int.etiantian.com:39804/display/zz/NEW-ETT-API-98-V1.5.2
  ///
  /// @description 智能题库 根据教材id获取有题的的章，节，知识点，树
  /// @param 
  /// @return 
  /// @author waitwalker
  /// @time 2020/11/11 5:15 PM
  ///
  static Future<ResponseData> fetchIntelligenceChapterList(materialId) async {
    var url = APIConst.kBaseServerURL + 'api-service-course-wx//wx-chapter/node/points/questions/tree';

    var map = {'materialId': materialId.toString()};
    var query = mapToQuery(map);
    url += '?$query';
    //url = "http://192.168.10.90:7300/mock/5fd17fc49da342432b15fb32/api/intelligence/chapter/list";
    var response = await NetworkManager.netFetch(url, null, null, null);
    if (response.result) {
      var courseList = WisdomModel.fromJson(response.data);
      response.model = courseList;
    }
    return response;
  }

  ///
  /// @description 获取历年真题数据
  /// @param
  /// @return
  /// @author waitwalker
  /// @time 3/30/21 3:02 PM
  ///
  /// http://int.etiantian.com:39804/display/zz/NEW-ETT-API-101-V1.5.2
  static Future<ResponseData> fetchRealQuestionData(subjectId, gradeId, semester, type, year) async {
    var url = APIConst.kBaseServerURL + 'api-study-service/api/papers/real/ques';
    var query = mapToQuery({
      'subjectId': subjectId.toString(),
      'gradeId': gradeId.toString(),
      'semester': semester.toString(),
      'type': type.toString(),
      'year': year.toString(),
    });

    // var query = mapToQuery({
    //   'subjectId': "2",
    //   'gradeId': "2",
    //   'semester': "1",
    //   'type': "5",
    //   'year': "2015-2016",
    // });
    url = '$url?$query';
    var response = await NetworkManager.netFetch(url, null, null, null);
    if (response.result) {
      var model = RealQuestionModel.fromJson(response.data);
      response.model = model;
    }
    return response;
  }

  ///
  /// @description 获取激活卡片数据
  /// @param
  /// @return
  /// @author waitwalker
  /// @time 3/30/21 3:02 PM
  ///
  /// http://int.etiantian.com:39804/display/zz/NEW-ETT-API-106-V1.5.4
  static Future<ResponseData> fetchActivatedCardData(subjectId, gradeId, semester, type, year) async {
    var url = APIConst.kBaseServerURL + 'api-study-service/api/card/user';
    var response = await NetworkManager.netFetch(url, null, null, null);
    if (response.result) {
      var model = ActivatedCardModel.fromJson(response.data);
      response.model = model;
    }
    return response;
  }

  ///
  /// @name fetchDegradedData
  /// @description 降级接口操作
  /// @parameters
  /// @return
  /// @author waitwalker
  /// @date 2020-02-07
  ///
  /// http://int.etiantian.com:39804/display/zz/NEW-ETT-API-107-V1.5.4
  static Future<ResponseData> fetchDegradedData(realCardId,gradeId,subjectId,refId,operationType,cardId) async {
    var url = APIConst.kBaseServerURL + 'api-study-service/api/card/user/modify/grade';
    var body = jsonEncode({
      "realCardId":realCardId,
      "gradeId":gradeId,
      "subjectId":subjectId,
      "refId":refId,
      "operationType":operationType,
      "cardId":cardId
    });
    var response = await NetworkManager.netFetch(url, body, null, Options(method: 'PUT'));
    if (response.code == 200) {
      print("response.data: ${response.data}");
      String string = json.encode(response.data);
      print("编码后:$string");
      /// 因为服务器返回的响应信息格式和其他接口不一样,要先decode一下
      if (response.data is String) {
        String jsonString = response.data;
        var resultMap = json.decode(jsonString);
        var addCard = DegradedModel.fromJson(resultMap);
        response.model = addCard;
        return response;
      } else {
        var addCard = DegradedModel.fromJson(response.data);
        response.model = addCard;
        return response;
      }
    } else {
      var addCard = DegradedModel();
      ResponseData responseData = ResponseData(addCard,false,-200);
      return responseData;
    }
  }

  ///
  /// @description 获取历年真题作答记录列表
  /// @param
  /// @return
  /// @author waitwalker
  /// @time 3/30/21 3:02 PM
  ///
  /// http://int.etiantian.com:39804/display/zz/NEW-ETT-API-104-V1.5.2
  static Future<ResponseData> fetchRealQuestionRecordData(realPaperId) async {
    var url = APIConst.kBaseServerURL + 'api-study-service/api/papers/real/ques/record';
    var query = mapToQuery({
      'realPaperId': realPaperId.toString(),
    });
    url = '$url?$query';
    var response = await NetworkManager.netFetch(url, null, null, null);
    if (response.result) {
      var model = RealQuestionAnswerRecordModel.fromJson(response.data);
      response.model = model;
    }
    return response;
  }

  ///
  /// @name fetchPDFURL
  /// @description 根据试题id获取pdf 路径
  /// @parameters
  /// @return
  /// @author waitwalker
  /// @date 2019-12-31
  ///
  /// http://int.etiantian.com:39804/display/zz/NEW-ETT-API-91-V1.2.6
  static Future<ResponseData> fetchPDFURL(Map<String,dynamic> parameter) async {
    var url = APIConst.pdfURL +
        'ai-report?m=getErrorQuestionPDF';
    var response = await NetworkManager.netFetch(url, null, null, null,queryParameters: parameter);
    if (response.code == 200) {
      print("response.data: ${response.data}");
      /// 因为服务器返回的响应信息格式和其他接口不一样,要先decode一下
      if (response.data is String) {
        String jsonString = response.data;
        var resultMap = json.decode(jsonString);
        var pdfModel = ETTPDFModel.fromJson(resultMap);
        response.model = pdfModel;
        return response;
      } else {
        var pdfModel = ETTPDFModel.fromJson(response.data);
        response.model = pdfModel;
        return response;
      }
    } else {
      var ettPdfModel = ETTPDFModel();
      ettPdfModel.type = "error";
      ResponseData responseData = ResponseData(ettPdfModel,false,-200);
      return responseData;
    }
  }

  ///
  /// @name fetchLiveMaterial
  /// @description 获取资料包
  /// @parameters
  /// @return
  /// @author waitwalker
  /// @date 2020-01-11
  ///
  /// http://192.168.10.8:8090/display/zz/NEW-ETT-API-92-V1.2.6
  /// http://int.etiantian.com:39804/display/zz/NEW-ETT-API-92
  static Future<ResponseData> fetchLiveMaterial(Map<String,dynamic> parameter, {bool isSenior = true, List<num?>?courseIdList}) async {
    print("isSenior:$isSenior");
    var url = APIConst.kBaseServerURL + 'api-study-service/api/course/coursewares/list';
    var response;
    // 高中
    if (isSenior) {
      response = await NetworkManager.netFetch(url, null, null, null,queryParameters: parameter);
    } else {
      // 初中
      var body = jsonEncode(courseIdList);
      response = await NetworkManager.netFetch(url, body, null, Options(method: 'POST'));
    }
    if (response.code == 200) {
      print("response.data: ${response.data}");
      String string = json.encode(response.data);
      print("编码后:$string");

      /// 因为服务器返回的响应信息格式和其他接口不一样,要先decode一下
      if (response.data is String) {
        String jsonString = response.data;
        var resultMap = json.decode(jsonString);
        var liveMaterial = LiveMaterialModel.fromJson(resultMap);
        response.model = liveMaterial;
        return response;
      } else {
        var liveMaterial = LiveMaterialModel.fromJson(response.data);
        response.model = liveMaterial;
        return response;
      }
    } else {
      var liveMaterial = LiveMaterialModel();
      ResponseData responseData = ResponseData(liveMaterial,false,-200);
      return responseData;
    }
  }

  ///
  /// @name fetchAddCard
  /// @description 给爱学跳转过来的用户加卡
  /// @parameters
  /// @return
  /// @author waitwalker
  /// @date 2020-02-07
  ///
  /// http://int.etiantian.com:39804/display/zz/NEW-ETT-API-94-V1
  static Future<ResponseData> fetchAddCard(Map<String,dynamic> parameter) async {
    var url = APIConst.kBaseServerURL + 'api-study-service/api/course-card/app-add-speci-card';
    var response = await NetworkManager.netFetch(url, null, null, Options(method: 'POST'),queryParameters: parameter);
    if (response.code == 200) {
      print("response.data: ${response.data}");
      String string = json.encode(response.data);
      print("编码后:$string");
      /// 因为服务器返回的响应信息格式和其他接口不一样,要先decode一下
      if (response.data is String) {
        String jsonString = response.data;
        var resultMap = json.decode(jsonString);
        var addCard = AddCardModel.fromJson(resultMap);
        response.model = addCard;
        return response;
      } else {
        var addCard = AddCardModel.fromJson(response.data);
        response.model = addCard;
        return response;
      }
    } else {
      var addCard = AddCardModel();
      ResponseData responseData = ResponseData(addCard,false,-200);
      return responseData;
    }
  }

  ///
  /// @name fetchUploadImage
  /// @description 上传审核图片
  /// @parameters
  /// @return
  /// @author waitwalker
  /// @date 2020-02-26
  ///
  /// http://int.etiantian.com:39804/display/zz/NEW-ETT-API-79-V1.2.4
  static fetchUploadImage(String imagePath) async {
    var url = APIConst.uploadImage;
    FormData formData = new FormData.fromMap({
      "file": await MultipartFile.fromFile(imagePath),
    });

    ResponseData response = await NetworkManager.netFetch(url, formData, null, Options(method: 'POST'));

    if (response.result) {
      var model = UploadFileModel.fromJson(jsonDecode(response.data));
      String imgPath = "https://attach.etiantian.com/common/xwx/wrong/photo/";
      if (model.result == 1) {
        DateTime dateTime = DateTime.now();
        String month = formatDate(dateTime, [mm]);
        imgPath = imgPath + month + "/" + model.data!.filePath!;
        LoggerManager.info("上传图片完整路径:$imgPath");
        model.data!.filePath = imgPath;
      } else {
        model.data!.filePath = null;
      }

      response.model = model;
    } else {
      var model = UploadFileModel();
      ResponseData responseData = ResponseData(model,false,-200);
      return responseData;
    }
    return response;
  }


  ///
  /// @name fetchCollegeEntrance
  /// @description 获取高考冲刺数据
  /// @parameters
  /// @return
  /// @author waitwalker
  /// @date 2020-03-16
  ///
  /// http://int.etiantian.com:39804/display/zz/ACTIVITY-API-01-V1.0
  static Future<ResponseData> fetchCollegeEntrance(Map<String,dynamic> parameter) async {
    var url = APIConst.kBaseServerURL + 'api-study-service/api/course/activity';
    var response = await NetworkManager.netFetch(url, null, null, null,queryParameters: parameter);
    if (response.code == 200) {
      print("response.data: ${response.data}");

      /// 因为服务器返回的响应信息格式和其他接口不一样,要先decode一下
      if (response.data is String) {
        String jsonString = response.data;
        var resultMap = json.decode(jsonString);
        var activityModel = CollegeEntranceModel.fromJson(resultMap);
        response.model = activityModel;
        return response;
      } else {
        var activityModel = CollegeEntranceModel.fromJson(response.data);
        response.model = activityModel;
        return response;
      }
    } else {
      var activityModel = CollegeEntranceModel();
      ResponseData responseData = ResponseData(activityModel,false,-200);
      return responseData;
    }
  }

  ///
  /// @name fetchLiveAuthority
  /// @description 获取专题讲解权限
  /// @parameters
  /// @return
  /// @author waitwalker
  /// @date 2020-05-25
  ///
  /// http://int.etiantian.com:39804/display/zz/ACTIVITY-API-01-V1.0
  static Future<ResponseData> fetchLiveAuthority(Map<String,dynamic> parameter) async {
    var url = APIConst.kBaseServerURL + 'api-cloudaccount-service/api/user/column/permits';
    var response = await NetworkManager.netFetch(url, null, null, null,queryParameters: parameter);
    if (response.code == 200) {
      print("response.data: ${response.data}");
      return response;
    } else {
      ResponseData responseData = ResponseData(null,false,-200);
      return responseData;
    }
  }

  ///
  /// @name fetchUnitTestAuthority
  /// @description 获取质检消错权限
  /// @parameters
  /// @return
  /// @author waitwalker
  /// @date 2020-05-25
  ///
  /// http://int.etiantian.com:39804/display/zz/DYZJ-ZL-API-01-V1.0
  static Future<ResponseData> fetchUnitTestAuthority(Map<String,dynamic> parameter) async {
    var url = APIConst.kBaseServerURL + 'api-dyzj-service/api/user/zl/info';
    var response = await NetworkManager.netFetch(url, null, null, null,queryParameters: parameter);
    if (response.code == 200) {
      if (response.data is String) {
        String jsonString = response.data;
        var resultMap = json.decode(jsonString);
        var model = UnitTestAuthorityModel.fromJson(resultMap);
        response.model = model;
        return response;
      } else {
        var model = UnitTestAuthorityModel.fromJson(response.data);
        response.model = model;
        return response;
      }
    } else {
      ResponseData responseData = ResponseData(null,false,-200);
      return responseData;
    }
  }

  ///
  /// @name fetchRegionData
  /// @description 获取地区数据
  /// @parameters
  /// @return
  /// @author waitwalker
  /// @date 2020-05-25
  ///
  /// http://192.168.10.8:8090/display/zz/NEW-ETT-API-70-V2.0
  ///
  static Future<ResponseData> fetchRegionData(Map<String,dynamic> parameter) async {
    //var url = APIConst.kBaseServerURL + 'api-cloudaccount-service/api/user/column/permits';

    var url = Config.DEBUG ? "http://gw5.bj.etiantian.net:42393/api-study-service/api/provinces#" : "http://school.etiantian.com/api-study-service/api/provinces";

    var response = await NetworkManager.netFetch(url, null, null, null,queryParameters: parameter);
    if (response.code == 200) {
      print("response.data: ${response.data}");
      return response;
    } else {
      ResponseData responseData = ResponseData(null,false,-200);
      return responseData;
    }
  }


  ///
  /// @description 获取错题本中试卷列表
  /// @param
  /// @return
  /// @author waitwalker
  /// @time 2020/10/28 3:59 PM
  ///
  static Future<ResponseData> fetchErrorBookTestPaperList(Map<String,dynamic> parameter) async {
    var url = APIConst.kBaseServerURL + 'api-dyzj-service/api/wrong/notebook/task/paper';
    var response = await NetworkManager.netFetch(url, null, null, null,queryParameters: parameter);
    if (response.code == 200) {
      print("response.data: ${response.data}");
      String string = json.encode(response.data);
      print("编码后:$string");

      /// 因为服务器返回的响应信息格式和其他接口不一样,要先decode一下
      if (response.data is String) {
        String jsonString = response.data;
        var resultMap = json.decode(jsonString);
        var liveMaterial = TestPaperListModel.fromJson(resultMap);
        response.model = liveMaterial;
        return response;
      } else {
        var liveMaterial = TestPaperListModel.fromJson(response.data);
        response.model = liveMaterial;
        return response;
      }
    } else {
      var liveMaterial = TestPaperListModel();
      ResponseData responseData = ResponseData(liveMaterial,false,-200);
      return responseData;
    }
  }

  ///
  /// @description 获取质检消错中试卷列表
  /// @param
  /// @return
  /// @author waitwalker
  /// @time 2020/10/28 3:59 PM
  ///
  static Future<ResponseData> fetchUnitTestPaperList(Map<String,dynamic> parameter) async {
    var url = APIConst.kBaseServerURL + 'api-dyzj-service/api/paper-infos/user';
    var response = await NetworkManager.netFetch(url, parameter, null, null,queryParameters: parameter);
    if (response.code == 200) {
      print("response.data: ${response.data}");
      String string = json.encode(response.data);
      print("编码后:$string");

      /// 因为服务器返回的响应信息格式和其他接口不一样,要先decode一下
      if (response.data is String) {
        String jsonString = response.data;
        var resultMap = json.decode(jsonString);
        var liveMaterial = UnitTestModel.fromJson(resultMap);
        response.model = liveMaterial;
        return response;
      } else {
        var liveMaterial = UnitTestModel.fromJson(response.data);
        response.model = liveMaterial;
        return response;
      }
    } else {
      var liveMaterial = UnitTestModel();
      ResponseData responseData = ResponseData(liveMaterial,false,-200);
      return responseData;
    }
  }

  // *********************** 全时自习室 **********************
  ///
  /// @description 我的计划权限获取
  /// @param
  /// @return
  /// @author waitwalker
  /// @time 2020/11/4 9:09 AM
  ///
  /// http://192.168.10.8:8090/display/zz/MINI_PRO_DALIY_TASK_WEB_API_202_V1.0
  static Future<ResponseData> fetchMyPlanAuthority(Map<String,dynamic> parameter) async {
    var url = APIConst.kBaseServerURL + 'api-study-service/api/plans/tasks/authority';
    var response = await NetworkManager.netFetch(url, null, null, null,queryParameters: parameter);
    if (response.code == 200) {
      if (response.data is String) {
        String jsonString = response.data;
        var resultMap = json.decode(jsonString);
        var model = MyPlanAuthorityModel.fromJson(resultMap);
        response.model = model;
        return response;
      } else {
        var model = MyPlanAuthorityModel.fromJson(response.data);
        response.model = model;
        return response;
      }
    } else {
      ResponseData responseData = ResponseData(null,false,-200);
      return responseData;
    }
  }

  ///
  /// @description 我的计划数据
  /// @param
  /// @return
  /// @author waitwalker
  /// @time 2020/11/4 9:09 AM
  ///
  /// http://192.168.10.8:8090/display/zz/MINI_PRO_DALIY_TASK_WEB_API_202_V1.0
  static Future<ResponseData> fetchMyPlanData(Map<String,dynamic> parameter) async {
    var url = APIConst.kBaseServerURL + 'api-study-service/api/plans/tasks';
    var response = await NetworkManager.netFetch(url, null, null, null,queryParameters: parameter);
    if (response.code == 200) {
      if (response.data is String) {
        String jsonString = response.data;
        var resultMap = json.decode(jsonString);
        var model = MyPlanModel.fromJson(resultMap);
        response.model = model;
        return response;
      } else {
        var model = MyPlanModel.fromJson(response.data);
        response.model = model;
        return response;
      }
    } else {
      ResponseData responseData = ResponseData(null,false,-200);
      return responseData;
    }
  }

  ///
  /// @description 我的计划任务完成接口
  /// @param
  /// @return
  /// @author waitwalker
  /// @time 2020/11/10 11:14 AM
  ///
  /// http://192.168.10.8:8090/display/zz/MINI_PRO_DALIY_TASK_WEB_API_203_V1.0
  static Future<ResponseData> fetchMyPlanTaskFinishLog(taskId, resourceId) async {
    var url = APIConst.kBaseServerURL + 'api-study-service/api/plans/tasks/finish';

    var body = jsonEncode({
      "taskId": taskId,
      "resourceId": resourceId
    });
    var headers = <String, String>{'content-type': 'application/json'};
    var response = await NetworkManager.netFetch(url, body, headers, Options(method: 'POST'));
    if (response.result) {
      var model = BaseModel.fromJson(response.data);
      response.model = model;
    }
    return response;
  }

  // *********************** 全时自习室 **********************

}