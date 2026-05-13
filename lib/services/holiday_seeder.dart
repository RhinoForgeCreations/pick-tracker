import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/non_work_day.dart';
import '../repositories/non_work_day_repository.dart';

class HolidaySeeder {
  final NonWorkDayRepository repo;
  HolidaySeeder(this.repo);

  Future<int> seedVic2026() async {
    final raw = await rootBundle.loadString('assets/data/vic_holidays_2026.json');
    final List items = jsonDecode(raw);
    int n = 0;
    for (final h in items) {
      await repo.upsert(NonWorkDay(
        date: h['date'] as String,
        reason: 'public_holiday',
        note: h['name'] as String,
      ));
      n++;
    }
    return n;
  }
}
