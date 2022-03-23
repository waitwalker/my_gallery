import 'package:flutter/material.dart';
import 'package:notification_permissions/notification_permissions.dart';

class CommonNotificationPermissionPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _CommonNotificationPermissionState();
  }
}

class _CommonNotificationPermissionState extends State<CommonNotificationPermissionPage> with WidgetsBindingObserver {

  Future<String>? permissionStatusFuture;
  var permGranted = "granted";
  var permDenied = "denied";
  var permUnknown = "unknown";

  @override
  void initState() {
    // set up the notification permissions class
    // set up the future to fetch the notification data
    permissionStatusFuture = getCheckNotificationPermStatus();
    // With this, we will be able to check if the permission is granted or not
    // when returning to the application
    WidgetsBinding.instance!.addObserver(this);
    super.initState();
  }

  /// When the application has a resumed status, check for the permission
  /// status
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      setState(() {
        permissionStatusFuture = getCheckNotificationPermStatus();
      });
    }
  }

//  @override
//  Widget build(BuildContext context) {
//    return Scaffold(
//      appBar: AppBar(
//        title: Text("通知权限"),
//      ),
//      body: Center(
//        child: Text("通知权限"),
//      ),
//    );
//  }

  /// Checks the notification permission status
  Future<String> getCheckNotificationPermStatus() {
    return NotificationPermissions.getNotificationPermissionStatus()
        .then((status) {
      switch (status) {
        case PermissionStatus.denied:
          return permDenied;
        case PermissionStatus.granted:
          return permGranted;
        default:
          return permUnknown;
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('通知权限'),
      ),
      body: Center(
          child: Container(
            margin: EdgeInsets.all(20),
            child: FutureBuilder(
                future: permissionStatusFuture,
                builder: (context, snapshot) {
                  // if we are waiting for data, show a progress indicator
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  }
                  if (snapshot.hasData) {
                    var textWidget = Text(
                      "The permission status is ${snapshot.data}",
                      style: TextStyle(fontSize: 20),
                      softWrap: true,
                      textAlign: TextAlign.center,
                    );
                    // The permission is granted, then just show the text
                    if (snapshot.data == permGranted) {
                      return textWidget;
                    }

                    // else, we'll show a button to ask for the permissions
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        textWidget,
                        SizedBox(
                          height: 20,
                        ),
                        TextButton(
                          style: ButtonStyle(
                            backgroundColor: ButtonStyleButton.allOrNull<Color>(Colors.amber),
                          ),
                          child:
                          Text("Ask for notification status".toUpperCase()),
                          onPressed: () {
                            // show the dialog/open settings screen
                            NotificationPermissions
                                .requestNotificationPermissions(
                                iosSettings:
                                const NotificationSettingsIos(
                                    sound: true,
                                    badge: true,
                                    alert: true))
                                .then((_) {
                              // when finished, check the permission status
                              setState(() {
                                permissionStatusFuture =
                                    getCheckNotificationPermStatus();
                              });
                            });
                          },
                        )
                      ],
                    );
                  }
                  return Text("No permission status yet");
                }),
          )),
    );
  }
}