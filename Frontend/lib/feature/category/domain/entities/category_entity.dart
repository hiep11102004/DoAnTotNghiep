class CategoryEntity {
  final int id;
  final String name;
  final String type; // 'income' hoặc 'expense'
  final String? icon;
  final String? color;

  CategoryEntity({
    required this.id,
    required this.name,
    required this.type,
    this.icon,
    this.color,
  });
}