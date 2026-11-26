// F2-TC-08..10: session state transitions and sign-in validation.
import 'package:flutter_test/flutter_test.dart';
import 'package:ilm_mobile/core/security/pin_service.dart';
import 'package:ilm_mobile/core/session/app_session.dart';
import 'package:ilm_mobile/data/auth_repository.dart';
import 'package:ilm_mobile/data/screening_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  AppSession newSession([PinService? pins]) => AppSession(
        auth: const MockAuthRepository(),
        pins: pins ?? PinService(InMemoryPinStore()),
        screening: MockScreeningRepository(),
      );

  group('F2-TC-08 sign-in validation (equivalence partitions)', () {
    const auth = MockAuthRepository();
    test('valid', () async => expect(await auth.signIn('teacher@school.pk', 'longenough'), isNull));
    test('no @', () async => expect(await auth.signIn('teacher.school.pk', 'longenough'), 'invalidEmail'));
    test('no domain dot', () async => expect(await auth.signIn('t@school', 'longenough'), 'invalidEmail'));
    test('empty', () async => expect(await auth.signIn('', ''), 'invalidEmail'));
    test('7-char password (boundary)', () async => expect(await auth.signIn('t@s.pk', '1234567'), 'passwordTooShort'));
    test('8-char password (boundary)', () async => expect(await auth.signIn('t@s.pk', '12345678'), isNull));
    test('surrounding spaces in email are ignored', () async => expect(await auth.signIn('  t@s.pk ', '12345678'), isNull));
  });

  test('F2-TC-09 first sign-in: signedOut -> createPin -> unlocked', () async {
    final session = newSession();
    expect(session.stage, SessionStage.signedOut);
    expect(await session.signIn('t@s.pk', 'bad'), 'passwordTooShort');
    expect(session.stage, SessionStage.signedOut);
    expect(await session.signIn('t@s.pk', '12345678'), isNull);
    expect(session.stage, SessionStage.createPin);
    await session.createPin('2468');
    expect(session.stage, SessionStage.unlocked);
  });

  test('F2-TC-10 later sign-in goes to unlock; lock and sign out', () async {
    final pins = PinService(InMemoryPinStore());
    await pins.setPin('2468');
    final session = newSession(pins);
    var notifications = 0;
    session.addListener(() => notifications++);

    await session.signIn('t@s.pk', '12345678');
    expect(session.stage, SessionStage.locked);
    session.unlock();
    expect(session.stage, SessionStage.unlocked);
    session.lock();
    expect(session.stage, SessionStage.locked);
    session.lock(); // no-op when already locked
    session.signOut();
    expect(session.stage, SessionStage.signedOut);
    expect(session.teacherEmail, isNull);
    expect(notifications, 4);
  });
}
