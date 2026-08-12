/// Request payload for creating a country.
///
/// Mirrors the backend `CreateCountryDTO` record. Nullable fields are omitted
/// from JSON so the backend's `@NotBlank` validation only applies to `name`.
class CreateCountryRequest {
  const CreateCountryRequest({
    required this.name,
    this.code,
    this.alias,
    this.description,
  });

  final String name;

  /// ISO 3166-1 alpha-2 country code, e.g. `IN`.
  final String? code;
  final String? alias;
  final String? description;

  Map<String, dynamic> toJson() => {
        'name': name,
        if (code != null) 'code': code,
        if (alias != null) 'alias': alias,
        if (description != null) 'description': description,
      };
}
