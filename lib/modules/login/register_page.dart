import 'dart:async';
import 'dart:convert';
import 'package:lpinyin/lpinyin.dart';
import 'package:my_gallery/common/const/router_const.dart';
import 'package:my_gallery/common/dao/manager/dao_manager.dart';
import 'package:my_gallery/common/dao/original_dao/register_dao.dart';
import 'package:my_gallery/common/dao/original_dao/sms_dao.dart';
import 'package:my_gallery/common/network/response.dart';
import 'package:my_gallery/model/base_model.dart';
import 'package:my_gallery/modules/widgets/sms_code/sms_code_widget.dart';
import 'package:my_gallery/modules/widgets/style/style.dart';
import 'package:my_gallery/modules/widgets/button/radio_button.dart';
import 'package:my_gallery/modules/widgets/button/rounded_gradient_ripple_button.dart';
import 'package:my_gallery/common/logger/logger.dart';
import 'package:my_gallery/common/tools/screen_adapt/screen_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../widgets/webviews/common_webview_page.dart';
import 'package:flutter/cupertino.dart';
import 'city_pickers/modal/result.dart';
import 'city_pickers/src/city_picker.dart';
import 'city_pickers/src/show_types.dart';

///
/// @name RegisterPage
/// @description 注册页面
/// @author waitwalker
/// @date 2020-01-10
///
class RegisterPage extends StatefulWidget {
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  TextEditingController? _mobileController;
  TextEditingController? _smsController;
  TextEditingController? _passwordController;
  TextEditingController? _regionController;

  Future<Null> Function()? _onPressed;
  bool? agree;

  bool _hidePassword = true;
  FocusNode _userFocusNode = FocusNode();
  FocusNode _passwordFocusNode = FocusNode();
  FocusNode _smsCodeFocusNode = FocusNode();

  FocusNode _cityFocusNode = FocusNode();

  bool showAccountDelete = false; ///删除是否可见
  bool showPasswordVisible = false; ///控制密码明文密文
  bool shouldHideVisible = true; ///密码明文密文按钮是否可见

  Result resultAttr = Result();
  Result result = Result();
  PickerItem showTypeAttr = PickerItem(name: '省+市+区(县)', value: ShowType.pca);

  Map<String, String?> provincesData = {};
  Map<String, dynamic> citiesData = {};

  String? provinceName = "";
  String? cityName = "";
  String? areaName = "";
  String? regionId = "";

  @override
  void initState() {

    // 需要的时候再请求
    //fetchRegionData();

    _mobileController = TextEditingController();
    _smsController = TextEditingController();
    _passwordController = TextEditingController();
    _regionController = TextEditingController();
    _onChanged(null);
    agree = false;

    _userFocusNode.addListener(() {
      if (!_userFocusNode.hasFocus) {
        showAccountDelete = false;
      } else {
        if (_mobileController!.text.length > 0) {
          showAccountDelete = true;
        }
      }
      setState(() {});
    });
    _passwordFocusNode.addListener(() {
      if (!_passwordFocusNode.hasFocus) {
        shouldHideVisible = false;
      } else {
        if (_passwordController!.text.length > 0) {
          shouldHideVisible = true;
        }
      }
      setState(() {});
    });
    _smsCodeFocusNode.addListener(() {
      debugLog('${_smsCodeFocusNode.hasFocus}');
      setState(() {});
    });

    super.initState();
  }

  fetchRegionData() async {
    ResponseData responseData = await DaoManager.fetchRegionData({});

    Map data = responseData.data;

    List dataList = data["data"];

    // 省份id对应的城市列表
    Map<String, dynamic> provinceIdWithCities = {};

    // 城市id对应的地区列表
    Map<String, dynamic> cityIdWithRegions = {};
    for(int i = 0; i < dataList.length; i++) {
      Map map = dataList[i];
      var provinceId = map["provinceId"];
      var provinceName = map["provinceName"];

      // 构造省级数据
      provincesData["$provinceId"] = provinceName;

      List? cities = map["cities"];
      Map cityZu = {};
      if (cities != null && cities.length > 0) {
        for(int j = 0; j < cities.length; j++) {
          Map theMap = cities[j];
          var cityId = theMap["cityId"];
          var cityName = theMap["cityName"];
          List? regions = theMap["regions"];
          cityZu["$cityId"] = {
            "name" : cityName,
            "alpha" : PinyinHelper.getFirstWordPinyin(cityName).substring(0, 1)
          };

          print("组装好的城市列表:$cityZu");

          Map regionZu = {};
          if (regions == null || regions.length == 0) {
            regionZu["66666"] = {
              "name" : "暂无",
              "alpha" : PinyinHelper.getFirstWordPinyin("暂无").substring(0, 1)};
            cityIdWithRegions["$cityId"] = regionZu;
            print("城市下面没有地区情况:$cityIdWithRegions");
          } else {
            for (int q = 0; q < regions.length; q++) {
              Map regionMap = regions[q];
              var regionId = regionMap["regionId"];
              var regionName = regionMap["regionName"];
              regionZu["$regionId"] = {
                "name" : regionName,
                "alpha" : PinyinHelper.getFirstWordPinyin(regionName).substring(0, 1)
              };
            }
            cityIdWithRegions["$cityId"] = regionZu;
          }

          print("城市id对应的地区列表:$cityIdWithRegions");
        }
        provinceIdWithCities["$provinceId"] = cityZu;

      } else {
        cityZu["666666"] = {
          "name" : "暂无",
          "alpha" : PinyinHelper.getFirstWordPinyin("暂无").substring(0, 1)
        };
        provinceIdWithCities["$provinceId"] = cityZu;
      }
    }


    print("省份id对应的城市列表:$provinceIdWithCities");
    print("城市id对应的地区列表:$cityIdWithRegions");
    provinceIdWithCities.addAll(cityIdWithRegions);

    print("省级数据:$provincesData");
    print("城市数据:$provinceIdWithCities");
    print("citiesData:$citiesData");
    citiesData = provinceIdWithCities;

    print("citiesData:$citiesData");
    String encodeProvinceData = jsonEncode(provincesData);
    String encodeCityData = jsonEncode(provinceIdWithCities);
    print("encode后的省级数据:$encodeProvinceData");
    print("encode后的城市数据:$encodeCityData");

    setState(() {

    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      color: Colors.red,
      child: _build(context),
    );
  }

  Widget _build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        _userFocusNode.unfocus();
        _passwordFocusNode.unfocus();
        _smsCodeFocusNode.unfocus();
      },
      child: Scaffold(
        body: Stack(
          alignment: Alignment.centerRight,
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
            _buildBody(context),
            Positioned(
              left: 30,
              top: 39,
              child: InkWell(
                child: Icon(Icons.arrow_back, color: Color(0xFF989797)),
                onTap: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  getItemBuilder() {
    return (item, list, index) {
      return Center(
          child: Text(item, maxLines: 1, style: TextStyle(fontSize: 15)));
    };
  }

  Widget _buildBody(BuildContext context) {
    return Container(
      color: Colors.transparent,
      height: double.infinity,
      // padding: EdgeInsets.all(32.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(
                  left: ScreenUtil.getInstance().setWidth(28),
                  top: ScreenUtil.getInstance().setHeight(84)),
              alignment: Alignment.centerLeft,
              child: Text('注册', style: textStyle24222),
            ),
            Padding(padding: EdgeInsets.only(top: 50),),
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
                  focusNode: _userFocusNode,
                  onChanged: _onChanged,
                  cursorWidth: 1,
                  cursorColor: Color(MyColors.primaryLightValue),
                  style: textStyleNormal,
                  keyboardType: TextInputType.numberWithOptions(),
                  inputFormatters: [LengthLimitingTextInputFormatter(11)],
                  textInputAction: TextInputAction.next,
                  onSubmitted: (_) {
                    _smsCodeFocusNode.requestFocus();
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
                    suffixIcon: !showAccountDelete ? Container(width: 1,height: 1,) :
                    GestureDetector(
                      child: Icon(Icons.close,size: 20,color: Color(0xff7494EC),),
                      onTap: (){
                        if (_mobileController!.text.length > 0){
                          _mobileController!.text = "";
                          showAccountDelete = false;
                          setState(() {

                          });
                        }
                      },
                    ),
                    border: OutlineInputBorder(borderSide: BorderSide.none),
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Color(MyColors.primaryLightValue),
                            width: 1.0),
                        borderRadius: BorderRadius.all(Radius.circular(22))),
                    hintText: '输入手机号',
                    contentPadding: EdgeInsets.only(top: 12.0, bottom: 12, left: 16),
                    hintStyle: _userFocusNode.hasFocus
                        ? textStyleHint
                        : textStyleNormal,
                  ),
                  controller: _mobileController,
                ),
              ),
            ),
            Padding(padding: EdgeInsets.only(top: 22)),
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
                    spreadRadius: 2.0,)],
              ),
              child: Container(
                child: SmsCodeWidget(
                  controller: _smsController,
                  focusNode: _smsCodeFocusNode,
                  labelText: '输入验证码',
                  normalStr: '获取验证码',
                  countdownStr: '重新获取',
                  hintStyle: textStyleNormal,
                  hintStyleFocused: textStyleHint,
                  normalStyle: textStyleHint,
                  countdownStyle: textStyleHint,
                  onChanged: _onChanged,
                  onRequest: _requestSms,
                  hideDecoration: false,
                  textInputAction: TextInputAction.next,
                  onSubmitted: (_) {
                    _passwordFocusNode.requestFocus();
                  },
                ),
              ),
            ),
            Padding(padding: EdgeInsets.only(top: 22)),
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
                  obscureText: !showPasswordVisible,
                  onChanged: _onChanged,
                  focusNode: _passwordFocusNode,
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
                          child: Image.asset(
                            "static/images/password_placeholder_icon.png",
                            width: 24,
                            height: 24,),
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
                    hintText: '输入密码',
                    contentPadding:
                    const EdgeInsets.only(top: 12.0, bottom: 12, left: 16),
                    hintStyle: _passwordFocusNode.hasFocus
                        ? textStyleHint
                        : textStyleNormal,
                  ),
                  controller: _passwordController,
                ),
              ),
            ),

            // 选择城市
            Padding(padding: EdgeInsets.only(top: 22)),
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
                    spreadRadius: 2.0,)
                ],
              ),
              child: Container(
                child: TextField(
                  enableInteractiveSelection: false,
                  onChanged: _onChanged,
                  onTap: () async {
                    FocusScope.of(context).requestFocus(FocusNode());
                    print("locationCode $resultAttr");
                    Result? tempResult = await CityPickers.showCityPicker(
                        context: context,
                        locationCode: resultAttr != null
                            ? resultAttr.areaId ??
                            resultAttr.cityId ??
                            resultAttr.provinceId
                            : null,
                        showType: showTypeAttr.value,
                        isSort: false,
                        barrierOpacity: 0.5,
                        barrierDismissible: true,
                        itemExtent: 44,
                        itemBuilder: this.getItemBuilder());
                    if (tempResult == null) {
                      return;
                    }

                    print("选择的省市结果:$tempResult");

                    provinceName = tempResult.provinceName;
                    cityName = tempResult.cityName;
                    areaName = tempResult.areaName;
                    regionId = tempResult.areaId;
                    String fullLocationString = "$provinceName | $cityName | $areaName";
                    if (regionId == "66666") {
                      regionId = "-1";
                    }

                    this.setState(() {
                      resultAttr = tempResult;
                      _regionController!.text = fullLocationString;
                    });
                  },
                  cursorWidth: 1,
                  cursorColor: Color(MyColors.primaryLightValue),
                  style: textStyleNormal,
                  keyboardType: TextInputType.numberWithOptions(),
                  inputFormatters: [LengthLimitingTextInputFormatter(11)],
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    prefixIcon: SizedBox(height: 20, width: 20,
                      child: Container(
                        width: 30,
                        height: 30,
                        child: Center(
                          child: Image.asset(
                            "static/images/location_placeholder_icon.png",
                            width: 24,
                            height: 24,
                          ),
                        ),
                      ),
                    ),
                    border: OutlineInputBorder(borderSide: BorderSide.none),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Color(MyColors.primaryLightValue),
                        width: 1.0,),
                      borderRadius: BorderRadius.all(Radius.circular(22),
                      ),
                    ),
                    hintText: '请选择所在地区',
                    contentPadding: EdgeInsets.only(top: 12.0, bottom: 12, left: 16),
                    hintStyle: textStyleNormal,
                    suffixIcon: Icon(Icons.arrow_drop_down, size: 30,),
                  ),
                  controller: _regionController,
                ),
              ),
            ),

            Padding(padding: EdgeInsets.only(top: 8),),
            Text("因区域和教材差异，为保证您的学习效果，请务必准确填写。",style: TextStyle(fontSize: 11),),
            Padding(padding: EdgeInsets.only(top: 37),),
            RaisedGradientRippleButton(
              radius: 22.0,
              gradient: LinearGradient(colors: [Color(0xFF6B86FF), Color(0xFF4D67D4)],),
              boxShadow: [
                BoxShadow(
                  color: Color(0x66B2C1D9),
                  offset: Offset(3, 4),
                  blurRadius: 10.0,
                  spreadRadius: 2.0,)],
              child: Text("注册", style: textStyle18WhiteBold,),
              onPressed: _onPressed,
            ),
            Padding(padding: EdgeInsets.only(top: 12),),
            Container(
              width: 176,
              child: Row(
                children: <Widget>[
                  MyRadio(
                    checked: agree,
                    label: '',
                    onTap: () {
                      agree = !agree!;
                      setState(() {});
                    },
                  ),
                  InkWell(
                    child: Text('阅读并同意用户服务协议', style: textStyleSub),
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          fullscreenDialog: true,
                          builder: (BuildContext context) {
                            return CommonWebviewPage(
                                initialUrl: 'https://www.etiantian.com/about/mobile/servandpriv.html',
                                title: '用户协议');
                          }));
                    },
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  void _onChanged(String? value) {
    if (_mobileController != null) {
      if (_mobileController!.text.length > 0) {
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

    var username = _mobileController!.text;
    if (username == null || username.isEmpty) {
      _onPressed = null;
    } else {
      _onPressed = onPressed;
    }
    setState(() {});
  }

  Future<Null> onPressed() async {
    _userFocusNode.unfocus();
    _passwordFocusNode.unfocus();
    _smsCodeFocusNode.unfocus();
    _mobileController!.text.isEmpty
        ? toast('手机号不能为空')
        : !RegExp(r"^1\d{10}$").hasMatch(_mobileController!.text)
        ? toast('手机号格式不正确')
        : _smsController!.text.isEmpty
        ? toast('验证码不能为空')
        : _regionController!.text.isEmpty
        ? toast('所在地区不能为空')
        : !agree!
        ? toast('请先阅读并同意用户服务协议')
        : checkPassword(_passwordController!.text, doRegister);
  }

  Future doRegister() async {
    if (regionId == "66666") regionId = "";
    var register = await RegisterDao.register(_mobileController!.value.text,
        _smsController!.value.text,
        _passwordController!.value.text,
        provinceName,
        cityName,
        regionId);
    var model = register.model as BaseModel?;
    if (register.result && model!.code == 1) {
      Navigator.pushNamed(context, RouteConst.login);
      Fluttertoast.showToast(msg: register.model.msg);
    } else {
      toast(model!.msg);
    }
  }

  toast(msg) {
    Fluttertoast.showToast(msg: msg, gravity: ToastGravity.CENTER);
  }

  checkPassword(String pwd, Function callback) {
    pwd.isEmpty
        ? toast('密码不能为空')
        : pwd.length < 6
        ? toast('密码不能小于6个字符')
        : pwd.length > 16
        ? toast('密码不能超过16个字符')
        : RegExp('^\\d+\$').hasMatch(pwd)
        ? toast('密码不能全是数字')
        : !RegExp('[0-9a-zA-Z_]{6,16}').hasMatch(pwd)
        ? toast('密码只能由字母、数字和下划线组成，长度6~16位')
        : callback();
  }

  Future<bool> _requestSms(params) async {
    bool malformed = !RegExp(r"^1\d{10}$").hasMatch(_mobileController!.text);
    if (malformed) {
      toast('手机号格式不正确');
      return false;
    }
    var sms = await SmsDao.getSms(_mobileController!.value.text,
        smsType: SmsType.register);
    var success = sms?.result ?? false;
    toast(sms.model.msg);
    return success;
  }

  void onTogglePasswordVisible() {
    _hidePassword = !_hidePassword;
    setState(() {});
  }
}



const double _pickerHeight = 200.0;

class PickerItem {
  String? name;
  dynamic value;

  PickerItem({this.name, this.value});
}

class Picker extends StatefulWidget {
  final List<PickerItem> items;
  final Widget target;
  final ValueChanged<PickerItem?>? onConfirm;

  Picker({this.onConfirm, required this.target, required this.items});

  @override
  _PickerState createState() => _PickerState();
}

class _PickerState extends State<Picker> {
  ScrollController scrollController =
  FixedExtentScrollController(initialItem: 0);
  PickerItem? result;

  @override
  void initState() {
    result = widget.items[0];
    super.initState();
  }

  onChange(int index) {
    this.setState(() {
      result = widget.items[index];
    });
  }

  buildPicker() {
    return CupertinoPicker.builder(
        magnification: 1.0,
        scrollController: scrollController as FixedExtentScrollController?,
        itemExtent: 40.0,
        backgroundColor: Colors.white,
        onSelectedItemChanged: onChange,
        itemBuilder: (context, index) {
          return Center(
            child: Text(
              '${widget.items[index].name}',
              maxLines: 1,
              overflow: TextOverflow.fade,
              textAlign: TextAlign.center,
            ),
          );
        },
        childCount: widget.items.length);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.white,
        padding: const EdgeInsets.all(6.0),
        alignment: Alignment.center,
        child: GestureDetector(
          onTap: () async {
            await showCupertinoModalPopup<void>(
              context: context,
              builder: (BuildContext context) {
                return Container(
                  height: _pickerHeight,
                  padding: const EdgeInsets.only(top: 6.0),
                  color: CupertinoColors.white,
                  child: DefaultTextStyle(
                      style: const TextStyle(
                        color: CupertinoColors.black,
                        fontSize: 22.0,
                      ),
                      child: Column(
                        children: <Widget>[
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text(
                                  'cancle',
                                  style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop(result);
                                },
                                child: Text(
                                  'confirm',
                                  style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Container(
                            height: _pickerHeight - 100,
                            child: buildPicker(),
                          )
                        ],
                      )),
                );
              },
            );
            widget.onConfirm!(result);
          },
          child: widget.target,
        ));
  }
}

