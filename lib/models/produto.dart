class Produto {
  final int id;
  final String codigo;
  final String descricao;
  final String precoVenda;
  final String precoCusto;

  Produto({
    required this.id,
    required this.codigo,
    required this.descricao,
    required this.precoVenda,
    required this.precoCusto,
  });

  // Para salvar/carregar no shared_preferences, use Map:
  factory Produto.fromMap(Map<String, dynamic> map) {
    return Produto(
      id: map['id'] ?? 0,
      codigo: map['codigo'] ?? '',
      descricao: map['descricao'] ?? '',
      precoVenda: map['precoVenda'] ?? '',
      precoCusto: map['precoCusto'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'codigo': codigo,
      'descricao': descricao,
      'precoVenda': precoVenda,
      'precoCusto': precoCusto,
    };
  }
}
