import 'dart:math';

import 'package:flutter/material.dart';
import 'package:my_gallery/modules/flu_app/home_module/19_provider/num_model.dart';
import 'package:provider/provider.dart';

class ProviderPage1 extends StatefulWidget {
  const ProviderPage1({Key? key}) : super(key: key);

  @override
  State<ProviderPage1> createState() => _ProviderPage1State();
}

class _ProviderPage1State extends State<ProviderPage1> {
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          children: [
            NumWidget1_1(),
            NumWidget1_2(),
            NumWidget2_1(),
            NumWidget2_2(),
            NumWidget3_1(),
            NumWidget3_2(),
            OutlinedButton(
              onPressed: () {
                int value = Random().nextInt(100);
                Provider.of<NumModel>(context, listen: false).setNum(value);
              },
              child: Text("num +"),
            ),

            OutlinedButton(
              onPressed: () {
                int value = Random().nextInt(200);
                Provider.of<NumModel>(context, listen: false).setAge(value);
              },
              child: Text("age +"),
            ),
            OutlinedButton(
              onPressed: () {
                int value = Random().nextInt(300);
                Provider.of<NumModel>(context, listen: false).setHeight(value);
              },
              child: Text("height +"),
            ),

          ],
        ),
      ),
    );
  }
}

/// 1 默认 全部监听
class NumWidget1_1 extends StatelessWidget {

  const NumWidget1_1({Key? key}) : super(key: key);

  
  @override
  Widget build(BuildContext context) {
    int num = Provider.of<NumModel>(context, listen: true).num;
    return Text("$num", style: TextStyle(fontSize: 40, color: Colors.blue,),);
  }

}

class NumWidget1_2 extends StatelessWidget {

  const NumWidget1_2({Key? key}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    int num = Provider.of<NumModel>(context, listen: true).num;
    return Text("$num", style: TextStyle(fontSize: 40, color: Colors.blue,),);
  }

}

/// 2 consumer
class NumWidget2_1 extends StatelessWidget {
  const NumWidget2_1({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<NumModel>(builder: (ctx,model, child){
      return Text("${model.age}", style: TextStyle(fontSize: 35, color: Colors.brown),);
    });
  }

}

class NumWidget2_2 extends StatelessWidget {
  const NumWidget2_2({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<NumModel>(builder: (ctx,model, child){
      return Text("${model.age}", style: TextStyle(fontSize: 35, color: Colors.brown),);
    });
  }

}


/// 3 selector
class NumWidget3_1 extends StatelessWidget {
  const NumWidget3_1({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Selector<NumModel, int>(builder: (ctx,value,child){
      return Text("$value", style: TextStyle(fontSize: 35, color: Colors.red),);
    }, selector: (ctx, model)=>model.height, shouldRebuild: (pre,nex)=>pre != nex,);
  }

}

class NumWidget3_2 extends StatelessWidget {
  const NumWidget3_2({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Selector<NumModel, int>(builder: (ctx,value,child){
      return Text("$value", style: TextStyle(fontSize: 35, color: Colors.red),);
    }, selector: (ctx, model)=>model.age, shouldRebuild: (pre,nex)=>pre != nex,);
  }

}

class FloatButton extends StatelessWidget {

  const FloatButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(onPressed: (){
      int value = Random().nextInt(1200);
      Provider.of<NumModel>(context, listen: false).setNum(value);
    },
      child: Icon(Icons.add),
    );
  }

}


