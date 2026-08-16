/// Request payload for creating an account nature.
///
/// Mirrors the backend `CreateAccountNatureDTO` record. Nullable fields are
/// omitted from JSON.
class CreateAccountNatureRequest {
  const CreateAccountNatureRequest({
    required this.name,
    this.code,
    this.description,
  });

  final String name;
  final int? code;
  final String? description;

  Map<String, dynamic> toJson() => {
    'name': name,
    if (code != null) 'code': code,
    if (description != null) 'description': description,
  };
}
