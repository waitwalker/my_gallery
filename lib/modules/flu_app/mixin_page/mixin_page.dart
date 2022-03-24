import 'package:flutter/material.dart';

class MixinPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MixinPageState();
  }
}

class _MixinPageState extends State<MixinPage> {
  bool isBaseUse = false;
  bool isHigh = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Mixin页面"),
      ),
      body: Column(children: [
        Padding(padding: EdgeInsets.only(top: 20)),
        InkWell(
          child: Padding(padding: EdgeInsets.only(left: 16, right: 16, bottom: 16),
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.deepPurple,
                borderRadius: BorderRadius.circular(10),
              ),
              width: MediaQuery.of(context).size.width, height: 60,
              child: Text("mixin的基本使用", style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold,),),
            ),
          ),
          onTap: (){
            isBaseUse = !isBaseUse;
            MyClass ma = MyClass();
            ma.name();
            ma.eat();
            setState(() {

            });
          },
        ),
        Padding(padding: EdgeInsets.only(left: 16, right: 16, bottom: 16),
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.deepPurple,
              borderRadius: BorderRadius.circular(10),
            ),
            width: MediaQuery.of(context).size.width, height: 160,
            child: Text("mixin的基本使用\n1)mixin中不能定义构造方法，否则会直接报错\n2）mixin中可以定义方法和属性\n3)mixin可以定义方法的声明，但基类中必须实现mixin中的声明方法\n4)mixin在基类中实现使用with关键字", style: TextStyle(fontSize: 15, color: isBaseUse ? Colors.amberAccent : Colors.white, fontWeight: FontWeight.bold,),),
          ),
        ),
        InkWell(
          child: Padding(padding: EdgeInsets.only(left: 16, right: 16, bottom: 16),
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.deepPurple,
                borderRadius: BorderRadius.circular(10),
              ),
              width: MediaQuery.of(context).size.width, height: 60,
              child: Text("mixin的高级使用", style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold,),),
            ),
          ),
          onTap: (){
            isHigh = !isHigh;
            Animal ma = Animal();
            ma.tellName();
            ma.showAge();
            setState(() {

            });
          },
        ),
        Padding(padding: EdgeInsets.only(left: 16, right: 16, bottom: 16),
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.deepPurple,
              borderRadius: BorderRadius.circular(10),
            ),
            width: MediaQuery.of(context).size.width, height: 160,
            child: Text("mixin的高级使用\n1)mixin可以使用on关键字指定其继承者，基类继承该继承者时，重写mixin中方法和不使用on关键字方法类似\n2）多个mixin中方法和属性重名在继承实现时会被覆盖，后面的覆盖前面的", style: TextStyle(fontSize: 15, color: isHigh ? Colors.amberAccent : Colors.white, fontWeight: FontWeight.bold,),),
          ),
        ),
      ],),
    );
  }
}

/// mixin基本使用
mixin Person {
  /// mixin中不能定义构造方法，定义构造方法会直接报错
  ///Person();
  /// mixin中可以定义方法声明，让继承类去实现，继承类必须实现
  eat();

  /// mixin中可以定义属性
  int? age;

  /// mixin中可以定义方法实现
  void name() {
    print("mixin中的name的方法实现");
  }
}

class MyClass with Person {
  MyClass(){
    age = 10;
  }
  @override
  eat() {
    print("基类中实现mixin中定义的方法声明");
  }

  @override
  name() {
    print("基类中重写mixin中定义的方法");
    super.name();
  }
}

class People {
  void tellName() {
    print("说出People 的名字");
  }

  void showAge() {
    print("显示People的名字");
  }
}

mixin Dog {
  void tellName() {
    print("说出Dog mixin的名字");
  }
}

mixin Cat on People{
  void tellName() {
    print("说出Cat mixin的名字");
  }
}

class Animal extends People with Cat, Dog {
  @override
  void tellName() {
    print("说出Animal的名字开始");
    super.tellName();
    print("说出Animal的名字结束");
  }

  @override
  void showAge() {
    print("显示Animal的名字开始");
    super.showAge();
    print("显示Animal的名字结束");
  }
}