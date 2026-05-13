class NonWorkDay {
  final String date;
  final String reason;
  final String? note;
  const NonWorkDay({required this.date, required this.reason, this.note});

  Map<String, Object?> toMap() => {'date': date, 'reason': reason, 'note': note};

  factory NonWorkDay.fromMap(Map<String, Object?> m) => NonWorkDay(
    date: m['date'] as String,
    reason: m['reason'] as String,
    note: m['note'] as String?,
  );
}
