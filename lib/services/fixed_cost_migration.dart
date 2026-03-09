import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../models/expense_category.dart';
import '../models/financial_type.dart';
import '../models/plan_item.dart';
import '../models/year_month.dart';
import 'plan_repository.dart';

/// One-time migration that reads legacy FixedCost records from finance_data.json
/// and converts them to PlanItems in PlanRepository.
///
/// Safe to call on every startup — it is a no-op if no fixedCosts exist in
/// the source file or if the migrated items are already present in PlanRepository.
class FixedCostMigration {
  const FixedCostMigration._();

  static Future<void> migrateIfNeeded(PlanRepository planRepo) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/finance_data.json');
    if (!await file.exists()) return;

    final Map<String, dynamic> json;
    try {
      json = jsonDecode(await file.readAsString()) as Map<String, dynamic>;
    } catch (_) {
      return;
    }

    final rawCosts = json['fixedCosts'] as List?;
    if (rawCosts == null || rawCosts.isEmpty) return;

    for (final raw in rawCosts) {
      final map = raw as Map<String, dynamic>;
      final originalId = map['id'] as String;
      final migratedId = 'migrated_$originalId';

      if (planRepo.items.any((i) => i.id == migratedId)) continue;

      final categoryRaw = map['category'] as String?;
      final financialTypeRaw = map['financialType'] as String?;
      final recurrenceRaw = map['recurrence'] as String;

      await planRepo.addPlanItem(PlanItem(
        id: migratedId,
        seriesId: migratedId,
        name: map['name'] as String,
        amount: (map['amount'] as num).toDouble(),
        type: PlanItemType.fixedCost,
        frequency: recurrenceRaw == 'yearly'
            ? PlanFrequency.yearly
            : PlanFrequency.monthly,
        validFrom: YearMonth(
          map['startYear'] as int,
          map['startMonth'] as int,
        ),
        category: categoryRaw != null
            ? ExpenseCategoryX.fromJson(categoryRaw)
            : ExpenseCategory.other,
        financialType: financialTypeRaw != null
            ? FinancialType.values.byName(financialTypeRaw)
            : FinancialType.consumption,
      ));
    }

    // Clear migrated records from finance_data.json so this never runs again.
    final updated = Map<String, dynamic>.from(json)
      ..['fixedCosts'] = <dynamic>[];
    await file.writeAsString(jsonEncode(updated));
  }
}
