// lib/widgets/pedidos_em_aberto_tab.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/pedido.dart';
import '../providers/pedidos_provider.dart';
import 'pedidos_dia_dialog.dart';

class PedidosEmAbertoTab extends StatelessWidget {
  const PedidosEmAbertoTab({super.key});

  Map<String, List<Pedido>> _agruparPorData(List<Pedido> pedidos) {
    final Map<String, List<Pedido>> agrupados = {};
    for (var pedido in pedidos.where((p) => !p.concluido)) {
      final data = DateFormat(
        'dd/MM/yyyy',
      ).format(DateTime.parse(pedido.dataEntrega));
      agrupados.putIfAbsent(data, () => []).add(pedido);
    }
    return agrupados;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PedidosProvider>(
      builder: (context, provider, child) {
        final agrupados = _agruparPorData(provider.pedidos);
        final datas =
            agrupados.keys.toList()..sort(
              (a, b) => DateFormat(
                'dd/MM/yyyy',
              ).parse(b).compareTo(DateFormat('dd/MM/yyyy').parse(a)),
            );

        return datas.isEmpty
            ? const Center(child: Text('Nenhum pedido em aberto!'))
            : ListView.builder(
              itemCount: datas.length,
              itemBuilder: (context, index) {
                final data = datas[index];
                final pedidosDia = agrupados[data]!;
                final indices =
                    pedidosDia.map((p) => provider.pedidos.indexOf(p)).toList();

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  child: ListTile(
                    leading: const Icon(
                      Icons.pending_actions,
                      color: Color(0xFF7B3F00),
                    ),
                    title: Text(data),
                    subtitle: Text('${pedidosDia.length} pedido(s)'),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder:
                            (_) => PedidosDiaDialog(
                              pedidos: pedidosDia,
                              data: DateFormat('dd/MM/yyyy').parse(data),
                              indices: indices,
                            ),
                      );
                    },
                  ),
                );
              },
            );
      },
    );
  }
}
