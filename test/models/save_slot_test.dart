import 'package:flutter_test/flutter_test.dart';
import 'package:finance_tracker/models/save_slot.dart';

void main() {
  group('SaveSlot — isAuto field', () {
    test('defaults to false when missing from JSON (backward compat)', () {
      final json = {
        'id': '123',
        'name': 'Test',
        'createdAt': '2024-03-01T10:00:00.000',
        'expenseCount': 5,
        'planItemCount': 2,
        // no 'isAuto' key
      };
      final slot = SaveSlot.fromJson(json);
      expect(slot.isAuto, false);
    });

    test('reads isAuto: true from JSON', () {
      final json = {
        'id': '123',
        'name': 'Test',
        'createdAt': '2024-03-01T10:00:00.000',
        'expenseCount': 5,
        'planItemCount': 2,
        'isAuto': true,
      };
      final slot = SaveSlot.fromJson(json);
      expect(slot.isAuto, true);
    });

    test('reads isAuto: false from JSON', () {
      final json = {
        'id': '123',
        'name': 'Test',
        'createdAt': '2024-03-01T10:00:00.000',
        'expenseCount': 5,
        'planItemCount': 2,
        'isAuto': false,
      };
      final slot = SaveSlot.fromJson(json);
      expect(slot.isAuto, false);
    });

    test('toJson includes isAuto key', () {
      final slot = SaveSlot(
        id: '1',
        name: 'Auto',
        createdAt: DateTime(2024, 3, 1),
        expenseCount: 3,
        planItemCount: 1,
        isAuto: true,
      );
      expect(slot.toJson()['isAuto'], true);
    });

    test('toJson round-trips isAuto correctly', () {
      final original = SaveSlot(
        id: '99',
        name: 'Backup',
        createdAt: DateTime(2025, 6, 15, 8, 30),
        expenseCount: 10,
        planItemCount: 4,
        isAuto: true,
      );
      final restored = SaveSlot.fromJson(original.toJson());
      expect(restored.isAuto, original.isAuto);
      expect(restored.id, original.id);
      expect(restored.expenseCount, original.expenseCount);
    });

    test('constructor defaults isAuto to false', () {
      final slot = SaveSlot(
        id: '1',
        name: 'Manual',
        createdAt: DateTime(2024, 1, 1),
        expenseCount: 0,
        planItemCount: 0,
      );
      expect(slot.isAuto, false);
    });
  });
}
