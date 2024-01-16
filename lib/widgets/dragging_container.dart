import 'package:fluent_ui/fluent_ui.dart';
import 'package:hakata_file_manager/common/style.dart';

class DraggingContainer extends StatelessWidget {
  const DraggingContainer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: blackColor.withOpacity(0.6),
      child: const Center(
        child: Text(
          'ファイルをドラッグ＆ドロップ中...',
          style: TextStyle(
            color: whiteColor,
            fontSize: 24,
          ),
        ),
      ),
    );
  }
}
