import 'package:fluent_ui/fluent_ui.dart';
import 'package:hakata_file_manager/common/style.dart';

class DirectoryPathHeader extends StatelessWidget {
  final String path;
  final Function()? onTap;

  const DirectoryPathHeader({
    required this.path,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        color: grey2Color,
        padding: const EdgeInsets.all(8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('現在接続中のファイルパス: $path'),
            const Text(
              'クリックで変更できます',
              style: TextStyle(color: greyColor),
            ),
          ],
        ),
      ),
    );
  }
}
