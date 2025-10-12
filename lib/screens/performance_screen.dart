import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:provider/provider.dart';
import '../services/returns_service.dart';
import '../models/performance_data.dart';

class PerformanceScreen extends StatefulWidget {
  const PerformanceScreen({super.key});

  @override
  State<PerformanceScreen> createState() => _PerformanceScreenState();
}

class _PerformanceScreenState extends State<PerformanceScreen> {
  String _selectedPeriod = '1M';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Consumer<ReturnsService>(
          builder: (context, returnsService, child) {
            // Initialize service if not already done
            if (!returnsService.isInitialized) {
              Future.microtask(() => returnsService.initialize());
            }
            
            return RefreshIndicator(
              onRefresh: () => returnsService.updateAllRecommendations(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with refresh indicator
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Performance Analytics',
                          style: GoogleFonts.roboto(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (returnsService.isUpdating)
                          const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    
                    // Portfolio Summary Cards
                    _buildPortfolioSummary(returnsService, isDark),
                    const SizedBox(height: 20),
                    
                    // Period Selector
                    _buildPeriodSelector(isDark),
                    const SizedBox(height: 20),
                    
                    // Performance Chart
                    _buildPerformanceChart(returnsService, isDark),
                    const SizedBox(height: 20),
                    
                    // Performance Table
                    _buildPerformanceTable(returnsService, isDark),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPortfolioSummary(ReturnsService returnsService, bool isDark) {
    final totalReturn = returnsService.totalPortfolioReturn;
    final totalInvestment = returnsService.totalInvestment;
    final returnPercentage = returnsService.portfolioReturnPercentage;
    final activeStocks = returnsService.getAllPerformanceData().length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Portfolio Summary',
          style: GoogleFonts.roboto(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                'Total Investment',
                '₹${totalInvestment.toStringAsFixed(0)}',
                Icons.account_balance_wallet,
                Colors.blue,
                isDark,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSummaryCard(
                'Total Return',
                '₹${totalReturn >= 0 ? '+' : ''}${totalReturn.toStringAsFixed(0)}',
                Icons.trending_up,
                totalReturn >= 0 ? Colors.green : Colors.red,
                isDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                'Return %',
                '${returnPercentage >= 0 ? '+' : ''}${returnPercentage.toStringAsFixed(2)}%',
                Icons.percent,
                returnPercentage >= 0 ? Colors.green : Colors.red,
                isDark,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSummaryCard(
                'Active Stocks',
                activeStocks.toString(),
                Icons.show_chart,
                Colors.orange,
                isDark,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.roboto(
                    fontSize: 12,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.roboto(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector(bool isDark) {
    final periods = ['1W', '1M', '3M', '6M', '1Y', 'ALL'];

    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: periods.map((period) {
          final isSelected = _selectedPeriod == period;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedPeriod = period;
                });
              },
              child: Container(
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.deepPurple[700] : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    period,
                    style: GoogleFonts.roboto(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? Colors.white
                          : (isDark ? Colors.grey[400] : Colors.grey[600]),
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPerformanceChart(ReturnsService returnsService, bool isDark) {
    final performanceData = returnsService.getAllPerformanceData();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Returns Distribution',
          style: GoogleFonts.roboto(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          height: 300,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? Colors.grey[850] : Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: performanceData.isEmpty
              ? Center(
                  child: Text(
                    'No performance data available',
                    style: GoogleFonts.roboto(
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                )
              : SfCartesianChart(
                  primaryXAxis: CategoryAxis(
                    labelStyle: GoogleFonts.roboto(fontSize: 10),
                  ),
                  primaryYAxis: NumericAxis(
                    labelFormat: '{value}%',
                    labelStyle: GoogleFonts.roboto(fontSize: 10),
                  ),
                  series: <CartesianSeries<PerformanceData, String>>[
                    ColumnSeries<PerformanceData, String>(
                      dataSource: performanceData,
                      xValueMapper: (PerformanceData data, _) => data.ticker,
                      yValueMapper: (PerformanceData data, _) => data.returnPercentage,
                      pointColorMapper: (PerformanceData data, _) => 
                          data.isProfitable ? Colors.green : Colors.red,
                      dataLabelSettings: const DataLabelSettings(
                        isVisible: true,
                        labelAlignment: ChartDataLabelAlignment.top,
                      ),
                    ),
                  ],
                  tooltipBehavior: TooltipBehavior(enable: true),
                ),
        ),
      ],
    );
  }

  Widget _buildPerformanceTable(ReturnsService returnsService, bool isDark) {
    final performanceData = returnsService.getAllPerformanceData();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Detailed Performance',
          style: GoogleFonts.roboto(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: isDark ? Colors.grey[850] : Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: performanceData.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(32),
                  child: Center(
                    child: Text(
                      'No recommendations available',
                      style: GoogleFonts.roboto(
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ),
                )
              : SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    headingRowColor: MaterialStateProperty.all(
                      isDark ? Colors.grey[800] : Colors.grey[100],
                    ),
                    columns: [
                      DataColumn(
                        label: Text('Ticker', style: GoogleFonts.roboto(fontWeight: FontWeight.bold)),
                      ),
                      DataColumn(
                        label: Text('Buy Price', style: GoogleFonts.roboto(fontWeight: FontWeight.bold)),
                      ),
                      DataColumn(
                        label: Text('Current', style: GoogleFonts.roboto(fontWeight: FontWeight.bold)),
                      ),
                      DataColumn(
                        label: Text('Monthly %', style: GoogleFonts.roboto(fontWeight: FontWeight.bold)),
                      ),
                      DataColumn(
                        label: Text('Yearly %', style: GoogleFonts.roboto(fontWeight: FontWeight.bold)),
                      ),
                      DataColumn(
                        label: Text('₹1L Profit', style: GoogleFonts.roboto(fontWeight: FontWeight.bold)),
                      ),
                    ],
                    rows: performanceData.map((data) {
                      return DataRow(
                        cells: [
                          DataCell(
                            Text(
                              data.ticker,
                              style: GoogleFonts.roboto(fontWeight: FontWeight.w600),
                            ),
                          ),
                          DataCell(
                            Text(
                              '₹${data.buyPrice.toStringAsFixed(2)}',
                              style: GoogleFonts.roboto(),
                            ),
                          ),
                          DataCell(
                            Text(
                              '₹${data.currentPrice.toStringAsFixed(2)}',
                              style: GoogleFonts.roboto(),
                            ),
                          ),
                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: data.monthlyReturn >= 0 
                                    ? Colors.green.withOpacity(0.1)
                                    : Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                data.formattedMonthlyReturn,
                                style: GoogleFonts.roboto(
                                  color: data.monthlyReturn >= 0 ? Colors.green : Colors.red,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: data.yearlyReturn >= 0 
                                    ? Colors.green.withOpacity(0.1)
                                    : Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                data.formattedYearlyReturn,
                                style: GoogleFonts.roboto(
                                  color: data.yearlyReturn >= 0 ? Colors.green : Colors.red,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: data.oneLakhProfit >= 0 
                                    ? Colors.green.withOpacity(0.1)
                                    : Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                data.formattedOneLakhProfit,
                                style: GoogleFonts.roboto(
                                  color: data.oneLakhProfit >= 0 ? Colors.green : Colors.red,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
        ),
      ],
    );
  }
}
