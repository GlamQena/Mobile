import 'package:flutter/material.dart';
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
    return Container(
      decoration: BoxDecoration(
        gradient: isSelected ?
          isDarkMode? AppColorsDark.sidebarActiveGradient : AppColorsLight.sidebarActiveGradient :
          LinearGradient(colors: [Colors.transparent, Colors.transparent], begin: Alignment.topCenter, end: Alignment.bottomCenter),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          focusColor: Colors.transparent,
          hoverColor: Colors.transparent,
          child: Theme(
            data: Theme.of(context).copyWith(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              hoverColor: Colors.transparent,
            ),
            child: ListTile(
              onTap: onTap,
              dense: true,
              leading: icon,
              title: Text(title, style: TextStyle(
                  color: titleColor ?? (isDarkMode? isSelected ? Colors.white : AppColorsDark.textPrimary : isSelected  ? Colors.white :AppColorsLight.textPrimary),
                  fontSize: 15,
                  fontWeight: FontWeight.w400
              )),
              minLeadingWidth: 0,
              enabled: enabled ?? true,
              splashColor: Colors.transparent,
              focusColor: Colors.transparent,
              hoverColor: Colors.transparent,
            ),
          ),
        ),
      ),
    );
  }
}