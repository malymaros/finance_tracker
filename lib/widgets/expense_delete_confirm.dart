import 'package:flutter/material.dart';

import '../l10n/l10n.dart';
import '../l10n/l10n_extensions.dart';
import '../models/expense.dart';
import '../services/currency_formatter.dart';
import '../theme/app_theme.dart';
import 'save_action_dialog.dart';

/// Shows a [SaveActionDialog] pre-populated with the full expense details and
/// returns true when the user confirms deletion.
Future<bool> confirmDeleteExpense(BuildContext context, Expense expense) {
  final l10n = context.l10n;
  final day = expense.date.day.toString().padLeft(2, '0');
  final dateStr = '$day ${l10n.monthName(expense.date.month)} ${expense.date.year}';
  final buf = StringBuffer()
    ..writeln(l10n.categoryName(expense.category))
    ..writeln('${CurrencyFormatter.format(expense.amount)}  ·  $dateStr')
    ..write(l10n.financialTypeName(expense.financialType));
  if (expense.note != null) buf.write('\n${l10n.labelNote}: ${expense.note}');
  if (expense.group != null) buf.write('\n${l10n.labelGroup}: ${expense.group}');
  return SaveActionDialog.show(
    context,
    icon: Icons.remove_circle_outline,
    iconColor: AppColors.expense,
    actionLabel: l10n.deleteExpenseAllCaps,
    targetName: buf.toString(),
    description: l10n.deleteExpenseDescription,
    confirmLabel: l10n.actionDelete,
  );
}
