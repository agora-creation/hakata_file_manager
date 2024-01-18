import 'package:fluent_ui/fluent_ui.dart';

class CustomTextBox extends StatelessWidget {
  final bool autofocus;
  final FocusNode? focusNode;
  final TextEditingController? controller;
  final String? placeholder;
  final int? maxLines;
  final Function(String)? onChanged;
  final Function(String)? onSubmitted;

  const CustomTextBox({
    this.autofocus = false,
    this.focusNode,
    this.controller,
    this.placeholder,
    this.maxLines,
    this.onChanged,
    this.onSubmitted,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextBox(
      autofocus: autofocus,
      focusNode: focusNode,
      controller: controller,
      placeholder: placeholder,
      expands: false,
      maxLines: maxLines,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
    );
  }
}
