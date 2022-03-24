import 'package:flutter/material.dart';
import 'package:random_color/random_color.dart';

class SliverListPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _SliverListPageState();
  }
}

class _SliverListPageState extends State<SliverListPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("SliverList页面"),
      ),
      body: CustomScrollView(
        slivers: [
          renderTitle("SliverList"),
          SliverList(delegate: SliverChildBuilderDelegate((context, index){
            RandomColor _randomColor = RandomColor();
            Color _color = _randomColor.randomColor();
            return Padding(padding: EdgeInsets.only(left: 20, bottom: 10, right: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: _color,
                  borderRadius: BorderRadius.circular(10),
                ),
                height: 44,
                child: Text("$index",style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold,),),
              ),
            );
          },
            childCount: 1000,
          ),),
          SliverPadding(padding: EdgeInsets.only(bottom: 20,)),
          renderTitle("SliverGrid"),
          /// SliverGrid 使用https://www.jianshu.com/p/a9309cab01c2
          SliverGrid(delegate: SliverChildBuilderDelegate((context, index){
            RandomColor _randomColor = RandomColor();
            Color _color = _randomColor.randomColor();
            return Padding(padding: EdgeInsets.only(left: 10, right: 20, bottom: 10),
              child: Container(
                decoration: BoxDecoration(
                  color: _color,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text("我是第$index个",style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),),
              ),
            );
          },
            childCount: 80,
          ), gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
            childAspectRatio: 1.5,
          ),),
        ],
      ),
    );
  }

  Widget renderTitle(String title) {
    return SliverToBoxAdapter(
      child: Padding(padding: EdgeInsets.only(top: 10,bottom: 10),
        child: Container(
          alignment: Alignment.centerLeft,
          height: 80,
          color: Colors.green,
          child: Text(title, style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold,),),
        ),
      ),
    );
  }
}