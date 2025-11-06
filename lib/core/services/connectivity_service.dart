import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

/// Connectivity Service
/// Monitors network connectivity status
/// Provides real-time updates and connection checking
class ConnectivityService extends ChangeNotifier {
  // Singleton pattern
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal();

  final Connectivity _connectivity = Connectivity();

  // Current connectivity status
  ConnectivityResult _connectionStatus = ConnectivityResult.none;
  ConnectivityResult get connectionStatus => _connectionStatus;

  // Stream subscription
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;

  // Connection state
  bool get isConnected =>
      _connectionStatus != ConnectivityResult.none;

  bool get isWifi => _connectionStatus == ConnectivityResult.wifi;

  bool get isMobile => _connectionStatus == ConnectivityResult.mobile;

  bool get isEthernet => _connectionStatus == ConnectivityResult.ethernet;

  // Callbacks for connection changes
  final List<VoidCallback> _onConnectedCallbacks = [];
  final List<VoidCallback> _onDisconnectedCallbacks = [];

  // ============================================================
  // INITIALIZATION
  // ============================================================

  /// Initialize connectivity monitoring
  Future<void> initialize() async {
    // Get initial status
    _connectionStatus = await _connectivity.checkConnectivity();

    // Listen to connectivity changes
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      _updateConnectionStatus,
      onError: (error) {
        debugPrint('Connectivity error: $error');
      },
    );
  }

  /// Update connection status
  void _updateConnectionStatus(ConnectivityResult result) {
    final wasConnected = isConnected;
    _connectionStatus = result;

    // Trigger callbacks
    if (isConnected && !wasConnected) {
      _triggerOnConnectedCallbacks();
    } else if (!isConnected && wasConnected) {
      _triggerOnDisconnectedCallbacks();
    }

    notifyListeners();
  }

  // ============================================================
  // CONNECTION CHECKING
  // ============================================================

  /// Check current connectivity status
  Future<bool> checkConnection() async {
    try {
      final result = await _connectivity.checkConnectivity();
      _updateConnectionStatus(result);
      return result != ConnectivityResult.none;
    } catch (e) {
      debugPrint('Failed to check connectivity: $e');
      return false;
    }
  }

  /// Check if device has internet access (not just connectivity)
  /// This actually tests if we can reach the internet
  Future<bool> hasInternetAccess() async {
    if (!isConnected) return false;

    try {
      // You can implement actual internet check here
      // For now, we just check connectivity
      return isConnected;
    } catch (e) {
      debugPrint('Internet access check failed: $e');
      return false;
    }
  }

  // ============================================================
  // CALLBACK MANAGEMENT
  // ============================================================

  /// Register callback for when connection is established
  void addOnConnectedCallback(VoidCallback callback) {
    _onConnectedCallbacks.add(callback);
  }

  /// Remove on-connected callback
  void removeOnConnectedCallback(VoidCallback callback) {
    _onConnectedCallbacks.remove(callback);
  }

  /// Register callback for when connection is lost
  void addOnDisconnectedCallback(VoidCallback callback) {
    _onDisconnectedCallbacks.add(callback);
  }

  /// Remove on-disconnected callback
  void removeOnDisconnectedCallback(VoidCallback callback) {
    _onDisconnectedCallbacks.remove(callback);
  }

  /// Trigger all on-connected callbacks
  void _triggerOnConnectedCallbacks() {
    for (final callback in _onConnectedCallbacks) {
      try {
        callback();
      } catch (e) {
        debugPrint('Error in onConnected callback: $e');
      }
    }
  }

  /// Trigger all on-disconnected callbacks
  void _triggerOnDisconnectedCallbacks() {
    for (final callback in _onDisconnectedCallbacks) {
      try {
        callback();
      } catch (e) {
        debugPrint('Error in onDisconnected callback: $e');
      }
    }
  }

  // ============================================================
  // STATUS HELPERS
  // ============================================================

  /// Get connection type as string
  String getConnectionType() {
    switch (_connectionStatus) {
      case ConnectivityResult.wifi:
        return 'WiFi';
      case ConnectivityResult.mobile:
        return 'Mobile Data';
      case ConnectivityResult.ethernet:
        return 'Ethernet';
      case ConnectivityResult.bluetooth:
        return 'Bluetooth';
      case ConnectivityResult.vpn:
        return 'VPN';
      case ConnectivityResult.none:
        return 'No Connection';
      case ConnectivityResult.other:
        return 'Other';
      default:
        return 'Unknown';
    }
  }

  /// Get user-friendly connection message
  String getConnectionMessage() {
    if (isConnected) {
      return 'Connected via ${getConnectionType()}';
    } else {
      return 'No internet connection';
    }
  }

  /// Check if connection is suitable for large downloads
  bool isGoodForDownload() {
    return isWifi || isEthernet;
  }

  /// Check if should show data warning (mobile data)
  bool shouldShowDataWarning() {
    return isMobile;
  }

  // ============================================================
  // STREAM ACCESS
  // ============================================================

  /// Get connectivity stream
  Stream<ConnectivityResult> get connectivityStream =>
      _connectivity.onConnectivityChanged;

  /// Get boolean connectivity stream (connected/disconnected)
  Stream<bool> get isConnectedStream =>
      connectivityStream.map((result) => result != ConnectivityResult.none);

  // ============================================================
  // WAIT FOR CONNECTION
  // ============================================================

  /// Wait until device is connected
  /// Useful for operations that require internet
  ///
  /// Parameters:
  /// - [timeout]: Maximum time to wait (default: 30 seconds)
  ///
  /// Returns: true if connected, false if timeout
  Future<bool> waitForConnection({
    Duration timeout = const Duration(seconds: 30),
  }) async {
    if (isConnected) return true;

    final completer = Completer<bool>();
    late VoidCallback callback;
    Timer? timeoutTimer;

    callback = () {
      if (!completer.isCompleted) {
        completer.complete(true);
        removeOnConnectedCallback(callback);
        timeoutTimer?.cancel();
      }
    };

    addOnConnectedCallback(callback);

    timeoutTimer = Timer(timeout, () {
      if (!completer.isCompleted) {
        completer.complete(false);
        removeOnConnectedCallback(callback);
      }
    });

    return completer.future;
  }

  // ============================================================
  // RETRY LOGIC
  // ============================================================

  /// Execute function with retry on connection failure
  ///
  /// Parameters:
  /// - [function]: Async function to execute
  /// - [maxRetries]: Maximum retry attempts (default: 3)
  /// - [retryDelay]: Delay between retries (default: 2 seconds)
  ///
  /// Returns: Result of function
  /// Throws: Last exception if all retries fail
  Future<T> executeWithRetry<T>({
    required Future<T> Function() function,
    int maxRetries = 3,
    Duration retryDelay = const Duration(seconds: 2),
  }) async {
    int attempts = 0;
    Exception? lastException;

    while (attempts < maxRetries) {
      try {
        // Check connection before attempting
        if (!isConnected) {
          await checkConnection();
          if (!isConnected) {
            throw NoConnectionException();
          }
        }

        // Execute function
        return await function();
      } catch (e) {
        lastException = e is Exception ? e : Exception(e.toString());
        attempts++;

        if (attempts >= maxRetries) break;

        // Wait before retry
        await Future.delayed(retryDelay);

        // Check connection status
        await checkConnection();
      }
    }

    throw lastException ?? Exception('Operation failed after $maxRetries attempts');
  }

  // ============================================================
  // OFFLINE MODE MANAGEMENT
  // ============================================================

  /// Check if app should work in offline mode
  bool shouldWorkOffline() {
    return !isConnected;
  }

  /// Get offline status message
  String getOfflineMessage() {
    return 'You are offline. Some features may be limited.';
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  /// Dispose resources
  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    _onConnectedCallbacks.clear();
    _onDisconnectedCallbacks.clear();
    super.dispose();
  }
}

/// Exception thrown when no connection is available
class NoConnectionException implements Exception {
  final String message;
  NoConnectionException([this.message = 'No internet connection']);

  @override
  String toString() => 'NoConnectionException: $message';
}

/// Connectivity Status Model (for easier state management)
class ConnectivityStatus {
  final bool isConnected;
  final ConnectivityResult result;
  final String message;

  ConnectivityStatus({
    required this.isConnected,
    required this.result,
    required this.message,
  });

  factory ConnectivityStatus.connected(ConnectivityResult result) {
    return ConnectivityStatus(
      isConnected: true,
      result: result,
      message: 'Connected',
    );
  }

  factory ConnectivityStatus.disconnected() {
    return ConnectivityStatus(
      isConnected: false,
      result: ConnectivityResult.none,
      message: 'No internet connection',
    );
  }
}