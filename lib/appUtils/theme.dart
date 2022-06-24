import 'package:firebase_assignment/constants/color_constants.dart';
import 'package:flutter/material.dart';


final appTheme = ThemeData(
  primaryColor: AppColors.aapnaGreen,
  scaffoldBackgroundColor: AppColors.white,
  appBarTheme: const AppBarTheme(backgroundColor: AppColors.aapnaGreen),
  colorScheme: ColorScheme.fromSwatch().copyWith(secondary: AppColors.burgundy),
);
