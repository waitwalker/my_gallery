// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:microcosm/app.dart';
// import 'package:microcosm/common/values/colors.dart';
// import 'package:microcosm/generated/l10n.dart';
// import 'package:microcosm/global.dart';
// import 'package:microcosm/model/bean/chat_info_bean_entity.dart';
// import 'package:microcosm/model/chat/create_group_model.dart';
// import 'package:microcosm/model/chat/forward/search_contact_model.dart';
// import 'package:microcosm/model/home/home_source_data_manager.dart';
// import 'package:microcosm/pages/chats/forward/forward_enum.dart';
// import 'package:microcosm/pages/chats/forward/pop_up_menu.dart';
// import 'package:microcosm/pages/chats/forward/search_contact_page.dart';
// import 'package:microcosm/routers/routes.dart';
// import 'package:microcosm/utils/log.dart';
// import 'package:microcosm/utils/toast_utils.dart';
// import 'package:provider/provider.dart';
// import 'package:tencent_im_sdk_plugin/enum/conversation_type.dart';
// import 'package:tencent_im_sdk_plugin/enum/message_elem_type.dart';
// import 'package:tencent_im_sdk_plugin/models/v2_tim_group_info.dart';
// import 'package:tencent_im_sdk_plugin/models/v2_tim_group_info_result.dart';
// import 'package:tencent_im_sdk_plugin/models/v2_tim_message.dart';
//
//
// /// @fileName message_tool_bar.dart
// /// @description 消息转发面板
// /// @date 2022/5/18 10:28
// /// @author LiuChuanan
// class MessageToolBar extends StatefulWidget {
//   /// 会话类型 必传
//   final int conversationType;
//   /// 消息
//   final V2TimMessage message;
//   final int messageIndex;
//   /// 子控件
//   final Widget child;
//   /// 子控件的最大宽度
//   final double? childMaxWidth;
//   /// 删除回调
//   final Function() onTapDelete;
//   /// 群组信息
//   final V2TimGroupInfo? groupInfo;
//   /// 单聊信息
//   final ChatInfoBeanEntity? chatInfo;
//
//   const MessageToolBar(
//       {Key? key,
//         required this.child,
//         required this.conversationType,
//         required this.message,
//         required this.messageIndex,
//         required this.onTapDelete,
//         this.childMaxWidth,
//         this.chatInfo,
//         this.groupInfo,
//       }) : super(key: key);
//   @override
//   State<StatefulWidget> createState() => _MessageToolBarState();
// }
//
// class _MessageToolBarState extends State<MessageToolBar> {
//   late PopupMenuController controller;
//   late int crossCount = 3;
//   late ForwardType type = ForwardType.Text;
//   late List<Map<String,dynamic>> _menuItems;
//   late double textWidth = 50.0;
//
//
//   @override
//   void initState() {
//     super.initState();
//     if (widget.message.elemType == MessageElemType.V2TIM_ELEM_TYPE_TEXT) {
//       Size size = boundingTextSize(widget.message.textElem!.text!, TextStyle(
//           fontSize: 15.sp,
//           color: AppColors.colorWhite));
//       textWidth = size.width + 24.0;
//       textWidth = textWidth <= widget.childMaxWidth! ? textWidth : widget.childMaxWidth!;
//     } else {
//       textWidth = widget.childMaxWidth!;
//     }
//     controller = PopupMenuController();
//   }
//
//   /// methodName _groupChatInfo
//   /// description 获取群组信息
//   /// date 2022/5/25 14:17
//   /// author LiuChuanan
//   void _groupChatInfo({bool isDelete = false}) async {
//     if (widget.groupInfo == null) {
//       ToastUtils.toastShortForLogin(isDelete
//           ? S.of(context).deleteChatGroupDisbanded
//           : S.of(context).forwardChatGroupDisbanded);
//       controller.hideMenu();
//       return;
//     }
//
//     Provider.of<CreateGroupModel>(context, listen: false)
//         .fetchMemberListById(widget.groupInfo!.groupID,
//         success: (value) async {
//           await Provider.of<CreateGroupModel>(context, listen: false)
//               .fetchGroupById(widget.groupInfo!.groupID,
//               success: (value) {
//                 List<V2TimGroupInfoResult> groupInfoList = value;
//                 if (groupInfoList.isEmpty ||
//                     groupInfoList[0].groupInfo == null) {
//                   ToastUtils.toastShortForLogin(isDelete
//                       ? S.of(context).deleteChatGroupDisbanded
//                       : S.of(context).forwardChatGroupDisbanded);
//                   return;
//                 }
//                 if (isDelete) {
//                   widget.onTapDelete();
//                   controller.hideMenu();
//                 } else {
//                   switch (widget.message.elemType) {
//                     case MessageElemType.V2TIM_ELEM_TYPE_TEXT:
//                       type = ForwardType.Text;
//                       break;
//                     case MessageElemType.V2TIM_ELEM_TYPE_IMAGE:
//                       type = ForwardType.Image;
//                       if (widget.message.imageElem!.imageList!.isEmpty) {
//                         controller.hideMenu();
//                         ToastUtils.toastShort(S.of(context).forwardMessageExpiredCannotForward);
//                         return;
//                       }
//                       break;
//                     case MessageElemType.V2TIM_ELEM_TYPE_SOUND:
//                       type = ForwardType.Sound;
//                       break;
//                     default:
//                       type = ForwardType.Text;
//                       break;
//                   }
//                   HomeSourceDataManager.clickForwardMessageToolBarModule();
//                   Provider.of<SearchContactModel>(context, listen: false).resetData();
//                   Routes.navigateTo(
//                     context,
//                     Routes.searchContactPage,
//                     routeSettings: RouteSettings(
//                       arguments: SearchContactArguments(
//                           conversationType: widget.conversationType,
//                           message: widget.message,
//                           forwardType: type,
//                           chatInfo: widget.chatInfo,
//                           groupInfo: widget.groupInfo
//                       ),
//                     ),
//                   );
//                   controller.hideMenu();
//                 }
//               });
//         }, fail: () {
//           ToastUtils.toastShortForLogin(isDelete
//               ? S.of(context).deleteChatGroupDisbanded
//               : S.of(context).forwardChatGroupDisbanded);
//           controller.hideMenu();
//         });
//   }
//
//
//   Widget _buildLongPressMenu() {
//     return ClipRRect(
//       borderRadius: BorderRadius.circular(5),
//       child: Container(
//         // width: toolBarWidth,
//         height: 60,
//         color: const Color(0xFF4C4C4C),
//         child: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: _menuItems
//               .map((item) => InkWell(
//             child: Padding(
//               padding: EdgeInsets.only(left: 15, right: 15),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: <Widget>[
//                   Icon(
//                     item["icon"],
//                     size: 20,
//                     color: Colors.white,
//                   ),
//                   Container(
//                     margin: EdgeInsets.only(top: 2),
//                     child: Text(
//                       item["title"],
//                       style: TextStyle(color: Colors.white, fontSize: 12),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             onTap: item["itemIndex"] == 0
//                 ? _onTapCopy
//                 : item["itemIndex"] == 1
//                 ? _onTapForward
//                 : _onTapDelete,
//           ),)
//               .toList(),
//         ),
//       ),
//     );
//   }
//
//   /// methodName
//   /// description 复制方法处理
//   /// date 2022/5/17 19:07
//   /// author LiuChuanan
//   void _onTapCopy() {
//     HomeSourceDataManager.exposureForwardMessageToolBarModule(0);
//     HomeSourceDataManager.exposureForwardMessageToolBarModule(1);
//     switch (widget.message.elemType) {
//       case MessageElemType.V2TIM_ELEM_TYPE_TEXT:
//         HomeSourceDataManager.exposureForwardMessageToolBarModule(2);
//         Clipboard.setData(ClipboardData(text: widget.message.textElem!.text));
//         break;
//       case MessageElemType.V2TIM_ELEM_TYPE_IMAGE:
//         ToastUtils.toastLong("${widget.message.imageElem!.imageList![2]!.url}");
//         Clipboard.setData(ClipboardData(text: widget.message.imageElem!.imageList![2]!.url));
//         break;
//       case MessageElemType.V2TIM_ELEM_TYPE_SOUND:
//         break;
//       default:
//         break;
//     }
//     ToastUtils.toastShort(S.of(context).forwardCopySuccess);
//     controller.hideMenu();
//     HomeSourceDataManager.clickForwardMessageToolBarModule();
//   }
//
//   /// methodName
//   /// description 转发方法处理
//   /// date 2022/5/17 19:07
//   /// author LiuChuanan
//   void _onTapForward() {
//     if (widget.message.status == 3) {
//       controller.hideMenu();
//       ToastUtils.toastShort(S.of(context).forwardMessageExpiredCannotForward);
//       return;
//     }
//
//     if (widget.conversationType == ConversationType.V2TIM_GROUP) {
//       _groupChatInfo();
//     } else {
//       switch (widget.message.elemType) {
//         case MessageElemType.V2TIM_ELEM_TYPE_TEXT:
//           type = ForwardType.Text;
//           break;
//         case MessageElemType.V2TIM_ELEM_TYPE_IMAGE:
//           type = ForwardType.Image;
//           if (widget.message.imageElem!.imageList!.isEmpty) {
//             controller.hideMenu();
//             ToastUtils.toastShort(S.of(context).forwardMessageExpiredCannotForward);
//             return;
//           }
//           break;
//         case MessageElemType.V2TIM_ELEM_TYPE_SOUND:
//           type = ForwardType.Sound;
//           break;
//         default:
//           type = ForwardType.Text;
//           break;
//       }
//       HomeSourceDataManager.clickForwardMessageToolBarModule();
//       Provider.of<SearchContactModel>(context, listen: false).resetData();
//       Routes.navigateTo(
//         context,
//         Routes.searchContactPage,
//         routeSettings: RouteSettings(
//           arguments: SearchContactArguments(
//               conversationType: widget.conversationType,
//               message: widget.message,
//               forwardType: type,
//               chatInfo: widget.chatInfo,
//               groupInfo: widget.groupInfo
//           ),
//         ),
//       );
//       controller.hideMenu();
//     }
//   }
//
//   /// methodName
//   /// description 删除方法处理
//   /// date 2022/5/18 10:25
//   /// author LiuChuanan
//   void _onTapDelete() {
//     if (widget.conversationType == ConversationType.V2TIM_GROUP) {
//       _groupChatInfo(isDelete: true);
//     } else {
//       widget.onTapDelete();
//       controller.hideMenu();
//       HomeSourceDataManager.clickForwardMessageToolBarModule();
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     bool isSelf = widget.message.isSelf!;
//     double avatarSize = 40;
//     double maxWidth = textWidth;
//     switch (widget.message.elemType) {
//       case MessageElemType.V2TIM_ELEM_TYPE_TEXT:
//         crossCount = 3;
//         _menuItems = [
//           {"title": S.of(context).forwardSystemCopy,
//             "icon":Icons.content_copy,
//             "itemIndex":0,
//           },
//           {"title": S.of(context).forwardSystemForward,
//             "icon":Icons.send,
//             "itemIndex":1,
//           },
//           {"title": S.of(context).forwardSystemDelete,
//             "icon":Icons.delete,
//             "itemIndex":2,
//           },
//         ];
//         break;
//       default:
//         crossCount = 2;
//         _menuItems = [
//           {"title": S.of(context).forwardSystemForward,
//             "icon":Icons.send,
//             "itemIndex":1,
//           },
//           {"title": S.of(context).forwardSystemDelete,
//             "icon":Icons.delete,
//             "itemIndex":2,
//           },
//         ];
//         break;
//     }
//     return Row(
//       textDirection: isSelf ? TextDirection.rtl : TextDirection.ltr,
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: <Widget>[
//         PopupMenu(
//           controller: controller,
//           verticalMargin: -10,
//           arrowSize: 20,
//           child: Container(
//             constraints: BoxConstraints(maxWidth: maxWidth, minHeight: avatarSize),
//             decoration: BoxDecoration(
//               color: Colors.transparent,
//               borderRadius: BorderRadius.circular(3.0),
//             ),
//             child: widget.child,
//           ),
//           menuBuilder: _buildLongPressMenu,
//           barrierColor: Colors.transparent,
//           pressType: PressType.longPress,
//         )
//       ],
//     );
//   }
//
//   @override
//   void dispose() {
//     super.dispose();
//     controller.dispose();
//   }
//
//   Size boundingTextSize(String text, TextStyle style,  {int maxLines = 2^31, double maxWidth = double.infinity}) {
//     if (text.isEmpty) {
//       return Size.zero;
//     }
//     final TextPainter textPainter = TextPainter(
//         textDirection: TextDirection.ltr,
//         locale: Localizations.localeOf(navigatorKey.currentContext!),
//         text: TextSpan(text: text, style: style), maxLines: maxLines)
//       ..layout(maxWidth: maxWidth);
//     return textPainter.size;
//   }
// }