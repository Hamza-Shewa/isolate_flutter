import 'package:image/image.dart';

import 'package:isolate_image_compress/src/constants/enums.dart';
import 'package:isolate_image_compress/src/entity/isolate_image.dart';

extension ResizeOnImage on Image {
  /// Resize image with resolution
  Image resizeWithResolution(ImageResolution resolution) {
    int? newWidth, newHeight;
    if (width < height) {
      if (height > resolution.height) {
        newHeight = resolution.height;
      }
    } else {
      if (width > resolution.width) {
        newWidth = resolution.width;
      }
    }
    if (newWidth != null || newHeight != null) {
      return copyResize(this, width: newWidth, height: newHeight);
    }

    return this;
  }
}

extension ResizeOnIsolateImage on IsolateImage {
  /// Resize image with resolution
  Image? resizeWithResolution(ImageResolution resolution) {
    if (data?.isNotEmpty == true) {
      final image = decodeImage(data!);
      if (image != null) {
        return image.resizeWithResolution(resolution);
      }
    }
    return null;
  }
}
