/// Payload for creating or updating a designation.
///
/// Mirrors the backend `CreateDesignationRequest` record, which both
/// `POST /designations/create` and `PUT /designations/{id}` accept. Nullable
/// fields are omitted from JSON.
class CreateDesignationRequest {
  const CreateDesignationRequest({
    required this.name,
    this.code,
    this.description,
    this.active,
  });

  final String name;
  final String? code;
  final String? description;

  /// Active/inactive flag; omitted unless toggling status so a plain
  /// edit never changes it.
  final bool? active;

  Map<String, dynamic> toJson() => {
    'name': name,
    if (code != null) 'code': code,
    if (description != null) 'description': description,
    if (active != null) 'active': active,
  };
}
