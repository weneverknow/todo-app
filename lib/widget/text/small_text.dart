import 'package:flutter/material.dart';

import 'general_text.dart';

class SmallText extends GeneralText {
  SmallText() {
    size = 12.0;
    weight = FontWeight.w400;
  }

  Widget get child => Text(text,
      style: TextStyle(color: color, fontSize: size, fontWeight: weight));
}
