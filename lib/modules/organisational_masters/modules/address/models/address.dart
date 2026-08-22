import 'package:flutter/material.dart';

import '../../../../../config/theme/app_theme.dart';

/// An address attached to an addressable entity (company, party, ...).
///
/// Mirrors the backend `AddressDTO` record (`id`, `stateId`, `countryId` and
/// `addressableId` are UUID strings).
class Address {
  const Address({
    required this.id,
    required this.addressType,
    required this.line1,
    this.line2,
    this.city,
    this.landmark,
    this.area,
    this.postOffice,
    required this.stateId,
    required this.countryId,
    required this.pinCode,
    this.latitude,
    this.longitude,
    this.isPrimary = false,
    this.addressableId,
    this.addressableType,
    this.active = true,
    this.icon = Icons.location_on_rounded,
    this.color = AppColors.primary,
  });

  /// UUID from the backend.
  final String id;

  /// Backend `AddressTypeEnum` name, e.g. `BILLING`.
  final String addressType;
  final String line1;
  final String? line2;
  final String? city;
  final String? landmark;
  final String? area;
  final String? postOffice;

  /// UUID of the state this address belongs to.
  final String stateId;

  /// UUID of the country this address belongs to.
  final String countryId;
  final String pinCode;
  final String? latitude;
  final String? longitude;
  final bool isPrimary;

  /// UUID of the entity this address is attached to.
  final String? addressableId;
  final String? addressableType;
  final bool active;
  final IconData icon;
  final Color color;

  factory Address.fromJson(Map<String, dynamic> json) => Address(
    id: json['id'] as String? ?? '',
    addressType: json['addressType'] as String? ?? '',
    line1: json['line1'] as String? ?? '',
    line2: json['line2'] as String?,
    city: json['city'] as String?,
    landmark: json['landmark'] as String?,
    area: json['area'] as String?,
    postOffice: json['postOffice'] as String?,
    stateId: json['stateId'] as String? ?? '',
    countryId: json['countryId'] as String? ?? '',
    pinCode: json['pinCode'] as String? ?? '',
    latitude: json['latitude'] as String?,
    longitude: json['longitude'] as String?,
    isPrimary: json['isPrimary'] == true,
    addressableId: json['addressableId'] as String?,
    addressableType: json['addressableType'] as String?,
    active: json['active'] == true,
  );
}
