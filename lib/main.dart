import 'package:flutter/material.dart';
import 'public/app_colors.dart';
import 'custom_widgets/gradient_button.dart';

// Authentication screens
import 'pages/authentication/login.dart';
import 'pages/authentication/register.dart';
import 'pages/authentication/forget_password.dart';
import 'pages/authentication/reset_password.dart';
import 'pages/authentication/verify_otp.dart';
import 'pages/authentication/verify_email.dart';

// Client dashboard screens
import 'pages/client_dashboard/profile.dart';
import 'pages/client_dashboard/stores.dart';
import 'pages/client_dashboard/cart.dart';
import 'pages/client_dashboard/orders.dart';
import 'pages/client_dashboard/wishlist.dart';
import 'pages/client_dashboard/store_products.dart';
import 'pages/client_dashboard/product_details.dart';
import 'pages/client_dashboard/billing.dart';
import 'pages/client_dashboard/order_details.dart';


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
                  Navigator.pushNamed(context, "/cart");
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
                  '/login': (context) => Login(),
                  '/register': (context) => Register(),
                  '/forget_password': (context) => ForgetPassword(),
                  '/reset_password': (context) => ResetPassword(),
                  '/verify_otp': (context) => VerifyOTP(),
                  '/verify_email': (context) => VerifyEmail(),

                  '/profile': (context) => Profile(),
                  '/cart': (context) => Cart(),
                  '/stores': (context) => Stores(),
                  '/wishlist': (context) => Wishlist(),
                  '/orders': (context) => Orders(),
                  '/store_products': (context) => StoreProducts(),
                  '/product_details': (context) => ProductDetails(),
                  '/billing': (context) => Billing(),
                  '/order_details': (context) => OrderDetails(),

                }
    );
  }
}