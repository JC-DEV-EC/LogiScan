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
  /// Logo URL for the courier / company returned by the backend.
  final String? courierImageUrl;

  const LoginResponse({
    this.token,
    this.personFirstName,
    this.personLastName,
    this.entityName,
    this.courierImageUrl,
  });

  factory LoginResponse.empty() => const LoginResponse();

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    final content = json['content'] as Map<String, dynamic>? ?? json;

    return LoginResponse(
      token: content['token'] as String?,
      personFirstName: content['personFirstName'] as String?,
      personLastName: content['personLastName'] as String?,
      entityName: content['entityName'] as String?,
      courierImageUrl: content['courierImageUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'content': {
          'token': token,
          'personFirstName': personFirstName,
          'personLastName': personLastName,
          'entityName': entityName,
          'courierImageUrl': courierImageUrl,
        },
      };
}
