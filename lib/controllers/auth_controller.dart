import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';

class AuthController {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  /// true ระหว่างสร้างบัญชีทดสอบ (กันหน้าจอกระพริบ)
  static final ValueNotifier<bool> seeding = ValueNotifier(false);

  Stream<User?> authChanges() => _auth.authStateChanges();

  /// อ่าน Role แบบ Real-time จาก users/{uid}
  Stream<AppUser?> userStream(String uid) =>
      _db.collection('users').doc(uid).snapshots().map(
            (s) => s.exists ? AppUser.fromMap(s.data()!) : null,
          );

  Future<void> signIn(String email, String password) =>
      _auth.signInWithEmailAndPassword(
          email: email.trim(), password: password.trim());

  Future<void> signOut() => _auth.signOut();

  /// สร้างบัญชีทดสอบ admin@test.com / operator@test.com (รหัส 123456)
  /// พร้อมเอกสารใน Collection users (กดครั้งเดียวตอนเตรียมสอบ)
  Future<void> seedTestAccounts() async {
    seeding.value = true;
    try {
      const accounts = [
        ['admin@test.com', 'Admin EVFleet', 'admin'],
        ['operator@test.com', 'Operator EVFleet', 'operator'],
      ];
      for (final a in accounts) {
        UserCredential cred;
        try {
          cred = await _auth.createUserWithEmailAndPassword(
              email: a[0], password: '123456');
        } on FirebaseAuthException catch (e) {
          if (e.code == 'email-already-in-use') {
            cred = await _auth.signInWithEmailAndPassword(
                email: a[0], password: '123456');
          } else {
            rethrow;
          }
        }
        final uid = cred.user!.uid;
        await _db.collection('users').doc(uid).set(
              AppUser(uid: uid, name: a[1], email: a[0], role: a[2]).toMap(),
              SetOptions(merge: true),
            );
        await _auth.signOut();
      }
    } finally {
      seeding.value = false;
    }
  }

  static String thaiError(Object e) {
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'invalid-credential':
        case 'wrong-password':
        case 'user-not-found':
          return 'อีเมลหรือรหัสผ่านไม่ถูกต้อง';
        case 'invalid-email':
          return 'รูปแบบอีเมลไม่ถูกต้อง';
        case 'user-disabled':
          return 'บัญชีนี้ถูกปิดการใช้งาน';
        case 'network-request-failed':
          return 'ไม่มีอินเทอร์เน็ต กรุณาตรวจสอบการเชื่อมต่อ';
        case 'operation-not-allowed':
          return 'ยังไม่ได้เปิด Email/Password ใน Firebase Console';
        case 'too-many-requests':
          return 'ลองใหม่หลายครั้งเกินไป กรุณารอสักครู่';
      }
      return 'เกิดข้อผิดพลาด: ${e.code}';
    }
    return e.toString();
  }
}
