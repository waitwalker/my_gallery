import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_gallery/modules/flu_app/common/refresh_custom.dart';
import 'package:my_gallery/modules/flu_app/common/values/colors.dart';

/// @fileName order_list_page.dart
/// @description 订单列表页面
/// @date 2022/3/29 5:51 下午
/// @author LiuChuanan
class OrderListPage extends StatefulWidget {
  final int pageIndex;
  const OrderListPage({
    Key? key,
    required this.pageIndex,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _OrderListPageState();
  }
}

class _OrderListPageState extends State<OrderListPage> with AutomaticKeepAliveClientMixin{


  Color? bgColor;

  @override
  void initState() {
    bgColor = widget.pageIndex == 0 ? Colors.lightBlue : widget.pageIndex == 1 ? Colors.deepPurple : Colors.greenAccent;
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Container(
      color: const Color(0xffF6F7F8),
      child: Padding(
        padding: EdgeInsets.only(left: 15.w, right: 15.w),
        child: Column(
          children: [
            Expanded(
              child: RefreshCustom(
                child: ListView.separated(itemBuilder: (context, index){
                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.r),
                      color: Colors.white,
                    ),
                    height: 100.h,
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: 15.w,
                        right: 12.w,
                        top: 10.h,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [

                              Text("2022-03-12 10:29:30",
                                maxLines: 1,
                                style: TextStyle(
                                  color: AppColors.colorFF666666,
                                  fontSize: 12.sp,
                                ),
                              ),

                              Padding(padding: EdgeInsets.only(left: 10.w)),

                              Text("Sccesso",
                                maxLines: 1,
                                style: TextStyle(
                                  color: AppColors.colorFFF7B500,
                                  fontSize: 15.sp,
                                ),
                              ),

                            ],
                          ),
                          Padding(padding: EdgeInsets.only(top: 5.h)),
                          Container(
                            color: Colors.white,
                            height: 56.h,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                // Image.network("src"),
                                Container(
                                  height: 56.r,
                                  width: 56.r,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8.r),
                                    color: Colors.lightBlue,
                                  ),
                                  child: Icon(Icons.monetization_on_outlined, size: 56.r, color: Colors.orangeAccent,),
                                ),

                                Padding(padding: EdgeInsets.only(left: 12.w)),

                                Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      constraints: BoxConstraints(maxWidth: 200.w),
                                      alignment: Alignment.centerLeft,
                                      child: Text("Cupom*100商品名称数量不能不超过两行Cupom*100商品名称数量不能不超过",
                                        textAlign: TextAlign.start,
                                        maxLines: 2,
                                        style: TextStyle(
                                          height: 1,
                                          fontSize: 14.sp,
                                          color: AppColors.colorFF333333,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      constraints: BoxConstraints(maxWidth: 200.w),
                                      alignment: Alignment.centerLeft,
                                      child: Text("R\$20",
                                        textAlign: TextAlign.start,
                                        maxLines: 1,
                                        style: TextStyle(
                                          height: 1,
                                          fontSize: 16.sp,
                                          color: AppColors.colorFFFA6400,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }, separatorBuilder: (BuildContext context, int index) {
                  return const SizedBox(height: 6,);
                }, itemCount: 100,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
  
}

