/// Request payload for updating a UQC (Unit Quantity Code).
///
/// Mirrors the backend `UpdateUQCDTO` record. [id] identifies the UQC being
/// edited; `name` and `code` are required, `alias` and `description` optional.
class UpdateUniqueQuantityCodeRequest {
  const UpdateUniqueQuantityCodeRequest({
    required this.id,
    required this.name,
    required this.code,
    this.alias,
    this.description,
  });

  final int id;
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
