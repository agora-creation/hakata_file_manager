import 'dart:io';

import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:hakata_file_manager/common/style.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<int?> getPrefsInt(String key) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getInt(key);
}

Future setPrefsInt(String key, int value) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setInt(key, value);
}

Future<String?> getPrefsString(String key) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString(key);
}

Future setPrefsString(String key, String value) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString(key, value);
}

Future<bool?> getPrefsBool(String key) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getBool(key);
}

Future setPrefsBool(String key, bool value) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setBool(key, value);
}

Future removePrefs(String key) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.remove(key);
}

Future allRemovePrefs() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.clear();
}

void showMessage(BuildContext context, String msg, bool success) {
  displayInfoBar(context, builder: (context, close) {
    return InfoBar(
      title: Text(msg),
      severity:
          success == true ? InfoBarSeverity.success : InfoBarSeverity.error,
    );
  });
}

String dateText(String format, DateTime? date) {
  String ret = '';
  if (date != null) {
    ret = DateFormat(format, 'ja').format(date);
  }
  return ret;
}

Future<bool> checkFileExistence(String filePath) async {
  if (await File(filePath).exists()) {
    return true;
  } else {
    return false;
  }
}

Future<List<DateTime?>?> showDataPickerDialog({
  required BuildContext context,
  required DateTime value,
}) async {
  List<DateTime?>? results = await showCalendarDatePicker2Dialog(
    context: context,
    config: CalendarDatePicker2WithActionButtonsConfig(
      calendarType: CalendarDatePicker2Type.single,
      firstDate: kFirstDate,
      lastDate: kLastDate,
    ),
    dialogSize: const Size(325, 400),
    value: [value],
    borderRadius: BorderRadius.circular(8),
    dialogBackgroundColor: whiteColor,
  );
  return results;
}

Future<List<DateTime?>?> showDataRangePickerDialog({
  required BuildContext context,
  required DateTime startValue,
  required DateTime endValue,
}) async {
  List<DateTime?>? results = await showCalendarDatePicker2Dialog(
    context: context,
    config: CalendarDatePicker2WithActionButtonsConfig(
      calendarType: CalendarDatePicker2Type.range,
      firstDate: kFirstDate,
      lastDate: kLastDate,
    ),
    dialogSize: const Size(325, 400),
    value: [startValue, endValue],
    borderRadius: BorderRadius.circular(8),
    dialogBackgroundColor: whiteColor,
  );
  return results;
}
