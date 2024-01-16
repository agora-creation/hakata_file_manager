import 'package:cross_file/cross_file.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:hakata_file_manager/common/functions.dart';
import 'package:hakata_file_manager/common/style.dart';
import 'package:hakata_file_manager/services/client.dart';
import 'package:hakata_file_manager/services/file.dart';
import 'package:hakata_file_manager/widgets/custom_icon_text_button.dart';
import 'package:hakata_file_manager/widgets/custom_text_box.dart';

class PreviewContainer extends StatefulWidget {
  final List<XFile> uploadFiles;
  final Function() getFiles;

  const PreviewContainer({
    required this.uploadFiles,
    required this.getFiles,
    super.key,
  });

  @override
  State<PreviewContainer> createState() => _PreviewContainerState();
}

class _PreviewContainerState extends State<PreviewContainer> {
  ClientService clientService = ClientService();
  FileService fileService = FileService();
  int index = 0;
  String clientNumber = '';
  String clientName = '';

  void pageLeft() {
    setState(() {
      index -= 1;
      clientNumber = '';
      clientName = '';
    });
  }

  void pageRight() {
    setState(() {
      index += 1;
      clientNumber = '';
      clientName = '';
    });
  }

  void uploadCancel() {
    setState(() {
      widget.uploadFiles.clear();
    });
  }

  void inputClientNumber(String value) {
    clientNumber = value;
  }

  void selectClient() async {
    List<Map> tmpClients = await clientService.select(searchMap: {
      'number': clientNumber,
    });
    if (tmpClients.isNotEmpty) {
      setState(() {
        clientName = tmpClients.first['name'];
      });
    }
  }

  void notSave() {
    setState(() {
      widget.uploadFiles.removeAt(index);
      if (widget.uploadFiles.isNotEmpty) {
        index = 0;
        clientNumber = '';
        clientName = '';
      } else {
        widget.uploadFiles.clear();
      }
    });
  }

  void save() async {
    String? error = await fileService.insert(
      clientNumber: clientNumber,
      clientName: clientName,
      uploadFile: widget.uploadFiles[index],
    );
    if (error != null) {
      if (!mounted) return;
      showMessage(context, error, false);
      return;
    }
    setState(() {
      widget.uploadFiles.removeAt(index);
      if (widget.uploadFiles.isNotEmpty) {
        index = 0;
        clientNumber = '';
        clientName = '';
      } else {
        widget.uploadFiles.clear();
      }
    });
    widget.getFiles();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.uploadFiles.isEmpty) {
      return Container();
    }
    bool isLeft = false;
    bool isRight = false;
    if (widget.uploadFiles.asMap().containsKey(index - 1)) {
      isLeft = true;
    }
    if (widget.uploadFiles.asMap().containsKey(index + 1)) {
      isRight = true;
    }
    XFile currentUploadFile = widget.uploadFiles[index];

    return Container(
      color: blackColor.withOpacity(0.6),
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.all(24),
                child: isLeft
                    ? IconButton(
                        icon: const Icon(
                          FluentIcons.page_left,
                          size: 24,
                        ),
                        style: ButtonStyle(
                          backgroundColor: ButtonState.all(whiteColor),
                        ),
                        onPressed: () => pageLeft(),
                      )
                    : Container(),
              ),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        color: grey2Color,
                        child: const Center(
                          child: Text('PDFプレビュー画像'),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        color: whiteColor,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                      '${index + 1} / ${widget.uploadFiles.length}',
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  InfoLabel(
                                    label: '取引先番号',
                                    child: CustomTextBox(
                                      controller: TextEditingController(
                                        text: clientNumber,
                                      ),
                                      onChanged: (value) {
                                        inputClientNumber(value);
                                      },
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  InfoLabel(
                                    label: '取引先名',
                                    child: Row(
                                      children: [
                                        Text(
                                          clientName,
                                          style: const TextStyle(fontSize: 18),
                                        ),
                                        clientName != ''
                                            ? const SizedBox(width: 8)
                                            : Container(),
                                        CustomIconTextButton(
                                          iconData: FluentIcons.search,
                                          iconColor: whiteColor,
                                          labelText: '取引先番号から取得',
                                          labelColor: whiteColor,
                                          backgroundColor: greyColor,
                                          onPressed: () => selectClient(),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  InfoLabel(
                                    label: 'ファイル名',
                                    child: Text(
                                      currentUploadFile.name,
                                      style: const TextStyle(fontSize: 18),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  CustomIconTextButton(
                                    iconData: FluentIcons.clear,
                                    iconColor: whiteColor,
                                    labelText: 'アップロードを全てキャンセルする',
                                    labelColor: whiteColor,
                                    backgroundColor: redColor,
                                    onPressed: () => uploadCancel(),
                                  ),
                                  const SizedBox(width: 8),
                                  CustomIconTextButton(
                                    iconData: FluentIcons.clear,
                                    iconColor: whiteColor,
                                    labelText: '保存しない',
                                    labelColor: whiteColor,
                                    backgroundColor: greyColor,
                                    onPressed: () => notSave(),
                                  ),
                                  const SizedBox(width: 8),
                                  CustomIconTextButton(
                                    iconData: FluentIcons.save,
                                    iconColor: whiteColor,
                                    labelText: '保存する',
                                    labelColor: whiteColor,
                                    backgroundColor: blueColor,
                                    onPressed: () => save(),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(32),
                child: isRight
                    ? IconButton(
                        icon: const Icon(
                          FluentIcons.page_right,
                          size: 24,
                        ),
                        style: ButtonStyle(
                          backgroundColor: ButtonState.all(whiteColor),
                        ),
                        onPressed: () => pageRight(),
                      )
                    : Container(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
