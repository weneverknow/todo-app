import 'package:flutter/material.dart';
import 'general_text.dart';

class TitleText extends GeneralText {
  TitleText() {
    size = 24.0;
    weight = FontWeight.w600;
  }

  Widget get child => Text(
        text,
        style: TextStyle(color: color, fontSize: size, fontWeight: weight),
      );
}
