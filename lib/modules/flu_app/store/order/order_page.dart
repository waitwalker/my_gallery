import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_gallery/modules/flu_app/store/order/order_list_page.dart';

/// @fileName order_page.dart
/// @description 订单页面 包含：购买；充值；体现 三个订单列表页面
/// @date 2022/3/29 5:51 下午
/// @author LiuChuanan
class OrderPage extends StatefulWidget {
  const OrderPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> with TickerProviderStateMixin  {

  TabController? _tabController;
  int? tabIndex;

  @override
  void initState() {
    tabIndex = 0;
    _tabController = TabController(vsync: this, length: 3, initialIndex: tabIndex!);
    _tabController!.addListener(() {
      _onTabChange(_tabController!.index);
    });
    super.initState();
  }

  void _onTabChange(int index) {
    tabIndex = index;
    setState(() {});
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("订单"),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
              padding: EdgeInsets.only(bottom: 16.h),
            child: Container(
              child: TabBar(
                indicatorColor: Colors.orange,
                indicatorSize: TabBarIndicatorSize.label,
                indicatorWeight: 4,
                labelPadding: const EdgeInsets.only(bottom: 7),
                unselectedLabelColor: Colors.black,
                labelColor: Colors.green,
                controller: _tabController,
                tabs: const <Widget>[
                  Text(' 购买 ', style: TextStyle(fontSize: 14),),
                  Text(' 充值 ', style: TextStyle(fontSize: 14),),
                  Text(' 体现 ', style: TextStyle(fontSize: 14),),
                ],
              ),
              decoration: _boxDecoration(),
            ),
          ),
          Expanded(
            child: TabBarView(controller: _tabController, children: const <Widget>[
              OrderListPage(pageIndex: 0),
              OrderListPage(pageIndex: 1),
              OrderListPage(pageIndex: 2),
            ]),
          ),
        ],
      ),
    );
  }

  BoxDecoration _boxDecoration() {
    return const BoxDecoration(
      color: Colors.white,
      boxShadow: [
        BoxShadow(color: Color(0x0F000000), offset: Offset(0, 4), blurRadius: 4.0, spreadRadius: 0.0)
      ],
    );
  }
}