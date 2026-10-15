import 'package:flutter/material.dart';

import '../controllers/auth_controller.dart';
import '../models/user_model.dart';
import '../utils/ui.dart';
import 'display_screen.dart';
import 'form_screen.dart';

/// หน้าหลัก : TabBar 2 แท็บ (บันทึกข้อมูล / รายการข้อมูล) + Sign Out บน AppBar
class HomeScreen extends StatelessWidget {
  final AppUser user;
  const HomeScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          foregroundColor: Colors.white,
          backgroundColor: Colors.transparent,
          elevation: 0,
          flexibleSpace: Container(
              decoration: const BoxDecoration(gradient: appGradient)),
          title: const Row(
            children: [
              Icon(Icons.ev_station_rounded),
              SizedBox(width: 8),
              Text('EVFleet', style: TextStyle(fontWeight: FontWeight.w800)),
            ],
          ),
          actions: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 14),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: user.isAdmin
                    ? Colors.amber.shade600
                    : Colors.white.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                      user.isAdmin
                          ? Icons.admin_panel_settings
                          : Icons.engineering,
                      size: 16,
                      color: user.isAdmin ? Colors.black87 : Colors.white),
                  const SizedBox(width: 4),
                  Text(
                    user.isAdmin ? 'Admin' : 'Operator',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: user.isAdmin ? Colors.black87 : Colors.white),
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Sign Out',
              icon: const Icon(Icons.logout_rounded),
              onPressed: () => AuthController().signOut(),
            ),
            const SizedBox(width: 4),
          ],
          bottom: const TabBar(
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(icon: Icon(Icons.edit_note_rounded), text: 'บันทึกข้อมูล'),
              Tab(icon: Icon(Icons.dashboard_rounded), text: 'แผงควบคุมหัวจ่าย'),
            ],
          ),
        ),
        body: Builder(
          builder: (context) {
            final tab = DefaultTabController.of(context);
            return TabBarView(
              children: [
                FormScreen(user: user, onSaved: () => tab.animateTo(1)),
                DisplayScreen(user: user),
              ],
            );
          },
        ),
      ),
    );
  }
}
