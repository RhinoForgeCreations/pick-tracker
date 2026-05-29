class BreakPeriod {
  final int? id;
  final int shiftId;
  // Always UTC.
  final DateTime startedAt;
  final DateTime? endedAt;

  BreakPeriod({
    this.id,
    required this.shiftId,
    required this.startedAt,
    this.endedAt,
  });

  int durationMs(DateTime asOf) =>
    (endedAt ?? asOf).difference(startedAt).inMilliseconds;

  Map<String, Object?> toMap() => {
    if (id != null) 'id': id,
    'shift_id': shiftId,
    'started_at': startedAt.toIso8601String(),
    'ended_at': endedAt?.toIso8601String(),
  };

  factory BreakPeriod.fromMap(Map<String, Object?> m) => BreakPeriod(
    id: m['id'] as int?,
    shiftId: m['shift_id'] as int,
    startedAt: DateTime.parse(m['started_at'] as String),
    endedAt: m['ended_at'] == null ? null : DateTime.parse(m['ended_at'] as String),
  );
}
