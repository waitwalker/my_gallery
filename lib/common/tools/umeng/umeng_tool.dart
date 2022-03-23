import 'dart:io';
import 'package:my_gallery/common/tools/share_preference/share_preference.dart';
import 'package:package_channels/package_channels.dart';
import 'package:umeng_plugin/umeng_plugin.dart';


///
/// @name 注册友盟
/// @description 
/// @author waitwalker
/// @date 2020-01-11
///
class UmengTool {
  static init() async {
    // 设置了本地化，和这条冲突
    // initializeDateFormatting('zh_CN');
    await SharedPrefsUtils.init();
    if (Platform.isAndroid)
      UmengPlugin.init('5cbd8c740cafb2e076000fb5',
          channel: await PackageChannels.getChannel,
          policy: Policy.BATCH,
          encrypt: true,
          reportCrash: true,
          logEnable: true);
    else if (Platform.isIOS)
      UmengPlugin.init('5cbd8cdd3fc195db0a0008bc',
          policy: Policy.BATCH,
          encrypt: true,
          reportCrash: true,
          logEnable: true);
  }
}
