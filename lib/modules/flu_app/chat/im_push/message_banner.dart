// import 'dart:async';
// import 'dart:ui';
// import 'package:extended_image/extended_image.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:microcosm/app.dart';
// import 'package:microcosm/common/event/fire_engine.dart';
// import 'package:microcosm/common/values/colors.dart';
// import 'package:microcosm/utils/manager/microcosm_agreement_manager.dart';
//
// class MessageBanner {
//
//   static late OverlayEntry? overlayEntry;
//   static bool isShow = false;
//   static late int count = 0;
//   ///声明变量
//   static Timer? _timer;
//   static show() {
//     remove();
//     overlayEntry = OverlayEntry(builder: (context){
//       return MessageBannerPage();
//     });
//     Overlay.of(navigatorKey.currentContext!)?.insert(overlayEntry!);
//     isShow = true;
//     count = 0;
//
//     _topFloatCallBack();
//   }
//
//   static _topFloatCallBack() {
//     _timer = Timer.periodic(Duration(milliseconds: 1000), (timer) {
//       ///自增
//       count++;
//       if (count == 5) {
//         _timer?.cancel();
//         autoRemove();
//       }
//     });
//   }
//
//   static remove() {
//     if (isShow) {
//       count = 0;
//       _timer?.cancel();
//       overlayEntry!.remove();
//       isShow = false;
//     }
//   }
//
//   static autoRemove() {
//     if (isShow) {
//       FireEngine.sendNotify(event: MessageEvent.RemoveMessageBanner);
//     }
//   }
// }
//
// class MessageBannerPage extends StatefulWidget {
//   const MessageBannerPage({Key? key}) : super(key: key);
//   @override
//   State<StatefulWidget> createState() => _MessageBannerPageState();
//
// }
//
// class _MessageBannerPageState extends State<MessageBannerPage> with SingleTickerProviderStateMixin{
//   late AnimationController animationController;
//   late Animation<double> animation;
//
//   @override
//   void initState() {
//     super.initState();
//     _addAnimationListener();
//     _handleFireEngine();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Positioned(
//       top: animation.value,
//       child: Dismissible(
//         key: ObjectKey("${DateTime.now()} + 1"),
//         direction: DismissDirection.up,
//         child: Dismissible(
//           key: ObjectKey("${DateTime.now()}"),
//           child: InkWell(
//             child: Padding(
//               padding: EdgeInsets.only(left: 15, right: 15),
//               child: Container(
//                 child: Padding(
//                   padding: EdgeInsets.only(
//                       left: 12, right: 12, top: 12),
//                   child: Row(
//                     crossAxisAlignment:
//                     CrossAxisAlignment.start,
//                     mainAxisAlignment:
//                     MainAxisAlignment.spaceBetween,
//                     children: [
//                       Row(
//                         crossAxisAlignment:
//                         CrossAxisAlignment.start,
//                         children: [
//                           ClipRRect(
//                             child: ExtendedImage.network(
//                               "https://static-microcosm-test.wxianlai.com/FESP_TEST/portal/main/201.png",
//                               height: 42,
//                               width: 42,
//                               fit: BoxFit.fill,
//                               cache: true,
//                               borderRadius:
//                               BorderRadius.circular(8.0.r),
//                             ),
//                             borderRadius:
//                             BorderRadius.circular(21),
//                           ),
//                           Padding(
//                               padding: EdgeInsets.only(
//                                 left: 12,
//                               )),
//                           SizedBox(
//                             width: MediaQuery.of(context)
//                                 .size
//                                 .width -
//                                 67 -
//                                 88 -
//                                 30,
//                             child: Column(
//                               mainAxisAlignment:
//                               MainAxisAlignment.start,
//                               crossAxisAlignment:
//                               CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   "这里显示标题这里显示标题这里显示标题",
//                                   style: TextStyle(
//                                     fontSize: 15.sp,
//                                     color:
//                                     AppColors.colorFF333333,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                   maxLines: 1,
//                                 ),
//                                 Padding(
//                                     padding: EdgeInsets.only(
//                                         top: 5.h)),
//                                 Text(
//                                   "这里内容最多展示两排字符这里内容最多展示两排字符这里",
//                                   style: TextStyle(
//                                     fontSize: 13.sp,
//                                     color:
//                                     AppColors.colorFF333333,
//                                   ),
//                                   maxLines: 2,
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                       InkWell(
//                         child: Container(
//                           height: 29,
//                           width: 58,
//                           decoration: BoxDecoration(
//                             color: AppColors.colorFFF9DB4A,
//                             borderRadius:
//                             BorderRadius.circular(15),
//                           ),
//                         ),
//                         onTap: () {},
//                       ),
//                     ],
//                   ),
//                 ),
//                 height: 84.h,
//                 width: MediaQuery.of(context).size.width - 30,
//                 decoration: BoxDecoration(
//                   color: AppColors.colorWhite,
//                   borderRadius: BorderRadius.circular(8.0.r),
//                   boxShadow: const [
//                     BoxShadow(
//                       color: AppColors.color12000000,
//                       offset: Offset(0, 0),
//                       blurRadius: 3.5,
//                       spreadRadius: 6.5,
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             onTap: () {
//               _handleEvent();
//
//               /// 这里要做消息的跳转
//               ///CommonEventManager.handleEvent(itemBeanEntity: itemBeanEntity);
//             },
//           ),
//           direction: DismissDirection.horizontal,
//           onDismissed: (direction) {
//             _handleEvent();
//           },
//         ),
//         onDismissed: (direction) {
//           _handleEvent();
//         },
//       ),
//     );
//   }
//
//   _addAnimationListener() {
//     animationController = AnimationController(
//         duration: const Duration(milliseconds: 500), vsync: this);
//     animation = Tween<double>(
//         begin: MediaQueryData.fromWindow(window).padding.top, end: -200.0)
//         .animate(animationController);
//     animation.addListener(() {
//       if (mounted) {
//         setState(() {});
//       }
//     });
//
//     animation.addStatusListener((status) {
//       if (status == AnimationStatus.completed) {
//         _handleEvent();
//       }
//     });
//   }
//
//   _handleEvent({String? jump}) {
//     MessageBanner.remove();
//     if (jump != null) {
//       MicrocosmAgreementManager.handleOpenUrl(url: jump);
//     }
//   }
//
//   _handleFireEngine() {
//     FireEngine.eventBus?.on().listen((event) {
//       EventEntity _event = event;
//       if (_event.event == MessageEvent.RemoveMessageBanner) {
//         animationController.forward();
//       }
//     });
//   }
//
//   @override
//   void dispose() {
//     super.dispose();
//     animationController.dispose();
//   }
//
// }
