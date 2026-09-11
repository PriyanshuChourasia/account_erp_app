/// Request payload for creating a bank.
///
/// Mirrors the backend `CreateBankDTO` record. Nullable fields are omitted
/// from JSON so the backend's `@NotBlank` validation only applies to `name`.
class CreateBankRequest {
  const CreateBankRequest({required this.name, this.code, this.bankTypeId});

  final String name;
  final String? code;
  final int? bankTypeId;

  Map<String, dynamic> toJson() => {
    'name': name,
    if (code != null) 'code': code,
    if (bankTypeId != null) 'bankTypeId': bankTypeId,
  };
}