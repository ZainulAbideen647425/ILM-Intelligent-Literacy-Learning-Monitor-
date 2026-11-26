import 'package:flutter/widgets.dart';

import '../../data/auth_repository.dart';
import '../../data/screening_repository.dart';
import '../security/pin_service.dart';

/// Where the teacher is in the sign-in flow.
enum SessionStage { signedOut, createPin, locked, unlocked }

/// App-wide session state (ChangeNotifier from the Flutter SDK, so no extra
/// state-management dependency is needed).
///
/// Transitions: signedOut -> createPin (first sign-in) or locked (PIN exists)
/// -> unlocked; unlocked -> locked (lock) or signedOut (sign out).
class AppSession extends ChangeNotifier {
  AppSession({
    required this.auth,
    required this.pins,
    required this.screening,
    this.classId = 'class-3b',
  });

  final AuthRepository auth;
  final PinService pins;
  final ScreeningRepository screening;
  final String classId;

  SessionStage _stage = SessionStage.signedOut;
  SessionStage get stage => _stage;

  String? _teacherEmail;
  String? get teacherEmail => _teacherEmail;

  /// Returns null on success or an AppStrings error key.
  Future<String?> signIn(String email, String password) async {
    final error = await auth.signIn(email, password);
    if (error != null) return error;
    _teacherEmail = email.trim();
    _stage = await pins.hasPin() ? SessionStage.locked : SessionStage.createPin;
    notifyListeners();
    return null;
  }

  Future<void> createPin(String pin) async {
    assert(_stage == SessionStage.createPin);
    await pins.setPin(pin);
    _go(SessionStage.unlocked);
  }

  void unlock() {
    assert(_stage == SessionStage.locked);
    _go(SessionStage.unlocked);
  }

  void lock() {
    if (_stage == SessionStage.unlocked) _go(SessionStage.locked);
  }

  void signOut() {
    _teacherEmail = null;
    _go(SessionStage.signedOut);
  }

  void _go(SessionStage next) {
    _stage = next;
    notifyListeners();
  }
}

/// Makes the [AppSession] available to the widget tree.
class SessionScope extends InheritedNotifier<AppSession> {
  const SessionScope({super.key, required AppSession session, required super.child})
      : super(notifier: session);

  static AppSession of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<SessionScope>();
    assert(scope != null, 'No SessionScope above this widget.');
    return scope!.notifier!;
  }

  /// Reads the session without rebuilding when it changes.
  static AppSession read(BuildContext context) {
    final element = context.getElementForInheritedWidgetOfExactType<SessionScope>();
    assert(element != null, 'No SessionScope above this widget.');
    return (element!.widget as SessionScope).notifier!;
  }
}
