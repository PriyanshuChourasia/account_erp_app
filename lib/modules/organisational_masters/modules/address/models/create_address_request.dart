/// Request payload for creating an address.
///
/// Mirrors the backend `CreateAddressDTO` record. Nullable fields are omitted
/// from JSON so the backend's validation only applies to the required ones.
class CreateAddressRequest {
  const CreateAddressRequest({
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
    this.isPrimary,
    this.active = true,
    this.mobileNo,
    this.email,
  });

  /// Backend `AddressTypeEnum` name, e.g. `BILLING`. Sent as-is.
  final String addressType;

  /// Building / street / door number.
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

  /// 3–10 characters per backend validation.
  final String pinCode;
  final String? latitude;
  final String? longitude;
  final bool? isPrimary;
  final bool active;

  /// Contact mobile number for this address.
  final String? mobileNo;

  /// Contact email for this address.
  final String? email;

  Map<String, dynamic> toJson() => {
    'addressType': addressType,
    'line1': line1,
    if (line2 != null) 'line2': line2,
    if (city != null) 'city': city,
    if (landmark != null) 'landmark': landmark,
    if (area != null) 'area': area,
    if (postOffice != null) 'postOffice': postOffice,
    'stateId': stateId,
    'countryId': countryId,
    'pinCode': pinCode,
    if (latitude != null) 'latitude': latitude,
    if (longitude != null) 'longitude': longitude,
    if (isPrimary != null) 'isPrimary': isPrimary,
    'active': active,
    if (mobileNo != null) 'mobileNo': mobileNo,
    if (email != null) 'email': email,
  };
}

/// Common `AddressTypeEnum` names offered by picker UIs. Adjust to match the
/// backend enum values.
const List<String> kCommonAddressTypes = [
  'BILLING',
  'SHIPPING',
  'MAILING',
  'REGISTERED',
  'CORPORATE',
];
