import 'package:easy_localization/easy_localization.dart';
import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mobile_app/custom_widgets/show_snack_bar.dart';
import 'package:mobile_app/services/api_client.dart';
import 'package:mobile_app/services/auth/auth.dart';
import 'package:mobile_app/messages_mappers/logout_messages.dart';
import 'config/app_config.dart';
import 'custom_widgets/drawer_list_tile.dart';
import 'custom_widgets/link_widget.dart';
import 'public/app_colors.dart';
import 'public/app_effects.dart';
import 'package:get_storage/get_storage.dart';
import 'services/auth/secure_storage.dart';
import "./services/auth/auth_state.dart";

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

  const env = String.fromEnvironment("ENV", defaultValue: "development");
  String envFile =
      env == "development" ? ".env.development" : ".env.production";

  debugPrint('🚀 Running in $env mode');
  debugPrint('📄 Loading: $envFile');

  try {
    await dotenv.load(fileName: envFile);
    debugPrint('✅ Environment loaded successfully');
    debugPrint('📍 API URL: ${AppConfig.apiUrl}');
    debugPrint('🔑 Paymob Iframe ID: ${AppConfig.paymobIframeId}');
  } catch (e) {
    debugPrint('⚠️ Error loading .env file: $e');
    await dotenv.load(fileName: '.env.development');
  }

  await GetStorage.init();
  final storage = GetStorage();
  final String preferredLang = storage.read("lang") ?? "ar";

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale("ar"), Locale("en")],
      path: "assets/i18n",
      startLocale: Locale(preferredLang),
      fallbackLocale: const Locale("ar"),
      useOnlyLangCode: true, // tells it to look for "ar.json" not "ar-EG.json"
      saveLocale: false,
      child: const MyApp(),
    ),
  );
}

Future<void> _configureSystemUI() async {
  await SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.immersiveSticky,
    overlays: [],
  );
}

class RouteChangeObserver extends NavigatorObserver {
  final void Function(Route<dynamic>? route) onRouteChanged;

  RouteChangeObserver({required this.onRouteChanged});

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    onRouteChanged(route);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    onRouteChanged(previousRoute);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    onRouteChanged(newRoute);
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didRemove(route, previousRoute);
    onRouteChanged(previousRoute);
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => MyAppState();
}

class MyAppState extends State<MyApp> with RouteAware {
  late AppLinks _appLinks;
  Uri? _pendingDeepLink;
  DateTime? _lastDeepLinkAt;
  String? _lastDeepLinkUri;
  late final RouteChangeObserver _routeChangeObserver;
  final storage = GetStorage();
  bool isPurpleMode = true;
  final SecureStorageService secureStorage = SecureStorageService();
  bool isLoggedIn = true;
  bool isArabic = true;

  /// Currently highlighted drawer entry. Derived from the active route via RouteAware.
  String selectedDrawerTile = "";

  /// Currently selected bottom navigation index (0..3).
  int _currentNavigationIndex = 0;

  late Color textPrimary;
  late Color textSecondary;
  late Color textMuted;
  late Color surfaceVariant;
  late Color themePrimary;

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  /// ----------------------------------------------------------------
  /// Route ↔ Drawer tile mapping
  /// ----------------------------------------------------------------
  static const Map<String, String> _routeToDrawerTile = {
    '/login': 'login',
    '/register': 'register',
    '/orders': 'orders',
    '/profile': 'profile',
    '/stores': 'stores',
    '/cart': 'cart',
    '/wishlist': 'wishlist',
    // Auth helper screens — no matching drawer tile.
    '/forget_password': '',
    '/reset_password': '',
    '/verify_otp': '',
    '/verify_email': '',
    // Store/product screens — reached from stores tile.
    '/store_products': 'stores',
    '/product_details': 'stores',
    '/billing': '',
    '/order_details': 'orders',
  };

  /// ----------------------------------------------------------------
  /// Route ↔ Bottom nav index mapping.
  /// ----------------------------------------------------------------
  static const Map<String, int> _routeToBottomNavIndex = {
    '/': 0,
    '/stores': 1,
    '/store_products': 1,
    '/product_details': 1,
    '/wishlist': 2,
    '/cart': 3,
  };

  void _onRouteChanged(Route<dynamic>? route) {
    final routeName = route?.settings.name ?? '';
    debugPrint("captured route name from NavigatorObserver: $routeName");

    if (routeName.isEmpty) return;

    if (routeName.startsWith('/?')) {
      debugPrint("🚫 popping mangled warm-start route: $routeName");
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Future.delayed(const Duration(milliseconds: 50), () {
          final nav = navigatorKey.currentState;
          if (nav != null && nav.canPop()) {
            debugPrint('🚫 popping mangled passthrough');
            nav.pop();
          }
        });
      });
      return;
    }

    final drawerTile = _routeToDrawerTile[routeName];
    final bottomIndex = _routeToBottomNavIndex[routeName];

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {
        if (drawerTile != null && drawerTile.isNotEmpty) {
          selectedDrawerTile = drawerTile;
        }
        if (bottomIndex != null) {
          _currentNavigationIndex = bottomIndex;
        }
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _routeChangeObserver = RouteChangeObserver(onRouteChanged: _onRouteChanged);
    isPurpleMode = storage.read("theme") ?? true;

    textPrimary =
        isPurpleMode ? PurpleTheme.textPrimary : PinkTheme.textPrimary;
    textSecondary =
        isPurpleMode ? PurpleTheme.textSecondary : PinkTheme.textSecondary;
    textMuted = isPurpleMode ? PurpleTheme.textMuted : PinkTheme.textMuted;
    surfaceVariant = isPurpleMode
        ? PurpleTheme.surfaceVariant
        : PinkTheme.surfaceVariant;
    themePrimary = isPurpleMode ? AppColors.purpleDark : AppColors.pinkMain;

    WidgetsBinding.instance.addPostFrameCallback((_) async{
      await _initDeepLinks();

      final loggedIn = await secureStorage.isLoggedIn();
      if (!mounted) return;
      if (loggedIn) {
        AuthState.setLoggedIn();
      } else {
        AuthState.setLoggedOut();
      }

      debugPrint("ℹ️ the user isLoggedIn? ${AuthState.isLoggedIn.value}");
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    isArabic = context.locale.languageCode == "ar";

    if (_pendingDeepLink != null) {
      final navigator = navigatorKey.currentState;
      if (navigator != null) {
        _handleAppLink(_pendingDeepLink!);
        _pendingDeepLink = null;
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _initDeepLinks() async {
    _appLinks = AppLinks();
    debugPrint("🔌 _initDeepLinks: created AppLinks instance");

    try {
      Uri? initialAppLink = await _appLinks.getInitialLink();
      debugPrint("🔌 _initDeepLinks: getInitialLink returned $initialAppLink");
      if (initialAppLink != null) {
        _handleAppLink(initialAppLink);
      }
    } catch (e) {
      debugPrint("error getting the initial app link: $e");
    }

    _appLinks.uriLinkStream.listen(
      (Uri uri) {
        debugPrint("🔔 uriLinkStream fired: $uri");
        _handleAppLink(uri);
      },
      onError: (e) {
        debugPrint("error while listening on the app link stream: $e");
      },
      onDone: () {
        debugPrint("🔴 uriLinkStream closed");
      }
    );
  }

  void _handleAppLink(Uri uri) {
    final uriStr = uri.toString();
    final now = DateTime.now();

    if (_lastDeepLinkUri == uriStr &&
        _lastDeepLinkAt != null &&
        now.difference(_lastDeepLinkAt!).inMilliseconds < 1500) {
      debugPrint("🔁 ignoring duplicate deep link within 1.5s: $uriStr");
      return;
    }
    _lastDeepLinkUri = uriStr;
    _lastDeepLinkAt = now;
    
    debugPrint("received deep link: $uri");
    debugPrint("deep link scheme: ${uri.scheme}");
    debugPrint("deep link host: ${uri.host}");
    debugPrint("deep link path: ${uri.path}");

    final navigator = navigatorKey.currentState;
    if (navigator == null) {
      debugPrint("the deep link is not ready to be navigated now");
      _pendingDeepLink = uri;
      return;
    }

    if (uri.host == "verify") {
      String? email = uri.queryParameters["email"];
      String? token = uri.queryParameters["token"];

      navigatorKey.currentState!.pushReplacementNamed(
        "/verify_email",
        arguments: {"email": email, "token": token, "delivery_id": DateTime.now().microsecondsSinceEpoch},
      );
    } else if (uri.host == "orders") {
      navigatorKey.currentState!.pushReplacementNamed("/orders");
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: context.locale,
      supportedLocales: context.supportedLocales,
      localizationsDelegates: context.localizationDelegates,
      navigatorKey: navigatorKey,
      navigatorObservers: [_routeChangeObserver], // ← register the observer
      theme: isPurpleMode ? buildPurpleTheme() : buildPinkTheme(),
      initialRoute: '/stores', ///instead of `home`

      // 1) Cold-start intercept — ignore any URI Flutter tries to use
      //    as the *initial* route. Always start on /stores.
      onGenerateInitialRoutes: (initialRoute) {
        debugPrint('🚫 onGenerateInitialRoutes ignored: $initialRoute');
        return <Route<dynamic>>[
          MaterialPageRoute(
            settings: const RouteSettings(name: '/stores'),
            builder: (context) => _buildMainScaffold(Stores(), context),
          ),
        ];
      },

      // 2) Warm-start intercept — handle every subsequent route resolution.
      //    This is where the mangled URI arrives on each warm-start intent.
      onGenerateRoute: (settings) {
        final name = settings.name ?? '';
        debugPrint('🛣️ onGenerateRoute: $name');

        // Drop the mangled URI silently.
        if (name.startsWith('/?')) {
          debugPrint('🚫 mangled URI — auto-popping');
          return PageRouteBuilder(
            settings: settings,
            opaque: false,
            barrierColor: Colors.transparent,
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
            pageBuilder: (context, _, __) => const SizedBox.shrink(),
          );
        }

        // Your supported routes.
        final builders = <String, WidgetBuilder>{
          '/stores':        (c) => _buildMainScaffold(Stores(), c),
          '/login':         (c) => _buildMainScaffold(Login(), c),
          '/register':      (c) => _buildMainScaffold(Register(), c),
          '/verify_email':  (c) => _buildMainScaffold(VerifyEmail(), c),
          '/verify_otp':    (c) => _buildMainScaffold(VerifyOTP(), c),
          '/orders':        (c) => _buildMainScaffold(Orders(), c),
          '/cart':          (c) => _buildMainScaffold(Cart(), c),
          '/wishlist':      (c) => _buildMainScaffold(Wishlist(), c),
          '/profile':       (c) => _buildMainScaffold(Profile(), c),
          '/store_products':(c) => _buildMainScaffold(StoreProducts(), c),
          '/product_details':(c)=> _buildMainScaffold(ProductDetails(), c),
          '/billing':       (c) => _buildMainScaffold(Billing(), c),
          '/order_details': (c) => _buildMainScaffold(OrderDetails(), c),
          '/forget_password':(c)=> _buildMainScaffold(ForgetPassword(), c),
          '/reset_password':(c) => _buildMainScaffold(ResetPassword(), c),
        };

        final b = builders[name];
        if (b != null) {
          return MaterialPageRoute(settings: settings, builder: b);
        }

        debugPrint('⚠️ truly unknown route "$name" → /stores');
        return MaterialPageRoute(
          settings: const RouteSettings(name: '/stores'),
          builder: (context) => _buildMainScaffold(Stores(), context),
        );
      },

      // 3) Belt-and-suspenders fallback. Should never fire now.
      onUnknownRoute: (settings) {
        debugPrint('⚠️ onUnknownRoute: ${settings.name}');
        return MaterialPageRoute(
          settings: const RouteSettings(name: '/stores'),
          builder: (context) => _buildMainScaffold(Stores(), context),
        );
      },
    );
  }

  // ================================================================
  // Logo
  // ================================================================

  Widget _buildLogo(BuildContext context) {
    bool isPurple = isPurpleMode;
    Color textPrimaryColor =
        isPurple ? PurpleTheme.textPrimary : PinkTheme.textPrimary;
    Color glamColor =
        isPurple ? AppColors.purpleBrandLogo : AppColors.pinkMain;
    Color goldColor = AppColors.goldMain;

    return GestureDetector(
      onTap: () {
        navigatorKey.currentState!.pushReplacementNamed("/stores");
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            "Glam",
            style: TextStyle(
              color: glamColor,
              fontWeight: FontWeight.w600,
              fontSize: 22,
              letterSpacing: -0.5,
              height: 1.0, // tighter line-box, less bottom slack
            ),
          ),
          const SizedBox(width: 8),
          Padding(
            // Push the dot down so it aligns with the visual baseline
            // rather than the (deeper) line-box bottom.
            padding: const EdgeInsets.only(bottom: 5),
            child: Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                color: goldColor,
                shape: BoxShape.circle
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            "Qena",
            style: TextStyle(
              color: textPrimaryColor,
              fontWeight: FontWeight.w500,
              fontSize: 22,
              letterSpacing: -0.5,
              height: 1.0,
            ),
          ),
        ],
      ),
    );
  }

  // ================================================================
  // Main scaffold
  // ================================================================

  Widget _buildMainScaffold(Widget body, BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: AuthState.isLoggedIn, 
      builder: (context, isLoggedIn, _){
        return Scaffold(
          appBar: _buildAppBar(),
          drawer: _buildDrawer(context, isLoggedIn),
            body: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                gradient: isPurpleMode
                    ? AppColors.purpleBackgroundGradient
                    : AppColors.pinkBackgroundGradient,
              ),
              child: SafeArea(
                top: false,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(
                          top: AppSpacing.xl,
                          left: AppSpacing.lg,
                          right: AppSpacing.lg,
                          bottom: AppSpacing.lg
                        ),
                        child: body,
                      ),
                      _buildFooter(context)
                    ],
                  ),
                ),
              ),
            ),
          bottomNavigationBar:
            Theme(
            data: Theme.of(context).copyWith(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent
            ),
            child: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              backgroundColor: isPurpleMode ? PurpleTheme.surface : PinkTheme.surface,
              selectedItemColor: isPurpleMode ? AppColors.purpleDark : AppColors.pinkMain,
              unselectedItemColor: textMuted,
              currentIndex: _currentNavigationIndex,
              onTap: (index) {
                setState(() {
                  _currentNavigationIndex = index;
                });

                switch (index) {
                  case 0:
                    navigatorKey.currentState!.pushReplacementNamed("/stores");
                    break;
                  case 1:
                    navigatorKey.currentState!.pushReplacementNamed("/stores");
                    break;
                  case 2:
                    navigatorKey.currentState!.pushReplacementNamed("/wishlist");
                    break;
                  case 3:
                    navigatorKey.currentState!.pushReplacementNamed("/cart");
                    break;
                }
              },
              items: [
                BottomNavigationBarItem(
                  icon: const Icon(Icons.home_outlined),
                  activeIcon: const Icon(Icons.home),
                  label: "home".tr(),
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.storefront_outlined),
                  activeIcon: const Icon(Icons.storefront),
                  label: "stores".tr(),
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.favorite_border),
                  activeIcon: const Icon(Icons.favorite),
                  label: "wishlist".tr(),
                ),
                BottomNavigationBarItem(
                  icon: Badge(
                    label: const Text("2"),
                    child: const Icon(Icons.shopping_bag_outlined),
                  ),
                  activeIcon: const Icon(Icons.shopping_bag),
                  label: "cart".tr(),
                ),
              ],
            )
          )
        );
      }
    );
  }

  // ================================================================
  // AppBar
  // ================================================================

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Builder(
        builder: (context) {
          return GestureDetector(
            onTap: () {
              navigatorKey.currentState!.pushReplacementNamed("/stores");
              // No manual selectedDrawerTile update needed — RouteAware handles it.
            },
            child: _buildLogo(context),
          );
        },
      ),
      titleSpacing: 0,
      backgroundColor: isPurpleMode ? PurpleTheme.surface : PinkTheme.surface,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isPurpleMode
            ? Brightness.light
            : Brightness.dark,
        statusBarBrightness: isPurpleMode ? Brightness.dark : Brightness.light,
      ),
      actionsPadding: const EdgeInsets.only(right: 3),
      iconTheme: IconThemeData(
        color: isPurpleMode ? AppColors.purpleDark : AppColors.pinkMain,
        size: 20,
      ),
      actionsIconTheme: IconThemeData(
        color: isPurpleMode ? AppColors.purpleDark : AppColors.pinkMain,
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
                    Locale newLocale = isArabic
                        ? const Locale("en")
                        : const Locale("ar");
                    context.setLocale(newLocale);
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      isArabic ? "EN" : "AR",
                      style: TextStyle(
                        color: isPurpleMode
                            ? AppColors.purpleDark
                            : AppColors.pinkMain,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, "/cart");
                    // No manual selectedDrawerTile update needed.
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(10),
                    child: Icon(Icons.shopping_cart_outlined, size: 17),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  // ================================================================
  // Drawer
  // ================================================================

  Widget _buildDrawer(BuildContext context, bool isLoggedIn) {
    final isPurple = isPurpleMode;
    AuthService authService = AuthService();
    ApiClient apiClient = ApiClient();

    final backgroundColor = isPurple
        ? PurpleTheme.sidebarBackground
        : PinkTheme.sidebarBackground;
    final textPrimary =
        isPurple ? PurpleTheme.textPrimary : PinkTheme.textPrimary;
    final textSecondary =
        isPurple ? PurpleTheme.textSecondary : PinkTheme.textSecondary;

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
                  GestureDetector(
                    onTap: () {
                      navigatorKey.currentState!
                          .pushReplacementNamed("/stores");
                    },
                    child: _buildLogo(context),
                  ),
                  IconButton(
                    onPressed: () => navigatorKey.currentState!.pop(),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: Icon(Icons.close, color: textPrimary, size: 22),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Colors.transparent),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                children: [
                  if (!isLoggedIn)
                    DrawerListTile(
                      title: 'drawer_login'.tr(),
                      icon: const Icon(Icons.login, size: 18),
                      onTap: () => navigatorKey.currentState!
                          .pushReplacementNamed("/login"),
                      isSelected: selectedDrawerTile == "login",
                      isPurpleMode: isPurple,
                    ),

                  DrawerListTile(
                    title: 'drawer_register'.tr(),
                    icon: const Icon(Icons.person_add_alt, size: 18),
                    onTap: () => navigatorKey.currentState!
                        .pushReplacementNamed("/register"),
                    isSelected: selectedDrawerTile == "register",
                    isPurpleMode: isPurple,
                  ),

                  const SizedBox(height: 8),

                  if (!isLoggedIn)
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
                    icon: const FaIcon(FontAwesomeIcons.cube, size: 18),
                    onTap: () => navigatorKey.currentState!
                        .pushReplacementNamed("/orders"),
                    isSelected: isLoggedIn && selectedDrawerTile == "orders",
                    isPurpleMode: isPurple,
                    enabled: isLoggedIn,
                  ),

                  DrawerListTile(
                    title: 'drawer_profile'.tr(),
                    icon: const Icon(Icons.person, size: 18),
                    onTap: () => navigatorKey.currentState!
                        .pushReplacementNamed("/profile"),
                    isSelected: isLoggedIn && selectedDrawerTile == "profile",
                    isPurpleMode: isPurple,
                    enabled: isLoggedIn,
                  ),

                  DrawerListTile(
                    title: 'drawer_logout'.tr(),
                    icon: const Icon(Icons.logout, size: 18),
                    onTap: () async {
                      try {
                        final successMessage = await authService.logout();
                        if (!context.mounted) return;
                        showSnackBarCustom(
                          message: LogoutMessages.getLocalizedMessage(successMessage),
                          isSuccess: true,
                          isPurpleMode: isPurple,
                          context: context,
                        );
                        setState(() => isLoggedIn = false);
                        navigatorKey.currentState!.pop();
                        navigatorKey.currentState!.pushReplacementNamed("/login");
                      } catch (ex) {
                        final errorMessage =
                            apiClient.extractResponseMessage(ex.toString());
                        if (!context.mounted) return;
                        showSnackBarCustom(
                          message: LogoutMessages.getLocalizedMessage(errorMessage),
                          isSuccess: false,
                          isPurpleMode: isPurple,
                          context: context,
                        );
                      }
                    },
                    isSelected: false,
                    isPurpleMode: isPurple,
                    enabled: isLoggedIn,
                    isDestructive: true,     // ← red fg + error-subtle hover
                  ),

                  const SizedBox(height: 8),
                ],
              ),
            ),
            // Drawer Footer with Theme Toggle
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: isPurple ? PurpleTheme.border : PinkTheme.border,
                    width: 0.5,
                  ),
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _toggleTheme,
                  borderRadius: BorderRadius.circular(AppRadii.pill),
                  highlightColor: AppShadows.drawerActiveBg(isPurple: isPurple),
                  splashColor: AppShadows.drawerActiveBg(isPurple: isPurple),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: isPurple
                          ? PurpleTheme.inputBackground   // matches --bg-input
                          : PinkTheme.inputBackground,
                      borderRadius: BorderRadius.circular(AppRadii.pill),
                      border: Border.all(
                        color: isPurple
                            ? PurpleTheme.border        // matches --border-subtle
                            : PinkTheme.border,
                        width: 0.7,
                      ),
                      // Reuse the shared input shadow so it matches web `--shadow-card` feel.
                      boxShadow: AppShadows.inputSoft(isPurple: isPurple),
                    ),
                    child: Row(
                      children: [
                        // ── Preview swatch (shows TARGET theme) ──
                        Container(
                          width: 25,
                          height: 25,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: isPurple
                                  ? [AppColors.pinkMain, Colors.white]
                                  : [AppColors.purpleDark, Colors.black],
                              stops: const [0.5, 0.5],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: (isPurple
                                        ? AppColors.pinkMain
                                        : AppColors.purpleDark)
                                    .withValues(alpha: 0.35),
                                blurRadius: 6,
                                spreadRadius: 0.5,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 12),

                        Expanded(
                          child: Text(
                            isPurple
                                ? "switch_to_pink_theme".tr()
                                : "switch_to_purple_theme".tr(),
                            style: TextStyle(
                              color: isPurple
                                  ? PurpleTheme.textSecondary
                                  : PinkTheme.textSecondary,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),

                        Icon(
                          Icons.swap_horiz_rounded,
                          size: 18,
                          color: (isPurple
                                  ? PurpleTheme.textMuted
                                  : PinkTheme.textMuted)
                              .withValues(alpha: 0.7),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleTheme() async {
    final newMode = !isPurpleMode;

    // Persist first so a restart restores the user's choice.
    await storage.write("theme", newMode);

    if (!mounted) return;

    setState(() {
      isPurpleMode = newMode;
    });
  }

  Widget _buildFooter(BuildContext context) {
    bool isPurple = isPurpleMode;

    Color backgroundColor = isPurple
        ? PurpleTheme.sidebarBackground
        : PinkTheme.surfaceVariant;
    Color titleColor =
        isPurple ? PurpleTheme.textPrimary : PinkTheme.textPrimary;
    Color textColor =
        isPurple ? PurpleTheme.textSecondary : PinkTheme.textSecondary;
    Color dividerColor = isPurple ? PurpleTheme.border : PinkTheme.border;
    Color iconColor =
        isPurple ? PurpleTheme.textPrimary : PinkTheme.textPrimary;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(right: 16, top: 24, left: 16, bottom: 24),
      color: backgroundColor,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildLogo(context),
              const SizedBox(height: 10),
              Text(
                "footer_description".tr(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.w400,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildSocialLink(
                    icon: FontAwesomeIcons.youtube,
                    url: "https://youtube.com",
                    isPurple: isPurple,
                    iconColor: iconColor,
                  ),
                  const SizedBox(width: 10),
                  _buildSocialLink(
                    icon: FontAwesomeIcons.xTwitter,
                    url: "https://x.com",
                    isPurple: isPurple,
                    iconColor: iconColor,
                  ),
                  const SizedBox(width: 10),
                  _buildSocialLink(
                    icon: FontAwesomeIcons.instagram,
                    url: "https://instagram.com",
                    isPurple: isPurple,
                    iconColor: iconColor,
                  ),
                  const SizedBox(width: 10),
                  _buildSocialLink(
                    icon: FontAwesomeIcons.github,
                    url: "https://github.com",
                    isPurple: isPurple,
                    iconColor: iconColor,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 25),
          Divider(color: dividerColor),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildFooterTitle("quick_links_title".tr(), titleColor),
                    const SizedBox(height: 12),
                    _buildQuickLink("stores".tr(),
                        "https://qenaglam.com/stores", isPurple),
                    _buildQuickLink("about_us".tr(),
                        "https://qenaglam.com/about", isPurple),
                    _buildQuickLink("contact_us".tr(),
                        "https://qenaglam.com/contact", isPurple),
                    _buildQuickLink("faq".tr(),
                        "https://qenaglam.com/faq", isPurple),
                    _buildQuickLink("privacy_policy".tr(),
                        "https://qenaglam.com/privacy", isPurple),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildFooterTitle("contact_us_title".tr(), titleColor),
                    const SizedBox(height: 12),
                    _buildContactLink(
                      icon: FontAwesomeIcons.whatsapp,
                      text: "footer_phone_number".tr(),
                      url: "https://wa.me/201286264392",
                      isPurple: isPurple,
                      textColor: textColor,
                    ),
                    _buildContactLink(
                      icon: FontAwesomeIcons.envelope,
                      text: "footer_email".tr(),
                      url: "mailto:info@qenaglam.com",
                      isPurple: isPurple,
                      textColor: textColor,
                    ),
                    _buildContactLink(
                      icon: FontAwesomeIcons.locationDot,
                      text: "footer_location".tr(),
                      url: "https://maps.google.com/?q=Qena",
                      isPurple: isPurple,
                      textColor: textColor,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          FaIcon(
                            FontAwesomeIcons.clock,
                            size: 14,
                            color: titleColor,
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              "footer_working_hours".tr(),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: textColor,
                                fontSize: 11,
                                height: 1.3,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Divider(color: dividerColor),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Link(
                text: "privacy_policy".tr(),
                url: "https://qenaglam.com/privacy",
                isPurpleMode: isPurple,
                color: textColor,
                fontSize: 14
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                height: 10,
                width: 1,
                color: textColor,
              ),
              Link(
                text: "terms_conditions".tr(),
                url: "https://qenaglam.com/terms",
                isPurpleMode: isPurple,
                color: textColor,
                fontSize: 14
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            "footer_copyright".tr(),
            style: TextStyle(
              color: textColor.withValues(alpha: 0.7),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  // ================================================================
  // Footer helper widgets
  // ================================================================

  Widget _buildSocialLink({
    required FaIconData icon,
    required String url,
    required bool isPurple,
    required Color iconColor,
  }) {
    return Container(
      width: 36,
      height: 36,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isPurple ? PurpleTheme.surface : PinkTheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Link(
        isPurpleMode: isPurple,
        icon: FaIcon(icon, size: 18, color: iconColor),
        url: url,
      ),
    );
  }

  Widget _buildFooterTitle(String title, Color color) {
    return Text(
      title,
      style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14),
    );
  }

  Widget _buildQuickLink(String text, String url, bool isPurple) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Link(
        text: text,
        url: url,
        isPurpleMode: isPurple,
        color: isPurple ? PurpleTheme.textSecondary : PinkTheme.textSecondary,
        fontSize: 10,
      ),
    );
  }

  Widget _buildContactLink({
    required FaIconData icon,
    required String text,
    required String url,
    required bool isPurple,
    required Color textColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Link(
            isPurpleMode: isPurple,
            icon: FaIcon(
              icon,
              size: 14,
              color: isPurple ? PurpleTheme.textPrimary : PinkTheme.textPrimary,
            ),
            url: url,
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Link(
              text: text,
              url: url,
              isPurpleMode: isPurple,
              color: textColor,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}