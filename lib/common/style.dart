import 'package:fluent_ui/fluent_ui.dart';

const double windowWidth = 1440;
const double windowHeight = 900;

const String appTitle = '羽方青果専用ファイル管理ソフト';

const mainColor = Color(0xFF009688);
const whiteColor = Color(0xFFFFFFFF);
const blackColor = Color(0xFF333333);
const greyColor = Color(0xFF9E9E9E);
const grey2Color = Color(0xFFE0E0E0);
const redColor = Color(0xFFF44336);
const blueColor = Color(0xFF2196F3);
const lightBlueColor = Color(0xFF03A9F4);
const tealColor = Color(0xFF009688);
const greenColor = Color(0xFF4CAF50);
const orangeColor = Color(0xFFFF9800);

FluentThemeData themeData() {
  return FluentThemeData(
    fontFamily: 'SourceHanSansJP-Regular',
    activeColor: mainColor,
    cardColor: whiteColor,
    scaffoldBackgroundColor: whiteColor,
    visualDensity: VisualDensity.adaptivePlatformDensity,
    navigationPaneTheme: const NavigationPaneThemeData(
      backgroundColor: whiteColor,
    ),
  );
}

const TextStyle headerStyle = TextStyle(
  color: blackColor,
  fontSize: 18,
  fontWeight: FontWeight.bold,
  fontFamily: 'SourceHanSansJP-Bold',
);

const homeGridDelegate = SliverGridDelegateWithFixedCrossAxisCount(
  crossAxisCount: 5,
  mainAxisSpacing: 8,
  crossAxisSpacing: 8,
);

DateTime kFirstDate = DateTime(2020, 1, 1);
DateTime kLastDate = DateTime(
  DateTime.now().year,
  DateTime.now().month + 1,
  1,
).subtract(const Duration(days: 1));

DateTime sDefaultDateStart = DateTime.now().subtract(const Duration(days: 1));
DateTime sDefaultDateEnd = DateTime.now().add(const Duration(days: 8));

List<String> kClientSorts = ['番号(昇順)', '番号(降順)', '名前(昇順)', '名前(降順)'];
