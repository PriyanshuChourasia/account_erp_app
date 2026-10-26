/// A gender option used across masters, e.g. `Male`, `Female`.
///
/// Mirrors the backend `GenderDTO` record.
class Gender {
  const Gender({
    required this.id,
    required this.name,
    this.code,
    this.description,
    this.isActive = true,
  });

  final String id;
  final String name;
  final String? code;
  final String? description;
  final bool isActive;

  factory Gender.fromJson(Map<String, dynamic> json) => Gender(
    id: json['id']?.toString() ?? '',
    name: json['name'] as String? ?? '',
    code: json['code'] as String?,
    description: json['description'] as String?,
    isActive: json['active'] != false,
  );
}
