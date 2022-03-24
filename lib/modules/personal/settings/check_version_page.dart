import 'dart:io';
import 'package:my_gallery/common/dao/original_dao/common_api.dart';
import 'package:my_gallery/model/check_update_model.dart';
import 'package:my_gallery/common/const/api_const.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:package_info/package_info.dart';
import 'package:url_launcher/url_launcher.dart';


///
/// @description 检查版本更新
/// @author waitwalker
/// @time 2021/5/7 13:39
///
mixin CheckVersionPage<T extends StatefulWidget> on State<T> {
  Future checkUpdate({bool showToast = false}) async {
    var model = await checkVersionSilence();
    await showNewVersionDialog(model, showToast);
  }

  Future checkVersionSilence() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    var versionName = 'V${packageInfo.version}';
    var checkUpdate = await CommonServiceDao.checkUpdate(version: versionName);
    if (checkUpdate.result && checkUpdate.model != null) {
      var model = checkUpdate.model as CheckUpdateModel?;
      return model;
    }
    return null;
  }

  Future showNewVersionDialog(model, bool showToast) async {
    if (model != null) {
      if (model.result == 1) {
        var data = model.data;
        if (data.forceType == 1 || model.data.forceType == 2) {
          showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) {
                List<Widget> actions = <Widget>[
                  TextButton(
                    onPressed: () async {
                      if (Platform.isIOS) {
                        Navigator.of(context).pop();
                        await launch(APIConst.appStoreURL);
                        return;
                      } else {
                        await launch(data.url);
                        if (data.forceType == 2) {
                        } else {
                          Navigator.of(context).pop();
                        }
                      }
                    },
                    child: Text('确定'),
                  ),
                ];
                if (Platform.isIOS){
                  var cancel = TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text('取消'),
                  );
                  actions.add(cancel);
                } else {
                  if (model.data.forceType == 1) {
                    var cancel = TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text('取消'),
                    );
                    actions.add(cancel);
                  }
                }
                return WillPopScope(
                  onWillPop: () => Future.value(model.data.forceType == 1),
                  child: AlertDialog(
                      title: Text(data.title),
                      content: Text(data.message),
                      actions: actions),
                );
              });
        } else if (showToast) {
          Fluttertoast.showToast(msg: '已是最新版了', gravity: ToastGravity.CENTER);
        }
      } else {
        Fluttertoast.showToast(
            msg: model.msg ?? '已经是最新版了', gravity: ToastGravity.CENTER);
      }
    }
  }
}
