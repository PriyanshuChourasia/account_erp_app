/// Request payload for creating a blood group.
///
/// Mirrors the backend `CreateBloodGroupDTO` record. Nullable fields are
/// omitted from JSON so the backend's `@NotBlank` validation only applies to
/// `name`.
class CreateBloodGroupRequest {
  const CreateBloodGroupRequest({required this.name, this.code, this.description});

  final String name;
  final String? code;
  final String? description;

  Map<String, dynamic> toJson() => {
    'name': name,
    if (code != null) 'code': code,
    if (description != null) 'description': description,
  };
}
