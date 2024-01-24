import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:hakata_file_manager/common/functions.dart';
import 'package:hakata_file_manager/common/style.dart';
import 'package:hakata_file_manager/widgets/custom_icon_text_button.dart';
import 'package:path/path.dart' as p;

class BackupScreen extends StatefulWidget {
  const BackupScreen({super.key});

  @override
  State<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends State<BackupScreen> {
  String backupDirectoryPath1 = '';
  String backupDirectoryPath2 = '';

  Future _backup() async {
    Directory directory1 = Directory(backupDirectoryPath1);
    Directory directory2 = Directory(backupDirectoryPath2);
    List<FileSystemEntity> dirFiles1 = await directory1.list().toList();
    List<FileSystemEntity> dirFiles2 = await directory2.list().toList();
    for (var file in dirFiles2) {
      if (file is File) {
        await file.delete();
      }
    }
    for (var file in dirFiles1) {
      if (file is File) {
        String fileName = p.basename(file.path);
        await file.copy('$backupDirectoryPath2\\$fileName');
      }
    }
    setState(() {
      backupDirectoryPath1 = '';
      backupDirectoryPath2 = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage(
      padding: EdgeInsets.zero,
      header: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(FluentIcons.back),
              onPressed: () => Navigator.pop(context),
            ),
            const Text('USB間バックアップ', style: headerStyle),
            Container(),
          ],
        ),
      ),
      content: Container(
        color: mainColor,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'USBを2つパソコンに挿入し、片方のUSBのバックアップをとります。',
                        ),
                        const SizedBox(height: 8),
                        InfoLabel(
                          label: '① 元のUSBファイルパス',
                          child: ListTile(
                            tileColor: ButtonState.all(grey2Color),
                            title: backupDirectoryPath1 != ''
                                ? Text(
                                    backupDirectoryPath1,
                                    style: const TextStyle(fontSize: 14),
                                  )
                                : const Text(
                                    'ファイルパスを選択してください',
                                    style: TextStyle(
                                      color: greyColor,
                                      fontSize: 14,
                                    ),
                                  ),
                            onPressed: () async {
                              String? path =
                                  await FilePicker.platform.getDirectoryPath();
                              backupDirectoryPath1 = '';
                              if (path != null) {
                                Directory directory = Directory(path);
                                backupDirectoryPath1 = directory.path;
                              }
                              setState(() {});
                            },
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Center(child: Icon(FluentIcons.down)),
                        const SizedBox(height: 8),
                        InfoLabel(
                          label: '② バックアップ先のUSBファイルパス',
                          child: ListTile(
                            tileColor: ButtonState.all(grey2Color),
                            title: backupDirectoryPath2 != ''
                                ? Text(
                                    backupDirectoryPath2,
                                    style: const TextStyle(fontSize: 14),
                                  )
                                : const Text(
                                    'ファイルパスを選択してください',
                                    style: TextStyle(
                                      color: greyColor,
                                      fontSize: 14,
                                    ),
                                  ),
                            onPressed: () async {
                              String? path =
                                  await FilePicker.platform.getDirectoryPath();
                              backupDirectoryPath2 = '';
                              if (path != null) {
                                Directory directory = Directory(path);
                                backupDirectoryPath2 = directory.path;
                              }
                              setState(() {});
                            },
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(),
                            backupDirectoryPath1 != '' &&
                                    backupDirectoryPath2 != ''
                                ? CustomIconTextButton(
                                    iconData: FluentIcons.switcher_start_end,
                                    iconColor: whiteColor,
                                    labelText: 'バックアップを開始する',
                                    labelColor: whiteColor,
                                    backgroundColor: blueColor,
                                    onPressed: () async {
                                      await _backup();
                                      if (!mounted) return;
                                      showMessage(
                                          context, 'バックアップに成功しました', true);
                                    },
                                  )
                                : const CustomIconTextButton(
                                    iconData: FluentIcons.switcher_start_end,
                                    iconColor: whiteColor,
                                    labelText: 'バックアップを開始する',
                                    labelColor: whiteColor,
                                    backgroundColor: greyColor,
                                  ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
