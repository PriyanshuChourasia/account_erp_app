import 'application_feature.dart';

/// Request payload for creating an application feature.
///
/// Mirrors the backend `CreateApplicationFeatureDTO` record. [description] is
/// omitted from JSON when null.
class CreateApplicationFeatureRequest {
  const CreateApplicationFeatureRequest({
    required this.name,
    required this.apiMethod,
    required this.apiDeviceType,
    required this.endPoint,
    this.description,
    this.active = true,
  });

  final String name;
  final ApiMethod apiMethod;
  final ApiDeviceType apiDeviceType;
  final String endPoint;
  final String? description;
  final bool active;

  Map<String, dynamic> toJson() => {
    'name': name,
    'apiMethod': apiMethod.name.toUpperCase(),
    'apiDeviceType': apiDeviceType.name.toUpperCase(),
    'endPoint': endPoint,
    if (description != null) 'description': description,
    'active': active,
  };
}
