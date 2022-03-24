import 'package:flutter/material.dart';
import 'package:my_gallery/flu_app/t_live/TRTCCallingDemo/model/TRTCCalling.dart';
import 'package:my_gallery/flu_app/t_live/TRTCCallingDemo/model/TRTCCallingDelegate.dart';
import 'package:my_gallery/flu_app/t_live/TRTCCallingDemo/ui/base/CallTypes.dart';
import 'package:my_gallery/flu_app/t_live/TRTCCallingDemo/ui/base/CallingScenes.dart';
import 'package:my_gallery/flu_app/t_live/debug/GenerateTestUserSig.dart';
import 'package:my_gallery/flu_app/t_live/login/ProfileManager_Mock.dart';
import 'package:my_gallery/flu_app/t_live/utils/TxUtils.dart';


class DemoSevice {
  static DemoSevice? _instance;

  TRTCCalling? _tRTCCallingService;
  ProfileManager? _profileManager;
  late GlobalKey<NavigatorState> _navigatorKey;
  bool _isRegisterListener = false;
  DemoSevice() {
    initTrtc();
  }
  initTrtc() async {
    _tRTCCallingService = await TRTCCalling.sharedInstance();
    _profileManager = await ProfileManager.getInstance();
  }

  static sharedInstance() {
    if (_instance == null) {
      _instance = new DemoSevice();
    }
    return _instance;
  }

  setNavigatorKey(GlobalKey<NavigatorState> navigatorKey) {
    _navigatorKey = navigatorKey;
  }

  start() async {
    if (_isRegisterListener) {
      _tRTCCallingService!.unRegisterListener(onTrtcListener);
    }
    String loginId = await TxUtils.getLoginUserId();
    await _tRTCCallingService!.login(GenerateTestUserSig.sdkAppId, loginId,
        await GenerateTestUserSig.genTestSig(loginId));
    _isRegisterListener = true;
    _tRTCCallingService!.registerListener(onTrtcListener);
  }

  onTrtcListener(type, params) async {
    switch (type) {
      case TRTCCallingDelegate.onInvited:
        {
          BuildContext context = _navigatorKey.currentState!.overlay!.context;
          UserModel userInfo = await _profileManager!
              .querySingleUserInfo(params["sponsor"].toString());
          Navigator.pushReplacementNamed(
            context,
            "/calling/callingView",
            arguments: {
              "remoteUserInfo": userInfo,
              "callType": CallTypes.Type_Being_Called,
              "callingScenes": params['type'] == TRTCCalling.typeVideoCall
                  ? CallingScenes.VideoOneVOne
                  : CallingScenes.AudioOneVOne
            },
          );
        }
        break;
    }
  }
}
