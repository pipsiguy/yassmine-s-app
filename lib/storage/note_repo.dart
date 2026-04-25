import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../models/guardian.dart';
import '../models/note.dart';
import '../theme/palette.dart';
import '../utils/seed.dart';

/// Local-only persistence for notes + a single realm name.
/// Stored as a single JSON file in the app documents directory.
class NoteRepo extends ChangeNotifier {
  static const _file = 'shanhai.json';
  static const _uuid = Uuid();

  final List<Note> _notes = [];
  String _realmName = '兰若';
  bool _onboarded = false;

  List<Note> get all => List.unmodifiable(_notes.where((n) => !n.archived));
  List<Note> get archived =>
      List.unmodifiable(_notes.where((n) => n.archived));
  String get realmName => _realmName;
  bool get onboarded => _onboarded;

  Future<File> _path() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$_file');
  }

  Future<void> load() async {
    try {
      final f = await _path();
      if (!await f.exists()) return;
      final raw = jsonDecode(await f.readAsString()) as Map<String, dynamic>;
      _realmName = raw['realm'] as String? ?? '兰若';
      _onboarded = raw['onboarded'] as bool? ?? false;
      _notes
        ..clear()
        ..addAll((raw['notes'] as List? ?? [])
            .map((n) => Note.fromJson(n as Map<String, dynamic>)));
      notifyListeners();
    } catch (e) {
      // Corrupt file — start fresh rather than crash.
      debugPrint('NoteRepo.load failed: $e');
    }
  }

  Future<void> _save() async {
    final f = await _path();
    final body = {
      'realm': _realmName,
      'onboarded': _onboarded,
      'notes': _notes.map((n) => n.toJson()).toList(),
    };
    await f.writeAsString(jsonEncode(body));
  }

  Future<void> setRealmName(String name) async {
    _realmName = name.isEmpty ? '兰若' : name;
    _onboarded = true;
    await _save();
    notifyListeners();
  }

  Future<Note> create({
    required String title,
    required String body,
    Mood? mood,
    WuxingElement? element,
  }) async {
    final seed = TextSeed.fromText('$title\n$body${DateTime.now()}');
    final pos = seed.mapPosition();
    final m = mood ?? seed.guessMood('$title $body');
    final el = element ?? seed.guessElement('$title $body');
    final now = DateTime.now();
    final n = Note(
      id: _uuid.v4(),
      title: title,
      body: body,
      mood: m,
      element: el,
      createdAt: now,
      updatedAt: now,
      mapX: pos.$1,
      mapY: pos.$2,
    );
    _notes.add(n);
    await _save();
    notifyListeners();
    return n;
  }

  Future<void> update(Note updated) async {
    final i = _notes.indexWhere((n) => n.id == updated.id);
    if (i == -1) return;
    _notes[i] = updated.copyWith(updatedAt: DateTime.now());
    await _save();
    notifyListeners();
  }

  Future<void> archive(String id) async {
    final i = _notes.indexWhere((n) => n.id == id);
    if (i == -1) return;
    _notes[i] = _notes[i].copyWith(archived: true);
    await _save();
    notifyListeners();
  }

  Future<void> delete(String id) async {
    _notes.removeWhere((n) => n.id == id);
    await _save();
    notifyListeners();
  }
}
