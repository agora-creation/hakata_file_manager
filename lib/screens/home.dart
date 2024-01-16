import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:hakata_file_manager/common/functions.dart';
import 'package:hakata_file_manager/common/style.dart';
import 'package:hakata_file_manager/screens/client.dart';
import 'package:hakata_file_manager/screens/pdf_view.dart';
import 'package:hakata_file_manager/services/client.dart';
import 'package:hakata_file_manager/services/file.dart';
import 'package:hakata_file_manager/widgets/custom_combo_box.dart';
import 'package:hakata_file_manager/widgets/custom_file_card.dart';
import 'package:hakata_file_manager/widgets/custom_icon_text_button.dart';
import 'package:hakata_file_manager/widgets/custom_pdf_preview.dart';
import 'package:path/path.dart' as p;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  ClientService clientService = ClientService();
  FileService fileService = FileService();
  List<Map<String, String>> files = [];
  String selectDirectoryPath = '';
  List<File> uploadFiles = [];
  int uploadFilesIndex = 0;
  String inputClientNumber = '';
  String inputClientName = '';
  FocusNode numberFocusNode = FocusNode();

  void _init() async {
    await Future.delayed(const Duration(seconds: 1));
    await _selectDirectory();
  }

  Future _selectDirectory() async {
    String? path = await FilePicker.platform.getDirectoryPath();
    uploadFiles.clear();
    uploadFilesIndex = 0;
    inputClientNumber = '';
    inputClientName = '';
    if (path != null) {
      Directory directory = Directory(path);
      selectDirectoryPath = directory.path;
      List<FileSystemEntity> dirFiles = await directory.list().toList();
      for (var file in dirFiles) {
        if (file is File) {
          String extension = p.extension(file.path);
          if (extension == '.pdf') {
            uploadFiles.add(file);
          }
        }
      }
    }
    setState(() {});
  }

  void _uploadFileLeft() {
    setState(() {
      uploadFilesIndex -= 1;
      inputClientNumber = '';
      inputClientName = '';
    });
  }

  void _uploadFileRight() {
    setState(() {
      uploadFilesIndex += 1;
      inputClientNumber = '';
      inputClientName = '';
    });
  }

  void _selectClient() async {
    List<Map> tmpClients = await clientService.select(searchMap: {
      'number': inputClientNumber,
    });
    if (tmpClients.isNotEmpty) {
      setState(() {
        inputClientName = tmpClients.first['name'];
      });
    }
  }

  void _uploadFilesClear() {
    setState(() {
      uploadFiles.clear();
      uploadFilesIndex = 0;
      inputClientNumber = '';
      inputClientName = '';
    });
  }

  void _uploadFileClear() {
    setState(() {
      uploadFiles.removeAt(uploadFilesIndex);
      if (uploadFiles.isNotEmpty) {
        uploadFilesIndex = 0;
        inputClientNumber = '';
        inputClientName = '';
      } else {
        uploadFiles.clear();
      }
    });
  }

  void _uploadFileSave() async {
    String? error = await fileService.insert(
      clientNumber: inputClientNumber,
      clientName: inputClientName,
      uploadFile: uploadFiles[uploadFilesIndex],
    );
    if (error != null) {
      if (!mounted) return;
      showMessage(context, error, false);
      return;
    }
    setState(() {
      uploadFiles.removeAt(uploadFilesIndex);
      if (uploadFiles.isNotEmpty) {
        uploadFilesIndex = 0;
        inputClientNumber = '';
        inputClientName = '';
      } else {
        uploadFiles.clear();
      }
    });
    _getFiles();
  }

  void _getFiles() async {
    //   files.clear();
    //   String tmpClientNumber = await getPrefsString('clientNumber') ?? '';
    //   List<Map> tmpFiles = await fileService.select(searchMap: {
    //     'clientNumber': tmpClientNumber,
    //   });
    //   setState(() {
    //     for (Map map in tmpFiles) {
    //       files.add({
    //         'clientNumber': map['clientNumber'],
    //         'clientName': map['clientName'],
    //         'filePath': map['filePath'],
    //       });
    //     }
    //   });
  }

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ScaffoldPage(
          padding: EdgeInsets.zero,
          header: Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(appTitle, style: headerStyle),
                Row(
                  children: [
                    CustomIconTextButton(
                      iconData: FluentIcons.search,
                      iconColor: whiteColor,
                      labelText: 'ファイル検索',
                      labelColor: whiteColor,
                      backgroundColor: lightBlueColor,
                      onPressed: () => showDialog(
                        context: context,
                        builder: (context) => SearchDialog(
                          getFiles: _getFiles,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    CustomIconTextButton(
                      iconData: FluentIcons.settings,
                      iconColor: whiteColor,
                      labelText: '取引先設定',
                      labelColor: whiteColor,
                      backgroundColor: greyColor,
                      onPressed: () => Navigator.push(
                        context,
                        FluentPageRoute(
                          builder: (context) => const ClientScreen(),
                          fullscreenDialog: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    CustomIconTextButton(
                      iconData: FluentIcons.folder,
                      iconColor: whiteColor,
                      labelText: 'フォルダ選択',
                      labelColor: whiteColor,
                      backgroundColor: greyColor,
                      onPressed: () async {
                        await _selectDirectory();
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          content: Container(
            color: mainColor,
            child: Stack(
              children: [
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('取得先フォルダパス:'),
                      Text(selectDirectoryPath),
                    ],
                  ),
                ),
                GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: homeGridDelegate,
                  itemCount: files.length,
                  itemBuilder: (context, index) {
                    Map<String, String> file = files[index];
                    String fileName = p.basename('${file['filePath']}');
                    return CustomFileCard(
                      fileName: fileName,
                      onTap: () => Navigator.push(
                        context,
                        FluentPageRoute(
                          builder: (context) => PDFViewScreen(
                            file: File('${file['filePath']}'),
                          ),
                          fullscreenDialog: true,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        CustomPdfPreview(
          files: uploadFiles,
          index: uploadFilesIndex,
          leftOnPressed: () => _uploadFileLeft(),
          rightOnPressed: () => _uploadFileRight(),
          clientNumberController: TextEditingController(
            text: inputClientNumber,
          ),
          clientName: inputClientName,
          numberFocusNode: numberFocusNode,
          clientNumberOnChanged: (value) {
            inputClientNumber = value;
          },
          clientSearchOnPressed: () => _selectClient(),
          allClearOnPressed: () => _uploadFilesClear(),
          clearOnPressed: () => _uploadFileClear(),
          saveOnPressed: () => _uploadFileSave(),
        ),
      ],
    );
  }
}

class SearchDialog extends StatefulWidget {
  final Function() getFiles;

  const SearchDialog({
    required this.getFiles,
    super.key,
  });

  @override
  State<SearchDialog> createState() => _SearchDialogState();
}

class _SearchDialogState extends State<SearchDialog> {
  ClientService clientService = ClientService();
  List<Map<String, String>> clients = [];
  String number = '';

  void _init() async {
    clients.clear();
    List<Map> tmpClients = await clientService.select(searchMap: {
      'number': '',
    });
    for (Map map in tmpClients) {
      clients.add({
        'number': map['number'],
        'name': map['name'],
      });
    }
    String tmpClientNumber = await getPrefsString('clientNumber') ?? '';
    number = tmpClientNumber;
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  Widget build(BuildContext context) {
    return ContentDialog(
      title: const Text(
        'ファイル検索',
        style: TextStyle(fontSize: 16),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InfoLabel(
            label: '取引先で絞り込み',
            child: CustomComboBox(
              value: number,
              items: clients.map((e) {
                return ComboBoxItem(
                  value: '${e['number']}',
                  child: Text('${e['name']}'),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  number = value ?? '';
                });
              },
            ),
          ),
        ],
      ),
      actions: [
        FilledButton(
          onPressed: () async {
            await setPrefsString('clientNumber', '');
            await widget.getFiles();
            if (!mounted) return;
            Navigator.pop(context);
          },
          style: ButtonStyle(
            backgroundColor: ButtonState.all(greyColor),
          ),
          child: const Text('検索クリア'),
        ),
        FilledButton(
          onPressed: () async {
            await setPrefsString('clientNumber', number);
            await widget.getFiles();
            if (!mounted) return;
            Navigator.pop(context);
          },
          style: ButtonStyle(
            backgroundColor: ButtonState.all(blueColor),
          ),
          child: const Text('検索実行'),
        ),
      ],
    );
  }
}
