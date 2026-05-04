import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'dart:io';

class Esp32Service {
  WebSocket? _webSocket;
  final StreamController<Map<String, dynamic>> _dataController =
      StreamController.broadcast();

  Stream<Map<String, dynamic>> get dataStream => _dataController.stream;

  bool get isConnected => _webSocket != null;

  Future<bool> connectToDevice(String ipAddress, int port) async {
    try {
      final wsUrl = 'ws://$ipAddress:$port/ws';
      _webSocket = await WebSocket.connect(wsUrl);

      _listenToMessages();
      debugPrint('✓ Connected to ESP32 at $wsUrl');
      return true;
    } catch (e) {
      debugPrint('✗ Failed to connect to ESP32: $e');
      _webSocket = null;
      return false;
    }
  }

  void _listenToMessages() {
    if (_webSocket == null) return;

    _webSocket!.listen(
      (dynamic message) {
        try {
          final data = jsonDecode(message.toString()) as Map<String, dynamic>;
          _dataController.add(data);
        } catch (e) {
          debugPrint('Error parsing ESP32 message: $e');
        }
      },
      onError: (dynamic error) {
        debugPrint('WebSocket error: $error');
        _dataController.addError(error);
        disconnect();
      },
      onDone: () {
        debugPrint('WebSocket closed');
        _webSocket = null;
      },
    );
  }

  Future<void> sendCommand(String command) async {
    if (_webSocket == null) {
      throw Exception('WebSocket not connected');
    }

    try {
      _webSocket?.add(jsonEncode({'cmd': command}));
      debugPrint('→ Sent command: $command');
    } catch (e) {
      debugPrint('✗ Failed to send command: $e');
      rethrow;
    }
  }

  Future<void> disconnect() async {
    try {
      if (_webSocket != null) {
        await _webSocket!.close();
      }
      _webSocket = null;
      debugPrint('✓ Disconnected from ESP32');
    } catch (e) {
      debugPrint('Error disconnecting: $e');
    }
  }

  void dispose() {
    disconnect();
    _dataController.close();
  }
}
