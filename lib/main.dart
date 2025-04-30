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
      dataEntrega: map['dataEntrega'] ?? '',
      dataTexto: map['dataTexto'] ?? '',
      observacao: map['observacao'] ?? '',
      emitirNfe: map['emitirNfe'] ?? 'Não',
      concluido: map['concluido'] ?? false,
    );
  }
}

// Provider para gerenciar os pedidos
class PedidosProvider with ChangeNotifier {
  List<Pedido> _pedidos = [];
  String _ordenacao = 'padrao'; // padrao, concluidos_topo, concluidos_final

  List<Pedido> get pedidos => _pedidos;

  String get ordenacao => _ordenacao;

  PedidosProvider() {
    carregarPedidos();
  }

  void carregarPedidos() async {
    final prefs = await SharedPreferences.getInstance();
    final String? pedidosString = prefs.getString('pedidos');
    if (pedidosString != null) {
      final List<dynamic> pedidosJson = jsonDecode(pedidosString);
      _pedidos = pedidosJson.map((pedido) => Pedido.fromMap(pedido)).toList();
      notifyListeners();
    }
  }

  Future<void> salvarPedidos() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'pedidos',
      jsonEncode(_pedidos.map((p) => p.toMap()).toList()),
    );
  }

  void adicionarPedido(Pedido pedido) {
    _pedidos.add(pedido);
    salvarPedidos();
    notifyListeners();
  }

  void atualizarPedido(int index, Pedido pedido) {
    if (index >= 0 && index < _pedidos.length) {
      _pedidos[index] = pedido;
      salvarPedidos();
      notifyListeners();
    }
  }

  void excluirPedido(int index) {
    if (index >= 0 && index < _pedidos.length) {
      _pedidos.removeAt(index);
      salvarPedidos();
      notifyListeners();
    }
  }

  void concluirPedido(int index) {
    if (index >= 0 && index < _pedidos.length) {
      _pedidos[index].concluido = !_pedidos[index].concluido;
      salvarPedidos();
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
      ),
      locale: const Locale('pt', 'BR'),
      supportedLocales: const [Locale('pt', 'BR')],
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
              Image.asset('assets/logo.png', height: 150),
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
                        builder: (context) => const ListaPedidosPage(),
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

class ListaPedidosPage extends StatelessWidget {
  const ListaPedidosPage({super.key});

  void mostrarDialogoAdicionar(BuildContext context) {
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
    final dataController = TextEditingController(
      text: DateFormat('dd/MM/yyyy').format(dataSelecionada),
    );

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Novo Pedido'),
            content: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Tipo de biscoito',
                      ),
                      onChanged: (val) => tipo = val,
                    ),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Quantidade',
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (val) => quantidade = val,
                    ),
                    TextFormField(
                      controller: valorController,
                      decoration: const InputDecoration(labelText: 'Valor'),
                      keyboardType: TextInputType.number,
                    ),
                    TextFormField(
                      controller: dataController,
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: 'Data de entrega',
                      ),
                      onTap: () async {
                        final DateTime? picked = await showDialog<DateTime>(
                          context: context,
                          builder:
                              (context) => Consumer<PedidosProvider>(
                                builder:
                                    (context, provider, child) =>
                                        CalendarioDialog(
                                          pedidos: provider.pedidos,
                                          dataInicial: dataSelecionada!,
                                        ),
                              ),
                        );
                        if (picked != null && picked != dataSelecionada) {
                          dataSelecionada = picked;
                          dataController.text = DateFormat(
                            'dd/MM/yyyy',
                          ).format(picked);
                        }
                      },
                    ),
                    DropdownButtonFormField<String>(
                      value: emitirNfe,
                      items:
                          ['Sim', 'Não'].map((value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                      decoration: const InputDecoration(
                        labelText: 'Emitir NFe?',
                      ),
                      onChanged: (value) {
                        emitirNfe = value!;
                      },
                    ),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Nome, telefone, observações...',
                      ),
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
                    double valorUnitario = double.tryParse(valorStr) ?? 0.0;
                    double valorTotal = quantidadeNum * valorUnitario;

                    final novoPedido = Pedido(
                      tipo: tipo.trim(),
                      quantidade: quantidade.trim(),
                      valor: valorController.text.trim(),
                      valorTotal:
                          'R\$ ${valorTotal.toStringAsFixed(2).replaceAll('.', ',')}',
                      dataEntrega: DateFormat(
                        'yyyy-MM-dd',
                      ).format(dataSelecionada!),
                      dataTexto: textoData,
                      observacao: observacao.trim(),
                      emitirNfe: emitirNfe,
                      concluido: false,
                    );

                    Provider.of<PedidosProvider>(
                      context,
                      listen: false,
                    ).adicionarPedido(novoPedido);

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

  Map<String, List<Pedido>> _getPedidosPorMes(List<Pedido> pedidos) {
    final Map<String, List<Pedido>> pedidosPorMes = {};
    for (var pedido in pedidos) {
      final data = DateTime.parse(pedido.dataEntrega);
      final mesAno = DateFormat('MMMM yyyy', 'pt_BR').format(data);
      if (!pedidosPorMes.containsKey(mesAno)) {
        pedidosPorMes[mesAno] = [];
      }
      pedidosPorMes[mesAno]!.add(pedido);
    }
    return pedidosPorMes;
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

  @override
  Widget build(BuildContext context) {
    return Consumer<PedidosProvider>(
      builder: (context, provider, child) {
        final pedidosPorMes = _getPedidosPorMes(provider.pedidos);
        final meses =
            pedidosPorMes.keys.toList()..sort((a, b) {
              final dataA = DateFormat('MMMM yyyy', 'pt_BR').parse(a);
              final dataB = DateFormat('MMMM yyyy', 'pt_BR').parse(b);
              return dataA.compareTo(dataB);
            });

        return Scaffold(
          appBar: AppBar(title: const Text('Pedidos de Biscoitos')),
          body:
              meses.isEmpty
                  ? const Center(
                    child: Text(
                      'Nenhum pedido ainda!',
                      style: TextStyle(color: Color(0xFF7B3F00), fontSize: 18),
                    ),
                  )
                  : ListView.builder(
                    itemCount: meses.length,
                    itemBuilder: (context, index) {
                      final mes = meses[index];
                      final pedidosMes = pedidosPorMes[mes]!;
                      final quantidade = pedidosMes.length;
                      final valorTotalMes = calcularValorTotal(pedidosMes);
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        child: ListTile(
                          title: Text(
                            mes,
                            style: const TextStyle(
                              color: Color(0xFF7B3F00),
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '$quantidade pedido${quantidade > 1 ? 's' : ''}',
                                style: const TextStyle(color: Colors.grey),
                              ),
                              Text(
                                'Total: $valorTotalMes',
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder:
                                    (context, animation, secondaryAnimation) =>
                                        MesPedidosPage(
                                          mes: mes,
                                          pedidos: pedidosMes,
                                        ),
                                transitionsBuilder: (
                                  context,
                                  animation,
                                  secondaryAnimation,
                                  child,
                                ) {
                                  const begin = Offset(1.0, 0.0);
                                  const end = Offset.zero;
                                  const curve = Curves.easeInOut;

                                  var tween = Tween(
                                    begin: begin,
                                    end: end,
                                  ).chain(CurveTween(curve: curve));
                                  var offsetAnimation = animation.drive(tween);

                                  return SlideTransition(
                                    position: offsetAnimation,
                                    child: child,
                                  );
                                },
                                transitionDuration: const Duration(
                                  milliseconds: 300,
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => mostrarDialogoAdicionar(context),
            child: const Icon(Icons.add, color: Colors.white),
          ),
        );
      },
    );
  }
}

class MesPedidosPage extends StatefulWidget {
  final String mes;
  final List<Pedido> pedidos;

  const MesPedidosPage({super.key, required this.mes, required this.pedidos});

  @override
  _MesPedidosPageState createState() => _MesPedidosPageState();
}

class _MesPedidosPageState extends State<MesPedidosPage> {
  late List<Pedido> pedidosAtuais;

  @override
  void initState() {
    super.initState();
    pedidosAtuais = List.from(widget.pedidos);
  }

  Map<String, List<Pedido>> _getPedidosPorData() {
    final Map<String, List<Pedido>> pedidosPorData = {};
    for (var pedido in pedidosAtuais) {
      final dataTexto = pedido.dataTexto;
      if (!pedidosPorData.containsKey(dataTexto)) {
        pedidosPorData[dataTexto] = [];
      }
      pedidosPorData[dataTexto]!.add(pedido);
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
      pedidosAtuais =
          provider.pedidos
              .where(
                (pedido) =>
                    DateFormat(
                      'MMMM yyyy',
                      'pt_BR',
                    ).format(DateTime.parse(pedido.dataEntrega)) ==
                    widget.mes,
              )
              .toList();

      // Se não houver mais pedidos no mês, voltar para a tela anterior
      if (pedidosAtuais.isEmpty) {
        Navigator.pop(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final pedidosPorData = _getPedidosPorData();
    final datas =
        pedidosPorData.keys.toList()..sort((a, b) {
          final dataA = DateFormat('dd/MM/yyyy').parse(a);
          final dataB = DateFormat('dd/MM/yyyy').parse(b);
          return dataB.compareTo(dataA); // Ordem decrescente
        });

    return Scaffold(
      appBar: AppBar(title: Text(widget.mes)),
      body:
          datas.isEmpty
              ? const Center(
                child: Text(
                  'Nenhum pedido neste mês!',
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
                    margin: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    child: ListTile(
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
                            style: const TextStyle(color: Colors.grey),
                          ),
                          Text(
                            'Total: $valorTotalDia',
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                      onTap: () {
                        if (pedidosData.isNotEmpty) {
                          final provider = Provider.of<PedidosProvider>(
                            context,
                            listen: false,
                          );
                          final indices = _calcularIndices(
                            data,
                            provider.pedidos,
                          );
                          showDialog(
                            context: context,
                            builder:
                                (context) => PedidosDiaDialog(
                                  pedidos: pedidosData,
                                  data: DateFormat('dd/MM/yyyy').parse(data),
                                  indices: indices,
                                  onPedidoExcluido:
                                      _atualizarPedidos, // Callback para atualizar a lista
                                ),
                          );
                        }
                      },
                    ),
                  );
                },
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
    return widget.pedidos
        .where((pedido) => pedido.dataEntrega == dataFormatada)
        .toList();
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
              child:
                  _getPedidosParaDia(_selectedDay).isEmpty
                      ? const Center(child: Text('Nenhum pedido para este dia'))
                      : ListView.builder(
                        shrinkWrap: true,
                        itemCount: _getPedidosParaDia(_selectedDay).length,
                        itemBuilder: (context, index) {
                          final pedido =
                              _getPedidosParaDia(_selectedDay)[index];
                          return ListTile(
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
  final VoidCallback onPedidoExcluido; // Callback para notificar a exclusão

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
    _fadeAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void mostrarDialogoEditar(
    BuildContext context,
    Pedido pedido,
    int pedidoIndex,
  ) {
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
      initialValue:
          double.tryParse(
            pedido.valor.replaceAll(RegExp(r'[^\d,]'), '').replaceAll(',', '.'),
          ) ??
          0,
    );

    final dataController = TextEditingController(text: pedido.dataTexto);

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Editar Pedido'),
            content: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      initialValue: tipo,
                      decoration: const InputDecoration(
                        labelText: 'Tipo de biscoito',
                      ),
                      onChanged: (val) => tipo = val,
                    ),
                    TextFormField(
                      initialValue: quantidade,
                      decoration: const InputDecoration(
                        labelText: 'Quantidade',
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (val) => quantidade = val,
                    ),
                    TextFormField(
                      controller: valorController,
                      decoration: const InputDecoration(labelText: 'Valor'),
                      keyboardType: TextInputType.number,
                    ),
                    TextFormField(
                      controller: dataController,
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: 'Data de entrega',
                      ),
                      onTap: () async {
                        final DateTime? picked = await showDialog<DateTime>(
                          context: context,
                          builder:
                              (context) => Consumer<PedidosProvider>(
                                builder:
                                    (context, provider, child) =>
                                        CalendarioDialog(
                                          pedidos: provider.pedidos,
                                          dataInicial: dataSelecionada!,
                                        ),
                              ),
                        );
                        if (picked != null && picked != dataSelecionada) {
                          dataSelecionada = picked;
                          dataController.text = DateFormat(
                            'dd/MM/yyyy',
                          ).format(picked);
                        }
                      },
                    ),
                    DropdownButtonFormField<String>(
                      value: emitirNfe,
                      items:
                          ['Sim', 'Não'].map((value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                      decoration: const InputDecoration(
                        labelText: 'Emitir NFe?',
                      ),
                      onChanged: (value) => emitirNfe = value!,
                    ),
                    TextFormField(
                      initialValue: observacao,
                      decoration: const InputDecoration(
                        labelText: 'Nome, telefone, observações...',
                      ),
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
                    double valorUnitario = double.tryParse(valorStr) ?? 0.0;
                    double valorTotal = quantidadeNum * valorUnitario;

                    final pedidoAtualizado = Pedido(
                      tipo: tipo.trim(),
                      quantidade: quantidade.trim(),
                      valor: valorController.text.trim(),
                      valorTotal:
                          'R\$ ${valorTotal.toStringAsFixed(2).replaceAll('.', ',')}',
                      dataEntrega: DateFormat(
                        'yyyy-MM-dd',
                      ).format(dataSelecionada!),
                      dataTexto: dataController.text,
                      observacao: observacao.trim(),
                      emitirNfe: emitirNfe,
                      concluido: pedido.concluido,
                    );

                    Provider.of<PedidosProvider>(
                      context,
                      listen: false,
                    ).atualizarPedido(pedidoIndex, pedidoAtualizado);

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

      // Atualizar a lista local
      setState(() {
        _pedidosAtuais.removeAt(index);
      });

      // Notificar a MesPedidosPage para atualizar sua lista
      widget.onPedidoExcluido();

      // Se não houver mais pedidos no dia, fechar o diálogo
      if (_pedidosAtuais.isEmpty) {
        Navigator.pop(context);
      }
    }
  }

  Widget _buildPedidoItem(int index, Pedido pedido, int pedidoIndex) {
    final title =
        _pedidosAtuais.length > 1
            ? 'Pedido ${index + 1}: ${pedido.tipo}'
            : pedido.tipo;
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
                      decoration:
                          pedido.concluido
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                      color:
                          pedido.concluido
                              ? Colors.grey
                              : const Color(0xFF7B3F00),
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
              'Valor Total: ${pedido.valorTotal}',
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
                    transitionBuilder: (
                      Widget child,
                      Animation<double> animation,
                    ) {
                      return ScaleTransition(
                        scale: animation,
                        child: FadeTransition(opacity: animation, child: child),
                      );
                    },
                    child: Icon(
                      pedido.concluido
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      key: ValueKey<bool>(pedido.concluido),
                      color: const Color(0xFF7B3F00),
                    ),
                  ),
                  onPressed: () {
                    if (pedidoIndex >= 0) {
                      final provider = Provider.of<PedidosProvider>(
                        context,
                        listen: false,
                      );
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
        // Filtrar pedidos pela data
        _pedidosAtuais =
            provider.pedidos
                .where(
                  (pedido) =>
                      pedido.dataTexto ==
                      DateFormat('dd/MM/yyyy').format(widget.data),
                )
                .toList();

        // Criar uma lista de índices correspondentes aos pedidos filtrados
        List<int> indicesAtuais = [];
        for (var pedido in _pedidosAtuais) {
          int index = provider.pedidos.indexOf(pedido);
          indicesAtuais.add(index);
        }

        // Aplicar ordenação na lista filtrada
        List<Pedido> pedidosOrdenados = List.from(_pedidosAtuais);
        List<int> indicesOrdenados = List.from(indicesAtuais);

        if (provider.ordenacao == 'concluidos_topo') {
          for (int i = 0; i < pedidosOrdenados.length; i++) {
            for (int j = 0; j < pedidosOrdenados.length - i - 1; j++) {
              if (!pedidosOrdenados[j].concluido &&
                  pedidosOrdenados[j + 1].concluido) {
                // Trocar pedidos
                var tempPedido = pedidosOrdenados[j];
                pedidosOrdenados[j] = pedidosOrdenados[j + 1];
                pedidosOrdenados[j + 1] = tempPedido;
                // Trocar índices
                var tempIndex = indicesOrdenados[j];
                indicesOrdenados[j] = indicesOrdenados[j + 1];
                indicesOrdenados[j + 1] = tempIndex;
              }
            }
          }
        } else if (provider.ordenacao == 'concluidos_final') {
          for (int i = 0; i < pedidosOrdenados.length; i++) {
            for (int j = 0; j < pedidosOrdenados.length - i - 1; j++) {
              if (pedidosOrdenados[j].concluido &&
                  !pedidosOrdenados[j + 1].concluido) {
                // Trocar pedidos
                var tempPedido = pedidosOrdenados[j];
                pedidosOrdenados[j] = pedidosOrdenados[j + 1];
                pedidosOrdenados[j + 1] = tempPedido;
                // Trocar índices
                var tempIndex = indicesOrdenados[j];
                indicesOrdenados[j] = indicesOrdenados[j + 1];
                indicesOrdenados[j + 1] = tempIndex;
              }
            }
          }
        }

        // Atualizar _pedidosAtuais com a lista ordenada
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
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF7B3F00),
                        ),
                      ),
                    ),
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.sort, color: Color(0xFF7B3F00)),
                      onSelected: (value) {
                        provider.setOrdenacao(value);
                      },
                      itemBuilder:
                          (context) => [
                            const PopupMenuItem(
                              value: 'padrao',
                              child: Text('Ordem de criação'),
                            ),
                            const PopupMenuItem(
                              value: 'concluidos_topo',
                              child: Text('Concluídos no topo'),
                            ),
                            const PopupMenuItem(
                              value: 'concluidos_final',
                              child: Text('Concluídos no final'),
                            ),
                          ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Total: $valorTotal no dia',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF7B3F00),
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  constraints: const BoxConstraints(maxHeight: 400),
                  child:
                      _pedidosAtuais.isEmpty
                          ? const Center(
                            child: Text(
                              'Nenhum pedido para este dia',
                              style: TextStyle(fontSize: 16),
                            ),
                          )
                          : AnimatedList(
                            key: _listKey,
                            initialItemCount: _pedidosAtuais.length,
                            shrinkWrap: true,
                            itemBuilder: (context, index, animation) {
                              final pedidoIndex = indicesOrdenados[index];
                              return FadeTransition(
                                opacity: animation,
                                child: SizeTransition(
                                  sizeFactor: animation,
                                  child: _buildPedidoItem(
                                    index,
                                    _pedidosAtuais[index],
                                    pedidoIndex,
                                  ),
                                ),
                              );
                            },
                          ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Fechar',
                        style: TextStyle(fontSize: 16),
                      ),
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
