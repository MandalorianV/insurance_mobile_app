import 'package:dio/dio.dart';
import 'package:insurance_mobile_app/features/insurance_dashboard/models/insurance_model.dart';
import 'package:insurance_mobile_app/features/insurance_dashboard/services/insurance_services.dart';

abstract class InsuranceRepositoryInterface {
  Future<List<InsuranceModel>> getActivePolicies();
}

class InsuranceRepository implements InsuranceRepositoryInterface {
  final InsuranceServices _service;
  InsuranceRepository(this._service);
  @override
  Future<List<InsuranceModel>> getActivePolicies() async {
    try {
      // 1. Servis üzerinden ham veriyi iste
      final List<dynamic> rawData = await _service.getActiveInsurances();

      // 2. Ham veriyi (Map) Model nesnelerine dönüştür
      return rawData.map((json) => InsuranceModel.fromJson(json)).toList();
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
