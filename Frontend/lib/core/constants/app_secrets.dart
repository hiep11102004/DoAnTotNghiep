/// Các secret key KHÔNG được hardcode vào code.
/// Truyền vào lúc build/run bằng --dart-define:
///
///   flutter run --dart-define=GEMINI_API_KEY=AIzaSy...
///
/// Hoặc thêm vào .vscode/launch.json (file này nên được gitignore):
///   "toolArgs": ["--dart-define=GEMINI_API_KEY=AIzaSy..."]
///
/// Lệnh build release:
///   flutter build apk --dart-define=GEMINI_API_KEY=AIzaSy...
class AppSecrets {
  static const String geminiApiKey = String.fromEnvironment(
    'GEMINI_API_KEY',
    defaultValue: '',
  );
}
