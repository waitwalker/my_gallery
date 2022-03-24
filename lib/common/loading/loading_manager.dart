import 'package:my_gallery/modules/widgets/loading/loading_dialog.dart';
import 'package:flutter/material.dart';

///
/// @name LoadingManager
/// @description 加载圈疯转
/// @author waitwalker
/// @date 2020-02-26
///
class LoadingManager {

  ///
  /// @name showLoading
  /// @description 显示加载圈
  /// @parameters
  /// @return
  /// @author waitwalker
  /// @date 2020-02-26
  ///
  static showLoading(BuildContext context, {String? message}) {
    showLoadingDialog(context,message: message);
  }

  ///
  /// @name hideLoading
  /// @description 隐藏加载圈
  /// @parameters
  /// @return
  /// @author waitwalker
  /// @date 2020-02-26
  ///
  static hideLoading(BuildContext context) {
    Navigator.of(context).pop();
  }

}