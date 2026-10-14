import 'package:test/test.dart';
import 'package:zhuaji_sync/zhuaji_sync.dart';

void main() {
  final older = DateTime.utc(2026, 10, 12, 1);
  final newer = DateTime.utc(2026, 10, 12, 2);

  test('a later timestamp replaces the stored row', () {
    expect(
      incomingWins(
        incomingUpdatedAt: newer,
        incomingDeviceId: 'a',
        storedUpdatedAt: older,
        storedDeviceId: 'z',
      ),
      isTrue,
    );
  });

  test('an older timestamp is skipped', () {
    expect(
      incomingWins(
        incomingUpdatedAt: older,
        incomingDeviceId: 'z',
        storedUpdatedAt: newer,
        storedDeviceId: 'a',
      ),
      isFalse,
    );
  });

  test('equal timestamps keep the greater device id', () {
    expect(
      incomingWins(
        incomingUpdatedAt: older,
        incomingDeviceId: 'phone-b',
        storedUpdatedAt: older,
        storedDeviceId: 'phone-a',
      ),
      isTrue,
    );
    expect(
      incomingWins(
        incomingUpdatedAt: older,
        incomingDeviceId: 'phone-a',
        storedUpdatedAt: older,
        storedDeviceId: 'phone-b',
      ),
      isFalse,
    );
  });

  test('a missing stored row accepts the incoming change', () {
    expect(
      incomingWins(incomingUpdatedAt: older, incomingDeviceId: 'phone'),
      isTrue,
    );
  });

  test('an older tombstone does not erase a newer edit', () {
    final stored = SyncRecord(
      entity: 'weights',
      id: '1',
      updatedAt: newer,
      deviceId: 'phone-a',
      payload: const {'weightKg': 4.2},
    );
    final tombstone = SyncRecord(
      entity: 'weights',
      id: '1',
      updatedAt: older,
      deviceId: 'phone-b',
      deletedAt: older,
      payload: const {},
    );
    expect(keepRecord(stored, tombstone).isDeleted, isFalse);
  });
}
