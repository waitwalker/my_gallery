import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'localizations.dart';


class MTTLocalizationsDelegate extends LocalizationsDelegate<MTTLocalization> {

  MTTLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    ///支持中文和英语
    return ['en', 'zh'].contains(locale.languageCode);
  }

  ///根据locale，创建一个对象用于提供当前locale下的文本显示
  @override
  Future<MTTLocalization> load(Locale locale) {
    return SynchronousFuture<MTTLocalization>(MTTLocalization(locale));
  }

  @override
  bool shouldReload(LocalizationsDelegate<MTTLocalization> old) {
    return false;
  }

  ///全局静态的代理
  static MTTLocalizationsDelegate delegate = MTTLocalizationsDelegate();
}

class ChineseCupertinoLocalizations implements CupertinoLocalizations {
  final materialDelegate = GlobalMaterialLocalizations.delegate;
  final widgetsDelegate = GlobalWidgetsLocalizations.delegate;
  final local = const Locale('zh');

  late MaterialLocalizations ml;

  Future init() async {
    ml = await materialDelegate.load(local);
    print(ml.pasteButtonLabel);
  }

  @override
  String get todayLabel => ml.tabLabel(tabCount: 0, tabIndex: 0);

  @override
  String get alertDialogLabel => ml.alertDialogLabel;

  @override
  String get anteMeridiemAbbreviation => ml.anteMeridiemAbbreviation;

  @override
  String get copyButtonLabel => ml.copyButtonLabel;

  @override
  String get cutButtonLabel => ml.cutButtonLabel;

  @override
  String get modalBarrierDismissLabel => ml.modalBarrierDismissLabel;

  @override
  DatePickerDateOrder get datePickerDateOrder => DatePickerDateOrder.mdy;

  @override
  DatePickerDateTimeOrder get datePickerDateTimeOrder =>
      DatePickerDateTimeOrder.date_time_dayPeriod;

  @override
  String datePickerDayOfMonth(int dayIndex) {
    return dayIndex.toString();
  }

  @override
  String tabSemanticsLabel({ int? tabIndex, int? tabCount }) {
    return tabIndex.toString() + tabCount.toString();
  }

  @override
  String datePickerHour(int hour) {
    return hour.toString().padLeft(2, "0");
  }

  @override
  String datePickerHourSemanticsLabel(int hour) {
    return "$hour" + "时";
  }

  @override
  String datePickerMediumDate(DateTime date) {
    return ml.formatMediumDate(date);
  }

  @override
  String datePickerMinute(int minute) {
    return minute.toString().padLeft(2, '0');
  }

  @override
  String datePickerMinuteSemanticsLabel(int minute) {
    return "$minute" + "分";
  }

  @override
  String datePickerMonth(int monthIndex) {
    return "$monthIndex";
  }

  @override
  String datePickerYear(int yearIndex) {
    return yearIndex.toString();
  }

  @override
  String get pasteButtonLabel => ml.pasteButtonLabel;

  @override
  String get postMeridiemAbbreviation => ml.postMeridiemAbbreviation;

  @override
  String get selectAllButtonLabel => ml.selectAllButtonLabel;

  @override
  String timerPickerHour(int hour) {
    return hour.toString().padLeft(2, "0");
  }

  @override
  String timerPickerHourLabel(int hour) {
    return "$hour".toString().padLeft(2, "0") + "时";
  }

  @override
  String timerPickerMinute(int minute) {
    return minute.toString().padLeft(2, "0");
  }

  @override
  String timerPickerMinuteLabel(int minute) {
    return minute.toString().padLeft(2, "0") + "分";
  }

  @override
  String timerPickerSecond(int second) {
    return second.toString().padLeft(2, "0");
  }

  @override
  String timerPickerSecondLabel(int second) {
    return second.toString().padLeft(2, "0") + "秒";
  }

  static const LocalizationsDelegate<CupertinoLocalizations> delegate =
  _ChineseDelegate();

  static Future<CupertinoLocalizations> load(Locale locale) async {
    var localizations = ChineseCupertinoLocalizations();
    await localizations.init();
    return SynchronousFuture<CupertinoLocalizations>(localizations);
  }

  @override
  // TODO: implement searchTextFieldPlaceholderLabel
  String get searchTextFieldPlaceholderLabel => throw UnimplementedError();

  @override
  // TODO: implement timerPickerHourLabels
  List<String> get timerPickerHourLabels => throw UnimplementedError();

  @override
  // TODO: implement timerPickerMinuteLabels
  List<String> get timerPickerMinuteLabels => throw UnimplementedError();

  @override
  // TODO: implement timerPickerSecondLabels
  List<String> get timerPickerSecondLabels => throw UnimplementedError();
}

class _ChineseDelegate extends LocalizationsDelegate<CupertinoLocalizations> {
  const _ChineseDelegate();

  @override
  bool isSupported(Locale locale) {
    return locale.languageCode == 'zh';
  }

  @override
  Future<CupertinoLocalizations> load(Locale locale) {
    return ChineseCupertinoLocalizations.load(locale);
  }

  @override
  bool shouldReload(LocalizationsDelegate<CupertinoLocalizations> old) {
    return false;
  }
}

