import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:my_gallery/common/const/router_const.dart';
import 'package:my_gallery/common/dao/manager/dao_manager.dart';
import 'package:my_gallery/common/dao/original_dao/analysis.dart';
import 'package:my_gallery/common/dao/original_dao/course_dao_manager.dart';
import 'package:my_gallery/common/dao/original_dao/login_dao.dart';
import 'package:my_gallery/common/dao/original_dao/user_info_dao.dart';
import 'package:my_gallery/common/logger/logger_manager.dart';
import 'package:my_gallery/common/singleton/singleton_manager.dart';
import 'package:my_gallery/model/login_model.dart';
import 'package:my_gallery/model/my_course_model.dart';
import 'package:my_gallery/model/user_info_model.dart';
import 'package:my_gallery/common/network/response.dart';
import 'package:my_gallery/common/redux/app_state.dart';
import 'package:my_gallery/common/redux/user_reducer.dart';
import 'package:my_gallery/modules/entrance/tabbar_container_page.dart';
import 'package:my_gallery/modules/my_plan/my_plan_authority_model.dart';
import 'package:my_gallery/modules/personal/error_book/unit_test/unit_test_authority_model.dart';
import 'package:my_gallery/modules/widgets/loading/loading_dialog.dart';
import 'package:my_gallery/modules/widgets/style/style.dart';
import 'package:my_gallery/modules/widgets/button/rounded_gradient_ripple_button.dart';
import 'package:my_gallery/common/tools/screen_adapt/screen_utils.dart';
import 'package:my_gallery/common/tools/share_preference/share_preference.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:jpush_flutter/jpush_flutter.dart';
import 'package:page_transition/page_transition.dart';
import 'package:redux/redux.dart';


///
/// @name LoginPage
/// @description 登录页
/// @author waitwalker
/// @date 2020-01-10
///
class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController? _userNameController;
  TextEditingController? _passwordController;

  Future<Null> Function()? _onPressed;
  GlobalKey? _pwdKey;
  late bool _hidePassword;

  FocusNode _userFocusNode = FocusNode();
  FocusNode _passwordFocusNode = FocusNode();

  MethodChannel methodChannel = const MethodChannel("aixue_wangxiao_channel");

  bool showAccountDelete = false; ///删除是否可见
  bool showPasswordVisible = false; ///控制密码明文密文
  bool shouldHideVisible = true; ///密码明文密文按钮是否可见

  ///
  /// @MethodName 跳转处理状态2
  /// @Parameter
  /// @ReturnType
  /// @Description
  /// @Author waitwalker
  /// @Date 2020-02-03
  ///
  Future<dynamic>? _handler(MethodCall methodCall) {
    LoggerManager.info("${methodCall.method}");
    LoggerManager.info("${methodCall.arguments}");
    if (SingletonManager.sharedInstance!.isHaveLogin == false) {
      if (methodCall.arguments != null) {
        List<String> arguments = methodCall.arguments.toString().split("&");
        String account = arguments[0];
        String password = arguments[1];
        String isVip = arguments[2];
        String gradeId = arguments[3];
        if (account != null && password != null) {
          SingletonManager.sharedInstance!.shouldShowActivityCourse = true;
          SingletonManager.sharedInstance!.isVip = isVip;
          SingletonManager.sharedInstance!.gradeId = gradeId;
          _userNameController!.text = account;
          _passwordController!.text = password;
          SingletonManager.sharedInstance!.isJumpFromAixue = true;
          loginAction();
        } else {
          _userNameController!.text = "";
          _passwordController!.text = "";
          SharedPrefsUtils.putString('username', _userNameController!.text);
          SharedPrefsUtils.putString('password', _passwordController!.text);
        }
      } else {
        _userNameController!.text = "";
        _passwordController!.text = "";
        SharedPrefsUtils.putString('username', _userNameController!.text);
        SharedPrefsUtils.putString('password', _passwordController!.text);
      }
      print("登录页处理跳转");

    }
    return null;
  }

  @override
  void initState() {
    methodChannel.setMethodCallHandler(_handler as Future<dynamic> Function(MethodCall)?);
    var nm = SharedPrefsUtils.getString('username');
    var pwd = SharedPrefsUtils.getString('password');
    _userNameController = new TextEditingController(text: nm);
    _passwordController = new TextEditingController(text: pwd);
    _pwdKey = GlobalKey();
    _hidePassword = true;
    _onChanged(null);

    _userFocusNode.addListener(() {
      LoggerManager.info("_userFocusNode.hasFocus: ${_userFocusNode.hasFocus}");
      if (!_userFocusNode.hasFocus) {
        showAccountDelete = false;
      } else {
        if (_userNameController!.text.length > 0) {
          showAccountDelete = true;
        }
      }
      setState(() {});
    });

    _passwordFocusNode.addListener(() {
      LoggerManager.info("_passwordFocusNode.hasFocus: ${_passwordFocusNode.hasFocus}");

      if (!_passwordFocusNode.hasFocus) {
        shouldHideVisible = false;
      } else {
        if (_passwordController!.text.length > 0) {
          shouldHideVisible = true;
        }
      }
      setState(() {});
    });

    /// 跳转处理状态3
    Future.delayed(Duration(seconds: 1),(){
      if (SingletonManager.sharedInstance!.isHaveLogin == true) {
        SingletonManager.sharedInstance!.isHaveLogin = false;
        SingletonManager.sharedInstance!.shouldShowActivityCourse = true;
        if (SingletonManager.sharedInstance!.aixueAccount != null
            && SingletonManager.sharedInstance!.aixueAccount!.length > 0
            && SingletonManager.sharedInstance!.isJumpColdStart == false) {
          _userNameController!.text = SingletonManager.sharedInstance!.aixueAccount!;
          _passwordController!.text = SingletonManager.sharedInstance!.aixuePassword!;
          SingletonManager.sharedInstance!.isJumpFromAixue = true;
          loginAction();
        } else {
          _userNameController!.text = "";
          _passwordController!.text = "";
          SharedPrefsUtils.putString('username', _userNameController!.text);
          SharedPrefsUtils.putString('password', _passwordController!.text);
        }
      }

    });

    /// 跳转处理状态1
    Future.delayed(Duration(seconds: 1),(){
      if (SingletonManager.sharedInstance!.isJumpColdStart == true) {
        if (SingletonManager.sharedInstance!.aixueAccount != null
            && SingletonManager.sharedInstance!.aixueAccount!.length > 0
        ) {
          SingletonManager.sharedInstance!.shouldShowActivityCourse = true;
          _userNameController!.text = SingletonManager.sharedInstance!.aixueAccount!;
          _passwordController!.text = SingletonManager.sharedInstance!.aixuePassword!;
          SingletonManager.sharedInstance!.isJumpFromAixue = true;
          loginAction();
        } else {
          _userNameController!.text = "";
          _passwordController!.text = "";
          SharedPrefsUtils.putString('username', _userNameController!.text);
          SharedPrefsUtils.putString('password', _passwordController!.text);
        }
      }

    });
    super.initState();
  }

  Widget _build(BuildContext context) {
    return Container(
      child: Stack(
        children: <Widget>[
          Positioned(
            top: 0,
            right: 0,
            child: Image(
                image: AssetImage('static/images/login_background_top.png'),
                width: 200,
                fit: BoxFit.contain),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Image(
                image: AssetImage('static/images/login_background_down.png'),
                fit: BoxFit.contain),
          ),
          _container(context),
        ],
      ),
    );
  }

  Widget build(BuildContext context) {
    return GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          _userFocusNode.unfocus();
          _passwordFocusNode.unfocus();
        },
        child: StoreBuilder(
            builder: (BuildContext context, Store<AppState> store) {
              return Scaffold(
                backgroundColor: Colors.white,
                body: _build(context),
              );
            }));
  }

  Container _container(BuildContext context) {
    if (SingletonManager.sharedInstance!.isPadDevice) {
      return Container(
        color: Colors.transparent,
        height: double.infinity,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                padding: EdgeInsets.only(left: ScreenUtil.getInstance().setWidth(28), top: ScreenUtil.getInstance().setHeight(144)),
                alignment: Alignment.centerLeft,
                child: Text('用户登录', style: textStyle24222),
              ),
              Padding(
                padding: EdgeInsets.only(top: 80),
              ),
              Container(
                height: 54,
                width: ScreenUtil.getInstance().setWidth(304),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(22.0)),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                        color: Color(0x66B2C1D9),
                        offset: Offset(3, 4),
                        blurRadius: 10.0,
                        spreadRadius: 2.0)
                  ],
                ),
                child: Center(
                    child: TextField(
                      focusNode: _userFocusNode,
                      onChanged: _onChanged,
                      cursorWidth: 1,
                      cursorColor: Color(MyColors.primaryLightValue),
                      style: textStyleNormal,
                      inputFormatters: [LengthLimitingTextInputFormatter(60)],
                      textInputAction: TextInputAction.next,
                      onSubmitted: (_) {
                        _passwordFocusNode.requestFocus();
                      },
                      decoration: InputDecoration(
                        prefixIcon: SizedBox(
                          height: 30,
                          width: 30,
                          child: Container(
                            width: 30,
                            height: 30,
                            child: Center(
                              child: Image.asset("static/images/account_placeholder_icon.png",width: 24,height: 24,),
                            ),
                          ),),
                        border: OutlineInputBorder(borderSide: BorderSide.none),
                        contentPadding: EdgeInsets.only(top: 12.0, bottom: 12, left: 16),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Color(MyColors.primaryLightValue), width: 1.0),
                            borderRadius: BorderRadius.all(Radius.circular(22))),
                        hintText: '用户名/手机号',
                        hintStyle:
                        _userFocusNode.hasFocus ? textStyleHint : textStyleNormal,
                        suffixIcon: !showAccountDelete ? Container(width: 1,height: 1,) : GestureDetector(
                          child: Icon(Icons.close,size: 20,color: Color(0xff7494EC),),
                          onTap: (){
                            if (_userNameController!.text.length > 0){
                              _userNameController!.text = "";
                              showAccountDelete = false;
                              setState(() {

                              });
                            }
                          },
                        ),
                      ),
                      controller: _userNameController,
                    )),
              ),
              const SizedBox(height: 30),
              Container(
                height: 54,
                width: ScreenUtil.getInstance().setWidth(304),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(22.0)),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                        color: Color(0x66B2C1D9),
                        offset: Offset(3, 4),
                        blurRadius: 10.0,
                        spreadRadius: 2.0)
                  ],
                ),
                child: Container(
                  child: TextField(
                    key: _pwdKey,
                    focusNode: _passwordFocusNode,
                    onChanged: _onChanged,
                    obscureText: !showPasswordVisible,
                    cursorWidth: 1,
                    cursorColor: Color(MyColors.primaryLightValue),
                    style: textStyleNormal,
                    keyboardType: TextInputType.text,
                    inputFormatters: [LengthLimitingTextInputFormatter(16)],
                    textInputAction: TextInputAction.go,
                    onSubmitted: (_) => _onPressed!(),
                    decoration: InputDecoration(
                      prefixIcon: SizedBox(
                        height: 30,
                        width: 30,
                        child: Container(
                          width: 30,
                          height: 30,
                          child: Center(
                            child: Image.asset("static/images/password_placeholder_icon.png",width: 24,height: 28,),
                          ),
                        ),),
                      suffixIcon: GestureDetector(
                        child: Container(
                          width: 30,
                          height: 30,
                          child: Center(
                            child: shouldHideVisible ?
                            Image.asset(!showPasswordVisible ?
                            "static/images/visible_placeholder_icon.png" :
                            "static/images/invisible_placeholder_icon.png",
                              width: 24,
                              height: 24,) :
                            Container(),
                          ),
                        ),
                        onTap: (){
                          showPasswordVisible = !showPasswordVisible;
                          setState(() {

                          });
                        },
                      ),
                      border: OutlineInputBorder(borderSide: BorderSide.none),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Color(MyColors.primaryLightValue),
                              width: 1.0),
                          borderRadius: BorderRadius.all(Radius.circular(22))),
                      hintText: '密码',
                      contentPadding: EdgeInsets.only(top: 12.0, bottom: 12, left: 16),
                      hintStyle: _passwordFocusNode.hasFocus ? textStyleHint : textStyleNormal,
                    ),
                    controller: _passwordController,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  horizontal: ScreenUtil.getInstance().setWidth(42),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    InkWell(
                      child: Text('忘记密码', style: TextStyle(fontSize: 16, color: Color(MyColors.shadow2))),
                      onTap: () {
                        Navigator.of(context).pushNamed(RouteConst.forget_password);
                      },
                    ),
                    const SizedBox(width: 10),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 33),
              ),
              RaisedGradientRippleButton(
                radius: 22.0,
                gradient: LinearGradient(
                  colors: [Color(0xFF6B86FF), Color(0xFF4D67D4)],
                ),
                boxShadow: [
                  BoxShadow(
                      color: Color(0x66B2C1D9),
                      offset: Offset(3, 4),
                      blurRadius: 10.0,
                      spreadRadius: 2.0)
                ],
                child: Text(
                  '登录',
                  style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
                ),
                onPressed: _onPressed,
              ),
              //const SizedBox(height: ),
              InkWell(
                borderRadius: BorderRadius.circular(5.0),
                child: Container(
                  height: 40,
                  width: 80,
                  child: Text('去注册',
                      style: TextStyle(
                          fontSize: 16,
                          color: Color(MyColors.primaryLightValue))),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5.0)
                  ),
                ),
                onTap: () {
                  Navigator.pushNamed(context, RouteConst.register);
                },
              ),
            ],
          ),
        ),
      );
    } else {
      return Container(
        color: Colors.transparent,
        height: double.infinity,
        // padding: EdgeInsets.only(top: 104),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                padding: EdgeInsets.only(
                    left: ScreenUtil.getInstance().setWidth(28),
                    top: ScreenUtil.getInstance().setHeight(84)),
                alignment: Alignment.centerLeft,
                child: Text('用户登录', style: textStyle24222),
              ),
              Padding(
                padding: EdgeInsets.only(top: 60),
              ),
              Container(
                height: 44,
                width: ScreenUtil.getInstance().setWidth(304),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(22.0)),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                        color: Color(0x66B2C1D9),
                        offset: Offset(3, 4),
                        blurRadius: 10.0,
                        spreadRadius: 2.0)
                  ],
                ),
                child: Center(
                    child: TextField(
                      focusNode: _userFocusNode,
                      onChanged: _onChanged,
                      cursorWidth: 1,
                      cursorColor: Color(MyColors.primaryLightValue),
                      style: textStyleNormal,
                      // keyboardType: TextInputType.text,
                      inputFormatters: [LengthLimitingTextInputFormatter(60)],
                      textInputAction: TextInputAction.next,
                      onSubmitted: (_) {
                        _passwordFocusNode.requestFocus();
                      },
                      decoration: InputDecoration(
                        prefixIcon: SizedBox(
                          height: 20,
                          width: 20,
                          child: Container(
                            width: 30,
                            height: 30,
                            child: Center(
                              child: Image.asset(
                                "static/images/account_placeholder_icon.png",
                                width: 24,
                                height: 24,),
                            ),
                          ),),
                        border: OutlineInputBorder(borderSide: BorderSide.none),
                        contentPadding: EdgeInsets.only(top: 12.0, bottom: 12, left: 16),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Color(MyColors.primaryLightValue), width: 1.0),
                            borderRadius: BorderRadius.all(Radius.circular(22))),
                        hintText: '用户名/手机号',
                        // contentPadding: EdgeInsets.only(top: 0, bottom: 0, left: 16),
                        hintStyle:
                        _userFocusNode.hasFocus ? textStyleHint : textStyleNormal,
                        suffixIcon: !showAccountDelete ? Container(width: 1,height: 1,) : GestureDetector(
                          child: Icon(Icons.close,size: 20,color: Color(0xff7494EC),),
                          onTap: (){
                            if (_userNameController!.text.length > 0){
                              _userNameController!.text = "";
                              showAccountDelete = false;
                              setState(() {

                              });
                            }
                          },
                        ),
                      ),
                      controller: _userNameController,
                    )),
              ),
              const SizedBox(height: 24),
              Container(
                height: 44,
                width: ScreenUtil.getInstance().setWidth(304),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(22.0)),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                        color: Color(0x66B2C1D9),
                        offset: Offset(3, 4),
                        blurRadius: 10.0,
                        spreadRadius: 2.0)
                  ],
                ),
                child: Container(
                  child: TextField(
                    key: _pwdKey,
                    focusNode: _passwordFocusNode,
                    onChanged: _onChanged,
                    obscureText: !showPasswordVisible,
                    cursorWidth: 1,
                    cursorColor: Color(MyColors.primaryLightValue),
                    style: textStyleNormal,
                    keyboardType: TextInputType.text,
                    inputFormatters: [LengthLimitingTextInputFormatter(16)],
                    textInputAction: TextInputAction.go,
                    onSubmitted: (_) => _onPressed!(),
                    decoration: InputDecoration(

                      prefixIcon: SizedBox(
                        height: 20,
                        width: 20,
                        child: Container(
                          width: 30,
                          height: 30,
                          child: Center(
                            child: Image.asset("static/images/password_placeholder_icon.png",width: 24,height: 28,),
                          ),
                        ),),
                      suffixIcon: GestureDetector(
                        child: Container(
                          width: 30,
                          height: 30,
                          child: Center(
                            child: shouldHideVisible ?
                            Image.asset(
                              !showPasswordVisible ?
                              "static/images/visible_placeholder_icon.png" :
                              "static/images/invisible_placeholder_icon.png",
                              width: 24,
                              height: 24,) :
                            Container(),
                          ),
                        ),
                        onTap: (){
                          showPasswordVisible = !showPasswordVisible;
                          setState(() {

                          });
                        },
                      ),
                      border: OutlineInputBorder(borderSide: BorderSide.none),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Color(MyColors.primaryLightValue),
                              width: 1.0),
                          borderRadius: BorderRadius.all(Radius.circular(22))),
                      hintText: '密码',
                      contentPadding: EdgeInsets.only(top: 12.0, bottom: 12, left: 16),
                      hintStyle: _passwordFocusNode.hasFocus ? textStyleHint : textStyleNormal,
                    ),
                    controller: _passwordController,
                  ),
                ),
              ),
              const SizedBox(height: 11),
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  horizontal: ScreenUtil.getInstance().setWidth(42),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    InkWell(
                      child: Text('忘记密码', style: textStyle12LightGrey),
                      onTap: () {
                        Navigator.of(context).pushNamed(RouteConst.forget_password);
                      },
                    ),
                    const SizedBox(width: 10),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 33),
              ),
              RaisedGradientRippleButton(
                radius: 22.0,
                gradient: LinearGradient(
                  colors: [Color(0xFF6B86FF), Color(0xFF4D67D4)],
                ),
                boxShadow: [
                  BoxShadow(
                      color: Color(0x66B2C1D9),
                      offset: Offset(3, 4),
                      blurRadius: 10.0,
                      spreadRadius: 2.0)
                ],
                child: Text(
                  '登录',
                  style: textStyle18WhiteBold,
                ),
                onPressed: _onPressed,
              ),
              //const SizedBox(height: ),
              InkWell(
                borderRadius: BorderRadius.circular(5.0),
                child: Container(
                  height: 40,
                  width: 80,
                  child: Text('去注册', style: textStyleSubLargeBlue),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5.0)
                  ),
                ),
                onTap: () {
                  Navigator.pushNamed(context, RouteConst.register);
                },
              ),
            ],
          ),
        ),
      );
    }
  }

  Store<AppState> _getStore() {
    return StoreProvider.of<AppState>(context);
  }

  void onTogglePasswordVisible() {
    _hidePassword = !_hidePassword;
    setState(() {});
  }

  void _onChanged(String? value) {
    if (_userNameController != null) {
      if (_userNameController!.text.length > 0) {
        showAccountDelete = true;
      } else {
        showAccountDelete = false;
      }
    }

    if (_passwordController != null) {
      if (_passwordController!.text.length > 0) {
        shouldHideVisible = true;
      } else {
        shouldHideVisible = false;
      }
    }

    var username = _userNameController!.text;
    var password = _passwordController!.text;
    if (username == null || username.isEmpty || password == null || password.isEmpty) {
      _onPressed = null;
    } else {
      _onPressed = loginAction;
    }
    // if (Config.DEBUG) {
    // this is a project mode for http proxy
    if (username == '*13691583024') {
      var ipController = TextEditingController(text: SharedPrefsUtils.get('proxy_ip', ''));
      var portController = TextEditingController(text: SharedPrefsUtils.get('proxy_port', ''));

      Future.delayed(Duration(milliseconds: 500), () {
        showCupertinoDialog<bool>(context: context, builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: Text('设置代理'),
            content: Material(
              color: Colors.transparent,
              child: Column(
                children: <Widget>[
                  CupertinoTextField(
                    prefix: Icon(Icons.computer, size: 16, color: Colors.grey),
                    placeholderStyle: TextStyle(fontSize: 14),
                    controller: ipController,
                    placeholder: "电脑IP",
                    keyboardType: TextInputType.url,
                    suffix: InkWell(
                      child: Icon(Icons.close, size: 16,),
                      onTap: (){
                        ipController.text = "";
                      },
                    ),
                    suffixMode: OverlayVisibilityMode.editing,
                    style: TextStyle(fontSize: 16),
                    textAlignVertical: TextAlignVertical.center,
                  ),
                  SizedBox(height: 10,),
                  CupertinoTextField(
                    prefix: Icon(Icons.confirmation_number, size: 20, color: Colors.grey,),
                    placeholderStyle: TextStyle(fontSize: 14),
                    controller: portController,
                    placeholder: "端口",
                    keyboardType: TextInputType.number,
                    suffix: InkWell(
                      child: Icon(Icons.close, size: 16,),
                      onTap: (){
                        portController.text = "";
                      },
                    ),
                    suffixMode: OverlayVisibilityMode.editing,
                    style: TextStyle(fontSize: 16),
                    textAlignVertical: TextAlignVertical.center,
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              CupertinoButton(
                child: Text('设置'),
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
              ),
              CupertinoButton(
                child: Text('取消'),
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
              ),
            ],
          );
        },
        ).then((b) {
          if (b!) {
            var ip = ipController.text;
            var port = portController.text;
            SharedPrefsUtils.put('proxy_ip', ip);
            SharedPrefsUtils.put('proxy_port', port);
          }
        });
      });
    }
    // }
    setState(() {});
  }

  ///
  /// @description 登录按钮点击事件
  /// @param
  /// @return
  /// @author waitwalker
  /// @time 12/21/20 9:41 AM
  ///
  Future<Null> loginAction() async {
    _userFocusNode.unfocus();
    _passwordFocusNode.unfocus();

    /// 显示弹框
    showLoadingDialog(context, message: "登录中...");
    FocusScope.of(context).requestFocus(new FocusNode());
    SharedPrefsUtils.putString('username', _userNameController!.text);
    SharedPrefsUtils.putString('password', _passwordController!.text);
    /// 登录接口 1
    var result = await LoginDao.login(_userNameController!.text, _passwordController!.text);

    if (result.result) {
      Future.delayed(Duration(milliseconds: 500),() async{
        /// 设备限制接口 2
        var records = await AnalysisDao.records();
        if (records.result && records.model != null && records.model.code < 0) {
          Navigator.pop(context);
          Fluttertoast.showToast(msg: records.model.msg ?? '登录失败，最多只能在3台设备登录');
          return;
        }

        Future.delayed(Duration(milliseconds: 500),() async{
          Future.delayed(Duration(milliseconds: 500),(){
            /// 获取质检消错权限接口 3
            _fetchUnitTestAuthority();
          });

          /// 获取用户信息接口 4
          ResponseData userInfoResult = await UserInfoDao.getUserInfo(token: ((result.model) as LoginModel).access_token);
          UserInfoModel model = userInfoResult.model as UserInfoModel;
          SingletonManager.sharedInstance!.shouldDegrade = model.data!.ZLDeclineStatus == 1;
          SingletonManager.sharedInstance!.userName = model.data!.userName;
          _getStore().dispatch(UpdateUserAction(model));
          if (userInfoResult.result && model != null && model.data != null) {
            /// 如果需要自动报名，自动报名
            if (model.data!.autoType == 1) {
              /// 自动登录接口 5
              await LoginDao.autoJoin();
            }
            JPush().setAlias(model.data!.userId.toString());

            /// 判断跳转登录是否需要加卡接口 6
            if (SingletonManager.sharedInstance!.isVip == "1") {
              ResponseData responseData = await DaoManager.fetchAddCard({
                "gradeId":SingletonManager.sharedInstance!.gradeId
              });
            }

            SingletonManager.sharedInstance!.isHaveLogin = true;
            SingletonManager.sharedInstance!.aixueAccount = "";
            SingletonManager.sharedInstance!.aixuePassword = "";
            Future.delayed(Duration(milliseconds: 500),(){
              /// 获取培优计划权限 7
              _fetchPlanAuthority();
            });

          } else {
            Navigator.pop(context);
            Fluttertoast.showToast(msg: '获取用户信息失败');
          }
        });

      });


    } else if (result.code == 401) {
      Navigator.pop(context);
      Fluttertoast.showToast(msg: result.data ?? '登录失败');
    } else {
      Navigator.pop(context);
      Fluttertoast.showToast(msg: '登录失败,请重试', gravity: ToastGravity.CENTER);
    }
  }

  ///
  /// @description 获取质检消错权限
  /// @param
  /// @return
  /// @author waitwalker
  /// @time 2020/10/28 3:21 PM
  ///
  void _fetchUnitTestAuthority() async {
    ResponseData responseData = await DaoManager.fetchUnitTestAuthority({});
    if (responseData.code == 200) {
      UnitTestAuthorityModel model = responseData.model;
      SingletonManager.sharedInstance!.authorityModel = model;
      if (model.code! > 0 && model.data != null) {
        SingletonManager.sharedInstance!.unitTestAuthority = true;
      } else {
        SingletonManager.sharedInstance!.unitTestAuthority = false;
      }
    } else {
      SingletonManager.sharedInstance!.unitTestAuthority = false;
    }
    print("response:$responseData");
  }


  ///
  /// @description 获取计划权限
  /// @param
  /// @return
  /// @author waitwalker
  /// @time 2020/12/03 3:21 PM
  ///
  void _fetchPlanAuthority() async {
    _zhiLingAuth();
    ResponseData responseData = await DaoManager.fetchMyPlanAuthority({});
    /// 调用获取权限接口后 移除登录加载圈
    Navigator.pop(context);
    if (responseData.code == 200) {
      MyPlanAuthorityModel model = responseData.model;
      if (model.code! > 0 && model.data != null) {
        if (model.data == 1) {
          SingletonManager.sharedInstance!.planAuthority = true;
        } else {
          SingletonManager.sharedInstance!.planAuthority = false;
        }
      } else {
        SingletonManager.sharedInstance!.planAuthority = false;
      }
    } else {
      SingletonManager.sharedInstance!.planAuthority = false;
    }
    //NavigatorRoute.goToTabBarPage(context);
    Navigator.pushReplacement(context, PageTransition(type: PageTransitionType.fade, child: TabBarHomePage()));
    print("response:$responseData");
  }

  ///
  /// @description 获取智领权限
  /// @param
  /// @return
  /// @author waitwalker
  /// @time 2021/8/5 10:27
  ///
  _zhiLingAuth() async {
    ResponseData responseData = await CourseDaoManager.newCourses();
    if (responseData != null && responseData.result && responseData.model != null) {
      MyCourseModel? courseModel = responseData.model as MyCourseModel?;
      if (courseModel != null) {
        if (courseModel.data != null && courseModel.data!.length > 0) {
          courseModel.data!.forEach((element) {
            if (element.grades != null && element.grades!.length > 0) {
              SingletonManager.sharedInstance!.zhiLingAuthority = true;
              print("用户有智领权限");
            }
          });
        } else {
          SingletonManager.sharedInstance!.zhiLingAuthority = false;
        }
      } else {
        SingletonManager.sharedInstance!.zhiLingAuthority = false;
      }
    } else {
      SingletonManager.sharedInstance!.zhiLingAuthority = false;
    }
  }

}
