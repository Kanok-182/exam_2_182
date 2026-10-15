import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../controllers/charger_controller.dart';
import '../models/charger_model.dart';
import '../models/user_model.dart';
import '../utils/ui.dart';
import 'edit_screen.dart';

/// แท็บ 2 : แผงควบคุมหัวจ่าย (Real-time ผ่าน StreamBuilder)
/// Admin เห็นปุ่ม Edit/Delete | Operator เห็นรายการอย่างเดียว
class DisplayScreen extends StatelessWidget {
  final AppUser user;
  DisplayScreen({super.key, required this.user});

  final _controller = ChargerController();

  Future<void> _confirmDelete(BuildContext context, Charger c) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        icon: const Icon(Icons.warning_amber_rounded,
            color: AppColors.danger, size: 40),
        title: const Text('ยืนยัน Decommission'),
        content: Text(
            'ต้องการปิดหัวจ่าย "${c.chargerId}" และลบออกจากระบบใช่หรือไม่?\nการลบไม่สามารถย้อนกลับได้'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('ยกเลิก')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('ลบ'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await _controller.deleteCharger(c.id, user);
      if (context.mounted) showSnack(context, 'ลบ ${c.chargerId} เรียบร้อย');
    } catch (e) {
      if (context.mounted) showSnack(context, '$e', error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _controller.chargersStream(),
      builder: (context, snap) {
        if (snap.hasError) {
          return Center(child: Text('เกิดข้อผิดพลาด: ${snap.error}'));
        }
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final chargers = snap.data!.docs.map(Charger.fromDoc).toList();
        if (chargers.isEmpty) {
          return const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.ev_station_outlined, size: 72, color: Colors.black26),
                SizedBox(height: 8),
                Text('ยังไม่มีหัวชาร์จ ไปที่แท็บ "บันทึกข้อมูล"',
                    style: TextStyle(color: Colors.black54)),
              ],
            ),
          );
        }
        final totalKw = chargers.fold<double>(0, (s, c) => s + c.powerKw);

        return Column(
          children: [
            _StatsHeader(count: chargers.length, totalKw: totalKw),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
                itemCount: chargers.length,
                itemBuilder: (context, i) => _chargerCard(context, chargers[i]),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _chargerCard(BuildContext context, Charger c) {
    return Card(
      elevation: 1.5,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
        child: Column(
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                radius: 30,
                backgroundColor: AppColors.green,
                foregroundColor: Colors.white,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(formatNum(c.powerKw),
                        style: const TextStyle(
                            fontWeight: FontWeight.w800, fontSize: 16)),
                    const Text('kW', style: TextStyle(fontSize: 10)),
                  ],
                ),
              ),
              title: Text(c.chargerId,
                  style: const TextStyle(
                      fontWeight: FontWeight.w800, fontSize: 16)),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      const Icon(Icons.location_on_outlined, size: 15),
                      const SizedBox(width: 4),
                      Expanded(child: Text(c.location)),
                    ]),
                    const SizedBox(height: 2),
                    Row(children: [
                      const Icon(Icons.payments_outlined, size: 15),
                      const SizedBox(width: 4),
                      Text('${formatNum(c.tariff)} THB/kWh',
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                    ]),
                  ],
                ),
              ),
            ),
            if (c.onPeakRate != null || c.offPeakRate != null)
              Align(
                alignment: Alignment.centerLeft,
                child: Wrap(
                  spacing: 8,
                  children: [
                    if (c.onPeakRate != null)
                      _rateChip('On-Peak ${formatNum(c.onPeakRate!)}',
                          Colors.orange),
                    if (c.offPeakRate != null)
                      _rateChip('Off-Peak ${formatNum(c.offPeakRate!)}',
                          Colors.blue),
                  ],
                ),
              ),
            const Divider(height: 14),
            // RBAC : Operator ไม่เห็นปุ่ม Edit / Delete เลย
            if (user.isAdmin)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => EditScreen(charger: c, user: user)),
                    ),
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('Edit'),
                  ),
                  TextButton.icon(
                    style: TextButton.styleFrom(
                        foregroundColor: AppColors.danger),
                    onPressed: () => _confirmDelete(context, c),
                    icon: const Icon(Icons.delete_outline_rounded),
                    label: const Text('Delete'),
                  ),
                ],
              )
            else
              const Align(
                alignment: Alignment.centerRight,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.lock_outline, size: 14, color: Colors.black45),
                    SizedBox(width: 4),
                    Text('ดูได้อย่างเดียว (Operator)',
                        style: TextStyle(fontSize: 12, color: Colors.black45)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _rateChip(String text, MaterialColor color) => Chip(
        visualDensity: VisualDensity.compact,
        backgroundColor: color.shade50,
        side: BorderSide(color: color.shade200),
        label: Text(text, style: TextStyle(fontSize: 12, color: color.shade800)),
      );
}

class _StatsHeader extends StatelessWidget {
  final int count;
  final double totalKw;
  const _StatsHeader({required this.count, required this.totalKw});

  @override
  Widget build(BuildContext context) {
    Widget item(IconData i, String v, String l) => Expanded(
          child: Column(
            children: [
              Icon(i, color: Colors.white),
              Text(v,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800)),
              Text(l,
                  style: const TextStyle(color: Colors.white70, fontSize: 12)),
            ],
          ),
        );
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        gradient: appGradient,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          item(Icons.ev_station_rounded, '$count', 'หัวจ่ายทั้งหมด'),
          item(Icons.bolt_rounded, formatNum(totalKw), 'กำลังไฟรวม (kW)'),
        ],
      ),
    );
  }
}
