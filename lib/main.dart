import 'package:flutter/material.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:table_calendar/table_calendar.dart';

void main() {
  runApp(const NeysApp());
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
                        builder: (context) => const ListaTarefasPage(),
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

class ListaTarefasPage extends StatefulWidget {
  const ListaTarefasPage({super.key});

  @override
  _ListaTarefasPageState createState() => _ListaTarefasPageState();
}

class _ListaTarefasPageState extends State<ListaTarefasPage> {
  List<Map<String, dynamic>> tarefas = [];

  @override
  void initState() {
    super.initState();
    carregarTarefas();
  }

  void carregarTarefas() async {
    final prefs = await SharedPreferences.getInstance();
    final String? tarefasString = prefs.getString('tarefas');
    if (tarefasString != null) {
      final List<dynamic> tarefasJson = jsonDecode(tarefasString);
      final List<Map<String, dynamic>> tarefasAtualizadas =
          tarefasJson
              .map((tarefa) {
                return {
                  'tipo': tarefa['tipo'] ?? 'Tipo não informado',
                  'quantidade': tarefa['quantidade'] ?? '',
                  'valor': tarefa['valor'] ?? 'R\$ 0,00',
                  'valorTotal': tarefa['valorTotal'] ?? 'R\$ 0,00',
                  'dataEntrega': tarefa['dataEntrega'] ?? '',
                  'dataTexto': tarefa['dataTexto'] ?? '',
                  'observacao': tarefa['observacao'] ?? '',
                  'emitirNfe': tarefa['emitirNfe'] ?? 'Não',
                  'concluida': tarefa['concluida'] ?? false,
                };
              })
              .cast<Map<String, dynamic>>()
              .toList();

      setState(() {
        tarefas = tarefasAtualizadas;
      });

      await prefs.setString('tarefas', jsonEncode(tarefasAtualizadas));
    }
  }

  Future<void> salvarTarefas() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('tarefas', jsonEncode(tarefas));
  }

  void adicionarTarefa(Map<String, dynamic> novaTarefa) {
    int quantidade = int.tryParse(novaTarefa['quantidade']) ?? 0;
    String valorStr = novaTarefa['valor']
        .replaceAll('R\$ ', '')
        .replaceAll('.', '')
        .replaceAll(',', '.');
    double valorUnitario = double.tryParse(valorStr) ?? 0.0;
    double valorTotal = quantidade * valorUnitario;
    novaTarefa['valorTotal'] =
        'R\$ ${valorTotal.toStringAsFixed(2).replaceAll('.', ',')}';

    setState(() {
      tarefas.add(novaTarefa);
    });
    salvarTarefas();
  }

  void concluirTarefa(int index) {
    if (index >= 0 && index < tarefas.length) {
      setState(() {
        tarefas[index]['concluida'] = !tarefas[index]['concluida'];
      });
      salvarTarefas();
    }
  }

  void excluirTarefa(int index) {
    if (index >= 0 && index < tarefas.length) {
      setState(() {
        tarefas.removeAt(index);
      });
      salvarTarefas();
    }
  }

  Map<String, List<Map<String, dynamic>>> _getTarefasPorMes() {
    final Map<String, List<Map<String, dynamic>>> tarefasPorMes = {};
    for (var tarefa in tarefas) {
      final data = DateTime.parse(tarefa['dataEntrega']);
      final mesAno = DateFormat('MMMM yyyy', 'pt_BR').format(data);
      if (!tarefasPorMes.containsKey(mesAno)) {
        tarefasPorMes[mesAno] = [];
      }
      tarefasPorMes[mesAno]!.add(tarefa);
    }
    return tarefasPorMes;
  }

  void mostrarDialogoAdicionar() {
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
                              (context) => CalendarioDialog(
                                tarefas: tarefas,
                                dataInicial: dataSelecionada!,
                              ),
                        );
                        if (picked != null && picked != dataSelecionada) {
                          setState(() {
                            dataSelecionada = picked;
                            dataController.text = DateFormat(
                              'dd/MM/yyyy',
                            ).format(picked);
                          });
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
                    adicionarTarefa({
                      'tipo': tipo.trim(),
                      'quantidade': quantidade.trim(),
                      'valor': valorController.text.trim(),
                      'dataEntrega': DateFormat(
                        'yyyy-MM-dd',
                      ).format(dataSelecionada!),
                      'dataTexto': textoData,
                      'emitirNfe': emitirNfe,
                      'observacao': observacao.trim(),
                      'concluida': false,
                    });
                    Navigator.pop(context);
                  }
                },
                child: const Text('Adicionar'),
              ),
            ],
          ),
    );
  }

  void mostrarDialogoEditar(
    Map<String, dynamic> tarefa,
    int index,
    Function onTarefaAtualizada,
  ) {
    if (index < 0 || index >= tarefas.length) return; // Validação do índice

    final _formKey = GlobalKey<FormState>();
    String tipo = tarefa['tipo'];
    String quantidade = tarefa['quantidade'];
    String observacao = tarefa['observacao'] ?? '';
    String emitirNfe = tarefa['emitirNfe'] ?? 'Não';
    DateTime? dataSelecionada;
    try {
      dataSelecionada = DateFormat('dd/MM/yyyy').parse(tarefa['dataTexto']);
    } catch (e) {
      dataSelecionada = DateTime.now();
    }

    final valorController = MoneyMaskedTextController(
      decimalSeparator: ',',
      thousandSeparator: '.',
      leftSymbol: 'R\$ ',
      initialValue:
          double.tryParse(
            tarefa['valor']
                .toString()
                .replaceAll(RegExp(r'[^\d,]'), '')
                .replaceAll(',', '.'),
          ) ??
          0,
    );

    final dataController = TextEditingController(text: tarefa['dataTexto']);

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
                              (context) => CalendarioDialog(
                                tarefas: tarefas,
                                dataInicial: dataSelecionada!,
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
                  if (tipo.trim().isNotEmpty &&
                      index >= 0 &&
                      index < tarefas.length) {
                    int quantidadeNum = int.tryParse(quantidade.trim()) ?? 0;
                    String valorStr = valorController.text
                        .replaceAll('R\$ ', '')
                        .replaceAll('.', '')
                        .replaceAll(',', '.');
                    double valorUnitario = double.tryParse(valorStr) ?? 0.0;
                    double valorTotal = quantidadeNum * valorUnitario;

                    setState(() {
                      tarefas[index] = {
                        'tipo': tipo.trim(),
                        'quantidade': quantidade.trim(),
                        'valor': valorController.text.trim(),
                        'dataEntrega': DateFormat(
                          'yyyy-MM-dd',
                        ).format(dataSelecionada!),
                        'dataTexto': dataController.text,
                        'emitirNfe': emitirNfe,
                        'observacao': observacao.trim(),
                        'concluida': tarefa['concluida'],
                        'valorTotal':
                            'R\$ ${valorTotal.toStringAsFixed(2).replaceAll('.', ',')}',
                      };
                    });
                    salvarTarefas();
                    Navigator.pop(context); // Fecha o diálogo de edição
                    onTarefaAtualizada(); // Notifica que a tarefa foi atualizada
                  }
                },
                child: const Text('Salvar'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tarefasPorMes = _getTarefasPorMes();
    final meses =
        tarefasPorMes.keys.toList()..sort((a, b) {
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
                  final tarefasMes = tarefasPorMes[mes]!;
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
                      onTap: () {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder:
                                (context, animation, secondaryAnimation) =>
                                    MesPedidosPage(
                                      mes: mes,
                                      tarefas: tarefasMes,
                                      tarefasGlobais: tarefas,
                                      onEditar:
                                          (tarefa, index, callback) =>
                                              mostrarDialogoEditar(
                                                tarefa,
                                                index,
                                                callback,
                                              ),
                                      onConcluir: concluirTarefa,
                                      onExcluir: excluirTarefa,
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
        onPressed: mostrarDialogoAdicionar,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class MesPedidosPage extends StatefulWidget {
  final String mes;
  final List<Map<String, dynamic>> tarefas;
  final List<Map<String, dynamic>> tarefasGlobais;
  final Function(Map<String, dynamic>, int, Function)
  onEditar; // Alterado para aceitar callback
  final Function(int) onConcluir;
  final Function(int) onExcluir;

  const MesPedidosPage({
    super.key,
    required this.mes,
    required this.tarefas,
    required this.tarefasGlobais,
    required this.onEditar,
    required this.onConcluir,
    required this.onExcluir,
  });

  @override
  _MesPedidosPageState createState() => _MesPedidosPageState();
}

class _MesPedidosPageState extends State<MesPedidosPage> {
  Map<String, List<Map<String, dynamic>>> _getTarefasPorData() {
    final Map<String, List<Map<String, dynamic>>> tarefasPorData = {};
    for (var tarefa in widget.tarefas) {
      final dataTexto = tarefa['dataTexto'];
      if (!tarefasPorData.containsKey(dataTexto)) {
        tarefasPorData[dataTexto] = [];
      }
      tarefasPorData[dataTexto]!.add(tarefa);
    }
    return tarefasPorData;
  }

  List<int> _calcularIndices(String data) {
    final indices =
        widget.tarefasGlobais
            .asMap()
            .entries
            .where((entry) => entry.value['dataTexto'] == data)
            .map((entry) => entry.key)
            .toList();
    return indices;
  }

  void _reabrirDialogo(BuildContext context, String data) {
    // Recalcular os índices e tarefas com base na lista global atualizada
    final indicesAtualizados = _calcularIndices(data);
    final tarefasAtualizadas =
        widget.tarefasGlobais
            .where((tarefa) => tarefa['dataTexto'] == data)
            .toList();

    if (tarefasAtualizadas.isNotEmpty) {
      showDialog(
        context: context,
        builder:
            (context) => TarefasDiaDialog(
              tarefas: tarefasAtualizadas,
              tarefasGlobais: widget.tarefasGlobais,
              data: DateFormat('dd/MM/yyyy').parse(data),
              onEditar: widget.onEditar,
              onConcluir: widget.onConcluir,
              onExcluir: widget.onExcluir,
              indices: indicesAtualizados,
              onActionCompleted: () {
                _reabrirDialogo(context, data);
              },
            ),
      );
    } else {
      Navigator.pop(
        context,
      ); // Volta para a tela anterior se não houver mais tarefas
    }
  }

  @override
  Widget build(BuildContext context) {
    final tarefasPorData = _getTarefasPorData();
    final datas =
        tarefasPorData.keys.toList()..sort((a, b) {
          final dataA = DateFormat('dd/MM/yyyy').parse(a);
          final dataB = DateFormat('dd/MM/yyyy').parse(b);
          return dataA.compareTo(dataB);
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
                  final tarefasData = tarefasPorData[data]!;
                  final quantidade = tarefasData.length;
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
                      subtitle: Text(
                        '$quantidade pedido${quantidade > 1 ? 's' : ''}',
                        style: const TextStyle(color: Colors.grey),
                      ),
                      onTap: () {
                        if (tarefasData.isNotEmpty) {
                          final indices = _calcularIndices(data);
                          showDialog(
                            context: context,
                            builder:
                                (context) => TarefasDiaDialog(
                                  tarefas: tarefasData,
                                  tarefasGlobais: widget.tarefasGlobais,
                                  data: DateFormat('dd/MM/yyyy').parse(data),
                                  onEditar: widget.onEditar,
                                  onConcluir: widget.onConcluir,
                                  onExcluir: widget.onExcluir,
                                  indices: indices,
                                  onActionCompleted: () {
                                    _reabrirDialogo(context, data);
                                  },
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
  final List<Map<String, dynamic>> tarefas;
  final DateTime dataInicial;

  const CalendarioDialog({
    super.key,
    required this.tarefas,
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

  List<Map<String, dynamic>> _getTarefasParaDia(DateTime day) {
    final String dataFormatada = DateFormat('yyyy-MM-dd').format(day);
    return widget.tarefas
        .where((tarefa) => tarefa['dataEntrega'] == dataFormatada)
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
                return _getTarefasParaDia(day);
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
              'Tarefas para ${DateFormat('dd/MM/yyyy').format(_selectedDay)}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF7B3F00),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              constraints: const BoxConstraints(maxHeight: 200),
              child:
                  _getTarefasParaDia(_selectedDay).isEmpty
                      ? const Center(
                        child: Text('Nenhuma tarefa para este dia'),
                      )
                      : ListView.builder(
                        shrinkWrap: true,
                        itemCount: _getTarefasParaDia(_selectedDay).length,
                        itemBuilder: (context, index) {
                          final tarefa =
                              _getTarefasParaDia(_selectedDay)[index];
                          return ListTile(
                            title: Text(tarefa['tipo']),
                            subtitle: Text(
                              'Quantidade: ${tarefa['quantidade']} | Valor Total: ${tarefa['valorTotal']}',
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

class TarefasDiaDialog extends StatelessWidget {
  final List<Map<String, dynamic>> tarefas;
  final List<Map<String, dynamic>> tarefasGlobais;
  final DateTime data;
  final Function(Map<String, dynamic>, int, Function)
  onEditar; // Alterado para aceitar callback
  final Function(int) onConcluir;
  final Function(int) onExcluir;
  final List<int> indices;
  final Function() onActionCompleted;

  const TarefasDiaDialog({
    super.key,
    required this.tarefas,
    required this.tarefasGlobais,
    required this.data,
    required this.onEditar,
    required this.onConcluir,
    required this.onExcluir,
    required this.indices,
    required this.onActionCompleted,
  });

  int getTarefasConcluidas() {
    return tarefas.where((tarefa) => tarefa['concluida'] == true).length;
  }

  String calcularValorTotal() {
    double total = 0.0;
    for (var tarefa in tarefas) {
      String valorStr = tarefa['valorTotal']
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
    final totalTarefas = tarefas.length;
    final concluidas = getTarefasConcluidas();
    final valorTotal = calcularValorTotal();

    return Dialog(
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 500, minWidth: 300),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Tarefas para ${DateFormat('dd/MM/yyyy').format(data)} ($concluidas/$totalTarefas concluídas)',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF7B3F00),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Total: $valorTotal no dia',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Color(0xFF7B3F00)),
            ),
            const SizedBox(height: 20),
            Container(
              constraints: const BoxConstraints(maxHeight: 400),
              child:
                  tarefas.isEmpty
                      ? const Center(
                        child: Text(
                          'Nenhuma tarefa para este dia',
                          style: TextStyle(fontSize: 16),
                        ),
                      )
                      : ListView.builder(
                        shrinkWrap: true,
                        itemCount: tarefas.length,
                        itemBuilder: (context, index) {
                          final tarefa = tarefas[index];
                          final tarefaIndex = indices[index];
                          final title =
                              tarefas.length > 1
                                  ? 'Tarefa ${index + 1}: ${tarefa['tipo']}'
                                  : tarefa['tipo'];
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            decoration: BoxDecoration(
                              color:
                                  tarefa['concluida']
                                      ? Colors.green[50]
                                      : Colors.white,
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
                                      if (tarefa['concluida'])
                                        const Padding(
                                          padding: EdgeInsets.only(right: 8),
                                          child: Icon(
                                            Icons.cake,
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
                                                tarefa['concluida']
                                                    ? TextDecoration.lineThrough
                                                    : TextDecoration.none,
                                            color:
                                                tarefa['concluida']
                                                    ? Colors.grey
                                                    : const Color(0xFF7B3F00),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Quantidade: ${tarefa['quantidade']}',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                  Text(
                                    'Valor Unitário: ${tarefa['valor']}',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                  Text(
                                    'Valor Total: ${tarefa['valorTotal']}',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                  Text(
                                    'Entrega: ${tarefa['dataTexto']}',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                  Text(
                                    'Cliente: ${tarefa['observacao']}',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                  Text(
                                    'Emitir NFe: ${tarefa['emitirNfe']}',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      IconButton(
                                        icon: const Icon(
                                          Icons.edit,
                                          color: Color(0xFF7B3F00),
                                        ),
                                        onPressed: () {
                                          if (tarefaIndex >= 0 &&
                                              tarefaIndex <
                                                  tarefasGlobais.length) {
                                            // Não fecha o diálogo aqui, apenas chama o onEditar
                                            onEditar(tarefa, tarefaIndex, () {
                                              Navigator.pop(
                                                context,
                                              ); // Fecha o TarefasDiaDialog
                                              onActionCompleted(); // Reabre com a lista atualizada
                                            });
                                          }
                                        },
                                      ),
                                      IconButton(
                                        icon: AnimatedSwitcher(
                                          duration: const Duration(
                                            milliseconds: 300,
                                          ),
                                          transitionBuilder: (
                                            Widget child,
                                            Animation<double> animation,
                                          ) {
                                            return ScaleTransition(
                                              scale: animation,
                                              child: FadeTransition(
                                                opacity: animation,
                                                child: child,
                                              ),
                                            );
                                          },
                                          child: Icon(
                                            tarefa['concluida']
                                                ? Icons.check_circle
                                                : Icons.radio_button_unchecked,
                                            key: ValueKey<bool>(
                                              tarefa['concluida'],
                                            ),
                                            color: const Color(0xFF7B3F00),
                                          ),
                                        ),
                                        onPressed: () {
                                          if (tarefaIndex >= 0 &&
                                              tarefaIndex <
                                                  tarefasGlobais.length) {
                                            onConcluir(tarefaIndex);
                                            Navigator.pop(context);
                                            onActionCompleted();
                                          }
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.delete,
                                          color: Colors.redAccent,
                                        ),
                                        onPressed: () {
                                          if (tarefaIndex >= 0 &&
                                              tarefaIndex <
                                                  tarefasGlobais.length) {
                                            onExcluir(tarefaIndex);
                                            Navigator.pop(context);
                                            onActionCompleted();
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ],
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
                  child: const Text('Fechar', style: TextStyle(fontSize: 16)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
