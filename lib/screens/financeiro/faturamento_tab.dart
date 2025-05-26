import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/pedido.dart';
import '../../providers/pedidos_provider.dart';

class FaturamentoTab extends StatefulWidget {
  const FaturamentoTab({super.key});

  @override
  State<FaturamentoTab> createState() => _FaturamentoTabState();
}

class _FaturamentoTabState extends State<FaturamentoTab> {
  int? _anoSelecionado;
  int? _mesSelecionado;

  Map<int, Set<int>> _getAnosMesesDisponiveis(List<Pedido> pedidos) {
    Map<int, Set<int>> anosMeses = {};
    for (var pedido in pedidos) {
      final data = DateTime.parse(pedido.dataEntrega);
      anosMeses.putIfAbsent(data.year, () => {}).add(data.month);
    }
    return anosMeses;
  }

  List<Pedido> _pedidosDoMes(List<Pedido> pedidos, int ano, int mes) {
    return pedidos.where((p) {
      final data = DateTime.parse(p.dataEntrega);
      return data.year == ano && data.month == mes;
    }).toList();
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
        final pedidos = provider.pedidos;
        final anosMeses = _getAnosMesesDisponiveis(pedidos);
        final anos = anosMeses.keys.toList()..sort((a, b) => b.compareTo(a));
        final meses =
            _anoSelecionado == null
                  ? <int>[]
                  : (anosMeses[_anoSelecionado!] ?? <int>{}).toList()
              ..sort();

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              DropdownButtonFormField<int>(
                decoration: const InputDecoration(labelText: 'Ano'),
                value: _anoSelecionado,
                onChanged: (value) {
                  setState(() {
                    _anoSelecionado = value;
                    _mesSelecionado = null;
                  });
                },
                items:
                    anos
                        .map(
                          (ano) => DropdownMenuItem<int>(
                            value: ano,
                            child: Text(ano.toString()),
                          ),
                        )
                        .toList(),
              ),
              const SizedBox(height: 12),
              if (_anoSelecionado != null)
                DropdownButtonFormField<int>(
                  decoration: const InputDecoration(labelText: 'Mês'),
                  value: _mesSelecionado,
                  onChanged: (value) {
                    setState(() {
                      _mesSelecionado = value;
                    });
                  },
                  items:
                      meses
                          .map(
                            (mes) => DropdownMenuItem<int>(
                              value: mes,
                              child: Text(
                                toBeginningOfSentenceCase(
                                      DateFormat.MMMM(
                                        'pt_BR',
                                      ).format(DateTime(0, mes)),
                                    ) ??
                                    '',
                              ),
                            ),
                          )
                          .toList(),
                ),
              const SizedBox(height: 24),
              if (_anoSelecionado != null && _mesSelecionado != null)
                Builder(
                  builder: (context) {
                    final pedidosMes = _pedidosDoMes(
                      pedidos,
                      _anoSelecionado!,
                      _mesSelecionado!,
                    );
                    if (pedidosMes.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.all(32.0),
                        child: Text(
                          'Nenhum faturamento registrado para este mês.',
                          textAlign: TextAlign.center,
                        ),
                      );
                    }

                    final quantidade = pedidosMes.length;
                    final valorBruto = calcularValorBruto(pedidosMes);
                    final descontoTotal = calcularDescontoTotal(pedidosMes);
                    final issTotal = calcularImpostoISSTotal(pedidosMes);

                    return Card(
                      margin: const EdgeInsets.only(bottom: 16.0),
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${toBeginningOfSentenceCase(DateFormat.MMMM('pt_BR').format(DateTime(0, _mesSelecionado!)))} $_anoSelecionado',
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
                  },
                ),
            ],
          ),
        );
      },
    );
  }
}
