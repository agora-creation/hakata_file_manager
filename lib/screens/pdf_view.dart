import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:hakata_file_manager/common/style.dart';
import 'package:path/path.dart' as p;
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PDFViewScreen extends StatefulWidget {
  final File file;

  const PDFViewScreen({
    required this.file,
    super.key,
  });

  @override
  State<PDFViewScreen> createState() => _PDFViewScreenState();
}

class _PDFViewScreenState extends State<PDFViewScreen> {
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
            Text(p.basename(widget.file.path), style: headerStyle),
            Container(),
          ],
        ),
      ),
      content: SfPdfViewer.file(widget.file),
    );
  }
}
