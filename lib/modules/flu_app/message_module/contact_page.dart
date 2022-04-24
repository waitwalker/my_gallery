import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lpinyin/lpinyin.dart';
import 'package:my_gallery/modules/flu_app/config/k_printer.dart';
import 'package:my_gallery/modules/flu_app/home_module/mtt_listview/hover_util.dart';
import 'package:my_gallery/modules/flu_app/home_module/mtt_listview/index_bar.dart';
import 'package:my_gallery/modules/flu_app/theme/theme_change_notifier.dart';
import 'package:provider/provider.dart';
import '../home_module/mtt_listview/mtt_listview.dart';


class ContactInfo extends HoverAbstractModel {
  String? name;
  String? tagIndex;
  String? namePinyin;

  Color? bgColor;
  IconData? iconData;

  String? img;
  String? id;

  ContactInfo({
    this.name,
    this.tagIndex,
    this.namePinyin,
    this.bgColor,
    this.iconData,
    this.img,
    this.id,
  });

  ContactInfo.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    img = json['img'];
    id = json['id']?.toString();
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'img': img,
  };

  @override
  String? getHoverTag() => tagIndex;

  @override
  String toString() => json.encode(this);
}

class ContactPage extends StatefulWidget {
  const ContactPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _ContactPageState();
  }
}

class _ContactPageState extends State<ContactPage> with WidgetsBindingObserver{

  List<ContactInfo> contactList = [];
  List<ContactInfo> topList = [];
  bool isLoading = true;

  @override
  void initState() {
    WidgetsBinding.instance!.addObserver(this);
    topList.add(ContactInfo(
      name: "新的朋友",
      tagIndex: '↑',
      bgColor: Colors.orange,
      iconData: Icons.person_add
    ));
    topList.add(ContactInfo(
        name: '群聊',
        tagIndex: '↑',
        bgColor: Colors.green,
        iconData: Icons.people));
    topList.add(ContactInfo(
        name: '标签',
        tagIndex: '↑',
        bgColor: Colors.blue,
        iconData: Icons.local_offer));
    topList.add(ContactInfo(
        name: '公众号',
        tagIndex: '↑',
        bgColor: Colors.blueAccent,
        iconData: Icons.person));
    _loadData();
    super.initState();
  }

  _loadData() {
    rootBundle.loadString("static/data/car_models.json").then((value) {
      List list = json.decode(value);
      list.forEach((element) {
        contactList.add(ContactInfo.fromJson(element));
      });
      _handleList(contactList);
    });
  }

  _handleList(List<ContactInfo> list) {
    if (list.isEmpty) {
      return;
    }
    for (int i = 0; i < list.length; i++) {
      String pinyin = PinyinHelper.getPinyin(list[i].name!);
      String tag = pinyin.substring(0,1).toUpperCase();
      list[i].namePinyin = pinyin;
      if (RegExp("[A-Z]").hasMatch(tag)) {
        list[i].tagIndex = tag;
      } else {
        list[i].tagIndex = "#";
      }
    }
    HoverUtil.sortByHoverTag(contactList);
    HoverUtil.setShowHoverStatus(contactList);

    contactList.insertAll(0, topList);
    setState(() {
      isLoading = false;
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
     kPrinter(state);
    super.didChangeAppLifecycleState(state);
  }

  @override
  Widget build(BuildContext context) {
    int themeIndex = Provider.of<ThemeChangeNotifier>(context).themeIndex;
    return Scaffold(
      appBar: AppBar(
        title: const Text("联系人"),
        backgroundColor: themeColorList[themeIndex],
      ),
      body: isLoading ? const CircularProgressIndicator() : MTTListView(
        data: contactList,
        itemCount: contactList.length,
        itemBuilder: (BuildContext context, int index) {
          /// item
          ContactInfo model = contactList[index];
          return Row(
            children: [
              InkWell(
                child: SizedBox(height: 44, child: Text("${model.name}"),),
                onTap: (){

                },
              )
            ],
          );
        },
        physics: const BouncingScrollPhysics(),
        hoverItemBuilder: (BuildContext context, int index) {
          ContactInfo model = contactList[index];
          if ('↑' == model.getHoverTag()) {
            return Container(width: 30, height: 30, color: Colors.transparent,);
          }
          /// 组头
          return Container(alignment: Alignment.centerLeft, color: Colors.red, height: 44, width: MediaQuery.of(context).size.width, child: Text("${model.tagIndex}"),);
        },
        indexBarData: ['↑', '☆', ...kIndexBarData],
        indexBarOptions: const IndexBarOptions(
          needRebuild: true,
          ignoreDragCancel: true,
          downTextStyle: TextStyle(fontSize: 12, color: Colors.white),
          downItemDecoration:
          BoxDecoration(shape: BoxShape.circle, color: Colors.green),
          indexHintWidth: 120 / 2,
          indexHintHeight: 100 / 2,
          indexHintDecoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('static/images/ic_index_bar_bubble_gray.png'),
              fit: BoxFit.contain,
            ),
          ),
          indexHintAlignment: Alignment.centerRight,
          indexHintChildAlignment: Alignment(-0.25, 0.0),
          indexHintOffset: Offset(-20, 0),
        ),
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }
}