import 'package:flutter/material.dart';

import '../../models/expense_category.dart';
import '../../models/financial_type.dart';
import '../../models/plan_item.dart';
import '../../models/year_month.dart';

class PlanItemDetailScreen extends StatelessWidget {
  final PlanItem item;

  static const _monthNames = [
    '',
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  const PlanItemDetailScreen({super.key, required this.item});

  String _formatYearMonth(YearMonth ym) => '${_monthNames[ym.month]} ${ym.year}';

  static String _frequencyLabel(PlanFrequency freq) => switch (freq) {
        PlanFrequency.monthly => 'Monthly',
        PlanFrequency.yearly => 'Yearly',
        PlanFrequency.oneTime => 'One-time',
      };

  @override
  Widget build(BuildContext context) {
    final isIncome = item.type == PlanItemType.income;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Plan Item'),
        scrolledUnderElevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildHeaderCard(context, isIncome),
          const SizedBox(height: 16),
          _buildDetailsCard(isIncome),
        ],
      ),
    );
  }

  Widget _buildHeaderCard(BuildContext context, bool isIncome) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        child: Column(
          children: [
            Text(
              item.name,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: (isIncome ? Colors.green : Colors.red)
                    .withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                isIncome ? 'Income' : 'Fixed Cost',
                style: TextStyle(
                  color: isIncome ? Colors.green : Colors.red,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsCard(bool isIncome) {
    final amountSuffix = switch (item.frequency) {
      PlanFrequency.monthly => '/ month',
      PlanFrequency.yearly => '/ year',
      PlanFrequency.oneTime => '(one-time)',
    };

    return Card(
      child: Column(
        children: [
          _buildDetailRow(
            icon: Icons.euro_outlined,
            iconColor: isIncome ? Colors.green : Colors.red,
            label: 'Amount',
            value: '${item.amount.toStringAsFixed(2)} € $amountSuffix',
          ),
          const Divider(height: 1, indent: 56),
          _buildDetailRow(
            icon: Icons.repeat_outlined,
            iconColor: Colors.grey,
            label: 'Frequency',
            value: _frequencyLabel(item.frequency),
          ),
          if (item.category != null) ...[
            const Divider(height: 1, indent: 56),
            _buildDetailRow(
              icon: item.category!.icon,
              iconColor: item.category!.color,
              label: 'Category',
              value: item.category!.displayName,
            ),
          ],
          if (item.financialType != null) ...[
            const Divider(height: 1, indent: 56),
            _buildDetailRow(
              icon: item.financialType!.icon,
              iconColor: item.financialType!.color,
              label: 'Financial type',
              value: item.financialType!.displayName,
            ),
          ],
          const Divider(height: 1, indent: 56),
          _buildDetailRow(
            icon: Icons.calendar_today_outlined,
            iconColor: Colors.grey,
            label: 'Active from',
            value: _formatYearMonth(item.validFrom),
          ),
          if (item.frequency != PlanFrequency.oneTime) ...[
            const Divider(height: 1, indent: 56),
            _buildDetailRow(
              icon: Icons.event_outlined,
              iconColor: Colors.grey,
              label: 'Active until',
              value: item.validTo != null
                  ? _formatYearMonth(item.validTo!)
                  : isIncome
                      ? 'Ongoing'
                      : 'No end date',
            ),
          ],
          if (item.note != null) ...[
            const Divider(height: 1, indent: 56),
            _buildDetailRow(
              icon: Icons.notes_outlined,
              iconColor: Colors.grey,
              label: 'Note',
              value: item.note!,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 22),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(fontSize: 15)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
