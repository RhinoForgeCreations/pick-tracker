class Order {
  final int? id;
  final int shiftId;
  final int seq;
  final int cases;
  final DateTime startedAt;
  final DateTime? endedAt;
  final int? durationMs;
  final bool isOutlier;
  final bool edited;

  Order({
    this.id, required this.shiftId, required this.seq, required this.cases,
    required this.startedAt, this.endedAt, this.durationMs,
    required this.isOutlier, required this.edited,
  });

  Map<String, Object?> toMap() => {
    if (id != null) 'id': id,
    'shift_id': shiftId, 'seq': seq, 'cases': cases,
    'started_at': startedAt.toIso8601String(),
    'ended_at': endedAt?.toIso8601String(),
    'duration_ms': durationMs,
    'is_outlier': isOutlier ? 1 : 0,
    'edited': edited ? 1 : 0,
  };

  factory Order.fromMap(Map<String, Object?> m) => Order(
    id: m['id'] as int?,
    shiftId: m['shift_id'] as int,
    seq: m['seq'] as int,
    cases: m['cases'] as int,
    startedAt: DateTime.parse(m['started_at'] as String),
    endedAt: m['ended_at'] == null ? null : DateTime.parse(m['ended_at'] as String),
    durationMs: m['duration_ms'] as int?,
    isOutlier: (m['is_outlier'] as int) == 1,
    edited: (m['edited'] as int) == 1,
  );
}
