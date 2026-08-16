/// Request payload for creating a UQC (Unit Quantity Code).
///
/// Mirrors the backend `CreateUQCDTO` record: `name` and `code` are both
/// `@NotBlank`, and `code` is capped at 3 characters. `alias` and
/// `description` are optional and omitted from JSON when absent.
class CreateUqcRequest {
  const CreateUqcRequest({
    required this.name,
    required this.code,
    this.alias,
    this.description,
  });

  final String name;

  /// GST UQC short code, e.g. `NOS`. Max 3 characters.
  final String code;
  final String? alias;
  final String? description;

  Map<String, dynamic> toJson() => {
    'name': name,
    'code': code,
    if (alias != null) 'alias': alias,
    if (description != null) 'description': description,
  };
}
