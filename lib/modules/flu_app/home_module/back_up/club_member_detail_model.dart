// import 'package:flutter/material.dart';
// import 'package:microcosm/common/values/enums.dart';
// import 'package:microcosm/model/club/member/bean/club_member_detail_bean.dart';
// import 'package:microcosm/utils/toast_utils.dart';
//
// class ClubMemberDetailModel extends ChangeNotifier {
//   /// 正常页面状态
//   late CommonPageStatus _pageStatus = CommonPageStatus.Loading;
//   get pageStatus {
//     return _pageStatus;
//   }
//
//   late ClubMemberDetailBean _memberDetailBean = ClubMemberDetailBean();
//
//   get memberDetailBean => _memberDetailBean;
//
//   /// 重置页面整体状态
//   void setPageStatus(CommonPageStatus status) {
//     _pageStatus = status;
//     notifyListeners();
//   }
//
//
//   void setClubDetailData({
//     bool hasError = false,
//     String? errorMsg,
//     ClubMemberDetailBean? detailBean,}) {
//     if (hasError) {
//       ToastUtils.toastShort(errorMsg!);
//       _pageStatus = CommonPageStatus.Error;
//     } else {
//       if (detailBean != null) {
//         _pageStatus = CommonPageStatus.Success;
//         _memberDetailBean = detailBean;
//       } else {
//         _pageStatus = CommonPageStatus.NoData;
//       }
//     }
//
//     notifyListeners();
//   }
//
//
//
// }