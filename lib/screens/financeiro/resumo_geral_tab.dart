// lib/screens/financeiro/resumo_geral_tab.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/pedidos_provider.dart';
import '../../models/pedido.dart';
import '../../models/conta_a_pagar.dart';

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
              _buildResumoCard('Total de Pedidos', '$totalPedidos'),
              _buildResumoCard('Faturamento Bruto', valorBrutoTotal),
              _buildResumoCard('Faturamento Líquido', valorLiquidoTotal),
              _buildResumoCard('Descontos Totais', descontoTotal),
              _buildResumoCard('Impostos ISS Totais', issTotal),
              _buildResumoCard('Total Contas a Pagar', totalContasAPagar),
            ],
          ),
        );
      },
    );
  }

  Widget _buildResumoCard(String titulo, String valor) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        title: Text(
          titulo,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF7B3F00),
          ),
        ),
        subtitle: Text(
          valor,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
