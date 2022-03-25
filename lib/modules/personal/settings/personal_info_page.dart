import 'dart:io';
import 'package:my_gallery/common/dao/original_dao/avatar_upload_dao.dart';
import 'package:my_gallery/common/dao/original_dao/user_info_dao.dart';
import 'package:my_gallery/common/locale/localizations.dart';
import 'package:my_gallery/model/base_model.dart';
import 'package:my_gallery/model/upload_avatar_model.dart';
import 'package:my_gallery/common/redux/app_state.dart';
import 'package:my_gallery/common/redux/user_reducer.dart';
import 'package:my_gallery/modules/widgets/style/style.dart';
import 'package:my_gallery/modules/widgets/button/radio_button.dart';
import 'package:my_gallery/modules/widgets/row/setting_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:redux/redux.dart';


///
/// @name PersonalInfoPage
/// @description 个人信息页面
/// @author waitwalker
/// @date 2020-01-11
///
class PersonalInfoPage extends StatefulWidget {
  @override
  _PersonalInfoPageState createState() => _PersonalInfoPageState();
}

class _PersonalInfoPageState extends State<PersonalInfoPage> {
  // final cropKey = GlobalKey<CropState>();
  File? _sample;
  File? _lastCropped;

  late bool editable;

  var _sex;
  var _realName;
  var _userName;
  var _oldUserName;

  var _birthday;
  var _address;
  var _email;

  TextEditingController _addressController = TextEditingController();
  TextEditingController _emailController = TextEditingController();

  @override
  void initState() {
    editable = false;
    super.initState();
  }

  @override
  void didChangeDependencies() {
    var data = _getStore().state.userInfo!.data!;
    _sex = data.sex;
    _realName = data.realName;
    _userName = data.userName;
    _oldUserName = data.realName;

    _birthday = data.birthday!.split(' ').first;
    _address = data.address;
    _email = data.email;

    super.didChangeDependencies();
  }

  @override
  void dispose() {
    super.dispose();
    // _file?.delete();
    _sample?.delete();
    _lastCropped?.delete();
  }

  @override
  Widget build(BuildContext context) {
    return StoreBuilder(builder: (BuildContext context, Store<AppState> store) {
      return _buildPage(store);
    });
  }

  Widget _buildPage(Store<AppState> store) {
    var data = store.state.userInfo!.data;

    return Scaffold(
      backgroundColor: Color(MyColors.background),
        appBar: AppBar(
          elevation: 1.0,
          title: Text(MTTLocalization.of(context)!.currentLocalized!.personalInfoPageNavigatorTitle!),
          backgroundColor: Colors.white,
          centerTitle: Platform.isIOS ? true : false,
          actions: <Widget>[
            Center(
              child: InkWell(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(editable ? MTTLocalization.of(context)!.currentLocalized!.personalInfoPageSave! : MTTLocalization.of(context)!.currentLocalized!.personalInfoPageEdit!, style: textStyleNormal),
                ),
                onTap: () async {
                  await _doSave(_realName, _oldUserName, _address, _email,
                      _birthday, _sex);
                },
              ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Stack(children: <Widget>[
            Column(
              children: <Widget>[
                Divider(height: 0.5, color: Colors.black12),
                Container(
                  color: Color(MyColors.background),
                  width: double.infinity,
                  child: InkWell(
                    child: Column(
                      children: <Widget>[
                        Padding(padding: EdgeInsets.only(top: 15)),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: Colors.black12, width: 1), // 边色与边宽度
                            shape: BoxShape.circle, // 圆形，使用圆形时不可以使用borderRadius
                          ),
                          child: ClipOval(
                            child: _lastCropped == null
                                ? Image.network(
                                    data!.userPhoto!,
                                    width: 96,
                                    height: 96,
                                    fit: BoxFit.cover,
                                  )
                                : Image.file(
                                    _lastCropped!,
                                    width: 96,
                                    height: 96,
                                    fit: BoxFit.cover,
                                  ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 8, bottom: 15),
                          child: Text(editable ? MTTLocalization.of(context)!.currentLocalized!.personalInfoPageEditAvatar! : '',
                              style: textStyleTabUnselected),
                        ),
                      ],
                    ),
                    onTap: () {
                      if (editable) {
                        _openImage();
                      }
                    },
                  ),
                ),
                Divider(height: 10.0, color: Colors.black12),
                SettingRow(
                  MTTLocalization.of(context)!.currentLocalized!.personalInfoPageUserId,
                  subText: data?.userId.toString(),
                ),
                Divider(height: 0.5, color: Colors.black12),
                SettingRow(MTTLocalization.of(context)!.currentLocalized!.personaInfoPageUserName, subText: _userName, onPress: null),
                Divider(height: 0.5, color: Colors.black12),
                SettingRow(
                  MTTLocalization.of(context)!.currentLocalized!.personalInfoPageGender,
                  subWidget: editable
                      ? Container(
                          padding: EdgeInsets.only(left: 14),
                          child: Row(
                            children: <Widget>[
                              MyRadio(
                                  label: MTTLocalization.of(context)!.currentLocalized!.personalInfoPageMale,
                                  labelStyle: textStyleTabUnselected,
                                  onTap: () {
                                    _sex = getSexValue(Sex.MALE);
                                    setState(() {});
                                  },
                                  checked: _sex == getSexValue(Sex.MALE)),
                              Padding(padding: EdgeInsets.only(left: 20)),
                              MyRadio(
                                  label: MTTLocalization.of(context)!.currentLocalized!.personalInfoPageFemale,
                                  labelStyle: textStyleTabUnselected,
                                  onTap: () {
                                    _sex = getSexValue(Sex.FEMALE);
                                    setState(() {});
                                  },
                                  checked: _sex == getSexValue(Sex.FEMALE)),
                            ],
                          ),
                        )
                      : null,
                  subText: editable
                      ? null
                      : data?.sex == 2 ? '女' : data?.sex == 1 ? '男' : '未填',
                ),
                Divider(height: 0.5, color: Colors.black12),
                SettingRow(
                  MTTLocalization.of(context)!.currentLocalized!.personalInfoPageBirthday,
                  subText: _birthday,
                  onPress: !editable
                      ? null
                      : () {
                          DatePicker.showDatePicker(
                            context,
                            currentTime: DateTime.parse(_birthday),
                            showTitleActions: true,
                            minTime: DateTime(1970, 1, 1),
                            locale: LocaleType.zh,
                            maxTime: DateTime.now(),
                            onChanged: (date) {
                              _birthday = DateFormat('yyyy-MM-dd').format(date);

                              setState(() {});
                            },
                            onConfirm: (date) {
                              _birthday = DateFormat('yyyy-MM-dd').format(date);

                              setState(() {});
                            },
                          );
                        },
                ),
                Divider(height: 0.5, color: Colors.black12),
                SettingRow(
                  MTTLocalization.of(context)!.currentLocalized!.personalInfoPageAddress,
                  subText: _address,
                  onPress: !editable
                      ? null
                      : () {
                          showDialog<String>(
                            context: context,
                            barrierDismissible: false,
                            builder: (BuildContext context) {
                              _addressController.text = _address;
                              return AlertDialog(
                                title: Text('地址'),
                                content: SingleChildScrollView(
                                  child: TextField(
                                    controller: _addressController,
                                  ),
                                ),
                                actions: <Widget>[
                                  TextButton(
                                    child: Text('确定'),
                                    onPressed: () {
                                      Navigator.of(context)
                                          .pop(_addressController.text);
                                    },
                                  ),
                                ],
                              );
                            },
                          ).then((val) {
                            var match = val!.length <= 200;
                            if (match) {
                              _address = val;
                              setState(() {});
                            } else {
                              showDialog<String>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                        title: Text('提示'),
                                        content: Text('住址长度不能超过200'),
                                      ));
                            }
                          });
                        },
                ),
                Divider(height: 0.5, color: Colors.black12),
                SettingRow(
                  MTTLocalization.of(context)!.currentLocalized!.personalInfoPageEmail,
                  subText: _email,
                  onPress: !editable
                      ? null
                      : () {
                          showDialog<String>(
                            context: context,
                            barrierDismissible: false,
                            builder: (BuildContext context) {
                              _emailController.text = _email;
                              return AlertDialog(
                                title: Text('邮箱'),
                                content: SingleChildScrollView(
                                  child: TextField(
                                    controller: _emailController,
                                  ),
                                ),
                                actions: <Widget>[
                                  TextButton(
                                    child: Text('确定'),
                                    onPressed: () {
                                      Navigator.of(context)
                                          .pop(_emailController.text);
                                    },
                                  ),
                                ],
                              );
                            },
                          ).then((val) {
                            var match = RegExp('.+?@.+?\..+').hasMatch(val!);
                            if (match) {
                              _email = val;
                              setState(() {});
                            } else {
                              showDialog<String>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                        title: Text('提示'),
                                        content: Text(
                                            '邮箱地址错误，正确格式示例：wangxiao@163.com'),
                                      ));
                            }
                          });
                        },
                ),
              ],
            ),
          ]),
        ));
    // : _buildCroppingImage();
  }

  Store<AppState> _getStore() {
    return StoreProvider.of(context);
  }

  toast(String msg) {
    Fluttertoast.showToast(msg: msg);
  }

  Future _doSave(String? _realName, String? _oldUserName, String? _address,
      String? _email, String? _birthday, Object? _sex) async {
    AppState state = _getStore().state;
    if (editable) {
      var setUserInfo = await UserInfoDao.setUserInfo(
          state.userInfo!.data!.userId.toString(),
          realName: _realName == _oldUserName ? null : _realName,
          address: _address,
          email: _email,
          birthday: _birthday,
          sex: _sex);
      var model = setUserInfo?.model as BaseModel?;
      if (setUserInfo.result && model != null && model.code == 1) {
        editable = !editable;
        _updateLocalUserInfo(
            email: _email,
            realName: _realName,
            sex: _sex as num?,
            address: _address,
            birthday: _birthday);
        setState(() {});
      } else {
        Fluttertoast.showToast(msg: model?.msg ?? '保存失败');
      }
    } else {
      editable = !editable;

      setState(() {});
    }
  }

  Future<void> _openImage() async {
    final picker = ImagePicker();

    final file = await picker.getImage(source: ImageSource.gallery);
    if (file != null) {
      File imageFile = File(file.path);
      final sample = await _cropImage(imageFile);

      var store = StoreProvider.of<AppState>(context);
      var userInfo = store.state.userInfo!;
      var uploadResult = await AvatarUploadDao.upload(
          userInfo.data!.userId.toString(), /*type_student*/ '3', imageFile);
      var model = uploadResult.model as UploadAvatarModel?;
      if (uploadResult.result && model != null && model.result == 1) {
        Fluttertoast.showToast(msg: '头像保存成功');
        userInfo.data!.userPhoto = model.data?.userPhoto;
        StoreProvider.of<AppState>(context).dispatch(UpdateUserAction(userInfo));
      } else {
        _lastCropped = null;
        setState(() {});
        Fluttertoast.showToast(msg: model!.msg!);

        setState(() {
          _sample = sample;
        });
      }
    }
  }

  _cropImage(File imageFile) async {
    File? croppedFile = await ImageCropper().cropImage(
      sourcePath: imageFile.path,
      aspectRatio: CropAspectRatio(ratioX: 1.0, ratioY: 1.0),
      maxWidth: 512,
      maxHeight: 512,
    );
    return croppedFile;
  }

  void _updateLocalUserInfo(
      {String? email,
      String? realName,
      num? sex,
      String? address,
      String? birthday}) {
    var store = StoreProvider.of<AppState>(context);
    var userInfo = store.state.userInfo!;
    userInfo.data!.email = email;
    userInfo.data!.realName = realName;
    userInfo.data!.sex = sex;
    userInfo.data!.address = address;
    userInfo.data!.birthday = birthday;
    StoreProvider.of<AppState>(context).dispatch(UpdateUserAction(userInfo));
  }
}

enum Sex { MALE, FEMALE, UNKNOWN }

getSexValue(Sex sex) {
  switch (sex) {
    case Sex.MALE:
      return 1;
    case Sex.FEMALE:
      return 2;
    default:
      return -1;
  }
}
