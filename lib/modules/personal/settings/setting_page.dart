import 'dart:io';
import 'package:my_gallery/common/const/api_const.dart';
import 'package:my_gallery/common/const/router_const.dart';
import 'package:my_gallery/common/config/config.dart';
import 'package:my_gallery/common/dao/original_dao/login_dao.dart';
import 'package:my_gallery/common/locale/localizations.dart';
import 'package:my_gallery/common/singleton/singleton_manager.dart';
import 'package:my_gallery/model/check_update_model.dart';
import 'package:my_gallery/common/redux/app_state.dart';
import 'package:my_gallery/common/redux/user_reducer.dart';
import 'package:my_gallery/model/user_info_model.dart';
import 'package:my_gallery/modules/common_app/entrance/common_bottom_tabbar_page.dart';
import 'package:my_gallery/modules/personal/settings/change_language.dart';
import 'package:my_gallery/modules/personal/settings/check_version_page.dart';
import 'package:my_gallery/modules/personal/settings/about_page.dart';
import 'package:my_gallery/modules/personal/settings/change_password_page.dart';
import 'package:my_gallery/modules/personal/settings/check_error_page.dart';
import 'package:my_gallery/modules/personal/settings/personal_info_page.dart';
import 'package:my_gallery/modules/personal/settings/qr_page.dart';
import 'package:my_gallery/modules/widgets/style/style.dart';
import 'package:my_gallery/modules/widgets/row/setting_row.dart';
import 'package:my_gallery/common/tools/date/eye_protection_timer.dart';
import 'package:my_gallery/common/tools/date/report_timer.dart';
import 'package:my_gallery/common/tools/share_preference/share_preference.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:jpush_flutter/jpush_flutter.dart';
import 'package:redux/redux.dart';
import 'change_mobile_number_page.dart';


///
/// @name SettingPage
/// @description 设置页面
/// @author waitwalker
/// @date 2020-01-11
///
class SettingPage extends StatefulWidget {
  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> with CheckVersionPage {
  bool? _wifiOnly;
  CheckUpdateModel? versionInfo;

  @override
  void initState() {
    super.initState();
    _wifiOnly = SharedPrefsUtils.get('wifi_only', true);
    checkVersionSilence().then((r) {
      if (r != null) {
        setState(() {
          versionInfo = r;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var userInfo = _getStore().state.userInfo;
    if (userInfo != null) {
      var hasBindMobile = _getStore().state.userInfo!.data!.bindingStatus == 1;
      return StoreBuilder(
        builder: (BuildContext context, Store<AppState> vm) {
          return Scaffold(
            appBar: AppBar(
              elevation: 1.0,
              title: Text(MTTLocalization.of(context)!.currentLocalized!.settingPageNavigatorTitle!),
              backgroundColor: Colors.white,
              centerTitle: Platform.isIOS ? true : false,
            ),
            backgroundColor: Color(MyColors.background),
            body: settingContent(hasBindMobile, userInfo),
          );
        },
      );
    } else {
      return Scaffold(
        body: Container(),
      );
    }
  }

  Widget settingContent(bool hasBindMobile, UserInfoModel userInfoModel) {
    if (SingletonManager.sharedInstance!.deviceName == Config.DEVICE_NAME) {
      return Container(
        child: Stack(children: <Widget>[
          Column(
            children: <Widget>[
              Divider(height: 0.5, color: Colors.black12),
              SettingRow(
                MTTLocalization.of(context)!.currentLocalized!.settingPagePersonalInfo,
                onPress: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (BuildContext context) => PersonalInfoPage()));
                },
              ),
              Divider(height: 0.5, color: Colors.black12),
              SettingRow(
                MTTLocalization.of(context)!.currentLocalized!.settingPageChangePassword,
                onPress: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (BuildContext context) =>
                          ChangePasswordPage()));
                },
              ),
              if (hasBindMobile)
                Divider(height: 0.5, color: Colors.black12),
              if (hasBindMobile)
                SettingRow(
                  MTTLocalization.of(context)!.currentLocalized!.settingPageChangeMobileNum,
                  onPress: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (BuildContext context) =>
                            ChangeMobileNumberPage()));
                  },
                ),
              Divider(height: 0.5, color: Colors.black12),
              // SettingRow(
              //   '修改手机',
              // ),
              // Divider(height: 0.5, color: Colors.black12),
              SettingRow(
                MTTLocalization.of(context)!.currentLocalized!.settingPageAbout,
                onPress: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (BuildContext context) => AboutPage()));
                },
              ),
              Divider(height: 0.5, color: Colors.black12),
              SettingRow(
                MTTLocalization.of(context)!.currentLocalized!.settingPageTroubleShoot,
                onPress: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (BuildContext context) => CheckErrorPage()));
                },
              ),
              Divider(height: 0.5, color: Colors.black12),
              SettingRow(
                MTTLocalization.of(context)!.currentLocalized!.settingPageWifiDownloadOnly,
                rightCustomWidget: CupertinoSwitch(
                  onChanged: _toggleWifiOnly,
                  value: _wifiOnly!,),
                showRightArrow: false,
                onPress: () => _toggleWifiOnly(!_wifiOnly!),
              ),
              Divider(height: 0.5, color: Colors.black12),
              SettingRow(
                  MTTLocalization.of(context)!.currentLocalized!.settingPageCheckVersion,
                  showRightArrow: false,
                  onPress: () {
                    checkUpdate(showToast: true);
                  },
                  subText: versionInfo?.data?.forceType == 1
                      ? '发现新版本'
                      : versionInfo?.data?.message ?? '已是最新版本',
                  subTextStyle: TextStyle(
                      fontSize: 12, color: Color(MyColors.black666))),
              Divider(height: 0.5, color: Colors.black12),

              SettingRow(
                MTTLocalization.of(context)!.currentLocalized!.settingPageChangeLanguage,
                onPress: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context){
                    return ChangeLanguagePage();
                  }));
                },
              ),
              Divider(height: 0.5, color: Colors.black12),

              SettingRow(
                MTTLocalization.of(context)!.currentLocalized!.settingPageChangeTheme,
                onPress: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context){
                    return ChangeLanguagePage();
                  }));
                },
              ),
              Divider(height: 0.5, color: Colors.black12),

              SettingRow(
                "二维码",
                onPress: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context){
                    return QRPage();
                  }));
                },
              ),
              Divider(height: 0.5, color: Colors.black12),

              SettingRow(
                "App",
                onPress: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context){
                    return CommonBottomTabBarPage();
                  }));
                },
              ),
              Divider(height: 0.5, color: Colors.black12),
            ],
          ),

          Positioned(
            bottom: 53,
            left: 32,
            right: 32,
            child: Container(
              child: ElevatedButton(
                style: ButtonStyle(
                  padding: MaterialStateProperty.resolveWith<EdgeInsetsGeometry>(
                        (Set<MaterialState> states) {
                      return EdgeInsets.only(top: 12, bottom: 12);
                    },
                  ),
                  shape: ButtonStyleButton.allOrNull<RoundedRectangleBorder>(RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4.0)))),
                  backgroundColor: ButtonStyleButton.allOrNull<Color>(
                      Color.fromRGBO(220, 220, 220, 1.0)
                  ),
                ),
                child: Text(
                  MTTLocalization.of(context)!.currentLocalized!.settingPageSignOut!,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.black,
                    fontWeight: FontWeight.normal,
                  ),
                ),
                onPressed: _logout,
              ),
            ),
          )
        ]),
      );
    } else {
      return Container(
        child: Stack(children: <Widget>[
          Column(
            children: <Widget>[
              Divider(height: 0.5, color: Colors.black12),
              SettingRow(
                MTTLocalization.of(context)!.currentLocalized!.settingPagePersonalInfo,
                onPress: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (BuildContext context) => PersonalInfoPage()));
                },
              ),
              Divider(height: 0.5, color: Colors.black12),
              SettingRow(
                MTTLocalization.of(context)!.currentLocalized!.settingPageChangePassword,
                onPress: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (BuildContext context) =>
                          ChangePasswordPage()));
                },
              ),
              if (hasBindMobile)
                Divider(height: 0.5, color: Colors.black12),
              if (hasBindMobile)
                SettingRow(
                  MTTLocalization.of(context)!.currentLocalized!.settingPageChangeMobileNum,
                  onPress: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (BuildContext context) =>
                            ChangeMobileNumberPage()));
                  },
                ),
              Divider(height: 0.5, color: Colors.black12),
              // SettingRow(
              //   '修改手机',
              // ),
              // Divider(height: 0.5, color: Colors.black12),
              SettingRow(
                MTTLocalization.of(context)!.currentLocalized!.settingPageAbout,
                onPress: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (BuildContext context) => AboutPage()));
                },
              ),
              Divider(height: 0.5, color: Colors.black12),
              SettingRow(
                MTTLocalization.of(context)!.currentLocalized!.settingPageTroubleShoot,
                onPress: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (BuildContext context) => CheckErrorPage()));
                },
              ),
              Divider(height: 0.5, color: Colors.black12),
              SettingRow(
                MTTLocalization.of(context)!.currentLocalized!.settingPageWifiDownloadOnly,
                rightCustomWidget: CupertinoSwitch(
                  onChanged: _toggleWifiOnly,
                  value: _wifiOnly!,),
                showRightArrow: false,
                onPress: () => _toggleWifiOnly(!_wifiOnly!),
              ),
              Divider(height: 0.5, color: Colors.black12),

              SettingRow(
                  MTTLocalization.of(context)!.currentLocalized!.settingPageCheckVersion,
                  showRightArrow: false,
                  onPress: () {
                    checkUpdate(showToast: true);
                  },
                  subText: versionInfo?.data?.forceType == 1
                      ? '发现新版本'
                      : versionInfo?.data?.message ?? '已是最新版本',
                  subTextStyle: TextStyle(fontSize: 12, color: Color(MyColors.black666))),
              Divider(height: 0.5, color: Colors.black12),

            ],
          ),
          Positioned(
            bottom: 53,
            left: 32,
            right: 32,
            child: Container(
              child: ElevatedButton(
                style: ButtonStyle(
                  padding: MaterialStateProperty.resolveWith<EdgeInsetsGeometry>(
                        (Set<MaterialState> states) {
                      return EdgeInsets.only(top: 12, bottom: 12);
                    },
                  ),
                  shape: ButtonStyleButton.allOrNull<RoundedRectangleBorder>(RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4.0)))),
                  backgroundColor: ButtonStyleButton.allOrNull<Color>(
                      Color.fromRGBO(220, 220, 220, 1.0)
                  ),
                ),
                child: Text(
                  MTTLocalization.of(context)!.currentLocalized!.settingPageSignOut!,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.black,
                    fontWeight: FontWeight.normal,
                  ),
                ),
                onPressed: _logout,
              ),
            ),
          )
        ]),
      );
    }
  }

  _toggleWifiOnly(bool value) {
    _wifiOnly = value;
    SharedPrefsUtils.put('wifi_only', _wifiOnly);
    setState(() {});
  }

  Store<AppState> _getStore() {
    return StoreProvider.of(context);
  }

  void _logout() {
    // NavigatorUtils.goLoginCC(context);
    LoginDao.logout();
    ReportTimer.stopTimer();
    EyeProtectionTimer.stopTimer();
    SharedPrefsUtils.remove(APIConst.LOGIN_JSON);
    _getStore().dispatch(UpdateUserAction(null));
    JPush().deleteAlias();
    /// 首页弹框置为默认值
    SingletonManager.sharedInstance!.isHaveLoadedAlert = false;
    SingletonManager.sharedInstance!.zhiLingAuthority = false;
    SingletonManager.sharedInstance!.isJumpFromAixue = false;
    SingletonManager.sharedInstance!.isJumpColdStart = false;
    SingletonManager.sharedInstance!.isHaveLogin = false;
    SingletonManager.sharedInstance!.shouldShowActivityCourse = true;
    SingletonManager.sharedInstance!.aixueAccount = "";
    SingletonManager.sharedInstance!.aixuePassword = "";
    SingletonManager.sharedInstance!.isVip = "";
    SingletonManager.sharedInstance!.gradeId = "";
    Navigator.pushNamedAndRemoveUntil(
        context, RouteConst.login, (Route<dynamic> route) => false);
  }

}
