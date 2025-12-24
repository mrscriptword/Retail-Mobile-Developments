import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class AnalyticsDashboard extends StatefulWidget {
  final List<dynamic> transactions;
  final List<dynamic> products;

  const AnalyticsDashboard({
    super.key,
    required this.transactions,
    required this.products,
  });

  @override
  State<AnalyticsDashboard> createState() => _AnalyticsDashboardState();
}

class _AnalyticsDashboardState extends State<AnalyticsDashboard> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Hitung total penjualan
    final totalSales = widget.transactions.fold<int>(
      0,
      (sum, item) => sum + (item['totalHarga'] as int? ?? 0),
    );

    // Hitung transaksi hari ini
    final today = DateTime.now();
    final todaySales = widget.transactions
        .where((item) {
          final date = DateTime.tryParse(item['tanggal'].toString());
          return date != null &&
              date.year == today.year &&
              date.month == today.month &&
              date.day == today.day;
        })
        .fold<int>(0, (sum, item) => sum + (item['totalHarga'] as int? ?? 0));

    // Produk terlaris
    final bestSelling = _getBestSellingProduct();

    // Data 7 hari terakhir
    final chartData = _getLast7DaysData();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Summary Cards
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          children: [
            _buildSummaryCard(
              title: 'Total Penjualan',
              value: 'Rp $totalSales',
              icon: Icons.trending_up,
              color: Colors.green,
              isDark: isDark,
              theme: theme,
            ),
            _buildSummaryCard(
              title: 'Penjualan Hari Ini',
              value: 'Rp $todaySales',
              icon: Icons.calendar_today,
              color: Colors.blue,
              isDark: isDark,
              theme: theme,
            ),
            _buildSummaryCard(
              title: 'Total Produk',
              value: '${widget.products.length}',
              icon: Icons.inventory,
              color: Colors.orange,
              isDark: isDark,
              theme: theme,
            ),
            _buildSummaryCard(
              title: 'Transaksi',
              value: '${widget.transactions.length}',
              icon: Icons.receipt,
              color: Colors.purple,
              isDark: isDark,
              theme: theme,
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Produk Terlaris
        Text(
          'Produk Terlaris',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        if (bestSelling != null)
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.dividerColor),
              color: isDark ? Colors.grey[900] : Colors.grey[50],
            ),
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF00BCD4), Color(0xFFE91E63)],
                    ),
                  ),
                  child: const Icon(Icons.star, color: Colors.white, size: 30),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        bestSelling['namaBuah'] ?? 'Produk',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Terjual: ${bestSelling['totalJumlah']} kg',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  'Rp ${bestSelling['totalPenjualan']}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: const Color(0xFF00BCD4),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          )
        else
          Text(
            'Belum ada transaksi',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
        const SizedBox(height: 24),

        // Chart 7 Hari Terakhir
        Text(
          'Tren Penjualan (7 Hari Terakhir)',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.dividerColor),
            color: isDark ? Colors.grey[900] : Colors.grey[50],
          ),
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            height: 300,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: true,
                  horizontalInterval: 500000,
                  verticalInterval: 1,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: theme.dividerColor,
                      strokeWidth: 1,
                    );
                  },
                  getDrawingVerticalLine: (value) {
                    return FlLine(
                      color: theme.dividerColor,
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const titles = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
                        if (value.toInt() < titles.length) {
                          return Text(
                            titles[value.toInt()],
                            style: const TextStyle(fontSize: 10),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          'Rp ${(value / 1000000).toStringAsFixed(1)}M',
                          style: const TextStyle(fontSize: 10),
                        );
                      },
                      reservedSize: 50,
                    ),
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(color: theme.dividerColor),
                ),
                minX: 0,
                maxX: 6,
                minY: 0,
                maxY: _getMaxYValue(chartData),
                lineBarsData: [
                  LineChartBarData(
                    spots: chartData,
                    isCurved: true,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF00BCD4), Color(0xFFE91E63)],
                    ),
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) =>
                          FlDotCirclePainter(
                        radius: 5,
                        color: const Color(0xFF00BCD4),
                        strokeWidth: 2,
                        strokeColor: Colors.white,
                      ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF00BCD4).withOpacity(0.3),
                          const Color(0xFFE91E63).withOpacity(0.0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required bool isDark,
    required ThemeData theme,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor),
        color: isDark ? Colors.grey[900] : Colors.grey[50],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withOpacity(0.2),
                ),
                padding: const EdgeInsets.all(8),
                child: Icon(icon, color: color, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  dynamic _getBestSellingProduct() {
    final salesByProduct = <String, Map<String, dynamic>>{};

    for (var item in widget.transactions) {
      final name = item['namaBuah'] ?? 'Unknown';
      if (!salesByProduct.containsKey(name)) {
        salesByProduct[name] = {
          'namaBuah': name,
          'totalJumlah': 0,
          'totalPenjualan': 0,
        };
      }
      salesByProduct[name]!['totalJumlah'] += item['jumlah'] as int? ?? 0;
      salesByProduct[name]!['totalPenjualan'] += item['totalHarga'] as int? ?? 0;
    }

    if (salesByProduct.isEmpty) return null;

    var best = salesByProduct.values.first;
    for (var product in salesByProduct.values) {
      if ((product['totalJumlah'] as int) > (best['totalJumlah'] as int)) {
        best = product;
      }
    }
    return best;
  }

  List<FlSpot> _getLast7DaysData() {
    final now = DateTime.now();
    final last7Days = <FlSpot>[];

    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final salesOnDate = widget.transactions
          .where((item) {
            final txDate = DateTime.tryParse(item['tanggal'].toString());
            return txDate != null &&
                txDate.year == date.year &&
                txDate.month == date.month &&
                txDate.day == date.day;
          })
          .fold<int>(0, (sum, item) => sum + (item['totalHarga'] as int? ?? 0));

      last7Days.add(FlSpot((6 - i).toDouble(), salesOnDate.toDouble()));
    }

    return last7Days;
  }

  double _getMaxYValue(List<FlSpot> data) {
    if (data.isEmpty) return 1000000;
    final max = data.map((e) => e.y).reduce((a, b) => a > b ? a : b);
    return (max * 1.2).toInt().toDouble();
  }
}
