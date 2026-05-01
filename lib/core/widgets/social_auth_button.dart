import 'package:flutter/material.dart';

class SocialAuthButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color textColor;
  final Color iconColor;

  const SocialAuthButton({
    Key? key,
    required this.text,
    required this.icon,
    required this.onPressed,
    this.backgroundColor = Colors.white,
    this.textColor = Colors.black87,
    this.iconColor = Colors.black87,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: iconColor),
        label: Text(
          text,
          style: TextStyle(
            color: textColor,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          elevation: 0,
        ),
      ),
    );
  }
}
