/// Payload for creating or updating a designation.
///
/// Mirrors the backend `CreateDesignationRequest` record, which both
/// `POST /designations/create` and `PUT /designations/{id}` accept. Nullable
/// fields are omitted from JSON.
///
/// The backend overwrites the stored parent on every update, so an edit must
/// always pass the designation's current [parentId] to keep it.
class CreateDesignationRequest {
  const CreateDesignationRequest({
    required this.name,
    this.code,
    this.parentId,
    this.description,
  });

  final String name;
  final String? code;

  /// Parent designation id; null makes it a top-level designation.
  final String? parentId;
  final String? description;

  Map<String, dynamic> toJson() => {
    'name': name,
    if (code != null) 'code': code,
    if (parentId != null) 'parentId': parentId,
    if (description != null) 'description': description,
  };
}
