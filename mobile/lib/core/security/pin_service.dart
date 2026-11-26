import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Key-value store for PIN data. Production uses [SecurePinStore]
/// (Android Keystore-backed); tests use [InMemoryPinStore].
abstract interface class PinStore {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
  Future<void> delete(String key);
}

class InMemoryPinStore implements PinStore {
  final Map<String, String> values = {};

  @override
  Future<String?> read(String key) async => values[key];

  @override
  Future<void> write(String key, String value) async => values[key] = value;

  @override
  Future<void> delete(String key) async => values.remove(key);
}

/// Stores PIN data with flutter_secure_storage (AES-GCM, key in Android
/// Keystore). Android auto-backup is disabled in the manifest so keys and
/// child data never leave the device.
class SecurePinStore implements PinStore {
  SecurePinStore([FlutterSecureStorage? storage])
      : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  @override
  Future<String?> read(String key) => _storage.read(key: key);

  @override
  Future<void> write(String key, String value) =>
      _storage.write(key: key, value: value);

  @override
  Future<void> delete(String key) => _storage.delete(key: key);
}

enum PinStatus { ok, wrong, locked }

class PinCheckResult {
  const PinCheckResult(this.status, {this.attemptsLeft = 0, this.lockRemaining = Duration.zero});

  final PinStatus status;
  final int attemptsLeft;
  final Duration lockRemaining;
}

/// Teacher PIN: exactly 4 digits, stored only as a salted, iterated SHA-256
/// hash. After [maxAttempts] wrong tries the PIN is locked for [lockDuration].
///
/// A 4-digit PIN is a convenience lock for a shared classroom device, not the
/// account password; the lockout is what makes guessing impractical.
class PinService {
  PinService(this._store, {DateTime Function()? clock, Random? random})
      : _now = clock ?? DateTime.now,
        _random = random ?? Random.secure();

  static const int pinLength = 4;
  static const int maxAttempts = 5;
  static const Duration lockDuration = Duration(seconds: 30);
  static const int _hashRounds = 10000;

  static const String _kHash = 'pin_hash';
  static const String _kSalt = 'pin_salt';
  static const String _kFailed = 'pin_failed';
  static const String _kLockedUntil = 'pin_locked_until';

  final PinStore _store;
  final DateTime Function() _now;
  final Random _random;

  static final RegExp _format = RegExp(r'^\d{4}$');

  static bool isValidFormat(String pin) => _format.hasMatch(pin);

  Future<bool> hasPin() async => (await _store.read(_kHash)) != null;

  Future<void> setPin(String pin) async {
    if (!isValidFormat(pin)) {
      throw ArgumentError.value('****', 'pin', 'must be exactly $pinLength digits');
    }
    final salt = base64Encode(List<int>.generate(16, (_) => _random.nextInt(256)));
    await _store.write(_kSalt, salt);
    await _store.write(_kHash, _hash(pin, salt));
    await _store.write(_kFailed, '0');
    await _store.delete(_kLockedUntil);
  }

  Future<PinCheckResult> verify(String pin) async {
    final remaining = await lockRemaining();
    if (remaining > Duration.zero) {
      return PinCheckResult(PinStatus.locked, lockRemaining: remaining);
    }
    final hash = await _store.read(_kHash);
    final salt = await _store.read(_kSalt);
    if (hash == null || salt == null) {
      throw StateError('No PIN has been set.');
    }
    if (isValidFormat(pin) && _constantTimeEquals(_hash(pin, salt), hash)) {
      await _store.write(_kFailed, '0');
      await _store.delete(_kLockedUntil);
      return const PinCheckResult(PinStatus.ok, attemptsLeft: maxAttempts);
    }
    final failed = int.parse(await _store.read(_kFailed) ?? '0') + 1;
    if (failed >= maxAttempts) {
      final until = _now().add(lockDuration);
      await _store.write(_kLockedUntil, until.toIso8601String());
      await _store.write(_kFailed, '0');
      return const PinCheckResult(PinStatus.locked, lockRemaining: lockDuration);
    }
    await _store.write(_kFailed, '$failed');
    return PinCheckResult(PinStatus.wrong, attemptsLeft: maxAttempts - failed);
  }

  Future<Duration> lockRemaining() async {
    final raw = await _store.read(_kLockedUntil);
    if (raw == null) return Duration.zero;
    final left = DateTime.parse(raw).difference(_now());
    return left.isNegative ? Duration.zero : left;
  }

  Future<void> clear() async {
    for (final key in [_kHash, _kSalt, _kFailed, _kLockedUntil]) {
      await _store.delete(key);
    }
  }

  static String _hash(String pin, String salt) {
    var digest = sha256.convert(utf8.encode('$salt:$pin')).bytes;
    for (var i = 1; i < _hashRounds; i++) {
      digest = sha256.convert([...digest, ...utf8.encode(salt)]).bytes;
    }
    return base64Encode(digest);
  }

  static bool _constantTimeEquals(String a, String b) {
    if (a.length != b.length) return false;
    var diff = 0;
    for (var i = 0; i < a.length; i++) {
      diff |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
    }
    return diff == 0;
  }
}
