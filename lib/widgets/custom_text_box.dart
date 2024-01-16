import 'package:fluent_ui/fluent_ui.dart';

class CustomTextBox extends StatelessWidget {
  final TextEditingController? controller;
  final String? placeholder;
  final int? maxLines;
  final Function(String)? onChanged;

  const CustomTextBox({
    this.controller,
    this.placeholder,
    this.maxLines,
    this.onChanged,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextBox(
      controller: controller,
      placeholder: placeholder,
      expands: false,
      maxLines: maxLines,
      onChanged: onChanged,
    );
  }
}
