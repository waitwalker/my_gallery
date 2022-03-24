import 'package:flutter/material.dart';
import 'package:redux/redux.dart';

// ignore: non_constant_identifier_names
final LocaleReducer = combineReducers<Locale?>([
  TypedReducer<Locale?,RefreshLocaleAction>(_refresh),
]);

Locale _refresh(Locale? locale, RefreshLocaleAction action) {
  locale = action.locale;
  return locale;
}

///
/// @Class: RefreshLocaleAction
/// @Description: 国际化事件Action
/// @author: lca
/// @Date: 2019-08-01
///
class RefreshLocaleAction {
  final Locale locale;
  RefreshLocaleAction(this.locale);
}