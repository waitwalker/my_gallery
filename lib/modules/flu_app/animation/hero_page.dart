import 'package:flutter/material.dart';


class HeroPage extends StatefulWidget {
  String? image;
  HeroPage({required Map<String,String> arguments, this.image}) {
    image = arguments["image"];
  }

  @override
  State<StatefulWidget> createState() {
    return _HeroPageState();
  }
}

class _HeroPageState extends State<HeroPage> {

  String? image;

  @override
  void initState() {
    image = widget.image;
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 400.0,
            title: Text("Hero 动画页面"),
            backgroundColor: Colors.grey[200],
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.parallax,
              background: Hero(
                tag: image!,
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(image!),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverList(delegate: SliverChildListDelegate(<Widget>[
            Container(
              height: 600,
              color: Colors.grey[200],
            ),
          ])),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}