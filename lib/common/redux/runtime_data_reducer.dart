import 'package:my_gallery/common/runtime_data/runtime_data.dart';
import 'package:redux/redux.dart';

// ignore: non_constant_identifier_names
final RuntimeDataReducer = combineReducers<RuntimeData?>([
  TypedReducer<RuntimeData?,RefreshRuntimeDataAction>(_refresh),
]);

RuntimeData _refresh(RuntimeData? runtimeData, RefreshRuntimeDataAction action) {
  runtimeData = action.runtimeData;
  return runtimeData;
}

///
/// @Class: RefreshRuntimeDataAction
/// @Description: 运行时事件Action
/// @author: lca
/// @Date: 2019-11-07
///
class RefreshRuntimeDataAction {
  final RuntimeData runtimeData;
  RefreshRuntimeDataAction(this.runtimeData);
}