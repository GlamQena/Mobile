import 'package:flutter/material.dart';
import 'package:mobile_app/public/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';

class Link extends StatelessWidget {
  final String text;
  final String url;
  final bool isDarkMode;

  const Link({super.key, required this.text, required this.url, required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        _launchUrl(url);
      },
      child: Text(text, style: TextStyle(color: isDarkMode ? AppColorsDark.link : AppColorsLight.link, fontWeight: FontWeight.w500, fontSize: 17)),
    );
  }

  Future<void> _launchUrl(String url) async{
    Uri uri = Uri.parse(url);
    if(await canLaunchUrl(uri)){
      await launchUrl(uri);
    }
    else{
      throw Exception('can\'t launch url: $url');
    }
  }
}
