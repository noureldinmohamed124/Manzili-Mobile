class CategoryModel {
  final int id;
  final String slug;
  final String nameAr;
  final bool isActive;
  final int sortOrder;
  final DateTime? createdAt;

  CategoryModel({
    required this.id,
    required this.slug,
    required this.nameAr,
    required this.isActive,
    required this.sortOrder,
    this.createdAt,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as int? ?? 0,
      slug: json['slug'] as String? ?? '',
      nameAr: json['nameAr'] as String? ?? '',
      isActive: json['isActive'] as bool? ?? true,
      sortOrder: json['sortOrder'] as int? ?? 0,
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'slug': slug,
      'nameAr': nameAr,
      'isActive': isActive,
      'sortOrder': sortOrder,
      'createdAt': createdAt?.toIso8601String(),
    };
  }
}
