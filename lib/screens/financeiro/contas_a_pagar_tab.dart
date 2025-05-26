import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:agenda/models/conta_a_pagar.dart';
import 'package:agenda/providers/pedidos_provider.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';

class ContasAPagarTab extends StatefulWidget {
  const ContasAPagarTab({Key? key}) : super(key: key);

  @override
  State<ContasAPagarTab> createState() => _ContasAPagarTabState();
}

class _ContasAPagarTabState extends State<ContasAPagarTab>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  bool _alertaMostrado = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _checarContasVencidas();
  }

  void _checarContasVencidas() {
    final provider = Provider.of<PedidosProvider>(context, listen: false);
    final contasVencidas =
        provider.contas.where((conta) {
          if (conta.pago) return false;
          final venc = DateFormat('dd/MM/yyyy').parse(conta.dataVencimento);
          final hoje = DateTime.now();
          return venc.isBefore(DateTime(hoje.year, hoje.month, hoje.day));
        }).toList();

    if (contasVencidas.isNotEmpty && !_alertaMostrado) {
      _alertaMostrado = true;
      final conta = contasVencidas.first;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Conta "${conta.descricao}" está vencida!'),
            backgroundColor: Colors.redAccent,
            action: SnackBarAction(
              label: 'Ver opções',
              textColor: Colors.white,
              onPressed: () => _mostrarDialogoAtraso(conta),
            ),
          ),
        );
      });
    } else if (contasVencidas.isEmpty && _alertaMostrado) {
      _alertaMostrado = false;
    }
  }

  void _mostrarDialogoAtraso(ContaAPagar conta) {
    final provider = Provider.of<PedidosProvider>(context, listen: false);

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Conta "${conta.descricao}" vencida!'),
            content: const Text('Deseja reagendar ou marcar como paga?'),
            actions: [
              TextButton(
                child: const Text('Reagendar'),
                onPressed: () async {
                  final novaData = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                    locale: const Locale('pt', 'BR'),
                  );
                  if (novaData != null) {
                    final contaAtualizada = ContaAPagar(
                      descricao: conta.descricao,
                      valor: conta.valor,
                      dataVencimento: DateFormat('dd/MM/yyyy').format(novaData),
                      pago: conta.pago,
                    );
                    provider.atualizarConta(
                      provider.contas.indexOf(conta),
                      contaAtualizada,
                    );
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Conta reagendada!')),
                    );
                    setState(() => _alertaMostrado = false);
                  }
                },
              ),
              TextButton(
                child: const Text('Marcar paga'),
                onPressed: () {
                  final contaAtualizada = ContaAPagar(
                    descricao: conta.descricao,
                    valor: conta.valor,
                    dataVencimento: conta.dataVencimento,
                    pago: true,
                  );
                  provider.atualizarConta(
                    provider.contas.indexOf(conta),
                    contaAtualizada,
                  );
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Conta marcada como paga!')),
                  );
                  setState(() => _alertaMostrado = false);
                },
              ),
              TextButton(
                child: const Text('Fechar'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
    );
  }

  /// Contas a vencer nos próximos 3 dias
  List<ContaAPagar> _alertaContas(List<ContaAPagar> contas) {
    final hoje = DateTime.now();
    final limite = hoje.add(const Duration(days: 3));
    return contas.where((c) {
      final data = DateFormat('dd/MM/yyyy').parse(c.dataVencimento);
      return !c.pago &&
          data.isAfter(hoje.subtract(const Duration(days: 1))) &&
          data.isBefore(limite.add(const Duration(days: 1)));
    }).toList();
  }

  /// Map contas por dia
  Map<DateTime, List<ContaAPagar>> _mapContasPorDia(List<ContaAPagar> contas) {
    final Map<DateTime, List<ContaAPagar>> contasPorDia = {};
    for (var conta in contas) {
      final data = DateFormat('dd/MM/yyyy').parse(conta.dataVencimento);
      final dia = DateTime(data.year, data.month, data.day);
      contasPorDia.putIfAbsent(dia, () => []).add(conta);
    }
    return contasPorDia;
  }

  void _adicionarConta(BuildContext context, PedidosProvider provider) {
    final formKey = GlobalKey<FormState>();
    String descricao = '';
    DateTime dataVencimento = DateTime.now();
    final valorController = MoneyMaskedTextController(
      decimalSeparator: ',',
      thousandSeparator: '.',
      leftSymbol: 'R\$ ',
    );
    final dataController = TextEditingController(
      text: DateFormat('dd/MM/yyyy').format(dataVencimento),
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder:
          (context) => Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              left: 16,
              right: 16,
              top: 24,
            ),
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Nova Conta a Pagar',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Descrição'),
                      validator:
                          (v) => v!.trim().isEmpty ? 'Campo obrigatório' : null,
                      onChanged: (val) => descricao = val,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: valorController,
                      decoration: const InputDecoration(labelText: 'Valor'),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: dataController,
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: 'Data de vencimento',
                      ),
                      onTap: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: dataVencimento,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          dataVencimento = picked;
                          dataController.text = DateFormat(
                            'dd/MM/yyyy',
                          ).format(picked);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.save, color: Colors.white),
                        label: const Text(
                          'Adicionar',
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                        ),
                        onPressed: () {
                          if (formKey.currentState!.validate()) {
                            final novaConta = ContaAPagar(
                              descricao: descricao.trim(),
                              valor: valorController.text.trim(),
                              dataVencimento: dataController.text,
                              pago: false,
                            );
                            provider.adicionarConta(novaConta);
                            Navigator.pop(context);
                            setState(() {});
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Conta adicionada com sucesso!'),
                                backgroundColor: Color(0xFF7B3F00),
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
    );
  }

  void _editarConta(
    BuildContext context,
    ContaAPagar conta,
    int index,
    PedidosProvider provider,
  ) {
    final formKey = GlobalKey<FormState>();
    String descricao = conta.descricao;
    DateTime dataVencimento = DateFormat(
      'dd/MM/yyyy',
    ).parse(conta.dataVencimento);
    final valorController = MoneyMaskedTextController(
      decimalSeparator: ',',
      thousandSeparator: '.',
      leftSymbol: 'R\$ ',
      initialValue:
          double.tryParse(
            conta.valor
                .replaceAll('R\$ ', '')
                .replaceAll('.', '')
                .replaceAll(',', '.'),
          ) ??
          0.0,
    );
    final dataController = TextEditingController(
      text: DateFormat('dd/MM/yyyy').format(dataVencimento),
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder:
          (context) => Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              left: 16,
              right: 16,
              top: 24,
            ),
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Editar Conta a Pagar',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      initialValue: descricao,
                      decoration: const InputDecoration(labelText: 'Descrição'),
                      validator:
                          (v) => v!.trim().isEmpty ? 'Campo obrigatório' : null,
                      onChanged: (val) => descricao = val,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: valorController,
                      decoration: const InputDecoration(labelText: 'Valor'),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: dataController,
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: 'Data de vencimento',
                      ),
                      onTap: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: dataVencimento,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          dataVencimento = picked;
                          dataController.text = DateFormat(
                            'dd/MM/yyyy',
                          ).format(picked);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.save),
                        label: const Text('Salvar'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                        ),
                        onPressed: () {
                          if (formKey.currentState!.validate()) {
                            final contaEditada = ContaAPagar(
                              descricao: descricao.trim(),
                              valor: valorController.text.trim(),
                              dataVencimento: dataController.text,
                              pago: conta.pago,
                            );
                            provider.atualizarConta(index, contaEditada);
                            Navigator.pop(context);
                            setState(() {});
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Conta editada com sucesso!'),
                                backgroundColor: Color(0xFF7B3F00),
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PedidosProvider>(
      builder: (context, provider, _) {
        final contasPendentes =
            provider.contas
                .where(
                  (c) =>
                      !c.pago &&
                      (_searchQuery.isEmpty ||
                          c.descricao.toLowerCase().contains(
                            _searchQuery.toLowerCase(),
                          )),
                )
                .toList();

        final contasPagas =
            provider.contas
                .where(
                  (c) =>
                      c.pago &&
                      (_searchQuery.isEmpty ||
                          c.descricao.toLowerCase().contains(
                            _searchQuery.toLowerCase(),
                          )),
                )
                .toList();

        return Scaffold(
          body: Column(
            children: [
              TabBar(
                controller: _tabController,
                tabs: const [Tab(text: "Pendentes"), Tab(text: "Pagas")],
                indicatorColor: Theme.of(context).primaryColor,
                labelColor: Theme.of(context).primaryColor,
                unselectedLabelColor: Colors.grey,
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Pesquisar por descrição...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onChanged: (value) => setState(() => _searchQuery = value),
                ),
              ),
              if (_tabController.index == 0 &&
                  _alertaContas(contasPendentes).isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(
                    top: 4,
                    left: 14,
                    right: 14,
                    bottom: 8,
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.warning,
                        color: Colors.deepOrange,
                        size: 20,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        "Contas próximas do vencimento: ${_alertaContas(contasPendentes).length}",
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.deepOrange,
                        ),
                      ),
                    ],
                  ),
                ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildCalendarView(contasPendentes, provider),
                    _buildCalendarView(contasPagas, provider),
                  ],
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _adicionarConta(context, provider),
            child: const Icon(Icons.add, color: Colors.white),
          ),
        );
      },
    );
  }

  Widget _buildCalendarView(
    List<ContaAPagar> contas,
    PedidosProvider provider,
  ) {
    final contasPorDia = _mapContasPorDia(contas);

    return StatefulBuilder(
      builder: (context, setState) {
        return Column(
          children: [
            TableCalendar(
              locale: 'pt_BR',
              firstDay: DateTime(2000),
              lastDay: DateTime(2100),
              focusedDay: _focusedDay,
              daysOfWeekStyle: DaysOfWeekStyle(
                weekendStyle: TextStyle(
                  color: Colors.red[300],
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                weekdayStyle: const TextStyle(
                  color: Colors.black87,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              selectedDayPredicate:
                  (day) => _selectedDay != null && isSameDay(_selectedDay, day),
              eventLoader:
                  (day) =>
                      contasPorDia[DateTime(day.year, day.month, day.day)] ??
                      [],
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: Colors.green.shade200,
                  shape: BoxShape.circle,
                ),
                markerDecoration: BoxDecoration(
                  color: Colors.red.shade400,
                  shape: BoxShape.circle,
                ),
              ),
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
              ),
              onDaySelected: (selected, focused) {
                setState(() {
                  _selectedDay = selected;
                  _focusedDay = focused;
                });
              },
            ),
            const SizedBox(height: 12),
            if (_selectedDay != null &&
                contasPorDia[DateTime(
                      _selectedDay!.year,
                      _selectedDay!.month,
                      _selectedDay!.day,
                    )] !=
                    null)
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  children:
                      contasPorDia[DateTime(
                            _selectedDay!.year,
                            _selectedDay!.month,
                            _selectedDay!.day,
                          )]!
                          .asMap()
                          .entries
                          .map((entry) {
                            final index = provider.contas.indexOf(entry.value);
                            final conta = entry.value;
                            return Card(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 6,
                              ),
                              color:
                                  conta.pago ? Colors.green[50] : Colors.white,
                              elevation: 2,
                              child: ListTile(
                                title: Text(
                                  conta.descricao,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text(
                                  'Valor: ${conta.valor}\nVencimento: ${conta.dataVencimento}',
                                ),
                                isThreeLine: true,
                                trailing: Wrap(
                                  spacing: 0,
                                  children: [
                                    IconButton(
                                      icon: Icon(
                                        conta.pago ? Icons.undo : Icons.check,
                                        color:
                                            conta.pago
                                                ? Colors.grey
                                                : Colors.green,
                                      ),
                                      tooltip:
                                          conta.pago
                                              ? 'Desfazer'
                                              : 'Marcar como paga',
                                      onPressed: () {
                                        final contaAtualizada = ContaAPagar(
                                          descricao: conta.descricao,
                                          valor: conta.valor,
                                          dataVencimento: conta.dataVencimento,
                                          pago: !conta.pago,
                                        );
                                        provider.atualizarConta(
                                          index,
                                          contaAtualizada,
                                        );
                                        setState(() {});
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.edit,
                                        color: Colors.blueAccent,
                                      ),
                                      onPressed:
                                          () => _editarConta(
                                            context,
                                            conta,
                                            index,
                                            provider,
                                          ),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.redAccent,
                                      ),
                                      onPressed: () {
                                        provider.excluirConta(index);
                                        setState(() {});
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text('Conta excluída!'),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            );
                          })
                          .toList(),
                ),
              )
            else
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('Selecione um dia com contas!'),
              ),
          ],
        );
      },
    );
  }
}
