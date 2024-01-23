import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';
import 'package:hakata_file_manager/common/functions.dart';
import 'package:hakata_file_manager/common/style.dart';
import 'package:hakata_file_manager/providers/home.dart';
import 'package:hakata_file_manager/screens/client.dart';
import 'package:hakata_file_manager/screens/pdf_details.dart';
import 'package:hakata_file_manager/services/client.dart';
import 'package:hakata_file_manager/widgets/custom_combo_box.dart';
import 'package:hakata_file_manager/widgets/custom_file_card.dart';
import 'package:hakata_file_manager/widgets/custom_icon_text_button.dart';
import 'package:hakata_file_manager/widgets/custom_pdf_preview.dart';
import 'package:hakata_file_manager/widgets/directory_path_header.dart';

class HomeScreen extends StatefulWidget {
  final HomeProvider homeProvider;

  const HomeScreen({
    required this.homeProvider,
    super.key,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, String>> files = [];

  Future _getFiles() async {
    files = await widget.homeProvider.getFiles();
    setState(() {});
  }

  void _init() async {
    await _getFiles();
    await Future.delayed(const Duration(seconds: 2));
    await widget.homeProvider.selectDirectory();
    await widget.homeProvider.autoFocus();
  }

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      autofocus: true,
      focusNode: widget.homeProvider.keyboardFocusNode,
      onKey: (event) async {
        if (widget.homeProvider.clientNumberFocusNode.hasFocus) return;
        if (event is RawKeyDownEvent) {
          if (event.isKeyPressed(LogicalKeyboardKey.enter)) {
            String? error = await widget.homeProvider.uploadFileSave();
            if (error != null) {
              if (!mounted) return;
              showMessage(context, error, false);
              return;
            }
            if (!mounted) return;
            showMessage(context, 'PDFファイル情報を保存しました', true);
            widget.homeProvider.uploadFileClear();
            await widget.homeProvider.autoFocus();
          }
          if (event.isKeyPressed(LogicalKeyboardKey.backspace)) {
            widget.homeProvider.uploadFileClear();
            await widget.homeProvider.autoFocus();
          }
        }
      },
      child: Stack(
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
                            homeProvider: widget.homeProvider,
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
            content: Container(
              color: mainColor,
              child: Column(
                children: [
                  DirectoryPathHeader(
                    path: widget.homeProvider.selectDirectoryPath,
                    onTap: () async {
                      await widget.homeProvider.selectDirectory();
                      await widget.homeProvider.autoFocus();
                    },
                  ),
                  Expanded(
                    child: GridView.builder(
                      padding: const EdgeInsets.all(8),
                      gridDelegate: homeGridDelegate,
                      itemCount: files.length,
                      itemBuilder: (context, index) {
                        return CustomFileCard(
                          file: files[index],
                          onTap: () => Navigator.push(
                            context,
                            FluentPageRoute(
                              builder: (context) => PdfDetailsScreen(
                                file: files[index],
                                getFiles: _getFiles,
                              ),
                              fullscreenDialog: true,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          CustomPdfPreview(
            files: widget.homeProvider.uploadFiles,
            index: widget.homeProvider.uploadFilesIndex,
            leftOnPressed: () async {
              widget.homeProvider.uploadFileLeft();
              await widget.homeProvider.autoFocus();
            },
            rightOnPressed: () async {
              widget.homeProvider.uploadFileRight();
              await widget.homeProvider.autoFocus();
            },
            clientNumberFocusNode: widget.homeProvider.clientNumberFocusNode,
            clientNumberController: widget.homeProvider.clientNumberController,
            clientNumberOnSubmitted: (value) async {
              await widget.homeProvider.checkClientNumber();
              widget.homeProvider.keyboardFocusNode.requestFocus();
            },
            clientName: widget.homeProvider.clientName,
            allClearOnTap: () async {
              widget.homeProvider.uploadFileAllClear();
              await widget.homeProvider.autoFocus();
            },
            clearOnPressed: () async {
              widget.homeProvider.uploadFileClear();
              await widget.homeProvider.autoFocus();
            },
            saveOnPressed: () async {
              String? error = await widget.homeProvider.uploadFileSave();
              if (error != null) {
                if (!mounted) return;
                showMessage(context, error, false);
                return;
              }
              if (!mounted) return;
              showMessage(context, 'PDFファイル情報を保存しました', true);
              widget.homeProvider.uploadFileClear();
              await widget.homeProvider.autoFocus();
            },
          ),
        ],
      ),
    );
  }
}

class SearchDialog extends StatefulWidget {
  final HomeProvider homeProvider;

  const SearchDialog({
    required this.homeProvider,
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
            // await widget.homeProvider.initFiles();
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
            // await widget.homeProvider.initFiles();
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
