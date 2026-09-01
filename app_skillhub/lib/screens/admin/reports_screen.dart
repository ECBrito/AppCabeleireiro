import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../config/theme.dart';
import '../../providers/app_provider.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  // Estado local para o filtro
  String _selectedPeriod = "Semana";
  final List<String> _periods = ["Semana", "Mês", "Ano"];

  void _exportReport(Color color) {
    // Simulação de exportação PDF/Excel
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: const [
            Icon(Icons.download_done, color: Colors.white),
            SizedBox(width: 10),
            Text("Relatório exportado para PDF!"),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final themeColor = provider.getThemeColor();
    
    // DADOS REAIS DO PROVIDER
    final revenue = provider.getRevenueByPeriod(_selectedPeriod);
    final growth = provider.getGrowthPercentage(_selectedPeriod);
    final topServices = provider.getTopServices();
    final chartData = provider.getWeeklyChartData();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Performance'),
        backgroundColor: AppColors.background,
        iconTheme: IconThemeData(color: themeColor),
        actions: [
          // BOTÃO EXPORTAR (Ponto 3 do pedido)
          IconButton(
            onPressed: () => _exportReport(themeColor),
            icon: const Icon(Icons.download),
            tooltip: "Exportar Relatório",
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. FILTROS DE TEMPO (Ponto 2 do pedido)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white10),
              ),
              child: Row(
                children: _periods.map((period) {
                  final isSelected = _selectedPeriod == period;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedPeriod = period),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected ? themeColor : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          period,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: isSelected ? Colors.black : Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 30),

            // 2. RESUMO FINANCEIRO (Com Comparação)
            Container(
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Lucro ($_selectedPeriod)", style: const TextStyle(color: Colors.grey)),
                      const SizedBox(height: 5),
                      Text(
                        "${revenue.toStringAsFixed(2)}€",
                        style: TextStyle(color: themeColor, fontSize: 32, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  // Ponto 4: Comparação de Performance
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: growth >= 0 ? Colors.green.withValues(alpha: 0.2) : Colors.red.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          growth >= 0 ? Icons.arrow_upward : Icons.arrow_downward,
                          color: growth >= 0 ? Colors.green : Colors.red,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "${growth.abs()}%",
                          style: TextStyle(
                            color: growth >= 0 ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ).animate().fadeIn().slideY(),

            const SizedBox(height: 40),
            
            // 3. GRÁFICO DINÂMICO
            Text("Fluxo de Caixa", style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 20),
            
            Container(
              height: 200,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(chartData.length, (index) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Tooltip(
                        message: "Dia ${index + 1}",
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 500),
                          width: 20,
                          height: 120 * chartData[index], // Altura dinâmica
                          decoration: BoxDecoration(
                            color: themeColor.withValues(alpha: 0.8),
                            borderRadius: BorderRadius.circular(6),
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [themeColor.withValues(alpha: 0.4), themeColor],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        ["S","T","Q","Q","S","S","D"][index], 
                        style: const TextStyle(color: Colors.grey, fontSize: 12)
                      ),
                    ],
                  );
                }),
              ),
            ),

            const SizedBox(height: 40),
            
            // 4. TOP SERVIÇOS (LIGADO AOS DADOS REAIS)
            Text("Top Serviços", style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 15),
            
            if (topServices.isEmpty)
              const Padding(
                padding: EdgeInsets.all(20),
                child: Text("Sem dados suficientes.", style: TextStyle(color: Colors.grey)),
              )
            else
              ...topServices.map((s) => _buildStatRow(
                  s['name'], 
                  s['percent'], 
                  (s['value'] as double), 
                  themeColor
              )),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value, double percent, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              Text(value, style: const TextStyle(color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: percent,
              minHeight: 8,
              backgroundColor: Colors.grey[800],
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideX();
  }
}