import 'package:flutter/material.dart';
import 'package:mobile_app/public/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';

class Link extends StatelessWidget {
  final String? text;
  final Widget? icon;
  final String url;
  final bool isPurpleMode;
  final Color? color;
  final double? fontSize;

  const Link({
    super.key,
    this.text,
    this.icon,
    required this.url,
    required this.isPurpleMode,
    this.color,
    this.fontSize
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _launchUrl(url);
      },
      child: text != null ?
      Text(
        text!,
        style: TextStyle(
          color: color ?? (isPurpleMode ? PurpleTheme.link : PinkTheme.link),
          fontWeight: FontWeight.w500,
          fontSize: fontSize ?? 17,
        ),
      ) :
      icon
    );
  }

  Future<void> _launchUrl(String url) async {
    Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw Exception('can\'t launch url: $url');
    }
  }
}
