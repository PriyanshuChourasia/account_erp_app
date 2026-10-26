/// Request payload for creating or updating a gender.
///
/// Mirrors the backend `CreateGenderRequest` record. Nullable fields are
/// omitted from JSON so the backend's `@NotBlank` validation only applies to
/// `name`.
class CreateGenderRequest {
  const CreateGenderRequest({required this.name, this.code, this.description});

  final String name;
  final String? code;
  final String? description;

  Map<String, dynamic> toJson() => {
    'name': name,
    if (code != null) 'code': code,
    if (description != null) 'description': description,
  };
}
