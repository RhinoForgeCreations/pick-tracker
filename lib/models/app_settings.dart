class AppSettings {
  final int defaultTarget;
  final int defaultFloor;
  final int shiftGapMinutes;
  final bool keepScreenOn;
  final String timeFormat;
  final int softCapPerOrder;
  final int hardCapPerOrder;
  final String currentInputBuffer;
  final DateTime? lastExportAt;

  const AppSettings({
    required this.defaultTarget, required this.defaultFloor,
    required this.shiftGapMinutes, required this.keepScreenOn,
    required this.timeFormat, required this.softCapPerOrder,
    required this.hardCapPerOrder, required this.currentInputBuffer,
    this.lastExportAt,
  });

  factory AppSettings.fromMap(Map<String, Object?> m) => AppSettings(
    defaultTarget: m['default_target'] as int,
    defaultFloor: m['default_floor'] as int,
    shiftGapMinutes: m['shift_gap_minutes'] as int,
    keepScreenOn: (m['keep_screen_on'] as int) == 1,
    timeFormat: m['time_format'] as String,
    softCapPerOrder: m['soft_cap_per_order'] as int,
    hardCapPerOrder: m['hard_cap_per_order'] as int,
    currentInputBuffer: m['current_input_buffer'] as String,
    lastExportAt: m['last_export_at'] == null ? null
      : DateTime.parse(m['last_export_at'] as String),
  );
}
