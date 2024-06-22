import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class NetworkMonitor with ChangeNotifier {
  bool _isConnected = true;
  final Connectivity _connectivity = Connectivity();

  NetworkMonitor() {
    _connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      bool previousConnectionStatus = _isConnected;
      _isConnected = result != ConnectivityResult.none;
      if (previousConnectionStatus != _isConnected) {
        notifyListeners();
      }
    });
  }

  bool get isConnected => _isConnected;
}
