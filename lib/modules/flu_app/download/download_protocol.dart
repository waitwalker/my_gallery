import 'package:dio/dio.dart';

typedef ProgressCallBack = void Function(int count, int total);

typedef CancelTokenProvider = void Function(CancelToken cancelToken);

abstract class AssetRepositoryProtocol {
  /// 下载单一资源
  Future<String> downloadAsset(String url,
      {String? subDir,
        ProgressCallBack? onReceiveProgress,
        CancelTokenProvider? cancelTokenProvider,
        Function(String)? done,
        Function(Exception)? failed});

  /// 取消下载，Dio中通过CancelToken可控制
  void cancelDownload(CancelToken cancelToken);

  /// 获取文件的缓存地址
  Future<String?> filePathForAsset(String url, {String? subDir});

  /// 检查文件是否缓存成功，简单对比md5
  Future<String?> checkCachedSuccess(String url, {String? md5Str});

  /// 查看缓存文件的大小
  Future<int> cachedFileSize({String? subDir});

  /// 清除缓存
  Future<void> clearCache({String? subDir});
}