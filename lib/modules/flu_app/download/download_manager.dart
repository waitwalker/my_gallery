import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:my_gallery/modules/flu_app/download/dio_manager.dart';
import 'package:my_gallery/modules/flu_app/download/download_protocol.dart';


class AssetRepository implements AssetRepositoryProtocol {
  AssetRepository(this.httpManager);

  final DioManager httpManager;

  @override
  Future<String> downloadAsset(String url,
      {String? subDir,
        ProgressCallBack? onReceiveProgress,
        CancelTokenProvider? cancelTokenProvider,
        Function(String)? done,
        Function(Exception)? failed}) async {
    CancelToken cancelToken = CancelToken();
    if (cancelTokenProvider != null) {
      cancelTokenProvider(cancelToken);
    }

    final savePath = await _getSavePath(url, subDir: subDir);
    try {
      httpManager.downloadFile(
          url: url,
          savePath: savePath + '.temp',
          onReceiveProgress: onReceiveProgress,
          cancelToken: cancelToken,
          done: () {
            done?.call(savePath);
          },
          failed: (e) {
            print(e);
            failed?.call(e);
          });
      return savePath;
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  @override
  void cancelDownload(CancelToken cancelToken) {
    try {
      if (!cancelToken.isCancelled) {
        cancelToken.cancel();
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Future<String?> filePathForAsset(String url, {String? subDir}) async {
    final path = await _getSavePath(url, subDir: subDir);
    final file = File(path);
    if (!(await file.exists())) {
      return null;
    }
    return path;
  }

  @override
  Future<String?> checkCachedSuccess(String url, {String? md5Str}) async {
    String? path = await _getSavePath(url, subDir: "");
    bool isCached = await File(path).exists();
    if (isCached && (md5Str != null && md5Str.isNotEmpty)) {
      // 存在但是md5验证不通过
      File(path).readAsBytes().then((Uint8List str) {
        /// 校验md5
        // if (md5.convert(str).toString() != md5Str) {
        //   path = null;
        // }
      });
    } else if (isCached) {
      return path;
    } else {
      path = null;
    }
    return path;
  }

  @override
  Future<int> cachedFileSize({String? subDir}) async {
    final dir = await _getDir(subDir: subDir);
    if (!(await dir.exists())) {
      return 0;
    }

    int totalSize = 0;
    await for (var entity in dir.list(recursive: true)) {
      if (entity is File) {
        try {
          totalSize += await entity.length();
        } catch (e) {
          print('Get size of $entity failed with exception: $e');
        }
      }
    }

    return totalSize;
  }

  @override
  Future<void> clearCache({String? subDir}) async {
    final dir = await _getDir(subDir: subDir);
    if (!(await dir.exists())) {
      return;
    }
    dir.deleteSync(recursive: true);
  }

  Future<String> _getSavePath(String url, {String? subDir}) async {
    final saveDir = await _getDir(subDir: subDir);

    if (!saveDir.existsSync()) {
      saveDir.createSync(recursive: true);
    }

    final uri = Uri.parse(url);
    final fileName = uri.pathSegments.last;
    return saveDir.path + fileName;
  }

  Future<Directory> _getDir({String? subDir}) async {
    String cacheDir = "";//await getTemporaryDirectory();
    late final Directory saveDir;
    if (subDir == null) {
      saveDir = cacheDir;
    } else {
      saveDir = Directory("cacheDir.path" + '/$subDir/');
    }
    return saveDir;
  }
}