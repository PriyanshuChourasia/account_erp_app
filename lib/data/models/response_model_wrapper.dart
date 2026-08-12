/// Envelope wrapped around every API response:
///
/// ```json
/// { "code": 200, "status": "OK", "message": "ok",
///   "data": { "result": { ... } } }
/// ```
///
/// Repositories are responsible for unwrapping this envelope and converting
/// failures into [AppException]. The `result` payload is parsed with the
/// provided `fromJson` converter when one is supplied.
class ResponseModelWrapper<T> {
  const ResponseModelWrapper({
    this.code,
    required this.success,
    this.message,
    this.data,
  });

  final int? code;
  final bool success;
  final String? message;
  final ResponseData<T>? data;

  factory ResponseModelWrapper.fromJson(
    Map<String, dynamic> json, {
    T Function(Map<String, dynamic> json)? fromJson,
  }) {
    final rawCode = json['code'];
    final code = rawCode is int ? rawCode : int.tryParse('$rawCode');
    final rawData = json['data'];
    return ResponseModelWrapper<T>(
      code: code,
      success: json['status'] == 'OK' || (code != null && code >= 200 && code < 300),
      message: json['message'] as String?,
      data: rawData is Map<String, dynamic>
          ? ResponseData<T>.fromJson(rawData, fromJson: fromJson)
          : null,
    );
  }
}

/// The `data` segment of the envelope: `{ result: T, error }`.
class ResponseData<T> {
  const ResponseData({this.result, this.error});

  final T? result;
  final ApiErrorModel? error;

  factory ResponseData.fromJson(
    Map<String, dynamic> json, {
    T Function(Map<String, dynamic> json)? fromJson,
  }) {
    return ResponseData<T>(
      result: _parseResult(json['result'], fromJson),
      error: json['error'] is Map<String, dynamic>
          ? ApiErrorModel.fromJson(json['error'] as Map<String, dynamic>)
          : null,
    );
  }

  static T? _parseResult<T>(
    dynamic rawResult,
    T Function(Map<String, dynamic> json)? fromJson,
  ) {
    if (rawResult == null) return null;
    if (fromJson == null) return rawResult is T ? rawResult : null;
    if (rawResult is! Map<String, dynamic>) return null;
    return fromJson(rawResult);
  }
}

/// Structured `error` object that may accompany a failed response.
class ApiErrorModel {
  const ApiErrorModel({this.code, this.message});

  final int? code;
  final String? message;

  factory ApiErrorModel.fromJson(Map<String, dynamic> json) => ApiErrorModel(
        code: json['code'] is int ? json['code'] as int : null,
        message: json['message'] as String?,
      );
}
