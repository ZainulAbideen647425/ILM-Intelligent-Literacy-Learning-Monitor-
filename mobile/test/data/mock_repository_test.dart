// F1-TC-09..11: models and mock data follow docs/api-contract.yaml.
import 'package:flutter_test/flutter_test.dart';
import 'package:ilm_mobile/core/models/models.dart';
import 'package:ilm_mobile/data/screening_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('F1-TC-09 mock class loads from assets and matches the contract',
      () async {
    final classRoom = await MockScreeningRepository().getClass('class-3b');
    expect(classRoom.name, 'Class 3-B');
    expect(classRoom.total, 8);
    expect(classRoom.screenedCount, 5);
    expect(classRoom.countOf(Signal.followUp), 2);
    expect(classRoom.children.where((c) => !c.hasConsent), hasLength(1));
    expect(classRoom.children.where((c) => c.isNextUp), hasLength(1));
  });

  test('F1-TC-10 unknown class id is rejected', () {
    expect(
      () => MockScreeningRepository().getClass('nope'),
      throwsA(isA<ArgumentError>()),
    );
  });

  test('F1-TC-11 unknown signal value is rejected', () {
    expect(() => Signal.fromWire('weak'), throwsFormatException);
    expect(Signal.fromWire('all_clear'), Signal.allClear);
  });

  group('Child.initials (equivalence classes)', () {
    Child child(String name) => Child(
        id: 'x', displayName: name, signal: Signal.notYet, hasConsent: true);

    test('two names', () => expect(child('Areeba Khan').initials, 'AK'));
    test('three names uses first and last',
        () => expect(child('Noor ul Ain').initials, 'NA'));
    test('one name', () => expect(child('Taha').initials, 'T'));
    test(
        'extra spaces', () => expect(child('  Saad   Rehman ').initials, 'SR'));
    test('empty name', () => expect(child('   ').initials, '?'));
  });
}
