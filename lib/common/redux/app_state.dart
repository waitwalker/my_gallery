import 'package:my_gallery/common/redux/runtime_data_reducer.dart';
import 'package:my_gallery/common/redux/theme_data_reducer.dart';
import 'package:my_gallery/common/runtime_data/runtime_data.dart';
import 'package:my_gallery/common/theme/mtt_theme.dart';
import 'package:my_gallery/model/app_info.dart';
import 'package:my_gallery/model/review_status_model.dart';
import 'package:my_gallery/model/user_info_model.dart';
import 'package:my_gallery/common/redux/app_info_reducer.dart';
import 'package:my_gallery/common/redux/config_reducer.dart';
import 'package:my_gallery/common/redux/theme_reducer_old.dart';
import 'package:my_gallery/common/redux/unread_msg_count_reducer.dart';
import 'package:my_gallery/common/redux/user_reducer.dart';
import 'package:flutter/material.dart';

import 'local_reducer.dart';

///
/// @description App 全局状态
/// @author waitwalker
/// @time 2021/5/7 12:00
///
class AppState {
  MTTTheme? theme;
  Locale? locale;
  Locale? platformLocale;
  RuntimeData? runtimeData;

  ///用户信息
  UserInfoModel? userInfo = UserInfoModel();

  AppInfo? appInfo = AppInfo();
  ReviewStatusModel? config = ReviewStatusModel();

  ///未读消息数
  int? unread = 0;

  ///主题数据
  ThemeData? themeData;
  AppState({
    this.theme,
    this.locale,
    this.runtimeData,
    this.userInfo,
    this.themeData,
    this.unread,
    this.config,
    this.appInfo
  });
}

///
/// @description 创建Reducer
/// @author waitwalker
/// @time 2021/5/7 12:03
///
AppState appReducer(AppState state, action) {
  return AppState(
    theme: ThemeDataReducer(state.theme, action),
    locale: LocaleReducer(state.locale, action),
    runtimeData: RuntimeDataReducer(state.runtimeData, action),
    ///通过 UserReducer 将 GSYState 内的 userInfo 和 action 关联在一起
    userInfo: UserReducer(state.userInfo, action),

    ///通过 ThemeDataReducer 将 GSYState 内的 themeData 和 action 关联在一起
    themeData: ThemeReducer(state.themeData, action),
    unread: UnreadMsgCountReducer(state.unread, action),
    config: ConfigReducer(state.config, action),
    appInfo: AppInfoReducer(state.appInfo, action),

  );
}

