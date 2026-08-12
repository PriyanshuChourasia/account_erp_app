/// Request payload for creating a stock category.
///
/// Mirrors the backend `CreateStockCategoryRequest` record. Nullable fields
/// are omitted from JSON so the backend's `@NotBlank` validation only applies
/// to `name`.
class CreateStockCategoryRequest {
  const CreateStockCategoryRequest({
    required this.name,
    this.code,
    this.alias,
    this.parentId,
    this.description,
  });

  final String name;
  final String? code;
  final String? alias;
  final int? parentId;
  final String? description;

  Map<String, dynamic> toJson() => {
        'name': name,
        if (code != null) 'code': code,
        if (alias != null) 'alias': alias,
        if (parentId != null) 'parentId': parentId,
        if (description != null) 'description': description,
      };
}
