import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter/foundation.dart';
import 'package:front_end/core/services/api_config.dart';
import 'auth_storage.dart';

class SocketService {
  static IO.Socket? _socket;
  static Function(dynamic)? _onNotification;
  static bool _isConnecting = false;

  /// Single entry-point: connects (if needed) and registers the listener.
  static Future<void> connectAndListen(Function(dynamic) onNotification) async {
    _onNotification = onNotification;

    // ── If already connected, just (re-)register the listener and return ──
    if (_socket != null && _socket!.connected) {
      _socket!.off('new_notification');
      _socket!.on('new_notification', (data) => _onNotification!(data));
      debugPrint('🔄 Socket already connected — listener re-registered');
      return;
    }

    // Prevent concurrent startup calls (like Splash + Provider constr) from killing each other
    if (_isConnecting) {
      debugPrint(
          '⏳ Socket is currently connecting — skipping duplicate attempt');
      return;
    }

    final token = await AuthStorage.getToken();
    if (token == null) {
      debugPrint('⚠️ No token found, socket not connected');
      return;
    }

    _isConnecting = true;

    // Dispose stale socket before creating a new one
    _socket?.dispose();

    // 🔴 THE FIX: enableForceNew() prevents socket_io_client from returning the exact
    // same cached (and now disposed) socket instance if the baseUrl hasn't changed.
    _socket = IO.io(
      ApiConfig.baseUrl,
      IO.OptionBuilder()
          .setTransports(['websocket', 'polling']) // 🔥 ALLOW FALLBACK FOR WEB
          .setAuth({'token': token})
          .disableAutoConnect() // We connect manually after setting up listeners
          .enableForceNew() // BUST CACHE on cold restarts
          .enableReconnection()
          .setReconnectionDelay(1000)
          .setReconnectionAttempts(99)
          .setExtraHeaders({'Connection': 'upgrade', 'Upgrade': 'websocket'})
          .build(),
    );

    _socket!.onConnect((_) {
      _isConnecting = false;
      debugPrint('✅ Socket connected & Handshake Complete');
      if (_onNotification != null) {
        _socket!.off('new_notification');
        _socket!.on('new_notification', (data) => _onNotification!(data));
        debugPrint('🔔 new_notification listener active');
      }
    });

    _socket!.onDisconnect((_) {
      _isConnecting = false;
      debugPrint('❌ Socket disconnected');
    });

    _socket!.onConnectError((e) {
      _isConnecting = false;
      debugPrint('⚠️ Socket connect error: $e');
    });

    _socket!.onError((e) {
      _isConnecting = false;
      debugPrint('⚠️ Socket error: $e');
    });

    // Now manually trigger connection since auto-connect is disabled
    _socket!.connect();
  }

  static void disconnect() {
    _isConnecting = false;
    _socket?.dispose();
    _socket = null;
    _onNotification = null;
  }
}
