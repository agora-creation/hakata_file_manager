import 'dart:io';

import 'package:cross_file/cross_file.dart';
import 'package:desktop_drop/desktop_drop.dart';
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
import 'package:hakata_file_manager/widgets/dragging_container.dart';
import 'package:hakata_file_manager/widgets/preview_container.dart';
import 'package:path/path.dart' as p;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  FileService fileService = FileService();
  List<Map<String, String>> files = [];
  final List<XFile> uploadFiles = [];
  bool isDragging = false;

  void _getFiles() async {
    files.clear();
    String tmpClientNumber = await getPrefsString('clientNumber') ?? '';
    List<Map> tmpFiles = await fileService.select(searchMap: {
      'clientNumber': tmpClientNumber,
    });
    setState(() {
      for (Map map in tmpFiles) {
        files.add({
          'clientNumber': map['clientNumber'],
          'clientName': map['clientName'],
          'filePath': map['filePath'],
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _getFiles();
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
                  ],
                ),
              ],
            ),
          ),
          content: DropTarget(
            onDragDone: (detail) {
              for (XFile uploadFile in detail.files) {
                String extension = p.extension(uploadFile.path);
                if (extension == '.pdf') {
                  uploadFiles.add(uploadFile);
                }
              }
              setState(() {});
            },
            onDragEntered: (detail) {
              setState(() {
                isDragging = true;
              });
            },
            onDragExited: (detail) {
              setState(() {
                isDragging = false;
              });
            },
            child: Container(
              color: mainColor,
              child: Stack(
                children: [
                  const Center(child: Text('PDFファイルをドラッグ＆ドロップしてください')),
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
                  isDragging ? const DraggingContainer() : Container(),
                ],
              ),
            ),
          ),
        ),
        PreviewContainer(
          uploadFiles: uploadFiles,
          getFiles: _getFiles,
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
