class RequestEncodeFile {
  final String encodeContent;
  final String fileExtension;
  final String fileName;

  const RequestEncodeFile({
    required this.encodeContent,
    required this.fileExtension,
    required this.fileName,
  });

  Map<String, dynamic> toJson() => {
        'encodeContent': encodeContent,
        'fileExtension': fileExtension,
        'fileName': fileName,
      };
}

class ProcessMeasurementDataRequest {
  final RequestEncodeFile file;

  const ProcessMeasurementDataRequest({required this.file});

  Map<String, dynamic> toJson() => {
        'file': file.toJson(),
      };
}

class ProcessMeasurementDataResponse {
  final double? weight;
  final double? width;
  final double? length;
  final double? height;

  const ProcessMeasurementDataResponse({
    this.weight,
    this.width,
    this.length,
    this.height,
  });

  factory ProcessMeasurementDataResponse.empty() =>
      const ProcessMeasurementDataResponse();

  /// Accepts either the outer generic wrapper or the raw content map
  /// from ProcessMeasurementDataResponseGenericResponse.
  factory ProcessMeasurementDataResponse.fromJson(Map<String, dynamic> json) {
    final content = json['content'] as Map<String, dynamic>? ?? json;

    double? _asDouble(dynamic value) {
      if (value == null) return null;
      if (value is num) return value.toDouble();
      return double.tryParse(value.toString());
    }

    return ProcessMeasurementDataResponse(
      weight: _asDouble(content['weight']),
      width: _asDouble(content['width']),
      length: _asDouble(content['length']),
      height: _asDouble(content['height']),
    );
  }
}
