import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:my_gallery/modules/flu_app/config/printer.dart';
import 'package:my_gallery/modules/flu_app/theme/theme_change_notifier.dart';
import 'package:provider/provider.dart';

class PersonalPage extends StatefulWidget {
  const PersonalPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _SelectorDemoWidgetState();
  }
}

class _PersonalPageState extends State<PersonalPage> {
  int index = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("个人主页"),
      ),
      body: Column(
        children: [
          InkWell(
            child: Text("切换",style: TextStyle(fontSize: 30, color: Colors.black87) ,),
            onTap: (){
              index++;
              if (index == 6) {
                index = 0;
              }
              Provider.of<ThemeChangeNotifier>(context, listen: false).setTheme(index);
            },
          ),
          
          Expanded(child: GridView.builder(itemCount: 50, gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            childAspectRatio: 1.0,
            mainAxisSpacing: 20,
            crossAxisSpacing: 20,
            crossAxisCount: 2,
          ), itemBuilder: (BuildContext context, int index){
            return Container(
              color: Colors.amber,
              child: Column(
                children: [
                  
                  InkWell(
                    onTap: (){
                      printer("点击了$index");
                    },
                    child: Container(
                      color: Colors.green,
                      constraints: BoxConstraints(minHeight: 100,maxHeight: 120, minWidth: 150),
                      child: Text("点击我"),
                    ),
                  ),
                ],
              ),
            );
          }))
        ],
      ),
    );
  }
}

//首先我们有一个model，做数据处理，ChangeNotifier用到Provider中
class CountModel extends ChangeNotifier {
  //key为字母，value为点击次数统计
  Map<String?, int> contentMap = SplayTreeMap();

  //初始化数据
  initData() {
    contentMap["a"] = 0;contentMap["b"] = 0;contentMap["c"] = 0;
  }

  //增加字母按钮的点击次数
  increment(String? content) {
    contentMap[content] = contentMap[content]! + 1;
    //通知刷新
    notifyListeners();
  }
}

// class SelectorDemoWidget extends StatefulWidget {
//  
// }

class _SelectorDemoWidgetState extends State<PersonalPage> {
  CountModel? _model;

  @override
  void initState() {
    super.initState();
    //初始化数据
    _model = CountModel()..initData();
  }

  @override
  Widget build(BuildContext context) {
    //构建一组字母按钮(CountItemWidget)
    List<CountItemWidget> _children = _model!.contentMap.keys
        .map((key) => CountItemWidget(content: key))
        .toList();
    return Scaffold(
    appBar: AppBar(title: Text("Gird局部刷新"),),
    body: ChangeNotifierProvider.value(
    value: _model,
    child: ListView(children: _children),
    ));
  }
}

//字母按钮
class CountItemWidget extends StatelessWidget {
  final String? content;

  const CountItemWidget({Key? key, this.content}):super(key: key);

  @override
  Widget build(BuildContext context) {
    printer("CountItemWidget:build");
    return Container(
      height: 80,
      padding: EdgeInsets.all(15),
      alignment: Alignment.center,
      child: InkWell(
        onTap: () =>
            Provider.of<CountModel>(context, listen: false).increment(content),
        child: Selector<CountModel, int?>(
          //从 CountModel得到对应字母的count
            selector: (context, model) => model.contentMap[content],
            //如果前后两次的count不相等，则刷新
            shouldRebuild: (preCount, nextCount) => preCount != nextCount,
            builder: (context, count, child) {
              printer("$content Selector:builder");
              return Text("$content : $count");
            }),
      ),
    );
  }
}
