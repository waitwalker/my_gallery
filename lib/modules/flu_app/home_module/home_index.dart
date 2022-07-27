// import 'dart:async';
// import 'dart:convert';
// import 'dart:io';
// import 'package:loading_animation_widget/loading_animation_widget.dart';
// import 'package:badges/badges.dart';
// import 'package:card_swiper/card_swiper.dart';
// import 'package:extended_image/extended_image.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
// import 'package:microcosm/app.dart';
// import 'package:microcosm/base/sdk/google/advertisement/video_ad.dart';
// import 'package:microcosm/common/components/appbar_custom.dart';
// import 'package:microcosm/common/components/dialog/invite_to_add_group.dart';
// import 'package:microcosm/common/components/dialog/invite_to_create_group.dart';
// import 'package:microcosm/common/components/dialog/update_dialog.dart';
// import 'package:microcosm/common/components/download_progress.dart';
// import 'package:microcosm/common/components/error_page.dart';
// import 'package:microcosm/common/components/loading_page.dart';
// import 'package:microcosm/common/event/common_event_manager.dart';
// import 'package:microcosm/common/event/fire_engine.dart';
// import 'package:microcosm/common/values/colors.dart';
// import 'package:microcosm/common/values/enums.dart';
// import 'package:microcosm/config/img.dart';
// import 'package:microcosm/generated/l10n.dart';
// import 'package:microcosm/model/bean/group_dialog_for_invite_entity.dart';
// import 'package:microcosm/model/chat/chat_user_info_model.dart';
// import 'package:microcosm/model/chat/friend_recommend/friend_recommend_service.dart';
// import 'package:microcosm/model/home/bean/home_item_bean_entity.dart';
// import 'package:microcosm/model/home/hall_user_assets_info_model.dart';
// import 'package:microcosm/model/home/home_model.dart';
// import 'package:microcosm/model/home/home_service.dart';
// import 'package:microcosm/model/home/home_source_data_manager.dart';
// import 'package:microcosm/model/login/user_info_repo.dart';
// import 'package:microcosm/model/navigator/navigator_view_model.dart';
// import 'package:microcosm/model/personal/personal_info_model.dart';
// import 'package:microcosm/model/settings/my_provider.dart';
// import 'package:microcosm/model/share/share_model.dart';
// import 'package:microcosm/model/store/store_provider.dart';
// import 'package:microcosm/model/unity/download_manager.dart';
// import 'package:microcosm/model/unity/unity_download_config.dart';
// import 'package:microcosm/navigation/custom_tab_item.dart';
// import 'package:microcosm/pages/home/float_box.dart';
// import 'package:microcosm/pages/home/guide_page.dart';
// import 'package:microcosm/pages/home/hall_user_assets_info_widget.dart';
// import 'package:microcosm/pages/home/home_module_enum.dart';
// import 'package:microcosm/pages/home/xl_indicator.dart';
// import 'package:microcosm/routers/routes.dart';
// import 'package:microcosm/utils/download_util.dart';
// import 'package:microcosm/utils/install_manager.dart';
// import 'package:microcosm/utils/log.dart';
// import 'package:microcosm/utils/platform.dart';
// import 'package:microcosm/utils/share/everyday_share_dialog.dart';
// import 'package:microcosm/utils/shu_mei_util.dart';
// import 'package:microcosm/utils/singleton/singleton_manager.dart';
// import 'package:microcosm/utils/storage.dart';
// import 'package:microcosm/utils/toast_utils.dart';
// import 'package:provider/provider.dart';

// /// @fileName home_index.dart
// /// @description 首页大厅主要模块：Banner，主模块，子模块，悬浮按钮等
// /// 点击事件会通过CommonEventManager做游戏相关预处理，为了处理一些需要热更的游戏
// /// @date 2022/6/25 18:33
// /// @author LiuChuanan
// class HomeIndex extends StatefulWidget with BasePage {
//   const HomeIndex({Key? key}) : super(key: key);

//   @override
//   State<StatefulWidget> createState() => _HomePage();

//   @override
//   String get darkIcon => Img.gameDark;

//   @override
//   String get icon => Img.game;

//   @override
//   String get label => S.current.home;

//   @override
//   int get tabItemIndex => 0;
// }

// class _HomePage extends State<HomeIndex> with SingleTickerProviderStateMixin {
//   /// 弹窗队列
//   late List<HomeItemBeanEntity> popupList = [];

//   /// key
//   final GlobalKey<_HomePage> _globalKey = GlobalKey();

//   /// 新人引导组件list
//   final List<GuidePage> _children = [];

//   /// 是否新人
//   bool isNewComer = false;

//   /// 是否显示弹窗
//   bool shouldPopup = false;

//   /// 是否App强更
//   bool isForce = false;

//   late StreamSubscription? _subscription;

//   /// methodName _fetchHomeData
//   /// description 请求首页数据
//   /// date 2022/6/25 18:20
//   /// author LiuChuanan
//   void _fetchHomeData() async {
//     await Provider.of<NavigatorViewModel>(context, listen: false)
//         .readTabItemBadge();
//     HomeService.fetchHomeData(Provider.of<HomeModel>(context, listen: false));
//   }

//   @override
//   void initState() {
//     super.initState();
//     Provider.of<ShareModel>(context, listen: false).getEverydayShareInfo();

//     ///获取邀请自动建群弹窗信息
//     Provider.of<ChatUserInfoModel>(context, listen: false)
//         .fetchInviteGroupDialogInfo();

//     /// 如果首页允许请求（超过10分钟）&& 登录成功 && 游戏都下载完成了
//     if (SingletonManager.sharedInstance.homeCanLoad &&
//         SingletonManager.sharedInstance.isLogin &&
//         SingletonManager.sharedInstance.finishDownload) {
//       /// 请求首页数据
//       _fetchHomeData();
//     }

//     /// 跨组件监听
//     _addListener();

//     /// 好友推荐入口请求
//     FriendRecommendService.fetchSwitch(shouldNotify: false);
//     if (SingletonManager.sharedInstance.isLogin) {
//       Provider.of<HallUserAssetsInfoModel>(context, listen: false)
//           .getUserAssetsInfo();
//     }
//     Provider.of<HallUserAssetsInfoModel>(context, listen: false)
//         .getClockRewardStates(context, (t) {});

//     ///请求个人主页接口，获得性别，生日等基础信息
//     Provider.of<PersonalInfoModel>(context, listen: false).fetchPersonalInfo();

//     /// 获取商城、我的模块配置
//     if (SingletonManager.sharedInstance.isLogin) {
//       Provider.of<StoreProvider>(context, listen: false)
//           .fetchStoreModuleData(true);
//       Provider.of<StoreProvider>(context, listen: false).fetchStoreInfo(true);
//       Provider.of<MyProvider>(context, listen: false).fetchMineModuleData(true);
//     }

//     ///获取签名配置
//     Provider.of<PersonalInfoModel>(context, listen: false).getSignConfig();

//     ///获取客服配置地址
//     Provider.of<PersonalInfoModel>(context, listen: false)
//         .getCustomServiceConfig();
//     VideoAd().load();

//     /// 首页页面曝光
//     HomeSourceDataManager.enterHomePage();

//     ///获取IM创建游戏配置
//     Provider.of<ChatUserInfoModel>(context, listen: false)
//         .getImCreateGameConfig();
//   }

//   /// 监听处理
//   void _addListener() {
//     _subscription = FireEngine.eventBus?.on().listen((event) async {
//       EventEntity _event = event;

//       /// 弹窗队列
//       if (_event.event == MessageEvent.DialogQueue) {
//         if (mounted) {
//           bool newComer = await _readUserCache();
//           if (Provider.of<HomeModel>(context, listen: false)
//               .popupList
//               .isNotEmpty) {
//             popupList =
//                 Provider.of<HomeModel>(context, listen: false).popupList;
//             shouldPopup = true;
//             if (newComer) {
//               HomeService.fetchNewPersonGiftBag(
//                   Provider.of<HomeModel>(context, listen: false));
//             } else {
//               _commonAction();
//             }
//           } else {
//             shouldPopup = false;
//             if (newComer) {
//               HomeService.fetchNewPersonGiftBag(
//                   Provider.of<HomeModel>(context, listen: false));
//             } else {
//               _sendPushNotifyCheck();
//             }
//           }
//         }
//         if (SingletonManager.sharedInstance.appUpdateType == AppUpdate.None) {
//           Provider.of<HomeModel>(context, listen: false).unitySilentDownload();
//         }
//       } else if (_event.event == MessageEvent.NewPersonSuccess) {
//         /// 获取新人礼包 接口请求数据成功
//         if (SingletonManager.sharedInstance.isLogin) {
//           HomeSourceDataManager.exposureNewPersonModule();
//           CommonEventManager.newComerGiftBagDialog(
//             context: context,
//             assetId: Provider.of<HomeModel>(context, listen: false)
//                 .newPersonGuidanceEntity
//                 .asset
//                 .first
//                 .assetId,
//             content: Provider.of<HomeModel>(context, listen: false)
//                 .newPersonGuidanceEntity
//                 .rewardMsg,
//           );
//         }
//       } else if (_event.event == MessageEvent.NewPersonFailure) {
//         /// 获取新人礼包失败 & 应该弹弹窗
//         if (shouldPopup) {
//           _commonAction();
//         } else {
//           _sendPushNotifyCheck();
//         }
//       } else if (_event.event == MessageEvent.NewPersonGift) {
//         /// 点击确定调用领取新人礼包接口成功
//         HomeSourceDataManager.clickNewPersonModule();
//         HomeService.fetchFeedBackNewPersonGiftBag();
//         await _writeUserCache();
//         _showGuild();
//       } else if (_event.event == MessageEvent.HomeRedDot) {
//         setHomeTabItemBadge();
//       } else if (_event.event == MessageEvent.AppDownload) {
//         dialog?.showProgress(true);
//         String? message = _event.message;
//         if (message != null) {
//           Map map = jsonDecode(message);
//           var status = map["status"];
//           var progress = map["progress"];
//           var downloadPath = map["downloadPath"];
//           var id = map["id"];
//           if (status != null) {
//             /// 下载中
//             if (status == 2) {
//               await SpUtils().setStorage("appTaskId", id);
//               if (isForce) {
//                 dialog!.showProgress(true);
//                 dialog!.update(progress / 100.0);
//               } else {
//                 Log.i("非强制更新当前进度:$progress");
//               }
//             } else if (status == 3) {
//               /// 下载完成
//               if (isForce) {
//                 dialog!.showProgress(false);
//                 dialog!.update(0.0);
//               }
//               if (downloadPath != null) {
//                 List list = downloadPath.split('/');
//                 await SpUtils().setStorage("targetVersionName", list.last);
//               }
//             } else {
//               /// 异常情况
//               if (isForce) {
//                 dialog!.showProgress(false);
//                 dialog!.update(0.0);
//               }
//             }
//           }
//         }
//       } else if (_event.event == MessageEvent.RemoveTopWidget) {
//         if (mounted) {
//           SmartDialog.dismiss(status: SmartStatus.allCustom);
//           SmartDialog.dismiss(status: SmartStatus.allAttach);
//           SmartDialog.dismiss(status: SmartStatus.allDialog);
//           SmartDialog.dismiss(status: SmartStatus.allToast);
//         }
//       }
//     });
//   }

//   /// methodName _sendPushNotifyCheck
//   /// description 发送可以检测通知权限
//   /// date 2022/6/25 18:22
//   /// author LiuChuanan
//   void _sendPushNotifyCheck() {
//     if (SingletonManager.sharedInstance.shouldCheck &&
//         SingletonManager.sharedInstance.isLogin) {
//       SingletonManager.sharedInstance.shouldCheck = false;
//       FireEngine.sendNotify(event: MessageEvent.CheckPush);
//     }
//   }

//   /// methodName readHomeTabItemBadge
//   /// description 读取首页item badge缓存记录
//   /// date 2022/4/22 16:17
//   /// author LiuChuanan
//   Future<void> setHomeTabItemBadge() async {
//     /// 拼接 userid
//     Provider.of<NavigatorViewModel>(context, listen: false).setHomeTabCount(
//         Provider.of<HomeModel>(context, listen: false).homeTabItemCount);
//     SingletonManager.sharedInstance.tabPageState?.indexChanged(0);
//     bool haveValue =
//         Provider.of<HomeModel>(context, listen: false).homeTabItemCount > 0
//             ? true
//             : false;
//     HomeSourceDataManager.clickNavItemModule(index: 0, haveValue: haveValue);
//   }

//   /// methodName showGuild
//   /// description 显示新人引导
//   /// date 2022/4/26 12:02
//   /// author LiuChuanan
//   void _showGuild() {
//     RenderObject? _renderBox = _globalKey.currentContext?.findRenderObject();
//     RenderBox renderBox = _renderBox as RenderBox;

//     if (!renderBox.size.isEmpty) {
//       Offset childOffset = renderBox.localToGlobal(Offset.zero);
//       Offset descOffset =
//           Offset(10, childOffset.dy + renderBox.size.height + 10);
//       _children.add(GuidePage()
//         ..offset = childOffset
//         ..childSize = renderBox.size
//         ..descOffset = descOffset
//         ..descWidget = getDescWidget()
//         ..callback = _removeNewPersonGuideCallback
//         ..closeByClickChild = true
//         ..childShape = ChildShape.ROUND_RECTANGLE);
//       GuideLayout.showGuide(context, _children, completedCallBack,
//         guideButtonList: Provider.of<HomeModel>(context, listen: false).guideButtonList,);
//     }
//   }

//   /// methodName _removeNewPersonGuideCallback
//   /// description 移除新人引导回调添加
//   /// date 2022/4/26 12:01
//   /// author LiuChuanan
//   void _removeNewPersonGuideCallback() {}

//   /// methodName completedCallBack
//   /// description 点击完成后回调
//   /// date 2022/4/26 14:22
//   /// author LiuChuanan
//   void completedCallBack() {
//     Future.delayed(Duration(milliseconds: 500), () {
//       if (shouldPopup) {
//         _commonAction();
//       } else {
//         _sendPushNotifyCheck();
//       }
//     });
//   }

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
//           padding: EdgeInsets.only(
//             left: 40,
//             right: 8,
//             top: 3,
//           ),
//           child: Container(
//             alignment: Alignment.center,
//             child: Text(
//               Provider.of<HomeModel>(context, listen: false)
//                   .newPersonGuidanceEntity
//                   .introMsg,
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

//   /// methodName _readUserCache
//   /// description 读取用户缓存记录
//   /// date 2022/4/22 19:07
//   /// author LiuChuanan
//   Future<bool> _readUserCache() async {
//     int userId = await SpUtils().getStorage("home_user_id") ?? 0;
//     String shuMeiId = await SpUtils().getStorage("home_shumei_id") ?? "";
//     if (userId == UserInfoRepo.userId &&
//         shuMeiId == ShuMeiUtil.shuMeiDeviceId) {
//       isNewComer = false;
//     } else {
//       isNewComer = true;
//     }
//     return !(userId == UserInfoRepo.userId &&
//         shuMeiId == ShuMeiUtil.shuMeiDeviceId);
//   }

//   /// methodName _writeUserCache
//   /// description 缓存用户信息
//   /// date 2022/4/22 19:11
//   /// author LiuChuanan
//   Future<void> _writeUserCache() async {
//     await SpUtils().setStorage("home_user_id", UserInfoRepo.userId);
//     await SpUtils().setStorage("home_shumei_id", ShuMeiUtil.shuMeiDeviceId);
//   }

//   @override
//   void dispose() {
//     super.dispose();

//     /// 首页页面消失
//     HomeSourceDataManager.exitHomePage();
//     if (_subscription != null) {
//       _subscription!.cancel();
//       _subscription = null;
//     }
//   }

//   /// methodName _removePopupData
//   /// description 移除弹窗队列的第一条数据
//   /// date 2022/4/6 17:27
//   /// author LiuChuanan
//   Future<void> _removePopupData() async {
//     if (popupList.isNotEmpty) {
//       HomeItemBeanEntity oldBeanEntity = popupList.first;
//       bool contain = false;
//       if (oldBeanEntity.shouldShow == ModuleShouldShow.Yes) {
//         oldBeanEntity.shouldShow = ModuleShouldShow.No;
//         oldBeanEntity.timeInterval = DateTime.now().millisecondsSinceEpoch;
//         String popKey = "${UserInfoRepo.userId}popupList";
//         var data = await SpUtils().getStorage(popKey);
//         List list = [];
//         for (int i = 0; i < data.length; i++) {
//           HomeItemBeanEntity beanEntity = HomeItemBeanEntity.fromJson(data[i]);
//           if (beanEntity.pop.key == oldBeanEntity.pop.key) {
//             contain = true;

//             /// 只显示一次的 不让再次显示
//             if (beanEntity.pop.frq == ModuleShowFrequency.OnlyOnce) {
//               beanEntity.shouldShow = ModuleShouldShow.No;
//             } else if (beanEntity.pop.frq == ModuleShowFrequency.EverydayOnce) {
//               beanEntity.shouldShow = ModuleShouldShow.No;

//               /// 把当前点击的时间保存
//               beanEntity.timeInterval = DateTime.now().millisecondsSinceEpoch;
//             } else if (beanEntity.pop.frq == ModuleShowFrequency.AlwaysShow) {
//               beanEntity.shouldShow = ModuleShouldShow.Yes;
//             }
//           }
//           list.add(beanEntity);
//         }

//         if (contain == false) {
//           list.add(oldBeanEntity);
//         }
//         await SpUtils().setStorage(popKey, list);
//       }
//       popupList.removeAt(0);
//     } else {
//       _sendPushNotifyCheck();
//     }
//   }

//   /// methodName _commonAction
//   /// description 弹窗基本两种类型图片弹窗和更新弹窗
//   /// date 2022/4/6 10:51
//   /// author LiuChuanan
//   void _commonAction() async {
//     if (popupList.isNotEmpty && SingletonManager.sharedInstance.isLogin) {
//       HomeItemBeanEntity itemBeanEntity = popupList.first;

//       /// 图片弹窗
//       if (itemBeanEntity.pop.pop == PopupType.ImagePop) {
//         HomeSourceDataManager.exposureImageModule(elementId: itemBeanEntity.id);
//         CommonEventManager.imageDialog(
//           context: context,
//           imagePath: itemBeanEntity.iconUrl,
//           closeAction: () async {
//             Routes.popWithGlobalContext(context);
//             Future.delayed(Duration(microseconds: 50), () async {
//               await _removePopupData();
//               if (popupList.isNotEmpty) {
//                 _commonAction();
//               } else {
//                 _sendPushNotifyCheck();
//               }
//             });
//           },
//           onTap: () {
//             HomeSourceDataManager.clickImageModule(
//                 elementId: itemBeanEntity.id);
//             Routes.popWithGlobalContext(context);
//             Future.delayed(Duration(microseconds: 50), () async {
//               await _removePopupData();
//               if (popupList.isNotEmpty) {
//                 _commonAction();
//               } else {
//                 _sendPushNotifyCheck();
//               }
//               CommonEventManager.handleEvent(itemBeanEntity: itemBeanEntity);
//             });
//           },
//         );
//       } else if (itemBeanEntity.pop.pop == PopupType.EventPop &&
//           itemBeanEntity.pop.key == EventPopupType.Update) {
//         if (Provider.of<HomeModel>(context, listen: false)
//                 .updateBeanEntity
//                 .needUpdate ==
//             false) {
//           await _removePopupData();
//           if (popupList.isNotEmpty) {
//             _commonAction();
//           } else {
//             _sendPushNotifyCheck();
//           }
//           return;
//         }
//         if (Provider.of<HomeModel>(context, listen: false)
//             .updateBeanEntity
//             .force) {
//           /// 强制版本更新
//           List<Map<String, dynamic>> para = [
//             {"element_name": S.of(context).update_now, "element_type": 1},
//           ];
//           HomeSourceDataManager.exposureAppUpdateModule(paramArray: para);
//           dialog = UpdateDialog.showUpdate(context,
//               updateContent: Provider.of<HomeModel>(context, listen: false)
//                   .updateBeanEntity
//                   .description, onUpdate: () async {
//             HomeSourceDataManager.clickAppUpdateModule(
//                 elementName: S.of(context).update_now, elementType: 1);
//             _updateCallBack(force: true);
//           });
//         } else {
//           /// 非强制更新
//           List<Map<String, dynamic>> para = [
//             {"element_name": S.of(context).update_now, "element_type": 0},
//             {"element_name": S.of(context).update_later, "element_type": 0},
//           ];
//           HomeSourceDataManager.exposureAppUpdateModule(paramArray: para);
//           CommonEventManager.optionalUpdateDialog(
//             context: context,
//             content: Provider.of<HomeModel>(context, listen: false)
//                 .updateBeanEntity
//                 .description,
//             noUpdateOnTap: () {
//               /// 执行非强制更新逻辑 安卓要后台下载
//               HomeSourceDataManager.clickAppUpdateModule(
//                   elementName: S.of(context).update_later, elementType: 0);
//               Routes.popWithGlobalContext(context);
//               Future.delayed(Duration(microseconds: 200), () async {
//                 await _removePopupData();
//                 if (popupList.isNotEmpty) {
//                   _commonAction();
//                 } else {
//                   _sendPushNotifyCheck();
//                 }
//                 CommonEventManager.handleEvent(itemBeanEntity: itemBeanEntity);
//               });
//             },
//             updateOnTap: () async {
//               HomeSourceDataManager.clickAppUpdateModule(
//                   elementName: S.of(context).update_now, elementType: 0);
//               _updateCallBack(force: false);
//               Routes.popWithGlobalContext(context);
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
//       } else if (itemBeanEntity.pop.pop == PopupType.EventPop &&
//           itemBeanEntity.pop.key == EventPopupType.ShareEvery) {
//         EverydayShareDialog.show(navigatorKey.currentContext!, callBack: () {
//           Future.delayed(Duration(microseconds: 50), () async {
//             await _removePopupData();
//             if (popupList.isNotEmpty) {
//               _commonAction();
//             } else {
//               _sendPushNotifyCheck();
//             }
//           });
//         });
//       } else if (itemBeanEntity.pop.pop == PopupType.EventPop &&
//           itemBeanEntity.pop.key == EventPopupType.InviteGroup) {
//         GroupDialogForInviteEntity inviteDialogInfo =
//             Provider.of<ChatUserInfoModel>(context, listen: false)
//                 .inviteDialogInfo;
//         if (inviteDialogInfo.popupType == 1) {
//           SmartDialog.show(
//               widget: InviteToCreateGroup(inviteDialogInfo),
//               keepSingle: true,
//               onDismiss: () {
//                 Future.delayed(Duration(microseconds: 50), () async {
//                   await _removePopupData();
//                   Provider.of<ChatUserInfoModel>(context, listen: false)
//                       .setInviteDialogInfo();
//                   if (popupList.isNotEmpty) {
//                     _commonAction();
//                   } else {
//                     _sendPushNotifyCheck();
//                   }
//                 });
//               });
//         } else if (inviteDialogInfo.popupType == 2) {
//           SmartDialog.show(
//               widget: InviteToAddGroup(inviteDialogInfo),
//               keepSingle: true,
//               onDismiss: () {
//                 Future.delayed(Duration(microseconds: 50), () async {
//                   Provider.of<ChatUserInfoModel>(context, listen: false)
//                       .setInviteDialogInfo();
//                   await _removePopupData();
//                   if (popupList.isNotEmpty) {
//                     _commonAction();
//                   } else {
//                     _sendPushNotifyCheck();
//                   }
//                 });
//               });
//         } else {
//           await _removePopupData();
//           if (popupList.isNotEmpty) {
//             _commonAction();
//           } else {
//             _sendPushNotifyCheck();
//           }
//         }
//       }
//     }
//   }

//   /// methodName _updateCallBack
//   /// description 更新回调：iOS&Android =》 强制&非强制
//   /// date 2022/6/25 18:10
//   /// author LiuChuanan
//   void _updateCallBack({required bool force}) async {
//     /// 执行强制更新逻辑
//     /// 执行非强制更新逻辑 安卓要后台下载 iOS的要跳转到App Store
//     if (PlatformUtils.isIOS) {
//       /// 跳转到苹果商店
//       CommonEventManager.openExternalUrlAction(
//           url: Provider.of<HomeModel>(context, listen: false)
//               .updateBeanEntity
//               .package);
//     } else if (PlatformUtils.isAndroid) {
//       isForce = force;
//       String path = await DownLoadUtil.getDownloadPath();
//       var cacheApkName = await SpUtils().getStorage("targetVersionName");
//       List list = Provider.of<HomeModel>(context, listen: false)
//           .updateBeanEntity
//           .package
//           .split('/');
//       String apkName = Provider.of<HomeModel>(context, listen: false)
//               .updateBeanEntity
//               .targetVersion +
//           "-" +
//           list.last;

//       if (cacheApkName != null) {
//         if (cacheApkName == apkName) {
//           File file = File(path + '/' + apkName);
//           var exist = file.existsSync();
//           if (exist) {
//             Provider.of<HomeModel>(context, listen: false)
//                 .unitySilentDownload();
//             InstallManager.install(apkPath: path + '/' + apkName);
//           } else {
//             _startDownload(path, apkName);
//           }
//         } else {
//           _startDownload(path, apkName);
//         }
//       } else {
//         _startDownload(path, apkName);
//       }
//     }
//   }

//   /// 开始下载回调
//   void _startDownload(String path, String apkName) {
//     DownLoadUtil.deleteFile(path);
//     if (isForce) {
//       dialog!.showProgress(true);
//       dialog!.update(0.0);
//     } else {
//       /// 非强制更新弹窗，点击立即更新后关闭弹窗时，弹出toast“开始下载新版本”
//       ToastUtils.toastLong(S.of(context).appStartDownload);
//     }
//     DownloadManager().downloadApp(
//       package: Provider.of<HomeModel>(context, listen: false)
//           .updateBeanEntity
//           .package,
//       fileName: apkName,
//     );
//   }

//   UpdateDialog? dialog;
//   double progress = 0.0;

//   @override
//   Widget build(BuildContext context) {
//     return Selector<HomeModel, HomeModel>(
//       builder: (ctx, model, child) {
//         /// 页面加载中状态
//         if (model.pageStatus == CommonPageStatus.Loading) {
//           return Scaffold(
//             backgroundColor: AppColors.colorWhite,
//             appBar: AppBarCustom(
//               toolbarHeight: 0,
//             ),
//             body: InkWell(
//               child: LoadingPage(),
//             ),
//           );
//         }

//         /// 页面加载错误状态
//         if (model.pageStatus == CommonPageStatus.Error) {
//           return Scaffold(
//             backgroundColor: AppColors.colorWhite,
//             appBar: AppBarCustom(
//               toolbarHeight: 0,
//             ),
//             body: Padding(
//               padding: EdgeInsets.only(left: 15.w, right: 15.w),
//               child: ErrorPage(
//                 onTap: () {
//                   Provider.of<HomeModel>(context, listen: false)
//                       .changeHomeStatus(CommonPageStatus.Loading);

//                   /// 请求首页数据
//                   HomeService.fetchHomeData(
//                       Provider.of<HomeModel>(context, listen: false));
//                 },
//               ),
//             ),
//           );
//         }

//         /// 页面正常状态
//         return Stack(
//           children: [
//             Scaffold(
//               appBar: AppBarCustom(
//                 toolbarHeight: 0,
//               ),
//               body: Padding(
//                 padding: EdgeInsets.only(left: 0, right: 0),
//                 child: Column(
//                   children: [
//                     HallUserAssetsInfoWidget(),
//                     Container(
//                       color: AppColors.colorWhite,
//                       height: 10.h,
//                     ),
//                     Expanded(
//                       child: ListView(
//                         children: [
//                           /// banner
//                           Padding(
//                             padding: EdgeInsets.only(left: 15, right: 15),
//                             child: Selector<HomeModel, HomeModel>(
//                               builder: (contextX, model, child) {
//                                 return (model.bannerList.length > 0)
//                                     ? SizedBox(
//                                         height: 68,
//                                         child: Column(
//                                           children: [
//                                             Padding(
//                                                 padding: EdgeInsets.only(
//                                               top: 12,
//                                             )),
//                                             SizedBox(
//                                               height: 56,
//                                               child: Swiper(
//                                                 physics: model
//                                                             .bannerList.length >
//                                                         1
//                                                     ? AlwaysScrollableScrollPhysics()
//                                                     : NeverScrollableScrollPhysics(),
//                                                 itemBuilder: (context, index) {
//                                                   HomeItemBeanEntity banner =
//                                                       model.bannerList[index];
//                                                   String imageUrl =
//                                                       banner.iconUrl;
//                                                   return InkWell(
//                                                     child: Container(
//                                                       decoration: BoxDecoration(
//                                                         color:
//                                                             Colors.transparent,
//                                                         borderRadius:
//                                                             BorderRadius
//                                                                 .circular(8.0),
//                                                       ),
//                                                       constraints:
//                                                           BoxConstraints
//                                                               .expand(),
//                                                       child: ClipRRect(
//                                                         borderRadius:
//                                                             BorderRadius
//                                                                 .circular(8.0),
//                                                         child: ExtendedImage
//                                                             .network(
//                                                           imageUrl,
//                                                           width: MediaQuery.of(
//                                                                   context)
//                                                               .size
//                                                               .width,
//                                                           fit: BoxFit.fill,
//                                                           cache: true,
//                                                         ),
//                                                       ),
//                                                     ),
//                                                     onTap: () {
//                                                       /// banner 点击
//                                                       HomeSourceDataManager
//                                                           .clickSingleModule(
//                                                         eventId:
//                                                             HomeSourceDataManager
//                                                                 .bannerModuleClick,
//                                                         elementId: banner.id,
//                                                       );

//                                                       CommonEventManager
//                                                           .handleEvent(
//                                                               itemBeanEntity:
//                                                                   banner);

//                                                       // CommonEventManager.newComerGiftBagDialog(context: context, content: "content");
//                                                     },
//                                                   );
//                                                 },
//                                                 itemCount:
//                                                     model.bannerList.length,
//                                                 autoplay:
//                                                     model.bannerList.length > 1
//                                                         ? true
//                                                         : false,
//                                                 pagination: SwiperPagination(
//                                                     alignment:
//                                                         Alignment.bottomRight,
//                                                     builder: SwiperCustomPagination(
//                                                         builder: (BuildContext
//                                                                 context,
//                                                             SwiperPluginConfig
//                                                                 config) {
//                                                       return model.bannerList
//                                                                   .length >
//                                                               1
//                                                           ? XLIndicator(
//                                                               config
//                                                                   .activeIndex,
//                                                               model.bannerList
//                                                                   .length)
//                                                           : Container();
//                                                     })),
//                                                 indicatorLayout:
//                                                     PageIndicatorLayout.SCALE,
//                                               ),
//                                             )
//                                           ],
//                                         ),
//                                       )
//                                     : Container();
//                               },
//                               selector: (contextX, model) {
//                                 return model;
//                               },
//                               shouldRebuild: (pre, model) => true,
//                             ),
//                           ),

//                           /// 主模块配置
//                           Padding(
//                             padding: EdgeInsets.only(left: 15, right: 15),
//                             child: Selector<HomeModel, HomeModel>(
//                                 builder: (ctx, model, child) {
//                               return model.mainModuleList.length > 0
//                                   ? _mainModuleBuilder(
//                                       list: model.mainModuleList)
//                                   : Container();
//                             }, selector: (ctx, model) {
//                               return model;
//                             }),
//                           ),

//                           /// 子模块入口
//                           Padding(
//                             padding: EdgeInsets.only(left: 10, right: 10),
//                             child: Selector<HomeModel, HomeModel>(
//                                 builder: (ctx, model, child) {
//                               return model.subModuleList.length > 0
//                                   ? Column(
//                                       crossAxisAlignment:
//                                           CrossAxisAlignment.start,
//                                       children: [
//                                         SizedBox(
//                                           height: 12,
//                                         ),

//                                         /// 更多文本
//                                         Text(
//                                           S.of(context).home_more,
//                                           textAlign: TextAlign.left,
//                                           style: TextStyle(
//                                             fontSize: 18,
//                                             fontWeight: FontWeight.bold,
//                                             color: AppColors.colorFF333333,
//                                           ),
//                                         ),
//                                         _subModulePage(
//                                             gameList: model.subModuleList),
//                                       ],
//                                     )
//                                   : Container();
//                             }, selector: (ctx, model) {
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

//             /// 悬浮按钮
//             Selector<HomeModel, HomeModel>(builder: (ctx, model, child) {
//               return model.floatingButton.length > 0
//                   ? FloatBox(
//                       screenWidth: MediaQuery.of(context).size.width,
//                       safeContentHeight: MediaQuery.of(context).size.height -
//                           MediaQuery.of(context).padding.top -
//                           MediaQuery.of(context).padding.bottom -
//                           kToolbarHeight -
//                           kBottomNavigationBarHeight,
//                       iconUrl: model.floatingButton.first.iconUrl,
//                       onTap: () {
//                         /// 悬浮按钮点击
//                         HomeSourceDataManager.clickSingleModule(
//                             eventId: HomeSourceDataManager.floatButtonClick,
//                             elementId: model.floatingButton.first.id);
//                         CommonEventManager.handleEvent(
//                             itemBeanEntity: model.floatingButton.first);
//                       },
//                     )
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

//   /// methodName _moduleBuilder
//   /// description 模块配置 根据接口动态调整
//   /// date 2022/3/9 2:36 下午
//   /// author LiuChuanan
//   Widget _mainModuleBuilder({required List<HomeItemBeanEntity> list}) {
//     Widget _widget = Container();

//     /// 下载状态
//     if (list.length == 3) {
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
//                         child: _builderDownloadStatus(itemBeanEntity: oneModuleFirst),
//                       )
//                     : Container(),
//               ],
//             ),
//           ),
//           onTap: !shouldShow
//               ? () {
//                   /// 主模块点击
//                   HomeSourceDataManager.clickSingleModule(
//                     eventId: HomeSourceDataManager.mainModuleClick,
//                     elementId: oneModuleFirst.id,
//                   );
//                   oneModuleFirst.downloadStatus = 1;
//                   Provider.of<HomeModel>(context, listen: false)
//                       .updateMainModuleDataSource(oneModuleFirst, 0);
//                   // handleUnityDownload(
//                   //   itemBeanEntity: oneModuleFirst,
//                   //   moduleIndex: HomeModuleEnum.MainModule,
//                   //   itemIndex: 0,
//                   // );
//                 }
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
//                               child: _downloadProgress(
//                                   twoModuleFirstBean.progress / 100.0),
//                             )
//                           : Container(),
//                     ],
//                   ),
//                   onTap: !twoModuleFirstShouldShow
//                       ? () {
//                           /// 主模块点击
//                           HomeSourceDataManager.clickSingleModule(
//                             eventId: HomeSourceDataManager.mainModuleClick,
//                             elementId: twoModuleFirstBean.id,
//                           );
//                           handleUnityDownload(
//                             itemBeanEntity: twoModuleFirstBean,
//                             moduleIndex: HomeModuleEnum.MainModule,
//                             itemIndex: 0,
//                           );
//                         }
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
//                               child: _downloadProgress(
//                                   twoModuleSecondBean.progress / 100.0),
//                             )
//                           : Container(),
//                     ],
//                   ),
//                   onTap: !twoModuleSecondShouldShow
//                       ? () {
//                           /// 主模块点击
//                           HomeSourceDataManager.clickSingleModule(
//                             eventId: HomeSourceDataManager.mainModuleClick,
//                             elementId: twoModuleSecondBean.id,
//                           );
//                           handleUnityDownload(
//                             itemBeanEntity: twoModuleSecondBean,
//                             moduleIndex: HomeModuleEnum.MainModule,
//                             itemIndex: 1,
//                           );
//                         }
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

//       bool threeModuleFirstShouldShow = false;
//       if (threeModuleFirstBean.downloadStatus == 1 ||
//           threeModuleFirstBean.downloadStatus == 2 ||
//           threeModuleFirstBean.downloadStatus == 6) {
//         threeModuleFirstShouldShow = true;
//       }

//       bool threeModuleSecondShouldShow = false;
//       if (threeModuleSecondBean.downloadStatus == 1 ||
//           threeModuleSecondBean.downloadStatus == 2 ||
//           threeModuleSecondBean.downloadStatus == 6) {
//         threeModuleSecondShouldShow = true;
//       }

//       bool threeModuleThirdShouldShow = false;
//       if (threeModuleThirdBean.downloadStatus == 1 ||
//           threeModuleThirdBean.downloadStatus == 2 ||
//           threeModuleThirdBean.downloadStatus == 6) {
//         threeModuleThirdShouldShow = true;
//       }

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
//                               child: _downloadProgress(
//                                   threeModuleFirstBean.progress / 100.0),
//                             )
//                           : Container(),
//                     ],
//                   ),
//                   onTap: !threeModuleFirstShouldShow
//                       ? () {
//                           /// 主模块点击
//                           HomeSourceDataManager.clickSingleModule(
//                             eventId: HomeSourceDataManager.mainModuleClick,
//                             elementId: threeModuleFirstBean.id,
//                           );
//                           handleUnityDownload(
//                             itemBeanEntity: threeModuleFirstBean,
//                             moduleIndex: HomeModuleEnum.MainModule,
//                             itemIndex: 0,
//                           );
//                         }
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
//                                     constraints: BoxConstraints.expand(),
//                                     height: 210,
//                                     decoration: BoxDecoration(
//                                       borderRadius: BorderRadius.circular(8.0),
//                                       image: const DecorationImage(
//                                         image: AssetImage(
//                                           Img.downloadBackground,
//                                         ),
//                                         fit: BoxFit.fill,
//                                       ),
//                                     ),
//                                     child: _downloadProgress(
//                                         threeModuleSecondBean.progress / 100.0),
//                                   )
//                                 : Container(),
//                           ],
//                         ),
//                         onTap: !threeModuleSecondShouldShow
//                             ? () {
//                                 /// 主模块点击
//                                 HomeSourceDataManager.clickSingleModule(
//                                   eventId:
//                                       HomeSourceDataManager.mainModuleClick,
//                                   elementId: threeModuleSecondBean.id,
//                                 );
//                                 handleUnityDownload(
//                                   itemBeanEntity: threeModuleSecondBean,
//                                   moduleIndex: HomeModuleEnum.MainModule,
//                                   itemIndex: 1,
//                                 );
//                               }
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
//                                     constraints: BoxConstraints.expand(),
//                                     height: 210,
//                                     decoration: BoxDecoration(
//                                       borderRadius: BorderRadius.circular(8.0),
//                                       image: const DecorationImage(
//                                         image: AssetImage(
//                                           Img.downloadBackground,
//                                         ),
//                                         fit: BoxFit.fill,
//                                       ),
//                                     ),
//                                     child: _downloadProgress(
//                                         threeModuleThirdBean.progress / 100.0),
//                                   )
//                                 : Container(),
//                           ],
//                         ),
//                         onTap: !threeModuleThirdShouldShow
//                             ? () {
//                                 /// 主模块点击
//                                 HomeSourceDataManager.clickSingleModule(
//                                   eventId:
//                                       HomeSourceDataManager.mainModuleClick,
//                                   elementId: threeModuleThirdBean.id,
//                                 );
//                                 handleUnityDownload(
//                                   itemBeanEntity: threeModuleThirdBean,
//                                   moduleIndex: HomeModuleEnum.MainModule,
//                                   itemIndex: 2,
//                                 );
//                               }
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
//         top: 10,
//       ),
//       child: Container(
//         key: _globalKey,
//         child: _widget,
//       ),
//     );
//   }

//   Widget _builderDownloadStatus({required HomeItemBeanEntity itemBeanEntity}) {
//     return Column(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         LoadingAnimationWidget.newtonCradle(
//           color: Colors.white,
//           size: 60,
//         ),
//       ],
//     );
//   }

//   /// methodName _downloadProgress
//   /// description 游戏更新包下载进度组件
//   /// date 2022/7/19 19:04
//   /// author LiuChuanan
//   Widget _downloadProgress(double progress) {
//     return DownloadProgress(
//       progress: progress,
//       fillColor: AppColors.colorGrey,
//       borderWidth: 3,
//       radius: 50.0,
//     );
//   }

//   /// methodName _gamesPage
//   /// description 游戏入口页面
//   /// date 2022/3/9 3:25 下午
//   /// author LiuChuanan
//   Widget _subModulePage({required List<HomeItemBeanEntity> gameList}) {
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
//           childAspectRatio: 0.78,
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
//                     if (gameBeanEntity.shouldShow == ModuleShouldShow.Yes &&
//                         gameBeanEntity.tip.ty == RedDotType.DigitalDot) {
//                       int count = Provider.of<HomeModel>(context, listen: false)
//                           .homeTabItemCount;
//                       count--;
//                       Provider.of<HomeModel>(context, listen: false)
//                           .homeTabItemCount = count;
//                       Provider.of<NavigatorViewModel>(context, listen: false)
//                           .setHomeTabCount(count);
//                     }

//                     bool contain = false;
//                     if (gameBeanEntity.shouldShow == ModuleShouldShow.Yes) {
//                       gameBeanEntity.shouldShow = ModuleShouldShow.No;
//                       gameBeanEntity.timeInterval =
//                           DateTime.now().millisecondsSinceEpoch;
//                       String gameKey = "${UserInfoRepo.userId}gameList";
//                       var data = await SpUtils().getStorage(gameKey);
//                       List list = [];
//                       for (int i = 0; i < data.length; i++) {
//                         HomeItemBeanEntity beanEntity =
//                             HomeItemBeanEntity.fromJson(data[i]);
//                         if (beanEntity.id == gameBeanEntity.id) {
//                           contain = true;
//                           beanEntity.shouldShow =
//                               gameBeanEntity.shouldShow = ModuleShouldShow.No;
//                           beanEntity.timeInterval = gameBeanEntity.timeInterval;
//                         }
//                         list.add(beanEntity);
//                       }

//                       if (contain == false) {
//                         list.add(gameBeanEntity);
//                       }

//                       await SpUtils().setStorage(gameKey, list);
//                     }

//                     /// 子模块点击
//                     HomeSourceDataManager.clickSingleModule(
//                       eventId: HomeSourceDataManager.subModuleClick,
//                       elementId: gameBeanEntity.id,
//                     );
//                     handleUnityDownload(
//                       itemBeanEntity: gameBeanEntity,
//                       moduleIndex: HomeModuleEnum.SubModule,
//                       itemIndex: index,
//                     );
//                   }
//                 : null,
//           );
//         },
//         itemCount: gameList.length,
//       ),
//     );
//   }

//   /// methodName _itemWidget
//   /// description 小红点显示控件
//   /// date 2022/3/22 4:50 下午
//   /// author LiuChuanan
//   Widget _itemWidget(int index, HomeItemBeanEntity gameBeanEntity) {
//     if (gameBeanEntity.shouldShow == ModuleShouldShow.Yes) {
//       if (gameBeanEntity.tip.ty == RedDotType.PureDot) {
//         /// 纯红点类型
//         return Badge(
//           toAnimate: false,
//           position: BadgePosition.topEnd(top: 10, end: 10),
//           badgeContent: null,
//           child: _contentItem(index, gameBeanEntity),
//         );
//       } else if (gameBeanEntity.tip.ty == RedDotType.TextDot) {
//         /// 文本类型
//         return Badge(
//           toAnimate: false,
//           shape: BadgeShape.square,
//           borderRadius: BorderRadius.circular(5),
//           position: BadgePosition.topEnd(top: 5, end: 10),
//           padding: EdgeInsets.all(2),
//           badgeContent: Text(
//             gameBeanEntity.tip.content,
//             style: TextStyle(
//               color: AppColors.colorWhite,
//               fontSize: 10,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           child: _contentItem(index, gameBeanEntity),
//         );
//       } else {
//         /// 数字类型
//         return Badge(
//           toAnimate: false,
//           position: BadgePosition.topEnd(top: 2, end: 10),
//           elevation: 0,
//           shape: BadgeShape.circle,
//           padding: EdgeInsets.all(0.1),
//           badgeContent: Center(
//             child: Container(
//               alignment: Alignment.center,
//               height: 18,
//               width: 18,
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(9.0),
//               ),
//               child: Text(
//                 gameBeanEntity.tip.content,
//                 textAlign: TextAlign.center,
//                 style: TextStyle(
//                   height: 1.25,
//                   color: AppColors.colorWhite,
//                   fontSize: gameBeanEntity.tip.content.length > 2
//                       ? 8
//                       : gameBeanEntity.tip.content.length == 2
//                           ? 10
//                           : 12,
//                 ),
//               ),
//             ),
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

//   Widget _contentItem(int index, HomeItemBeanEntity gameBeanEntity) {
//     bool shouldShow = false;
//     if (gameBeanEntity.downloadStatus == 1 ||
//         gameBeanEntity.downloadStatus == 2 ||
//         gameBeanEntity.downloadStatus == 6) {
//       shouldShow = true;
//     }
//     return Container(
//       color: Colors.transparent,
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.start,
//         children: [
//           Padding(padding: EdgeInsets.only(top: 5)),
//           Container(
//             color: Colors.transparent,
//             height: 62,
//             width: 62,
//             child: Stack(
//               children: [
//                 ClipRRect(
//                   borderRadius: BorderRadius.circular(8.0),
//                   child: ExtendedImage.network(
//                     gameBeanEntity.iconUrl,
//                     height: 62,
//                     fit: BoxFit.fitWidth,
//                     cache: true,
//                   ),
//                 ),
//                 shouldShow
//                     ? Container(
//                         constraints: BoxConstraints.expand(),
//                         decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(8.0),
//                           image: const DecorationImage(
//                             image: AssetImage(
//                               Img.downloadBackground,
//                             ),
//                             fit: BoxFit.fill,
//                           ),
//                         ),
//                         child:
//                             _downloadProgress(gameBeanEntity.progress / 100.0),
//                       )
//                     : Container(),
//               ],
//             ),
//           ),
//           Padding(padding: EdgeInsets.only(top: 4)),
//           Container(
//             color: Colors.transparent,
//             child: Text(
//               gameBeanEntity.name,
//               textAlign: TextAlign.center,
//               maxLines: 2,
//               overflow: TextOverflow.ellipsis,
//               style: TextStyle(
//                 fontSize: 10.5,
//                 fontWeight: FontWeight.w500,
//                 color: AppColors.colorFF333333,
//                 height: 1.05,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   /// methodName handleUnityDownload moduleIndex：大模块索引； itemIndex：大模块内小模块索引
//   /// description 处理游戏下载加载动态状态
//   /// date 2022/6/25 10:06
//   /// author LiuChuanan
//   void handleUnityDownload({
//     required HomeItemBeanEntity itemBeanEntity,
//     int moduleIndex = 1,
//     int itemIndex = 0,
//   }) {
//     DownloadManager().downloadUnityModule(
//         gameId: UnityDownloadConfig.getGameIdName(
//             jump: itemBeanEntity.jump, key: UnityDownloadConfig.gameId),
//         moduleIndex: moduleIndex,
//         itemIndex: itemIndex,
//         callBack: (map) {
//           int status = map["status"];
//           if (status == 3) {
//             CommonEventManager.handleEvent(
//                 itemBeanEntity: itemBeanEntity, status: 3);
//           } else {
//             itemBeanEntity.downloadStatus = 2;
//             if (moduleIndex == HomeModuleEnum.MainModule) {
//               Provider.of<HomeModel>(context, listen: false)
//                   .updateMainModuleDataSource(itemBeanEntity, itemIndex);
//             } else if (moduleIndex == HomeModuleEnum.SubModule) {
//               Provider.of<HomeModel>(context, listen: false)
//                   .updateSubModuleDataSource(itemBeanEntity, itemIndex);
//             }
//           }
//         });
//   }
// }
