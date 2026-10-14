import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class PhotoStore {
  Future<String> persist(String sourcePath) async {
    final root = await getApplicationDocumentsDirectory();
    final folder = Directory(p.join(root.path, 'cat_photos'));
    await folder.create(recursive: true);
    final name = '${DateTime.now().microsecondsSinceEpoch}.jpg';
    final dest = File(p.join(folder.path, name));
    final bytes = await File(sourcePath).readAsBytes();
    final cropped = centerCatPhoto(bytes);
    await dest.writeAsBytes(compressStoredPhoto(cropped ?? bytes));
    return dest.path;
  }
}

/// Crops a square around the non-background subject and keeps that subject
/// in the middle. Photos that cannot be decoded are returned unchanged.
Uint8List? centerCatPhoto(Uint8List bytes) {
  final decoded = img.decodeImage(bytes);
  if (decoded == null || decoded.width < 8 || decoded.height < 8) return null;
  final work = decoded.width > 360
      ? img.copyResize(decoded, width: 360)
      : decoded;
  final scaleX = decoded.width / work.width;
  final scaleY = decoded.height / work.height;
  var minX = work.width;
  var minY = work.height;
  var maxX = 0;
  var maxY = 0;
  var count = 0;
  var sumX = 0;
  var sumY = 0;
  for (var y = 0; y < work.height; y += 2) {
    for (var x = 0; x < work.width; x += 2) {
      if (!_isSubject(work.getPixel(x, y))) continue;
      count++;
      sumX += x;
      sumY += y;
      if (x < minX) minX = x;
      if (y < minY) minY = y;
      if (x > maxX) maxX = x;
      if (y > maxY) maxY = y;
    }
  }
  if (count < 24) return img.encodeJpg(decoded, quality: 85);
  final cx = (sumX / count * scaleX).round();
  final cy = (sumY / count * scaleY).round();
  var side = math.max((maxX - minX) * scaleX, (maxY - minY) * scaleY).round();
  side = (side * 1.2).round();
  final limit = math.min(decoded.width, decoded.height);
  side = side.clamp(32, limit);
  final left = (cx - side ~/ 2).clamp(0, decoded.width - side);
  final top = (cy - side ~/ 2).clamp(0, decoded.height - side);
  final cropped = img.copyCrop(
    decoded,
    x: left,
    y: top,
    width: side,
    height: side,
  );
  final framed = side > 1080
      ? img.copyResize(cropped, width: 1080, height: 1080)
      : cropped;
  return img.encodeJpg(framed, quality: 85);
}

/// Longest edge stays within [maxEdge]. Undecodable bytes are returned as-is.
Uint8List compressStoredPhoto(
  Uint8List bytes, {
  int maxEdge = 1280,
  int quality = 80,
}) {
  final decoded = img.decodeImage(bytes);
  if (decoded == null) return bytes;
  final edge = math.max(decoded.width, decoded.height);
  final sized = edge <= maxEdge
      ? decoded
      : img.copyResize(
          decoded,
          width: decoded.width >= decoded.height
              ? maxEdge
              : (decoded.width * maxEdge / decoded.height).round(),
          height: decoded.height > decoded.width
              ? maxEdge
              : (decoded.height * maxEdge / decoded.width).round(),
        );
  return img.encodeJpg(sized, quality: quality);
}

bool _isSubject(img.Pixel pixel) {
  final r = pixel.r.toInt();
  final g = pixel.g.toInt();
  final b = pixel.b.toInt();
  final maxC = math.max(r, math.max(g, b));
  final minC = math.min(r, math.min(g, b));
  final value = maxC / 255;
  final sat = maxC == 0 ? 0.0 : (maxC - minC) / maxC;
  if (value > 0.9 && sat < 0.12) return false;
  return true;
}
