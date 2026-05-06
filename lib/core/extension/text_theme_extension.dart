import 'package:flutter/material.dart';

extension AppTextStyles on BuildContext {
  TextTheme get textTheme => Theme.of(this).textTheme;

}