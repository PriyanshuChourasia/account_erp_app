/// Request payload for creating an accounting group.
///
/// Mirrors the backend `CreateAccountGroupDTO` record. Nullable fields are
/// omitted from JSON so the backend's `@NotBlank` validation only applies to
/// `name`.
class CreateAccountGroupRequest {
  const CreateAccountGroupRequest({
    required this.name,
    this.alias,
    this.description,
    this.parentId,
  });

  final String name;
  final String? alias;
  final String? description;

  /// Parent group id — accounting groups form a hierarchy.
  final int? parentId;

  Map<String, dynamic> toJson() => {
        'name': name,
        if (alias != null) 'alias': alias,
        if (description != null) 'description': description,
        if (parentId != null) 'parentId': parentId,
      };
}
