class YearMonth implements Comparable<YearMonth> {
  final int year;
  final int month;

  const YearMonth(this.year, this.month);

  factory YearMonth.now() {
    final now = DateTime.now();
    return YearMonth(now.year, now.month);
  }

  YearMonth addMonths(int n) {
    final totalMonths = (year * 12 + month - 1) + n;
    return YearMonth(totalMonths ~/ 12, totalMonths % 12 + 1);
  }

  bool isBefore(YearMonth other) =>
      year < other.year || (year == other.year && month < other.month);

  bool isAfter(YearMonth other) =>
      year > other.year || (year == other.year && month > other.month);

  bool isAtOrBefore(YearMonth other) => !isAfter(other);

  bool isAtOrAfter(YearMonth other) => !isBefore(other);

  @override
  int compareTo(YearMonth other) {
    if (year != other.year) return year.compareTo(other.year);
    return month.compareTo(other.month);
  }

  @override
  bool operator ==(Object other) =>
      other is YearMonth && year == other.year && month == other.month;

  @override
  int get hashCode => year * 100 + month;

  @override
  String toString() => '$year-${month.toString().padLeft(2, '0')}';

  Map<String, dynamic> toJson() => {'year': year, 'month': month};

  factory YearMonth.fromJson(Map<String, dynamic> json) =>
      YearMonth(json['year'] as int, json['month'] as int);
}
