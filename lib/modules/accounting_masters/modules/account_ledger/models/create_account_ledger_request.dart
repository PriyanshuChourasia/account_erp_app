/// Request payload for creating an account ledger.
///
/// Mirrors the backend `CreateAccountLedgerDTO` record. Nullable fields are
/// omitted from JSON.
class CreateAccountLedgerRequest {
  const CreateAccountLedgerRequest({
    required this.name,
    this.alias,
    this.description,
    this.groupId,
  });

  final String name;
  final String? alias;
  final String? description;

  /// Parent account group id — ledgers are classified under account groups.
  final int? groupId;

  Map<String, dynamic> toJson() => {
    'name': name,
    if (alias != null) 'alias': alias,
    if (description != null) 'description': description,
    if (groupId != null) 'groupId': groupId,
  };
}
