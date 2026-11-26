/// Data models shared by the app. Field names follow docs/api-contract.yaml.
library;

/// Screening result signal. Each value has its own colour AND shape in the UI
/// so results are readable without colour vision.
enum Signal {
  followUp('follow_up'),
  watch('watch'),
  allClear('all_clear'),
  notYet('not_yet');

  const Signal(this.wire);

  /// Value used in the API contract.
  final String wire;

  static Signal fromWire(String value) => Signal.values.firstWhere(
    (s) => s.wire == value,
    orElse: () => throw FormatException('Unknown signal: $value'),
  );
}

/// How often a pattern was seen, shown to teachers as a word, never a number.
enum Level {
  many('many'),
  some('some'),
  few('few');

  const Level(this.wire);

  final String wire;

  static Level fromWire(String value) => Level.values.firstWhere(
    (l) => l.wire == value,
    orElse: () => throw FormatException('Unknown level: $value'),
  );
}

class Child {
  const Child({
    required this.id,
    required this.displayName,
    required this.signal,
    required this.hasConsent,
    this.isNextUp = false,
  });

  factory Child.fromJson(Map<String, Object?> json) => Child(
    id: json['id']! as String,
    displayName: json['display_name']! as String,
    signal: Signal.fromWire(json['signal']! as String),
    hasConsent: json['has_consent']! as bool,
    isNextUp: (json['is_next_up'] as bool?) ?? false,
  );

  final String id;
  final String displayName;
  final Signal signal;
  final bool hasConsent;
  final bool isNextUp;

  /// Up to two initials from the display name, e.g. "Areeba Khan" -> "AK".
  String get initials {
    final parts = displayName
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    final first = parts.first.characters.first;
    final last = parts.length > 1 ? parts.last.characters.first : '';
    return (first + last).toUpperCase();
  }
}

class ClassRoom {
  const ClassRoom({
    required this.id,
    required this.name,
    required this.nameUr,
    required this.children,
    this.savedOfflineCount = 0,
  });

  factory ClassRoom.fromJson(Map<String, Object?> json) => ClassRoom(
    id: json['id']! as String,
    name: json['name']! as String,
    nameUr: json['name_ur']! as String,
    savedOfflineCount: (json['saved_offline_count'] as int?) ?? 0,
    children: (json['children']! as List<Object?>)
        .cast<Map<String, Object?>>()
        .map(Child.fromJson)
        .toList(),
  );

  final String id;
  final String name;
  final String nameUr;
  final List<Child> children;
  final int savedOfflineCount;

  int get total => children.length;

  int get screenedCount =>
      children.where((c) => c.signal != Signal.notYet).length;

  int countOf(Signal signal) =>
      children.where((c) => c.signal == signal).length;
}

extension on String {
  Iterable<String> get characters => runes.map(String.fromCharCode);
}
