/// Request payload for updating an accounting group.
///
/// Mirrors the backend `UpdateAccountGroupDTO` record. [id] identifies the
/// group being edited; nullable fields are omitted from JSON.
class UpdateAccountGroupRequest {
  const UpdateAccountGroupRequest({
    required this.id,
    required this.name,
    required this.code,
    required this.accountNatureId,
    this.alias,
    this.description,
    this.parentId,
  });

  final int id;
  final String name;
  final int code;
  final String? alias;
  final String? description;

  /// Parent group id — accounting groups form a hierarchy.
  final int? parentId;

  /// The account nature this group belongs to.
  final int accountNatureId;

  Map<String, dynamic> toJson() => {
        'name': name,
        'code': code,
        if (alias != null) 'alias': alias,
        if (description != null) 'description': description,
        if (parentId != null) 'parentId': parentId,
        'accountNatureId': accountNatureId,
      };
}
