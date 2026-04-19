import 'package:flutter/material.dart';

import '../l10n/l10n.dart';
import '../services/currency_formatter.dart';
import '../theme/app_theme.dart';
import 'sub_step_indicator.dart';

class HowCategoryBudgetsWorkSheet extends StatefulWidget {
  const HowCategoryBudgetsWorkSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const HowCategoryBudgetsWorkSheet(),
    );
  }

  @override
  State<HowCategoryBudgetsWorkSheet> createState() =>
      _HowCategoryBudgetsWorkSheetState();
}

class _HowCategoryBudgetsWorkSheetState
    extends State<HowCategoryBudgetsWorkSheet> {
  late final PageController _controller;
  int _page = 0;

  @override
  void initState() {
    super.initState();
    _controller = PageController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _goTo(int page) {
    _controller.animateToPage(
      page,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final subtitles = [
      l10n.howCategoryBudgetsSubtitle0,
      l10n.howCategoryBudgetsSubtitle1,
      l10n.howCategoryBudgetsSubtitle2,
    ];
    final labels = [
      l10n.howCategoryBudgetsLabel0,
      l10n.howCategoryBudgetsLabel1,
      l10n.howCategoryBudgetsLabel2,
    ];

    return DraggableScrollableSheet(
      initialChildSize: 0.82,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, _) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            _buildHandle(),
            _buildTopHeader(context),
            _buildStepHeader(context, subtitles, labels),
            const Divider(height: 1),
            Expanded(
              child: PageView(
                controller: _controller,
                onPageChanged: (i) => setState(() => _page = i),
                children: const [
                  _WhatPage(),
                  _SetupPage(),
                  _ProgressPage(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHandle() {
    return Center(
      child: Container(
        margin: const EdgeInsets.only(top: 12),
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: AppColors.border,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildTopHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 8, 4),
      child: Row(
        children: [
          Text(
            context.l10n.howItWorksQuestion,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Widget _buildStepHeader(
    BuildContext context,
    List<String> subtitles,
    List<String> labels,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.categoryBudgetsTitle,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 2),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            layoutBuilder: (current, previous) => Stack(
              alignment: Alignment.centerLeft,
              children: [...previous, ?current],
            ),
            child: Text(
              subtitles[_page],
              key: ValueKey(_page),
              style: const TextStyle(fontSize: 14, color: AppColors.textMuted),
            ),
          ),
          const SizedBox(height: 10),
          SubStepIndicator(
            activeSubStep: _page,
            labels: labels,
            onTap: _goTo,
          ),
        ],
      ),
    );
  }
}

// ── Page 0: What ─────────────────────────────────────────────────────────────

class _WhatPage extends StatelessWidget {
  const _WhatPage();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.howCategoryBudgetsWhatIntro,
            style: const TextStyle(
                fontSize: 14, height: 1.6, color: Colors.black87),
          ),
          const SizedBox(height: 20),
          const _MockProgressBar(),
          const SizedBox(height: 20),
          _rule(l10n.howCategoryBudgetsRule1),
          const SizedBox(height: 10),
          _rule(l10n.howCategoryBudgetsRule2),
          const SizedBox(height: 10),
          _rule(l10n.howCategoryBudgetsRule3),
          const SizedBox(height: 10),
          _rule(l10n.howCategoryBudgetsRule4),
        ],
      ),
    );
  }
}

class _MockProgressBar extends StatelessWidget {
  const _MockProgressBar();

  @override
  Widget build(BuildContext context) {
    const double percent = 0.62;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.restaurant_outlined,
                  size: 16, color: AppColors.textMuted),
              const SizedBox(width: 6),
              const Expanded(
                child: Text(
                  'Restaurants',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87),
                ),
              ),
              Text(
                '62.00 / 100.00 ${CurrencyFormatter.currencySymbol}',
                style:
                    const TextStyle(fontSize: 12, color: AppColors.textMuted),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percent,
              minHeight: 6,
              backgroundColor: AppColors.border,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.income),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Page 1: Set up ────────────────────────────────────────────────────────────

class _SetupPage extends StatelessWidget {
  const _SetupPage();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.howCategoryBudgetsSetupIntro,
            style: const TextStyle(
                fontSize: 14, height: 1.6, color: Colors.black87),
          ),
          const SizedBox(height: 16),
          _rule(l10n.howCategoryBudgetsSetupRule1),
          const SizedBox(height: 10),
          _rule(l10n.howCategoryBudgetsSetupRule2),
          const SizedBox(height: 10),
          _rule(l10n.howCategoryBudgetsSetupRule3),
          const SizedBox(height: 10),
          _rule(l10n.howCategoryBudgetsSetupRule4),
          const SizedBox(height: 20),
          _hint(
            icon: Icons.warning_amber_outlined,
            text: l10n.howCategoryBudgetsPastMonthHint,
          ),
        ],
      ),
    );
  }
}

// ── Page 2: Progress ──────────────────────────────────────────────────────────

class _ProgressPage extends StatelessWidget {
  const _ProgressPage();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.howCategoryBudgetsProgressIntro,
            style: const TextStyle(
                fontSize: 14, height: 1.6, color: Colors.black87),
          ),
          const SizedBox(height: 16),
          _ColorRule(
            color: AppColors.income,
            text: l10n.howCategoryBudgetsProgressRule1,
          ),
          const SizedBox(height: 8),
          _ColorRule(
            color: AppColors.warning,
            text: l10n.howCategoryBudgetsProgressRule2,
          ),
          const SizedBox(height: 8),
          _ColorRule(
            color: AppColors.expense,
            text: l10n.howCategoryBudgetsProgressRule3,
          ),
          const SizedBox(height: 20),
          Text(
            l10n.howCategoryBudgetsWhereTitle,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 10),
          _rule(l10n.howCategoryBudgetsWhere1),
          const SizedBox(height: 8),
          _rule(l10n.howCategoryBudgetsWhere2),
          const SizedBox(height: 8),
          _rule(l10n.howCategoryBudgetsWhere3),
          const SizedBox(height: 20),
          _hint(
            icon: Icons.info_outline,
            text: l10n.howCategoryBudgetsResetHint,
          ),
        ],
      ),
    );
  }
}

class _ColorRule extends StatelessWidget {
  final Color color;
  final String text;

  const _ColorRule({required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
                fontSize: 14, height: 1.6, color: Colors.black87),
          ),
        ),
      ],
    );
  }
}

// ── Shared helpers ────────────────────────────────────────────────────────────

Widget _rule(String text) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Padding(
        padding: EdgeInsets.only(top: 6),
        child: Icon(Icons.circle, size: 5, color: AppColors.textMuted),
      ),
      const SizedBox(width: 10),
      Expanded(
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 14,
            height: 1.6,
            color: Colors.black87,
          ),
        ),
      ),
    ],
  );
}

Widget _hint({required IconData icon, required String text}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: AppColors.border),
    ),
    child: Row(
      children: [
        Icon(icon, size: 15, color: AppColors.textMuted),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
          ),
        ),
      ],
    ),
  );
}
