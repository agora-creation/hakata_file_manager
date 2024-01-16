import 'package:fluent_ui/fluent_ui.dart';

class CustomComboBox extends StatelessWidget {
  final String? value;
  final List<ComboBoxItem<String>>? items;
  final Function(String?)? onChanged;

  const CustomComboBox({
    required this.value,
    required this.items,
    required this.onChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ComboBox<String>(
      isExpanded: true,
      value: value,
      items: items,
      onChanged: onChanged,
    );
  }
}
