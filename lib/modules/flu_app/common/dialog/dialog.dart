import 'package:flutter/material.dart';

/// @fileName DialogManager
/// @description 弹窗管理类 根据不同的类型显示弹窗
/// 1：金币；
/// 2：红包券；
/// 3：奖励；
/// 4：强制版本更新；
/// 5：非强制版本更新；
/// 6：纯文本；
/// 7：图片事件弹窗
/// @date 2022/3/16 3:52 下午
/// @author LiuChuanan
class DialogManager {
  static showDialogType(
      BuildContext context,{
        required int dialogType,
        Function()? eventAction1,
        Function()? eventAction2,
        bool? barrierDismissible = true,
        bool? onWillPop = false,
        String? title,
        String? content,
        String? subTitle,
        String? buttonTitle,
        String? imagePath,
      }) async{
    await showDialog(
      barrierDismissible: barrierDismissible!,
      context: context,
      builder: (context){
        return DialogPage(
          dialogType: dialogType,
          eventAction1: eventAction1,
          eventAction2: eventAction2,
          onWillPop: onWillPop,
          title: title,
          content: content,
          subTitle: subTitle,
          buttonTitle: buttonTitle,
          imagePath: imagePath,
        );
      },
    );
  }
}

class DialogPage extends StatelessWidget {
  /// 弹窗类型
  final int dialogType;
  /// 通用事件1回调
  final Function()? eventAction1;
  /// 通用事件2回调
  final Function()? eventAction2;
  /// onWillPop
  final bool? onWillPop;
  /// 标题
  final String? title;
  /// 内容
  final String? content;
  /// 副标题
  final String? subTitle;
  /// 按钮标题
  final String? buttonTitle;
  /// 图片路径
  final String? imagePath;
  const DialogPage({
    Key? key,
    required this.dialogType,
    this.eventAction1,
    this.eventAction2,
    this.onWillPop,
    this.title,
    this.content,
    this.subTitle,
    this.buttonTitle,
    this.imagePath,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
      backgroundColor: Colors.black.withOpacity(0.2),
      body: Padding(
        padding: const EdgeInsets.only(
          left: 55,
          right: 55,
        ),
        child: Center(
          child: _builderContent(dialogType, context),
        ),
      ),
    ),
      onWillPop: () async{
        return onWillPop!;
      },
    );
  }

  /// methodName _builderContent
  /// description 构建不同类型dialog body
  /// date 2022/3/16 4:10 下午
  /// author LiuChuanan
  _builderContent(int type, BuildContext context) {
    switch (type) {
      case 1:
      case 2:
        return Container(
          alignment: Alignment.center,
          height: 405,
          width: 265,
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(
                      imagePath!,
                    ),
                    fit: BoxFit.fill,
                  ),
                ),
              ),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [

                    Padding(
                      padding: const EdgeInsets.only(
                        bottom: 20,
                        left: 10,
                        right: 10,
                      ),
                      child: Text(
                        title!,
                        maxLines: 1,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.only(
                        bottom: 16,
                        left: 10,
                        right: 10,
                      ),
                      child: Text(
                        content!,
                        maxLines: 1,
                        style: const TextStyle(
                          fontSize: 30,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    Padding(
                        padding: const EdgeInsets.only(
                          bottom: 12,
                          left: 10,
                          right: 10,
                        ),
                      child: Text(
                        subTitle!,
                        maxLines: 1,
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.white,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.only(
                        left: 33,
                        right: 33,
                        bottom: 24,
                      ),
                      child: InkWell(
                        child: Container(
                          height: 52,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: const Color(0xff0A2267),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(
                                left: 5,
                                right: 5),
                            child: Text(
                              buttonTitle!,
                              maxLines: 1,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        onTap: eventAction2,
                      ),
                    ),

                  ],
                ),
              ),

              /// 关闭按钮
              Positioned(
                top: 30,
                right: 0,
                child: Center(
                  child: GestureDetector(
                    child: Container(
                      alignment: Alignment.centerRight,
                      height: 60,
                      width: 60,
                      color: Colors.transparent,
                      child: Image.asset("static/images/dialog_close_icon.webp"),
                    ),
                    onTap: eventAction1,
                  ),
                ),
              ),
            ],
          ),
        );
      case 3:
        return Container(
          alignment: Alignment.center,
          height: 405,
          width: 265,
          child: Stack(
            children: [
              Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(
                      "static/images/dialog_bg_common.webp",
                    ),
                    fit: BoxFit.fill,
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Center(
                    child: Container(
                      height: 180,
                      width: 180,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(
                            imagePath!,
                          ),
                        ),
                      ),
                    ),
                  ),

                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12, right: 10, left: 10,),
                        child: Text(
                          title!,
                          maxLines: 1,
                          style: const TextStyle(
                            fontSize: 19,
                            color: Colors.green,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.only(bottom: 10, left: 10, right: 10,),
                        child: SizedBox(
                          height: 80,
                          child: Text(
                            content!,
                            maxLines: 2,
                            style: const TextStyle(
                              height: 1,
                              fontSize: 33,
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.only(
                          bottom: 26,
                          left: 33,
                          right: 33,
                        ),
                        child: InkWell(
                          child: Container(
                            alignment: Alignment.center,
                            height: 52,
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: Padding(padding: const EdgeInsets.only(left: 5, right: 5),
                              child: Text(
                                buttonTitle!,
                                maxLines: 2,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          onTap: eventAction2,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Positioned(
                right: 0,
                child: GestureDetector(
                  child: Container(
                    alignment: Alignment.centerRight,
                    height: 60,
                    width: 60,
                    color: Colors.transparent,
                    child: Image.asset("static/images/dialog_close_icon.webp"),
                  ),
                  onTap: eventAction1,
                ),
              ),
            ],
          ),
        );
      case 4:
      case 5:
        return Container(
          alignment: Alignment.center,
          constraints: const BoxConstraints.expand(height: 410, width: 265),
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage(
                "static/images/dialog_bg_update.webp",
              ),
              fit: BoxFit.fill,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Padding(padding: EdgeInsets.only(top: 116)),

              const Text("更新",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              ),

              const Padding(padding: EdgeInsets.only(top: 60)),

              Padding(
                padding: const EdgeInsets.only(
                  left: 22,
                  right: 22,
                  // top: 65.h,
                ),
                child: SizedBox(
                  height: 130,
                  child: ListView(
                    children: [
                      Text(title!,
                        maxLines: 2,
                        style: const TextStyle(
                          height: 1,
                          color: Colors.black,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        content!,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.only(
                  left: 22,
                  right: 22,
                  top: 15
                ),
                child: Row(
                  children: [
                    if (type == 4) Expanded(
                      flex: 1,
                      child: InkWell(
                        child: Container(
                          alignment: Alignment.center,
                          height: 50,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.0),
                            color: const Color(0xffEFD963),
                          ),
                          child: const Text("稍后更新",
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        onTap: eventAction1,
                      ),),
                    if (type == 4) const Padding(padding: EdgeInsets.only(left: 12)),
                    Expanded(
                      flex: 1,
                      child: InkWell(
                        child: Container(
                          alignment: Alignment.center,
                          height: 50,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.0),
                            color: const Color(0xff5E9549),
                          ),
                          child: const Text("马上更新",
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        onTap: eventAction2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      case 6:
        return Container(
          constraints: const BoxConstraints.expand(height: 350),
          color: Colors.transparent,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              GestureDetector(
                child: Container(
                  alignment: Alignment.centerRight,
                  height: 60,
                  width: 60,
                  color: Colors.transparent,
                  child: Image.asset("static/images/dialog_close_icon.webp"),
                ),
                onTap: eventAction1,
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  color: Colors.white,
                ),
                alignment: Alignment.center,
                width: MediaQuery.of(context).size.width,
                height: 260,
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 22,
                    right: 22,
                  ),
                  child: Text(content!,
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),

            ],
          ),
        );
      case 7:
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                GestureDetector(
                  child: Container(
                    alignment: Alignment.centerRight,
                    height: 60,
                    width: 60,
                    color: Colors.transparent,
                    child: Image.asset("static/images/dialog_close_icon.webp"),
                  ),
                  onTap: eventAction1,
                ),
              ],
            ),
            InkWell(
              child: Container(
                constraints: const BoxConstraints.expand(height: 400),
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(
                      imagePath!,
                    ),
                    fit: BoxFit.fitWidth,
                  ),
                ),
              ),
              onTap: eventAction2,
            ),
          ],
        );
    }
  }
}