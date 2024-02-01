import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:hakata_file_manager/common/functions.dart';
import 'package:hakata_file_manager/common/style.dart';
import 'package:path/path.dart' as p;
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class CustomFileCard extends StatelessWidget {
  final Map<String, String> file;
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
              child: FutureBuilder<bool>(
                future: checkFileExistence('${file['filePath']}'),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    if (snapshot.data == true) {
                      return SfPdfViewer.file(
                        File('${file['filePath']}'),
                        canShowScrollHead: false,
                        canShowPageLoadingIndicator: false,
                        canShowScrollStatus: false,
                        enableDoubleTapZooming: false,
                        enableTextSelection: false,
                        enableDocumentLinkAnnotation: false,
                        canShowPaginationDialog: false,
                        canShowSignaturePadDialog: false,
                        pageLayoutMode: PdfPageLayoutMode.single,
                      );
                    } else {
                      return Container(color: grey2Color);
                    }
                  } else {
                    return Container(color: grey2Color);
                  }
                },
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                color: redColor.withOpacity(0.8),
                padding: const EdgeInsets.all(4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${file['clientName']}',
                          style: const TextStyle(
                            color: whiteColor,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${file['createDate']}',
                          style: const TextStyle(
                            color: whiteColor,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
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
                      p.basename('${file['filePath']}'),
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
