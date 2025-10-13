import 'package:flutter/material.dart';
import 'my_colors.dart';

final ThemeData darkLuxuryTheme = ThemeData(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: MyColors.background,
  primaryColor: MyColors.primary,
 
  colorScheme: const ColorScheme.dark(
    primary: MyColors.primary,
    secondary: MyColors.secondary,
    error: MyColors.error,
    surface: MyColors.surface,
  ),
  cardColor: MyColors.surface,
  appBarTheme: const AppBarTheme(
    backgroundColor: MyColors.surface,
    elevation: 0,
    titleTextStyle: TextStyle(color: MyColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w600),
    iconTheme: IconThemeData(color: MyColors.icon),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: MyColors.buttonBackground,
      foregroundColor: MyColors.buttonText,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
    ),
  ),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: MyColors.textPrimary),
    bodyMedium: TextStyle(color: MyColors.textSecondary),
    titleLarge: TextStyle(color: MyColors.textPrimary, fontWeight: FontWeight.bold),
  ),
  dividerColor: MyColors.divider,
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: MyColors.inputFill,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: MyColors.inputBorder),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: MyColors.inputFocusedBorder),
    ),
    hintStyle: const TextStyle(color: MyColors.hintText),
  ),
);
