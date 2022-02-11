import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart' as pathProvider;
import 'package:provider/provider.dart';
import 'package:qr_coffee/root/splash.dart';
import 'package:qr_coffee/shared/theme_provider.dart';

void main() async {
  // INITIALIZATION
  WidgetsFlutterBinding.ensureInitialized();
  final appDocumentDirectory =
      await pathProvider.getApplicationDocumentsDirectory();

  Hive.init(appDocumentDirectory.path);

  final settings = await Hive.openBox('settings');
  bool isLightTheme = settings.get('isLightTheme') ?? true;

  // APP START
  runApp(ChangeNotifierProvider(
    create: (_) => ThemeProvider(isLightTheme: isLightTheme),
    child: AppStart(),
  ));
}
