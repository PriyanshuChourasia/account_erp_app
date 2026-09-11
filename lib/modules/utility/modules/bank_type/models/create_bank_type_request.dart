/// Request payload for creating a bank type.
///
/// Mirrors the backend `CreateBankTypeDTO` record. Nullable fields are omitted
/// from JSON so the backend's `@NotBlank` validation only applies to `name`.
class CreateBankTypeRequest {
  const CreateBankTypeRequest({required this.name, this.description});

  final String name;
  final String? description;

  Map<String, dynamic> toJson() => {
    'name': name,
    if (description != null) 'description': description,
  };
}