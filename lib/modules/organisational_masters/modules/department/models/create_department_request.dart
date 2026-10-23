/// Payload for creating or updating a department.
///
/// Mirrors the backend `CreateDepartmentRequest` record, which both
/// `POST /departments/create` and `PUT /departments/{id}` accept. Nullable
/// fields are omitted from JSON.
class CreateDepartmentRequest {
  const CreateDepartmentRequest({
    required this.name,
    this.code,
    this.description,
    this.active,
  });

  final String name;
  final String? code;
  final String? description;

  /// Active/inactive flag, sent only when toggling status. Requires the
  /// backend `CreateDepartmentRequest` to accept a `Boolean active` field.
  final bool? active;

  Map<String, dynamic> toJson() => {
    'name': name,
    if (code != null) 'code': code,
    if (description != null) 'description': description,
    if (active != null) 'active': active,
  };
}
