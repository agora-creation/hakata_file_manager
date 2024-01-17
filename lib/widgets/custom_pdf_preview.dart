import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:hakata_file_manager/common/style.dart';
import 'package:hakata_file_manager/widgets/custom_icon_button.dart';
import 'package:hakata_file_manager/widgets/custom_icon_text_button.dart';
import 'package:hakata_file_manager/widgets/custom_text_box.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class CustomPdfPreview extends StatelessWidget {
  final List<File> files;
  final int index;
  final Function()? leftOnPressed;
  final Function()? rightOnPressed;
  final TextEditingController clientNumberController;
  final String clientName;
  final FocusNode numberFocusNode;
  final Function(String)? clientNumberOnChanged;
  final Function()? clientSearchOnPressed;
  final Function()? allClearOnPressed;
  final Function()? clearOnPressed;
  final Function()? saveOnPressed;

  const CustomPdfPreview({
    required this.files,
    required this.index,
    required this.leftOnPressed,
    required this.rightOnPressed,
    required this.clientNumberController,
    required this.clientName,
    required this.numberFocusNode,
    required this.clientNumberOnChanged,
    required this.clientSearchOnPressed,
    required this.allClearOnPressed,
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
                  color: grey2Color,
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
                      const SizedBox(width: 4),
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
                                        '${index + 1} / ${files.length}',
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    InfoLabel(
                                      label: '取引先番号',
                                      child: CustomTextBox(
                                        focusNode: numberFocusNode,
                                        controller: clientNumberController,
                                        maxLines: 1,
                                        onChanged: clientNumberOnChanged,
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
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          InfoLabel(
                                            label: '取引先名',
                                            child: Text(
                                              clientName,
                                              style:
                                                  const TextStyle(fontSize: 16),
                                            ),
                                          ),
                                          CustomIconButton(
                                            iconData: FluentIcons.search,
                                            iconColor: whiteColor,
                                            backgroundColor: greyColor,
                                            onPressed: clientSearchOnPressed,
                                          ),
                                        ],
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
                                      onPressed: allClearOnPressed,
                                    ),
                                    const SizedBox(width: 8),
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
                                      labelText: '保存する',
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
