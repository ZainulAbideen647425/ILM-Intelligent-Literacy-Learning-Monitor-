import 'dart:convert';

import 'package:flutter/services.dart';

import '../core/models/models.dart';

/// Data access used by the UI. The frontend sprint runs on [MockScreeningRepository];
/// the real HTTP implementation follows docs/api-contract.yaml and replaces it
/// without UI changes.
abstract interface class ScreeningRepository {
  Future<ClassRoom> getClass(String classId);
}

/// Serves sample data from `assets/mock/`. All names are invented sample data;
/// no real child data is ever stored in this repository.
class MockScreeningRepository implements ScreeningRepository {
  MockScreeningRepository({AssetBundle? bundle})
    : _bundle = bundle ?? rootBundle;

  final AssetBundle _bundle;

  static const Map<String, String> _classAssets = {
    'class-3b': 'assets/mock/class_3b.json',
  };

  @override
  Future<ClassRoom> getClass(String classId) async {
    final path = _classAssets[classId];
    if (path == null) {
      throw ArgumentError.value(classId, 'classId', 'No mock data');
    }
    return parseClass(await _bundle.loadString(path));
  }

  /// Parses a class payload in the API-contract shape.
  static ClassRoom parseClass(String source) =>
      ClassRoom.fromJson(jsonDecode(source) as Map<String, Object?>);
}

/// Serves a class already held in memory. Used by widget tests (asset loading
/// is cached across tests and can hang inside the test clock) and demos.
class InMemoryScreeningRepository implements ScreeningRepository {
  InMemoryScreeningRepository(List<ClassRoom> classes)
    : _classes = {for (final c in classes) c.id: c};

  final Map<String, ClassRoom> _classes;

  @override
  Future<ClassRoom> getClass(String classId) async {
    final room = _classes[classId];
    if (room == null) {
      throw ArgumentError.value(classId, 'classId', 'No such class');
    }
    return room;
  }
}
