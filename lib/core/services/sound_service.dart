import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum TransactionSound {
  income,
  expense,
  transfer,
  goalDeposit,
  goalWithdraw,
  reverse,
}

class SoundService {
  SoundService._();
  static final SoundService instance = SoundService._();

  static const _prefKey = 'sound_enabled';

  bool _soundEnabled = true;
  final AudioPlayer _player = AudioPlayer();

  // Map each type to its asset path
  static const _soundAssets = {
    TransactionSound.income:      'sounds/income.mp3',
    TransactionSound.expense:     'sounds/expense.mp3',
    TransactionSound.transfer:    'sounds/transfer.mp3',
    TransactionSound.goalDeposit: 'sounds/goal_deposit.mp3',
    TransactionSound.goalWithdraw:'sounds/goal_withdraw.mp3',
    TransactionSound.reverse:     'sounds/reverse.mp3',
  };

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _soundEnabled = prefs.getBool(_prefKey) ?? true;

    // Set low latency mode for snappy playback
    await _player.setPlayerMode(PlayerMode.lowLatency);
  }

  Future<void> playTransaction(TransactionSound type) async {
    if (!_soundEnabled) return;

    // Play sound and haptic at the same time
    await Future.wait([
      _playSound(type),
      _vibrate(type),
    ]);
  }

  Future<void> _playSound(TransactionSound type) async {
    try {
      final asset = _soundAssets[type];
      if (asset == null) return;

      // Stop any currently playing sound first to avoid overlap
      await _player.stop();
      await _player.play(AssetSource(asset));
    } catch (e) {
      // Fail silently — sound is non-critical
    }
  }

  Future<void> setSoundEnabled(bool enabled) async {
    _soundEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefKey, enabled);
  }

  bool get soundEnabled => _soundEnabled;

  Future<void> _vibrate(TransactionSound type) async {
    try {
      switch (type) {
        case TransactionSound.income:
          HapticFeedback.lightImpact();
          break;
        case TransactionSound.expense:
          HapticFeedback.mediumImpact();
          break;
        case TransactionSound.transfer:
          HapticFeedback.selectionClick();
          break;
        default:
          HapticFeedback.lightImpact();
      }
    } catch (_) {}
  }

  Future<void> dispose() async {
    await _player.dispose();
  }
}