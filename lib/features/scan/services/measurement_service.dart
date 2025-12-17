import '../../../core/config/api_config.dart';
import '../../../core/models/api_response.dart';
import '../../../core/services/http_service.dart';
import '../models/measurement_models.dart';
import '../models/register_models.dart';
import '../models/verify_tracking_models.dart';

class MeasurementService {
  final HttpService _http;

  MeasurementService(this._http);

  Future<ApiResponse<ProcessMeasurementDataResponse>>
      processMeasurementData(ProcessMeasurementDataRequest request) async {
    try {
      final response = await _http.post<ProcessMeasurementDataResponse>(
        ApiEndpoints.processMeasurement,
        request.toJson(),
        (json) => ProcessMeasurementDataResponse.fromJson(json),
      );

      if (!response.isSuccessful) {
        return ApiResponse.error(
          messageDetail: response.messageDetail,
          content: ProcessMeasurementDataResponse.empty(),
        );
      }

      return response;
    } catch (_) {
      return ApiResponse.error(
        messageDetail: null,
        content: ProcessMeasurementDataResponse.empty(),
      );
    }
  }

  Future<ApiResponse<GenericOperationResponse>> registerPackage(
    RegisterPackageRequest request,
  ) async {
    try {
      final response = await _http.post<GenericOperationResponse>(
        ApiEndpoints.registerPackage,
        request.toJson(),
        (json) => GenericOperationResponse.fromJson(json),
      );

      if (!response.isSuccessful) {
        return ApiResponse.error(
          messageDetail: response.messageDetail,
          content: const GenericOperationResponse(userMessage: null),
        );
      }

      return response;
    } catch (_) {
      return ApiResponse.error(
        messageDetail: null,
        content: const GenericOperationResponse(userMessage: null),
      );
    }
  }

  Future<ApiResponse<VerifyTrackingNumberResponse>> verifyTrackingNumber(
    VerifyTrackingNumberRequest request,
  ) async {
    try {
      final response = await _http.post<VerifyTrackingNumberResponse>(
        ApiEndpoints.verifyTrackingNumber,
        request.toJson(),
        (json) => VerifyTrackingNumberResponse.fromJson(json),
      );

      if (!response.isSuccessful) {
        return ApiResponse.error(
          messageDetail: response.messageDetail,
          content: const VerifyTrackingNumberResponse.empty(),
        );
      }

      return response;
    } catch (_) {
      return ApiResponse.error(
        messageDetail: null,
        content: const VerifyTrackingNumberResponse.empty(),
      );
    }
  }
}
