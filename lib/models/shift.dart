class Shift {
  final int? id;
  final DateTime startedAt;
  final DateTime? endedAt;
  final String? endedReason;
  final String date;
  final int target;
  final int floor;
  final String? notes;

  Shift({
    this.id, required this.startedAt, this.endedAt, this.endedReason,
    required this.date, required this.target, required this.floor, this.notes,
  });

  Map<String, Object?> toMap() => {
    if (id != null) 'id': id,
    'started_at': startedAt.toIso8601String(),
    'ended_at': endedAt?.toIso8601String(),
    'ended_reason': endedReason,
    'date': date, 'target': target, 'floor': floor, 'notes': notes,
  };

  factory Shift.fromMap(Map<String, Object?> m) => Shift(
    id: m['id'] as int?,
    startedAt: DateTime.parse(m['started_at'] as String),
    endedAt: m['ended_at'] == null ? null : DateTime.parse(m['ended_at'] as String),
    endedReason: m['ended_reason'] as String?,
    date: m['date'] as String,
    target: m['target'] as int,
    floor: m['floor'] as int,
    notes: m['notes'] as String?,
  );
}
