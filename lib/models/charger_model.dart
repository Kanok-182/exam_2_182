import 'package:cloud_firestore/cloud_firestore.dart';

/// Collection `chargers` : หัวชาร์จ EV
class Charger {
  final String id; // Document ID
  final String chargerId;
  final String location;
  final String engineerEmail;
  final double powerKw;
  final double tariff; // THB/kWh (อัตราปกติ)
  final double? onPeakRate; // กำหนดตอน Edit
  final double? offPeakRate; // กำหนดตอน Edit
  final String createdBy;

  const Charger({
    this.id = '',
    required this.chargerId,
    required this.location,
    required this.engineerEmail,
    required this.powerKw,
    required this.tariff,
    this.onPeakRate,
    this.offPeakRate,
    this.createdBy = '',
  });

  factory Charger.fromDoc(DocumentSnapshot<Map<String, dynamic>> d) {
    final m = d.data() ?? {};
    return Charger(
      id: d.id,
      chargerId: m['chargerId'] ?? '',
      location: m['location'] ?? '',
      engineerEmail: m['engineerEmail'] ?? '',
      powerKw: (m['powerKw'] as num?)?.toDouble() ?? 0,
      tariff: (m['tariff'] as num?)?.toDouble() ?? 0,
      onPeakRate: (m['onPeakRate'] as num?)?.toDouble(),
      offPeakRate: (m['offPeakRate'] as num?)?.toDouble(),
      createdBy: m['createdBy'] ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
        'chargerId': chargerId,
        'location': location,
        'engineerEmail': engineerEmail,
        'powerKw': powerKw,
        'tariff': tariff,
        'onPeakRate': onPeakRate,
        'offPeakRate': offPeakRate,
      };
}
