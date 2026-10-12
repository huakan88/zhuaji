import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class PhotoStore {
  Future<String> persist(String sourcePath) async {
    final root = await getApplicationDocumentsDirectory();
    final folder = Directory(p.join(root.path, 'cat_photos'));
    await folder.create(recursive: true);
    final ext = p.extension(sourcePath);
    final name =
        '${DateTime.now().microsecondsSinceEpoch}${ext.isEmpty ? '.jpg' : ext}';
    final dest = File(p.join(folder.path, name));
    await File(sourcePath).copy(dest.path);
    return dest.path;
  }
}
