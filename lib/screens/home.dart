import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';
import 'package:hakata_file_manager/common/functions.dart';
import 'package:hakata_file_manager/common/style.dart';
import 'package:hakata_file_manager/providers/home.dart';
import 'package:hakata_file_manager/screens/backup.dart';
import 'package:hakata_file_manager/screens/client.dart';
import 'package:hakata_file_manager/screens/pdf_details.dart';
import 'package:hakata_file_manager/services/client.dart';
import 'package:hakata_file_manager/widgets/custom_calendar_field.dart';
import 'package:hakata_file_manager/widgets/custom_file_card.dart';
import 'package:hakata_file_manager/widgets/custom_icon_text_button.dart';
import 'package:hakata_file_manager/widgets/custom_pdf_preview.dart';
import 'package:hakata_file_manager/widgets/custom_text_box.dart';
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
          if (event.isKeyPressed(LogicalKeyboardKey.shiftRight)) {
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
            if (widget.homeProvider.uploadFiles.isEmpty) {
              await _getFiles();
            }
          }
          if (event.isKeyPressed(LogicalKeyboardKey.backspace)) {
            widget.homeProvider.uploadFileClear();
            await widget.homeProvider.autoFocus();
            if (widget.homeProvider.uploadFiles.isEmpty) {
              await _getFiles();
            }
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
                        iconData: FluentIcons.usb,
                        iconColor: whiteColor,
                        labelText: 'USB/HDD間バックアップ作成',
                        labelColor: whiteColor,
                        backgroundColor: orangeColor,
                        onPressed: () => Navigator.push(
                          context,
                          FluentPageRoute(
                            builder: (context) => const BackupScreen(),
                            fullscreenDialog: true,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
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
                            getFiles: _getFiles,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      CustomIconTextButton(
                        iconData: FluentIcons.bulleted_list,
                        iconColor: whiteColor,
                        labelText: '取引先一覧',
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
                    child: files.isNotEmpty
                        ? GridView.builder(
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
                          )
                        : const Center(
                            child: Text(
                              'PDFファイル情報は見つかりませんでした',
                              style: TextStyle(fontSize: 24),
                            ),
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
            createDate: widget.homeProvider.createDate,
            dateOnPressed: () async {
              var selected = await showDataPickerDialog(
                context: context,
                value: widget.homeProvider.createDate,
              );
              if (selected == null) return;
              if (selected.first == null) return;
              widget.homeProvider.dateOnChange(selected.first!);
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
              if (widget.homeProvider.uploadFiles.isEmpty) {
                await _getFiles();
              }
            },
            clearOnPressed: () async {
              widget.homeProvider.uploadFileClear();
              await widget.homeProvider.autoFocus();
              if (widget.homeProvider.uploadFiles.isEmpty) {
                await _getFiles();
              }
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
              if (widget.homeProvider.uploadFiles.isEmpty) {
                await _getFiles();
              }
            },
          ),
        ],
      ),
    );
  }
}

class SearchDialog extends StatefulWidget {
  final HomeProvider homeProvider;
  final Future Function() getFiles;

  const SearchDialog({
    required this.homeProvider,
    required this.getFiles,
    super.key,
  });

  @override
  State<SearchDialog> createState() => _SearchDialogState();
}

class _SearchDialogState extends State<SearchDialog> {
  ClientService clientService = ClientService();
  List<Map<String, String>> clients = [];
  DateTime createDateStart = sDefaultDateStart;
  DateTime createDateEnd = sDefaultDateEnd;
  String clientNumber = '';
  String clientName = '';

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
    String tmpCreateDateStart = await getPrefsString('createDateStart') ?? '';
    if (tmpCreateDateStart != '') {
      createDateStart = DateTime.parse(tmpCreateDateStart);
    }
    String tmpCreateDateEnd = await getPrefsString('createDateEnd') ?? '';
    if (tmpCreateDateEnd != '') {
      createDateEnd = DateTime.parse(tmpCreateDateEnd);
    }
    String tmpClientNumber = await getPrefsString('clientNumber') ?? '';
    clientNumber = tmpClientNumber;
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
            label: '登録日で絞り込み',
            child: CustomCalendarField(
              label:
                  '${dateText('yyyy/MM/dd', createDateStart)} ～ ${dateText('yyyy/MM/dd', createDateEnd)}',
              onPressed: () async {
                var selected = await showDataRangePickerDialog(
                  context: context,
                  startValue: createDateStart,
                  endValue: createDateEnd,
                );
                if (selected == null) return;
                if (selected.first == null && selected.last == null) return;
                var diff = selected.last!.difference(selected.first!);
                int diffDays = diff.inDays;
                if (diffDays > 10) {
                  if (!mounted) return;
                  showMessage(context, '10日以上の範囲は検索不可です', false);
                  return;
                }
                setState(() {
                  createDateStart = selected.first!;
                  createDateEnd = selected.last!;
                });
              },
            ),
          ),
          const SizedBox(height: 8),
          InfoLabel(
            label: '取引先番号で絞り込み',
            child: CustomTextBox(
              controller: TextEditingController(text: clientNumber),
              maxLines: 1,
              onSubmitted: (value) async {
                clientNumber = value;
                List<Map> tmpClients = await clientService.select(searchMap: {
                  'number': clientNumber,
                });
                if (tmpClients.isNotEmpty) {
                  clientName = tmpClients.first['name'];
                } else {
                  clientName = '';
                }
                setState(() {});
              },
            ),
          ),
          const SizedBox(height: 8),
          InfoLabel(
            label: '取引先名(上記番号から自動取得)',
            child: clientName != ''
                ? Text(clientName)
                : const Text(
                    '取引先が見つかりません',
                    style: TextStyle(color: greyColor),
                  ),
          ),
        ],
      ),
      actions: [
        FilledButton(
          onPressed: () async {
            createDateStart = sDefaultDateStart;
            createDateEnd = sDefaultDateEnd;
            clientNumber = '';
            clientName = '';
            await setPrefsString('createDateStart', '');
            await setPrefsString('createDateEnd', '');
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
            await setPrefsString(
              'createDateStart',
              dateText('yyyy-MM-dd', createDateStart),
            );
            await setPrefsString(
              'createDateEnd',
              dateText('yyyy-MM-dd', createDateEnd),
            );
            await setPrefsString('clientNumber', clientNumber);
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
