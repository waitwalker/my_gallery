import 'dart:math';

import 'package:flutter/material.dart';
import 'package:my_gallery/modules/flu_app/home_module/18_inherited_page/info_widget.dart';

class InheritedPage extends StatefulWidget {
  const InheritedPage({Key? key}) : super(key: key);

  @override
  State<InheritedPage> createState() => _InheritedPageState();
}

class _InheritedPageState extends State<InheritedPage> {

  int _number = 0;

  void increment() {
    _number = Random().nextInt(1000);
    setState(() {
    });
  }

  @override
  void initState() {

    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: InfoWidget(num: _number,
          child: Center(
            child: Column(
              children: const [
                InfoChildWidget(),
                InfoChildWidget(),
                InfoChildWidget(),
              ],
            ),
      )),
      floatingActionButton: FloatingActionButton(
        onPressed: increment,
        child: Icon(Icons.add),
      ),
    );
  }
}
