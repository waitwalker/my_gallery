import 'package:flutter/material.dart';
import 'package:random_color/random_color.dart';

class TabBarPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _TabBarPageState();
  }
}

class _TabBarPageState extends State<TabBarPage> with TickerProviderStateMixin{

  final List<String> _titles = ["关注","推荐","教育","本地","精品课","旅游"];
  TabController? _tabController;
  late PageController _pageController;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _tabController = TabController(length: _titles.length, vsync: this);
    _pageController = PageController();
  }

  void _changeTab(int index) {
    _pageController.animateToPage(index, duration: Duration(milliseconds: 300), curve: Curves.easeIn);
  }

  void _onPageChange(int index) {
    _tabController!.animateTo(index, duration: Duration(milliseconds: 300));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        automaticallyImplyLeading: false,
        title: TabBar(
          isScrollable: true,
          controller: _tabController,
          onTap: _changeTab,
          tabs: _titles.map((e) => Tab(text: e,)).toList(),
        ),
      ),
      body: Column(
        children: [
          // Container(
          //   width: double.infinity,
          //   height: 44,
          //   color: Colors.orange,
          //   child: TabBar(
          //     isScrollable: true,
          //     controller: _tabController,
          //     onTap: _changeTab,
          //     tabs: _titles.map((e) => Tab(text: e,)).toList(),
          //   ),
          // ),
          
          Expanded(child: PageView.builder(
            itemBuilder: _itemBuilder,
            itemCount: _titles.length,
            onPageChanged: _onPageChange,
          ),)
        ],
      ),
    );
  }

  Widget _itemBuilder(BuildContext context, int index) {
    RandomColor _random = RandomColor();
    Color _color = _random.randomColor();
    return Container(
      color: _color,
      child: Text("$index"),
    );
  }
}