import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
 static String get apiUrl => dotenv.env["API_URL"] ?? "http://192.168.40.1:8080";
 static String get paymobIframeId => dotenv.env["PAYMOB_IFRAME_ID"] ?? "1012636";
}