import '../theme/palette.dart';
import 'guardian.dart';

/// A single note. Tiny, plain, JSON-serialisable.
class Note {
  final String id;
  final String title;
  final String body;
  final Mood mood;
  final WuxingElement element;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool archived;

  /// Persistent map position in normalised realm space (0..1, 0..1).
  /// Positions are seeded once at creation so the same note always lives
  /// in the same place on the kingdom map.
  final double mapX;
  final double mapY;

  const Note({
    required this.id,
    required this.title,
    required this.body,
    required this.mood,
    required this.element,
    required this.createdAt,
    required this.updatedAt,
    required this.mapX,
    required this.mapY,
    this.archived = false,
  });

  Guardian get guardian => mood.guardian;

  Note copyWith({
    String? title,
    String? body,
    Mood? mood,
    WuxingElement? element,
    DateTime? updatedAt,
    bool? archived,
  }) =>
      Note(
        id: id,
        title: title ?? this.title,
        body: body ?? this.body,
        mood: mood ?? this.mood,
        element: element ?? this.element,
        createdAt: createdAt,
        updatedAt: updatedAt ?? DateTime.now(),
        mapX: mapX,
        mapY: mapY,
        archived: archived ?? this.archived,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'body': body,
        'mood': mood.name,
        'element': element.name,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'mapX': mapX,
        'mapY': mapY,
        'archived': archived,
      };

  static Note fromJson(Map<String, dynamic> json) => Note(
        id: json['id'] as String,
        title: json['title'] as String,
        body: json['body'] as String,
        mood: Mood.values.firstWhere((m) => m.name == json['mood']),
        element:
            WuxingElement.values.firstWhere((e) => e.name == json['element']),
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
        mapX: (json['mapX'] as num).toDouble(),
        mapY: (json['mapY'] as num).toDouble(),
        archived: json['archived'] as bool? ?? false,
      );
}
