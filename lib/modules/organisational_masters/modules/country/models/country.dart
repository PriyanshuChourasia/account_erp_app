import 'package:flutter/material.dart';

import '../../../../../config/theme/app_theme.dart';

/// A country used by organisational masters.
///
/// Mirrors the backend `CountryDTO` record (`id` is a UUID string). [demo]
/// serves as placeholder data until the backend is reachable.
class Country {
  const Country({
    required this.id,
    required this.name,
    this.alias,
    this.iso2Code,
    this.iso3Code,
    this.numericCode,
    this.phoneCode,
    this.currencyCode,
    this.currencyName,
    this.region,
    this.subRegion,
    this.active = true,
    this.icon = Icons.public_rounded,
    this.color = AppColors.primary,
  });

  /// UUID from the backend.
  final String id;
  final String name;
  final String? alias;

  /// ISO 3166-1 alpha-2 country code, e.g. `IN`.
  final String? iso2Code;

  /// ISO 3166-1 alpha-3 country code, e.g. `IND`.
  final String? iso3Code;

  /// ISO 3166-1 numeric code, e.g. `356`.
  final String? numericCode;

  /// International dialling code, e.g. `+91`.
  final String? phoneCode;

  /// ISO 4217 currency code, e.g. `INR`.
  final String? currencyCode;
  final String? currencyName;
  final String? region;
  final String? subRegion;
  final bool active;
  final IconData icon;
  final Color color;

  factory Country.fromJson(Map<String, dynamic> json) => Country(
    id: json['id'] as String? ?? '',
    name: json['name'] as String? ?? '',
    alias: json['alias'] as String?,
    iso2Code: json['iso2Code'] as String?,
    iso3Code: json['iso3Code'] as String?,
    numericCode: json['numericCode'] as String?,
    phoneCode: json['phoneCode'] as String?,
    currencyCode: json['currencyCode'] as String?,
    currencyName: json['currencyName'] as String?,
    region: json['region'] as String?,
    subRegion: json['subRegion'] as String?,
    active: json['active'] == true,
  );

  static const List<Country> demo = [
    Country(
      id: '00000000-0000-0000-0000-000000000001',
      name: 'India',
      alias: 'Bharat',
      iso2Code: 'IN',
      iso3Code: 'IND',
      numericCode: '356',
      phoneCode: '+91',
      currencyCode: 'INR',
      currencyName: 'Indian Rupee',
      region: 'Asia',
      subRegion: 'Southern Asia',
      icon: Icons.flag_rounded,
      color: Color(0xFF0D9488),
    ),
    Country(
      id: '00000000-0000-0000-0000-000000000002',
      name: 'United States',
      iso2Code: 'US',
      iso3Code: 'USA',
      numericCode: '840',
      phoneCode: '+1',
      currencyCode: 'USD',
      currencyName: 'US Dollar',
      region: 'Americas',
      subRegion: 'Northern America',
      icon: Icons.flag_rounded,
      color: Color(0xFF1D4ED8),
    ),
    Country(
      id: '00000000-0000-0000-0000-000000000003',
      name: 'United Kingdom',
      iso2Code: 'GB',
      iso3Code: 'GBR',
      numericCode: '826',
      phoneCode: '+44',
      currencyCode: 'GBP',
      currencyName: 'Pound Sterling',
      region: 'Europe',
      subRegion: 'Northern Europe',
      icon: Icons.flag_rounded,
      color: Color(0xFF7C3AED),
    ),
    Country(
      id: '00000000-0000-0000-0000-000000000004',
      name: 'United Arab Emirates',
      iso2Code: 'AE',
      iso3Code: 'ARE',
      numericCode: '784',
      phoneCode: '+971',
      currencyCode: 'AED',
      currencyName: 'UAE Dirham',
      region: 'Asia',
      subRegion: 'Western Asia',
      icon: Icons.flag_rounded,
      color: Color(0xFFD97706),
    ),
    Country(
      id: '00000000-0000-0000-0000-000000000005',
      name: 'Singapore',
      iso2Code: 'SG',
      iso3Code: 'SGP',
      numericCode: '702',
      phoneCode: '+65',
      currencyCode: 'SGD',
      currencyName: 'Singapore Dollar',
      region: 'Asia',
      subRegion: 'South-eastern Asia',
      icon: Icons.flag_rounded,
      color: Color(0xFF059669),
    ),
  ];
}
