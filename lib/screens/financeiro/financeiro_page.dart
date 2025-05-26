// lib/screens/financeiro/financeiro_page.dart
import 'package:flutter/material.dart';
import 'faturamento_tab.dart';
import 'contas_a_pagar_tab.dart';
import 'resumo_geral_tab.dart';

class FinanceiroPage extends StatefulWidget {
  const FinanceiroPage({super.key});

  @override
  _FinanceiroPageState createState() => _FinanceiroPageState();
}

class _FinanceiroPageState extends State<FinanceiroPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Módulo Financeiro'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(
              child: Text(
                'Faturamento',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ), // ajuste como quiser
              ),
            ),
            Tab(
              child: Text(
                'Contas a Pagar',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
              ),
            ),
            Tab(
              child: Text(
                'Resumo Geral',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
              ),
            ),
          ],
          labelStyle: const TextStyle(fontSize: 16),
          labelPadding: const EdgeInsets.symmetric(horizontal: 16),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [FaturamentoTab(), ContasAPagarTab(), ResumoGeralTab()],
      ),
    );
  }
}
