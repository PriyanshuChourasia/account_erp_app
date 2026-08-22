/// Request payload for creating a state.
///
/// Mirrors the backend `CreateStateDTO` record. Nullable fields are omitted
/// from JSON; the backend's validation requires `name`, `gstCode` and
/// `countryId`.
class CreateStateRequest {
  const CreateStateRequest({
    required this.name,
    this.code,
    required this.gstCode,
    required this.countryId,
    this.description,
  });

  final String name;

  /// e.g. state/region code like `MH` for Maharashtra.
  final String? code;

  /// GST state code, e.g. `27` for Maharashtra.
  final String gstCode;

  /// UUID of the country this state belongs to.
  final String countryId;
  final String? description;

  Map<String, dynamic> toJson() => {
    'name': name,
    if (code != null) 'code': code,
    'gstCode': gstCode,
    'countryId': countryId,
    if (description != null) 'description': description,
  };
}
