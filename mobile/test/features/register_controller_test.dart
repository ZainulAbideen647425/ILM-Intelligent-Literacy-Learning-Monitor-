// F2-TC-11..13: register filters (equivalence classes) and offline session flow.
import 'package:flutter_test/flutter_test.dart';
import 'package:ilm_mobile/core/models/models.dart';
import 'package:ilm_mobile/data/screening_repository.dart';
import 'package:ilm_mobile/features/register/register_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late RegisterController controller;

  setUp(() async {
    controller = RegisterController(repository: MockScreeningRepository(), classId: 'class-3b');
    await controller.load();
  });

  test('F2-TC-11 filters return the right children', () {
    expect(controller.visibleChildren, hasLength(8));
    controller.setFilter(RegisterFilter.followUp);
    expect(controller.visibleChildren.map((c) => c.displayName), ['Areeba Khan', 'Mahnoor Ali']);
    controller.setFilter(RegisterFilter.notYet);
    expect(controller.visibleChildren.map((c) => c.id), ['c05', 'c06', 'c08']);
  });

  test('F2-TC-12 next child = next-up child, never one without consent', () {
    final room = controller.classRoom!;
    expect(room.nextChild!.displayName, 'Noor Fatima');
    final c06 = room.children.firstWhere((c) => c.id == 'c06');
    expect(c06.canStart, isFalse, reason: 'no consent');
  });

  test('F2-TC-13 finishing a session saves it offline and moves next-up', () {
    controller.completeSession('c05');
    final room = controller.classRoom!;
    final noor = room.children.firstWhere((c) => c.id == 'c05');
    expect(noor.hasPendingSession, isTrue);
    expect(noor.canStart, isFalse);
    expect(room.savedOfflineCount, 8);
    expect(room.nextChild!.id, 'c08', reason: 'c06 has no consent');
    expect(room.children.where((c) => c.isNextUp).map((c) => c.id), ['c08']);

    controller.completeSession('c08');
    expect(controller.classRoom!.nextChild, isNull);
  });

  test('load error is reported, not thrown', () async {
    final bad = RegisterController(repository: MockScreeningRepository(), classId: 'missing');
    await bad.load();
    expect(bad.error, isA<ArgumentError>());
    expect(bad.classRoom, isNull);
  });

  test('a child is screened only once: signals other than not-yet cannot start', () {
    const done = Child(id: 'x', displayName: 'X Y', signal: Signal.allClear, hasConsent: true);
    expect(done.canStart, isFalse);
    expect(done.firstName, 'X');
  });
}
