/// A change that can move between a phone and the API.
///
/// Conflict rule (both sides must use [incomingWins]):
/// 1. The phone writes Drift first. The screen never waits on the network.
/// 2. When a cloud token exists, the outbox is pushed, then changes since
///    the cursor are pulled.
/// 3. The row with the later [SyncRecord.updatedAt] (UTC) stays.
/// 4. If the timestamps are equal, the lexicographically greater
///    [SyncRecord.deviceId] stays, so both sides pick the same winner.
/// 5. A delete is a [SyncRecord.deletedAt] tombstone. It still competes
///    with edits by timestamp, so an older delete cannot erase a newer edit.
class SyncRecord {
  const SyncRecord({
    required this.entity,
    required this.id,
    required this.updatedAt,
    required this.deviceId,
    required this.payload,
    this.deletedAt,
  });

  final String entity;
  final String id;
  final DateTime updatedAt;
  final String deviceId;
  final DateTime? deletedAt;
  final Map<String, Object?> payload;

  bool get isDeleted => deletedAt != null;

  Map<String, Object?> toJson() => {
    'entity': entity,
    'id': id,
    'updatedAt': updatedAt.toUtc().toIso8601String(),
    'deviceId': deviceId,
    'deletedAt': deletedAt?.toUtc().toIso8601String(),
    'payload': payload,
  };

  factory SyncRecord.fromJson(Map<String, Object?> json) {
    return SyncRecord(
      entity: json['entity']! as String,
      id: json['id']! as String,
      updatedAt: DateTime.parse(json['updatedAt']! as String).toUtc(),
      deviceId: json['deviceId']! as String,
      deletedAt: json['deletedAt'] == null
          ? null
          : DateTime.parse(json['deletedAt']! as String).toUtc(),
      payload: Map<String, Object?>.from(json['payload'] as Map? ?? const {}),
    );
  }
}

/// True when [incoming] should replace [stored]. A missing stored row always
/// loses to the incoming one.
bool incomingWins({
  required DateTime incomingUpdatedAt,
  required String incomingDeviceId,
  DateTime? storedUpdatedAt,
  String? storedDeviceId,
}) {
  if (storedUpdatedAt == null) return true;
  final incoming = incomingUpdatedAt.toUtc();
  final stored = storedUpdatedAt.toUtc();
  if (incoming.isAfter(stored)) return true;
  if (stored.isAfter(incoming)) return false;
  return incomingDeviceId.compareTo(storedDeviceId ?? '') >= 0;
}

/// The record that should be kept after comparing [stored] and [incoming].
SyncRecord keepRecord(SyncRecord? stored, SyncRecord incoming) {
  if (stored == null) return incoming;
  final take = incomingWins(
    incomingUpdatedAt: incoming.updatedAt,
    incomingDeviceId: incoming.deviceId,
    storedUpdatedAt: stored.updatedAt,
    storedDeviceId: stored.deviceId,
  );
  return take ? incoming : stored;
}
