import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:hakata_file_manager/common/functions.dart';
import 'package:hakata_file_manager/common/style.dart';
import 'package:hakata_file_manager/services/file.dart';
import 'package:hakata_file_manager/widgets/custom_icon_text_button.dart';
import 'package:path/path.dart' as p;
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PdfDetailsScreen extends StatefulWidget {
  final Map<String, String> file;
  final Function() getFiles;

  const PdfDetailsScreen({
    required this.file,
    required this.getFiles,
    super.key,
  });

  @override
  State<PdfDetailsScreen> createState() => _PdfDetailsScreenState();
}

class _PdfDetailsScreenState extends State<PdfDetailsScreen> {
  FileService fileService = FileService();

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
            Text(p.basename(File('${widget.file['filePath']}').path),
                style: headerStyle),
            CustomIconTextButton(
              iconData: FluentIcons.delete,
              iconColor: whiteColor,
              labelText: '削除する',
              labelColor: whiteColor,
              backgroundColor: redColor,
              onPressed: () async {
                await fileService.delete(id: int.parse('${widget.file['id']}'));
                await widget.getFiles();
                if (!mounted) return;
                showMessage(context, 'PDFファイル情報を削除しました', true);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      content: Container(
        color: grey2Color,
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: SfPdfViewer.file(File('${widget.file['filePath']}')),
      ),
    );
  }
}
