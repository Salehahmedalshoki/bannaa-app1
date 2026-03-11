import 'dart:io';

void main() {
  final dir = Directory('lib');
  final files = dir.listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart'));
  for (var file in files) {
    String content = file.readAsStringSync();
    if (content.contains("import '../utils/app_localizations.dart'';")) {
      content = content.replaceAll("import '../utils/app_localizations.dart'';", "import '../utils/app_localizations.dart';");
      file.writeAsStringSync(content);
      print('Fixed ${file.path}');
    }
  }
}
