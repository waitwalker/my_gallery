// 关键类型定义

import 'package:flutter/material.dart';

class LActionCallback {
  /// 错误码
  int code;

  /// 信息描述
  String desc;

  LActionCallback({this.code = 0, this.desc = ''});
}

class LTRTCLiveRoomConfig {
  /// 【字段含义】观众端使用CDN播放
  /// 【特殊说明】true: 默认进房使用CDN播放 false: 使用低延时播放
  bool useCDNFirst;

  /// 【字段含义】CDN播放的域名地址
  String? cdnPlayDomain;
  LTRTCLiveRoomConfig({required this.useCDNFirst, this.cdnPlayDomain});
}

class LIMAnchorInfo {
  String? userId;
  String? streamId;
  String? name;

  LIMAnchorInfo({this.userId, this.streamId, this.name});
}

class LRoomInfo {
  /// 【字段含义】房间唯一标识
  int roomId;

  /// 【字段含义】房间名称
  String? roomName;

  /// 【字段含义】房间封面图
  String? coverUrl;

  /// 【字段含义】房主id
  String? ownerId;

  /// 【字段含义】房主昵称
  String? ownerName;

  /// 【字段含义】房间人数
  int? memberCount;

  LRoomInfo(
      {required this.roomId,
        this.roomName,
        this.coverUrl,
        this.memberCount,
        required this.ownerId,
        this.ownerName});
}

class LRoomInfoCallback {
  /// 错误码
  int code;

  /// 信息描述
  String desc;

  List<LRoomInfo>? list;

  LRoomInfoCallback({required this.code, required this.desc, this.list});
}

class LRoomParam {
  /// 房间名称
  String roomName;

  /// 房间封面图
  String? coverUrl;

  /// 音质
  int? quality;

  LRoomParam({required this.roomName, this.coverUrl, this.quality});
}

class LMemberListCallback {
  /// 错误码
  int code;

  /// 信息描述
  String desc;

  /// nextSeq	分页拉取标志，第一次拉取填0，回调成功如果 nextSeq 不为零，需要分页，传入再次拉取，直至为0。
  int nextSeq;

  List<LUserInfo>? list;

  LMemberListCallback(
      {this.code = 0, this.desc = '', this.nextSeq = 0, this.list});
}

class LUserListCallback {
  /// 错误码
  int code;

  /// 信息描述
  String desc;

  /// 用户信息列表
  List<LUserInfo>? list;

  /// nextSeq	分页拉取标志，第一次拉取填0，回调成功如果 nextSeq 不为零，需要分页，传入再次拉取，直至为0。
  int nextSeq;

  LUserListCallback(
      {this.code = 0, this.desc = '', this.list, this.nextSeq = 0});
}

class LUserInfo {
  /// 用户唯一标识
  String? userId;

  /// 用户昵称
  String? userName;

  /// 用户头像
  String? userAvatar;

  LUserInfo({
    required this.userId,
    this.userName,
    this.userAvatar,
  });
}
