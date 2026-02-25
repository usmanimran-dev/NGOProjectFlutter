import 'package:connectivity_plus/connectivity_plus.dart';

abstract class NetworkInfo {
  Future<bool> get isConnected;
}

class NetworkInfoImpl implements NetworkInfo {
  final Connectivity connectivity;

  NetworkInfoImpl(this.connectivity);

  @override
  Future<bool> get isConnected async {
    try {
      final dynamic result = await connectivity.checkConnectivity();
      // Handle both List<ConnectivityResult> (v6.x) and ConnectivityResult (v5.x)
      if (result is List) {
        return result.isNotEmpty && !result.contains(ConnectivityResult.none);
      }
      return result != ConnectivityResult.none;
    } catch (_) {
      // Default to true if connectivity check fails (common on web/desktop)
      return true;
    }
  }
}
