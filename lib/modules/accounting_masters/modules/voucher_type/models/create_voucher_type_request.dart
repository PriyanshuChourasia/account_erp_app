/// Request payload for creating a voucher type.
///
/// Mirrors the backend `CreateVoucherTypeDTO` record. Nullable fields are
/// omitted from JSON.
class CreateVoucherTypeRequest {
  const CreateVoucherTypeRequest({
    required this.name,
    this.code,
    this.description,
  });

  final String name;
  final String? code;
  final String? description;

  Map<String, dynamic> toJson() => {
        'name': name,
        if (code != null && code!.isNotEmpty) 'code': code,
        if (description != null) 'description': description,
      };
}
