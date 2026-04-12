import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../l10n/l10n.dart';
import '../models/expense.dart';
import '../models/import_result.dart';
import '../models/imported_expense.dart';
import '../services/finance_repository.dart';
import '../services/import_export_service.dart';
import '../theme/app_theme.dart';
import '../widgets/edit_import_row_sheet.dart';
import '../widgets/import_error_tile.dart';
import '../widgets/import_row_tile.dart';

enum _ImportPhase { idle, loading, preview, saving }

/// Multi-step screen for importing expenses from an xlsx file.
///
/// Phase flow:
///   idle → (pick file) → loading → (parse) → preview → (confirm) → saving → pop
///
/// Nothing is written to [FinanceRepository] until the user explicitly
/// confirms on the preview phase.
class ImportScreen extends StatefulWidget {
  final FinanceRepository repository;

  const ImportScreen({super.key, required this.repository});

  @override
  State<ImportScreen> createState() => _ImportScreenState();
}

class _ImportScreenState extends State<ImportScreen> {
  _ImportPhase _phase = _ImportPhase.idle;
  ImportResult? _result;

  /// Mutable working copy of valid rows — the user can edit or remove entries
  /// before confirming. Initialised when the file is parsed successfully.
  final List<ImportedExpense> _editableRows = [];

  // ── Template download ─────────────────────────────────────────────────────

  Future<void> _downloadTemplate() async {
    try {
      final bytes = await ImportExportService.generateTemplate();
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/finance_tracker_import_template.xlsx');
      await file.writeAsBytes(bytes);
      await Share.shareXFiles(
        [XFile(file.path, mimeType: ImportExportService.xlsxMimeType)],
        subject: 'Finance Tracker Import Template',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.importTemplateError(e))),
        );
      }
    }
  }

  // ── File pick + parse ─────────────────────────────────────────────────────

  Future<void> _pickFile() async {
    FilePickerResult? picked;
    try {
      // FileType.any is intentional: FileType.custom filters by MIME type on
      // Android, and Google Drive serves CSV files as text/plain or
      // application/octet-stream, which causes them to be hidden. We validate
      // the type ourselves after picking.
      picked = await FilePicker.platform.pickFiles(
        type: FileType.any,
        withData: true,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.importPickerError(e))),
        );
      }
      return;
    }

    if (picked == null || picked.files.isEmpty) return;

    // Read bytes first — withData: true already placed them in memory.
    final bytes = picked.files.first.bytes;
    if (bytes == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.importCouldNotReadFile)),
        );
      }
      return;
    }

    // Determine file type: extension-first, with content-based fallback.
    // On some Android content providers (e.g. Gmail attachment downloads,
    // certain cloud-storage apps), DISPLAY_NAME omits the extension, so the
    // exported file arrives as "expenses_20260101_20260301" rather than
    // "expenses_20260101_20260301.xlsx". xlsx files are ZIP archives and always
    // start with the ZIP magic bytes 50 4B 03 04, so we can detect them
    // reliably by content even when the extension is absent.
    final fileName = picked.files.first.name.toLowerCase();
    final isCsvByExt = fileName.endsWith('.csv');
    final isXlsxByExt = fileName.endsWith('.xlsx');

    final bool isCsv;
    if (isXlsxByExt) {
      isCsv = false;
    } else if (isCsvByExt) {
      isCsv = true;
    } else {
      // Magic-byte detection: xlsx (ZIP) starts with PK\x03\x04.
      final isZip = bytes.length >= 4 &&
          bytes[0] == 0x50 &&
          bytes[1] == 0x4B &&
          bytes[2] == 0x03 &&
          bytes[3] == 0x04;
      if (isZip) {
        isCsv = false;
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(context.l10n.importUnsupportedFile)),
          );
        }
        return;
      }
    }

    setState(() => _phase = _ImportPhase.loading);

    // Yield to let the loading indicator render before parsing.
    final result = await Future.microtask(() => isCsv
        ? ImportExportService.parseCsvFile(bytes)
        : ImportExportService.parseImportFile(bytes));

    if (mounted) {
      setState(() {
        _result = result;
        _editableRows
          ..clear()
          ..addAll(result.validRows);
        _phase = _ImportPhase.preview;
      });
    }
  }

  // ── Edit / delete a single row ────────────────────────────────────────────

  Future<void> _openEditSheet(int index) async {
    final result = await Navigator.of(context).push<Object>(
      MaterialPageRoute(
        builder: (_) => EditImportRowSheet(expense: _editableRows[index]),
      ),
    );
    if (!mounted || result == null) return;

    setState(() {
      if (result == EditImportRowSheet.deleted) {
        _editableRows.removeAt(index);
      } else if (result is ImportedExpense) {
        _editableRows[index] = result;
      }
    });
  }

  // ── Import confirmation ───────────────────────────────────────────────────

  Future<void> _confirmImport() async {
    if (_editableRows.isEmpty) return;

    setState(() => _phase = _ImportPhase.saving);

    final baseId = DateTime.now().microsecondsSinceEpoch;
    final expenses = _editableRows.asMap().entries.map((entry) {
      final row = entry.value;
      return Expense(
        id: '${baseId}_${entry.key}',
        amount: row.amount,
        category: row.category,
        financialType: row.financialType,
        date: row.date,
        note: row.note,
        group: row.group,
      );
    }).toList();

    await widget.repository.addExpenses(expenses);

    if (mounted) {
      final count = expenses.length;
      final dates = expenses.map((e) => e.date).toList()..sort();
      final first = dates.first;
      final last = dates.last;
      final sameMonth =
          first.year == last.year && first.month == last.month;
      const monthNames = [
        '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
      ];
      final rangeLabel = sameMonth
          ? '${monthNames[first.month]} ${first.year}'
          : '${monthNames[first.month]} ${first.year} – '
              '${monthNames[last.month]} ${last.year}';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.importSuccessMessage(count, rangeLabel)),
        ),
      );
      Navigator.of(context).pop();
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.importTitle),
        scrolledUnderElevation: 0,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    switch (_phase) {
      case _ImportPhase.idle:
        return _buildIdle();
      case _ImportPhase.loading:
      case _ImportPhase.saving:
        return const Center(child: CircularProgressIndicator());
      case _ImportPhase.preview:
        return _buildPreview();
    }
  }

  // ── Idle phase ────────────────────────────────────────────────────────────

  Widget _buildIdle() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _StepCard(
          step: '1',
          title: context.l10n.importStep1Title,
          description: context.l10n.importStep1Description,
          icon: Icons.download_outlined,
          buttonLabel: context.l10n.importStep1Button,
          onTap: _downloadTemplate,
        ),
        const SizedBox(height: 12),
        _StepCard(
          step: '2',
          title: context.l10n.importStep2Title,
          description: context.l10n.importStep2Description,
          icon: Icons.upload_file_outlined,
          buttonLabel: context.l10n.importStep2Button,
          onTap: _pickFile,
        ),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            context.l10n.importInfoText,
            style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
          ),
        ),
      ],
    );
  }

  // ── Preview phase ─────────────────────────────────────────────────────────

  Widget _buildPreview() {
    final result = _result!;

    if (result.headerError != null) {
      return _buildHardError(result.headerError!);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildPreviewSummary(result),
        const Divider(height: 1),
        Expanded(child: _buildPreviewList(result)),
        _buildPreviewActions(),
      ],
    );
  }

  Widget _buildHardError(String message) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.expense.withAlpha(13),
              border: Border.all(color: AppColors.expense.withAlpha(100)),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: [
                const Icon(Icons.error_outline,
                    color: AppColors.expense, size: 40),
                const SizedBox(height: 12),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            icon: const Icon(Icons.upload_file_outlined),
            label: Text(context.l10n.tryAnotherFile),
            onPressed: () => setState(() {
              _phase = _ImportPhase.idle;
              _result = null;
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewSummary(ImportResult result) {
    final validCount = _editableRows.length;
    final errorCount = result.invalidRows.length;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.importReadyCount(validCount),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          if (errorCount > 0) ...[
            const SizedBox(height: 4),
            Text(
              validCount > 0
                  ? context.l10n.importErrorCountSkipped(errorCount)
                  : context.l10n.importErrorCount(errorCount),
              style: const TextStyle(color: AppColors.warning, fontSize: 13),
            ),
          ],
          if (validCount == 0 && errorCount == 0)
            Text(
              context.l10n.importNoDataFound,
              style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
            ),
          const SizedBox(height: 4),
          Text(
            context.l10n.importTapToEdit,
            style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewList(ImportResult result) {
    if (_editableRows.isEmpty && result.invalidRows.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.inbox_outlined, size: 48, color: AppColors.textMuted),
            const SizedBox(height: 12),
            Text(context.l10n.importNoDataRows,
                style: const TextStyle(color: AppColors.textMuted)),
          ],
        ),
      );
    }

    return ListView(
      children: [
        for (var i = 0; i < _editableRows.length; i++)
          ImportRowTile(
            expense: _editableRows[i],
            onTap: () => _openEditSheet(i),
          ),
        if (result.invalidRows.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: Text(
              context.l10n.importRowsWithErrors,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.warning,
              ),
            ),
          ),
          ...result.invalidRows.map((err) => ImportErrorTile(error: err)),
        ],
      ],
    );
  }

  Widget _buildPreviewActions() {
    final validCount = _editableRows.length;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          TextButton(
            onPressed: () => setState(() {
              _phase = _ImportPhase.idle;
              _result = null;
              _editableRows.clear();
            }),
            child: Text(context.l10n.actionCancel),
          ),
          const Spacer(),
          FilledButton(
            onPressed: validCount > 0 ? _confirmImport : null,
            child: Text(context.l10n.importConfirmButton(validCount)),
          ),
        ],
      ),
    );
  }

}

// ── Step card widget ──────────────────────────────────────────────────────────

class _StepCard extends StatelessWidget {
  final String step;
  final String title;
  final String description;
  final IconData icon;
  final String buttonLabel;
  final VoidCallback onTap;

  const _StepCard({
    required this.step,
    required this.title,
    required this.description,
    required this.icon,
    required this.buttonLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: Text(
                    step,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              description,
              style: const TextStyle(
                  color: AppColors.textMuted, fontSize: 13),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onTap,
                icon: Icon(icon),
                label: Text(buttonLabel),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
