import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../public/app_colors.dart';

class  DrawerListTile extends StatelessWidget {
  final String title;
  final Widget icon;
  final VoidCallback onTap;
  final bool isSelected;
  final bool isDarkMode;
  final bool? enabled;
  final Color? titleColor;

  const DrawerListTile({super.key, required this.title, required this.icon, required this.onTap, required this.isSelected, required this.isDarkMode, this.titleColor, this.enabled});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      dense: true,
      leading: icon,
      title: Text(title, style: TextStyle(
          color: titleColor ?? (isDarkMode? isSelected ? Colors.white : AppColorsDark.textPrimary : isSelected  ? Colors.white :AppColorsLight.textPrimary),
          fontSize: 15,
          fontWeight: FontWeight.w400
      )),
      selectedTileColor: isDarkMode? AppColors.primary : AppColors.primary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      minLeadingWidth: 0,
      selected: isSelected ,
      enabled: enabled ?? true,
      splashColor: Colors.transparent,
    );
  }
}
