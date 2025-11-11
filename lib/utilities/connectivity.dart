import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  StreamController<bool>? _connectionStatusController;

  Stream<bool> get connectionStatus {
    _connectionStatusController ??= StreamController<bool>.broadcast(
      onListen: _initializeConnectionListener,
    );
    return _connectionStatusController!.stream;
  }

  void _initializeConnectionListener() {
    _connectivity.onConnectivityChanged.listen((result) {
      _connectionStatusController?.add(_hasConnection(result.first));
    });

    // Check initial connection
    checkConnection().then((isConnected) {
      _connectionStatusController?.add(isConnected);
    });
  }

  bool _hasConnection(ConnectivityResult result) {
    return result != ConnectivityResult.none;
  }

  Future<bool> checkConnection() async {
    try {
      final result = await _connectivity.checkConnectivity();
      return _hasConnection(result.first);
    } catch (e) {
      return false;
    }
  }

  void dispose() {
    _connectionStatusController?.close();
  }
}