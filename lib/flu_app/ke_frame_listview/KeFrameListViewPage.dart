import 'package:flutter/material.dart';

class KeFrameListViewPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _KeFrameListViewPageState1();
}

class _KeFrameListViewPageState1 extends State<KeFrameListViewPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("贝壳列表"),
      ),
      body: Column(
        children: [
          Expanded(child: ListView.builder(itemBuilder: itemBuilder, itemCount: 200,)),
        ],
      ),
    );
  }
  
  Widget itemBuilder(BuildContext context, int index){
    return Container(
      color: index % 2 == 0 ? Colors.red : Colors.blue,
      height: 60,
      child: Column(
        children: [
          Row(children: [
            Text("$index"),
            Text("data"),
            Icon(Icons.image)
          ],),
          Container(
            height: index % 2 == 0 ? 30 : 40,
            color: index /2 == 1 ? Colors.amberAccent : Colors.green,
          ),
        ],
      ),
    );
  }
}