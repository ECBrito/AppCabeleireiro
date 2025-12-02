import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../config/theme.dart';
import '../providers/app_provider.dart';
import '../models/appointment_model.dart';

class WorkerDashboard extends StatefulWidget {
  const WorkerDashboard({super.key});

  @override
  State<WorkerDashboard> createState() => _WorkerDashboardState();
}

class _WorkerDashboardState extends State<WorkerDashboard> {
  bool _isOnDuty = true; // Estado: Disponível ou Em Pausa
  int _selectedTab = 0; // 0: Pendentes, 1: Histórico

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    // Em produção, filtrarias aqui pelo ID do utilizador logado:
    // final myAppointments = provider.appointments.where((a) => a.workerId == currentUser.id).toList();
    // Para teste, vamos mostrar todas as marcações:
    final myAppointments = provider.appointments;

    // Calcula comissão simulada (ex: 40% do valor total)
    final double totalRevenue = provider.totalRevenue;
    final double myCommission = totalRevenue * 0.40;
    final double myTips = 45.50; // Valor simulado de gorjetas

    final themeColor = provider.getThemeColor();

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('A Minha Agenda', style: TextStyle(fontSize: 20)),
            Text(
              DateFormat('EEEE, d MMMM', 'pt_PT').format(DateTime.now()).toUpperCase(),
              style: TextStyle(fontSize: 12, color: Colors.grey[400], letterSpacing: 1),
            ),
          ],
        ),
        backgroundColor: AppColors.background,
        iconTheme: IconThemeData(color: themeColor),
        actions: [
          // Barbeiro não tem acesso às configurações da loja, apenas logout
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sair',
            onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. SWITCH "EM SERVIÇO"
            _buildStatusToggle(themeColor),
            const SizedBox(height: 25),

            // 2. ESTATÍSTICAS PESSOAIS (Com Scroll Horizontal para caber mais)
            // CORREÇÃO: Aumentei a altura de 140 para 170 para evitar overflow
            SizedBox(
              height: 170,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  SizedBox(
                      width: 150, // Aumentei ligeiramente a largura
                      child: _buildStatCard("Clientes", "${myAppointments.length}", Icons.content_cut, themeColor)
                  ),
                  const SizedBox(width: 15),
                  SizedBox(
                      width: 150,
                      child: _buildStatCard("Comissão", "${myCommission.toStringAsFixed(2)}€", Icons.euro, Colors.green)
                  ),
                  const SizedBox(width: 15),
                  SizedBox(
                      width: 150,
                      child: _buildStatCard("Gorjetas", "${myTips.toStringAsFixed(2)}€", Icons.favorite, Colors.pinkAccent)
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // 3. PERFORMANCE SEMANAL (NOVO)
            Text("Minha Performance", style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 15),
            _buildWeeklyPerformance(themeColor),
            const SizedBox(height: 30),

            // 4. ABAS DE LISTAGEM (NOVO)
            Row(
              children: [
                _buildTabButton("Próximos", 0, themeColor),
                const SizedBox(width: 15),
                _buildTabButton("Histórico", 1, themeColor),
              ],
            ),
            const SizedBox(height: 15),

            // Lista Dinâmica baseada na Aba
            _selectedTab == 0
                ? (myAppointments.isEmpty
                ? _buildEmptyState()
                : _buildAppointmentList(myAppointments, themeColor))
                : _buildHistoryList(), // Lista de histórico

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton(String text, int index, Color color) {
    final isSelected = _selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? color : Colors.grey.withOpacity(0.5)),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.grey,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildWeeklyPerformance(Color color) {
    final data = [0.4, 0.7, 0.2, 0.9, 0.6, 0.8, 0.5]; // Dados dummy (0.0 a 1.0)
    final days = ["S", "T", "Q", "Q", "S", "S", "D"];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(data.length, (index) {
          return Column(
            children: [
              Container(
                width: 8,
                height: 60 * data[index],
                decoration: BoxDecoration(
                  color: color.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(4),
                ),
              ).animate().scaleY(duration: 600.ms, curve: Curves.easeOutBack),
              const SizedBox(height: 8),
              Text(days[index], style: const TextStyle(color: Colors.grey, fontSize: 10)),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildStatusToggle(Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isOnDuty ? Colors.green.withOpacity(0.5) : Colors.red.withOpacity(0.5),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 12, height: 12,
                decoration: BoxDecoration(
                  color: _isOnDuty ? Colors.green : Colors.red,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: (_isOnDuty ? Colors.green : Colors.red).withOpacity(0.6),
                      blurRadius: 8,
                      spreadRadius: 2,
                    )
                  ],
                ),
              ),
              const SizedBox(width: 15),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _isOnDuty ? "DISPONÍVEL" : "EM PAUSA",
                    style: TextStyle(
                      color: _isOnDuty ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      letterSpacing: 1,
                    ),
                  ),
                  Text(
                    _isOnDuty ? "A aceitar marcações" : "Não incomodar",
                    style: TextStyle(color: Colors.grey[500], fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
          Switch(
            value: _isOnDuty,
            activeColor: Colors.green,
            inactiveTrackColor: Colors.red.withOpacity(0.2),
            thumbIcon: MaterialStateProperty.resolveWith<Icon?>((states) {
              if (states.contains(MaterialState.selected)) {
                return const Icon(Icons.check, color: Colors.white);
              }
              return const Icon(Icons.close, color: Colors.white);
            }),
            onChanged: (val) => setState(() => _isOnDuty = val),
          ),
        ],
      ),
    ).animate().fadeIn().slideX();
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      // CORREÇÃO: Reduzi o padding de 20 para 16 para ganhar espaço interno
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center, // Centrar verticalmente
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 15),
          // Usa FittedBox para o texto encolher se for muito grande
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            title,
            style: const TextStyle(color: Colors.grey, fontSize: 13),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms).scale();
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          children: [
            Icon(Icons.coffee, size: 60, color: Colors.grey[800]),
            const SizedBox(height: 15),
            const Text("Tudo calmo por agora.", style: TextStyle(color: Colors.grey, fontSize: 16)),
            const Text("Aproveita a pausa!", style: TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildAppointmentList(List<Appointment> appointments, Color color) {
    final sortedList = List.from(appointments.reversed);

    return Column(
      children: sortedList.map((appt) {
        return Container(
          margin: const EdgeInsets.only(bottom: 15),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: CircleAvatar(
                  radius: 25,
                  backgroundColor: AppColors.background,
                  child: Text(
                    appt.clientName.substring(0, 1).toUpperCase(),
                    style: TextStyle(color: color, fontWeight: FontWeight.bold),
                  ),
                ),
                title: Text(
                    appt.clientName,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Row(
                    children: [
                      Icon(Icons.access_time, size: 14, color: color),
                      const SizedBox(width: 4),
                      Text(
                          "${DateFormat('HH:mm').format(appt.date)} • ${appt.serviceName}",
                          style: const TextStyle(color: Colors.grey)
                      ),
                    ],
                  ),
                ),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.green.withOpacity(0.3)),
                  ),
                  child: const Text(
                    "Confirmado",
                    style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              // Botões de Ação Rápida
              Container(
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05))),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextButton.icon(
                        onPressed: () {
                          // Lógica para ver detalhes
                        },
                        icon: const Icon(Icons.info_outline, size: 18, color: Colors.grey),
                        label: const Text("Detalhes", style: TextStyle(color: Colors.grey)),
                      ),
                    ),
                    Container(width: 1, height: 30, color: Colors.white.withOpacity(0.05)),
                    Expanded(
                      child: TextButton.icon(
                        onPressed: () {
                          // Lógica para concluir corte
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Corte de ${appt.clientName} concluído! +Comissão"), backgroundColor: Colors.green),
                          );
                        },
                        icon: const Icon(Icons.check, size: 18, color: Colors.green),
                        label: const Text("Concluir", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1, end: 0);
      }).toList(),
    );
  }

  // Widget simples para simular histórico
  Widget _buildHistoryList() {
    final history = [
      {"name": "Pedro A.", "service": "Barba Mestre", "time": "Ontem", "price": "10.00€"},
      {"name": "Rui Costa", "service": "Corte Clássico", "time": "Ontem", "price": "15.00€"},
    ];

    return Column(
      children: history.map((item) => Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: AppColors.surface.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListTile(
          title: Text(item['name']!, style: const TextStyle(color: Colors.white70)),
          subtitle: Text(item['service']!, style: const TextStyle(color: Colors.grey)),
          trailing: Text(item['price']!, style: const TextStyle(color: Colors.white54)),
        ),
      )).toList(),
    );
  }
}