/// A node in the stock category hierarchy tree.
///
/// Mirrors the backend `StockCategoryHierarchyDTO` record. Nullable fields are
/// omitted in the same way the backend's `@JsonInclude(NON_NULL)` drops them.
class StockCategoryHierarchy {
  const StockCategoryHierarchy({
    required this.id,
    required this.name,
    this.code,
    this.alias,
    this.parentId,
    this.description,
    this.isActive = true,
    this.children,
  });

  final int id;
  final String name;
  final String? code;
  final String? alias;
  final int? parentId;
  final String? description;
  final bool isActive;
  final List<StockCategoryHierarchy>? children;

  factory StockCategoryHierarchy.fromJson(Map<String, dynamic> json) =>
      StockCategoryHierarchy(
        id: (json['id'] as num?)?.toInt() ?? 0,
        name: json['name'] as String? ?? '',
        code: json['code'] as String?,
        alias: json['alias'] as String?,
        parentId: (json['parentId'] as num?)?.toInt(),
        description: json['description'] as String?,
        isActive: json['isActive'] == true,
        children: (json['children'] as List<dynamic>?)
            ?.map((child) => StockCategoryHierarchy.fromJson(
                  child as Map<String, dynamic>,
                ))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        if (code != null) 'code': code,
        if (alias != null) 'alias': alias,
        if (parentId != null) 'parentId': parentId,
        if (description != null) 'description': description,
        'isActive': isActive,
        if (children != null)
          'children': children!.map((child) => child.toJson()).toList(),
      };
}
