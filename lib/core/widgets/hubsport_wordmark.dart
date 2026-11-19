import 'package:flutter/material.dart';

/// Wordmark de marca: HUB en blanco + SPORT en azul claro.
class HubSportWordmark extends StatelessWidget {
  final double fontSize;
  final FontWeight fontWeight;
  final double letterSpacing;
  final TextAlign textAlign;

  const HubSportWordmark({
    super.key,
    this.fontSize = 24,
    this.fontWeight = FontWeight.w900,
    this.letterSpacing = 0.5,
    this.textAlign = TextAlign.center,
  });

  static const Color sportBlue = Color(0xFF64A6FF);

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: 'HUB',
            style: TextStyle(
              color: Colors.white,
              fontSize: fontSize,
              fontWeight: fontWeight,
              letterSpacing: letterSpacing,
            ),
          ),
          TextSpan(
            text: 'SPORT',
            style: TextStyle(
              color: sportBlue,
              fontSize: fontSize,
              fontWeight: fontWeight,
              letterSpacing: letterSpacing,
            ),
          ),
        ],
      ),
      textAlign: textAlign,
    );
  }
}
