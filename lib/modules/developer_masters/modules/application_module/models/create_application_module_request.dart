/// Request payload for creating an application module.
///
/// Mirrors the backend `CreateApplicationModuleDTO` record. Nullable fields
/// are omitted from JSON.
class CreateApplicationModuleRequest {
  const CreateApplicationModuleRequest({
    required this.name,
    this.description,
    this.endpoint,
    this.isSystem = false,
  });

  final String name;
  final String? description;
  final String? endpoint;
  final bool isSystem;

  Map<String, dynamic> toJson() => {
    'name': name,
    if (description != null) 'description': description,
    if (endpoint != null) 'endpoint': endpoint,
    'isSystem': isSystem,
  };
}
