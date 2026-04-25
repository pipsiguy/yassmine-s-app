# 山海 · Shānhǎi

A notes app reframed as a living ink-wash kingdom. Every note becomes a sacred site on your own animated mountains-and-seas landscape, drawn from the *Classic of Mountains and Seas* (山海经) and Chinese folklore (西游记, 白蛇传, 嫦娥, 五行/四象).

The functionality is just notes. The point is the feeling.

## Highlights
- **Living realm** — parallax mountains, drifting 祥云 clouds, day/night sky tied to your real clock, lunar moon phase, falling plum petals, fireflies after dusk.
- **Mythical guardians** — each note is inhabited by a creature picked from its mood: 龙 dragon, 凤凰 phoenix, 鹤 crane, 嫦娥 + 玉兔 moon goddess, 九尾狐 nine-tailed fox, 麒麟 qilin, 锦鲤 koi, 孙悟空 monkey king.
- **Ink, paper, seal** — GLSL ink-bleed shader, rice-paper grain, water ripples, cinnabar 朱砂 seal stamp with paper-mask alpha.
- **Handscroll reading** — tap a pin and a 手卷 unfurls horizontally with two wooden rollers.
- **Tilt parallax** — gyroscope drives 4 layers of mountains, sea, and reeds.
- **Offline-first** — notes saved locally as JSON; no backend.

## Run it
You'll need the Flutter SDK (3.22+) and an Android device or emulator.

```bash
# 1. Pull dependencies
flutter pub get

# 2. Run on a connected device
flutter run -d <device-id>

# 3. Build a release APK (per-architecture, slim)
flutter build apk --release --split-per-abi
# ➜ build/app/outputs/flutter-apk/app-arm64-v8a-release.apk  (~60–80 MB)
```

## Get the APK without installing anything
Pick whichever you have access to.

**A. GitHub Actions (CI)** — pushes to this branch already trigger
`.github/workflows/build-apk.yml`. APKs land at the rolling
`shanhai-latest` pre-release. Requires Actions to be enabled on the account.

**B. GitHub Codespaces** — open the repo in a Codespace; the
`.devcontainer/` here boots with Flutter and the Android SDK ready, then
run `./build.sh` and download the file from `build/app/outputs/flutter-apk/`.

**C. Docker** — one command, on any machine:
```bash
docker run --rm -v "$PWD":/work -w /work ghcr.io/cirruslabs/flutter:3.41.7 \
  bash -lc "flutter pub get && flutter build apk --release --split-per-abi"
```
Or, to pull the APKs straight out of the container into the current directory:
```bash
docker buildx build -f Dockerfile.build -o . .
```

**D. Local toolchain** — `./build.sh` on Linux/macOS/WSL with JDK 17+
installed. Downloads Flutter and the Android SDK into `./.tools/` on
first run.

## Project layout
```
lib/
  main.dart, app.dart
  theme/        — palette, typography, motion presets
  models/       — Note, Guardian, Element
  storage/      — local JSON repo
  utils/        — text → guardian seed, lunar phase
  features/
    onboarding/ — ink-drop intro
    realm/      — parallax map, sky, weather, pins, creatures
    note/       — handscroll page, brush editor, 朱砂 seal
  rendering/
    ink/        — ink-bleed painter, brush stroke
    paper/      — rice-paper texture
    particles/  — clouds, petals, fireflies, koi
shaders/        — GLSL fragment shaders (.frag)
```

## Notes
- Fonts (Ma Shan Zheng, Noto Serif SC, Noto Sans SC) are loaded via `google_fonts` on first run. To bundle them offline, drop the `.ttf` files in `assets/fonts/` and switch `Typography` to local refs.
- Audio loops are stubbed; drop `assets/audio/{guzheng,water,wind,night}.ogg` and uncomment the `just_audio` block to enable.
- Particle and shader fidelity auto-throttle if the frame budget slips — see `RealmPage._qualityKnob`.
