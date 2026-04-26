// core/network/connectivity_service.dart
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  static final _instance = ConnectivityService._();
  factory ConnectivityService() => _instance;
  ConnectivityService._();

  final _connectivity = Connectivity();

  Stream<bool> get onConnectivityChanged => _connectivity.onConnectivityChanged
      .map((results) => results.any((r) => r != ConnectivityResult.none));

  Future<bool> get isConnected async {
    final results = await _connectivity.checkConnectivity();
    return results.any((r) => r != ConnectivityResult.none);
  }
}
