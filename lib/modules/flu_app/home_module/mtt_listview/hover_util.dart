import 'package:my_gallery/modules/flu_app/config/k_printer.dart';

/// 抽象类
abstract class HoverAbstractModel {
  bool shouldShowHover = false;

  String? getHoverTag(); //Suspension Tag
}

///
/// @ClassName 工具类
/// @Description
/// @Author waitwalker
/// @Date 2022/1/21
///
class HoverUtil {

  ///
  /// @MethodName 根据名称进行排序
  /// @Parameter
  /// @ReturnType
  /// @Description
  /// @Author waitwalker
  /// @Date 2022/1/21
  ///
  /// 根据[A-Z]排序。
  static void sortByHoverTag(List<HoverAbstractModel> list) {
    if (list == null || list.isEmpty) return;
    list.sort((a, b) {
      if (a.getHoverTag() == "@" || b.getHoverTag() == "#") {
        return -1;
      } else if (a.getHoverTag() == "#" || b.getHoverTag() == "@") {
        return 1;
      } else {
        return a.getHoverTag()!.compareTo(b.getHoverTag()!);
      }
    });
    kPrinter("排序完的列表$list");
  }

  ///
  /// @MethodName 获取索引列表
  /// @Parameter
  /// @ReturnType
  /// @Description
  /// @Author waitwalker
  /// @Date 2022/1/21
  ///
  static List<String?> getTagIndexList(List<HoverAbstractModel> list) {
    List<String?> indexData = [];
    if (list != null && list.isNotEmpty) {
      String? tempTag;
      for (int i = 0, length = list.length; i < length; i++) {
        String? tag = list[i].getHoverTag();
        if (tempTag != tag) {
          indexData.add(tag);
          tempTag = tag;
        }
      }
    }
    return indexData;
  }

  ///
  /// @MethodName 设置显示悬停的状态 当前是否显示悬停
  /// @Parameter
  /// @ReturnType
  /// @Description
  /// @Author waitwalker
  /// @Date 2022/1/21
  ///
  static void setShowHoverStatus(List<HoverAbstractModel> list) {
    if (list == null || list.isEmpty) return;
    String? tempTag;
    for (int i = 0, length = list.length; i < length; i++) {
      String? tag = list[i].getHoverTag();
      if (tempTag != tag) {
        tempTag = tag;
        list[i].shouldShowHover = true;
      } else {
        list[i].shouldShowHover = false;
      }
    }
  }
}
