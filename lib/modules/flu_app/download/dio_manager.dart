import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';

class DioManager {
  final downloadDio = Dio();

  Future<void> downloadFile({
    required String url,
    required String savePath,
    required CancelToken cancelToken,
    ProgressCallback? onReceiveProgress,
    void Function()? done,
    void Function(Exception)? failed,
  }) async {
    int downloadStart = 0;
    File f = File(savePath);
    if (await f.exists()) {
      // 文件存在时拿到已下载的字节数
      downloadStart = f.lengthSync();
    }
    print("start: $downloadStart");
    try {
      var response = await downloadDio.get<ResponseBody>(
        url,
        options: Options(
          /// Receive response data as a stream
          responseType: ResponseType.stream,
          followRedirects: false,
          headers: {
            /// 加入range请求头，实现断点续传
            "range": "bytes=$downloadStart-",
          },
        ),
      );
      File file = File(savePath);
      RandomAccessFile raf = file.openSync(mode: FileMode.append);
      int received = downloadStart;
      int total = 20;//await _getContentLength(response);
      Stream<Uint8List> stream = response.data!.stream;
      StreamSubscription<Uint8List>? subscription;
      subscription = stream.listen(
            (data) {
          /// Write files must be synchronized
          raf.writeFromSync(data);
          received += data.length;
          onReceiveProgress?.call(received, total);
        },
        onDone: () async {
          file.rename(savePath.replaceAll('.temp', ''));
          await raf.close();
          done?.call();
        },
        onError: (e) async {
          await raf.close();
          failed?.call(e);
        },
        cancelOnError: true,
      );
      cancelToken.whenCancel.then((_) async {
        await subscription?.cancel();
        await raf.close();
      });
    } on DioError catch (error) {
      if (CancelToken.isCancel(error)) {
        print("Download cancelled");
      } else {
        failed?.call(error);
      }
    }
  }
}

