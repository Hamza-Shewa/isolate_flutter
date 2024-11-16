import 'dart:typed_data';

import 'package:image/image.dart';

import 'package:isolate_image_compress/src/log_utils.dart';
import 'package:isolate_image_compress/src/resize_utils.dart';
import 'package:isolate_image_compress/src/constants/enums.dart';

/// Compress Jpeg Image - return empty(*Uint8List(0)*) if image can't be compressed.
///
/// Params:
/// - [data] The image data to compress.
/// - [maxSize] limit file size you want to compress (Bytes). If it is null, return [data].
/// - [maxResolution] limit image resolution you want to compress ([ImageResolution]). Default is [ImageResolution.uhd].
Future<Uint8List> compressJpegImage(Uint8List data,
    {int? maxSize, ImageResolution? maxResolution}) async {
  if (maxSize == null) {
    return data;
  }

  // quality: The JPEG quality, in the range [0, 100] where 100 is highest quality.
  const minQuality = 0;
  const maxQuality = 100;
  const step = 10;

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

      data0 = encodeJpg(image!, quality: maxQuality);
      print('encodeJpg - _maxQuality: ${data0.length}');

      if (data0.length > maxSize) {
        data0 = encodeJpg(image, quality: minQuality);
        print('encodeJpg - _minQuality: ${data0.length}');

        if (data0.length < maxSize) {
          int quality = maxQuality;
          do {
            quality -= step;
            data0 = encodeJpg(image, quality: quality);
            print('encodeJpg - _quality - $quality: ${data0.length}');
          } while (data0.length > maxSize && quality > minQuality);

          break;
        }
      }

      resolution = resolution?.prev();
    } while (resolution != null);

    return data0.length < maxSize ? Uint8List.fromList(data0) : Uint8List(0);
  }
}
