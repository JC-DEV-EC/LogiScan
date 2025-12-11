import 'measurement_models.dart';

class RegisterPackageRequest {
  final String trackingNumber;
  final double weight;
  final double width;
  final double length;
  final double height;
  final List<RequestEncodeFile>? files;

  const RegisterPackageRequest({
    required this.trackingNumber,
    required this.weight,
    required this.width,
    required this.length,
    required this.height,
    this.files,
  });

  Map<String, dynamic> toJson() => {
        'trackingNumber': trackingNumber,
        'weight': weight,
        'width': width,
        'length': length,
        'height': height,
        if (files != null && files!.isNotEmpty)
          'files': files!.map((f) => f.toJson()).toList(),
      };
}

class GenericOperationResponse {
  final String? userMessage;

  const GenericOperationResponse({this.userMessage});

  factory GenericOperationResponse.fromJson(Map<String, dynamic> json) {
    final content = json['content'] as Map<String, dynamic>? ?? json;
    return GenericOperationResponse(
      userMessage: content['userMessage'] as String?,
    );
  }
}
