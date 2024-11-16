import 'dart:typed_data';

import 'package:image/image.dart';

import 'package:isolate_image_compress/src/log_utils.dart';
import 'package:isolate_image_compress/src/resize_utils.dart';
import 'package:isolate_image_compress/src/constants/enums.dart';

/// Compress PNG Image - return empty(*Uint8List(0)*) if image can't be compressed.
///
/// Params:
/// - [data] The image data to compress.
/// - [maxSize] limit file size you want to compress (Bytes). If it is null, return [data].
/// - [maxResolution] limit image resolution you want to compress ([ImageResolution]). Default is [ImageResolution.uhd].
Future<Uint8List> compressPngImage(Uint8List data,
    {int? maxSize, ImageResolution? maxResolution}) async {
  if (maxSize == null) {
    return data;
  }

  // level: The compression level, in the range [0, 9] where 9 is the most compressed.
  const minLevel = 0;
  const maxLevel = 9;
  const step = 1;

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

      data0 = encodePng(image!, level: minLevel);
      print('encodePNG - _minLevel: ${data0.length}');

      if (data0.length > maxSize) {
        data0 = encodePng(image, level: maxLevel);
        print('encodePNG - _maxLevel: ${data0.length}');

        if (data0.length < maxSize) {
          int level = minLevel;
          do {
            level += step;
            data0 = encodePng(image, level: level);
            print('encodePNG - _level - $level: ${data0.length}');
          } while (data0.length > maxSize && level < maxLevel);

          break;
        }
      }
      resolution = resolution?.prev();
    } while (resolution != null);

    return data0.length < maxSize ? Uint8List.fromList(data0) : Uint8List(0);
  }
}
