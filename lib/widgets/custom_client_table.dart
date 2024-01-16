import 'package:fluent_ui/fluent_ui.dart';
import 'package:hakata_file_manager/common/style.dart';

class CustomClientTable extends StatelessWidget {
  final List<TableRow> rows;

  const CustomClientTable({
    required this.rows,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    List<TableRow> children = [
      TableRow(
        decoration: const BoxDecoration(color: grey2Color),
        children: [
          Container(
            alignment: Alignment.center,
            margin: const EdgeInsets.all(4),
            child: const Text('取引先番号'),
          ),
          Container(
            alignment: Alignment.center,
            margin: const EdgeInsets.all(4),
            child: const Text('取引先名'),
          ),
          Container(
            alignment: Alignment.center,
            margin: const EdgeInsets.all(4),
            child: const Text('削除'),
          ),
        ],
      ),
    ];
    for (TableRow row in rows) {
      children.add(row);
    }
    return Table(
      border: TableBorder.all(color: greyColor),
      columnWidths: const {
        0: FlexColumnWidth(5),
        1: FlexColumnWidth(5),
        2: FlexColumnWidth(0.5),
      },
      children: children,
    );
  }
}
