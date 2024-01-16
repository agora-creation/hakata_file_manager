import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hakata_file_manager/common/style.dart';
import 'package:hakata_file_manager/screens/home.dart';
import 'package:window_size/window_size.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setWindowTitle(appTitle);
  setWindowMinSize(const Size(windowWidth, windowHeight));
  setWindowMaxSize(const Size(windowWidth, windowHeight));
  getCurrentScreen().then((screen) {
    setWindowFrame(Rect.fromCenter(
      center: screen!.frame.center,
      width: windowWidth,
      height: windowHeight,
    ));
  });
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FluentApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('ja')],
      locale: const Locale('ja'),
      title: appTitle,
      theme: themeData(),
      home: const HomeScreen(),
    );
  }
}
