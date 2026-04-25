import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app.dart';
import 'storage/note_repo.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Lock to portrait — the parallax + handscroll ergonomics expect it.
  await SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp]);

  final repo = NoteRepo();
  await repo.load();

  runApp(ShanhaiApp(repo: repo));
}
