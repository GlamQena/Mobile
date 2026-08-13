import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'custom_widgets/drawer_list_tile.dart';
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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale("ar"), Locale("en")],
      path: "assets/i18n",
      fallbackLocale: const Locale("ar"),
      startLocale: const Locale("ar"),
      useOnlyLangCode: true,
      saveLocale: false,
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  bool isDarkMode = false;
  late bool isArabic;
  String selectedDrawerTile = "login";

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    isArabic = context.locale.languageCode == "ar";
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: context.locale,
      supportedLocales: context.supportedLocales,
      localizationsDelegates: context.localizationDelegates,
      home: Scaffold(
        appBar: AppBar(
          title: Text(
            'drawer_app_title'.tr(), // ✅ Updated to flattened key
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
          titleSpacing: 0,
          backgroundColor: isDarkMode ? AppColorsDark.background : AppColorsLight.background,
          actionsPadding: const EdgeInsets.only(right: 3),
          iconTheme: IconThemeData(
            color: AppColors.primary,
            size: 20,
          ),
          actionsIconTheme: const IconThemeData(
            color: AppColors.primary,
            size: 17,
          ),
          actions: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () {
                    Locale newLocale = isArabic ? const Locale("en") : const Locale("ar");
                    context.setLocale(newLocale);
                    setState(() => isArabic = !isArabic);
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      isArabic ? "EN" : "AR",
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pushNamed(context, "/cart"),
                  child: const Padding(
                    padding: EdgeInsets.all(10),
                    child: Icon(
                      Icons.shopping_cart_outlined,
                      size: 17,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => setState(() => isDarkMode = !isDarkMode),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Icon(
                      isDarkMode ? Icons.wb_sunny_outlined : Icons.nightlight_outlined,
                      size: 17,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        drawer: _buildDrawer(context),
        body: Login(),
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
      },
    );
  }

  Widget _buildDrawer(BuildContext context) {
    final isDark = isDarkMode;

    final backgroundColor = isDark ? AppColorsDark.sidebarBackground : AppColorsLight.sidebarBackground;
    final textPrimary = isDark ? AppColorsDark.textPrimary : AppColorsLight.textPrimary;
    final textMuted = isDark ? AppColorsDark.textMuted : AppColorsLight.textMuted;
    final textSecondary = isDark ? AppColorsDark.textSecondary : AppColorsLight.textSecondary;

    return Drawer(
      backgroundColor: backgroundColor,
      width: MediaQuery.of(context).size.width * 0.82,
      child: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'drawer_app_title'.tr(), // ✅ Updated to flattened key
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: Icon(
                      Icons.close,
                      color: textPrimary,
                      size: 22,
                    ),
                  ),
                ],
              ),
            ),

            const Divider(height: 1, color: Colors.transparent),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                children: [
                  // ✅ Updated to flattened keys
                  DrawerListTile(
                    title: 'drawer_stores'.tr(),
                    icon: Icon(
                      Icons.store,
                      size: 18,
                      color: selectedDrawerTile == "stores"
                          ? Colors.white
                          : isDark ? AppColorsDark.textSecondary : AppColorsLight.textSecondary,
                    ),
                    onTap: () {
                      selectedDrawerTile = "stores";
                      Navigator.of(context).pushReplacementNamed("/stores");
                    },
                    isSelected: selectedDrawerTile == "stores",
                    isDarkMode: isDark,
                  ),

                  DrawerListTile(
                    title: 'drawer_login'.tr(),
                    icon: FaIcon(
                      FontAwesomeIcons.doorOpen,
                      size: 18,
                      color: selectedDrawerTile == "login"
                          ? Colors.white
                          : isDark ? AppColorsDark.textSecondary : AppColorsLight.textSecondary,
                    ),
                    onTap: () {
                      selectedDrawerTile = "login";
                      Navigator.of(context).pushReplacementNamed("/login");
                    },
                    isSelected: selectedDrawerTile == "login",
                    isDarkMode: isDark,
                  ),

                  DrawerListTile(
                    title: 'drawer_register'.tr(),
                    icon: Icon(
                      Icons.person_add_alt,
                      size: 18,
                      color: selectedDrawerTile == "register"
                          ? Colors.white
                          : isDark ? AppColorsDark.textSecondary : AppColorsLight.textSecondary,
                    ),
                    onTap: () {
                      selectedDrawerTile = "register";
                      Navigator.of(context).pushReplacementNamed("/register");
                    },
                    isSelected: selectedDrawerTile == "register",
                    isDarkMode: isDark,
                  ),

                  const SizedBox(height: 8),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    child: Text(
                      'drawer_member_area'.tr().toUpperCase(),
                      style: TextStyle(
                        color: textMuted,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),

                  DrawerListTile(
                    title: 'drawer_profile'.tr(),
                    icon: FaIcon(
                      FontAwesomeIcons.personCane,
                      size: 18,
                      color: selectedDrawerTile == "profile"
                          ? Colors.white
                          : isDark ? AppColorsDark.textSecondary : AppColorsLight.textSecondary,
                    ),
                    onTap: () {
                      selectedDrawerTile = "profile";
                      Navigator.of(context).pushReplacementNamed("/profile");
                    },
                    isSelected: selectedDrawerTile == "profile",
                    isDarkMode: isDark,
                  ),

                  DrawerListTile(
                    title: 'drawer_wishlist'.tr(),
                    icon: FaIcon(
                      FontAwesomeIcons.heart,
                      size: 18,
                      color: selectedDrawerTile == "wishlist"
                          ? Colors.white
                          : isDark ? AppColorsDark.textSecondary : AppColorsLight.textSecondary,
                    ),
                    onTap: () {
                      selectedDrawerTile = "wishlist";
                      Navigator.of(context).pushReplacementNamed("/wishlist");
                    },
                    isSelected: selectedDrawerTile == "wishlist",
                    isDarkMode: isDark,
                  ),

                  DrawerListTile(
                    title: 'drawer_orders'.tr(),
                    icon: FaIcon(
                      FontAwesomeIcons.boxesPacking,
                      size: 18,
                      color: selectedDrawerTile == "orders"
                          ? Colors.white
                          : isDark ? AppColorsDark.textSecondary : AppColorsLight.textSecondary,
                    ),
                    onTap: () {
                      selectedDrawerTile = "orders";
                      Navigator.of(context).pushReplacementNamed("/orders");
                    },
                    isSelected: selectedDrawerTile == "orders",
                    isDarkMode: isDark,
                  ),

                  const SizedBox(height: 8),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}