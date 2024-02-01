import 'package:fluent_ui/fluent_ui.dart';
import 'package:hakata_file_manager/common/style.dart';

class CustomCalendarField extends StatelessWidget {
  final String label;
  final Function()? onPressed;

  const CustomCalendarField({
    required this.label,
    this.onPressed,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: grey2Color),
      ),
      child: ListTile(
        title: Text(label),
        trailing: const Icon(
          FluentIcons.calendar,
          color: greyColor,
        ),
        onPressed: onPressed,
      ),
    );
  }
}
