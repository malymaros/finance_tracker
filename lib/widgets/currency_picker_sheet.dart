import 'package:flutter/material.dart';

import '../l10n/l10n.dart';
import '../models/currency_choice.dart';
import '../services/currency_service.dart';
import '../theme/app_theme.dart';

/// Dialog for selecting the app currency.
///
/// Navy header matching the app chrome, six preset rows, and a "Custom" row
/// that opens a keyboard-safe bottom sheet for free-form input.
class CurrencyPickerDialog extends StatelessWidget {
  const CurrencyPickerDialog({super.key});

  Future<void> _selectPreset(BuildContext context, CurrencyPreset preset) async {
    await CurrencyService.instance.setCurrency(PresetCurrency(preset));
    if (context.mounted) Navigator.of(context).pop();
  }

  Future<void> _openCustomSheet(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const _CustomCurrencySheet(),
    );
    // Close the picker dialog once the sheet returns — handles both
    // "Save" (currency changed) and "Cancel" (no-op) dismissals.
    // Only close when a custom currency was actually saved.
    if (context.mounted &&
        CurrencyService.instance.current is CustomCurrency) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: CurrencyService.instance,
      builder: (context, _) {
        final current = CurrencyService.instance.current;

        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          insetPadding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
          clipBehavior: Clip.antiAlias,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Navy header ───────────────────────────────────────────────
              Container(
                color: AppColors.navy,
                padding: const EdgeInsets.fromLTRB(20, 14, 8, 14),
                child: Row(
                  children: [
                    const Icon(Icons.currency_exchange,
                        color: AppColors.gold, size: 18),
                    const SizedBox(width: 10),
                    Text(
                      context.l10n.currencyPickerTitle,
                      style: const TextStyle(
                        color: AppColors.gold,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.4,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close,
                          color: AppColors.gold, size: 20),
                      onPressed: () => Navigator.of(context).pop(),
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
              ),

              // ── Preset rows ───────────────────────────────────────────────
              for (final preset in CurrencyPreset.values)
                _PresetRow(
                  preset: preset,
                  isSelected:
                      current is PresetCurrency && current.preset == preset,
                  onTap: () => _selectPreset(context, preset),
                ),

              const Divider(height: 1),

              // ── Custom row ────────────────────────────────────────────────
              _CustomRow(
                current: current,
                onTap: () => _openCustomSheet(context),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }
}

// ── Preset row ────────────────────────────────────────────────────────────────

class _PresetRow extends StatelessWidget {
  final CurrencyPreset preset;
  final bool isSelected;
  final VoidCallback onTap;

  const _PresetRow({
    required this.preset,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        color: isSelected ? AppColors.navy.withAlpha(10) : null,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            _CurrencyBadge(
              symbol: preset.symbol,
              isSelected: isSelected,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                preset.code,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight:
                      isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected ? AppColors.navy : null,
                ),
              ),
            ),
            Text(
              preset.symbol,
              style: TextStyle(
                fontSize: 15,
                color: isSelected ? AppColors.navy : AppColors.textMuted,
                fontWeight:
                    isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
            const SizedBox(width: 8),
            if (isSelected)
              Stack(
                alignment: Alignment.center,
                children: const [
                  Icon(Icons.circle, size: 20, color: AppColors.navy),
                  Icon(Icons.check, size: 13, color: AppColors.gold),
                ],
              )
            else
              const Icon(Icons.radio_button_unchecked,
                  size: 20, color: AppColors.border),
          ],
        ),
      ),
    );
  }
}

// ── Custom row ────────────────────────────────────────────────────────────────

class _CustomRow extends StatelessWidget {
  final CurrencyChoice current;
  final VoidCallback onTap;

  const _CustomRow({required this.current, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isSelected = current is CustomCurrency;
    final symbol = isSelected ? (current as CustomCurrency).symbol : '?';
    final l10n = context.l10n;

    return InkWell(
      onTap: onTap,
      child: Container(
        color: isSelected ? AppColors.navy.withAlpha(10) : null,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            _CurrencyBadge(symbol: symbol, isSelected: isSelected),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.currencyCustom,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w400,
                      color: isSelected ? AppColors.navy : null,
                    ),
                  ),
                  Text(
                    isSelected
                        ? '${(current as CustomCurrency).code} · ${(current as CustomCurrency).symbol}'
                        : l10n.currencyCustomSubtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Stack(
                alignment: Alignment.center,
                children: const [
                  Icon(Icons.circle, size: 20, color: AppColors.navy),
                  Icon(Icons.check, size: 13, color: AppColors.gold),
                ],
              )
            else
              const Icon(Icons.chevron_right,
                  size: 20, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}

// ── Currency badge ────────────────────────────────────────────────────────────

class _CurrencyBadge extends StatelessWidget {
  final String symbol;
  final bool isSelected;

  const _CurrencyBadge({required this.symbol, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isSelected ? AppColors.navy : AppColors.surface,
        border: Border.all(
          color: isSelected ? AppColors.navy : AppColors.border,
          width: 1.5,
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        symbol,
        style: TextStyle(
          color: isSelected ? AppColors.gold : AppColors.textMuted,
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

// ── Custom currency bottom sheet ──────────────────────────────────────────────

class _CustomCurrencySheet extends StatefulWidget {
  const _CustomCurrencySheet();

  @override
  State<_CustomCurrencySheet> createState() => _CustomCurrencySheetState();
}

class _CustomCurrencySheetState extends State<_CustomCurrencySheet> {
  final _codeController = TextEditingController();
  final _symbolController = TextEditingController();
  String? _error;

  @override
  void initState() {
    super.initState();
    final current = CurrencyService.instance.current;
    if (current is CustomCurrency) {
      _codeController.text = current.code;
      _symbolController.text = current.symbol;
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    _symbolController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final code = _codeController.text.trim().toUpperCase();
    final symbol = _symbolController.text.trim();
    try {
      await CurrencyService.instance.setCurrency(
        CustomCurrency(code: code, symbol: symbol),
      );
      if (mounted) Navigator.of(context).pop();
    } on ArgumentError catch (e) {
      setState(() => _error = e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Navy header ──────────────────────────────────────────────────────
        Container(
          decoration: const BoxDecoration(
            color: AppColors.navy,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 14, 8, 14),
          child: Row(
            children: [
              const Icon(Icons.edit_outlined, color: AppColors.gold, size: 18),
              const SizedBox(width: 10),
              Text(
                context.l10n.currencyCustomTitle,
                style: const TextStyle(
                  color: AppColors.gold,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.4,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close, color: AppColors.gold, size: 20),
                onPressed: () => Navigator.of(context).pop(),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
        ),

        // ── Form ─────────────────────────────────────────────────────────────
        Padding(
          padding: EdgeInsets.fromLTRB(
            20, 20, 20,
            MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _codeController,
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(
                  labelText: context.l10n.currencyCodeLabel,
                  hintText: context.l10n.currencyCodeHint,
                  border: const OutlineInputBorder(),
                ),
                maxLength: 8,
                onChanged: (_) => setState(() => _error = null),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _symbolController,
                decoration: InputDecoration(
                  labelText: context.l10n.currencySymbolLabel,
                  hintText: context.l10n.currencySymbolHint,
                  border: const OutlineInputBorder(),
                ),
                maxLength: 5,
                onChanged: (_) => setState(() => _error = null),
              ),
              if (_error != null) ...[
                const SizedBox(height: 8),
                Text(
                  _error!,
                  style: const TextStyle(
                      color: AppColors.expense, fontSize: 12),
                ),
              ],
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(context.l10n.actionCancel),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: _save,
                    style: FilledButton.styleFrom(
                        backgroundColor: AppColors.navy),
                    child: Text(context.l10n.actionSave),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
