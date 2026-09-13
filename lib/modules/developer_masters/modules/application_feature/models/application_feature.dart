import 'package:flutter/material.dart';

import '../../../../../config/theme/app_theme.dart';

/// The HTTP verb an [ApplicationFeature] is exposed over.
///
/// Mirrors the backend `ApiMethod` enum.
///
/// NOTE: values are a best guess (standard REST verbs) pending confirmation
/// of the exact backend enum constants.
enum ApiMethod { get, post, put, patch, delete }

/// The class of client a feature's endpoint is meant to serve.
///
/// Mirrors the backend `APIDeviceType` enum (`ALL, MOBILE, DESKTOP, WEB`).
enum ApiDeviceType { all, mobile, desktop, web }

/// A registered API feature/route of the application (method + device type +
/// endpoint), used for API-level permission/registry configuration.
///
/// Mirrors the backend `ApplicationFeatureDTO` record. [demo] serves as
/// placeholder data until the backend is reachable.
class ApplicationFeature {
  const ApplicationFeature({
    required this.id,
    required this.name,
    required this.apiMethod,
    required this.apiDeviceType,
    required this.endPoint,
    this.moduleId,
    this.code,
    this.description,
    this.active = true,
    this.icon = Icons.extension_rounded,
    this.color = AppColors.primary,
  });

  /// UUID assigned by the backend.
  final String id;

  /// The [id] of the [ApplicationModule] this feature belongs to, when known.
  final String? moduleId;
  final String name;
  final int? code;
  final ApiMethod apiMethod;
  final ApiDeviceType apiDeviceType;
  final String endPoint;
  final String? description;
  final bool active;
  final IconData icon;
  final Color color;

  factory ApplicationFeature.fromJson(Map<String, dynamic> json) =>
      ApplicationFeature(
        id: json['id'] as String? ?? '',
        name: json['name'] as String? ?? '',
        moduleId: json['moduleId'] as String?,
        code: (json['code'] as num?)?.toInt(),
        apiMethod: _apiMethodFromWire(json['apiMethod'] as String?),
        apiDeviceType: _apiDeviceTypeFromWire(json['apiDeviceType'] as String?),
        endPoint: json['endPoint'] as String? ?? '',
        description: json['description'] as String?,
        active: json['active'] as bool? ?? true,
      );

  static ApiMethod _apiMethodFromWire(String? value) => ApiMethod.values
      .firstWhere(
        (method) => method.name.toUpperCase() == value?.toUpperCase(),
        orElse: () => ApiMethod.get,
      );

  static ApiDeviceType _apiDeviceTypeFromWire(String? value) =>
      ApiDeviceType.values.firstWhere(
        (deviceType) => deviceType.name.toUpperCase() == value?.toUpperCase(),
        orElse: () => ApiDeviceType.all,
      );

  static const List<ApplicationFeature> demo = [
    ApplicationFeature(
      id: '1',
      name: 'Account Nature',
      moduleId: '1',
      apiMethod: ApiMethod.get,
      apiDeviceType: ApiDeviceType.all,
      endPoint: 'account_natures',
      code: 1,
      description: 'Classify accounts by their nature',
      icon: Icons.category_rounded,
      color: Color(0xFF0D9488),
    ),
    ApplicationFeature(
      id: '2',
      name: 'Account Group',
      moduleId: '1',
      apiMethod: ApiMethod.get,
      apiDeviceType: ApiDeviceType.all,
      endPoint: 'account_groups',
      code: 2,
      description: 'Hierarchical classification of ledgers',
      icon: Icons.account_tree_rounded,
      color: Color(0xFF7C3AED),
    ),
    ApplicationFeature(
      id: '3',
      name: 'Stock Group',
      moduleId: '2',
      apiMethod: ApiMethod.get,
      apiDeviceType: ApiDeviceType.web,
      endPoint: 'stock-groups',
      code: 3,
      description: 'Group stock items for reporting',
      icon: Icons.warehouse_rounded,
      color: Color(0xFF1D4ED8),
    ),
    ApplicationFeature(
      id: '4',
      name: 'Country',
      moduleId: '3',
      apiMethod: ApiMethod.get,
      apiDeviceType: ApiDeviceType.mobile,
      endPoint: 'countries',
      code: 4,
      description: 'Countries used across organisational masters',
      icon: Icons.public_rounded,
      color: Color(0xFFD97706),
    ),
  ];
}
