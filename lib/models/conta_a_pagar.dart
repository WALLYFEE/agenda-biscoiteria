// lib/models/conta_a_pagar.dart
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
