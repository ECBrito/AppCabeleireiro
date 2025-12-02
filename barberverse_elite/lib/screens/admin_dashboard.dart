import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../config/theme.dart';
import '../providers/app_provider.dart';
import '../models/appointment_model.dart';
import '../models/worker_model.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  DateTime _selectedDate = DateTime.now();
  bool _isShopOpen = true;

  // --- LÓGICA DE GESTÃO DE TRABALHADORES ---

  void _showWorkerManagementDialog(BuildContext context, {Worker? worker}) {
    final isEditing = worker != null;
    final nameController = TextEditingController(text: worker?.name ?? '');
    final roleController = TextEditingController(text: worker?.role ?? '');
    // Em produção, isto seria um upload de imagem
    final photoUrlController = TextEditingController(text: worker?.photoUrl ?? 'https://randomuser.me/api/portraits/men/1.jpg');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(
          isEditing ? "Editar Profissional" : "Novo Profissional",
          style: const TextStyle(color: Colors.white),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(labelText: "Nome"),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: roleController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(labelText: "Cargo (ex: Barbeiro Sénior)"),
              ),
              const SizedBox(height: 10),
              // Simulação de URL de foto
              TextField(
                controller: photoUrlController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(labelText: "URL da Foto (Opcional)"),
              ),
            ],
          ),
        ),
        actions: [
          // Botão de Apagar (Só aparece se estivermos a editar)
          if (isEditing)
            TextButton(
              onPressed: () {
                // Lógica para remover (Requer adicionar removeWorker no Provider)
                // Provider.of<AppProvider>(context, listen: false).removeWorker(worker.id);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Profissional removido!")));
              },
              child: const Text("Remover", style: TextStyle(color: AppColors.error)),
            ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancelar", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                // Aqui chamaríamos o Provider para guardar
                // final newWorker = Worker(id: ..., name: ..., ...);
                // Provider.of<AppProvider>(context, listen: false).addWorker(newWorker);

                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(isEditing ? "Atualizado com sucesso!" : "Adicionado com sucesso!")),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold),
            child: const Text("GUARDAR", style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final appointments = provider.appointments;
    final totalRevenue = provider.totalRevenue;
    final themeColor = provider.getThemeColor();
    final workers = provider.shopWorkers;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Painel de Gestão', style: TextStyle(fontSize: 20)),
            Text(
              DateFormat('EEEE, d MMMM', 'pt_PT').format(DateTime.now()).toUpperCase(),
              style: TextStyle(fontSize: 12, color: Colors.grey[400], letterSpacing: 1),
            ),
          ],
        ),
        backgroundColor: AppColors.background,
        iconTheme: IconThemeData(color: themeColor),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Configurar Loja',
            onPressed: () => Navigator.pushNamed(context, '/shop_edit'),
          ),
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
            // 1. SWITCH DE ESTADO DA LOJA
            _buildShopStatusToggle(themeColor),
            const SizedBox(height: 20),

            // 2. CARTÃO DE FATURAÇÃO COM GRÁFICO
            _buildRevenueCardWithGraph(totalRevenue, themeColor),
            const SizedBox(height: 25),

            // 3. PERFORMANCE DA EQUIPA (ATUALIZADO)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Equipa em Serviço", style: Theme.of(context).textTheme.titleLarge),
                // Contador de equipa
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(8)),
                  child: Text("${workers.length}", style: const TextStyle(color: Colors.white)),
                ),
              ],
            ),
            const SizedBox(height: 15),
            _buildTeamPerformanceList(workers, themeColor),
            const SizedBox(height: 30),

            // 4. AÇÕES RÁPIDAS
            Text("Gestão Rápida", style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 15),
            _buildQuickActionsGrid(context, themeColor),
            const SizedBox(height: 30),

            // 5. TOP SERVIÇOS DO DIA (NOVO)
            Text("Top Serviços Hoje", style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 15),
            _buildTopServicesList(themeColor),
            const SizedBox(height: 30),

            // 6. ATIVIDADE RECENTE (NOVO)
            Text("Atividade Recente", style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 15),
            _buildRecentActivityList(themeColor),
            const SizedBox(height: 30),

            // 7. AGENDA
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Agenda", style: Theme.of(context).textTheme.titleLarge),
                Icon(Icons.calendar_month, color: themeColor),
              ],
            ),
            const SizedBox(height: 15),
            _buildDateSelector(themeColor),
            const SizedBox(height: 15),

            appointments.isEmpty
                ? _buildEmptyState()
                : _buildAppointmentList(appointments, themeColor),

            const SizedBox(height: 80),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        backgroundColor: themeColor,
        icon: const Icon(Icons.add, color: Colors.black),
        label: const Text("NOVA MARCAÇÃO", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildShopStatusToggle(Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _isShopOpen ? Colors.green.withOpacity(0.5) : Colors.red.withOpacity(0.5),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 10, height: 10,
                decoration: BoxDecoration(
                  color: _isShopOpen ? Colors.green : Colors.red,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: (_isShopOpen ? Colors.green : Colors.red).withOpacity(0.6), blurRadius: 8)],
                ),
              ),
              const SizedBox(width: 12),
              Text(_isShopOpen ? "LOJA ABERTA" : "LOJA FECHADA", style: TextStyle(color: _isShopOpen ? Colors.green : Colors.red, fontWeight: FontWeight.bold)),
            ],
          ),
          Switch(
            value: _isShopOpen,
            activeColor: Colors.green,
            onChanged: (val) => setState(() => _isShopOpen = val),
          ),
        ],
      ),
    ).animate().fadeIn();
  }

  Widget _buildRevenueCardWithGraph(double revenue, Color themeColor) {
    // Dados fictícios para o gráfico
    final List<double> weeklyData = [0.4, 0.6, 0.3, 0.8, 0.5, 0.9, 0.7];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [themeColor.withOpacity(0.9), themeColor.withOpacity(0.6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: themeColor.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Faturação Hoje", style: GoogleFonts.lato(color: Colors.black87, fontWeight: FontWeight.bold)),
                  Text("${revenue.toStringAsFixed(2)}€", style: GoogleFonts.playfairDisplay(color: Colors.black, fontSize: 36, fontWeight: FontWeight.w900)),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.trending_up, color: Colors.black, size: 28),
              )
            ],
          ),
          const SizedBox(height: 20),
          // Mini Gráfico de Barras
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: weeklyData.map((level) {
              return Tooltip(
                message: "Dia: ${(level * 1000).toInt()}€",
                child: Container(
                  width: 8,
                  height: 40 * level,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 5),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("S", style: TextStyle(fontSize: 10, color: Colors.black54)),
              Text("T", style: TextStyle(fontSize: 10, color: Colors.black54)),
              Text("Q", style: TextStyle(fontSize: 10, color: Colors.black54)),
              Text("Q", style: TextStyle(fontSize: 10, color: Colors.black54)),
              Text("S", style: TextStyle(fontSize: 10, color: Colors.black54)),
              Text("S", style: TextStyle(fontSize: 10, color: Colors.black54)),
              Text("D", style: TextStyle(fontSize: 10, color: Colors.black54)),
            ],
          )
        ],
      ),
    ).animate().scale(duration: 500.ms, curve: Curves.easeOutBack);
  }

  Widget _buildTeamPerformanceList(List<Worker> workers, Color color) {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        // +1 para incluir o botão de adicionar
        itemCount: workers.length + 1,
        itemBuilder: (context, index) {
          // O primeiro item é sempre o botão de adicionar
          if (index == 0) {
            return GestureDetector(
              onTap: () => _showWorkerManagementDialog(context),
              child: Container(
                width: 70,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: color.withOpacity(0.5), style: BorderStyle.solid),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add, color: color, size: 30),
                    const SizedBox(height: 4),
                    Text("Novo", style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            );
          }

          final worker = workers[index - 1];
          return GestureDetector(
            onTap: () => _showWorkerManagementDialog(context, worker: worker),
            child: Container(
              width: 140,
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white10),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundImage: NetworkImage(worker.photoUrl),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    worker.name.split(' ')[0],
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text("4 Cortes", style: TextStyle(color: color, fontSize: 12)),
                ],
              ),
            ).animate().fadeIn(delay: (100 * index).ms).slideX(),
          );
        },
      ),
    );
  }

  Widget _buildQuickActionsGrid(BuildContext context, Color color) {
    final actions = [
      {'title': 'Serviços', 'icon': Icons.content_cut, 'route': '/services_manage'},
      {'title': 'Clientes', 'icon': Icons.people, 'route': null},
      {'title': 'Promoções', 'icon': Icons.local_offer, 'route': null},
      {'title': 'Relatórios', 'icon': Icons.bar_chart, 'route': null},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
        childAspectRatio: 2.5,
      ),
      itemCount: actions.length,
      itemBuilder: (context, index) {
        final action = actions[index];
        return InkWell(
          onTap: () => action['route'] != null
              ? Navigator.pushNamed(context, action['route'] as String)
              : ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Em breve!"), backgroundColor: color)),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withOpacity(0.2)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(action['icon'] as IconData, color: color, size: 20),
                const SizedBox(width: 10),
                Text(action['title'] as String, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTopServicesList(Color color) {
    final services = [
      {"name": "Corte Clássico", "count": "12", "trend": "+2"},
      {"name": "Barba Mestre", "count": "8", "trend": "-1"},
      {"name": "Combo King", "count": "5", "trend": "+3"},
    ];

    return Column(
      children: services.map((s) => Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border(left: BorderSide(color: s['trend'].toString().contains('+') ? Colors.green : Colors.red, width: 3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(s['name']!, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            Row(
              children: [
                Text("${s['count']} pedidos", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: s['trend'].toString().contains('+') ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(s['trend']!, style: TextStyle(color: s['trend'].toString().contains('+') ? Colors.green : Colors.red, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ],
        ),
      )).toList(),
    );
  }

  Widget _buildRecentActivityList(Color color) {
    final activities = [
      {"text": "Nova marcação de João Silva", "time": "5 min atrás", "icon": Icons.bookmark_added},
      {"text": "Carlos terminou corte", "time": "15 min atrás", "icon": Icons.check_circle},
      {"text": "Inventário baixo: Gel", "time": "1h atrás", "icon": Icons.warning},
    ];

    return Column(
      children: activities.map((act) => ListTile(
        contentPadding: EdgeInsets.zero,
        leading: CircleAvatar(
          backgroundColor: Colors.white10,
          radius: 18,
          child: Icon(act['icon'] as IconData, color: color, size: 18),
        ),
        title: Text(act['text'] as String, style: const TextStyle(color: Colors.white70, fontSize: 14)),
        trailing: Text(act['time'] as String, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      )).toList(),
    );
  }

  Widget _buildDateSelector(Color color) {
    return SizedBox(
      height: 70,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 14,
        itemBuilder: (context, index) {
          final date = DateTime.now().add(Duration(days: index));
          final isSelected = date.day == _selectedDate.day && date.month == _selectedDate.month;

          return GestureDetector(
            onTap: () => setState(() => _selectedDate = date),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 55,
              margin: const EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                color: isSelected ? color : AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: isSelected ? null : Border.all(color: Colors.white10),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('E', 'pt_PT').format(date).toUpperCase(),
                    style: TextStyle(color: isSelected ? Colors.black : Colors.grey, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    date.day.toString(),
                    style: TextStyle(color: isSelected ? Colors.black : Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(child: Padding(padding: EdgeInsets.all(40), child: Text("Sem marcações.", style: TextStyle(color: Colors.grey))));
  }

  Widget _buildAppointmentList(List<Appointment> appointments, Color color) {
    final sortedList = List.from(appointments.reversed);
    return Column(
      children: sortedList.map((appt) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border(left: BorderSide(color: color, width: 4)),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            title: Text(appt.clientName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            subtitle: Text("${appt.serviceName} • ${DateFormat('HH:mm').format(appt.date)}", style: TextStyle(color: Colors.grey[400])),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text("${appt.price.toStringAsFixed(2)}€", style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16)),
                Text(appt.workerName, style: const TextStyle(color: Colors.white54, fontSize: 10)),
              ],
            ),
          ),
        ).animate().fadeIn().slideY(begin: 0.1, end: 0);
      }).toList(),
    );
  }
}