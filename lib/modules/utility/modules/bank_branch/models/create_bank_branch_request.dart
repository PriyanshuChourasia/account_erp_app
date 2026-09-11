/// Request payload for creating a bank branch.
///
/// Mirrors the backend `CreateBankBranchDTO` record. Nullable fields are
/// omitted from JSON so the backend's `@NotBlank` validation only applies to
/// `name`.
class CreateBankBranchRequest {
  const CreateBankBranchRequest({
    required this.name,
    this.bankId,
    this.ifscCode,
    this.address,
  });

  final String name;
  final int? bankId;
  final String? ifscCode;
  final String? address;

  Map<String, dynamic> toJson() => {
    'name': name,
    if (bankId != null) 'bankId': bankId,
    if (ifscCode != null) 'ifscCode': ifscCode,
    if (address != null) 'address': address,
  };
}