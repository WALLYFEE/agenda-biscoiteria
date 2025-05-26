import 'package:flutter/material.dart';
import '../../widgets/lista_pedidos_tab.dart';
import '../../widgets/menu_drawer.dart'; // <--- Importa aqui!
import '../financeiro/financeiro_page.dart';

class MainTabsPage extends StatefulWidget {
  const MainTabsPage({Key? key}) : super(key: key);

  @override
  State<MainTabsPage> createState() => _MainTabsPageState();
}

class _MainTabsPageState extends State<MainTabsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pedidos')),
      drawer: MenuDrawer(
        onFinanceiro: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const FinanceiroPage()),
          );
        },
      ),
      body: const ListaPedidosTab(),
    );
  }
}
