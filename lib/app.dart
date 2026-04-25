import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'features/onboarding/drop_page.dart';
import 'features/realm/realm_page.dart';
import 'storage/note_repo.dart';
import 'theme/palette.dart';

class ShanhaiApp extends StatefulWidget {
  final NoteRepo repo;
  const ShanhaiApp({super.key, required this.repo});

  @override
  State<ShanhaiApp> createState() => _ShanhaiAppState();
}

class _ShanhaiAppState extends State<ShanhaiApp> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Palette.xuanZhi,
      systemNavigationBarIconBrightness: Brightness.dark,
    ));
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    widget.repo.addListener(_onChange);
  }

  void _onChange() {
    if (!mounted) return;
    setState(() {});
  }

  @override
  void dispose() {
    widget.repo.removeListener(_onChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '山海',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Palette.xuanZhi,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Palette.zhuSha,
          surface: Palette.xuanZhi,
        ),
        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: Palette.zhuSha,
          selectionColor: Color(0x3FB83D2E),
          selectionHandleColor: Palette.zhuSha,
        ),
        useMaterial3: true,
      ),
      home: widget.repo.onboarded
          ? RealmPage(repo: widget.repo)
          : DropPage(
              repo: widget.repo,
              onComplete: () => setState(() {}),
            ),
    );
  }
}
