import 'package:flutter/material.dart';
import 'public/app_colors.dart';
import 'custom_widgets/gradient_button.dart';
import 'pages/Authentication/Login.dart';
import 'pages/Authentication/Register.dart';
import 'pages/Authentication/VerifyEmail.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => MyAppState();
}

class MyAppState extends State<MyApp>{
  bool isDarkMode = false;
  bool isArabic = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
          appBar: AppBar(
            title: Text("GlamQena", style: TextStyle(color: AppColors.primary)),
            backgroundColor: isDarkMode ? AppColorsDark.background : AppColorsLight.background,
            actions:[
              TextButton(
                onPressed: (){
                  setState((){
                    isArabic = !isArabic;
                  });
                },
                style: TextButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: isDarkMode? AppColorsDark.textPrimary : AppColorsLight.textPrimary,
                ),
                child: Text(isArabic ? "EN" : "AR", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400))
              ),

              IconButton(
                onPressed: (){
                  Navigator.pushNamed(context, "cart");
                },
                style: IconButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: isDarkMode? AppColorsDark.textPrimary : AppColorsLight.textPrimary,
                  iconSize: 15
                ),
                icon: Icon(Icons.shopping_cart_outlined,)
              ),

              IconButton(
                  onPressed: (){
                    setState((){
                      isDarkMode = !isDarkMode;
                    });
                  },
                  style: IconButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: isDarkMode? AppColorsDark.textPrimary : AppColorsLight.textPrimary,
                      iconSize: 15
                  ),
                  icon: Icon(isDarkMode ? Icons.sunny : Icons.mode_night)
              ),
            ]
          ),
        ),
        routes: {
          "Login": (context) => Login(),
          "Register": (context) => Register(),
          "Profile": (context) => Profile(),
          "Cart": (context) => Cart(),
          "Stores.dart": (context) => Stores(),
          "Wishlist": (context) => Wishlist(),
          "Orders": (context) => Orders(),

        }
    );
  }
}