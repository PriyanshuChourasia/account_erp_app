/// Request payload for creating a state.
///
/// Mirrors the backend `CreateStateDTO` record. Nullable fields are omitted
/// from JSON so the backend's `@NotBlank` validation only applies to `name`.
class CreateStateRequest {
  const CreateStateRequest({
    required this.name,
    this.code,
    required this.countryId,
    this.description,
  });

  final String name;

  /// e.g. state/region code like `MH` for Maharashtra.
  final String? code;

  /// The country this state belongs to.
  final int countryId;
  final String? description;

  Map<String, dynamic> toJson() => {
        'name': name,
        if (code != null) 'code': code,
        'countryId': countryId,
        if (description != null) 'description': description,
      };
}
