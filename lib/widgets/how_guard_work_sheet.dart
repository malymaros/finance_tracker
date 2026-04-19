import 'package:flutter/material.dart';

import '../l10n/l10n.dart';
import '../theme/app_theme.dart';
import 'sub_step_indicator.dart';

class HowGuardWorkSheet extends StatefulWidget {
  const HowGuardWorkSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const HowGuardWorkSheet(),
    );
  }

  @override
  State<HowGuardWorkSheet> createState() => _HowGuardWorkSheetState();
}

class _HowGuardWorkSheetState extends State<HowGuardWorkSheet> {
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
      l10n.howGuardSubtitle0,
      l10n.howGuardSubtitle1,
      l10n.howGuardSubtitle2,
    ];
    final labels = [
      l10n.howGuardLabel0,
      l10n.howGuardLabel1,
      l10n.howGuardLabel2,
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
                  _ActivatePage(),
                  _ActPage(),
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
            context.l10n.howGuardTitle,
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
          Row(
            children: [
              const Icon(Icons.pets, color: AppColors.gold, size: 18),
              const SizedBox(width: 6),
              Text(
                context.l10n.guardScreenTitle,
                style: const TextStyle(
                    fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ],
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
            l10n.howGuardWhatIntro,
            style: const TextStyle(
                fontSize: 14, height: 1.6, color: Colors.black87),
          ),
          const SizedBox(height: 16),
          _rule(l10n.howGuardRule1),
          const SizedBox(height: 10),
          _rule(l10n.howGuardRule2),
          const SizedBox(height: 10),
          _rule(l10n.howGuardRule3),
          const SizedBox(height: 20),
          _MockStatusRows(
            unpaid: l10n.howGuardStateUnpaid,
            paid: l10n.howGuardStatePaid,
            silenced: l10n.howGuardStateSilenced,
          ),
        ],
      ),
    );
  }
}

class _MockStatusRows extends StatelessWidget {
  final String unpaid;
  final String paid;
  final String silenced;

  const _MockStatusRows({
    required this.unpaid,
    required this.paid,
    required this.silenced,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          _StatusRow(
            icon: Icons.warning_amber_rounded,
            color: AppColors.warning,
            label: unpaid,
          ),
          const Divider(height: 16),
          _StatusRow(
            icon: Icons.check_circle_outline,
            color: AppColors.income,
            label: paid,
          ),
          const Divider(height: 16),
          _StatusRow(
            icon: Icons.volume_off_outlined,
            color: AppColors.textMuted,
            label: silenced,
          ),
        ],
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;

  const _StatusRow({
    required this.icon,
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 10),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}

// ── Page 1: Activate ──────────────────────────────────────────────────────────

class _ActivatePage extends StatelessWidget {
  const _ActivatePage();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.howGuardActivateIntro,
            style: const TextStyle(
                fontSize: 14, height: 1.6, color: Colors.black87),
          ),
          const SizedBox(height: 16),
          _rule(l10n.howGuardActivateRule1),
          const SizedBox(height: 10),
          _rule(l10n.howGuardActivateRule2),
          const SizedBox(height: 10),
          _rule(l10n.howGuardActivateRule3),
          const SizedBox(height: 10),
          _rule(l10n.howGuardActivateRule4),
          const SizedBox(height: 20),
          _hint(
            icon: Icons.lock_outline,
            text: l10n.howGuardFixedCostOnlyHint,
          ),
        ],
      ),
    );
  }
}

// ── Page 2: Act ───────────────────────────────────────────────────────────────

class _ActPage extends StatelessWidget {
  const _ActPage();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.howGuardActIntro,
            style: const TextStyle(
                fontSize: 14, height: 1.6, color: Colors.black87),
          ),
          const SizedBox(height: 16),
          _rule(l10n.howGuardActRule1),
          const SizedBox(height: 10),
          _rule(l10n.howGuardActRule2),
          const SizedBox(height: 10),
          _rule(l10n.howGuardActRule3),
          const SizedBox(height: 20),
          const _MockCycleTile(),
          const SizedBox(height: 20),
          _hint(
            icon: Icons.info_outline,
            text: l10n.howGuardPerPeriodHint,
          ),
        ],
      ),
    );
  }
}

// ── Mock cycle tile ───────────────────────────────────────────────────────────

class _MockCycleTile extends StatelessWidget {
  const _MockCycleTile();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          _CycleRow(
            label: 'Rent · April',
            badgeText: '${l10n.guardStatusPaid} ✓',
            badgeColor: AppColors.income,
          ),
          const Divider(height: 16),
          _CycleRow(
            label: 'Rent · May',
            badgeText: '${l10n.guardStatusUnpaid} ●',
            badgeColor: AppColors.warning,
          ),
        ],
      ),
    );
  }
}

class _CycleRow extends StatelessWidget {
  final String label;
  final String badgeText;
  final Color badgeColor;

  const _CycleRow({
    required this.label,
    required this.badgeText,
    required this.badgeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.home_outlined, size: 16, color: AppColors.textMuted),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 13, color: Colors.black87),
          ),
        ),
        Text(
          badgeText,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: badgeColor,
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
