const kDisclaimer =
    '疫苗、驱虫、体检和疾病养护提醒只供家庭记录参考，不能替代执业兽医的诊断、处方或个体化建议。仅供参考，请遵医嘱。猫咪如果呕吐、拒食、精神差或呼吸异常，请及时就医。';

const kGuidelineSources =
    '体检频率和疾病养护依据 AAHA/AAFP《猫生命阶段指南》（2021）、WSAVA 犬猫疫苗指南、ISFM 猫科共识，以及 IRIS 慢性肾病分期。各地法规和每只猫的病情不同，请以执业兽医的方案为准。';

const kBarcodeNote = '条码里没有日期。扫到这袋粮之后，再拍包装上的日期，或者用滚轮点。';

const kSampleFoodNote = '没核实的条码、热量和开封天数先空着，以你手里的包装为准。';

/// Shown when a barcode correction is waiting to leave this phone.
String shareQueueNotice(int count) {
  if (count <= 0) return '';
  return '有 $count 条条码修正还没发出去。联网后会自动提交。';
}
