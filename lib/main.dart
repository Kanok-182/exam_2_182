import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'controllers/auth_controller.dart';
import 'models/user_model.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'utils/ui.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const EVFleetApp());
}

class EVFleetApp extends StatelessWidget {
  const EVFleetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EVFleet',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.green),
        scaffoldBackgroundColor: AppColors.bg,
      ),
      home: const FirebaseBootstrap(),
    );
  }
}

/// Initialize Firebase ผ่าน FutureBuilder (อ่านค่าจาก google-services.json)
class FirebaseBootstrap extends StatefulWidget {
  const FirebaseBootstrap({super.key});

  @override
  State<FirebaseBootstrap> createState() => _FirebaseBootstrapState();
}

class _FirebaseBootstrapState extends State<FirebaseBootstrap> {
  final Future<FirebaseApp> _init = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<FirebaseApp>(
      future: _init,
      builder: (context, snap) {
        if (snap.hasError) {
          return Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'เชื่อมต่อ Firebase ไม่สำเร็จ\n${snap.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }
        if (snap.connectionState == ConnectionState.done) {
          return const AuthGate();
        }
        return const SplashScreen();
      },
    );
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: appGradient),
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.ev_station_rounded, size: 72, color: Colors.white),
              SizedBox(height: 20),
              CircularProgressIndicator(color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}

/// ตัดสินใจว่าจะแสดง Login หรือ Home ตามสถานะผู้ใช้ + Role จาก Firestore
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = AuthController();
    return ValueListenableBuilder<bool>(
      valueListenable: AuthController.seeding,
      builder: (context, seeding, _) {
        if (seeding) return const LoginScreen();
        return StreamBuilder<User?>(
          stream: auth.authChanges(),
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const SplashScreen();
            }
            final user = snap.data;
            if (user == null) return const LoginScreen();

            return StreamBuilder<AppUser?>(
              stream: auth.userStream(user.uid),
              builder: (context, us) {
                if (us.connectionState == ConnectionState.waiting) {
                  return const SplashScreen();
                }
                final appUser = us.data;
                if (appUser == null) {
                  return _NoProfile(onSignOut: auth.signOut);
                }
                return HomeScreen(user: appUser);
              },
            );
          },
        );
      },
    );
  }
}

class _NoProfile extends StatelessWidget {
  final VoidCallback onSignOut;
  const _NoProfile({required this.onSignOut});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.person_off_rounded, size: 64),
              const SizedBox(height: 12),
              const Text(
                'ไม่พบข้อมูลผู้ใช้ใน Collection users\n(ต้องมีเอกสาร users/{uid} พร้อม role)',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton(onPressed: onSignOut, child: const Text('Sign Out')),
            ],
          ),
        ),
      ),
    );
  }
}
