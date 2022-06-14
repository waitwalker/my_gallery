// import 'dart:convert';
// import 'package:flutter/widgets.dart';
// import 'package:microcosm/app.dart';
// import 'package:microcosm/model/club/member/bean/club_member_bean.dart';
// import 'package:microcosm/model/club/member/bean/club_member_detail_bean.dart';
// import 'package:microcosm/model/club/member/club_member_detail_model.dart';
// import 'package:microcosm/model/club/member/club_member_model.dart';
// import 'package:microcosm/pages/club/member/club_member_page.dart';
// import 'package:microcosm/pages/club/member/member_entrance_enum.dart';
// import 'package:microcosm/routers/routes.dart';
// import 'package:microcosm/services/network/api.dart';
// import 'package:microcosm/services/network/http_utils.dart';
// import 'package:provider/provider.dart';
//
// /// @fileName club_member_service.dart
// /// @description 成员列表Service，负责网络请求&解析数据等
// /// @date 2022/6/10 18:49
// /// @author LiuChuanan
// class ClubMemberService {
//
//   /// methodName fetchClubMemberListData
//   /// description 获取成员list数据
//   /// date 2022/6/10 17:14
//   /// author LiuChuanan
//   static Future<void> fetchNormalClubMemberListData({required Map <String, dynamic> params}) async {
//     _fetchMemberList(params: params, model: Provider.of<ClubMemberModel>(navigatorKey.currentContext!, listen: false));
//   }
//
//   static Future<void> _fetchMemberList({required Map<String, dynamic> params, required ClubMemberModel model}) async{
//     HttpUtils.get(Api.clubMember, parameters: params, success: (data) async{
//       if (data != null && data.isNotEmpty) {
//         ClubMemberBean clubMemberBean = ClubMemberBean.fromJson(data);
//         model.setMemberData(
//           searching: params["search"].isNotEmpty ? true : false,
//           currentPage: params["page"],
//           hasError: false,
//           clubMemberBean: clubMemberBean,);
//       } else {
//         model.setMemberData(
//           searching: params["search"].isNotEmpty ? true : false,
//           currentPage: params["page"],
//           hasError: false,);
//       }
//     }, fail: (errorCode, msg){
//       if (msg.runtimeType == String) {
//         model.setMemberData(
//           searching: params["search"].isNotEmpty ? true : false,
//           currentPage: params["page"],
//           hasError: true,
//           errorMsg: msg,);
//       } else {
//         model.setMemberData(
//           searching: params["search"].isNotEmpty ? true : false,
//           currentPage: params["page"],
//           hasError: true,
//           errorMsg: jsonEncode(msg),);
//       }
//     });
//   }
//
//   /// methodName fetchNormalClubMemberDetail
//   /// description 获取成员详情
//   /// date 2022/6/13 09:54
//   /// author LiuChuanan
//   static Future<void> fetchNormalClubMemberDetail({required Map <String, dynamic> params}) async {
//     _fetchDetail(params: params, model:  Provider.of<ClubMemberDetailModel>(navigatorKey.currentContext!, listen: false));
//   }
//
//   static Future<void> _fetchDetail({required Map<String, dynamic> params, required ClubMemberDetailModel model}) async{
//     HttpUtils.get(Api.clubMemberDetail, parameters: params, success: (data) async{
//       if (data != null && data.isNotEmpty) {
//         ClubMemberDetailBean detailBean = ClubMemberDetailBean.fromJson(data);
//         model.setClubDetailData(hasError: false, detailBean: detailBean);
//       } else {
//         model.setClubDetailData(hasError: false, detailBean: null);
//       }
//     }, fail: (errorCode, msg){
//       if (msg.runtimeType == String) {
//         model.setClubDetailData(hasError: true, errorMsg: msg);
//       } else {
//         model.setClubDetailData(hasError: true, errorMsg: jsonEncode(msg));
//       }
//     });
//   }
//
//
//   /// methodName pushToClubMemberPage
//   /// description 进入成员列表页面
//   /// entrance：MemberList(来自memberList)，ClubInfo(来自俱乐部详情信息)，ClubAdmin(来自管理员)
//   /// date 2022/6/10 17:39
//   /// author LiuChuanan
//   static void pushToClubMemberPage({required MemberEntrance entrance, required int clubId,}) {
//     clearData();
//     ClubMemberParameter parameter = ClubMemberParameter(entrance: entrance, clubId: clubId);
//     Routes.navigateTo(navigatorKey.currentContext!,
//       Routes.clubMemberPage,
//       routeSettings: RouteSettings(arguments: parameter),);
//   }
//
//   /// 清空数据
//   static void clearData() {
//     Provider.of<ClubMemberModel>(navigatorKey.currentContext!, listen: false).clearData();
//   }
//
// }