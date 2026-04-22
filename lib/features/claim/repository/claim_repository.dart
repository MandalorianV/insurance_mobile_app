import 'package:dio/dio.dart';
import 'package:insurance_mobile_app/features/claim/models/claim_types_model.dart';
import 'package:insurance_mobile_app/features/claim/services/claim_services.dart';

abstract class ClaimRepositoryInterface {
  Future<List<ClaimType>> getClaimTypes();
}

class ClaimRepository implements ClaimRepositoryInterface {
  final ClaimServices _service;
  ClaimRepository(this._service);
  @override
  Future<List<ClaimType>> getClaimTypes() async {
    try {
      // 1. Servis üzerinden ham veriyi iste
      final List<dynamic> rawData = await _service.getClaimTypes();

      // 2. Ham veriyi (Map) Model nesnelerine dönüştür
      return rawData.map((json) => ClaimType.fromJson(json)).toList();
    } on DioException catch (dioError) {
      // 3. Teknik hatayı yakala ve anlamsal hataya çevir
      throw _handleNetworkError(dioError);
    } catch (e) {
      // Beklenmedik diğer hatalar (Parsing vb.)
      throw Exception("Veriler işlenirken bir hata oluştu.");
    }
  }

  _handleNetworkError(DioException dioError) {
    // Hata yönetimi burada yapılabilir
    return Exception("Ağ hatası oluştu.");
  }
}
