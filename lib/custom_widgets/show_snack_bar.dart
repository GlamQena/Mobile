import 'package:flutter/material.dart';
import 'package:mobile_app/public/app_colors.dart';

ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showSnackBarCustom({required String message, required bool isSuccess, required bool isDarkMode, required BuildContext context}){

  return ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      dismissDirection: DismissDirection.down,
      content: Text(message, style: TextStyle(
        color: isSuccess ? Colors.green : isDarkMode ? AppColorsDark.error : AppColorsLight.error,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      )),
    )
  );
}
