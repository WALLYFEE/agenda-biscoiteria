enum TipoPessoa { fisica, juridica }

class Cliente {
  final int id;
  final String nome;
  final String cpfCnpj;
  final TipoPessoa tipoPessoa;
  final String endereco;
  final String contato;

  Cliente({
    required this.id,
    required this.nome,
    required this.cpfCnpj,
    required this.tipoPessoa,
    required this.endereco,
    required this.contato,
  });

  factory Cliente.fromMap(Map<String, dynamic> map) {
    return Cliente(
      id: map['id'],
      nome: map['nome'] ?? '',
      cpfCnpj: map['cpfCnpj'] ?? '',
      tipoPessoa: map['tipoPessoa'] == 'juridica' ? TipoPessoa.juridica : TipoPessoa.fisica,
      endereco: map['endereco'] ?? '',
      contato: map['contato'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'cpfCnpj': cpfCnpj,
      'tipoPessoa': tipoPessoa == TipoPessoa.juridica ? 'juridica' : 'fisica',
      'endereco': endereco,
      'contato': contato,
    };
  }
}
