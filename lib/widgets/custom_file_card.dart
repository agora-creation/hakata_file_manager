import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:hakata_file_manager/common/style.dart';
import 'package:path/path.dart' as p;
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class CustomFileCard extends StatelessWidget {
  final File file;
  final Function()? onTap;

  const CustomFileCard({
    required this.file,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        padding: EdgeInsets.zero,
        child: Stack(
          children: [
            Center(
              child: SfPdfViewer.file(
                file,
                canShowPaginationDialog: false,
                canShowScrollStatus: false,
                canShowScrollHead: false,
                pageLayoutMode: PdfPageLayoutMode.single,
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                color: blackColor.withOpacity(0.8),
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      p.basename(file.path),
                      style: const TextStyle(
                        color: whiteColor,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
