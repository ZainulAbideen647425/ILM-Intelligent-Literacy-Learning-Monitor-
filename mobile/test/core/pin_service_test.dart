// F2-TC-01..07: PIN rules (boundary values, lockout state transitions, storage).
import 'package:flutter_test/flutter_test.dart';
import 'package:ilm_mobile/core/security/pin_service.dart';

void main() {
  late InMemoryPinStore store;
  late DateTime now;
  late PinService pins;

  setUp(() {
    store = InMemoryPinStore();
    now = DateTime(2026, 12, 1, 9);
    pins = PinService(store, clock: () => now);
  });

  group('F2-TC-01 PIN format (boundary values)', () {
    const cases = {
      '123': false, // 3 digits: below boundary
      '1234': true, // 4 digits: on boundary
      '12345': false, // 5 digits: above boundary
      '12a4': false, // non-digit
      '': false,
      ' 123': false,
      '٠١٢٣': false, // Arabic-Indic digits are not accepted by the pad
    };
    cases.forEach((pin, valid) {
      test('"$pin" -> $valid', () => expect(PinService.isValidFormat(pin), valid));
    });

    test('setPin rejects an invalid PIN', () {
      expect(() => pins.setPin('123'), throwsArgumentError);
    });
  });

  test('F2-TC-02 correct PIN unlocks; wrong PIN is rejected', () async {
    expect(await pins.hasPin(), isFalse);
    await pins.setPin('2468');
    expect(await pins.hasPin(), isTrue);
    expect((await pins.verify('2468')).status, PinStatus.ok);
    final wrong = await pins.verify('1357');
    expect(wrong.status, PinStatus.wrong);
    expect(wrong.attemptsLeft, PinService.maxAttempts - 1);
  });

  test('F2-TC-03 the PIN is never stored in plain text', () async {
    await pins.setPin('2468');
    for (final value in store.values.values) {
      expect(value.contains('2468'), isFalse);
    }
    expect(store.values['pin_hash'], isNotNull);
    expect(store.values['pin_salt'], isNotNull);
  });

  test('F2-TC-04 same PIN gets a different hash on each device (salted)', () async {
    final other = InMemoryPinStore();
    await pins.setPin('2468');
    await PinService(other).setPin('2468');
    expect(store.values['pin_hash'], isNot(other.values['pin_hash']));
  });

  test('F2-TC-05 fifth wrong try locks for 30 s (boundary: 4 vs 5)', () async {
    await pins.setPin('2468');
    for (var i = 1; i <= 4; i++) {
      final r = await pins.verify('0000');
      expect(r.status, PinStatus.wrong, reason: 'try $i');
      expect(r.attemptsLeft, PinService.maxAttempts - i);
    }
    final fifth = await pins.verify('0000');
    expect(fifth.status, PinStatus.locked);
    expect(fifth.lockRemaining, PinService.lockDuration);

    // Even the correct PIN is refused while locked.
    expect((await pins.verify('2468')).status, PinStatus.locked);
  });

  test('F2-TC-06 lock expires after 30 s and the counter resets', () async {
    await pins.setPin('2468');
    for (var i = 0; i < PinService.maxAttempts; i++) {
      await pins.verify('0000');
    }
    now = now.add(const Duration(seconds: 29));
    expect((await pins.verify('2468')).status, PinStatus.locked);
    now = now.add(const Duration(seconds: 2));
    expect((await pins.verify('2468')).status, PinStatus.ok);
    expect((await pins.verify('0000')).attemptsLeft, PinService.maxAttempts - 1);
  });

  test('F2-TC-07 a correct PIN resets the wrong-try counter', () async {
    await pins.setPin('2468');
    await pins.verify('0000');
    await pins.verify('0000');
    await pins.verify('2468');
    expect((await pins.verify('0000')).attemptsLeft, PinService.maxAttempts - 1);
  });

  test('verify without a PIN is a programming error', () {
    expect(() => pins.verify('1234'), throwsStateError);
  });
}
