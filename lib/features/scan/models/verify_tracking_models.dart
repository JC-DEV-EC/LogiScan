// Modelos para verificar tracking number

class VerifyTrackingNumberRequest {
  final String trackingNumber;

  const VerifyTrackingNumberRequest({required this.trackingNumber});

  Map<String, dynamic> toJson() => {
        'trackingNumber': trackingNumber,
      };
}

class VerifyTrackingNumberResponse {
  /// Indica si el número de tracking tiene un registro
  final bool isRegistered;

  /// Fecha de registro del tracking (puede ser null)
  final DateTime? registrationDateTime;

  const VerifyTrackingNumberResponse({
    required this.isRegistered,
    this.registrationDateTime,
  });

  factory VerifyTrackingNumberResponse.fromJson(Map<String, dynamic> json) {
    print('[MODEL] VerifyTrackingNumberResponse.fromJson called');
    print('[MODEL] Raw JSON keys: ${json.keys.toList()}');
    print('[MODEL] Full JSON: $json');
    
    // El HttpService pasa el JSON completo, necesitamos extraer 'content'
    final contentJson = json['content'] as Map<String, dynamic>?;
    print('[MODEL] Content JSON: $contentJson');
    
    if (contentJson == null) {
      print('[MODEL] No content found, returning empty');
      return const VerifyTrackingNumberResponse.empty();
    }
    
    DateTime? registrationDate;
    // Soportar tanto camelCase como PascalCase
    final registrationDateTimeStr = contentJson['registrationDateTime'] ?? contentJson['RegistrationDateTime'];
    if (registrationDateTimeStr != null) {
      try {
        registrationDate = DateTime.parse(registrationDateTimeStr as String);
      } catch (_) {
        registrationDate = null;
      }
    }

    // Soportar tanto camelCase como PascalCase
    final isReg = contentJson['isRegistered'] ?? contentJson['IsRegistered'];
    print('[MODEL] isReg value: $isReg (type: ${isReg.runtimeType})');

    return VerifyTrackingNumberResponse(
      isRegistered: isReg as bool? ?? false,
      registrationDateTime: registrationDate,
    );
  }

  const VerifyTrackingNumberResponse.empty()
      : isRegistered = false,
        registrationDateTime = null;
}
