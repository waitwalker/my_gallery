import 'package:my_gallery/common/dao/original_dao/card_dao.dart';
import 'package:my_gallery/common/dao/original_dao/user_info_dao.dart';
import 'package:my_gallery/common/singleton/singleton_manager.dart';
import 'package:my_gallery/model/activate_model.dart';
import 'package:my_gallery/model/base_model.dart';
import 'package:my_gallery/model/card_list_model.dart';
import 'package:my_gallery/common/redux/app_state.dart';
import 'package:my_gallery/modules/personal/activate_card/activate_success_page.dart';
import 'package:my_gallery/modules/personal/activate_card/choose_card_page.dart';
import 'package:my_gallery/modules/widgets/style/style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:redux/redux.dart';
import 'package:rxdart/rxdart.dart';


///
/// @name ActivateCardStatePage
/// @description 激活卡 state=1
/// @author waitwalker
/// @date 2020-01-11
///
class ActivateCardStatePage extends StatefulWidget {

  @override
  _ActivateCardStatePageState createState() => _ActivateCardStatePageState();
}

class _ActivateCardStatePageState extends State<ActivateCardStatePage> {
  TextEditingController? _cardPasswordController;
  TextEditingController? _cardNumberController;
  TextEditingController? _nameController;
  TextEditingController? _areaController;
  TextEditingController? _schoolController;

  var selectItValue;

  final subject = PublishSubject();

  @override
  void initState() {
    _cardNumberController = TextEditingController(text: '');
    _cardPasswordController = TextEditingController(text: '');
    _nameController = TextEditingController();
    _areaController = TextEditingController();
    _schoolController = TextEditingController();
    // 防止激活重复点击
    /// https://blog.csdn.net/weixin_30826095/article/details/96432239
    subject.debounceTime(Duration(seconds: 1)).listen((_) => _onPressed(_onGetCourseList));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StoreBuilder(builder: (BuildContext context, Store<AppState> store) {
      bool showMore = (store.state.userInfo?.data?.stateType ?? 0) == 0;
      return Scaffold(
        appBar: AppBar(
          elevation: 1.0,
          backgroundColor: Colors.white,
          title: Text('课程申请'),
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(32.0),
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text('如果您收到的有课程申请卡，可以在这里申请对应的课程。'),
                TextField(
                  cursorWidth: 1,
                  cursorColor: Color(MyColors.primaryLightValue),
                  style: textStyleNormal,
                  decoration: InputDecoration(
                    enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                            color: Color(MyColors.line),
                            width: 1,
                            style: BorderStyle.solid)),
                    labelText: '卡号',
                  ),
                  controller: _cardNumberController,
                ),
                Padding(
                  padding: EdgeInsets.only(top: 18),
                ),
                TextField(
                  cursorWidth: 1,
                  cursorColor: Color(MyColors.primaryLightValue),
                  style: textStyleNormal,
                  decoration: InputDecoration(
                    enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                            color: Color(MyColors.line),
                            width: 1,
                            style: BorderStyle.solid)),
                    labelText: '密码',
                  ),
                  controller: _cardPasswordController,
                ),
                Padding(
                  padding: EdgeInsets.only(top: 24),
                ),
              ]
                ..addAll(!showMore
                    ? []
                    : [
                        Text('为了方便给您提供更好的服务，请完善个人信息，要填写真实信息哟~'),
                        TextField(
                          cursorWidth: 1,
                          cursorColor: Color(MyColors.primaryLightValue),
                          style: textStyleNormal,
                          decoration: InputDecoration(
                            enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color: Color(MyColors.line),
                                    width: 1,
                                    style: BorderStyle.solid)),
                            labelText: '姓名',
                          ),
                          controller: _nameController,
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 24),
                        ),
                        TextField(
                          cursorWidth: 1,
                          cursorColor: Color(MyColors.primaryLightValue),
                          style: textStyleNormal,
                          decoration: InputDecoration(
                            enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color: Color(MyColors.line),
                                    width: 1,
                                    style: BorderStyle.solid)),
                            labelText: '地区',
                          ),
                          controller: _areaController,
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 24),
                        ),
                        TextField(
                          cursorWidth: 1,
                          cursorColor: Color(MyColors.primaryLightValue),
                          style: textStyleNormal,
                          decoration: InputDecoration(
                            enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color: Color(MyColors.line),
                                    width: 1,
                                    style: BorderStyle.solid)),
                            labelText: '学校',
                          ),
                          controller: _schoolController,
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 24),
                        ),
                        DropdownButton(
                          items: getListData(),
                          value: selectItValue,
                          hint: Text('选择年级'),
                          onChanged: (dynamic gradeId) {
                            selectItValue = gradeId;
                            FocusScope.of(context).requestFocus(FocusNode());
                            setState(() {});
                          },
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 24),
                        ),
                      ])
                ..add(
                  ElevatedButton(
                    style: ButtonStyle(
                      padding: MaterialStateProperty.resolveWith<EdgeInsetsGeometry>(
                            (Set<MaterialState> states) {
                          return EdgeInsets.only(top: 12, bottom: 12);
                        },
                      ),
                      shape: ButtonStyleButton.allOrNull<RoundedRectangleBorder>(RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4.0)))),
                      backgroundColor: MaterialStateProperty.resolveWith<Color?>(
                            (Set<MaterialState> states) {
                          if (states.contains(MaterialState.pressed))
                            return Color(MyColors.primaryValue);
                          else if (states.contains(MaterialState.disabled))
                            return Color(MyColors.ccc);
                          return null; // Use the component's default.
                        },
                      ),
                    ),
                    child: Text(
                      "申请",
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.white,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    onPressed: () => subject.add(0),
                  ),
                ),
            ),
          ),
        ),
      );
    });
  }

  List<DropdownMenuItem> getListData() {
    List<DropdownMenuItem> items = [];
    DropdownMenuItem dropdownMenuItem7 = DropdownMenuItem(
      child: Text('初中一年级'),
      value: '6',
    );
    items.add(dropdownMenuItem7);
    DropdownMenuItem dropdownMenuItem8 = DropdownMenuItem(
      child: Text('初中二年级'),
      value: '5',
    );
    items.add(dropdownMenuItem8);
    DropdownMenuItem dropdownMenuItem9 = DropdownMenuItem(
      child: Text('初中三年级'),
      value: '4',
    );
    items.add(dropdownMenuItem9);
    DropdownMenuItem dropdownMenuItem10 = DropdownMenuItem(
      child: Text('高中一年级'),
      value: '3',
    );
    items.add(dropdownMenuItem10);
    DropdownMenuItem dropdownMenuItem11 = DropdownMenuItem(
      child: Text('高中二年级'),
      value: '2',
    );
    items.add(dropdownMenuItem11);
    DropdownMenuItem dropdownMenuItem12 = DropdownMenuItem(
      child: Text('高中三年级'),
      value: '1',
    );
    items.add(dropdownMenuItem12);
    return items;
  }

  Future _onPressed(Function callback) async {
    _cardNumberController!.text.trim().isEmpty
        ? toast('卡号不能为空')
        : _cardPasswordController!.text.isEmpty
            ? toast('卡密码不能为空')
            : _nameController!.text.isEmpty
                ? toast('姓名不能为空')
                : _areaController!.text.isEmpty
                    ? toast('地区不能为空')
                    : _schoolController!.text.isEmpty
                        ? toast('学校名不能为空')
                        : selectItValue == null ? toast('年级不能为空') : callback();
  }

  Future _onGetCourseList() async {
    var result = await CardDao.getCards(
        _cardNumberController!.text.trim(), _cardPasswordController!.text);
    var model = result.model as CardListModel?;
    if (result.result &&
        model != null &&
        model.code == 1 &&
        model.data != null &&
        model.data!.courseInfoResultDTOS != null &&
        model.data!.courseInfoResultDTOS!.length > 0) {
      var data = model.data!;
      if (data.courseInfoResultDTOS!.length == data.activationNumber) {
        // 全部激活，无须选择
        _doSubmit(data.courseInfoResultDTOS!);
      } else {
        Navigator.of(context)
            .push(MaterialPageRoute(
                fullscreenDialog: true,
                builder: (BuildContext context) => ChooseCardPage(
                    model.data!.courseInfoResultDTOS,
                    _cardNumberController!.text.trim(),
                    _cardPasswordController!.text,
                    limit: model.data!.activationNumber as int?)))
            .then((r) => _doSubmit(r));
      }
    } else {
      Fluttertoast.showToast(msg: model!.msg!);
    }
  }

  toast(msg) {
    Fluttertoast.showToast(msg: msg, gravity: ToastGravity.CENTER);
  }

  _doSubmit(List<CourseInfoResultDTOSEntity> list) async {
    var courseIds = list.map((c) => c.courseId).toList();
    var activate = await CardDao.activate(
        _cardNumberController!.text.trim(), _cardPasswordController!.text, courseIds);
    var activateModel = activate.model as ActivateModel?;
    if (!activate.result ||
        activateModel!.code != 1 ||
        activateModel.data == null) {
      toast(activateModel?.msg ?? '激活失败');
      return;
    }
    if (activateModel.data!.stateType == 0) {
      var completeUserInfo = await UserInfoDao.completeUserInfo(
          schoolId: activateModel.data!.schoolId,
          realName: _nameController!.text,
          address: _areaController!.text,
          gradeId: selectItValue,
          schoolName: _schoolController!.text,
          cardId: _cardNumberController!.text.trim(),
          onlineCourseId: courseIds);
      if (completeUserInfo.result) {
        var model = completeUserInfo.model as BaseModel?;
        if (model != null && model.code == 1) {
          var userInfo = _getStore().state.userInfo!;
          userInfo.data!.stateType = 1;
          SingletonManager.sharedInstance!.zhiLingAuthority = true;
          Navigator.of(context).pushReplacement(MaterialPageRoute(
              fullscreenDialog: true,
              builder: (BuildContext context) => ActivateSuccessPage(
                  waitAudit: (activateModel.data?.waitAudit ?? 0) == 0)));
        } else {
          toast(model?.msg ?? '激活失败');
        }
      }
    } else {
      toast('激活成功');
      Navigator.of(context).pop(true);
    }
  }

  Store<AppState> _getStore() {
    return StoreProvider.of<AppState>(context);
  }
}
