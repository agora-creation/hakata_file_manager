import 'package:fluent_ui/fluent_ui.dart';

class CustomIconButton extends StatelessWidget {
  final IconData iconData;
  final Color iconColor;
  final Color backgroundColor;
  final Function()? onPressed;

  const CustomIconButton({
    required this.iconData,
    required this.iconColor,
    required this.backgroundColor,
    this.onPressed,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        iconData,
        color: iconColor,
        size: 20,
      ),
      style: ButtonStyle(
        backgroundColor: ButtonState.all(backgroundColor),
      ),
      onPressed: onPressed,
    );
  }
}
