import 'package:file_selector/file_selector.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:hakata_file_manager/common/functions.dart';
import 'package:hakata_file_manager/common/style.dart';
import 'package:hakata_file_manager/services/client.dart';
import 'package:hakata_file_manager/widgets/custom_client_table.dart';
import 'package:hakata_file_manager/widgets/custom_combo_box.dart';
import 'package:hakata_file_manager/widgets/custom_icon_button.dart';
import 'package:hakata_file_manager/widgets/custom_icon_text_button.dart';
import 'package:hakata_file_manager/widgets/custom_text_box.dart';

class ClientScreen extends StatefulWidget {
  const ClientScreen({super.key});

  @override
  State<ClientScreen> createState() => _ClientScreenState();
}

class _ClientScreenState extends State<ClientScreen> {
  ClientService clientService = ClientService();
  String clientSort = kClientSorts.first;
  String keyword = '';
  List<Map<String, String>> clients = [];
  List<TableRow> clientRows = [];

  void _clientAdd() {
    clients.add({'number': '', 'name': ''});
    _rebuildClientRows();
  }

  void _clientRemove(Map<String, String> map) {
    clients.remove(map);
    _rebuildClientRows();
  }

  void _rebuildClientRows() {
    clientRows.clear();
    for (Map<String, String> map in clients) {
      clientRows.add(TableRow(
        children: [
          Container(
            alignment: Alignment.center,
            margin: const EdgeInsets.all(4),
            child: CustomTextBox(
              controller: TextEditingController(text: '${map['number']}'),
              placeholder: '例) 00000001',
              onChanged: (value) {
                map['number'] = value;
              },
            ),
          ),
          Container(
            alignment: Alignment.center,
            margin: const EdgeInsets.all(4),
            child: CustomTextBox(
              controller: TextEditingController(text: '${map['name']}'),
              placeholder: '例) 株式会社羽方青果',
              onChanged: (value) {
                map['name'] = value;
              },
            ),
          ),
          Container(
            alignment: Alignment.center,
            margin: const EdgeInsets.all(4),
            child: CustomIconButton(
              iconData: FluentIcons.clear,
              iconColor: whiteColor,
              backgroundColor: redColor,
              onPressed: () => _clientRemove(map),
            ),
          ),
        ],
      ));
    }
    setState(() {});
  }

  Future _init() async {
    clients.clear();
    String name = '';
    String orderBy = '';
    name = keyword;
    switch (clientSort) {
      case '番号(昇順)':
        orderBy = 'numberASC';
        break;
      case '番号(降順)':
        orderBy = 'numberDESC';
        break;
      case '名前(昇順)':
        orderBy = 'nameASC';
        break;
      case '名前(降順)':
        orderBy = 'nameDESC';
        break;
    }
    List<Map> tmpClients = await clientService.select(searchMap: {
      'number': '',
      'name': name,
      'orderBy': orderBy,
    });
    for (Map map in tmpClients) {
      clients.add({
        'number': map['number'],
        'name': map['name'],
      });
    }
    _rebuildClientRows();
  }

  void _setKeyword(String value) {
    setState(() {
      keyword = value;
    });
  }

  Future _save() async {
    String? error;
    await clientService.clear();
    clients.forEach((map) async {
      error = await clientService.insert(
        number: '${map['number']}',
        name: '${map['name']}',
      );
    });
    if (error != null) {
      if (!mounted) return;
      showMessage(context, error!, false);
      return;
    }
  }

  @override
  void initState() {
    super.initState();
    _init();
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
            Row(
              children: [
                IconButton(
                  icon: const Icon(FluentIcons.back),
                  onPressed: () => Navigator.pop(context),
                ),
                const SizedBox(width: 8),
                const Text('取引先一覧', style: headerStyle),
                const SizedBox(width: 16),
                CustomIconTextButton(
                  iconData: FluentIcons.search,
                  iconColor: whiteColor,
                  labelText: 'キーワード検索: $keyword',
                  labelColor: whiteColor,
                  backgroundColor: lightBlueColor,
                  onPressed: () => showDialog(
                    context: context,
                    builder: (context) => SearchDialog(
                      keyword: keyword,
                      init: _init,
                      setKeyword: _setKeyword,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CustomComboBox(
                  value: clientSort,
                  items: kClientSorts.map((e) {
                    return ComboBoxItem(
                      value: e,
                      child: Text(e),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      clientSort = value!;
                    });
                    _init();
                  },
                ),
                const SizedBox(width: 8),
                CustomIconTextButton(
                  iconData: FluentIcons.upload,
                  iconColor: whiteColor,
                  labelText: 'CSVアップロード',
                  labelColor: whiteColor,
                  backgroundColor: greenColor,
                  onPressed: () => showDialog(
                    context: context,
                    builder: (context) => UploadDialog(
                      init: _init,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CustomIconTextButton(
                  iconData: FluentIcons.download,
                  iconColor: whiteColor,
                  labelText: 'CSVダウンロード',
                  labelColor: whiteColor,
                  backgroundColor: greenColor,
                  onPressed: () async {
                    List<String> header = ['番号', '名前'];
                    List<List<String>> rows = clients.map((e) {
                      return ['${e['number']}', '${e['name']}'];
                    }).toList();
                    await downloadCSV(
                      header: header,
                      rows: rows,
                    );
                  },
                ),
              ],
            ),
            Row(
              children: [
                CustomIconTextButton(
                  iconData: FluentIcons.save,
                  iconColor: whiteColor,
                  labelText: '以下の内容で保存する',
                  labelColor: whiteColor,
                  backgroundColor: blueColor,
                  onPressed: () async {
                    await _save();
                    if (!mounted) return;
                    showMessage(context, '取引先設定を保存しました', true);
                  },
                ),
                const SizedBox(width: 8),
                CustomIconTextButton(
                  iconData: FluentIcons.add,
                  iconColor: whiteColor,
                  labelText: '入力欄を追加',
                  labelColor: whiteColor,
                  backgroundColor: greyColor,
                  onPressed: () => _clientAdd(),
                ),
              ],
            ),
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
                          '※必ず上部の『以下の内容で保存する』ボタンを押してください。入力しただけでは保存されません。',
                          style: TextStyle(
                            color: redColor,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text(
                          'ここで取引先情報を登録できます。PDFファイル情報を保存する際に必要になりますので、かならず1つ以上登録してください。',
                        ),
                        CustomClientTable(rows: clientRows),
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

class SearchDialog extends StatefulWidget {
  final String keyword;
  final Function() init;
  final Function(String) setKeyword;

  const SearchDialog({
    required this.keyword,
    required this.init,
    required this.setKeyword,
    super.key,
  });

  @override
  State<SearchDialog> createState() => _SearchDialogState();
}

class _SearchDialogState extends State<SearchDialog> {
  TextEditingController keywordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    keywordController.text = widget.keyword;
  }

  @override
  Widget build(BuildContext context) {
    return ContentDialog(
      title: const Text(
        'キーワード検索',
        style: TextStyle(fontSize: 16),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomTextBox(
            controller: keywordController,
            maxLines: 1,
          ),
        ],
      ),
      actions: [
        FilledButton(
          onPressed: () async {
            widget.setKeyword('');
            await widget.init();
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
            widget.setKeyword(keywordController.text);
            await widget.init();
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

class UploadDialog extends StatefulWidget {
  final Function() init;

  const UploadDialog({
    required this.init,
    super.key,
  });

  @override
  State<UploadDialog> createState() => _UploadDialogState();
}

class _UploadDialogState extends State<UploadDialog> {
  ClientService clientService = ClientService();
  XFile? uploadFile;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return ContentDialog(
      title: const Text(
        'CSVアップロード',
        style: TextStyle(fontSize: 16),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '※CSVファイルの文字コードは「utf-8」にしてください。',
            style: TextStyle(
              color: redColor,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FilledButton(
                onPressed: () async {
                  XTypeGroup group = const XTypeGroup(
                    label: 'CSVファイル',
                    extensions: ['csv'],
                  );
                  XFile? result = await openFile(acceptedTypeGroups: [group]);
                  if (result == null) return;
                  setState(() {
                    uploadFile = result;
                  });
                },
                style: ButtonStyle(
                  backgroundColor: ButtonState.all(greenColor),
                ),
                child: const Text('CSVファイル選択'),
              ),
              const SizedBox(height: 4),
              uploadFile != null
                  ? Text(
                      '${uploadFile?.name}',
                      overflow: TextOverflow.ellipsis,
                    )
                  : Container(),
            ],
          ),
        ],
      ),
      actions: isLoading
          ? null
          : [
              FilledButton(
                onPressed: () => Navigator.pop(context),
                style: ButtonStyle(
                  backgroundColor: ButtonState.all(greyColor),
                ),
                child: const Text('キャンセル'),
              ),
              FilledButton(
                onPressed: () async {
                  if (uploadFile == null) return;
                  setState(() {
                    isLoading = true;
                  });
                  String csvText = await uploadFile!.readAsString();
                  List<List<String>> csvData = [];
                  int lineCount = 0;
                  for (String line in csvText.split('\n')) {
                    if (lineCount != 0 && line != '') {
                      List<String> rows = line.split(',');
                      csvData.add(rows);
                    }
                    lineCount++;
                  }
                  String? error;
                  await clientService.clear();
                  csvData.forEach((data) async {
                    data.add('');
                    error = await clientService.insert(
                      number: data[0],
                      name: data[1],
                    );
                  });
                  if (error != null) {
                    if (!mounted) return;
                    showMessage(context, error!, false);
                    return;
                  }
                  await widget.init();
                  if (!mounted) return;
                  Navigator.pop(context);
                },
                style: ButtonStyle(
                  backgroundColor: ButtonState.all(blueColor),
                ),
                child: const Text('アップロード実行'),
              ),
            ],
    );
  }
}
