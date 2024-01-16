import 'package:fluent_ui/fluent_ui.dart';
import 'package:hakata_file_manager/common/functions.dart';
import 'package:hakata_file_manager/common/style.dart';
import 'package:hakata_file_manager/services/client.dart';
import 'package:hakata_file_manager/widgets/custom_client_table.dart';
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
    _rebuildClientRows();
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
            IconButton(
              icon: const Icon(FluentIcons.back),
              onPressed: () => Navigator.pop(context),
            ),
            const Text('取引先設定', style: headerStyle),
            CustomIconTextButton(
              iconData: FluentIcons.save,
              iconColor: whiteColor,
              labelText: '設定を保存',
              labelColor: whiteColor,
              backgroundColor: blueColor,
              onPressed: () async {
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
                if (!mounted) return;
                showMessage(context, '設定を保存しました', true);
                return;
              },
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
                        CustomClientTable(rows: clientRows),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(),
                            CustomIconTextButton(
                              iconData: FluentIcons.add,
                              iconColor: whiteColor,
                              labelText: '取引先を追加',
                              labelColor: whiteColor,
                              backgroundColor: blueColor,
                              onPressed: () => _clientAdd(),
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
