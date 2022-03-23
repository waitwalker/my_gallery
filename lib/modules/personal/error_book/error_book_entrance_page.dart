import 'dart:io';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:my_gallery/common/locale/localizations.dart';
import 'package:my_gallery/common/redux/app_state.dart';
import 'package:my_gallery/common/singleton/singleton_manager.dart';
import 'package:my_gallery/modules/widgets/style/style.dart';
import 'package:flutter/material.dart';
import 'error_book_subject_list_page.dart';
import 'package:redux/redux.dart';


///
/// @name ErrorBookEntrancePage
/// @description 错题本入口  里面包括:1)系统错题;2)数校错题;3)上传错题
/// @author waitwalker
/// @date 2020-01-11
///
// ignore: must_be_immutable
class ErrorBookEntrancePage extends StatefulWidget {
  bool fromShuXiao = false;
  ErrorBookEntrancePage({this.fromShuXiao = false});

  @override
  State<StatefulWidget> createState() {
    return _ErrorBookEntrancePageState();
  }
}

class _ErrorBookEntrancePageState extends State<ErrorBookEntrancePage> {
  List? _modules;

  void _setItemDataSource() {
    if (SingletonManager.sharedInstance!.unitTestAuthority && widget.fromShuXiao) {
      _modules = [
        {
          'type':'1',
          'title': MTTLocalization.of(context)!.currentLocalized!.errorBookPageSystemErrorItem,
          'pic': 'static/images/errorbook_xitongcuoti.png',
          'color': 0xFF8C8FF6,
        },
        {
          'type':'2',
          'title': MTTLocalization.of(context)!.currentLocalized!.errorBookPageDigitalCampusErrorItem,
          'pic': 'static/images/errorbook_xiaoyuancuoti.png',
          'color': 0xFF64D2FD
        },
        {
          'type':'3',
          'title': MTTLocalization.of(context)!.currentLocalized!.errorBookPageUploadErrorItem,
          'pic': 'static/images/errorbook_shangchuancuoti.png',
          'color': 0xFF5A7CED,
        },
        {
          'type':'4',
          'title': MTTLocalization.of(context)!.currentLocalized!.errorBookPageUnitTestErrorItem,
          'pic': 'static/images/errorbook_unit_test.png',
          'color': 0xFF5A7CED,
        },
      ];
    } else if (SingletonManager.sharedInstance!.unitTestAuthority){

      _modules = [
        {
          'type':'1',
          'title': MTTLocalization.of(context)!.currentLocalized!.errorBookPageSystemErrorItem,
          'pic': 'static/images/errorbook_xitongcuoti.png',
          'color': 0xFF8C8FF6,
        },
        {
          'type':'3',
          'title': MTTLocalization.of(context)!.currentLocalized!.errorBookPageUploadErrorItem,
          'pic': 'static/images/errorbook_shangchuancuoti.png',
          'color': 0xFF5A7CED,
        },
        {
          'type':'4',
          'title': MTTLocalization.of(context)!.currentLocalized!.errorBookPageUnitTestErrorItem,
          'pic': 'static/images/errorbook_unit_test.png',
          'color': 0xFF5A7CED,
        },
      ];

    } else if (widget.fromShuXiao) {
      _modules = [
        {
          'type':'1',
          'title': MTTLocalization.of(context)!.currentLocalized!.errorBookPageSystemErrorItem,
          'pic': 'static/images/errorbook_xitongcuoti.png',
          'color': 0xFF8C8FF6,
        },
        {
          'type':'2',
          'title': MTTLocalization.of(context)!.currentLocalized!.errorBookPageDigitalCampusErrorItem,
          'pic': 'static/images/errorbook_xiaoyuancuoti.png',
          'color': 0xFF64D2FD
        },
        {
          'type':'3',
          'title': MTTLocalization.of(context)!.currentLocalized!.errorBookPageUploadErrorItem,
          'pic': 'static/images/errorbook_shangchuancuoti.png',
          'color': 0xFF5A7CED,
        },
      ];
    } else {
      _modules = [
        {
          'type':'1',
          'title': MTTLocalization.of(context)!.currentLocalized!.errorBookPageSystemErrorItem,
          'pic': 'static/images/errorbook_xitongcuoti.png',
          'color': 0xFF8C8FF6,
        },
        {
          'type':'3',
          'title': MTTLocalization.of(context)!.currentLocalized!.errorBookPageUploadErrorItem,
          'pic': 'static/images/errorbook_shangchuancuoti.png',
          'color': 0xFF5A7CED,
        },
      ];
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StoreBuilder(builder: (BuildContext context, Store<AppState> store){
      _setItemDataSource();
      return Scaffold(
        appBar: AppBar(
          title: Text(MTTLocalization.of(context)!.currentLocalized!.errorBookPageNavigatorTitle!),
          elevation: 1.0,
          backgroundColor: Colors.white,
          centerTitle: Platform.isIOS ? true : false,
        ),
        backgroundColor: Color(MyColors.background),
        body: Container(
          padding: EdgeInsets.symmetric(vertical: 16, horizontal: 14),
          child: Column(children: [
            Expanded(child: _buildList()),
          ],),),
      );
    });
  }

  _buildList() {
    return GridView.builder(
      itemBuilder: _itemBuilder,
      itemCount: _modules?.length ?? 0,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 0.91),
    );
  }

  Widget _itemBuilder(BuildContext context, int index) {
    var item = _modules![index];
    String? type = _modules![index]['type'];
    return InkWell(
        child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6.0),
              image: DecorationImage(image: AssetImage(item['pic']))),
        ),
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => ErrorBookSubjectListPage(
                title:item['title'],
                fromUnitTest: type == "4",
                fromShuXiao: type == "2", // 数校错题本地址不一样，
                showCamera: type == "3",)));
        });
  }
}
