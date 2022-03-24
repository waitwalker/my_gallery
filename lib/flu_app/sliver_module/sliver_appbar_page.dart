import 'package:flutter/material.dart';
import 'package:random_color/random_color.dart';

class SliverAppBarPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _SliverAppBarPageState();
  }
}

class _SliverAppBarPageState extends State<SliverAppBarPage> {

  int currentIndex = 1;
  bool _floating = true;
  bool _snap = false;
  bool _pinned = false;
  String _title = "Floating";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: _floating,
            snap: _snap,
            pinned: _pinned,
            expandedHeight: 260,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(_title, style: TextStyle(fontSize: 20, color: Colors.red, fontWeight: FontWeight.bold),),
              background: Image.network("http://img1.mukewang.com/5c18cf540001ac8206000338.jpg",
                fit: BoxFit.cover,
              ),
            ),
          ),
          renderWidget(),
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
          },childCount: 30,)),
        ],
      ),
    );
  }

  Widget renderWidget() {
    return SliverToBoxAdapter(
      child: InkWell(
        child: Padding(padding: EdgeInsets.only(bottom: 10),
          child: Container(
            alignment: Alignment.center,
            height: 80,
            color: Colors.green,
            child: Text("切换", style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),),
          ),
        ),
        onTap: (){
          currentIndex++;
          if (currentIndex > 3) currentIndex = 1;
          if (currentIndex == 1) {
            _floating = true;
            _snap = false;
            _pinned = false;
            _title = "Floating";
          } else if (currentIndex == 2) {
            _floating = true;
            _snap = true;
            _pinned = false;
            _title = "Snap";
          } else {
            _floating = false;
            _snap = false;
            _pinned = true;
            _title = "Pinned";
          }
          setState(() {

          });
        },
      ),
    );
  }

}