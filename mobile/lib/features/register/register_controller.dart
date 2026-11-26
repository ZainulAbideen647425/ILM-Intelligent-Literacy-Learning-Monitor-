import 'package:flutter/foundation.dart';

import '../../core/models/models.dart';
import '../../data/screening_repository.dart';

enum RegisterFilter { everyone, followUp, notYet }

/// State for the class register: the class, the active filter and
/// recording finished sessions while offline.
class RegisterController extends ChangeNotifier {
  RegisterController({required this.repository, required this.classId});

  final ScreeningRepository repository;
  final String classId;

  ClassRoom? _classRoom;
  ClassRoom? get classRoom => _classRoom;

  Object? _error;
  Object? get error => _error;

  RegisterFilter _filter = RegisterFilter.everyone;
  RegisterFilter get filter => _filter;

  Future<void> load() async {
    try {
      _classRoom = await repository.getClass(classId);
      _error = null;
    } catch (e) {
      _error = e;
    }
    notifyListeners();
  }

  void setFilter(RegisterFilter value) {
    if (value == _filter) return;
    _filter = value;
    notifyListeners();
  }

  List<Child> get visibleChildren {
    final children = _classRoom?.children ?? const <Child>[];
    return switch (_filter) {
      RegisterFilter.everyone => children,
      RegisterFilter.followUp =>
        children.where((c) => c.signal == Signal.followUp).toList(),
      RegisterFilter.notYet =>
        children.where((c) => c.signal == Signal.notYet).toList(),
    };
  }

  /// Marks [childId]'s session as saved offline and moves "next up" to the
  /// following child who can start.
  void completeSession(String childId) {
    final room = _classRoom;
    if (room == null) return;
    final updated = [
      for (final c in room.children)
        c.id == childId
            ? c.copyWith(hasPendingSession: true, isNextUp: false)
            : c.copyWith(isNextUp: false),
    ];
    var next = room.copyWith(
      children: updated,
      savedOfflineCount: room.savedOfflineCount + 1,
    );
    final nextChild = next.nextChild;
    if (nextChild != null) {
      next = next.copyWith(
        children: [
          for (final c in next.children)
            c.id == nextChild.id ? c.copyWith(isNextUp: true) : c,
        ],
      );
    }
    _classRoom = next;
    notifyListeners();
  }
}
