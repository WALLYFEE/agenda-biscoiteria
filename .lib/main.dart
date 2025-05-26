import 'package:flutter/material.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:provider/provider.dart';

// Modelo para Pedido
class Pedido {
  String tipo;
  String quantidade;
  String valor;
  String valorTotal;
  String desconto;
  String impostoISS;
  String dataEntrega;
  String dataTexto;
  String observacao;
  String emitirNfe;
  bool concluido;

  Pedido({
    required this.tipo,
    required this.quantidade,
    required this.valor,
    required this.valorTotal,
    required this.desconto,
    required this.impostoISS,
    required this.dataEntrega,
    required this.dataTexto,
    required this.observacao,
    required this.emitirNfe,
    required this.concluido,
  });

  Map<String, dynamic> toMap() {
    return {
      'tipo': tipo,
      'quantidade': quantidade,
      'valor': valor,
      'valorTotal': valorTotal,
      'desconto': desconto,
      'impostoISS': impostoISS,
      'dataEntrega': dataEntrega,
      'dataTexto': dataTexto,
      'observacao': observacao,
      'emitirNfe': emitirNfe,
      'concluido': concluido,
    };
  }

  factory Pedido.fromMap(Map<String, dynamic> map) {
    return Pedido(
      tipo: map['tipo'] ?? 'Tipo não informado',
      quantidade: map['quantidade'] ?? '',
      valor: map['valor'] ?? 'R\$ 0,00',
      valorTotal: map['valorTotal'] ?? 'R\$ 0,00',
      desconto: map['desconto'] ?? 'R\$ 0,00',
      impostoISS: map['impostoISS'] ?? 'R\$ 0,00',
      dataEntrega: map['dataEntrega'] ?? '',
      dataTexto: map['dataTexto'] ?? '',
      observacao: map['observacao'] ?? '',
      emitirNfe: map['emitirNfe'] ?? 'Não',
      concluido: map['concluido'] ?? false,
    );
  }
}

// Modelo para Conta a Pagar
class ContaAPagar {
  String descricao;
  String valor;
  String dataVencimento;
  bool pago;

  ContaAPagar({
    required this.descricao,
    required this.valor,
    required this.dataVencimento,
    this.pago = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'descricao': descricao,
      'valor': valor,
      'dataVencimento': dataVencimento,
      'pago': pago,
    };
  }

  factory ContaAPagar.fromMap(Map<String, dynamic> map) {
    return ContaAPagar(
      descricao: map['descricao'] ?? '',
      valor: map['valor'] ?? 'R\$ 0,00',
      dataVencimento: map['dataVencimento'] ?? '',
      pago: map['pago'] ?? false,
    );
  }
}

// Provider para gerenciar Pedidos e Contas
class PedidosProvider with ChangeNotifier {
  List<Pedido> _pedidos = [];
  List<ContaAPagar> _contas = [];
  String _ordenacao = 'padrao';

  List<Pedido> get pedidos => _pedidos;
  List<ContaAPagar> get contas => _contas;
  String get ordenacao => _ordenacao;

  PedidosProvider() {
    carregarDados();
  }

  void carregarDados() async {
    final prefs = await SharedPreferences.getInstance();
    final String? pedidosString = prefs.getString('pedidos');
    if (pedidosString != null) {
      final List<dynamic> pedidosJson = jsonDecode(pedidosString);
      _pedidos = pedidosJson.map((pedido) => Pedido.fromMap(pedido)).toList();
    }
    final String? contasString = prefs.getString('contas');
    if (contasString != null) {
      final List<dynamic> contasJson = jsonDecode(contasString);
      _contas = contasJson.map((conta) => ContaAPagar.fromMap(conta)).toList();
    }
    notifyListeners();
  }

  Future<void> salvarDados() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('pedidos', jsonEncode(_pedidos.map((p) => p.toMap()).toList()));
    await prefs.setString('contas', jsonEncode(_contas.map((c) => c.toMap()).toList()));
  }

  void adicionarPedido(Pedido pedido) {
    _pedidos.add(pedido);
    salvarDados();
    notifyListeners();
  }

  void atualizarPedido(int index, Pedido pedido) {
    if (index >= 0 && index < _pedidos.length) {
      _pedidos[index] = pedido;
      salvarDados();
      notifyListeners();
    }
  }

  void excluirPedido(int index) {
    if (index >= 0 && index < _pedidos.length) {
      _pedidos.removeAt(index);
      salvarDados();
      notifyListeners();
    }
  }

  void concluirPedido(int index) {
    if (index >= 0 && index < _pedidos.length) {
      _pedidos[index].concluido = !_pedidos[index].concluido;
      salvarDados();
      notifyListeners();
    }
  }

  void adicionarConta(ContaAPagar conta) {
    _contas.add(conta);
    salvarDados();
    notifyListeners();
  }

  void atualizarConta(int index, ContaAPagar conta) {
    if (index >= 0 && index < _contas.length) {
      _contas[index] = conta;
      salvarDados();
      notifyListeners();
    }
  }

  void excluirConta(int index) {
    if (index >= 0 && index < _contas.length) {
      _contas.removeAt(index);
      salvarDados();
      notifyListeners();
    }
  }

  void setOrdenacao(String novaOrdenacao) {
    _ordenacao = novaOrdenacao;
    notifyListeners();
  }
}

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => PedidosProvider(),
      child: const NeysApp(),
    ),
  );
}

class NeysApp extends StatelessWidget {
  const NeysApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Agenda Neys',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF7B3F00),
        scaffoldBackgroundColor: const Color(0xFFFFEBEB),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF7B3F00),
          foregroundColor: Colors.white,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFF7B3F00),
        ),
        tabBarTheme: const TabBarTheme(
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Colors.black87),
          bodySmall: TextStyle(color: Colors.black54),
        ),
      ),
      locale: const Locale('pt', 'BR'),
      supportedLocales: const [
        Locale('pt', 'BR'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const TelaLogin(),
    );
  }
}

class TelaLogin extends StatelessWidget {
  const TelaLogin({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/logo.png', height: 400, fit: BoxFit.contain), // Aumentado de 150 para 200
              const SizedBox(height: 32),
              const Text(
                'Bem-vinda, Neys!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF7B3F00),
                ),
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7B3F00),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MainTabsPage(),
                      ),
                    );
                  },
                  child: const Text(
                    'Entrar',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class MainTabsPage extends StatefulWidget {
  const MainTabsPage({super.key});

  @override
  _MainTabsPageState createState() => _MainTabsPageState();
}

class _MainTabsPageState extends State<MainTabsPage> {
  @override
  void initState() {
    super.initState();
  }

  void _mostrarMenu(BuildContext context) {
    showMenu(
      context: context,
      position: const RelativeRect.fromLTRB(100, 56, 0, 0),
      items: [
        PopupMenuItem(
          value: 'financeiro',
          child: const Text('Módulo Financeiro'),
        ),
      ],
    ).then((value) {
      if (value == 'financeiro') {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const FinanceiroPage()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agenda Neys'),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => _mostrarMenu(context),
          ),
        ],
      ),
      body: const PedidosEmAbertoTab(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ListaPedidosTab.mostrarDialogoAdicionar(context);
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class FinanceiroPage extends StatefulWidget {
  const FinanceiroPage({super.key});

  @override
  _FinanceiroPageState createState() => _FinanceiroPageState();
}

class _FinanceiroPageState extends State<FinanceiroPage> with SingleTickerProviderStateMixin {
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
            Tab(text: 'Faturamento'),
            Tab(text: 'Contas a Pagar'),
            Tab(text: 'Resumo Geral'),
          ],
          labelStyle: const TextStyle(fontSize: 16),
          labelPadding: const EdgeInsets.symmetric(horizontal: 16),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          FaturamentoTab(),
          ContasAPagarTab(),
          ResumoGeralTab(),
        ],
      ),
    );
  }
}

class FaturamentoTab extends StatelessWidget {
  const FaturamentoTab({super.key});

  Map<String, List<Pedido>> _getPedidosPorMes(List<Pedido> pedidos) {
    final Map<String, List<Pedido>> pedidosPorMes = {};
    for (var pedido in pedidos) {
      final data = DateTime.parse(pedido.dataEntrega);
      final mes = DateFormat('MMMM yyyy', 'pt_BR').format(data);

      if (!pedidosPorMes.containsKey(mes)) {
        pedidosPorMes[mes] = [];
      }
      pedidosPorMes[mes]!.add(pedido);
    }
    return pedidosPorMes;
  }

  String calcularValorBruto(List<Pedido> pedidos) {
    double total = 0.0;
    for (var pedido in pedidos) {
      String valorStr = pedido.valorTotal
          .replaceAll('R\$ ', '')
          .replaceAll('.', '')
          .replaceAll(',', '.');
      total += double.tryParse(valorStr) ?? 0.0;
    }
    return 'R\$ ${total.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  String calcularDescontoTotal(List<Pedido> pedidos) {
    double total = 0.0;
    for (var pedido in pedidos) {
      String descontoStr = pedido.desconto
          .replaceAll('R\$ ', '')
          .replaceAll('.', '')
          .replaceAll(',', '.');
      total += double.tryParse(descontoStr) ?? 0.0;
    }
    return 'R\$ ${total.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  String calcularImpostoISSTotal(List<Pedido> pedidos) {
    double total = 0.0;
    for (var pedido in pedidos) {
      String issStr = pedido.impostoISS
          .replaceAll('R\$ ', '')
          .replaceAll('.', '')
          .replaceAll(',', '.');
      total += double.tryParse(issStr) ?? 0.0;
    }
    return 'R\$ ${total.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PedidosProvider>(
      builder: (context, provider, child) {
        final pedidosPorMes = _getPedidosPorMes(provider.pedidos);
        final meses = pedidosPorMes.keys.toList()
          ..sort((a, b) {
            final dataA = DateFormat('MMMM yyyy', 'pt_BR').parse(a);
            final dataB = DateFormat('MMMM yyyy', 'pt_BR').parse(b);
            return dataB.compareTo(dataA);
          });

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: meses.isEmpty
                ? [const Center(child: Text('Nenhum faturamento registrado!'))]
                : meses.map((mes) {
                    final pedidosMes = pedidosPorMes[mes]!;
                    final quantidade = pedidosMes.length;
                    final valorBruto = calcularValorBruto(pedidosMes);
                    final descontoTotal = calcularDescontoTotal(pedidosMes);
                    final issTotal = calcularImpostoISSTotal(pedidosMes);

                    return Card(
                      margin: const EdgeInsets.only(bottom: 16.0),
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              mes,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF7B3F00),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text('Quantidade de Pedidos: $quantidade'),
                            Text('Valor Total Bruto: $valorBruto'),
                            Text('Total de Descontos: $descontoTotal'),
                            Text('Total de ISS: $issTotal'),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
          ),
        );
      },
    );
  }
}

class ContasAPagarTab extends StatefulWidget {
  const ContasAPagarTab({super.key});

  @override
  _ContasAPagarTabState createState() => _ContasAPagarTabState();
}

class _ContasAPagarTabState extends State<ContasAPagarTab> {
  final _formKey = GlobalKey<FormState>();
  String descricao = '';
  final valorController = MoneyMaskedTextController(
    decimalSeparator: ',',
    thousandSeparator: '.',
    leftSymbol: 'R\$ ',
  );
  DateTime? dataVencimento = DateTime.now();

  void _mostrarDialogoAdicionar(BuildContext context) {
    final dataController = TextEditingController(
      text: DateFormat('dd/MM/yyyy').format(dataVencimento!),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nova Conta a Pagar'),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Descrição'),
                onChanged: (val) => descricao = val,
              ),
              TextFormField(
                controller: valorController,
                decoration: const InputDecoration(labelText: 'Valor'),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: dataController,
                readOnly: true,
                decoration: const InputDecoration(labelText: 'Data de Vencimento'),
                onTap: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: dataVencimento!,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null && picked != dataVencimento) {
                    dataVencimento = picked;
                    dataController.text = DateFormat('dd/MM/yyyy').format(picked);
                  }
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (descricao.trim().isNotEmpty) {
                final novaConta = ContaAPagar(
                  descricao: descricao.trim(),
                  valor: valorController.text.trim(),
                  dataVencimento: DateFormat('dd/MM/yyyy').format(dataVencimento!),
                );
                Provider.of<PedidosProvider>(context, listen: false)
                    .adicionarConta(novaConta);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Conta adicionada com sucesso!'),
                    backgroundColor: Color(0xFF7B3F00),
                  ),
                );
              }
            },
            child: const Text('Adicionar'),
          ),
        ],
      ),
    );
  }

  void _mostrarDialogoEditar(BuildContext context, int index, ContaAPagar conta) {
    final _formKey = GlobalKey<FormState>();
    String descricaoEdit = conta.descricao;
    final valorControllerEdit = MoneyMaskedTextController(
      decimalSeparator: ',',
      thousandSeparator: '.',
      leftSymbol: 'R\$ ',
      initialValue: double.tryParse(
            conta.valor.replaceAll('R\$ ', '').replaceAll('.', '').replaceAll(',', '.')) ?? 0.0,
    );
    DateTime? dataVencimentoEdit = DateFormat('dd/MM/yyyy').parse(conta.dataVencimento);

    final dataControllerEdit = TextEditingController(text: conta.dataVencimento);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Conta a Pagar'),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                initialValue: descricaoEdit,
                decoration: const InputDecoration(labelText: 'Descrição'),
                onChanged: (val) => descricaoEdit = val,
              ),
              TextFormField(
                controller: valorControllerEdit,
                decoration: const InputDecoration(labelText: 'Valor'),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: dataControllerEdit,
                readOnly: true,
                decoration: const InputDecoration(labelText: 'Data de Vencimento'),
                onTap: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: dataVencimentoEdit!,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null && picked != dataVencimentoEdit) {
                    dataVencimentoEdit = picked;
                    dataControllerEdit.text = DateFormat('dd/MM/yyyy').format(picked);
                  }
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (descricaoEdit.trim().isNotEmpty) {
                final contaAtualizada = ContaAPagar(
                  descricao: descricaoEdit.trim(),
                  valor: valorControllerEdit.text.trim(),
                  dataVencimento: dataControllerEdit.text,
                  pago: conta.pago,
                );
                Provider.of<PedidosProvider>(context, listen: false)
                    .atualizarConta(index, contaAtualizada);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Conta editada com sucesso!'),
                    backgroundColor: Color(0xFF7B3F00),
                  ),
                );
              }
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  void _marcarComoPago(int index, ContaAPagar conta) {
    final provider = Provider.of<PedidosProvider>(context, listen: false);
    conta.pago = !conta.pago;
    provider.atualizarConta(index, conta);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          conta.pago ? 'Conta marcada como paga!' : 'Conta marcada como pendente!',
        ),
        backgroundColor: Color(0xFF7B3F00),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PedidosProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          body: provider.contas.isEmpty
              ? const Center(child: Text('Nenhuma conta a pagar registrada!'))
              : ListView.builder(
                  itemCount: provider.contas.length,
                  itemBuilder: (context, index) {
                    final conta = provider.contas[index];
                    return ListTile(
                      title: Text(conta.descricao),
                      subtitle: Text(
                        'Valor: ${conta.valor} | Vencimento: ${conta.dataVencimento}',
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Color(0xFF7B3F00)),
                            onPressed: () => _mostrarDialogoEditar(context, index, conta),
                          ),
                          IconButton(
                            icon: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              transitionBuilder: (Widget child, Animation<double> animation) {
                                return ScaleTransition(
                                  scale: animation,
                                  child: FadeTransition(
                                    opacity: animation,
                                    child: child,
                                  ),
                                );
                              },
                              child: Icon(
                                conta.pago ? Icons.check_circle : Icons.pending,
                                key: ValueKey<bool>(conta.pago),
                                color: conta.pago ? Colors.green : Colors.orange,
                              ),
                            ),
                            onPressed: () => _marcarComoPago(index, conta),
                          ),
                        ],
                      ),
                    );
                  },
                ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _mostrarDialogoAdicionar(context),
            backgroundColor: const Color(0xFF7B3F00),
            child: const Icon(Icons.add, color: Colors.white),
          ),
        );
      },
    );
  }
}

class ResumoGeralTab extends StatelessWidget {
  const ResumoGeralTab({super.key});

  String calcularValorBrutoTotal(List<Pedido> pedidos) {
    double total = 0.0;
    for (var pedido in pedidos) {
      String valorStr = pedido.valorTotal
          .replaceAll('R\$ ', '')
          .replaceAll('.', '')
          .replaceAll(',', '.');
      total += double.tryParse(valorStr) ?? 0.0;
    }
    return 'R\$ ${total.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  String calcularDescontoTotal(List<Pedido> pedidos) {
    double total = 0.0;
    for (var pedido in pedidos) {
      String descontoStr = pedido.desconto
          .replaceAll('R\$ ', '')
          .replaceAll('.', '')
          .replaceAll(',', '.');
      total += double.tryParse(descontoStr) ?? 0.0;
    }
    return 'R\$ ${total.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  String calcularImpostoISSTotal(List<Pedido> pedidos) {
    double total = 0.0;
    for (var pedido in pedidos) {
      String issStr = pedido.impostoISS
          .replaceAll('R\$ ', '')
          .replaceAll('.', '')
          .replaceAll(',', '.');
      total += double.tryParse(issStr) ?? 0.0;
    }
    return 'R\$ ${total.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  String calcularValorLiquidoTotal(List<Pedido> pedidos) {
    double bruto = 0.0;
    double desconto = 0.0;
    double iss = 0.0;
    for (var pedido in pedidos) {
      String valorStr = pedido.valorTotal
          .replaceAll('R\$ ', '')
          .replaceAll('.', '')
          .replaceAll(',', '.');
      bruto += double.tryParse(valorStr) ?? 0.0;

      String descontoStr = pedido.desconto
          .replaceAll('R\$ ', '')
          .replaceAll('.', '')
          .replaceAll(',', '.');
      desconto += double.tryParse(descontoStr) ?? 0.0;

      String issStr = pedido.impostoISS
          .replaceAll('R\$ ', '')
          .replaceAll('.', '')
          .replaceAll(',', '.');
      iss += double.tryParse(issStr) ?? 0.0;
    }
    double liquido = bruto - desconto - iss;
    return 'R\$ ${liquido.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  String calcularTotalContasAPagar(List<ContaAPagar> contas) {
    double total = 0.0;
    for (var conta in contas) {
      if (!conta.pago) {
        String valorStr = conta.valor
            .replaceAll('R\$ ', '')
            .replaceAll('.', '')
            .replaceAll(',', '.');
        total += double.tryParse(valorStr) ?? 0.0;
      }
    }
    return 'R\$ ${total.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PedidosProvider>(
      builder: (context, provider, child) {
        final totalPedidos = provider.pedidos.length;
        final valorBrutoTotal = calcularValorBrutoTotal(provider.pedidos);
        final descontoTotal = calcularDescontoTotal(provider.pedidos);
        final issTotal = calcularImpostoISSTotal(provider.pedidos);
        final valorLiquidoTotal = calcularValorLiquidoTotal(provider.pedidos);
        final totalContasAPagar = calcularTotalContasAPagar(provider.contas);

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                color: Colors.white,
                child: ListTile(
                  title: const Text(
                    'Total de Pedidos',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF7B3F00)),
                  ),
                  subtitle: Text(
                    '$totalPedidos',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                color: Colors.white,
                child: ListTile(
                  title: const Text(
                    'Faturamento Bruto',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF7B3F00)),
                  ),
                  subtitle: Text(
                    valorBrutoTotal,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                color: Colors.white,
                child: ListTile(
                  title: const Text(
                    'Faturamento Líquido',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF7B3F00)),
                  ),
                  subtitle: Text(
                    valorLiquidoTotal,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                color: Colors.white,
                child: ListTile(
                  title: const Text(
                    'Descontos Totais',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF7B3F00)),
                  ),
                  subtitle: Text(
                    descontoTotal,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                color: Colors.white,
                child: ListTile(
                  title: const Text(
                    'Impostos ISS Totais',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF7B3F00)),
                  ),
                  subtitle: Text(
                    issTotal,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                color: Colors.white,
                child: ListTile(
                  title: const Text(
                    'Total Contas a Pagar',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF7B3F00)),
                  ),
                  subtitle: Text(
                    totalContasAPagar,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class ListaPedidosTab extends StatefulWidget {
  const ListaPedidosTab({super.key});

  static void mostrarDialogoAdicionar(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    String tipo = '';
    String quantidade = '';
    String observacao = '';
    String emitirNfe = 'Não';
    DateTime? dataSelecionada = DateTime.now();

    final valorController = MoneyMaskedTextController(
      decimalSeparator: ',',
      thousandSeparator: '.',
      leftSymbol: 'R\$ ',
    );
    final descontoController = MoneyMaskedTextController(
      decimalSeparator: ',',
      thousandSeparator: '.',
      leftSymbol: 'R\$ ',
    );
    final dataController = TextEditingController(
      text: DateFormat('dd/MM/yyyy').format(dataSelecionada),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Novo Pedido'),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Tipo de biscoito'),
                  onChanged: (val) => tipo = val,
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Quantidade'),
                  keyboardType: TextInputType.number,
                  onChanged: (val) => quantidade = val,
                ),
                TextFormField(
                  controller: valorController,
                  decoration: const InputDecoration(labelText: 'Valor'),
                  keyboardType: TextInputType.number,
                ),
                TextFormField(
                  controller: descontoController,
                  decoration: const InputDecoration(labelText: 'Desconto'),
                  keyboardType: TextInputType.number,
                ),
                TextFormField(
                  controller: dataController,
                  readOnly: true,
                  decoration: const InputDecoration(labelText: 'Data de entrega'),
                  onTap: () async {
                    final DateTime? picked = await showDialog<DateTime>(
                      context: context,
                      builder: (context) => Consumer<PedidosProvider>(
                        builder: (context, provider, child) => CalendarioDialog(
                          pedidos: provider.pedidos,
                          dataInicial: dataSelecionada!,
                        ),
                      ),
                    );
                    if (picked != null && picked != dataSelecionada) {
                      dataSelecionada = picked;
                      dataController.text = DateFormat('dd/MM/yyyy').format(picked);
                    }
                  },
                ),
                DropdownButtonFormField<String>(
                  value: emitirNfe,
                  items: ['Sim', 'Não'].map((value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  decoration: const InputDecoration(labelText: 'Emitir NFe?'),
                  onChanged: (value) {
                    emitirNfe = value!;
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Nome, telefone, observações...'),
                  onChanged: (val) => observacao = val,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (tipo.trim().isNotEmpty) {
                final textoData = dataController.text;
                int quantidadeNum = int.tryParse(quantidade.trim()) ?? 0;
                String valorStr = valorController.text
                    .replaceAll('R\$ ', '')
                    .replaceAll('.', '')
                    .replaceAll(',', '.');
                String descontoStr = descontoController.text
                    .replaceAll('R\$ ', '')
                    .replaceAll('.', '')
                    .replaceAll(',', '.');
                double valorUnitario = double.tryParse(valorStr) ?? 0.0;
                double desconto = double.tryParse(descontoStr) ?? 0.0;
                double valorTotalBase = quantidadeNum * valorUnitario;
                double valorTotal = valorTotalBase - desconto;
                double impostoISS = emitirNfe == 'Sim' ? valorTotalBase * 0.05 : 0.0;

                final novoPedido = Pedido(
                  tipo: tipo.trim(),
                  quantidade: quantidade.trim(),
                  valor: valorController.text.trim(),
                  valorTotal: 'R\$ ${valorTotal.toStringAsFixed(2).replaceAll('.', ',')}',
                  desconto: descontoController.text.trim(),
                  impostoISS: 'R\$ ${impostoISS.toStringAsFixed(2).replaceAll('.', ',')}',
                  dataEntrega: DateFormat('yyyy-MM-dd').format(dataSelecionada!),
                  dataTexto: textoData,
                  observacao: observacao.trim(),
                  emitirNfe: emitirNfe,
                  concluido: false,
                );

                Provider.of<PedidosProvider>(context, listen: false).adicionarPedido(novoPedido);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Pedido adicionado com sucesso!'),
                    backgroundColor: Color(0xFF7B3F00),
                  ),
                );

                Navigator.pop(context);
              }
            },
            child: const Text('Adicionar'),
          ),
        ],
      ),
    );
  }

  @override
  _ListaPedidosTabState createState() => _ListaPedidosTabState();
}

class _ListaPedidosTabState extends State<ListaPedidosTab> {
  String _searchQuery = '';

  Map<String, List<Pedido>> _getPedidosPorMes(List<Pedido> pedidos) {
    final Map<String, List<Pedido>> pedidosPorMes = {};
    for (var pedido in pedidos) {
      if (_searchQuery.isEmpty ||
          pedido.tipo.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          pedido.observacao.toLowerCase().contains(_searchQuery.toLowerCase())) {
        final data = DateTime.parse(pedido.dataEntrega);
        final mesAno = DateFormat('MMMM yyyy', 'pt_BR').format(data);
        if (!pedidosPorMes.containsKey(mesAno)) {
          pedidosPorMes[mesAno] = [];
        }
        pedidosPorMes[mesAno]!.add(pedido);
      }
    }
    return pedidosPorMes;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PedidosProvider>(
      builder: (context, provider, child) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Pesquisar por tipo ou cliente...',
                  hintStyle: const TextStyle(color: Colors.grey),
                  prefixIcon: const Icon(Icons.search, color: Colors.grey, size: 20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.grey, width: 1),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.grey, width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFF7B3F00), width: 1),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                ),
                style: const TextStyle(fontSize: 14),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
            ),
            Expanded(
              child: Builder(
                builder: (context) {
                  final pedidosPorMes = _getPedidosPorMes(provider.pedidos);
                  final meses = pedidosPorMes.keys.toList()
                    ..sort((a, b) {
                      final dataA = DateFormat('MMMM yyyy', 'pt_BR').parse(a);
                      final dataB = DateFormat('MMMM yyyy', 'pt_BR').parse(b);
                      return dataA.compareTo(dataB);
                    });

                  return meses.isEmpty
                      ? const Center(
                          child: Text(
                            'Nenhum pedido encontrado!',
                            style: TextStyle(color: Color(0xFF7B3F00), fontSize: 18),
                          ),
                        )
                      : ListView.builder(
                          itemCount: meses.length,
                          itemBuilder: (context, index) {
                            final mes = meses[index];
                            final pedidosMes = pedidosPorMes[mes]!;
                            return Card(
                              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              child: ListTile(
                                title: Text(
                                  mes,
                                  style: const TextStyle(
                                    color: Color(0xFF7B3F00),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    PageRouteBuilder(
                                      pageBuilder: (context, animation, secondaryAnimation) =>
                                          MesPedidosPage(
                                        mes: mes,
                                        pedidos: pedidosMes,
                                      ),
                                      transitionsBuilder:
                                          (context, animation, secondaryAnimation, child) {
                                        const begin = Offset(1.0, 0.0);
                                        const end = Offset.zero;
                                        const curve = Curves.easeInOut;

                                        var tween = Tween(begin: begin, end: end)
                                            .chain(CurveTween(curve: curve));
                                        var offsetAnimation = animation.drive(tween);

                                        return SlideTransition(
                                          position: offsetAnimation,
                                          child: child,
                                        );
                                      },
                                      transitionDuration: const Duration(milliseconds: 300),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class PedidosEmAbertoTab extends StatefulWidget {
  const PedidosEmAbertoTab({super.key});

  @override
  _PedidosEmAbertoTabState createState() => _PedidosEmAbertoTabState();
}

class _PedidosEmAbertoTabState extends State<PedidosEmAbertoTab> {
  String _searchQuery = '';

  Map<String, Map<String, List<Pedido>>> _getPedidosPorMesDia(List<Pedido> pedidos) {
    final Map<String, Map<String, List<Pedido>>> pedidosPorMesDia = {};
    for (var pedido in pedidos) {
      // Removemos o filtro !pedido.concluido para incluir todos os pedidos
      if (_searchQuery.isEmpty ||
          pedido.tipo.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          pedido.observacao.toLowerCase().contains(_searchQuery.toLowerCase())) {
        final data = DateTime.parse(pedido.dataEntrega);
        final mesAno = DateFormat('MMMM yyyy', 'pt_BR').format(data);
        final dia = DateFormat('dd/MM/yyyy').format(data);

        if (!pedidosPorMesDia.containsKey(mesAno)) {
          pedidosPorMesDia[mesAno] = {};
        }
        if (!pedidosPorMesDia[mesAno]!.containsKey(dia)) {
          pedidosPorMesDia[mesAno]![dia] = [];
        }
        pedidosPorMesDia[mesAno]![dia]!.add(pedido);
      }
    }
    return pedidosPorMesDia;
  }

  List<int> _calcularIndices(String data, List<Pedido> pedidosGlobais) {
    return pedidosGlobais
        .asMap()
        .entries
        .where((entry) => entry.value.dataTexto == data)
        .map((entry) => entry.key)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PedidosProvider>(
      builder: (context, provider, child) {
        // Incluímos todos os pedidos (em aberto e concluídos)
        final pedidos = provider.pedidos;
        final pedidosPorMesDia = _getPedidosPorMesDia(pedidos);
        final meses = pedidosPorMesDia.keys.toList()
          ..sort((a, b) {
            final dataA = DateFormat('MMMM yyyy', 'pt_BR').parse(a);
            final dataB = DateFormat('MMMM yyyy', 'pt_BR').parse(b);
            return dataB.compareTo(dataA);
          });

        return Column(
          children: [
            if (pedidos.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Pesquisar por tipo ou cliente...',
                    hintStyle: const TextStyle(color: Colors.grey),
                    prefixIcon: const Icon(Icons.search, color: Colors.grey, size: 20),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Colors.grey, width: 1),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Colors.grey, width: 1),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFF7B3F00), width: 1),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  ),
                  style: const TextStyle(fontSize: 14),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
              ),
            Expanded(
              child: Builder(
                builder: (context) {
                  return meses.isEmpty
                      ? Center(
                          child: Container(
                            padding: const EdgeInsets.all(16.0),
                            child: const Text(
                              'Nenhum pedido encontrado!',
                              style: TextStyle(color: Color(0xFF7B3F00), fontSize: 18),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )
                      : ListView.builder(
                          itemCount: meses.length,
                          itemBuilder: (context, mesIndex) {
                            final mes = meses[mesIndex];
                            final diasMap = pedidosPorMesDia[mes]!;
                            final dias = diasMap.keys.toList()
                              ..sort((a, b) {
                                final dataA = DateFormat('dd/MM/yyyy').parse(a);
                                final dataB = DateFormat('dd/MM/yyyy').parse(b);
                                // Ordenar dias com pedidos em aberto no topo
                                final pedidosA = diasMap[a]!;
                                final pedidosB = diasMap[b]!;
                                final aConcluido = pedidosA.every((pedido) => pedido.concluido);
                                final bConcluido = pedidosB.every((pedido) => pedido.concluido);
                                if (aConcluido != bConcluido) {
                                  return aConcluido ? 1 : -1; // Em aberto no topo
                                }
                                return dataB.compareTo(dataA); // Ordenação por data descendente
                              });
                            return ExpansionTile(
                              title: Text(
                                mes,
                                style: const TextStyle(
                                  color: Color(0xFF7B3F00),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              children: dias.map((dia) {
                                final pedidosDia = pedidosPorMesDia[mes]![dia]!;
                                final quantidade = pedidosDia.length;
                                final todosConcluidos = pedidosDia.every((pedido) => pedido.concluido);
                                return Card(
                                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  child: ListTile(
                                    leading: Icon(
                                      todosConcluidos ? Icons.check_circle : Icons.pending,
                                      color: todosConcluidos ? Colors.green : Colors.orange,
                                    ),
                                    title: Text(
                                      dia,
                                      style: const TextStyle(
                                        color: Color(0xFF7B3F00),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    subtitle: Text(
                                      '$quantidade pedido${quantidade > 1 ? 's' : ''}',
                                    ),
                                    onTap: () {
                                      if (pedidosDia.isNotEmpty) {
                                        final indices = _calcularIndices(dia, provider.pedidos);
                                        showDialog(
                                          context: context,
                                          builder: (context) => PedidosDiaDialog(
                                            pedidos: pedidosDia,
                                            data: DateFormat('dd/MM/yyyy').parse(dia),
                                            indices: indices,
                                            onPedidoExcluido: () {
                                              setState(() {});
                                            },
                                          ),
                                        );
                                      }
                                    },
                                  ),
                                );
                              }).toList(),
                            );
                          },
                        );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
class MesPedidosPage extends StatefulWidget {
  final String mes;
  final List<Pedido> pedidos;

  const MesPedidosPage({
    super.key,
    required this.mes,
    required this.pedidos,
  });

  @override
  _MesPedidosPageState createState() => _MesPedidosPageState();
}

class _MesPedidosPageState extends State<MesPedidosPage> {
  late List<Pedido> pedidosAtuais;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    pedidosAtuais = List.from(widget.pedidos);
  }

  Map<String, List<Pedido>> _getPedidosPorData() {
    final Map<String, List<Pedido>> pedidosPorData = {};
    for (var pedido in pedidosAtuais) {
      if (_searchQuery.isEmpty ||
          pedido.tipo.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          pedido.observacao.toLowerCase().contains(_searchQuery.toLowerCase())) {
        final dataTexto = pedido.dataTexto;
        if (!pedidosPorData.containsKey(dataTexto)) {
          pedidosPorData[dataTexto] = [];
        }
        pedidosPorData[dataTexto]!.add(pedido);
      }
    }
    return pedidosPorData;
  }

  List<int> _calcularIndices(String data, List<Pedido> pedidosGlobais) {
    return pedidosGlobais
        .asMap()
        .entries
        .where((entry) => entry.value.dataTexto == data)
        .map((entry) => entry.key)
        .toList();
  }

  String calcularValorTotal(List<Pedido> pedidos) {
    double total = 0.0;
    for (var pedido in pedidos) {
      String valorStr = pedido.valorTotal
          .replaceAll('R\$ ', '')
          .replaceAll('.', '')
          .replaceAll(',', '.');
      double valor = double.tryParse(valorStr) ?? 0.0;
      total += valor;
    }
    return 'R\$ ${total.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  void _atualizarPedidos() {
    setState(() {
      final provider = Provider.of<PedidosProvider>(context, listen: false);
      pedidosAtuais = provider.pedidos
          .where((pedido) =>
              DateFormat('MMMM yyyy', 'pt_BR')
                  .format(DateTime.parse(pedido.dataEntrega)) ==
              widget.mes)
          .toList();

      if (pedidosAtuais.isEmpty) {
        Navigator.pop(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.mes),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Pesquisar por tipo ou cliente...',
                hintStyle: const TextStyle(color: Colors.grey),
                prefixIcon: const Icon(Icons.search, color: Colors.grey, size: 20),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.grey, width: 1),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.grey, width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF7B3F00), width: 1),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              ),
              style: const TextStyle(fontSize: 14),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          Expanded(
            child: Builder(
              builder: (context) {
                final pedidosPorData = _getPedidosPorData();
                final datas = pedidosPorData.keys.toList()
                  ..sort((a, b) {
                    final dataA = DateFormat('dd/MM/yyyy').parse(a);
                    final dataB = DateFormat('dd/MM/yyyy').parse(b);
                    return dataB.compareTo(dataA);
                  });

                return datas.isEmpty
                    ? const Center(
                        child: Text(
                          'Nenhum pedido encontrado!',
                          style: TextStyle(color: Color(0xFF7B3F00), fontSize: 18),
                        ),
                      )
                    : ListView.builder(
                        itemCount: datas.length,
                        itemBuilder: (context, index) {
                          final data = datas[index];
                          final pedidosData = pedidosPorData[data]!;
                          final quantidade = pedidosData.length;
                          final valorTotalDia = calcularValorTotal(pedidosData);
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            child: ListTile(
                              leading: Icon(
                                pedidosData.every((pedido) => pedido.concluido)
                                    ? Icons.check_circle
                                    : Icons.pending,
                                color: pedidosData.every((pedido) => pedido.concluido)
                                    ? Colors.green
                                    : Colors.orange,
                              ),
                              title: Text(
                                data,
                                style: const TextStyle(
                                  color: Color(0xFF7B3F00),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '$quantidade pedido${quantidade > 1 ? 's' : ''}',
                                  ),
                                  Text(
                                    'Total: $valorTotalDia',
                                  ),
                                ],
                              ),
                              onTap: () {
                                if (pedidosData.isNotEmpty) {
                                  final provider =
                                      Provider.of<PedidosProvider>(context, listen: false);
                                  final indices = _calcularIndices(data, provider.pedidos);
                                  showDialog(
                                    context: context,
                                    builder: (context) => PedidosDiaDialog(
                                      pedidos: pedidosData,
                                      data: DateFormat('dd/MM/yyyy').parse(data),
                                      indices: indices,
                                      onPedidoExcluido: _atualizarPedidos,
                                    ),
                                  );
                                }
                              },
                            ),
                          );
                        },
                      );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class CalendarioDialog extends StatefulWidget {
  final List<Pedido> pedidos;
  final DateTime dataInicial;

  const CalendarioDialog({
    super.key,
    required this.pedidos,
    required this.dataInicial,
  });

  @override
  _CalendarioDialogState createState() => _CalendarioDialogState();
}

class _CalendarioDialogState extends State<CalendarioDialog> {
  late DateTime _selectedDay;
  late DateTime _focusedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = widget.dataInicial;
    _focusedDay = widget.dataInicial;
  }

  List<Pedido> _getPedidosParaDia(DateTime day) {
    final String dataFormatada = DateFormat('yyyy-MM-dd').format(day);
    return widget.pedidos.where((pedido) => pedido.dataEntrega == dataFormatada).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        padding: const EdgeInsets.all(16),
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TableCalendar(
              locale: 'pt_BR',
              firstDay: DateTime(2000),
              lastDay: DateTime(2100),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              eventLoader: (day) {
                return _getPedidosParaDia(day);
              },
              calendarStyle: const CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: Color(0xFF7B3F00),
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: Color(0xFF7B3F00),
                  shape: BoxShape.circle,
                ),
                markerDecoration: BoxDecoration(
                  color: Colors.redAccent,
                  shape: BoxShape.circle,
                ),
              ),
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Pedidos para ${DateFormat('dd/MM/yyyy').format(_selectedDay)}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF7B3F00),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              constraints: const BoxConstraints(maxHeight: 200),
              child: _getPedidosParaDia(_selectedDay).isEmpty
                  ? const Center(child: Text('Nenhum pedido para este dia'))
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: _getPedidosParaDia(_selectedDay).length,
                      itemBuilder: (context, index) {
                        final pedido = _getPedidosParaDia(_selectedDay)[index];
                        return ListTile(
                          leading: Icon(
                            pedido.concluido ? Icons.check_circle : Icons.pending,
                            color: pedido.concluido ? Colors.green : Colors.orange,
                          ),
                          title: Text(pedido.tipo),
                          subtitle: Text(
                            'Quantidade: ${pedido.quantidade} | Valor Total: ${pedido.valorTotal}',
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context, _selectedDay);
                  },
                  child: const Text('Selecionar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class PedidosDiaDialog extends StatefulWidget {
  final List<Pedido> pedidos;
  final DateTime data;
  final List<int> indices;
  final VoidCallback onPedidoExcluido;

  const PedidosDiaDialog({
    super.key,
    required this.pedidos,
    required this.data,
    required this.indices,
    required this.onPedidoExcluido,
  });

  @override
  _PedidosDiaDialogState createState() => _PedidosDiaDialogState();
}

class _PedidosDiaDialogState extends State<PedidosDiaDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  List<Pedido> _pedidosAtuais = [];

  @override
  void initState() {
    super.initState();
    _pedidosAtuais = List.from(widget.pedidos);
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void mostrarDialogoEditar(BuildContext context, Pedido pedido, int pedidoIndex) {
    final _formKey = GlobalKey<FormState>();
    String tipo = pedido.tipo;
    String quantidade = pedido.quantidade;
    String observacao = pedido.observacao;
    String emitirNfe = pedido.emitirNfe;
    DateTime? dataSelecionada;
    try {
      dataSelecionada = DateFormat('dd/MM/yyyy').parse(pedido.dataTexto);
    } catch (e) {
      dataSelecionada = DateTime.now();
    }

    final valorController = MoneyMaskedTextController(
      decimalSeparator: ',',
      thousandSeparator: '.',
      leftSymbol: 'R\$ ',
      initialValue: double.tryParse(
            pedido.valor.replaceAll(RegExp(r'[^\d,]'), '').replaceAll(',', '.')) ?? 0,
    );
    final descontoController = MoneyMaskedTextController(
      decimalSeparator: ',',
      thousandSeparator: '.',
      leftSymbol: 'R\$ ',
      initialValue: double.tryParse(
            pedido.desconto.replaceAll(RegExp(r'[^\d,]'), '').replaceAll(',', '.')) ?? 0,
    );
    final dataController = TextEditingController(text: pedido.dataTexto);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Pedido'),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  initialValue: tipo,
                  decoration: const InputDecoration(labelText: 'Tipo de biscoito'),
                  onChanged: (val) => tipo = val,
                ),
                TextFormField(
                  initialValue: quantidade,
                  decoration: const InputDecoration(labelText: 'Quantidade'),
                  keyboardType: TextInputType.number,
                  onChanged: (val) => quantidade = val,
                ),
                TextFormField(
                  controller: valorController,
                  decoration: const InputDecoration(labelText: 'Valor'),
                  keyboardType: TextInputType.number,
                ),
                TextFormField(
                  controller: descontoController,
                  decoration: const InputDecoration(labelText: 'Desconto'),
                  keyboardType: TextInputType.number,
                ),
                TextFormField(
                  controller: dataController,
                  readOnly: true,
                  decoration: const InputDecoration(labelText: 'Data de entrega'),
                  onTap: () async {
                    final DateTime? picked = await showDialog<DateTime>(
                      context: context,
                      builder: (context) => Consumer<PedidosProvider>(
                        builder: (context, provider, child) => CalendarioDialog(
                          pedidos: provider.pedidos,
                          dataInicial: dataSelecionada!,
                        ),
                      ),
                    );
                    if (picked != null && picked != dataSelecionada) {
                      dataSelecionada = picked;
                      dataController.text = DateFormat('dd/MM/yyyy').format(picked);
                    }
                  },
                ),
                DropdownButtonFormField<String>(
                  value: emitirNfe,
                  items: ['Sim', 'Não'].map((value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  decoration: const InputDecoration(labelText: 'Emitir NFe?'),
                  onChanged: (value) => emitirNfe = value!,
                ),
                TextFormField(
                  initialValue: observacao,
                  decoration: const InputDecoration(labelText: 'Nome, telefone, observações...'),
                  onChanged: (val) => observacao = val,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (tipo.trim().isNotEmpty && pedidoIndex >= 0) {
                int quantidadeNum = int.tryParse(quantidade.trim()) ?? 0;
                String valorStr = valorController.text
                    .replaceAll('R\$ ', '')
                    .replaceAll('.', '')
                    .replaceAll(',', '.');
                String descontoStr = descontoController.text
                    .replaceAll('R\$ ', '')
                    .replaceAll('.', '')
                    .replaceAll(',', '.');
                double valorUnitario = double.tryParse(valorStr) ?? 0.0;
                double desconto = double.tryParse(descontoStr) ?? 0.0;
                double valorTotalBase = quantidadeNum * valorUnitario;
                double valorTotal = valorTotalBase - desconto;
                double impostoISS = emitirNfe == 'Sim' ? valorTotalBase * 0.05 : 0.0;

                final pedidoAtualizado = Pedido(
                  tipo: tipo.trim(),
                  quantidade: quantidade.trim(),
                  valor: valorController.text.trim(),
                  valorTotal: 'R\$ ${valorTotal.toStringAsFixed(2).replaceAll('.', ',')}',
                  desconto: descontoController.text.trim(),
                  impostoISS: 'R\$ ${impostoISS.toStringAsFixed(2).replaceAll('.', ',')}',
                  dataEntrega: DateFormat('yyyy-MM-dd').format(dataSelecionada!),
                  dataTexto: dataController.text,
                  observacao: observacao.trim(),
                  emitirNfe: emitirNfe,
                  concluido: pedido.concluido,
                );

                Provider.of<PedidosProvider>(context, listen: false)
                    .atualizarPedido(pedidoIndex, pedidoAtualizado);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Pedido editado com sucesso!'),
                    backgroundColor: Color(0xFF7B3F00),
                  ),
                );

                Navigator.pop(context);
              }
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  int getPedidosConcluidos(List<Pedido> pedidos) {
    return pedidos.where((pedido) => pedido.concluido).length;
  }

  void _excluirPedido(int index, int pedidoIndex) async {
    final provider = Provider.of<PedidosProvider>(context, listen: false);
    if (pedidoIndex >= 0) {
      _listKey.currentState?.removeItem(
        index,
        (context, animation) => SizeTransition(
          sizeFactor: animation,
          child: FadeTransition(
            opacity: animation,
            child: _buildPedidoItem(index, _pedidosAtuais[index], pedidoIndex),
          ),
        ),
        duration: const Duration(milliseconds: 300),
      );
      await Future.delayed(const Duration(milliseconds: 300));
      provider.excluirPedido(pedidoIndex);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pedido excluído com sucesso!'),
          backgroundColor: Color(0xFF7B3F00),
        ),
      );

      setState(() {
        _pedidosAtuais.removeAt(index);
      });

      widget.onPedidoExcluido();

      if (_pedidosAtuais.isEmpty) {
        Navigator.pop(context);
      }
    }
  }

  Widget _buildPedidoItem(int index, Pedido pedido, int pedidoIndex) {
    final title = _pedidosAtuais.length > 1 ? 'Pedido ${index + 1}: ${pedido.tipo}' : pedido.tipo;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: pedido.concluido ? Colors.green[50] : Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (pedido.concluido)
                  const Padding(
                    padding: EdgeInsets.only(right: 8),
                    child: Icon(
                      Icons.cookie,
                      color: Color(0xFF8D6E63),
                      size: 20,
                    ),
                  ),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      decoration: pedido.concluido ? TextDecoration.lineThrough : TextDecoration.none,
                      color: pedido.concluido ? Colors.grey : const Color(0xFF7B3F00),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Quantidade: ${pedido.quantidade}',
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              'Valor Unitário: ${pedido.valor}',
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              'Desconto: ${pedido.desconto}',
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              'Valor Total: ${pedido.valorTotal}',
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              'Imposto ISS: ${pedido.impostoISS}',
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              'Entrega: ${pedido.dataTexto}',
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              'Cliente: ${pedido.observacao}',
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              'Emitir NFe: ${pedido.emitirNfe}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Color(0xFF7B3F00)),
                  onPressed: () {
                    if (pedidoIndex >= 0) {
                      mostrarDialogoEditar(context, pedido, pedidoIndex);
                    }
                  },
                ),
                IconButton(
                  icon: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (Widget child, Animation<double> animation) {
                      return ScaleTransition(
                        scale: animation,
                        child: FadeTransition(
                          opacity: animation,
                          child: child,
                        ),
                      );
                    },
                    child: Icon(
                      pedido.concluido ? Icons.check_circle : Icons.radio_button_unchecked,
                      key: ValueKey<bool>(pedido.concluido),
                      color: const Color(0xFF7B3F00),
                    ),
                  ),
                  onPressed: () {
                    if (pedidoIndex >= 0) {
                      final provider = Provider.of<PedidosProvider>(context, listen: false);
                      provider.concluirPedido(pedidoIndex);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            pedido.concluido
                                ? 'Pedido marcado como concluído!'
                                : 'Pedido marcado como não concluído!',
                          ),
                          backgroundColor: const Color(0xFF7B3F00),
                        ),
                      );
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.redAccent),
                  onPressed: () {
                    if (pedidoIndex >= 0) {
                      _excluirPedido(index, pedidoIndex);
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PedidosProvider>(
      builder: (context, provider, child) {
        _pedidosAtuais = provider.pedidos
            .where((pedido) => pedido.dataTexto == DateFormat('dd/MM/yyyy').format(widget.data))
            .toList();

        List<int> indicesAtuais = [];
        for (var pedido in _pedidosAtuais) {
          int index = provider.pedidos.indexOf(pedido);
          indicesAtuais.add(index);
        }

        List<Pedido> pedidosOrdenados = List.from(_pedidosAtuais);
        List<int> indicesOrdenados = List.from(indicesAtuais);

        if (provider.ordenacao == 'concluidos_topo') {
          for (int i = 0; i < pedidosOrdenados.length; i++) {
            for (int j = 0; j < pedidosOrdenados.length - i - 1; j++) {
              if (!pedidosOrdenados[j].concluido && pedidosOrdenados[j + 1].concluido) {
                var tempPedido = pedidosOrdenados[j];
                pedidosOrdenados[j] = pedidosOrdenados[j + 1];
                pedidosOrdenados[j + 1] = tempPedido;
                var tempIndex = indicesOrdenados[j];
                indicesOrdenados[j] = indicesOrdenados[j + 1];
                indicesOrdenados[j + 1] = tempIndex;
              }
            }
          }
        } else if (provider.ordenacao == 'concluidos_final') {
          for (int i = 0; i < pedidosOrdenados.length; i++) {
            for (int j = 0; j < pedidosOrdenados.length - i - 1; j++) {
              if (pedidosOrdenados[j].concluido && !pedidosOrdenados[j + 1].concluido) {
                var tempPedido = pedidosOrdenados[j];
                pedidosOrdenados[j] = pedidosOrdenados[j + 1];
                pedidosOrdenados[j + 1] = tempPedido;
                var tempIndex = indicesOrdenados[j];
                indicesOrdenados[j] = indicesOrdenados[j + 1];
                indicesOrdenados[j + 1] = tempIndex;
              }
            }
          }
        }

        _pedidosAtuais = pedidosOrdenados;

        final totalPedidos = _pedidosAtuais.length;
        final concluidos = getPedidosConcluidos(_pedidosAtuais);
        String calcularValorTotal(List<Pedido> pedidos) {
          double total = 0.0;
          for (var pedido in pedidos) {
            String valorStr = pedido.valorTotal
                .replaceAll('R\$ ', '')
                .replaceAll('.', '')
                .replaceAll(',', '.');
            double valor = double.tryParse(valorStr) ?? 0.0;
            total += valor;
          }
          return 'R\$ ${total.toStringAsFixed(2).replaceAll('.', ',')}';
        }
        final valorTotal = calcularValorTotal(_pedidosAtuais);

        return Dialog(
          child: Container(
            padding: const EdgeInsets.all(24),
            constraints: const BoxConstraints(maxWidth: 500, minWidth: 300),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Pedidos para ${DateFormat('dd/MM/yyyy').format(widget.data)} ($concluidos/$totalPedidos concluídos)',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF7B3F00),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.sort, color: Color(0xFF7B3F00)),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Ordenar Pedidos'),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ListTile(
                                  title: const Text('Padrão'),
                                  onTap: () {
                                    Provider.of<PedidosProvider>(context, listen: false)
                                        .setOrdenacao('padrao');
                                    Navigator.pop(context);
                                  },
                                ),
                                ListTile(
                                  title: const Text('Concluídos no Topo'),
                                  onTap: () {
                                    Provider.of<PedidosProvider>(context, listen: false)
                                        .setOrdenacao('concluidos_topo');
                                    Navigator.pop(context);
                                  },
                                ),
                                ListTile(
                                  title: const Text('Concluídos no Final'),
                                  onTap: () {
                                    Provider.of<PedidosProvider>(context, listen: false)
                                        .setOrdenacao('concluidos_final');
                                    Navigator.pop(context);
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Flexible(
                  child: AnimatedList(
                    key: _listKey,
                    initialItemCount: _pedidosAtuais.length,
                    itemBuilder: (context, index, animation) {
                      return SizeTransition(
                        sizeFactor: animation,
                        child: FadeTransition(
                          opacity: animation,
                          child: _buildPedidoItem(index, _pedidosAtuais[index], indicesOrdenados[index]),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'Total: $valorTotal',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF7B3F00),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Fechar'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}