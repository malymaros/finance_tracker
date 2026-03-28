import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:finance_tracker/models/financial_type.dart';

void main() {
  group('FinancialTypeX.tintColor', () {
    test('asset returns a semi-transparent green', () {
      final color = FinancialType.asset.tintColor;
      expect(color.a, greaterThan(0));
      expect(color, isNot(Colors.transparent));
    });

    test('insurance returns a semi-transparent blue', () {
      final color = FinancialType.insurance.tintColor;
      expect(color.a, greaterThan(0));
      expect(color, isNot(Colors.transparent));
    });

    test('consumption returns transparent', () {
      expect(FinancialType.consumption.tintColor, Colors.transparent);
    });

    test('asset and insurance tintColors are different', () {
      expect(FinancialType.asset.tintColor,
          isNot(FinancialType.insurance.tintColor));
    });

    test('tintColor is a const — same instance across calls', () {
      expect(
        identical(FinancialType.asset.tintColor, FinancialType.asset.tintColor),
        isTrue,
      );
    });
  });

  group('FinancialTypeX.fromDisplayName', () {
    test('returns asset for "Asset"', () {
      expect(FinancialTypeX.fromDisplayName('Asset'), FinancialType.asset);
    });

    test('returns consumption for "Consumption"', () {
      expect(FinancialTypeX.fromDisplayName('Consumption'),
          FinancialType.consumption);
    });

    test('returns insurance for "Insurance"', () {
      expect(FinancialTypeX.fromDisplayName('Insurance'),
          FinancialType.insurance);
    });

    test('is case-insensitive for all values', () {
      expect(FinancialTypeX.fromDisplayName('asset'), FinancialType.asset);
      expect(FinancialTypeX.fromDisplayName('CONSUMPTION'),
          FinancialType.consumption);
      expect(
          FinancialTypeX.fromDisplayName('iNsUrAnCe'), FinancialType.insurance);
    });

    test('trims leading/trailing whitespace before matching', () {
      expect(
          FinancialTypeX.fromDisplayName('  Asset  '), FinancialType.asset);
    });

    test('empty string returns consumption', () {
      expect(
          FinancialTypeX.fromDisplayName(''), FinancialType.consumption);
    });

    test('whitespace-only string returns consumption', () {
      expect(
          FinancialTypeX.fromDisplayName('   '), FinancialType.consumption);
    });

    test('unknown value returns consumption', () {
      expect(
          FinancialTypeX.fromDisplayName('unknown'), FinancialType.consumption);
      expect(FinancialTypeX.fromDisplayName('xyz'), FinancialType.consumption);
    });
  });
}
