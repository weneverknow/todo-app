import 'package:flutter/material.dart';

import 'general_text.dart';

class SubTitleText extends GeneralText {
  SubTitleText() {
    size = 18.0;
    weight = FontWeight.w600;
  }

  Widget get child => Text(text,
      style: TextStyle(color: color, fontSize: size, fontWeight: weight));
}
