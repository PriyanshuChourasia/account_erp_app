/// HTTP method used for an API operation.
enum ApiMethod {
  post('POST'),
  put('PUT'),
  get('GET'),
  delete('DELETE'),
  options('OPTIONS'),
  head('HEAD');

  const ApiMethod(this.wireValue);

  /// Serialized value sent on the wire, e.g. `GET`.
  final String wireValue;
}