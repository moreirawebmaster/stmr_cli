class CreateTemplates {
  /// Gera o template do arquivo pubspec.yaml
  static String pubspec(final String projectName, final String projectNameSnake) => '''name: $projectNameSnake
description: A new Flutter project.
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  engine:
    git:
      url: https://github.com/moreirawebmaster/engine.git
      ref: main
  design_system:
    git:
      url: https://github.com/moreirawebmaster/design_system.git
      ref: main
  get: ^4.6.6
  dio: ^5.4.0
  shared_preferences: ^2.2.2
  flutter_dotenv: ^5.1.0
  intl: ^0.18.1
  logger: ^2.0.2+1

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.1

flutter:
  uses-material-design: true
  assets:
    - .env
    - assets/images/
    - assets/icons/
''';

  /// Gera o template do arquivo main.dart
  static String main(final String projectName) => '''import 'package:engine/lib.dart';
import 'package:flutter/material.dart';
import 'package:design_system/lib.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Engine.initialize();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: '$projectName',
      theme: DsTheme.light,
      darkTheme: DsTheme.dark,
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const DsText('Home'),
      ),
      body: const Center(
        child: DsText(
          'Bem-vindo ao $projectName!',
          type: DsTextType.heading1,
        ),
      ),
    );
  }
}''';

  /// Gera template para app principal com Clean Architecture
  static String initialAppFile(final String projectName) {
    final capitalizedName = _capitalize(projectName);

    return '''import 'package:engine/lib.dart';
import 'package:flutter/material.dart';

class ${capitalizedName}App extends StatelessWidget {
  const ${capitalizedName}App({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: '$capitalizedName',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
      initialBinding: InitialBinding(),
    );
  }
}

class InitialBinding extends EngineBaseBinding {
  @override
  void dependencies() {
    
  }
}''';
  }

  static String _capitalize(final String text) {
    if (text.isEmpty) {
      return text;
    }
    return text[0].toUpperCase() + text.substring(1);
  }
}
