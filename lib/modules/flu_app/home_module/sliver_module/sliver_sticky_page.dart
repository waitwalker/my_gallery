import 'package:flutter/material.dart';
import 'package:random_color/random_color.dart';

/// 目前页面会存在滚动冲突问题 事件竞争
class SliverStickyPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _SliverStickyPageState();
  }
}

class _SliverStickyPageState extends State<SliverStickyPage> with SingleTickerProviderStateMixin{
  TabController? tabController;
  @override
  void initState() {
    super.initState();
    this.tabController = TabController(length: 8, vsync: this);
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 260,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              title: Text("SliverPersistentHeader", style: TextStyle(fontSize: 20, color: Colors.red, fontWeight: FontWeight.bold),),
              background: Image.network("http://img1.mukewang.com/5c18cf540001ac8206000338.jpg",
                fit: BoxFit.cover,
              ),
            ),
          ),
          SliverPersistentHeader(
            pinned: true,
            delegate: StickyTabBarDelegate(TabBar(
              labelColor: Colors.red,
              controller: tabController,
              tabs: <Widget>[
                Tab(text: "要闻",),
                Tab(text: "体育",),
                Tab(text: "经济",),
                Tab(text: "科技",),
                Tab(text: "教育",),
                Tab(text: "北京",),
                Tab(text: "财经",),
                Tab(text: "热点",),
            ],),),
          ),
          SliverFillRemaining(
            child: TabBarView(
              controller: tabController,
              children: <Widget>[
                Expanded(child: ListView.builder(itemBuilder: (context, index){
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
                })),
                Expanded(child: ListView.builder(itemBuilder: (context, index){
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
                })),
                Expanded(child: ListView.builder(itemBuilder: (context, index){
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
                })),
                Expanded(child: ListView.builder(itemBuilder: (context, index){
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
                })),
                Expanded(child: ListView.builder(itemBuilder: (context, index){
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
                })),
                Expanded(child: ListView.builder(itemBuilder: (context, index){
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
                })),
                Expanded(child: ListView.builder(itemBuilder: (context, index){
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
                })),
                Expanded(child: ListView.builder(itemBuilder: (context, index){
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
                })),
            ],),
          ),
        ],
      ),
    );
  }
}

class StickyTabBarDelegate extends SliverPersistentHeaderDelegate {

  final TabBar child;

  StickyTabBarDelegate(this.child);

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  // TODO: implement maxExtent
  double get maxExtent => child.preferredSize.height;

  @override
  // TODO: implement minExtent
  double get minExtent => child.preferredSize.height;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
  
}