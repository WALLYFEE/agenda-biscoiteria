// lib/widgets/pedidos_dia_dialog.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/pedido.dart';
import '../providers/pedidos_provider.dart';

class PedidosDiaDialog extends StatelessWidget {
  final List<Pedido> pedidos;
  final DateTime data;
  final List<int> indices;

  const PedidosDiaDialog({
    super.key,
    required this.pedidos,
    required this.data,
    required this.indices,
  });

  @override
  Widget build(BuildContext context) {
    final totalPedidos = pedidos.length;
    final concluidos = pedidos.where((p) => p.concluido).length;

    return AlertDialog(
      title: Text(
        'Pedidos de ${DateFormat('dd/MM/yyyy').format(data)} ($concluidos/$totalPedidos concluídos)',
        style: const TextStyle(color: Color(0xFF7B3F00)),
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: pedidos.length,
          itemBuilder: (context, index) {
            final pedido = pedidos[index];
            final pedidoIndex = indices[index];

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 6),
              child: ListTile(
                leading: Icon(
                  pedido.concluido
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                  color: pedido.concluido ? Colors.green : Colors.orange,
                ),
                title: Text(pedido.produto.descricao),
                subtitle: Text(
                  'Qtd: ${pedido.quantidade} | Valor: ${pedido.valorTotal}',
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.check),
                  onPressed: () {
                    Provider.of<PedidosProvider>(
                      context,
                      listen: false,
                    ).concluirPedido(pedidoIndex);
                    Navigator.pop(context);
                  },
                ),
              ),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Fechar'),
        ),
      ],
    );
  }
}
