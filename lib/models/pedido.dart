import 'produto.dart';
import 'cliente.dart';

class Pedido {
  final int id;
  final Produto produto;
  final Cliente cliente;
  final String quantidade;
  final String valor;
  final String valorTotal;
  final String desconto;
  final String impostoISS;
  final String dataEntrega;
  final String dataTexto;
  final String observacao;
  final String emitirNfe;
  bool concluido; // Agora não é mais final

  Pedido({
    required this.id,
    required this.produto,
    required this.cliente,
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

  factory Pedido.fromMap(Map<String, dynamic> map) {
    return Pedido(
      id: map['id'],
      produto: Produto.fromMap(map['produto']),
      cliente: Cliente.fromMap(map['cliente']),
      quantidade: map['quantidade'] ?? '',
      valor: map['valor'] ?? '',
      valorTotal: map['valorTotal'] ?? '',
      desconto: map['desconto'] ?? '',
      impostoISS: map['impostoISS'] ?? '',
      dataEntrega: map['dataEntrega'] ?? '',
      dataTexto: map['dataTexto'] ?? '',
      observacao: map['observacao'] ?? '',
      emitirNfe: map['emitirNfe'] ?? '',
      concluido: map['concluido'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'produto': produto.toMap(),
      'cliente': cliente.toMap(),
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
}
