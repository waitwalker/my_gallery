import 'package:get_it/get_it.dart';
import 'package:my_gallery/modules/flu_app/router/navigator_service.dart';

/// 1创建全局GetIt实例
final GetIt getIt = GetIt.instance;

/// 2注册服务 这里将NavigatorState注册进入
void setupLocator(){
  getIt.registerSingleton(NavigatorService());
}