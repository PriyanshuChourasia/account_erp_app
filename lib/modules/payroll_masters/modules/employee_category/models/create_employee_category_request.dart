/// Request payload for creating or updating an employee category.
///
/// Mirrors the backend `CreateEmployeeCategoryRequest` record. Nullable
/// fields are omitted from JSON so the backend's validation only applies to
/// `name`.
class CreateEmployeeCategoryRequest {
  const CreateEmployeeCategoryRequest({
    required this.name,
    this.alias,
    this.description,
    this.allocateRevenueItem = false,
    this.allocateNonRevenueItem = false,
  });

  final String name;
  final String? alias;
  final String? description;
  final bool allocateRevenueItem;
  final bool allocateNonRevenueItem;

  Map<String, dynamic> toJson() => {
    'name': name,
    if (alias != null) 'alias': alias,
    if (description != null) 'description': description,
    'allocateRevenueItem': allocateRevenueItem,
    'allocateNonRevenueItem': allocateNonRevenueItem,
  };
}
