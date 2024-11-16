import 'dart:typed_data';

import 'package:image/image.dart';

import 'package:isolate_image_compress/src/log_utils.dart';
import 'package:isolate_image_compress/src/resize_utils.dart';
import 'package:isolate_image_compress/src/constants/enums.dart';

/// Compress Gif Image - return empty(*Uint8List(0)*) if image can't be compressed.
///
/// Params:
/// - [data] The image data to compress.
/// - [maxSize] limit file size you want to compress (Bytes). If it is null, return [data].
/// - [maxResolution] limit image resolution you want to compress ([ImageResolution]). Default is [ImageResolution.uhd].
Future<Uint8List> compressGifImage(Uint8List data,
    {int? maxSize, ImageResolution? maxResolution}) async {
  if (maxSize == null) {
    return data;
  }

  ImageResolution? resolution = maxResolution ?? ImageResolution.uhd;

  Image? image = decodeImage(data);
  if (image == null) {
    return Uint8List(0);
  } else {
    List<int>? data0;
    do {
      if (resolution != null) {
        image = image!.resizeWithResolution(resolution);
        print(
            'resizeWithResolution: ${resolution.width} - ${resolution.height}');
      }
      data0 = encodeGif(image!);
      print('encodeGif - length: ${data0.length}');
      if (data0.length < maxSize) {
        break;
      }

      resolution = resolution?.prev();
    } while (resolution != null);

    return data0.length < maxSize ? Uint8List.fromList(data0) : Uint8List(0);
  }
}
