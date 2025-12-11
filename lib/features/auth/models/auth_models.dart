/// Request para login
class LoginRequest {
  final String username;
  final String password;

  const LoginRequest({
    required this.username,
    required this.password,
  });

  Map<String, dynamic> toJson() => {
        'username': username,
        'password': password,
      };
}

/// Login response used across the app
class LoginResponse {
  final String? token;
  final String? personFirstName;
  final String? personLastName;
  final String? entityName;

  const LoginResponse({
    this.token,
    this.personFirstName,
    this.personLastName,
    this.entityName,
  });

  factory LoginResponse.empty() => const LoginResponse();

  /// The backend wraps LoginResponse in a generic "LoginResponseGenericResponse"
  /// with fields: code, responseType, message, messageDetail, content.
  /// This factory accepts either the outer wrapper or the raw content map.
  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    final content = json['content'] as Map<String, dynamic>? ?? json;

    return LoginResponse(
      token: content['token'] as String?,
      personFirstName: content['personFirstName'] as String?,
      personLastName: content['personLastName'] as String?,
      entityName: content['entityName'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'content': {
          'token': token,
          'personFirstName': personFirstName,
          'personLastName': personLastName,
          'entityName': entityName,
        },
      };
}
