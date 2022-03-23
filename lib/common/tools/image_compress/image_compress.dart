import 'dart:async';
import 'dart:io';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:image_size_getter/file_input.dart';
import 'package:image_size_getter/image_size_getter.dart';

///
/// @name ImageCompressManager
/// @description 图片尺寸&质量压缩
/// @author waitwalker
/// @date 2020/5/11
///
class ImageCompressManager {

  ///
  /// @name compressImage
  /// @description 压缩本地图片
  /// @parameters
  /// @return 压缩后的图片
  /// @author waitwalker
  /// @date 2020/5/11
  ///
  static Future<File?> compressImage(File image) async {

    Size imageDimension = ImageSizeGetter.getSize(FileInput(image));
    print("图片的原生分辨率:$imageDimension");
    File? compressedImage;
    // 1 宽高均 <= 1280，图片尺寸大小保持不变
    if (imageDimension.width <= 1280 && imageDimension.height <= 1280) {
      compressedImage = image;
    }
    // 2 宽高均大于1280
    else if (imageDimension.width > 1280 && imageDimension.height > 1280) {
      // 2.1 宽高比大于2 取高1280 宽等比例缩放
      if ((imageDimension.width / imageDimension.height) > 2.0) {
        var scale = (imageDimension.width / imageDimension.height);
        compressedImage = await FlutterNativeImage.compressImage(image.path,
            quality: 100,
            percentage: 100,
            targetHeight: 1280,
            targetWidth: (1280 * scale).toInt());
      }
      // 2.2 宽高比小于0.5 取宽1280, 高等比例缩放
      else if ((imageDimension.width / imageDimension.height) < 0.5){
        var scale = (imageDimension.width / imageDimension.height);
        compressedImage = await FlutterNativeImage.compressImage(image.path,
            quality: 100,
            percentage: 100,
            targetHeight: (1280 * scale).toInt(),
            targetWidth: 1280);
      }
      // 2.3 宽高比介于0.5 ~ 2.0,取宽或高为1280 另一边等比例缩放
      else {
        var scale = (imageDimension.width / imageDimension.height);
        if (imageDimension.width > imageDimension.height) {
          compressedImage = await FlutterNativeImage.compressImage(image.path,
              quality: 100,
              percentage: 100,
              targetHeight: 1280~/scale,
              targetWidth: 1280);
        } else {
          compressedImage = await FlutterNativeImage.compressImage(image.path,
              quality: 100,
              percentage: 100,
              targetHeight: 1280,
              targetWidth: 1280 ~/ scale);
        }
      }
    }
    // 3 宽或高大于1280
    else {
      // 3.1 宽高比大与2(宽图) 或者小于0.5(长图)  大小不变, 可以做压缩图片质量
      if ((imageDimension.width / imageDimension.height) > 2.0 || (imageDimension.width / imageDimension.height) < 0.5) {
        compressedImage = image;
      }
      // 3.2 宽大于高, 取较大值W = 1280, H等比压缩;
      else if (imageDimension.width > imageDimension.height) {
        var scale = (imageDimension.width / imageDimension.height);
        compressedImage = await FlutterNativeImage.compressImage(image.path,
            quality: 100,
            percentage: 100,
            targetHeight: (1280 * scale).toInt(),
            targetWidth: 1280);
      }
      // 3.3 高大于宽, 去较大值H = 1280. W等比压缩
      else if (imageDimension.width < imageDimension.height) {
        var scale = (imageDimension.width / imageDimension.height);
        compressedImage = await FlutterNativeImage.compressImage(image.path,
            quality: 100,
            percentage: 100,
            targetHeight: 1280,
            targetWidth: (1280 * scale).toInt());
      }
    }
    int imageSize = await compressedImage!.length();
    double imageScale = imageSize.toDouble() / 1024.0 / 1024.0;
    print("压缩后图片大小:$imageScale Mb");
    final size = ImageSizeGetter.getSize(FileInput(compressedImage));
    print("压缩后图片尺寸:$size");

    // 如果压缩后的图片尺寸大于1.0MB 在对质量进行70%压缩
    if (imageScale > 1.0) {
      compressedImage = await FlutterNativeImage.compressImage(compressedImage.path,quality: 70);
    }
    return compressedImage;
  }

  ///
  /// @description 图片压缩质量
  /// @param
  /// @return 
  /// @author waitwalker
  /// @time 2020/10/9 12:03 PM
  ///
  static Future<File> compressImageQuality(File file) async {
    int imageSize = await file.length();
    final originalSize = ImageSizeGetter.getSize(FileInput(file));
    print("压缩之前图片宽高:$originalSize");
    int quality = 100;
    if (imageSize > 5000000) {
      quality = 25;
      if (Platform.isAndroid) quality = 35;
    } else if (imageSize > 4000000) {
      quality = 30;
      if (Platform.isAndroid) quality = 40;
    } else if (imageSize > 3000000) {
      quality = 35;
      if (Platform.isAndroid) quality = 45;
    } else if (imageSize > 2000000) {
      quality = 50;
      if (Platform.isAndroid) quality = 55;
    } else if (imageSize > 1500000) {
      quality = 75;
    } else if (imageSize > 1000000) {
      quality = 85;
    } else {
      quality = 100;
    }

    File compressedImage = await FlutterNativeImage.compressImage(
      file.path,
      quality: quality,
      percentage: 100,
    );
    final compressedSize = ImageSizeGetter.getSize(FileInput(compressedImage));
    print("压缩之后图片宽高:$compressedSize");
    return compressedImage;
  }
}

///
/// @name ImageCompressManager
/// @description 图片尺寸&质量压缩
/// @author waitwalker
/// @date 2020/5/11
///
// class ImageCompressManager {
//
//   ///
//   /// @name compressImage
//   /// @description 压缩本地图片
//   /// @parameters
//   /// @return 压缩后的图片
//   /// @author waitwalker
//   /// @date 2020/5/11
//   ///
//   static Future<File> compressImage(File image) async {
//
//     Size imageDimension = ImageSizGetter.getSize(image);
//     print("图片的原生分辨率:$imageDimension");
//     File compressedImage;
//     // 1 宽高均 <= 1280，图片尺寸大小保持不变
//     if (imageDimension.width <= 1280 && imageDimension.height <= 1280) {
//       compressedImage = image;
//     }
//     // 2 宽高均大于1280
//     else if (imageDimension.width > 1280 && imageDimension.height > 1280) {
//       // 2.1 宽高比大于2 取高1280 宽等比例缩放
//       if ((imageDimension.width / imageDimension.height) > 2.0) {
//         var scale = (imageDimension.width / imageDimension.height);
//         compressedImage = await FlutterNativeImage.compressImage(image.path,
//             quality: 100,
//             percentage: 100,
//             targetHeight: 1280,
//             targetWidth: (1280 * scale).toInt());
//       }
//       // 2.2 宽高比小于0.5 取宽1280, 高等比例缩放
//       else if ((imageDimension.width / imageDimension.height) < 0.5){
//         var scale = (imageDimension.width / imageDimension.height);
//         compressedImage = await FlutterNativeImage.compressImage(image.path,
//             quality: 100,
//             percentage: 100,
//             targetHeight: (1280 * scale).toInt(),
//             targetWidth: 1280);
//       }
//       // 2.3 宽高比介于0.5 ~ 2.0,取宽或高为1280 另一边等比例缩放
//       else {
//         var scale = (imageDimension.width / imageDimension.height);
//         if (imageDimension.width > imageDimension.height) {
//           compressedImage = await FlutterNativeImage.compressImage(image.path,
//               quality: 100,
//               percentage: 100,
//               targetHeight: (1280 / scale).toInt(),
//               targetWidth: 1280);
//         } else {
//           compressedImage = await FlutterNativeImage.compressImage(image.path,
//               quality: 100,
//               percentage: 100,
//               targetHeight: 1280,
//               targetWidth: (1280 / scale).toInt());
//         }
//       }
//     }
//     // 3 宽或高大于1280
//     else {
//       // 3.1 宽高比大与2(宽图) 或者小于0.5(长图)  大小不变, 可以做压缩图片质量
//       if ((imageDimension.width / imageDimension.height) > 2.0 || (imageDimension.width / imageDimension.height) < 0.5) {
//         compressedImage = image;
//       }
//       // 3.2 宽大于高, 取较大值W = 1280, H等比压缩;
//       else if (imageDimension.width > imageDimension.height) {
//         var scale = (imageDimension.width / imageDimension.height);
//         compressedImage = await FlutterNativeImage.compressImage(image.path,
//             quality: 100,
//             percentage: 100,
//             targetHeight: (1280 * scale).toInt(),
//             targetWidth: 1280);
//       }
//       // 3.3 高大于宽, 去较大值H = 1280. W等比压缩
//       else if (imageDimension.width < imageDimension.height) {
//         var scale = (imageDimension.width / imageDimension.height);
//         compressedImage = await FlutterNativeImage.compressImage(image.path,
//             quality: 100,
//             percentage: 100,
//             targetHeight: 1280,
//             targetWidth: (1280 * scale).toInt());
//       }
//     }
//     int imageSize = await compressedImage.length();
//     double imageScale = imageSize.toDouble() / 1024.0 / 1024.0;
//     print("压缩后图片大小:$imageScale Mb");
//     print("压缩后图片尺寸:${ImageSizGetter.getSize(compressedImage)}");
//
//     // 如果压缩后的图片尺寸大于1.0MB 在对质量进行70%压缩
//     if (imageScale > 1.0) {
//       compressedImage = await FlutterNativeImage.compressImage(compressedImage.path,quality: 70);
//     }
//     return compressedImage;
//   }
// }