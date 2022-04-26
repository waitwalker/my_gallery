// import 'dart:async';
// import 'dart:math';
// import 'dart:ui';
// import 'package:badges/badges.dart';
// import 'package:extended_image/extended_image.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:flutter_swiper_null_safety/flutter_swiper_null_safety.dart';
// import 'package:flutter_vibrate/flutter_vibrate.dart';
// import 'package:just_audio/just_audio.dart';
// import 'package:microcosm/common/components/dialog/update_dialog.dart';
// import 'package:microcosm/common/components/download_progress.dart';
// import 'package:microcosm/common/components/error_page.dart';
// import 'package:microcosm/common/components/loading_page.dart';
// import 'package:microcosm/common/event/common_event_manager.dart';
// import 'package:microcosm/common/values/colors.dart';
// import 'package:microcosm/config/img.dart';
// import 'package:microcosm/generated/l10n.dart';
// import 'package:microcosm/model/home/bean/home_item_bean_entity.dart';
// import 'package:microcosm/model/home/hall_user_assets_info_model.dart';
// import 'package:microcosm/model/home/home_fire.dart';
// import 'package:microcosm/model/home/home_model.dart';
// import 'package:microcosm/model/home/home_service.dart';
// import 'package:microcosm/model/login/user_info_repo.dart';
// import 'package:microcosm/model/navigator/navigator_view_model.dart';
// import 'package:microcosm/model/personal/personal_info_model.dart';
// import 'package:microcosm/model/settings/my_provider.dart';
// import 'package:microcosm/model/store/store_provider.dart';
// import 'package:microcosm/navigation/custom_tab_item.dart';
// import 'package:microcosm/utils/log.dart';
// import 'package:microcosm/utils/manager/unity_manager.dart';
// import 'package:microcosm/utils/platform.dart';
// import 'package:microcosm/utils/shu_mei_util.dart';
// import 'package:microcosm/utils/singleton_manager.dart';
// import 'package:microcosm/utils/storage.dart';
// import 'package:microcosm/utils/toast_utils.dart';
// import 'package:provider/provider.dart';
// import 'package:shake_animation_widget/shake_animation_widget.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'hall_user_assets_info_widget.dart';
//
// /// Created by yufengyang on 2022/2/17 6:11 下午
// /// @des home
//
// class HomeIndex extends StatefulWidget with BasePage {
//   const HomeIndex({Key? key}) : super(key: key);
//
//   @override
//   State<StatefulWidget> createState() => _HomePage();
//
//   @override
//   String get darkIcon => Img.gameDark;
//
//   @override
//   String get icon => Img.game;
//
//   @override
//   String get label => S.current.home;
//
//   @override
//   int get tabItemIndex => 0;
// }
//
// class _HomePage extends State<HomeIndex> with SingleTickerProviderStateMixin {
//   late int downloadValue = 10;
//   late List<HomeItemBeanEntity> popupList = [];
//   final ShakeAnimationController _shakeAnimationController = ShakeAnimationController();
//   late AnimationController animationController;
//   late Animation<double> animation;
//   final GlobalKey<_HomePage> _globalKey = GlobalKey();
//   List<GuideChild> children = [];
//   bool isNewComer = false;
//   /// 是否显示弹窗
//   bool shouldPopup = false;
//   Timer? timer;
//
//
//   @override
//   void initState() {
//     super.initState();
//     /// 1.先去获取红点缓存
//     /// 2.获取首页配置
//     /// 3.校验是否是新人
//     _fetchHomeData();
//     animationController = AnimationController(
//         duration: const Duration(milliseconds: 1500), vsync: this);
//     animation = Tween<double>(
//         begin: MediaQueryData.fromWindow(window).padding.top, end: -200.0)
//         .animate(animationController);
//     animation.addListener(() {
//       setState(() {});
//     });
//
//     animation.addStatusListener((status) {
//       if (status == AnimationStatus.completed) {
//         HomeItemBeanEntity itemBeanEntity =
//             Provider.of<HomeModel>(context, listen: false).topFloatBean;
//         itemBeanEntity.shouldShow = 0;
//         Provider.of<HomeModel>(context, listen: false)
//             .setTopFloatData(itemBeanEntity);
//       }
//     });
//
//     Provider.of<HallUserAssetsInfoModel>(context, listen: false)
//         .getUserAssetsInfo();
//     Provider.of<HallUserAssetsInfoModel>(context, listen: false)
//         .getClockRewardStates(context, (t) {});
//
//     ///请求个人主页接口，获得性别，生日等基础信息
//     Provider.of<PersonalInfoModel>(context, listen: false).fetchPersonalInfo();
//
//     /// 获取商城、我的模块配置
//     Provider.of<StoreProvider>(context, listen: false)
//         .fetchStoreModuleData(true);
//     Provider.of<StoreProvider>(context, listen: false).fetchStoreInfo(true);
//     Provider.of<MyProvider>(context, listen: false).fetchMineModuleData(true);
//
//   }
//
//   /// methodName _fetchHomeData
//   /// description 获取首页数据
//   /// date 2022/4/22 19:08
//   /// author LiuChuanan
//   _fetchHomeData() {
//     if (SingletonManager.sharedInstance.homeCanLoad) {
//       /// 请求首页数据
//       HomeService.fetchHomeData(Provider.of<HomeModel>(context, listen: false));
//       HomeFire.eventBus.on().listen((event) async{
//         HomeEvent _event = event;
//         if (_event.type == 1) {
//           if (mounted) {
//             bool newComer = await _readUserCache();
//             Log.i(newComer);
//             if (Provider.of<HomeModel>(context, listen: false).popupList.isNotEmpty) {
//               popupList = Provider.of<HomeModel>(context, listen: false).popupList;
//               shouldPopup = true;
//               if (newComer) {
//                 HomeService.fetchNewPersonGiftBag(Provider.of<HomeModel>(context, listen: false));
//               } else {
//                 _commonAction();
//               }
//             } else {
//               shouldPopup = false;
//               if (newComer) {
//                 HomeService.fetchNewPersonGiftBag(Provider.of<HomeModel>(context, listen: false));
//               }
//             }
//           }
//         } else if (_event.type == 21) {
//           /// 获取新人礼包 接口请求数据成功
//           CommonEventManager.newComerGiftBagDialog(
//             context: context,
//             content: Provider.of<HomeModel>(context, listen: false).newPersonGuidanceEntity.rewardMsg,);
//         } else if (_event.type == -21){
//           /// 获取新人礼包失败 & 应该弹弹窗
//           if (shouldPopup) {
//             _commonAction();
//           }
//         } else if (_event.type == 3) {
//           /// 点击确定调用领取新人礼包接口成功
//           HomeService.fetchFeedBackNewPersonGiftBag();
//           await _writeUserCache();
//           showGuild();
//         } else if (_event.type == 4) {
//           readHomeTabItemBadge();
//         }
//       });
//     }
//   }
//
//   /// methodName readHomeTabItemBadge
//   /// description 读取首页item badge缓存记录
//   /// date 2022/4/22 16:17
//   /// author LiuChuanan
//   Future<void> readHomeTabItemBadge() async {
//     /// 拼接 userid
//     String homeKey = "${UserInfoRepo.userId}homeBadge";
//     int homeCount = await SpUtils().getStorage(homeKey) ?? 0;
//     if (homeCount == 0) {
//       Provider.of<NavigatorViewModel>(context, listen: false)
//           .setHomeTabCount(Provider.of<HomeModel>(context, listen: false).homeTabItemCount);
//     }
//   }
//
//   /// methodName showGuild
//   /// description 显示新人引导
//   /// date 2022/4/26 12:02
//   /// author LiuChuanan
//   showGuild() {
//     RenderObject? _renderBox = _globalKey.currentContext?.findRenderObject();
//     RenderBox renderBox = _renderBox as RenderBox;
//
//     if (!renderBox.size.isEmpty) {
//       Offset childOffset = renderBox.localToGlobal(Offset.zero);
//       Offset descOffset =
//       Offset(10, childOffset.dy + renderBox.size.height + 10);
//       children.add(GuideChild()
//         ..offset = childOffset
//         ..childSize = renderBox.size
//         ..descOffset = descOffset
//         ..descWidget = getDescWidget()
//         ..callback = _removeNewPersonGuideCallback
//         ..closeByClickChild = true
//         ..childShape = ChildShape.ROUND_RECTANGLE);
//       GuideLayout.showGuide(context, children, completedCallBack);
//     }
//   }
//
//   /// methodName _removeNewPersonGuideCallback
//   /// description 移除新人引导回调添加
//   /// date 2022/4/26 12:01
//   /// author LiuChuanan
//   _removeNewPersonGuideCallback() {
//
//   }
//
//   /// methodName completedCallBack
//   /// description 点击完成后回调
//   /// date 2022/4/26 14:22
//   /// author LiuChuanan
//   completedCallBack() {
//     Future.delayed(Duration(milliseconds: 500),(){
//       if (shouldPopup) {
//         _commonAction();
//       }
//     });
//   }
//
//   /// methodName getDescWidget
//   /// description 新手引导描述
//   /// date 2022/4/26 14:53
//   /// author LiuChuanan
//   Widget getDescWidget() {
//     return Padding(
//       padding: EdgeInsets.only(top: 35),
//       child: Container(
//         width: 273,
//         height: 63,
//         decoration: BoxDecoration(
//           image: const DecorationImage(
//             image: AssetImage(
//               Img.newComerBgText,
//             ),
//             fit: BoxFit.fill,
//           ),
//         ),
//         child: Padding(
//           padding: EdgeInsets.only(left: 40, right: 8, top: 3,),
//           child: Container(
//             alignment: Alignment.center,
//             child: Text(Provider.of<HomeModel>(context, listen: false).newPersonGuidanceEntity.introMsg,
//               maxLines: 2,
//               style: TextStyle(
//                 color: AppColors.colorWhite,
//                 fontSize: 14.sp,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   /// methodName _readUserCache
//   /// description 读取用户缓存记录
//   /// date 2022/4/22 19:07
//   /// author LiuChuanan
//   Future<bool> _readUserCache() async {
//     int userId = await SpUtils().getStorage("home_user_id") ?? 0;
//     String shuMeiId = await SpUtils().getStorage("home_shumei_id") ?? "";
//     if (userId == UserInfoRepo.userId && shuMeiId == ShuMeiUtil.shuMeiDeviceId) {
//       isNewComer = false;
//     } else {
//       isNewComer = true;
//     }
//     return !(userId == UserInfoRepo.userId && shuMeiId == ShuMeiUtil.shuMeiDeviceId);
//   }
//
//   /// methodName _writeUserCache
//   /// description 缓存用户信息
//   /// date 2022/4/22 19:11
//   /// author LiuChuanan
//   Future<void> _writeUserCache() async {
//     await SpUtils().setStorage("home_user_id", UserInfoRepo.userId);
//     await SpUtils().setStorage("home_shumei_id", ShuMeiUtil.shuMeiDeviceId);
//   }
//
//   @override
//   void dispose() {
//     if (mounted) {
//       animationController.dispose();
//     }
//     super.dispose();
//   }
//
//   /// methodName _removePopupData
//   /// description 移除弹窗队列的第一条数据
//   /// date 2022/4/6 17:27
//   /// author LiuChuanan
//   Future<void> _removePopupData() async {
//     if (popupList.isNotEmpty) {
//       HomeItemBeanEntity oldBeanEntity = popupList.first;
//       bool contain = false;
//       if (oldBeanEntity.shouldShow == 1) {
//         oldBeanEntity.shouldShow = 0;
//         oldBeanEntity.timeInterval = DateTime.now().millisecondsSinceEpoch;
//         String popKey = "${UserInfoRepo.userId}popupList";
//         var data = await SpUtils().getStorage(popKey);
//         List list = [];
//         for (int i = 0; i < data.length; i++) {
//           HomeItemBeanEntity beanEntity = HomeItemBeanEntity.fromJson(data[i]);
//           if (beanEntity.pop.key == oldBeanEntity.pop.key) {
//             contain = true;
//             /// 只显示一次的 不让再次显示
//             if (beanEntity.pop.frq == 0) {
//               beanEntity.shouldShow = 0;
//             } else if (beanEntity.pop.frq == 1) {
//               beanEntity.shouldShow = 0;
//               /// 把当前点击的时间保存
//               beanEntity.timeInterval = DateTime.now().millisecondsSinceEpoch;
//             } else if (beanEntity.pop.frq == 2) {
//               beanEntity.shouldShow = 1;
//             }
//           }
//           list.add(beanEntity);
//         }
//
//         if (contain == false) {
//           list.add(oldBeanEntity);
//         }
//         await SpUtils().setStorage(popKey, list);
//       }
//       popupList.removeAt(0);
//     }
//   }
//
//   /// methodName _commonAction
//   /// description 弹窗基本两种类型图片弹窗和更新弹窗
//   /// date 2022/4/6 10:51
//   /// author LiuChuanan
//   _commonAction() {
//     if (popupList.isNotEmpty) {
//       HomeItemBeanEntity itemBeanEntity = popupList.first;
//       /// 图片弹窗
//       if (itemBeanEntity.pop.pop == 0) {
//         CommonEventManager.imageDialog(
//           context: context,
//           imagePath: itemBeanEntity.iconUrl,
//           closeAction: () async {
//             Navigator.pop(context);
//             Future.delayed(Duration(microseconds: 100), () async {
//               await _removePopupData();
//               if (popupList.isNotEmpty) {
//                 _commonAction();
//               }
//             });
//           },
//           onTap: () {
//             Navigator.pop(context);
//             Future.delayed(Duration(microseconds: 100), () async {
//               await _removePopupData();
//               if (popupList.isNotEmpty) {
//                 _commonAction();
//               }
//               CommonEventManager.handleEvent(itemBeanEntity: itemBeanEntity);
//             });
//           },
//         );
//       } else if (itemBeanEntity.pop.pop == 2) {
//         if (itemBeanEntity.update.force) {
//           /// 强制版本更新
//           dialog = UpdateDialog.showUpdate(context,
//               title: '', updateContent: itemBeanEntity.update.description,
//               onUpdate: () async {
//                 if (PlatformUtils.isIOS) {
//                   /// 跳转到苹果商店
//                   if (await canLaunch(itemBeanEntity.update.package)) {
//                     await launch(itemBeanEntity.update.package);
//                   } else {
//                     ToastUtils.toastShort(S.current.schemeIsNotExist);
//                   }
//                 } else if (PlatformUtils.isAndroid) {
//                   /// 1.开启下载
//
//                   /// 2.下载完打开apk open_file
//                 }
//
//                 /// 更新进度条显示  下面代码是调试所用
//                 dialog?.showProgress(true);
//                 Timer.periodic(const Duration(milliseconds: 50), (Timer timer) {
//                   progress = progress + 0.02;
//                   if (progress > 1.0001) {
//                     timer.cancel();
//                     // dialog!.dismiss();
//                     /// 更新进度条移除
//                     dialog?.showProgress(false);
//                     progress = 0;
//                   } else {
//                     dialog!.update(progress);
//                   }
//                 });
//               });
//         } else {
//           /// 功能弹窗 目前只有游戏更新
//           CommonEventManager.optionalUpdateDialog(
//             context: context,
//             title: "",
//             content: itemBeanEntity.update.description,
//             noUpdateOnTap: () {
//               /// 执行非强制更新逻辑 安卓要后台下载
//               Navigator.pop(context);
//               Future.delayed(Duration(microseconds: 200), () async {
//                 await _removePopupData();
//                 if (popupList.isNotEmpty) {
//                   _commonAction();
//                 }
//                 CommonEventManager.handleEvent(itemBeanEntity: itemBeanEntity);
//               });
//             },
//             updateOnTap: () async {
//               /// 执行强制更新逻辑
//               /// 执行非强制更新逻辑 安卓要后台下载 iOS的要跳转到App Store
//               if (PlatformUtils.isIOS) {
//                 /// 跳转到苹果商店
//                 if (await canLaunch(itemBeanEntity.update.package)) {
//                   await launch(itemBeanEntity.update.package);
//                 } else {
//                   ToastUtils.toastShort(S.current.schemeIsNotExist);
//                 }
//               } else if (PlatformUtils.isAndroid) {
//                 /// 1.开启后台下载
//
//                 /// 2.下载完打开apk open_file
//               }
//
//               Navigator.pop(context);
//               Future.delayed(Duration(microseconds: 200), () async {
//                 await _removePopupData();
//                 if (popupList.isNotEmpty) {
//                   _commonAction();
//                 }
//                 CommonEventManager.handleEvent(itemBeanEntity: itemBeanEntity);
//               });
//             },
//           );
//         }
//       }
//     }
//   }
//
//   UpdateDialog? dialog;
//
//   double progress = 0.0;
//
//   /// methodName forceUpdateCallBack
//   /// description 强制更新回调 如果是强制更新，不用移除弹窗，这个会一直显示，直到用户更新
//   /// date 2022/4/6 11:30
//   /// author LiuChuanan
//   void forceUpdateCallBack() {
//     if (PlatformUtils.isIOS) {
//       /// 跳转到苹果商店
//
//     } else if (PlatformUtils.isAndroid) {
//       /// 1.开启下载
//
//       /// 2.下载完打开apk open_file
//     }
//
//     /// 更新进度条显示
//     dialog?.showProgress(true);
//     Timer.periodic(const Duration(milliseconds: 50), (Timer timer) {
//       progress = progress + 0.02;
//       if (progress > 1.0001) {
//         timer.cancel();
//         // dialog!.dismiss();
//         /// 更新进度条移除
//         dialog?.showProgress(false);
//         progress = 0;
//       } else {
//         dialog!.update(progress);
//       }
//     });
//   }
//
//   /// methodName _topFloatCallBack
//   /// description  首页顶部条幅信息 如果有IM消息过来的话 直接调用这个方法 5s后移除这个消息
//   /// date 2022/3/23 3:01 下午
//   /// author LiuChuanan
//   _topFloatCallBack() {
//     late int count = 0;
//     /// 首页应用内消息调试
//     HomeItemBeanEntity itemBeanEntity = Provider.of<HomeModel>(context, listen: false).floatingButton.first;
//     itemBeanEntity.shouldShow = 1;
//     Provider.of<HomeModel>(context,listen: false).setTopFloatData(itemBeanEntity);
//     initAudioPlayer();
//     var _type = FeedbackType.heavy;
//     Vibrate.feedback(_type);
//     animationController.reset();
//     _shakeAnimationController.start();
//     var period = Duration(seconds: 1);
//     if (timer != null) {
//       timer?.cancel();
//     }
//     timer = Timer.periodic(period, (timer){
//       Log.i("当前时间计数:$count");
//       count++;
//       if (count >= 5) {
//         timer.cancel();
//         /// 消失
//         animationController.forward();
//         // itemBeanEntity.shouldShow = 0;
//         // Provider.of<HomeModel>(context,listen: false).setTopFloatData(itemBeanEntity);
//       }
//     });
//     // Timer.periodic(period, (timer) {
//     //
//     // });
//   }
//
//   initAudioPlayer() async {
//     final player = AudioPlayer();
//     player.stop();
//     var duration = await player.setAsset('assets/nasa_on_a_mission.mp3');
//     player.play();
//   }
//
//   /// methodName _newMessage
//   /// description 有新的消息
//   /// date 2022/4/13 11:37
//   /// author LiuChuanan
//   // _newMessage() {
//   //   HomeItemBeanEntity itemBeanEntity = Provider.of<HomeModel>(context, listen: false).topFloatBean;
//   //   itemBeanEntity.shouldShow = 1;
//   //   Provider.of<HomeModel>(context, listen: false).setTopFloatData(itemBeanEntity);
//   //   controller.reset();
//   // }
//
//   @override
//   Widget build(BuildContext context) {
//     return Selector<HomeModel, HomeModel>(
//       builder: (ctx, model, child) {
//         /// 页面加载中状态
//         if (model.homePageStatus == 1) {
//           return Scaffold(
//             backgroundColor: Colors.white,
//             appBar: HallUserAssetsInfoWidget(),
//             body: InkWell(
//               child: LoadingPage(),
//               onTap: () {
//                 /// 以下数据为了模拟数据
//                 int value = Random().nextInt(3);
//                 if (value == 0) {
//                   value = 1;
//                 }
//                 Provider.of<HomeModel>(context, listen: false)
//                     .changeHomeStatus(value);
//
//                 /// 请求首页数据
//                 HomeService.fetchHomeData(
//                     Provider.of<HomeModel>(context, listen: false));
//               },
//             ),
//           );
//         }
//
//         /// 页面加载错误状态
//         if (model.homePageStatus == 2) {
//           return Scaffold(
//             backgroundColor: Colors.white,
//             appBar: HallUserAssetsInfoWidget(),
//             body: Padding(
//               padding: EdgeInsets.only(left: 15.w, right: 15.w),
//               child: ErrorPage(
//                 content: model.errorMsg,
//                 onTap: () {
//                   /// 以下数据为了模拟数据
//                   int value = Random().nextInt(3);
//                   if (value == 0) {
//                     value = 1;
//                   }
//                   Provider.of<HomeModel>(context, listen: false)
//                       .changeHomeStatus(value);
//
//                   /// 请求首页数据
//                   HomeService.fetchHomeData(
//                       Provider.of<HomeModel>(context, listen: false));
//                 },
//               ),
//             ),
//           );
//         }
//
//         /// 页面正常状态
//         return Stack(
//           children: [
//             Scaffold(
//               appBar: HallUserAssetsInfoWidget(),
//               body: Padding(
//                 padding: EdgeInsets.only(left: 0, right: 0),
//                 child: Column(
//                   children: [
//                     Expanded(
//                       child: ListView(
//                         children: [
//
//                           InkWell(
//                             child: Container(
//                               height: 100,
//                               width: MediaQuery.of(context).size.width,
//                               color: Colors.orange,
//                               alignment: Alignment.center,
//                               child: Text("新消息", style: TextStyle(fontSize: 25),),
//                             ),
//                             onTap: (){
//                               _topFloatCallBack();
//                             },
//                           ),
//
//                           /// banner
//                           Padding(
//                             padding: EdgeInsets.only(left: 15, right: 15),
//                             child: Selector<HomeModel, HomeModel>(
//                               builder: (contextX, model, child) {
//                                 return (model.bannerList.length > 0)
//                                     ? SizedBox(
//                                   height: 68,
//                                   child: Column(
//                                     children: [
//                                       Padding(
//                                           padding: EdgeInsets.only(
//                                             top: 12,
//                                           )),
//                                       SizedBox(
//                                         height: 56,
//                                         child: Swiper(
//                                           physics: model
//                                               .bannerList.length >
//                                               1
//                                               ? AlwaysScrollableScrollPhysics()
//                                               : NeverScrollableScrollPhysics(),
//                                           itemBuilder: (context, index) {
//                                             HomeItemBeanEntity banner =
//                                             model.bannerList[index];
//                                             String imageUrl =
//                                                 banner.iconUrl;
//                                             return InkWell(
//                                               child: Container(
//                                                 decoration: BoxDecoration(
//                                                   color:
//                                                   Colors.transparent,
//                                                   borderRadius:
//                                                   BorderRadius
//                                                       .circular(8.0),
//                                                 ),
//                                                 constraints:
//                                                 BoxConstraints
//                                                     .expand(),
//                                                 child: ClipRRect(
//                                                   borderRadius:
//                                                   BorderRadius
//                                                       .circular(8.0),
//                                                   child: ExtendedImage
//                                                       .network(
//                                                     imageUrl,
//                                                     width: MediaQuery.of(
//                                                         context)
//                                                         .size
//                                                         .width,
//                                                     fit: BoxFit.fill,
//                                                     cache: true,
//                                                   ),
//                                                 ),
//                                               ),
//                                               onTap: () {
//                                                 CommonEventManager
//                                                     .handleEvent(
//                                                     itemBeanEntity:
//                                                     banner);
//                                               },
//                                             );
//                                           },
//                                           itemCount:
//                                           model.bannerList.length,
//                                           autoplay:
//                                           model.bannerList.length > 1
//                                               ? true
//                                               : false,
//                                           pagination: SwiperPagination(
//                                               alignment:
//                                               Alignment.bottomRight,
//                                               builder: SwiperCustomPagination(
//                                                   builder: (BuildContext
//                                                   context,
//                                                       SwiperPluginConfig
//                                                       config) {
//                                                     return model.bannerList
//                                                         .length >
//                                                         1
//                                                         ? XLIndicator(
//                                                         config
//                                                             .activeIndex,
//                                                         model.bannerList
//                                                             .length)
//                                                         : Container();
//                                                   })),
//                                           indicatorLayout:
//                                           PageIndicatorLayout.SCALE,
//                                         ),
//                                       )
//                                     ],
//                                   ),
//                                 )
//                                     : Container();
//                               },
//                               selector: (contextX, model) {
//                                 return model;
//                               },
//                               shouldRebuild: (pre, model) => true,
//                             ),
//                           ),
//
//                           /// 主模块配置
//                           Padding(
//                             padding: EdgeInsets.only(left: 15, right: 15),
//                             child: Selector<HomeModel, HomeModel>(
//                                 builder: (ctx, model, child) {
//                                   return model.mainModuleList.length > 0
//                                       ? _mainModuleBuilder(
//                                       list: model.mainModuleList)
//                                       : Container();
//                                 }, selector: (ctx, model) {
//                               return model;
//                             }),
//                           ),
//
//                           /// 子模块入口
//                           Padding(
//                             padding: EdgeInsets.only(left: 15, right: 15),
//                             child: Selector<HomeModel, HomeModel>(
//                                 builder: (ctx, model, child) {
//                                   return model.subModuleList.length > 0
//                                       ? Column(
//                                     crossAxisAlignment:
//                                     CrossAxisAlignment.start,
//                                     children: [
//                                       SizedBox(
//                                         height: 12,
//                                       ),
//
//                                       /// 更多文本
//                                       Text(
//                                         S.of(context).home_more,
//                                         textAlign: TextAlign.left,
//                                         style: TextStyle(
//                                           fontSize: 18,
//                                           fontWeight: FontWeight.bold,
//                                           color: AppColors.colorFF333333,
//                                         ),
//                                       ),
//                                       _subModulePage(
//                                           gameList: model.subModuleList),
//                                     ],
//                                   )
//                                       : Container();
//                                 }, selector: (ctx, model) {
//                               return model;
//                             }),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//
//             /// 顶部消息条幅
//             Selector<HomeModel, HomeModel>(builder: (ctx, model, child) {
//               return model.topFloatBean.shouldShow == 1
//                   ? Positioned(
//                 top: animation.value,
//                 child: ShakeAnimationWidget(
//                   shakeAnimationController: _shakeAnimationController,
//                   shakeAnimationType: ShakeAnimationType.LeftRightShake,
//                   ///设置开启抖动
//                   isForward: true,
//                   ///默认为 0 无限执行
//                   shakeCount: 2,
//                   ///抖动的幅度 取值范围为[0,1]
//                   shakeRange: 0.2,
//                   child: Dismissible(
//                     key: ObjectKey("${DateTime.now()} + 1"),
//                     direction: DismissDirection.up,
//                     child: Dismissible(
//                       key: ObjectKey("${DateTime.now()}"),
//                       child: InkWell(
//                         child: Padding(
//                           padding: EdgeInsets.only(left: 15, right: 15),
//                           child: Container(
//                             child: Padding(
//                               padding: EdgeInsets.only(
//                                   left: 12, right: 12, top: 12),
//                               child: Row(
//                                 crossAxisAlignment:
//                                 CrossAxisAlignment.start,
//                                 mainAxisAlignment:
//                                 MainAxisAlignment.spaceBetween,
//                                 children: [
//                                   Row(
//                                     crossAxisAlignment:
//                                     CrossAxisAlignment.start,
//                                     children: [
//                                       ClipRRect(
//                                         child: ExtendedImage.network(
//                                           model
//                                               .floatingButton.first.iconUrl,
//                                           height: 42,
//                                           width: 42,
//                                           fit: BoxFit.fill,
//                                           cache: true,
//                                           borderRadius:
//                                           BorderRadius.circular(8.0.r),
//                                         ),
//                                         borderRadius:
//                                         BorderRadius.circular(21),
//                                       ),
//                                       Padding(
//                                           padding: EdgeInsets.only(
//                                             left: 12,
//                                           )),
//                                       SizedBox(
//                                         width: MediaQuery.of(context)
//                                             .size
//                                             .width -
//                                             67 -
//                                             88 -
//                                             30,
//                                         child: Column(
//                                           mainAxisAlignment:
//                                           MainAxisAlignment.start,
//                                           crossAxisAlignment:
//                                           CrossAxisAlignment.start,
//                                           children: [
//                                             Text(
//                                               "这里显示标题这里显示标题这里显示标题",
//                                               style: TextStyle(
//                                                 fontSize: 15.sp,
//                                                 color:
//                                                 AppColors.colorFF333333,
//                                                 fontWeight: FontWeight.bold,
//                                               ),
//                                               maxLines: 1,
//                                             ),
//                                             Padding(
//                                                 padding: EdgeInsets.only(
//                                                     top: 5.h)),
//                                             Text(
//                                               "这里内容最多展示两排字符这里内容最多展示两排字符这里",
//                                               style: TextStyle(
//                                                 fontSize: 13.sp,
//                                                 color:
//                                                 AppColors.colorFF333333,
//                                               ),
//                                               maxLines: 2,
//                                             ),
//                                           ],
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                   InkWell(
//                                     child: Container(
//                                       height: 29,
//                                       width: 58,
//                                       decoration: BoxDecoration(
//                                         color: AppColors.colorFFF9DB4A,
//                                         borderRadius:
//                                         BorderRadius.circular(15),
//                                       ),
//                                     ),
//                                     onTap: () {},
//                                   ),
//                                 ],
//                               ),
//                             ),
//                             height: 84.h,
//                             width: MediaQuery.of(context).size.width - 30,
//                             decoration: BoxDecoration(
//                               color: AppColors.colorWhite,
//                               borderRadius: BorderRadius.circular(8.0.r),
//                               boxShadow: const [
//                                 BoxShadow(
//                                   color: AppColors.color12000000,
//                                   offset: Offset(0, 0),
//                                   blurRadius: 3.5,
//                                   spreadRadius: 6.5,
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                         onTap: () {
//                           HomeItemBeanEntity itemBeanEntity =
//                               model.topFloatBean;
//                           itemBeanEntity.shouldShow = 0;
//                           Provider.of<HomeModel>(context, listen: false)
//                               .setTopFloatData(itemBeanEntity);
//
//                           /// 这里要做消息的跳转
//                           ///CommonEventManager.handleEvent(itemBeanEntity: itemBeanEntity);
//                         },
//                       ),
//                       direction: DismissDirection.horizontal,
//                       onDismissed: (direction) {
//                         HomeItemBeanEntity itemBeanEntity =
//                             model.topFloatBean;
//                         itemBeanEntity.shouldShow = 0;
//                         Provider.of<HomeModel>(context, listen: false)
//                             .setTopFloatData(itemBeanEntity);
//                       },
//                     ),
//                     onDismissed: (direction) {
//                       HomeItemBeanEntity itemBeanEntity =
//                           model.topFloatBean;
//                       itemBeanEntity.shouldShow = 0;
//                       Provider.of<HomeModel>(context, listen: false)
//                           .setTopFloatData(itemBeanEntity);
//                     },
//                   ),
//                 ),
//               )
//                   : Container();
//             }, selector: (ctx, model) {
//               return model;
//             }),
//
//             /// 悬浮按钮
//             Selector<HomeModel, HomeModel>(builder: (ctx, model, child) {
//               return model.floatingButton.length > 0
//                   ? FloatBox(
//                 screenWidth: MediaQuery.of(context).size.width,
//                 safeContentHeight: MediaQuery.of(context).size.height -
//                     MediaQuery.of(context).padding.top -
//                     MediaQuery.of(context).padding.bottom -
//                     kToolbarHeight -
//                     kBottomNavigationBarHeight,
//                 iconUrl: model.floatingButton.first.iconUrl,
//                 onTap: () {
//                   CommonEventManager.handleEvent(
//                       itemBeanEntity: model.floatingButton.first);
//                 },
//               )
//                   : Container();
//             }, selector: (ctx, model) {
//               return model;
//             }),
//           ],
//         );
//       },
//       selector: (ctx, model) {
//         return model;
//       },
//       shouldRebuild: (pre, model) => true,
//     );
//   }
//
//   /// methodName _moduleBuilder
//   /// description 模块配置 根据接口动态调整
//   /// date 2022/3/9 2:36 下午
//   /// author LiuChuanan
//   _mainModuleBuilder({required List<HomeItemBeanEntity> list}) {
//     Widget _widget = Container();
//
//     /// 下载状态
//     if (list.length == 1) {
//       HomeItemBeanEntity oneModuleFirst = list.first;
//       Log.i("下载状态：${oneModuleFirst.downloadStatus}");
//       bool shouldShow = false;
//       if (oneModuleFirst.downloadStatus == 1 ||
//           oneModuleFirst.downloadStatus == 2 ||
//           oneModuleFirst.downloadStatus == 6) {
//         shouldShow = true;
//       }
//       _widget = ClipRRect(
//         borderRadius: BorderRadius.circular(8.0.r),
//         child: InkWell(
//           child: SizedBox(
//             height: 210,
//             child: Stack(
//               fit: StackFit.loose,
//               children: [
//                 Container(
//                   height: 210,
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(8.0),
//                   ),
//                   child: ExtendedImage.network(
//                     oneModuleFirst.iconUrl,
//                     width: MediaQuery.of(context).size.width,
//                     fit: BoxFit.fill,
//                     cache: true,
//                   ),
//                 ),
//                 shouldShow
//                     ? Container(
//                   constraints: BoxConstraints.expand(),
//                   height: 210,
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(8.0),
//                     image: const DecorationImage(
//                       image: AssetImage(
//                         Img.downloadBackground,
//                       ),
//                       fit: BoxFit.fill,
//                     ),
//                   ),
//                   child: DownloadProgress(
//                     progress: oneModuleFirst.progress / 100.0,
//                     fillColor: Colors.grey,
//                     borderWidth: 1,
//                     radius: 50.0,
//                   ),
//                 )
//                     : Container(),
//               ],
//             ),
//           ),
//           onTap: !shouldShow
//               ? () {
//             Log.i("模块1点击回调");
//             // oneModuleFirst.downloadStatus = 2;
//             // Provider.of<HomeModel>(context, listen: false)
//             //     .updateMainModuleDataSource(oneModuleFirst, 0);
//             // ToastUtils.toastShort("跳转事件处理中");
//             CommonEventManager.handleEvent(
//                 itemBeanEntity: oneModuleFirst);
//           }
//               : null,
//         ),
//       );
//     } else if (list.length == 2) {
//       HomeItemBeanEntity twoModuleFirstBean = list.first;
//       HomeItemBeanEntity twoModuleSecondBean = list.last;
//       bool twoModuleFirstShouldShow = false;
//       if (twoModuleFirstBean.downloadStatus == 1 ||
//           twoModuleFirstBean.downloadStatus == 2 ||
//           twoModuleFirstBean.downloadStatus == 6) {
//         twoModuleFirstShouldShow = true;
//       }
//
//       bool twoModuleSecondShouldShow = false;
//       if (twoModuleSecondBean.downloadStatus == 1 ||
//           twoModuleSecondBean.downloadStatus == 2 ||
//           twoModuleSecondBean.downloadStatus == 6) {
//         twoModuleSecondShouldShow = true;
//       }
//       _widget = Container(
//         height: 210,
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(8.0.r),
//         ),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.start,
//           children: [
//             Expanded(
//               flex: 1,
//               child: ClipRRect(
//                 borderRadius: BorderRadius.circular(8.0.r),
//                 child: InkWell(
//                   child: Stack(
//                     children: [
//                       Container(
//                         decoration: BoxDecoration(
//                           color: Colors.transparent,
//                           borderRadius: BorderRadius.circular(8.0),
//                         ),
//                         child: ExtendedImage.network(
//                           twoModuleFirstBean.iconUrl,
//                           width: MediaQuery.of(context).size.width,
//                           fit: BoxFit.fill,
//                           cache: true,
//                         ),
//                       ),
//                       twoModuleFirstShouldShow
//                           ? Container(
//                         constraints: BoxConstraints.expand(),
//                         height: 210,
//                         decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(8.0),
//                           image: const DecorationImage(
//                             image: AssetImage(
//                               Img.downloadBackground,
//                             ),
//                             fit: BoxFit.fill,
//                           ),
//                         ),
//                         child: DownloadProgress(
//                           progress: twoModuleFirstBean.progress / 100.0,
//                           fillColor: Colors.grey,
//                           borderWidth: 1,
//                           radius: 50.0,
//                         ),
//                       )
//                           : Container(),
//                     ],
//                   ),
//                   onTap: !twoModuleFirstShouldShow
//                       ? () {
//                     // twoModuleFirstBean.downloadStatus = 2;
//                     // Provider.of<HomeModel>(context, listen: false)
//                     //     .updateMainModuleDataSource(twoModuleFirstBean, 0);
//                     CommonEventManager.handleEvent(
//                         itemBeanEntity: twoModuleFirstBean);
//                   }
//                       : null,
//                 ),
//               ),
//             ),
//             Padding(padding: EdgeInsets.only(left: 12)),
//             Expanded(
//               flex: 1,
//               child: ClipRRect(
//                 borderRadius: BorderRadius.circular(8.0.r),
//                 child: InkWell(
//                   child: Stack(
//                     children: [
//                       Container(
//                         decoration: BoxDecoration(
//                           color: Colors.transparent,
//                           borderRadius: BorderRadius.circular(8.0),
//                         ),
//                         child: ExtendedImage.network(
//                           twoModuleSecondBean.iconUrl,
//                           width: MediaQuery.of(context).size.width,
//                           fit: BoxFit.fill,
//                           cache: true,
//                         ),
//                       ),
//                       twoModuleSecondShouldShow
//                           ? Container(
//                         constraints: BoxConstraints.expand(),
//                         height: 210,
//                         decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(8.0),
//                           image: const DecorationImage(
//                             image: AssetImage(
//                               Img.downloadBackground,
//                             ),
//                             fit: BoxFit.fill,
//                           ),
//                         ),
//                         child: DownloadProgress(
//                           progress: twoModuleSecondBean.progress / 100.0,
//                           fillColor: Colors.grey,
//                           borderWidth: 1,
//                           radius: 50.0,
//                         ),
//                       )
//                           : Container(),
//                     ],
//                   ),
//                   onTap: !twoModuleSecondShouldShow
//                       ? () {
//                     // twoModuleSecondBean.downloadStatus = 2;
//                     // Provider.of<HomeModel>(context, listen: false)
//                     //     .updateMainModuleDataSource(twoModuleSecondBean, 1);
//                     CommonEventManager.handleEvent(
//                         itemBeanEntity: twoModuleSecondBean);
//                   }
//                       : null,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       );
//     } else {
//       HomeItemBeanEntity threeModuleFirstBean = list.first;
//       HomeItemBeanEntity threeModuleSecondBean = list[1];
//       HomeItemBeanEntity threeModuleThirdBean = list[2];
//
//       bool threeModuleFirstShouldShow = false;
//       if (threeModuleFirstBean.downloadStatus == 1 ||
//           threeModuleFirstBean.downloadStatus == 2 ||
//           threeModuleFirstBean.downloadStatus == 6) {
//         threeModuleFirstShouldShow = true;
//       }
//
//       bool threeModuleSecondShouldShow = false;
//       if (threeModuleSecondBean.downloadStatus == 1 ||
//           threeModuleSecondBean.downloadStatus == 2 ||
//           threeModuleSecondBean.downloadStatus == 6) {
//         threeModuleSecondShouldShow = true;
//       }
//
//       bool threeModuleThirdShouldShow = false;
//       if (threeModuleThirdBean.downloadStatus == 1 ||
//           threeModuleThirdBean.downloadStatus == 2 ||
//           threeModuleThirdBean.downloadStatus == 6) {
//         threeModuleThirdShouldShow = true;
//       }
//
//       _widget = Container(
//         height: 210,
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(8.0),
//         ),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Expanded(
//               flex: 1,
//               child: ClipRRect(
//                 borderRadius: BorderRadius.circular(8.0.r),
//                 child: InkWell(
//                   child: Stack(
//                     children: [
//                       Container(
//                         decoration: BoxDecoration(
//                           color: Colors.transparent,
//                           borderRadius: BorderRadius.circular(8.0),
//                         ),
//                         child: ExtendedImage.network(
//                           threeModuleFirstBean.iconUrl,
//                           width: MediaQuery.of(context).size.width,
//                           fit: BoxFit.fill,
//                           cache: true,
//                         ),
//                       ),
//                       threeModuleFirstShouldShow
//                           ? Container(
//                         constraints: BoxConstraints.expand(),
//                         height: 210,
//                         decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(8.0),
//                           image: const DecorationImage(
//                             image: AssetImage(
//                               Img.downloadBackground,
//                             ),
//                             fit: BoxFit.fill,
//                           ),
//                         ),
//                         child: DownloadProgress(
//                           progress: threeModuleFirstBean.progress / 100.0,
//                           fillColor: Colors.grey,
//                           borderWidth: 2,
//                           radius: 50.0,
//                         ),
//                       )
//                           : Container(),
//                     ],
//                   ),
//                   onTap: !threeModuleFirstShouldShow
//                       ? () {
//                     /// 下面是调试数据
//                     // threeModuleFirstBean.downloadStatus = 2;
//                     // Provider.of<HomeModel>(context, listen: false)
//                     //     .updateMainModuleDatasSource(threeModuleFirstBean, 0);
//                     UnityManager.openUnity(gameId: "truco");
//                   }
//                       : null,
//                 ),
//               ),
//             ),
//             Padding(padding: EdgeInsets.only(left: 12)),
//             Expanded(
//               flex: 1,
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Expanded(
//                     flex: 1,
//                     child: ClipRRect(
//                       borderRadius: BorderRadius.circular(8.0.r),
//                       child: InkWell(
//                         child: Stack(
//                           children: [
//                             Container(
//                               decoration: BoxDecoration(
//                                 color: Colors.transparent,
//                                 borderRadius: BorderRadius.circular(8.0),
//                               ),
//                               child: ExtendedImage.network(
//                                 threeModuleSecondBean.iconUrl,
//                                 width: MediaQuery.of(context).size.width,
//                                 fit: BoxFit.fill,
//                                 cache: true,
//                               ),
//                             ),
//                             threeModuleSecondShouldShow
//                                 ? Container(
//                               constraints: BoxConstraints.expand(),
//                               height: 210,
//                               decoration: BoxDecoration(
//                                 borderRadius: BorderRadius.circular(8.0),
//                                 image: const DecorationImage(
//                                   image: AssetImage(
//                                     Img.downloadBackground,
//                                   ),
//                                   fit: BoxFit.fill,
//                                 ),
//                               ),
//                               child: DownloadProgress(
//                                 progress: threeModuleSecondBean.progress /
//                                     100.0,
//                                 fillColor: Colors.grey,
//                                 borderWidth: 2,
//                                 radius: 50.0,
//                               ),
//                             )
//                                 : Container(),
//                           ],
//                         ),
//                         onTap: !threeModuleSecondShouldShow
//                             ? () {
//                           /// 下面是调试数据
//                           // threeModuleSecondBean.downloadStatus = 2;
//                           // Provider.of<HomeModel>(context, listen: false)
//                           //     .updateMainModuleDataSource(threeModuleSecondBean, 1);
//                           CommonEventManager.handleEvent(
//                               itemBeanEntity: threeModuleSecondBean);
//                         }
//                             : null,
//                       ),
//                     ),
//                   ),
//                   Padding(padding: EdgeInsets.only(top: 6)),
//                   Expanded(
//                     flex: 1,
//                     child: ClipRRect(
//                       borderRadius: BorderRadius.circular(8.0.r),
//                       child: InkWell(
//                         child: Stack(
//                           children: [
//                             Container(
//                               decoration: BoxDecoration(
//                                 color: Colors.transparent,
//                                 borderRadius: BorderRadius.circular(8.0),
//                               ),
//                               child: ExtendedImage.network(
//                                 threeModuleThirdBean.iconUrl,
//                                 width: MediaQuery.of(context).size.width,
//                                 fit: BoxFit.fill,
//                                 cache: true,
//                               ),
//                             ),
//                             threeModuleThirdShouldShow
//                                 ? Container(
//                               constraints: BoxConstraints.expand(),
//                               height: 210,
//                               decoration: BoxDecoration(
//                                 borderRadius: BorderRadius.circular(8.0),
//                                 image: const DecorationImage(
//                                   image: AssetImage(
//                                     Img.downloadBackground,
//                                   ),
//                                   fit: BoxFit.fill,
//                                 ),
//                               ),
//                               child: DownloadProgress(
//                                 progress:
//                                 threeModuleThirdBean.progress / 100.0,
//                                 fillColor: Colors.grey,
//                                 borderWidth: 3,
//                                 radius: 50.0,
//                               ),
//                             )
//                                 : Container(),
//                           ],
//                         ),
//                         onTap: !threeModuleThirdShouldShow
//                             ? () {
//                           // threeModuleThirdBean.downloadStatus = 2;
//                           // Provider.of<HomeModel>(context, listen: false)
//                           //     .updateMainModuleDataSource(threeModuleThirdBean, 2);
//                           CommonEventManager.handleEvent(
//                               itemBeanEntity: threeModuleThirdBean);
//                         }
//                             : null,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       );
//     }
//     return Padding(
//       padding: EdgeInsets.only(
//         top: 23,
//       ),
//       child: Container(
//         key: _globalKey,
//         child: _widget,
//       ),
//     );
//   }
//
//   /// methodName _gamesPage
//   /// description 游戏入口页面
//   /// date 2022/3/9 3:25 下午
//   /// author LiuChuanan
//   _subModulePage({required List<HomeItemBeanEntity> gameList}) {
//     return Padding(
//       padding: EdgeInsets.only(
//         top: 12,
//       ),
//       child: GridView.builder(
//         physics: NeverScrollableScrollPhysics(),
//         shrinkWrap: true,
//         gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//           crossAxisCount: 4,
//           mainAxisSpacing: 10,
//           childAspectRatio: 0.8,
//         ),
//         itemBuilder: (context, index) {
//           HomeItemBeanEntity gameBeanEntity = gameList[index];
//           bool shouldShow = false;
//           if (gameBeanEntity.downloadStatus == 1 ||
//               gameBeanEntity.downloadStatus == 2 ||
//               gameBeanEntity.downloadStatus == 6) {
//             shouldShow = true;
//           }
//           return InkWell(
//             child: _itemWidget(index, gameBeanEntity),
//             onTap: !shouldShow
//                 ? () async {
//               if (gameBeanEntity.shouldShow == 1 && gameBeanEntity.tip.ty == 2) {
//                 int count = Provider.of<HomeModel>(context, listen: false).homeTabItemCount;
//                 count--;
//                 Provider.of<HomeModel>(context, listen: false).homeTabItemCount = count;
//                 Provider.of<NavigatorViewModel>(context,listen: false).setHomeTabCount(count);
//               }
//
//               bool contain = false;
//               if (gameBeanEntity.shouldShow == 1) {
//                 gameBeanEntity.shouldShow = 0;
//                 gameBeanEntity.timeInterval =
//                     DateTime.now().millisecondsSinceEpoch;
//                 String gameKey = "${UserInfoRepo.userId}gameList";
//                 var data = await SpUtils().getStorage(gameKey);
//                 List list = [];
//                 for (int i = 0; i < data.length; i++) {
//                   HomeItemBeanEntity beanEntity =
//                   HomeItemBeanEntity.fromJson(data[i]);
//                   if (beanEntity.id == gameBeanEntity.id) {
//                     contain = true;
//                     beanEntity.shouldShow = gameBeanEntity.shouldShow = 0;
//                     beanEntity.timeInterval = gameBeanEntity.timeInterval;
//                   }
//                   list.add(beanEntity);
//                 }
//
//                 if (contain == false) {
//                   list.add(gameBeanEntity);
//                 }
//
//                 await SpUtils().setStorage(gameKey, list);
//               }
//
//               Log.i("点击了当前游戏索引：$index");
//               gameBeanEntity.downloadStatus = 2;
//               Provider.of<HomeModel>(context, listen: false)
//                   .updateSubModuleDataSource(gameBeanEntity, index);
//               CommonEventManager.handleEvent(
//                   itemBeanEntity: gameBeanEntity);
//             }
//                 : null,
//           );
//         },
//         itemCount: gameList.length,
//       ),
//     );
//   }
//
//   /// methodName _itemWidget
//   /// description 小红点显示控件
//   /// date 2022/3/22 4:50 下午
//   /// author LiuChuanan
//   _itemWidget(int index, HomeItemBeanEntity gameBeanEntity) {
//     if (gameBeanEntity.shouldShow == 1) {
//       if (gameBeanEntity.tip.ty == 0) {
//         /// 纯红点类型
//         return Badge(
//           position: BadgePosition.topEnd(top: 10, end: 10),
//           badgeContent: null,
//           child: _contentItem(index, gameBeanEntity),
//         );
//       } else if (gameBeanEntity.tip.ty == 1) {
//         /// 文本类型
//         return Badge(
//           shape: BadgeShape.square,
//           borderRadius: BorderRadius.circular(5),
//           position: BadgePosition.topEnd(top: 5, end: 10),
//           padding: EdgeInsets.all(2),
//           badgeContent: Text(
//             gameBeanEntity.tip.content,
//             style: TextStyle(
//               color: Colors.white,
//               fontSize: 10,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           child: _contentItem(index, gameBeanEntity),
//         );
//       } else {
//         /// 数字类型
//         return Badge(
//           position: BadgePosition.topEnd(top: 0, end: 10),
//           elevation: 0,
//           shape: BadgeShape.circle,
//           padding: EdgeInsets.all(7),
//           badgeContent: Text(
//             gameBeanEntity.tip.content,
//             style: TextStyle(color: Colors.white),
//           ),
//           child: _contentItem(index, gameBeanEntity),
//         );
//       }
//     } else {
//       return Badge(
//         showBadge: false,
//         badgeContent: null,
//         child: _contentItem(index, gameBeanEntity),
//       );
//     }
//   }
//
//   _contentItem(int index, HomeItemBeanEntity gameBeanEntity) {
//     bool shouldShow = false;
//     if (gameBeanEntity.downloadStatus == 1 ||
//         gameBeanEntity.downloadStatus == 2 ||
//         gameBeanEntity.downloadStatus == 6) {
//       shouldShow = true;
//     }
//     return Column(
//       mainAxisAlignment: MainAxisAlignment.start,
//       children: [
//         Padding(padding: EdgeInsets.only(top: 15)),
//         SizedBox(
//           height: 62,
//           width: 62,
//           child: Stack(
//             children: [
//               ClipRRect(
//                 borderRadius: BorderRadius.circular(8.0),
//                 child: ExtendedImage.network(
//                   gameBeanEntity.iconUrl,
//                   height: 62,
//                   fit: BoxFit.fitWidth,
//                   cache: true,
//                 ),
//               ),
//               shouldShow
//                   ? Container(
//                 constraints: BoxConstraints.expand(),
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(8.0),
//                   image: const DecorationImage(
//                     image: AssetImage(
//                       Img.downloadBackground,
//                     ),
//                     fit: BoxFit.fill,
//                   ),
//                 ),
//                 child: DownloadProgress(
//                   progress: gameBeanEntity.progress / 100.0,
//                   fillColor: Colors.grey,
//                   borderWidth: 1.0,
//                   radius: 24.0,
//                 ),
//               )
//                   : Container(),
//             ],
//           ),
//         ),
//         Padding(padding: EdgeInsets.only(top: 4)),
//         Text(
//           gameBeanEntity.name,
//           textAlign: TextAlign.center,
//           maxLines: 2,
//           style: TextStyle(
//             fontSize: 11,
//             fontWeight: FontWeight.w500,
//             color: AppColors.colorFF333333,
//             height: 1.0,
//           ),
//         ),
//       ],
//     );
//   }
// }
//
// /// @fileName FloatBox.dart
// /// @description 浮动组件
// /// @date 2022/3/23 2:22 下午
// /// @author LiuChuanan
// class FloatBox extends StatefulWidget {
//   final double screenWidth;
//   final double safeContentHeight;
//   final String iconUrl;
//   final Function()? onTap;
//   const FloatBox({
//     Key? key,
//     required this.screenWidth,
//     required this.safeContentHeight,
//     required this.iconUrl,
//     this.onTap,
//   }) : super(key: key);
//   @override
//   _FloatBoxState createState() => _FloatBoxState();
// }
//
// class _FloatBoxState extends State<FloatBox> {
//   late Offset offset;
//   Offset _calOffset(Size size, Offset offset, Offset nextOffset) {
//     double dx = 0;
//     dx = widget.screenWidth - 62 - 10;
//     double dy = 0;
//     if (offset.dy + nextOffset.dy <
//         MediaQueryData.fromWindow(window).padding.top + kToolbarHeight) {
//       dy = MediaQueryData.fromWindow(window).padding.top + kToolbarHeight;
//     } else if (offset.dy + nextOffset.dy >
//         MediaQueryData.fromWindow(window).size.height -
//             kBottomNavigationBarHeight -
//             MediaQueryData.fromWindow(window).padding.bottom -
//             62) {
//       dy = MediaQueryData.fromWindow(window).size.height -
//           kBottomNavigationBarHeight -
//           MediaQueryData.fromWindow(window).padding.bottom -
//           62;
//     } else {
//       dy = offset.dy + nextOffset.dy;
//     }
//     return Offset(
//       dx,
//       dy,
//     );
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     offset = Offset(widget.screenWidth - 62 - 10, 400.h);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Positioned(
//       left: offset.dx,
//       top: offset.dy,
//       child: GestureDetector(
//         onPanUpdate: (detail) {
//           setState(() {
//             offset =
//                 _calOffset(MediaQuery.of(context).size, offset, detail.delta);
//           });
//         },
//         onTap: widget.onTap,
//         onPanEnd: (detail) {},
//         child: SizedBox(
//           height: 62,
//           width: 62,
//           child: ExtendedImage.network(
//             widget.iconUrl,
//             height: 62,
//             fit: BoxFit.fitWidth,
//             cache: true,
//             borderRadius: BorderRadius.circular(8.0.r),
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// /// @fileName XLIndicator
// /// @description 自定义指示器
// /// @date 2022/3/9 4:28 下午
// /// @author LiuChuanan
// @immutable
// class XLIndicator extends StatelessWidget {
//   final int _currentIndex;
//   final int _count;
//
//   const XLIndicator(this._currentIndex, this._count, {Key? key})
//       : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: 150,
//       margin: EdgeInsets.only(right: 34),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.end,
//         children: List.generate(_count, (index) {
//           return _currentIndex == index
//               ? Container(
//             width: 24,
//             height: 8,
//             margin: EdgeInsets.only(right: 8),
//             decoration: BoxDecoration(
//                 color: Colors.greenAccent,
//                 borderRadius: BorderRadius.circular(4)),
//           )
//               : Container(
//             width: 8,
//             height: 8,
//             margin: EdgeInsets.only(right: 8),
//             decoration: BoxDecoration(
//                 color: Colors.grey.withOpacity(0.5),
//                 borderRadius: BorderRadius.circular(20)),
//           );
//         }),
//       ),
//     );
//   }
// }
//
// enum ChildShape {
//   CIRCLE, //圆形
//   RECTANGLE, //矩形
//   OVAL, //椭圆
//   ROUND_RECTANGLE //圆角矩形
// }
//
// class GuideChild {
//   //突出显示的widget的大小
//   late Size childSize;
//
//   //突出显示widget的位置（偏移量）
//   late Offset offset;
//
//   //突出显示widget的形状
//   ChildShape childShape = ChildShape.RECTANGLE;
//
//   //用于解释说明突出显示widget的组件
//   late Widget descWidget;
//
//   //用于解释说明突出显示widget的组件位置
//   late Offset descOffset;
//
//   //点击组件的回调
//   late GestureTapCallback callback;
//
//   //仅点击组件可关闭
//   bool closeByClickChild = false;
//
//   double padding = 5;
// }
//
// class GuideLayout extends StatefulWidget {
//   final List<GuideChild> children;
//   final GestureTapCallback onCompete;
//
//   const GuideLayout(this.children, {Key? key, required this.onCompete}): super(key: key);
//
//   @override
//   State<StatefulWidget> createState() {
//     return GuideLayoutState();
//   }
//
//   static void showGuide(BuildContext context, List<GuideChild> children,
//       GestureTapCallback onComplete) {
//     Navigator.of(context).push(PageRouteBuilder(
//         pageBuilder: (context, animation, secAnim) {
//           return FadeTransition(
//             ///渐变过渡 0.0-1.0
//             opacity: Tween(begin: 0.5, end: 1.0).animate(
//               CurvedAnimation(
//                 ///动画样式
//                 parent: animation,
//                 ///动画曲线
//                 curve: Curves.fastOutSlowIn,
//               ),
//             ),
//             child: GuideLayout(
//               children,
//               onCompete: onComplete,
//             ),
//           );
//         },
//         opaque: false));
//   }
// }
//
// class GuideLayoutState extends State<GuideLayout> {
//   @override
//   Widget build(BuildContext context) {
//     Size screenSize = MediaQuery.of(context).size;
//     return Material(
//       color: Color(0x00ffffff),
//       type: MaterialType.transparency,
//       child: GestureDetector(
//         onTapUp: tapUp,
//         child: CustomPaint(
//           size: screenSize,
//           painter: BgPainter(
//               offset: widget.children.first.offset,
//               childSize: widget.children.first.childSize,
//               shape: widget.children.first.childShape,
//               padding: widget.children.first.padding),
//           child: Stack(
//             children: [
//               Positioned(
//                 child: widget.children.first.descWidget,
//                 left: widget.children.first.descOffset.dx + 63,
//                 top: widget.children.first.descOffset.dy,
//               ),
//               Positioned(
//                 child: Container(
//                   height: widget.children.first.childSize.height + 40,
//                   width: MediaQuery.of(context).size.width - 6,
//                   decoration: BoxDecoration(
//                     image: DecorationImage(
//                       fit: BoxFit.fill,
//                       image: AssetImage(
//                         Img.newComerBgBorder,
//                       ),
//                     ),
//                   ),
//                 ),
//                 left: 3,
//                 top: widget.children.first.offset.dy - 15,
//               ),
//
//               Positioned(
//                 child: Container(
//                   width: 38,
//                   height: 53,
//                   decoration: BoxDecoration(
//                     image: DecorationImage(
//                       fit: BoxFit.fill,
//                       image: AssetImage(
//                         Img.newComerIconFinger,
//                       ),
//                     ),
//                   ),
//                 ),
//                 left: MediaQuery.of(context).size.width / 2.0 + 10.0,
//                 top: widget.children.first.descOffset.dy - 30,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   void tapChild() {
//     widget.children.first.callback.call();
//
//     setState(() {
//       if (widget.children.length == 1) {
//         widget.onCompete.call();
//         Navigator.of(context).pop();
//       } else if (widget.children.length > 1) {
//         widget.children.removeAt(0);
//       }
//     });
//   }
//
//   void tapUp(TapUpDetails details) {
//     if (widget.children.first.closeByClickChild) {
//       Path path = Path();
//       path.addRect(Rect.fromLTWH(
//           widget.children.first.offset.dx,
//           widget.children.first.offset.dy,
//           widget.children.first.childSize.width,
//           widget.children.first.childSize.height));
//       if (!path.contains(details.globalPosition)) {
//         return;
//       }
//     }
//
//     widget.children.first.callback.call();
//     widget.children.removeAt(0);
//     if (widget.children.isEmpty) {
//       widget.onCompete.call();
//       Navigator.of(context).pop();
//     } else {
//       setState(() {});
//     }
//   }
// }
//
// class BgPainter extends CustomPainter {
//   late Offset offset;
//   late Size childSize;
//
//   late Path path1;
//   late Path path2;
//   late Path path3;
//   late Paint _paint;
//
//   late ChildShape shape;
//   late double padding;
//
//   BgPainter({required this.offset, required this.childSize, required this.shape, required this.padding}) {
//     path1 = Path();
//     path2 = Path();
//     path3 = Path();
//     _paint = Paint()
//       ..color = Color(0x90000000)
//       ..style = PaintingStyle.fill
//       ..isAntiAlias = true;
//   }
//
//   @override
//   void paint(Canvas canvas, Size size) {
//     path1.reset();
//     path2.reset();
//
//     path1.addRect(Rect.fromLTWH(0, 0, size.width, size.height));
//
//     switch (shape) {
//       case ChildShape.RECTANGLE:
//         path2.addRect(Rect.fromLTWH(offset.dx - padding, offset.dy - padding,
//             childSize.width + padding * 2, childSize.height + padding * 2));
//         break;
//       case ChildShape.CIRCLE:
//         double length;
//         double left;
//         double top;
//         double radius = sqrt(childSize.width * childSize.width +
//             childSize.height * childSize.height);
//         length = radius + padding * 2;
//         left = offset.dx - (radius - childSize.width) / 2 - padding;
//         top = offset.dy - (radius - childSize.height) / 2 - padding;
//         path2.addOval(Rect.fromLTWH(left, top, length, length));
//
//         break;
//       case ChildShape.OVAL:
//         double length;
//         double left;
//         double top;
//         double radius = sqrt(childSize.width * childSize.width +
//             childSize.height * childSize.height);
//         length = radius + padding * 2;
//         left =
//             offset.dx - (radius + padding * 4 - childSize.width) / 2 - padding;
//         top = offset.dy - (radius - childSize.height) / 2 - padding;
//         path2.addOval(Rect.fromLTWH(
//             left, top, length + padding * 6, length + padding * 2));
//         break;
//       case ChildShape.ROUND_RECTANGLE:
//         path2.addRRect(RRect.fromRectXY(
//             Rect.fromLTWH(offset.dx - padding, offset.dy - padding, childSize.width + padding * 2, childSize.height + padding * 2), padding * 2, padding * 2));
//         break;
//     }
//
//     Path result = Path.combine(PathOperation.difference, path1, path2);
//
//     canvas.drawPath(result, _paint);
//   }
//
//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) {
//     return false;
//   }
// }
//
//
