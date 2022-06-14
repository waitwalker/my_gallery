// import 'package:extended_image/extended_image.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:microcosm/common/components/loading_page.dart';
// import 'package:microcosm/common/values/colors.dart';
// import 'package:microcosm/common/values/enums.dart';
// import 'package:microcosm/config/img.dart';
// import 'package:microcosm/generated/l10n.dart';
// import 'package:microcosm/model/club/member/bean/club_member_bean.dart';
// import 'package:microcosm/model/club/member/club_member_detail_model.dart';
// import 'package:microcosm/model/club/member/club_member_service.dart';
// import 'package:provider/provider.dart';
//
// /// @fileName club_member_detail_page.dart
// /// @description 成员详情页面：添加一些回调处理
// /// @date 2022/6/11 17:13
// /// @author LiuChuanan
// class ClubMemberDetailPage extends StatefulWidget {
//
//   final Function(bool shouldRefrsh) onTap;
//   final ClubMemberItemBean itemBean;
//   final int clubId;
//   const ClubMemberDetailPage({
//     Key? key,
//     required this.onTap,
//     required this.itemBean,
//     required this.clubId,
//   }) : super(key: key);
//
//   @override
//   State<StatefulWidget> createState() => _ClubMemberDetailPageState();
//
// }
//
// class _ClubMemberDetailPageState extends State<ClubMemberDetailPage> {
//
//   @override
//   void initState() {
//     super.initState();
//     _fetchDetailData();
//   }
//
//   _fetchDetailData() async {
//     Provider.of<ClubMemberDetailModel>(context, listen: false).setPageStatus(CommonPageStatus.Loading);
//     ClubMemberService.fetchNormalClubMemberDetail(params: {
//       "toClubId": widget.clubId,
//       "toUserId": widget.itemBean.memberInfo.userId,
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return InkWell(
//       onTap: (){
//         widget.onTap(true);
//       },
//       child: Scaffold(
//         backgroundColor: AppColors.color40000000,
//         body: Selector<ClubMemberDetailModel, ClubMemberDetailModel>(builder: (ctx, model, child){
//           switch (model.pageStatus) {
//             case CommonPageStatus.Loading:
//               return LoadingPage(loadingColor: AppColors.colorWhite,);
//             case CommonPageStatus.Error:
//             case CommonPageStatus.NoData:
//               Future.delayed(Duration(milliseconds: 200),(){
//                 widget.onTap(true);
//               });
//               return LoadingPage(loadingColor: AppColors.colorWhite,);
//             case CommonPageStatus.Success:
//               return Padding(
//                 padding: EdgeInsets.only(left: 25.w, right: 25.w, top: MediaQuery.of(context).size.height / 2 - 180.h),
//                 child: InkWell(
//                   child: Container(
//                     decoration: BoxDecoration(
//                       color: AppColors.colorFFF6F7F8,
//                       borderRadius: BorderRadius.circular(12.0.r),
//                     ),
//                     child: Column(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         /// 黄色背景区域
//                         Container(
//                           decoration: BoxDecoration(
//                             color: AppColors.colorFFF9DB4A,
//                             borderRadius:  BorderRadius.only(topLeft: Radius.circular(12.0.r,), topRight: Radius.circular(12.0.r,),),
//                           ),
//                           child: Padding(
//                             padding: EdgeInsets.only(left: 12.w, right: 12.w, top: 12.w),
//                             child: Column(
//                               mainAxisAlignment: MainAxisAlignment.start,
//                               mainAxisSize: MainAxisSize.min,
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Row(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Stack(
//                                       children: [
//                                         ClipRRect(
//                                           borderRadius: BorderRadius.circular(32.0),
//                                           child: Provider.of<ClubMemberDetailModel>(
//                                               context,
//                                               listen: false)
//                                               .memberDetailBean.memberInfo.headImg.isNotEmpty
//                                               ? ExtendedImage.network(
//                                             Provider.of<ClubMemberDetailModel>(
//                                                 context,
//                                                 listen: false).memberDetailBean.memberInfo.headImg,
//                                             width: 64,
//                                             height: 64,
//                                             fit: BoxFit.cover,
//                                           )
//                                               : Image.asset(
//                                             Img.defaultAvatar,
//                                             width: 64,
//                                             height: 64,
//                                           ),
//                                         ),
//                                         Positioned(
//                                           bottom: 0,
//                                           right: 0,
//                                           child: Image.asset(
//                                             Provider.of<ClubMemberDetailModel>(context, listen: false).memberDetailBean.memberInfo.gender == 1
//                                                 ? Img.clubMemberGenderIconMan
//                                                 : Img.clubMemberGenderIconWoman,
//                                             width: 16,
//                                             height: 16,
//                                           ),)
//                                       ],
//                                     ),
//                                     SizedBox(width: 6,),
//                                     Expanded(child: Text(Provider.of<ClubMemberDetailModel>(
//                                         context,
//                                         listen: false).memberDetailBean.memberInfo.name,
//                                       maxLines: 1,
//                                       overflow: TextOverflow.ellipsis,
//                                       style: TextStyle(fontSize: 18, color: AppColors.colorFF333333, fontWeight: FontWeight.bold,),
//                                     ),),
//                                     SizedBox(width: 6,),
//                                     Container(
//                                       alignment: Alignment.center,
//                                       padding: EdgeInsets.symmetric(horizontal: 16),
//                                       height: 25,
//                                       decoration: BoxDecoration(
//                                         color: Colors.green,
//                                         borderRadius: BorderRadius.circular(12.5),
//                                       ),
//                                       child: Text("删除", style: TextStyle(fontSize: 13, color: AppColors.colorWhite, fontWeight: FontWeight.bold,),),
//                                     ),
//                                   ],
//                                 ),
//                                 SizedBox(height: 6,),
//                                 Text(Provider.of<ClubMemberDetailModel>(
//                                     context,
//                                     listen: false).memberDetailBean.memberInfo.sign.length > 0 ? Provider.of<ClubMemberDetailModel>(
//                                     context,
//                                     listen: false).memberDetailBean.memberInfo.sing : S.of(context).clubMemberSignPlaceholder,),
//                                 SizedBox(height: 12,),
//                               ],
//                             ),
//                           ),
//                         ),
//                         /// 游戏统计标题
//                         Container(
//                           height: 35.h,
//                           alignment: Alignment.centerLeft,
//                           color: AppColors.colorWhite,
//                           child: Padding(
//                             padding: EdgeInsets.only(left: 12),
//                             child: Text("游戏统计"),
//                           ),
//                         ),
//                         /// 游戏统计数据
//                         Container(
//                           height: 133.h,
//                           color: Colors.transparent,
//                         ),
//                         /// 常玩游戏标题
//                         Container(
//                           height: 35.h,
//                           alignment: Alignment.centerLeft,
//                           color: AppColors.colorWhite,
//                           child: Padding(
//                             padding: EdgeInsets.only(left: 12),
//                             child: Text("常玩游戏"),
//                           ),
//                         ),
//
//                         /// 常玩游戏列表
//                         Container(
//                           height: 58.h,
//                         ),
//                       ],),
//                   ),
//                   onTap: (){
//                     /// 阻止移除
//                   },
//                 ),
//               );
//             default:
//               return Container();
//           }
//         }, selector: (ctx, model){
//           return model;
//         },shouldRebuild: (_,model)=>true,),
//       ),
//     );
//   }
//
//
// }