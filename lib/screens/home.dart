import 'package:fluent_ui/fluent_ui.dart';
import 'package:hakata_file_manager/common/functions.dart';
import 'package:hakata_file_manager/common/style.dart';
import 'package:hakata_file_manager/providers/home.dart';
import 'package:hakata_file_manager/services/client.dart';
import 'package:hakata_file_manager/widgets/custom_combo_box.dart';
import 'package:hakata_file_manager/widgets/custom_file_card.dart';
import 'package:hakata_file_manager/widgets/custom_icon_text_button.dart';
import 'package:hakata_file_manager/widgets/custom_pdf_preview.dart';
import 'package:hakata_file_manager/widgets/custom_text_box.dart';
import 'package:hakata_file_manager/widgets/directory_path_header.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final homeProvider = Provider.of<HomeProvider>(context);

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
                      onPressed: () {},
                    ),
                    const SizedBox(width: 8),
                    CustomIconTextButton(
                      iconData: FluentIcons.settings,
                      iconColor: whiteColor,
                      labelText: '取引先設定',
                      labelColor: whiteColor,
                      backgroundColor: greyColor,
                      onPressed: () {},
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
                  path: homeProvider.selectDirectoryPath,
                  onTap: () async {
                    await homeProvider.selectDirectory();
                    await homeProvider.autoFocus();
                  },
                ),
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(8),
                    gridDelegate: homeGridDelegate,
                    itemCount: homeProvider.files.length,
                    itemBuilder: (context, index) {
                      Map<String, String> file = homeProvider.files[index];
                      return CustomFileCard(
                        file: file,
                        onTap: () {},
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        CustomPdfPreview(
          files: homeProvider.uploadFiles,
          index: homeProvider.uploadFilesIndex,
          leftOnPressed: () async {
            homeProvider.uploadFileLeft();
            await homeProvider.autoFocus();
          },
          rightOnPressed: () async {
            homeProvider.uploadFileRight();
            await homeProvider.autoFocus();
          },
          inputWidget: CustomTextBox(
            focusNode: homeProvider.clientNumberFocusNode,
            controller: homeProvider.clientNumberController,
            maxLines: 1,
            onSubmitted: (value) {
              homeProvider.checkClientNumber();
            },
          ),
          clientName: homeProvider.clientName,
          allClearOnTap: () async {
            homeProvider.uploadFileAllClear();
            await homeProvider.autoFocus();
          },
          clearOnPressed: () async {
            homeProvider.uploadFileClear();
            await homeProvider.autoFocus();
          },
          saveOnPressed: () async {
            String? error = await homeProvider.uploadFileSave();
            if (error != null) {
              if (!mounted) return;
              showMessage(context, error, false);
              return;
            }
            if (!mounted) return;
            showMessage(context, 'PDFファイル情報を保存しました', true);
            homeProvider.uploadFileClear();
            await homeProvider.autoFocus();
          },
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
