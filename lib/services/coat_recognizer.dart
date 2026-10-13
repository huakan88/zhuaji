import 'dart:io';

import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';

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
      detail: '示例识别，可替换为 ML Kit 等端侧模型。请点选最接近的毛色和品种。',
      coatChoices: nearbyChoices(_coats, coat),
      breedChoices: nearbyChoices(_breeds, breed),
    );
  }
}

class MlKitCoatBreedRecognizer implements CoatBreedRecognizer {
  MlKitCoatBreedRecognizer({this.fallback = const MockCoatBreedRecognizer()});

  final CoatBreedRecognizer fallback;

  @override
  Future<RecognitionSuggestion> recognize(String imagePath) async {
    ImageLabeler? labeler;
    try {
      labeler = ImageLabeler(
        options: ImageLabelerOptions(confidenceThreshold: 0.35),
      );
      final labels = await labeler.processImage(
        InputImage.fromFilePath(imagePath),
      );
      final mapped = _map(labels);
      if (mapped != null) return mapped;
    } catch (_) {
      // Desktop tests and devices without the model stay on the mock.
    } finally {
      await labeler?.close();
    }
    return fallback.recognize(imagePath);
  }

  RecognitionSuggestion? _map(List<ImageLabel> labels) {
    if (labels.isEmpty) return null;
    final text = labels.map((label) => label.label.toLowerCase()).join(' ');
    String? coat;
    String? breed;
    if (text.contains('tabby') || text.contains('tiger cat')) {
      coat = '狸花';
      breed = '中华田园猫';
    } else if (text.contains('siamese')) {
      coat = '重点色';
      breed = '暹罗猫';
    } else if (text.contains('persian')) {
      coat = '长毛';
      breed = '波斯猫';
    } else if (text.contains('egyptian')) {
      coat = '短毛';
      breed = '家猫';
    }
    if (coat == null || breed == null) return null;
    final confidence = labels
        .map((label) => label.confidence)
        .reduce((a, b) => a > b ? a : b);
    final names = labels.take(3).map((label) => label.label).join('、');
    return RecognitionSuggestion(
      coatColor: coat,
      breed: breed,
      confidence: confidence,
      source: RecognitionSource.mlkit,
      detail: 'ML Kit 图像标签：$names。这是粗略映射，不是品种鉴定，请点选确认。',
      coatChoices: [coat],
      breedChoices: [breed],
    );
  }
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
