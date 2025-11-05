import 'package:flutter/material.dart';
import 'l10n/localization.dart';
// imports cleaned
import 'package:flutter_vite/screens/diagnosis_screen.dart';
import 'package:flutter_vite/screens/map_screen.dart';
import 'package:flutter_vite/screens/emergency_screen.dart';
import 'package:flutter_vite/screens/support_chat_screen.dart';
import 'package:flutter_vite/screens/settings_screen.dart';
import 'package:flutter_vite/screens/sign_in_screen.dart';
import 'services/auth_service.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'widgets/lumi_overlay.dart';
import 'screens/wellness_screen.dart';
// import 'widgets/lumi_widget.dart';
import 'lumi/lumi_brain.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AuthService.instance.initialize();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale? _locale;
  void setLocale(Locale? l) => setState(() => _locale = l);

  int _tab = 0;

  void _handleCommand(String cmd) {
    switch (cmd) {
      case 'emergency_call':
        setState(() => _tab = 3);
        break;
      case 'map_pharmacy':
      case 'map_hospital':
        setState(() => _tab = 2);
        break;
      case 'diagnose':
        setState(() => _tab = 1);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final overlayController = LumiOverlayController();
    LumiOverlay.init(overlayController);
    return MaterialApp(
      title: 'VITA',
      locale: _locale,
      supportedLocales: L.supported,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.cyan),
        useMaterial3: true,
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: ZoomPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
            TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
            TargetPlatform.windows: ZoomPageTransitionsBuilder(),
            TargetPlatform.linux: ZoomPageTransitionsBuilder(),
          },
        ),
      ),
      builder: (context, child) => Stack(
        children: [
          if (child != null) child,
          GlobalLumiOverlay(controller: overlayController),
        ],
      ),
      home: StreamBuilder<String?>(
        stream: AuthService.instance.userIdStream,
        builder: (context, snap) {
          if (!snap.hasData) {
            // Hide Lumi overlay on auth screens to avoid intercepting taps
            LumiOverlay.set(visible: false);
            return const SignInScreen();
          }
          // Show Lumi overlay once authenticated
          LumiOverlay.set(visible: true);
          // Initialize greeting without holding context across async gap
          // Safe: schedule after build
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            await LumiBrain.instance.init();
            LumiBrain.instance.onAppStart();
          });
          return Scaffold(
            body: SafeArea(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 280),
                child: _buildBody(key: ValueKey(_tab)),
              ),
            ),
            bottomNavigationBar: _buildBottomBar(),
          );
        },
      ),
    );
  }

  Widget _buildBody({Key? key}) {
    switch (_tab) {
      case 0:
        return HomeScreen(key: key, onCommand: _handleCommand);
      case 1:
        return DiagnosisScreen(key: key);
      case 2:
        return MapScreen(key: key);
      case 3:
        return EmergencyScreen(key: key);
      case 4:
        return WellnessScreen(key: key);
      case 5:
        return SupportChatScreen(key: key);
      case 6:
        return SettingsScreen(key: key, onSetLocale: setLocale);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildBottomBar() {
    final l = L.of(context);
    return NavigationBar(
      selectedIndex: _tab,
      onDestinationSelected: (i) {
        setState(() => _tab = i);
        // Move LUMI depending on tab to create "walking" effect
        final anchors = [
          const Offset(0.85, 0.75), // Home
          const Offset(0.2, 0.75), // Diagnose
          const Offset(0.15, 0.8), // Map
          const Offset(0.8, 0.2), // Emergency
          const Offset(0.2, 0.2), // Wellness
          const Offset(0.85, 0.25), // Support
          const Offset(0.5, 0.85), // Settings
        ];
        LumiOverlay.controller?.animateTo(
          anchors[i.clamp(0, anchors.length - 1)],
        );
        // Lumi reactions per destination
        switch (i) {
          case 0:
            LumiBrain.instance.onHomeOpen();
            break;
          case 1:
            LumiBrain.instance.onDiagnoseStart();
            break;
          case 2:
            LumiBrain.instance.onMapOpen();
            break;
          case 3:
            LumiBrain.instance.onEmergency();
            break;
          case 4:
            LumiBrain.instance.onWellnessOpen();
            break;
          case 5:
            LumiBrain.instance.onSupportOpen();
            break;
          case 6:
            LumiBrain.instance.onSettingsOpen();
            break;
        }
      },
      destinations: [
        NavigationDestination(
          icon: const Icon(Icons.auto_awesome),
          label: l.tabHome,
        ),
        NavigationDestination(
          icon: const Icon(Icons.healing),
          label: l.tabDiagnose,
        ),
        NavigationDestination(icon: const Icon(Icons.map), label: l.tabMap),
        NavigationDestination(
          icon: const Icon(Icons.sos),
          label: l.tabEmergency,
        ),
        NavigationDestination(
          icon: const Icon(Icons.fitness_center),
          label: l.tabWellness,
        ),
        NavigationDestination(
          icon: const Icon(Icons.chat_bubble),
          label: l.tabSupport,
        ),
        NavigationDestination(
          icon: const Icon(Icons.settings),
          label: l.tabSettings,
        ),
      ],
    );
  }
}
