import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/expense_controller.dart';
import '../utils/currency_utils.dart';
import '../widgets/dart_theme.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DarkTheme.background,
      body: Obx(() {
        final ec = Get.find<ExpenseController>();
        return Column(
          children: [
            _buildHeader(context, ec),
            Expanded(
              child: TabBarView(
                controller: _tab,
                children: [
                  _ComparisonTab(ec: ec),
                  _PieTab(ec: ec),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildHeader(BuildContext context, ExpenseController ec) {
    return Stack(
      children: [
        // Background gradient
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1A1630), DarkTheme.background],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          height: 300,
        ),
        // Purple orb top-right
        Positioned(
          top: -50,
          right: -40,
          child: Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  DarkTheme.primary.withOpacity(0.2),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        // Green orb bottom-left
        Positioned(
          bottom: 0,
          left: 10,
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  DarkTheme.success.withOpacity(0.08),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        // Content
        Padding(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 12,
            left: 20,
            right: 20,
            bottom: 0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: DarkTheme.border),
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: DarkTheme.textSecondary,
                        size: 15,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Analytics',
                    style: TextStyle(
                      color: DarkTheme.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Balance hero card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.04),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: DarkTheme.border),
                ),
                child: Column(
                  children: [
                    // Month label
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.calendar_today_outlined,
                          color: DarkTheme.textMuted,
                          size: 13,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          ec.monthLabel,
                          style: const TextStyle(
                            color: DarkTheme.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Big balance number
                    Text(
                      ec.isOverBudget
                          ? '-${CurrencyUtils.format(ec.totalSpent - ec.monthlyBudget.value)}'
                          : '+${CurrencyUtils.format(ec.remainingBalance)}',
                      style: TextStyle(
                        color: ec.isOverBudget
                            ? DarkTheme.danger
                            : DarkTheme.success,
                        fontSize: 36,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -1.5,
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      ec.isOverBudget ? 'Over Budget' : 'General Balance',
                      style: const TextStyle(
                        color: DarkTheme.textMuted,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Budget / Spent row
                    Row(
                      children: [
                        Expanded(
                          child: _balancePill(
                            'Budget',
                            ec.monthlyBudget.value,
                            DarkTheme.success,
                            Icons.arrow_upward_rounded,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _balancePill(
                            'Spent',
                            ec.totalSpent,
                            DarkTheme.danger,
                            Icons.arrow_downward_rounded,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Tab bar
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.04),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: DarkTheme.border),
                ),
                padding: const EdgeInsets.all(4),
                child: TabBar(
                  controller: _tab,
                  indicator: BoxDecoration(
                    color: DarkTheme.primary.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: DarkTheme.primary.withOpacity(0.4),
                    ),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  labelColor: DarkTheme.primaryLight,
                  unselectedLabelColor: DarkTheme.textMuted,
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                  tabs: const [
                    Tab(text: 'Comparison'),
                    Tab(text: 'Pie Chart'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _balancePill(
      String label,
      double val,
      Color color,
      IconData icon,
      ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 14),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: DarkTheme.textMuted,
                  fontSize: 10,
                  letterSpacing: 0.3,
                ),
              ),
              Text(
                CurrencyUtils.formatCompact(val),
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Comparison Tab ───────────────────────────────────────────────────────────
class _ComparisonTab extends StatelessWidget {
  final ExpenseController ec;
  const _ComparisonTab({required this.ec});

  @override
  Widget build(BuildContext context) {
    final daily = ec.dailySpending;
    if (daily.isEmpty) return const _EmptyState();

    final maxY = daily.values.reduce((a, b) => a > b ? a : b) * 1.3;
    final days = daily.keys.toList()..sort();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      children: [
        // Stat cards row
        Row(
          children: [
            _statCard(
              'Avg / Day',
              CurrencyUtils.formatCompact(ec.avgDailySpend),
              DarkTheme.primary,
              Icons.today_rounded,
            ),
            const SizedBox(width: 10),
            _statCard(
              'Total Spent',
              CurrencyUtils.formatCompact(ec.totalSpent),
              DarkTheme.danger,
              Icons.receipt_rounded,
            ),
            const SizedBox(width: 10),
            _statCard(
              'Transactions',
              ec.monthExpenses.length.toString(),
              DarkTheme.success,
              Icons.list_rounded,
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Bar chart card
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: DarkTheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: DarkTheme.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Daily Spending',
                    style: TextStyle(
                      color: DarkTheme.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: DarkTheme.primary.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: DarkTheme.primary.withOpacity(0.25),
                      ),
                    ),
                    child: Text(
                      ec.monthLabel,
                      style: const TextStyle(
                        color: DarkTheme.primaryLight,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 200,
                child: BarChart(
                  BarChartData(
                    maxY: maxY,
                    barTouchData: BarTouchData(
                      touchTooltipData: BarTouchTooltipData(
                        tooltipBgColor: DarkTheme.surface2,
                        tooltipBorder: const BorderSide(color: DarkTheme.border),
                        tooltipRoundedRadius: 10,
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          return BarTooltipItem(
                            CurrencyUtils.format(rod.toY),
                            const TextStyle(
                              color: DarkTheme.primaryLight,
                              fontWeight: FontWeight.w600,
                              fontSize: 11,
                            ),
                          );
                        },
                      ),
                    ),
                    barGroups: days.map((d) {
                      return BarChartGroupData(
                        x: d,
                        barRods: [
                          BarChartRodData(
                            toY: daily[d]!,
                            gradient: const LinearGradient(
                              colors: [DarkTheme.primary, DarkTheme.primaryLight],
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                            ),
                            width: 10,
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(6),
                            ),
                            backDrawRodData: BackgroundBarChartRodData(
                              show: true,
                              toY: maxY,
                              color: Colors.white.withOpacity(0.03),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                    borderData: FlBorderData(show: false),
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      getDrawingHorizontalLine: (_) => FlLine(
                        color: Colors.white.withOpacity(0.05),
                        strokeWidth: 1,
                      ),
                    ),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 46,
                          getTitlesWidget: (v, _) => Text(
                            CurrencyUtils.formatCompact(v),
                            style: const TextStyle(
                              color: DarkTheme.textMuted,
                              fontSize: 9,
                            ),
                          ),
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 26,
                          getTitlesWidget: (v, _) => Text(
                            v.toInt().toString(),
                            style: const TextStyle(
                              color: DarkTheme.textMuted,
                              fontSize: 9,
                            ),
                          ),
                        ),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Spending insight card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: DarkTheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: DarkTheme.border),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: DarkTheme.warning.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.lightbulb_outline_rounded,
                  color: DarkTheme.warning,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Spending Insight',
                      style: TextStyle(
                        color: DarkTheme.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Your avg daily spend is ${CurrencyUtils.formatCompact(ec.avgDailySpend)}. '
                          'Keep it up to stay within budget!',
                      style: const TextStyle(
                        color: DarkTheme.textSecondary,
                        fontSize: 11,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _statCard(String label, String val, Color color, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: DarkTheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: DarkTheme.border),
        ),
        child: Column(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(height: 8),
            Text(
              val,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                color: DarkTheme.textMuted,
                fontSize: 10,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Pie Tab ──────────────────────────────────────────────────────────────────
class _PieTab extends StatefulWidget {
  final ExpenseController ec;
  const _PieTab({required this.ec});

  @override
  State<_PieTab> createState() => _PieTabState();
}

class _PieTabState extends State<_PieTab> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final bd = widget.ec.categoryBreakdown;
    if (bd.isEmpty) return const _EmptyState();

    final total = bd.values.fold(0.0, (a, b) => a + b);
    final entries = bd.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final sections = entries.asMap().entries.map((entry) {
      final i = entry.key;
      final e = entry.value;
      final color = widget.ec.colorOf(e.key);
      final isTouched = i == _touchedIndex;
      return PieChartSectionData(
        color: color,
        value: e.value,
        title: isTouched
            ? '${(e.value / total * 100).toStringAsFixed(1)}%'
            : '',
        titleStyle: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
        radius: isTouched ? 82 : 70,
        badgeWidget: isTouched
            ? Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.4),
                blurRadius: 8,
              ),
            ],
          ),
          child: Text(
            '${(e.value / total * 100).toStringAsFixed(1)}%',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        )
            : null,
        badgePositionPercentageOffset: 1.1,
      );
    }).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      children: [
        // Pie chart card
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: DarkTheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: DarkTheme.border),
          ),
          child: Column(
            children: [
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Category Breakdown',
                  style: TextStyle(
                    color: DarkTheme.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Tap a slice to see percentage',
                  style: TextStyle(
                    color: DarkTheme.textMuted,
                    fontSize: 11,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 220,
                child: PieChart(
                  PieChartData(
                    sections: sections,
                    centerSpaceRadius: 52,
                    sectionsSpace: 2,
                    borderData: FlBorderData(show: false),
                    pieTouchData: PieTouchData(
                      touchCallback: (event, response) {
                        setState(() {
                          if (!event.isInterestedForInteractions ||
                              response == null ||
                              response.touchedSection == null) {
                            _touchedIndex = -1;
                            return;
                          }
                          _touchedIndex =
                              response.touchedSection!.touchedSectionIndex;
                        });
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Mini legend row
              Wrap(
                spacing: 10,
                runSpacing: 8,
                children: entries.map((e) {
                  final color = widget.ec.colorOf(e.key);
                  final catName =
                      widget.ec.categoryById(e.key)?.name ?? 'Unknown';
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        catName.length > 10
                            ? catName.substring(0, 10)
                            : catName,
                        style: const TextStyle(
                          color: DarkTheme.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Category list
        ...entries.map((e) {
          final color = widget.ec.colorOf(e.key);
          final icon = widget.ec.iconOf(e.key);
          final catName = widget.ec.categoryById(e.key)?.name ?? 'Unknown';
          final pct = e.value / total * 100;

          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: DarkTheme.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: DarkTheme.border),
            ),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.14),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        catName,
                        style: const TextStyle(
                          color: DarkTheme.textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 6),
                      // Gradient progress bar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: SizedBox(
                          height: 4,
                          child: Stack(
                            children: [
                              Container(
                                color: Colors.white.withOpacity(0.06),
                              ),
                              FractionallySizedBox(
                                widthFactor: (pct / 100).clamp(0.0, 1.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        color,
                                        color.withOpacity(0.5),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      CurrencyUtils.format(e.value),
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${pct.toStringAsFixed(1)}%',
                        style: TextStyle(
                          color: color,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}

// ─── Empty State ──────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: DarkTheme.surface,
              shape: BoxShape.circle,
              border: Border.all(color: DarkTheme.border),
            ),
            child: const Icon(
              Icons.bar_chart_rounded,
              color: DarkTheme.textMuted,
              size: 32,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'No data this month',
            style: TextStyle(color: DarkTheme.textSecondary, fontSize: 14),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}
