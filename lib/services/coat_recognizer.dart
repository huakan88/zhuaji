import 'dart:io';
import 'dart:math' as math;

import 'package:image/image.dart' as img;

import '../domain/models.dart';

class MockCoatBreedRecognizer implements CoatBreedRecognizer {
  const MockCoatBreedRecognizer();

  static const _coats = ['橘白', '纯白', '银渐层', '蓝灰色', '狸花', '三花', '奶牛', '纯黑'];
  static const _breeds = [
    '中华田园猫',
    '英国短毛猫',
    '美国短毛猫',
    '布偶猫',
    '暹罗猫',
    '俄罗斯蓝猫',
    '缅因猫',
    '异国短毛猫',
  ];

  @override
  Future<RecognitionSuggestion> recognize(String imagePath) async {
    var hash = imagePath.hashCode.abs();
    final file = File(imagePath);
    if (await file.exists()) {
      final bytes = await file.readAsBytes();
      hash = bytes.fold<int>(0, (sum, byte) => (sum + byte) & 0x7fffffff);
    }
    final index = hash % _coats.length;
    final coat = _coats[index];
    final breed = _breeds[index];
    return RecognitionSuggestion(
      coatColor: coat,
      breed: breed,
      confidence: 0.45 + (hash % 20) / 100,
      source: RecognitionSource.mock,
      detail: '示例识别，请点选最接近的毛色和品种。',
      coatChoices: nearbyChoices(_coats, coat),
      breedChoices: nearbyChoices(_breeds, breed),
    );
  }
}

/// Reads the photo's own colors. It does not claim a breed identity.
class ColorCoatRecognizer implements CoatBreedRecognizer {
  const ColorCoatRecognizer();

  @override
  Future<RecognitionSuggestion> recognize(String imagePath) async {
    try {
      final bytes = await File(imagePath).readAsBytes();
      final decoded = img.decodeImage(bytes);
      if (decoded != null) return suggestionForImage(decoded);
    } catch (_) {
      // A photo that cannot be decoded still leaves the chips usable.
    }
    return const RecognitionSuggestion(
      coatColor: '短毛',
      breed: '中华田园猫',
      confidence: 0.2,
      source: RecognitionSource.mock,
      detail: '这张照片没有读出毛色，请从下面点选。',
      coatChoices: ['短毛', '橘', '纯白'],
      breedChoices: ['中华田园猫', '英国短毛猫', '美国短毛猫'],
    );
  }
}

class _ColorStats {
  int count = 0;
  int orange = 0;
  int black = 0;
  int white = 0;
  int gray = 0;
  int cream = 0;
  double lumaSum = 0;
  double lumaSq = 0;
  int edgeDark = 0;
  int edgeCount = 0;
  int centerLight = 0;
  int centerCount = 0;
}

RecognitionSuggestion suggestionForImage(img.Image source) {
  final image = source.width > 240
      ? img.copyResize(source, width: 240)
      : source;
  final stats = _ColorStats();
  final top = (image.height * 0.22).round();
  for (var y = 0; y < image.height; y += 2) {
    for (var x = 0; x < image.width; x += 2) {
      final pixel = image.getPixel(x, y);
      final r = pixel.r.toInt();
      final g = pixel.g.toInt();
      final b = pixel.b.toInt();
      final maxC = math.max(r, math.max(g, b));
      final minC = math.min(r, math.min(g, b));
      final value = maxC / 255;
      final sat = maxC == 0 ? 0.0 : (maxC - minC) / maxC;
      final luma = (0.299 * r + 0.587 * g + 0.114 * b) / 255;
      if (y < top) {
        stats.edgeCount++;
        if (luma < 0.35) stats.edgeDark++;
      }
      final center =
          x > image.width * 0.3 &&
          x < image.width * 0.7 &&
          y > image.height * 0.3 &&
          y < image.height * 0.75;
      if (center) {
        stats.centerCount++;
        if (luma > 0.72 && sat < 0.35) stats.centerLight++;
      }
      if (value > 0.92 && sat < 0.08) continue;
      stats.count++;
      stats.lumaSum += luma;
      stats.lumaSq += luma * luma;
      if (value < 0.22) {
        stats.black++;
      } else if (value > 0.82 && sat < 0.16) {
        stats.white++;
      } else if (sat < 0.18) {
        stats.gray++;
      } else if (_hue(r, g, b) < 45 && sat > 0.28 && value > 0.35) {
        if (value > 0.75 && sat < 0.45) {
          stats.cream++;
        } else {
          stats.orange++;
        }
      }
    }
  }
  if (stats.count < 12) {
    return const RecognitionSuggestion(
      coatColor: '短毛',
      breed: '中华田园猫',
      confidence: 0.2,
      source: RecognitionSource.mock,
      detail: '画面里几乎没有毛色，请点选。',
      coatChoices: ['短毛', '纯白', '纯黑'],
      breedChoices: ['中华田园猫', '英国短毛猫', '布偶猫'],
    );
  }
  final mean = stats.lumaSum / stats.count;
  final variance = stats.lumaSq / stats.count - mean * mean;
  final pointed =
      stats.edgeCount > 0 &&
      stats.centerCount > 0 &&
      stats.edgeDark / stats.edgeCount > 0.45 &&
      stats.centerLight / stats.centerCount > 0.4;
  final coat = _coatName(stats, variance, pointed);
  final breeds = _breedsFor(coat);
  return RecognitionSuggestion(
    coatColor: coat,
    breed: breeds.first,
    confidence: 0.55,
    source: RecognitionSource.mock,
    detail: '按照片里的颜色给出毛色，品种只是常见候选，请点选确认。',
    coatChoices: _coatChoices(coat),
    breedChoices: breeds,
  );
}

String _coatName(_ColorStats stats, double variance, bool pointed) {
  if (pointed) return '重点色';
  final total = stats.count;
  final orange = stats.orange / total;
  final black = stats.black / total;
  final white = stats.white / total;
  final gray = stats.gray / total;
  final cream = stats.cream / total;
  if (orange > 0.15 && black > 0.15 && white > 0.1) return '三花';
  if (orange > 0.2 && black > 0.2) return '玳瑁';
  if (black > 0.55 && white > 0.15) return '奶牛';
  if (black > 0.6) return '纯黑';
  if (white > 0.7) return '纯白';
  if (orange > 0.45 && variance > 0.02) return '狸花';
  if (orange > 0.35 && white > 0.2) return '橘白';
  if (orange > 0.4) return '橘';
  if (cream > 0.4) return '乳白';
  if (gray > 0.45 && _meanLight(stats)) return '银渐层';
  if (gray > 0.4) return '蓝灰色';
  return '短毛';
}

bool _meanLight(_ColorStats stats) => stats.lumaSum / stats.count > 0.62;

List<String> _breedsFor(String coat) {
  return switch (coat) {
    '重点色' => ['暹罗猫', '布偶猫', '中华田园猫'],
    '狸花' || '橘' || '橘白' || '玳瑁' || '三花' || '奶牛' => ['中华田园猫', '英国短毛猫', '美国短毛猫'],
    '银渐层' || '蓝灰色' => ['英国短毛猫', '俄罗斯蓝猫', '中华田园猫'],
    '纯白' || '乳白' => ['中华田园猫', '英国短毛猫', '布偶猫'],
    '纯黑' => ['中华田园猫', '孟买猫', '英国短毛猫'],
    _ => ['中华田园猫', '英国短毛猫', '美国短毛猫'],
  };
}

List<String> _coatChoices(String coat) {
  const nearby = ['橘', '狸花', '橘白', '纯白', '乳白', '银渐层', '蓝灰色', '纯黑', '重点色', '三花'];
  if (!nearby.contains(coat)) return [coat, '短毛', '纯白'];
  final index = nearby.indexOf(coat);
  return [
    coat,
    nearby[(index + 1) % nearby.length],
    nearby[(index + 2) % nearby.length],
  ];
}

double _hue(int r, int g, int b) {
  final rf = r / 255;
  final gf = g / 255;
  final bf = b / 255;
  final maxC = math.max(rf, math.max(gf, bf));
  final minC = math.min(rf, math.min(gf, bf));
  final delta = maxC - minC;
  if (delta == 0) return 0;
  double hue;
  if (maxC == rf) {
    hue = 60 * (((gf - bf) / delta) % 6);
  } else if (maxC == gf) {
    hue = 60 * (((bf - rf) / delta) + 2);
  } else {
    hue = 60 * (((rf - gf) / delta) + 4);
  }
  if (hue < 0) hue += 360;
  return hue;
}

List<String> nearbyChoices(List<String> all, String primary) {
  final index = all.indexOf(primary);
  if (index < 0) return [primary];
  return [
    primary,
    all[(index + 1) % all.length],
    all[(index + 2) % all.length],
  ];
}
