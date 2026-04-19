import 'package:flutter/material.dart';

import '../l10n/l10n.dart';
import '../services/currency_formatter.dart';
import '../theme/app_theme.dart';
import 'sub_step_indicator.dart';

/// Bottom sheet explaining how expense groups work.
///
/// Shell and header are identical to [HowItWorksSheet]: title "How it works?",
/// drag handle, close button. Below the header a step-header block shows
/// "Groups" + a subtitle that tracks the current page, plus a sub-step
/// indicator row (Tag | Be creative | Record) at full width. A [PageView]
/// fills the remaining space and can be swiped or jumped via the indicator.
class HowGroupsWorkSheet extends StatefulWidget {
  const HowGroupsWorkSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const HowGroupsWorkSheet(),
    );
  }

  @override
  State<HowGroupsWorkSheet> createState() => _HowGroupsWorkSheetState();
}

class _HowGroupsWorkSheetState extends State<HowGroupsWorkSheet> {
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
      l10n.howGroupsSubtitle0,
      l10n.howGroupsSubtitle1,
      l10n.howGroupsSubtitle2,
    ];
    final labels = [
      l10n.howGroupsLabel0,
      l10n.howGroupsLabel1,
      l10n.howGroupsLabel2,
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
                  _TagPage(),
                  _BeCreativePage(),
                  _RecordPage(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Chrome ─────────────────────────────────────────────────────────────────

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
            context.l10n.howGroupsTitle,
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


// ── Page 1: Tag ───────────────────────────────────────────────────────────────

class _TagPage extends StatelessWidget {
  const _TagPage();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            margin: EdgeInsets.zero,
            child: ListTile(
              leading: const Icon(
                Icons.folder_outlined,
                color: AppColors.gold,
                size: 22,
              ),
              title: Text(l10n.howGroupsExampleGroupName),
              subtitle: Text(
                l10n.itemCount(15),
                style: const TextStyle(fontSize: 12),
              ),
              trailing: Text(
                '440.00 ${CurrencyFormatter.currencySymbol}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),
          const SizedBox(height: 20),
          _rule(l10n.howGroupsRule1),
          const SizedBox(height: 10),
          _rule(l10n.howGroupsRule2),
          const SizedBox(height: 10),
          _rule(l10n.howGroupsRule3),
          const SizedBox(height: 10),
          _rule(l10n.howGroupsRule4),
          const SizedBox(height: 10),
          _rule(l10n.howGroupsRule5),
          const SizedBox(height: 20),
          _hint(
            icon: Icons.edit_outlined,
            text: l10n.howGroupsHint,
          ),
        ],
      ),
    );
  }

  static Widget _rule(String text) {
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

  static Widget _hint({required IconData icon, required String text}) {
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
}

// ── Page 2: Be creative ───────────────────────────────────────────────────────

class _BeCreativePage extends StatelessWidget {
  const _BeCreativePage();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final year = DateTime.now().year;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.howGroupsUseIntro,
            style: const TextStyle(fontSize: 14, height: 1.6, color: Colors.black87),
          ),
          const SizedBox(height: 16),
          _ExampleCard(
            label: l10n.howGroupsExample1Label(year),
            description: l10n.howGroupsExample1Desc,
          ),
          const SizedBox(height: 10),
          _ExampleCard(
            label: l10n.howGroupsExample2Label(year),
            description: l10n.howGroupsExample2Desc,
          ),
          const SizedBox(height: 10),
          _ExampleCard(
            label: l10n.howGroupsExample3Label,
            description: l10n.howGroupsExample3Desc,
          ),
          const SizedBox(height: 16),
          Text(
            l10n.howGroupsPrecision,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textMuted,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}

class _ExampleCard extends StatelessWidget {
  final String label;
  final String description;

  const _ExampleCard({required this.label, required this.description});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.folder_outlined, size: 13, color: AppColors.gold),
              const SizedBox(width: 5),
              Text(
                '"$label"',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.gold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: const TextStyle(
              fontSize: 13,
              height: 1.4,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Page 3: Record ────────────────────────────────────────────────────────────

class _RecordPage extends StatelessWidget {
  const _RecordPage();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _RecordRow(
            icon: Icons.folder_outlined,
            title: l10n.howGroupsRecord0Title,
            body: l10n.howGroupsRecord0Body,
          ),
          const SizedBox(height: 12),
          _RecordRow(
            icon: Icons.picture_as_pdf_outlined,
            title: l10n.howGroupsRecord1Title,
            body: l10n.howGroupsRecord1Body,
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, size: 15, color: AppColors.textMuted),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    l10n.howGroupsMonthlyNote,
                    style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RecordRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;

  const _RecordRow({
    required this.icon,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 2),
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.border),
          ),
          child: Icon(icon, size: 18, color: AppColors.gold),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                body,
                style: const TextStyle(
                  fontSize: 13,
                  height: 1.5,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
