class Schema {
  const Schema._();

  static const List<String> v1Statements = [
    '''CREATE TABLE meta (
      schema_version INTEGER NOT NULL,
      created_at TEXT NOT NULL
    )''',
    '''CREATE TABLE shifts (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      started_at TEXT NOT NULL,
      ended_at TEXT,
      ended_reason TEXT,
      date TEXT NOT NULL,
      target INTEGER NOT NULL,
      floor INTEGER NOT NULL,
      notes TEXT
    )''',
    '''CREATE TABLE orders (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      shift_id INTEGER NOT NULL REFERENCES shifts(id),
      seq INTEGER NOT NULL,
      cases INTEGER NOT NULL CHECK(cases > 0),
      started_at TEXT NOT NULL,
      ended_at TEXT,
      duration_ms INTEGER,
      is_outlier INTEGER NOT NULL DEFAULT 0,
      edited INTEGER NOT NULL DEFAULT 0
    )''',
    '''CREATE TABLE non_work_days (
      date TEXT PRIMARY KEY,
      reason TEXT NOT NULL,
      note TEXT
    )''',
    '''CREATE TABLE settings (
      id INTEGER PRIMARY KEY CHECK(id=1),
      default_target INTEGER NOT NULL DEFAULT 1000,
      default_floor INTEGER NOT NULL DEFAULT 900,
      shift_gap_minutes INTEGER NOT NULL DEFAULT 120,
      keep_screen_on INTEGER NOT NULL DEFAULT 1,
      time_format TEXT NOT NULL DEFAULT '24h',
      soft_cap_per_order INTEGER NOT NULL DEFAULT 200,
      hard_cap_per_order INTEGER NOT NULL DEFAULT 2000,
      current_input_buffer TEXT NOT NULL DEFAULT '',
      last_export_at TEXT
    )''',
    'CREATE INDEX idx_orders_shift ON orders(shift_id)',
    'CREATE INDEX idx_orders_started ON orders(started_at)',
    'CREATE INDEX idx_shifts_date ON shifts(date)',
  ];

  static const List<String> v2Statements = [
    '''CREATE TABLE breaks (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      shift_id INTEGER NOT NULL REFERENCES shifts(id),
      started_at TEXT NOT NULL,
      ended_at TEXT
    )''',
    'CREATE INDEX idx_breaks_shift ON breaks(shift_id)',
  ];

  static const String seedMeta =
      "INSERT INTO meta (schema_version, created_at) VALUES (?, ?)";
  static const String seedSettings = "INSERT INTO settings (id) VALUES (1)";
}
