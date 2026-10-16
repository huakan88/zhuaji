import 'models.dart';

/// Flavors offered as chips. Longer names are listed first so a parser that
/// scans in order prefers 三文鱼 over 鱼.
const foodFlavors = [
  '三文鱼',
  '金枪鱼',
  '鳕鱼',
  '鸡肉',
  '牛肉',
  '鸭肉',
  '兔肉',
  '羊肉',
  '火鸡',
  '鹿肉',
  '鱼肉',
  '鱼',
];

const foodSpecs = ['70g', '85g', '100g', '500g', '1.5kg', '2kg', '5kg', '10kg'];

/// Catalog search. Custom foods live in the same list, so a query matches them
/// the same way it matches the built-in rows.
bool foodMatchesQuery(FoodProduct item, String query) {
  final q = query.trim().toLowerCase();
  if (q.isEmpty) return true;
  return _haystack(item).contains(q);
}

List<FoodProduct> filterFoods(List<FoodProduct> products, String query) {
  final matched = [
    for (final item in products)
      if (foodMatchesQuery(item, query)) item,
  ];
  matched.sort((a, b) {
    if (a.isCustom != b.isCustom) return a.isCustom ? -1 : 1;
    final brand = a.brand.compareTo(b.brand);
    if (brand != 0) return brand;
    return a.name.compareTo(b.name);
  });
  return matched;
}

String _haystack(FoodProduct item) {
  return [
    item.brand,
    item.name,
    item.flavor,
    item.spec,
    item.formTitle,
    item.barcode ?? '',
    if (item.isCustom) '自定义',
  ].join(' ').toLowerCase();
}
