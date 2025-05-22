import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkConnection {
  final Connectivity _connectivity = Connectivity();

  Future<bool> isConnected() async {
    final List<ConnectivityResult> connectivityResults =
    await _connectivity.checkConnectivity();

    // Check if any of the connectivity results indicate a connection
    return connectivityResults.any((result) =>
    result == ConnectivityResult.wifi ||
        result == ConnectivityResult.mobile);
  }
}
