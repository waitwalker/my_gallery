import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// @fileName badge_custom.dart
/// @description 角标组件
/// @date 2022/4/19 10:20
/// @author LiuChuanan
enum BonusBadge { text, number }

class BadgeCustom extends StatelessWidget {
  const BadgeCustom({
    Key? key,
    this.badgeContent,
    this.badgeType = BonusBadge.number,
    required this.icon,
  }) : super(key: key);

  /// 角标内容 不传或者内容为空 不显示
  final String? badgeContent;

  /// 图标
  final String icon;

  /// 脚本类型：文本/数字
  final BonusBadge badgeType;

  /// methodName builderLabel
  /// description 构建脚本的显示
  /// date 2023/1/28 12:12
  /// author LiuChuanan
  Widget _builderLabel(BuildContext context) {
    String content = badgeContent ?? "";
    if (badgeType == BonusBadge.text) {
      return Center(
        child: Container(
          height: 21.h,
          margin: EdgeInsets.only(top: 1.5.h),
          decoration: BoxDecoration(
            border: Border.all(
              width: 1.5.w,
              color: Theme.of(context).colorScheme.background,
            ),
          ),
          child: Container(
            padding: EdgeInsetsDirectional.symmetric(horizontal: 5.h),
            alignment: Alignment.topCenter,
            height: 19.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(9.5.h),
              color: Theme.of(context).badgeTheme.backgroundColor,
            ),
            child: Text(
              content,
              maxLines: 1,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 9.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      );
    } else {
      return Center(
          child: Container(
            height: 21.w,
            width: 21.w,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.5.w),
              border: Border.all(
                width: 1.5.w,
                color: Theme.of(context).colorScheme.background,
              ),
            ),
            child: Container(
              alignment: content.length == 1 ? Alignment.topCenter : Alignment.center,
              height: 19.w,
              width: 19.w,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(9.5.w),
                color: Theme.of(context).badgeTheme.backgroundColor,
              ),
              child: Text(
                content,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: content.length > 2
                      ? 7.sp
                      : content.length == 2
                      ? 9.5.sp
                      : 12.sp,
                ),
              ),
            ),
          ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    String content = badgeContent ?? "";
    return Badge(
      alignment: AlignmentDirectional(10.w, -6.h),
      backgroundColor: Colors.transparent,
      label: _builderLabel(context),
      largeSize: 21.w,
      isLabelVisible: content.isNotEmpty,
      child: Image.asset(
        icon,
        width: 20.h,
        height: 20.h,
        fit: BoxFit.fitHeight,
      ),
    );
  }
}
