import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../models/pedido.dart';
import '../models/produto.dart';
import '../models/cliente.dart';
import '../providers/pedidos_provider.dart';
import '../providers/produtos_provider.dart';
import '../providers/clientes_provider.dart';
import '../utils/format_utils.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';

class ListaPedidosTab extends StatefulWidget {
  const ListaPedidosTab({Key? key}) : super(key: key);

  @override
  State<ListaPedidosTab> createState() => _ListaPedidosTabState();
}

class _ListaPedidosTabState extends State<ListaPedidosTab>
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

  int _proximoId(List<Pedido> pedidos) {
    if (pedidos.isEmpty) return 1;
    final ids = pedidos.map((p) => p.id).toList()..sort();
    return ids.last + 1;
  }

  List<Pedido> _alertaPedidos(List<Pedido> pedidos) {
    final hoje = DateTime.now();
    final limite = hoje.add(const Duration(days: 3));
    return pedidos.where((p) {
      final data = DateTime.parse(p.dataEntrega);
      return !p.concluido &&
          data.isAfter(hoje.subtract(const Duration(days: 1))) &&
          data.isBefore(limite.add(const Duration(days: 1)));
    }).toList();
  }

  Map<DateTime, List<Pedido>> _mapPedidosPorDia(List<Pedido> pedidos) {
    final Map<DateTime, List<Pedido>> pedidosPorDia = {};
    for (var pedido in pedidos) {
      final data = DateTime.parse(pedido.dataEntrega);
      final dia = DateTime(data.year, data.month, data.day);
      pedidosPorDia.putIfAbsent(dia, () => []).add(pedido);
    }
    return pedidosPorDia;
  }

  void _adicionarPedido(BuildContext context, PedidosProvider provider) {
    final produtosProvider = Provider.of<ProdutosProvider>(
      context,
      listen: false,
    );
    final clientesProvider = Provider.of<ClientesProvider>(
      context,
      listen: false,
    );

    final formKey = GlobalKey<FormState>();
    Produto? produtoSelecionado;
    Cliente? clienteSelecionado;
    String quantidade = '';
    String observacao = '';
    String emitirNfe = 'Não';
    DateTime dataSelecionada = DateTime.now();

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

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
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
                      'Novo Pedido',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 16),

                    DropdownButtonFormField<Produto>(
                      decoration: const InputDecoration(labelText: 'Produto'),
                      value: produtoSelecionado,
                      items:
                          produtosProvider.produtos
                              .map(
                                (p) => DropdownMenuItem(
                                  value: p,
                                  child: Text(p.descricao),
                                ),
                              )
                              .toList(),
                      onChanged: (produto) {
                        setState(() {
                          produtoSelecionado = produto;
                        });
                      },
                      validator:
                          (value) =>
                              value == null ? 'Selecione o produto' : null,
                    ),

                    const SizedBox(height: 8),

                    DropdownButtonFormField<Cliente>(
                      decoration: const InputDecoration(labelText: 'Cliente'),
                      value: clienteSelecionado,
                      items:
                          clientesProvider.clientes
                              .map(
                                (c) => DropdownMenuItem(
                                  value: c,
                                  child: Text('${c.nome} - ${c.cpfCnpj}'),
                                ),
                              )
                              .toList(),
                      onChanged: (cliente) {
                        setState(() {
                          clienteSelecionado = cliente;
                        });
                      },
                      validator:
                          (value) =>
                              value == null ? 'Selecione o cliente' : null,
                    ),

                    const SizedBox(height: 8),

                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Quantidade',
                      ),
                      keyboardType: TextInputType.number,
                      validator:
                          (v) => v!.trim().isEmpty ? 'Campo obrigatório' : null,
                      onChanged: (val) => quantidade = val,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: valorController,
                      decoration: const InputDecoration(labelText: 'Valor'),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: descontoController,
                      decoration: const InputDecoration(labelText: 'Desconto'),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: dataController,
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: 'Data de entrega',
                      ),
                      onTap: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: dataSelecionada,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          dataSelecionada = picked;
                          dataController.text = DateFormat(
                            'dd/MM/yyyy',
                          ).format(picked);
                        }
                      },
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: emitirNfe,
                      items:
                          ['Sim', 'Não']
                              .map(
                                (value) => DropdownMenuItem(
                                  value: value,
                                  child: Text(value),
                                ),
                              )
                              .toList(),
                      decoration: const InputDecoration(
                        labelText: 'Emitir NFe?',
                      ),
                      onChanged: (value) => emitirNfe = value!,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Observações (cliente, telefone...)',
                      ),
                      onChanged: (val) => observacao = val,
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
                            final qtd = int.tryParse(quantidade) ?? 0;
                            final valorUnitario = converterParaDouble(
                              valorController.text,
                            );
                            final desconto = converterParaDouble(
                              descontoController.text,
                            );
                            final totalBase = qtd * valorUnitario;
                            final valorTotal = totalBase - desconto;
                            final iss =
                                emitirNfe == 'Sim' ? totalBase * 0.05 : 0.0;

                            final novoPedido = Pedido(
                              id: _proximoId(provider.pedidos),
                              produto: produtoSelecionado!,
                              cliente: clienteSelecionado!,
                              quantidade: quantidade,
                              valor: formatarMoeda(valorUnitario),
                              valorTotal: formatarMoeda(valorTotal),
                              desconto: formatarMoeda(desconto),
                              impostoISS: formatarMoeda(iss),
                              dataEntrega: DateFormat(
                                'yyyy-MM-dd',
                              ).format(dataSelecionada),
                              dataTexto: dataController.text,
                              observacao: observacao,
                              emitirNfe: emitirNfe,
                              concluido: false,
                            );

                            provider.adicionarPedido(novoPedido);
                            Navigator.pop(context);
                            setState(() {});
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Pedido adicionado com sucesso!'),
                                backgroundColor: Color(0xFF7B3F00),
                              ),
                            );
                            _alertaMostrado = false;
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

  void _editarPedido(
    BuildContext context,
    Pedido pedido,
    int index,
    PedidosProvider provider,
  ) {
    final produtosProvider = Provider.of<ProdutosProvider>(
      context,
      listen: false,
    );
    final clientesProvider = Provider.of<ClientesProvider>(
      context,
      listen: false,
    );

    final formKey = GlobalKey<FormState>();
    Produto? produtoSelecionado = pedido.produto;
    Cliente? clienteSelecionado = pedido.cliente;
    String quantidade = pedido.quantidade;
    String observacao = pedido.observacao;
    String emitirNfe = pedido.emitirNfe;
    DateTime dataSelecionada = DateFormat('dd/MM/yyyy').parse(pedido.dataTexto);

    final valorController = MoneyMaskedTextController(
      decimalSeparator: ',',
      thousandSeparator: '.',
      leftSymbol: 'R\$ ',
      initialValue: converterParaDouble(pedido.valor),
    );
    final descontoController = MoneyMaskedTextController(
      decimalSeparator: ',',
      thousandSeparator: '.',
      leftSymbol: 'R\$ ',
      initialValue: converterParaDouble(pedido.desconto),
    );
    final dataController = TextEditingController(
      text: DateFormat('dd/MM/yyyy').format(dataSelecionada),
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
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
                      'Editar Pedido',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 16),

                    DropdownButtonFormField<Produto>(
                      decoration: const InputDecoration(labelText: 'Produto'),
                      value: produtoSelecionado,
                      items:
                          produtosProvider.produtos
                              .map(
                                (p) => DropdownMenuItem(
                                  value: p,
                                  child: Text(p.descricao),
                                ),
                              )
                              .toList(),
                      onChanged: (produto) {
                        setState(() {
                          produtoSelecionado = produto;
                        });
                      },
                      validator:
                          (value) =>
                              value == null ? 'Selecione o produto' : null,
                    ),

                    const SizedBox(height: 8),

                    DropdownButtonFormField<Cliente>(
                      decoration: const InputDecoration(labelText: 'Cliente'),
                      value: clienteSelecionado,
                      items:
                          clientesProvider.clientes
                              .map(
                                (c) => DropdownMenuItem(
                                  value: c,
                                  child: Text('${c.nome} - ${c.cpfCnpj}'),
                                ),
                              )
                              .toList(),
                      onChanged: (cliente) {
                        setState(() {
                          clienteSelecionado = cliente;
                        });
                      },
                      validator:
                          (value) =>
                              value == null ? 'Selecione o cliente' : null,
                    ),

                    const SizedBox(height: 8),

                    TextFormField(
                      initialValue: quantidade,
                      decoration: const InputDecoration(
                        labelText: 'Quantidade',
                      ),
                      keyboardType: TextInputType.number,
                      validator:
                          (v) => v!.trim().isEmpty ? 'Campo obrigatório' : null,
                      onChanged: (val) => quantidade = val,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: valorController,
                      decoration: const InputDecoration(labelText: 'Valor'),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: descontoController,
                      decoration: const InputDecoration(labelText: 'Desconto'),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: dataController,
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: 'Data de entrega',
                      ),
                      onTap: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: dataSelecionada,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          dataSelecionada = picked;
                          dataController.text = DateFormat(
                            'dd/MM/yyyy',
                          ).format(picked);
                        }
                      },
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: emitirNfe,
                      items:
                          ['Sim', 'Não']
                              .map(
                                (value) => DropdownMenuItem(
                                  value: value,
                                  child: Text(value),
                                ),
                              )
                              .toList(),
                      decoration: const InputDecoration(
                        labelText: 'Emitir NFe?',
                      ),
                      onChanged: (value) => emitirNfe = value!,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      initialValue: observacao,
                      decoration: const InputDecoration(
                        labelText: 'Observações (cliente, telefone...)',
                      ),
                      onChanged: (val) => observacao = val,
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
                            final qtd = int.tryParse(quantidade) ?? 0;
                            final valorUnitario = converterParaDouble(
                              valorController.text,
                            );
                            final desconto = converterParaDouble(
                              descontoController.text,
                            );
                            final totalBase = qtd * valorUnitario;
                            final valorTotal = totalBase - desconto;
                            final iss =
                                emitirNfe == 'Sim' ? totalBase * 0.05 : 0.0;

                            final pedidoAtualizado = Pedido(
                              id: pedido.id,
                              produto: produtoSelecionado!,
                              cliente: clienteSelecionado!,
                              quantidade: quantidade,
                              valor: formatarMoeda(valorUnitario),
                              valorTotal: formatarMoeda(valorTotal),
                              desconto: formatarMoeda(desconto),
                              impostoISS: formatarMoeda(iss),
                              dataEntrega: DateFormat(
                                'yyyy-MM-dd',
                              ).format(dataSelecionada),
                              dataTexto: dataController.text,
                              observacao: observacao,
                              emitirNfe: emitirNfe,
                              concluido: pedido.concluido,
                            );

                            provider.atualizarPedido(index, pedidoAtualizado);
                            Navigator.pop(context);
                            setState(() {});
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Pedido editado com sucesso!'),
                                backgroundColor: Color(0xFF7B3F00),
                              ),
                            );
                            _alertaMostrado = false;
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

  void _mostrarDialogoAtraso(Pedido pedido) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Pedido ${pedido.id} atrasado!'),
            content: const Text('Deseja reagendar ou marcar como entregue?'),
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
                    final provider = Provider.of<PedidosProvider>(
                      context,
                      listen: false,
                    );
                    final novoPedido = Pedido(
                      id: pedido.id,
                      produto: pedido.produto,
                      cliente: pedido.cliente,
                      quantidade: pedido.quantidade,
                      valor: pedido.valor,
                      valorTotal: pedido.valorTotal,
                      desconto: pedido.desconto,
                      impostoISS: pedido.impostoISS,
                      dataEntrega: DateFormat('yyyy-MM-dd').format(novaData),
                      dataTexto: DateFormat('dd/MM/yyyy').format(novaData),
                      observacao: pedido.observacao,
                      emitirNfe: pedido.emitirNfe,
                      concluido: false,
                    );
                    provider.atualizarPedido(
                      provider.pedidos.indexOf(pedido),
                      novoPedido,
                    );
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Pedido reagendado!')),
                    );
                    setState(() {
                      _alertaMostrado = false;
                    });
                  }
                },
              ),
              TextButton(
                child: const Text('Marcar entregue'),
                onPressed: () {
                  final provider = Provider.of<PedidosProvider>(
                    context,
                    listen: false,
                  );
                  final pedidoAtualizado = Pedido(
                    id: pedido.id,
                    produto: pedido.produto,
                    cliente: pedido.cliente,
                    quantidade: pedido.quantidade,
                    valor: pedido.valor,
                    valorTotal: pedido.valorTotal,
                    desconto: pedido.desconto,
                    impostoISS: pedido.impostoISS,
                    dataEntrega: pedido.dataEntrega,
                    dataTexto: pedido.dataTexto,
                    observacao: pedido.observacao,
                    emitirNfe: pedido.emitirNfe,
                    concluido: true,
                  );
                  provider.atualizarPedido(
                    provider.pedidos.indexOf(pedido),
                    pedidoAtualizado,
                  );
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Pedido marcado como entregue!'),
                    ),
                  );
                  setState(() {
                    _alertaMostrado = false;
                  });
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

  void _detalhesPedido(
    BuildContext context,
    Pedido pedido,
    int index,
    PedidosProvider provider,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            top: 24,
            left: 24,
            right: 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    '${pedido.produto.descricao} (ID: ${pedido.id})',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text('Cliente: ${pedido.cliente.nome}'),
                Text('CPF/CNPJ: ${pedido.cliente.cpfCnpj}'),
                Text('Quantidade: ${pedido.quantidade}'),
                Text('Valor unitário: ${pedido.valor}'),
                Text('Valor total: ${pedido.valorTotal}'),
                Text('Desconto: ${pedido.desconto}'),
                Text('ISS: ${pedido.impostoISS}'),
                Text('Data de entrega: ${pedido.dataTexto}'),
                Text('Emitir NFe: ${pedido.emitirNfe}'),
                Text('Observações: ${pedido.observacao}'),
                Text('Status: ${pedido.concluido ? "Concluído" : "Pendente"}'),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: Icon(
                        pedido.concluido ? Icons.undo : Icons.check,
                        color: pedido.concluido ? Colors.grey : Colors.green,
                      ),
                      tooltip:
                          pedido.concluido ? 'Desfazer conclusão' : 'Concluir',
                      onPressed: () {
                        provider.concluirPedido(index);
                        setState(() {});
                        Navigator.pop(context);
                        _alertaMostrado = false;
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blueAccent),
                      onPressed: () {
                        Navigator.pop(context);
                        _editarPedido(context, pedido, index, provider);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.redAccent),
                      onPressed: () {
                        provider.excluirPedido(index);
                        Navigator.pop(context);
                        setState(() {});
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Pedido excluído!'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        _alertaMostrado = false;
                      },
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

  @override
  Widget build(BuildContext context) {
    final pedidosProvider = Provider.of<PedidosProvider>(context);
    final pedidosAtrasados =
        pedidosProvider.pedidos.where((pedido) {
          if (pedido.concluido) return false;
          final entrega = DateTime.parse(pedido.dataEntrega);
          final hoje = DateTime.now();
          return entrega.isBefore(DateTime(hoje.year, hoje.month, hoje.day));
        }).toList();

    if (pedidosAtrasados.isNotEmpty && !_alertaMostrado) {
      _alertaMostrado = true;
      final pedido = pedidosAtrasados.first;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Pedido ${pedido.id} está atrasado!'),
            backgroundColor: Colors.redAccent,
            action: SnackBarAction(
              label: 'Ver opções',
              textColor: Colors.white,
              onPressed: () {
                _mostrarDialogoAtraso(pedido);
              },
            ),
          ),
        );
      });
    } else if (pedidosAtrasados.isEmpty && _alertaMostrado) {
      _alertaMostrado = false;
    }

    final pedidosPendentes =
        pedidosProvider.pedidos
            .where(
              (p) =>
                  !p.concluido &&
                  (_searchQuery.isEmpty ||
                      p.produto.descricao.toLowerCase().contains(
                        _searchQuery.toLowerCase(),
                      ) ||
                      p.cliente.nome.toLowerCase().contains(
                        _searchQuery.toLowerCase(),
                      ) ||
                      p.observacao.toLowerCase().contains(
                        _searchQuery.toLowerCase(),
                      )),
            )
            .toList();

    final pedidosConcluidos =
        pedidosProvider.pedidos
            .where(
              (p) =>
                  p.concluido &&
                  (_searchQuery.isEmpty ||
                      p.produto.descricao.toLowerCase().contains(
                        _searchQuery.toLowerCase(),
                      ) ||
                      p.cliente.nome.toLowerCase().contains(
                        _searchQuery.toLowerCase(),
                      ) ||
                      p.observacao.toLowerCase().contains(
                        _searchQuery.toLowerCase(),
                      )),
            )
            .toList();

    return Scaffold(
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            tabs: const [Tab(text: "Pendentes"), Tab(text: "Concluídos")],
            indicatorColor: Theme.of(context).primaryColor,
            labelColor: Theme.of(context).primaryColor,
            unselectedLabelColor: Colors.grey,
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Pesquisar por cliente, produto ou observação...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),
          if (_tabController.index == 0 &&
              _alertaPedidos(pedidosPendentes).isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(
                top: 4,
                left: 14,
                right: 14,
                bottom: 8,
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning, color: Colors.deepOrange, size: 20),
                  const SizedBox(width: 6),
                  Text(
                    "Pedidos próximos da entrega: ${_alertaPedidos(pedidosPendentes).length}",
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
                _buildCalendarView(pedidosPendentes, pedidosProvider),
                _buildCalendarView(pedidosConcluidos, pedidosProvider),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _adicionarPedido(context, pedidosProvider),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildCalendarView(List<Pedido> pedidos, PedidosProvider provider) {
    final pedidosPorDia = _mapPedidosPorDia(pedidos);

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
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
                weekdayStyle: const TextStyle(
                  color: Colors.black87,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
              selectedDayPredicate:
                  (day) => _selectedDay != null && isSameDay(_selectedDay, day),
              eventLoader:
                  (day) =>
                      pedidosPorDia[DateTime(day.year, day.month, day.day)] ??
                      [],
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: Colors.orange.shade100,
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
                pedidosPorDia[DateTime(
                      _selectedDay!.year,
                      _selectedDay!.month,
                      _selectedDay!.day,
                    )] !=
                    null)
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  children:
                      pedidosPorDia[DateTime(
                            _selectedDay!.year,
                            _selectedDay!.month,
                            _selectedDay!.day,
                          )]!
                          .map((pedido) {
                            final index = provider.pedidos.indexOf(pedido);
                            return Card(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 6,
                              ),
                              color:
                                  pedido.concluido
                                      ? Colors.green[50]
                                      : Colors.white,
                              elevation: 2,
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Colors.brown,
                                  child: Text(
                                    '${pedido.id}',
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                                title: Text(
                                  pedido.produto.descricao,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text(
                                  'Cliente: ${pedido.cliente.nome}\nQtd: ${pedido.quantidade}\nObs: ${pedido.observacao}',
                                ),
                                isThreeLine: true,
                                trailing: Wrap(
                                  spacing: 0,
                                  children: [
                                    IconButton(
                                      icon: Icon(
                                        pedido.concluido
                                            ? Icons.undo
                                            : Icons.check,
                                        color:
                                            pedido.concluido
                                                ? Colors.grey
                                                : Colors.green,
                                      ),
                                      tooltip:
                                          pedido.concluido
                                              ? 'Desfazer'
                                              : 'Concluir',
                                      onPressed: () {
                                        provider.concluirPedido(index);
                                        setState(() {});
                                        _alertaMostrado = false;
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.edit,
                                        color: Colors.blueAccent,
                                      ),
                                      onPressed:
                                          () => _editarPedido(
                                            context,
                                            pedido,
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
                                        provider.excluirPedido(index);
                                        setState(() {});
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text('Pedido excluído!'),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                        _alertaMostrado = false;
                                      },
                                    ),
                                  ],
                                ),
                                onTap:
                                    () => _detalhesPedido(
                                      context,
                                      pedido,
                                      index,
                                      provider,
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
                child: Text('Selecione um dia com pedidos!'),
              ),
          ],
        );
      },
    );
  }
}
