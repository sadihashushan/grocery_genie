import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

final connectivityProvider = StateNotifierProvider<ConnectivityNotifier, bool>((ref) {
  return ConnectivityNotifier();
});

class ConnectivityNotifier extends StateNotifier<bool> {
  ConnectivityNotifier() : super(true) {
    _checkInitialConnectivity();
    _monitorConnectivity();
  }

  final Connectivity _connectivity = Connectivity();

  void _checkInitialConnectivity() async {
    final result = await _connectivity.checkConnectivity();
    state = result.isNotEmpty && result.first != ConnectivityResult.none;
  }

  void _monitorConnectivity() {
    _connectivity.onConnectivityChanged.listen((List<ConnectivityResult> results) {
      // Ensure results list is not empty before checking connectivity
      state = results.isNotEmpty && results.first != ConnectivityResult.none;
    });
  }
}
