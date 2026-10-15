import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/charger_model.dart';
import '../models/user_model.dart';

class ChargerController {
  final _col = FirebaseFirestore.instance.collection('chargers');

  /// READ : Real-time สำหรับ StreamBuilder
  Stream<QuerySnapshot<Map<String, dynamic>>> chargersStream() =>
      _col.orderBy('createdAt', descending: true).snapshots();

  /// CREATE : ทั้ง Admin และ Operator ทำได้
  Future<void> addCharger(Charger c, AppUser by) async {
    await _col.add({
      ...c.toMap(),
      'createdBy': by.email,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// UPDATE : เฉพาะ Admin (ตรวจซ้ำที่ชั้น Controller)
  Future<void> updateCharger(String docId, Charger c, AppUser by) async {
    _requireAdmin(by);
    await _col.doc(docId).update({
      ...c.toMap(),
      'updatedBy': by.email,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// DELETE : เฉพาะ Admin
  Future<void> deleteCharger(String docId, AppUser by) async {
    _requireAdmin(by);
    await _col.doc(docId).delete();
  }

  void _requireAdmin(AppUser u) {
    if (!u.isAdmin) throw Exception('สิทธิ์ไม่เพียงพอ: ต้องเป็น Admin เท่านั้น');
  }
}
