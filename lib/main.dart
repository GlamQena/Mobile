import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  await _configureSystemUI();

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

Future<void> _configureSystemUI() async {
  // Enter immersive fullscreen so system status/navigation bars are hidden.
  // Note: bars re-appear on user swipe (immersiveSticky), which is typical.
  await SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.immersiveSticky,
    overlays: [],
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

  // ✅ Global key for the navigator
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

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
      navigatorKey: navigatorKey,
      home: _buildMainScaffold(Login()),
      routes: {
        '/login': (context) => _buildMainScaffold(Login()),
        '/register': (context) => _buildMainScaffold(Register()),
        '/forget_password': (context) => _buildMainScaffold(ForgetPassword()),
        '/reset_password': (context) => _buildMainScaffold(ResetPassword()),
        '/verify_otp': (context) => _buildMainScaffold(VerifyOTP()),
        '/verify_email': (context) => _buildMainScaffold(VerifyEmail()),
        '/profile': (context) => _buildMainScaffold(Profile()),
        '/cart': (context) => _buildMainScaffold(Cart()),
        '/stores': (context) => _buildMainScaffold(Stores()),
        '/wishlist': (context) => _buildMainScaffold(Wishlist()),
        '/orders': (context) => _buildMainScaffold(Orders()),
        '/store_products': (context) => _buildMainScaffold(StoreProducts()),
        '/product_details': (context) => _buildMainScaffold(ProductDetails()),
        '/billing': (context) => _buildMainScaffold(Billing()),
        '/order_details': (context) => _buildMainScaffold(OrderDetails()),
      },
    );
  }

  // Wrapper widget with fixed AppBar
  Widget _buildMainScaffold(Widget body) {
    return Scaffold(
      appBar: _buildAppBar(),
      drawer: _buildDrawer(context),
      body: body,
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Builder(
        builder: (context) {
          return GestureDetector(
            onTap: (){
              Navigator.pushReplacementNamed(context, "/stores");
              selectedDrawerTile="stores";
            },
            child: Text(
              'drawer_app_title'.tr(),
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
          );
        }
      ),
      titleSpacing: 0,
      backgroundColor: isDarkMode ? AppColorsDark.background : AppColorsLight.background,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDarkMode ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDarkMode ? Brightness.dark : Brightness.light,
      ),
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
        Builder(
          builder: (context) {
            return Row(
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
                      isDarkMode ? Icons.wb_sunny_outlined : Icons.nightlight_rounded,
                      size: 17,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            );
          }
        ),
      ],
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
      child: Builder(
        builder: (context) {
          return Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: (){
                        Navigator.pushReplacementNamed(context, "/stores");
                        selectedDrawerTile="stores";
                      },
                      child: Text(
                        'drawer_app_title'.tr(),
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ), //used as a listener to user gestures for raw touch detection
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
                    DrawerListTile(
                      title: 'drawer_stores'.tr(),
                      icon: Icon(
                        Icons.store,
                        size: 18,
                        color: selectedDrawerTile == "stores"
                            ? Colors.white
                            : isDark
                            ? AppColorsDark.textPrimary
                            : AppColorsLight.textPrimary,
                      ),
                      onTap: () {
                        selectedDrawerTile = "stores";
                        Navigator.pushReplacementNamed(context, "/stores");
                      },
                      isSelected: selectedDrawerTile == "stores",
                      isDarkMode: isDark,
                    ),

                    DrawerListTile(
                      title: 'drawer_login'.tr(),
                      icon: Icon(
                        Icons.login,
                        size: 18,
                        color: selectedDrawerTile == "login"
                            ? Colors.white
                            : isDark
                            ? AppColorsDark.textPrimary
                            : AppColorsLight.textPrimary,
                      ),
                      onTap: () {
                        selectedDrawerTile = "login";
                        Navigator.pushReplacementNamed(context, "/login");
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
                            : isDark
                            ? AppColorsDark.textPrimary
                            : AppColorsLight.textPrimary,
                      ),
                      onTap: () {
                        selectedDrawerTile = "register";
                        Navigator.pushReplacementNamed(context, "/register");
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
                          color: textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),

                    DrawerListTile(
                      title: 'drawer_orders'.tr(),
                      icon: FaIcon(
                        FontAwesomeIcons.cube,
                        size: 18,
                        color: selectedDrawerTile == "orders"
                            ? Colors.white
                            : isDark
                            ? AppColorsDark.textMuted
                            : AppColorsLight.textMuted,
                      ),
                      onTap: () {
                        selectedDrawerTile = "orders";
                        Navigator.pushReplacementNamed(context, "/orders");
                      },
                      isSelected: false,
                      isDarkMode: isDark,
                      titleColor: textMuted,
                      enabled: false,
                    ),

                    DrawerListTile(
                      title: 'drawer_wishlist'.tr(),
                      icon: FaIcon(
                        FontAwesomeIcons.heart,
                        size: 18,
                        color: selectedDrawerTile == "wishlist"
                            ? Colors.white
                            : isDark
                            ? AppColorsDark.textMuted
                            : AppColorsLight.textMuted,
                      ),
                      onTap: () {
                        selectedDrawerTile = "wishlist";
                        Navigator.pushReplacementNamed(context, "/wishlist");
                      },
                      isSelected: false,
                      isDarkMode: isDark,
                      titleColor: textMuted,
                      enabled: false,
                    ),

                    DrawerListTile(
                      title: 'drawer_profile'.tr(),
                      icon: Icon(
                        Icons.person,
                        size: 18,
                        color: selectedDrawerTile == "profile"
                            ? Colors.white
                            : isDark
                            ? AppColorsDark.textMuted
                            : AppColorsLight.textMuted,
                      ),
                      onTap: () {
                        selectedDrawerTile = "profile";
                        Navigator.pushReplacementNamed(context, "/profile");
                      },
                      isSelected: false,
                      isDarkMode: isDark,
                      titleColor: textMuted,
                      enabled: false,
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}