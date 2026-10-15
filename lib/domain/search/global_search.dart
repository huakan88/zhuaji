import '../../core/format.dart';
import '../care/agenda.dart';
import '../food/fresh_recipes.dart';
import '../models.dart';
import 'pinyin.dart';

class SearchHit {
  const SearchHit({
    required this.group,
    required this.title,
    required this.subtitle,
    required this.route,
    this.catId,
  });

  final String group;
  final String title;
  final String subtitle;
  final String route;
  final int? catId;
}

class SearchGroup {
  const SearchGroup(this.label, this.hits);

  final String label;
  final List<SearchHit> hits;
}

const searchGroupOrder = [
  '猫咪',
  '粮仓',
  '猫粮库',
  '自制食谱',
  '疫苗',
  '驱虫',
  '体重',
  '化验',
  '就诊',
  '提醒',
];

/// Every group the query touches, in [searchGroupOrder]. At most eight hits
/// in a group, so a short initial such as "m" does not fill the page.
List<SearchGroup> globalSearch({
  required String query,
  required List<CatProfile> cats,
  required List<PantryEntry> pantry,
  required List<FoodProduct> products,
  required List<VaccineRecord> vaccines,
  required List<DewormRecord> deworms,
  required List<WeightRecord> weights,
  required List<LabReport> labs,
  required List<VetRecord> visits,
  required List<AgendaItem> reminders,
  required String Function(int catId) catName,
}) {
  final needle = query.trim();
  if (needle.isEmpty) return const [];
  bool hit(Iterable<String> parts) {
    return matchesQuery(
      needle,
      parts.where((part) => part.isNotEmpty).join(' '),
    );
  }

  final stocked = {for (final entry in pantry) entry.product.id};
  final hits = <SearchHit>[
    for (final cat in cats)
      if (hit([cat.name, cat.breed ?? '']))
        SearchHit(
          group: '猫咪',
          title: cat.name,
          subtitle: cat.breed ?? '',
          route: '/cat-form?id=${cat.id}',
          catId: cat.id,
        ),
    for (final entry in pantry)
      if (hit(_foodParts(entry.product)))
        SearchHit(
          group: '粮仓',
          title: entry.product.name,
          subtitle: [
            entry.product.brand,
            entry.product.spec,
          ].where((part) => part.isNotEmpty).join(' · '),
          route: '/bag?id=${entry.item.id}',
        ),
    for (final item in products)
      if (!stocked.contains(item.id) && hit(_foodParts(item)))
        SearchHit(
          group: '猫粮库',
          title: item.displayName,
          subtitle: '未入库',
          route: '/confirm?product=${item.id}',
        ),
    for (final card in freshCards)
      if (hit([card.title]))
        SearchHit(
          group: '自制食谱',
          title: card.title,
          subtitle: card.summary,
          route: '/recipe?id=${card.id}',
        ),
    for (final shot in vaccines)
      if (hit([shot.name, shot.notes, shot.clinic ?? '', catName(shot.catId)]))
        SearchHit(
          group: '疫苗',
          title: shot.name,
          subtitle: _whoWhen(catName(shot.catId), shot.givenOn),
          route: '/vaccines',
          catId: shot.catId,
        ),
    for (final item in deworms)
      if (hit([
        item.product,
        dewormLabel(item.kind),
        item.notes,
        catName(item.catId),
      ]))
        SearchHit(
          group: '驱虫',
          title: item.product,
          subtitle: _whoWhen(catName(item.catId), item.givenOn),
          route: '/deworms',
          catId: item.catId,
        ),
    for (final item in weights)
      if (hit([
        catName(item.catId),
        '体重',
        item.weightKg.toStringAsFixed(2),
        formatDate(item.loggedOn),
      ]))
        SearchHit(
          group: '体重',
          title: '${item.weightKg.toStringAsFixed(2)} kg',
          subtitle: _whoWhen(catName(item.catId), item.loggedOn),
          route: '/weight',
          catId: item.catId,
        ),
    for (final report in labs)
      if (hit([
        labKindLabel(report.kind),
        report.note,
        catName(report.catId),
        '化验',
      ]))
        SearchHit(
          group: '化验',
          title: labKindLabel(report.kind),
          subtitle: _whoWhen(catName(report.catId), report.takenOn),
          route: '/lab?id=${report.id}',
          catId: report.catId,
        ),
    for (final visit in visits)
      if (hit([
        visit.reason,
        visit.clinic ?? '',
        visit.diagnosis ?? '',
        visit.notes,
        catName(visit.catId),
      ]))
        SearchHit(
          group: '就诊',
          title: visit.reason,
          subtitle: [
            catName(visit.catId),
            if (visit.clinic != null && visit.clinic!.isNotEmpty) visit.clinic!,
            formatDate(visit.visitedOn),
          ].where((part) => part.isNotEmpty).join(' · '),
          route: '/visits',
          catId: visit.catId,
        ),
    for (final item in reminders)
      if (hit([item.title, item.detail]))
        SearchHit(
          group: '提醒',
          title: item.title,
          subtitle: item.detail,
          route: item.route,
        ),
  ];
  final grouped = <String, List<SearchHit>>{};
  for (final item in hits) {
    final list = grouped.putIfAbsent(item.group, () => []);
    if (list.length >= 8) continue;
    list.add(item);
  }
  return [
    for (final label in searchGroupOrder)
      if (grouped[label] != null) SearchGroup(label, grouped[label]!),
  ];
}

List<String> _foodParts(FoodProduct item) {
  return [
    item.brand,
    item.name,
    item.flavor,
    item.spec,
    formLabel(item.foodForm),
    item.barcode ?? '',
    if (item.isCustom) '自定义',
  ];
}

String _whoWhen(String name, DateTime day) {
  return [name, formatDate(day)].where((part) => part.isNotEmpty).join(' · ');
}
