import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:hakata_file_manager/common/style.dart';
import 'package:hakata_file_manager/widgets/custom_icon_text_button.dart';
import 'package:hakata_file_manager/widgets/link_text.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class CustomPdfPreview extends StatelessWidget {
  final List<File> files;
  final int index;
  final Function()? leftOnPressed;
  final Function()? rightOnPressed;
  final Widget inputWidget;
  final String clientName;
  final Function()? allClearOnTap;
  final Function()? clearOnPressed;
  final Function()? saveOnPressed;

  const CustomPdfPreview({
    required this.files,
    required this.index,
    required this.leftOnPressed,
    required this.rightOnPressed,
    required this.inputWidget,
    required this.clientName,
    required this.allClearOnTap,
    required this.clearOnPressed,
    required this.saveOnPressed,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (files.isEmpty) {
      return Container();
    }
    bool isLeft = false;
    bool isRight = false;
    if (files.asMap().containsKey(index - 1)) {
      isLeft = true;
    }
    if (files.asMap().containsKey(index + 1)) {
      isRight = true;
    }
    File file = files[index];

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
                        onPressed: leftOnPressed,
                      )
                    : Container(),
              ),
              Expanded(
                child: Container(
                  color: blackColor,
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          color: grey2Color,
                          child: Center(
                            child: SfPdfViewer.file(file),
                          ),
                        ),
                      ),
                      const SizedBox(width: 1),
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
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        LinkText(
                                          label: 'アップロードを全てキャンセル',
                                          labelColor: redColor,
                                          onTap: allClearOnTap,
                                        ),
                                        Text(
                                          '${index + 1} / ${files.length}',
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    InfoLabel(
                                      label: '取引先番号',
                                      child: inputWidget,
                                    ),
                                    const SizedBox(height: 8),
                                    Container(
                                      width: double.infinity,
                                      decoration: const BoxDecoration(
                                        border: Border(
                                          bottom: BorderSide(color: blackColor),
                                        ),
                                      ),
                                      child: InfoLabel(
                                        label: '取引先名',
                                        child: clientName != ''
                                            ? Text(
                                                clientName,
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                ),
                                              )
                                            : const Text(
                                                '※取引先番号から自動入力されます',
                                                style: TextStyle(
                                                  color: greyColor,
                                                  fontSize: 16,
                                                ),
                                              ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Container(
                                      width: double.infinity,
                                      decoration: const BoxDecoration(
                                        border: Border(
                                          bottom: BorderSide(color: blackColor),
                                        ),
                                      ),
                                      child: InfoLabel(
                                        label: 'ファイルパス',
                                        child: Text(
                                          file.path,
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                      ),
                                    ),
                                    const Text(
                                      '※このソフトにPDFファイル自体は保存されません。上記のテキスト情報のみです。',
                                      style: TextStyle(color: redColor),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    CustomIconTextButton(
                                      iconData: FluentIcons.clear,
                                      iconColor: whiteColor,
                                      labelText: '保存しない',
                                      labelColor: whiteColor,
                                      backgroundColor: greyColor,
                                      onPressed: clearOnPressed,
                                    ),
                                    const SizedBox(width: 8),
                                    CustomIconTextButton(
                                      iconData: FluentIcons.save,
                                      iconColor: whiteColor,
                                      labelText: '保存する(Sキー)',
                                      labelColor: whiteColor,
                                      backgroundColor: blueColor,
                                      onPressed: saveOnPressed,
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
                        onPressed: rightOnPressed,
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
