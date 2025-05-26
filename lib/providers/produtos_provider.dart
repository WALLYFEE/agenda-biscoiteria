import 'package:flutter/material.dart';
import '../models/produto.dart';

class ProdutosProvider extends ChangeNotifier {
  final List<Produto> _produtos = [];

  List<Produto> get produtos => List.unmodifiable(_produtos);

  void adicionarProduto(Produto produto) {
    _produtos.add(produto);
    notifyListeners();
  }

  void atualizarProduto(int index, Produto produto) {
    _produtos[index] = produto;
    notifyListeners();
  }

  void excluirProduto(int index) {
    _produtos.removeAt(index);
    notifyListeners();
  }

  String gerarCodigoAuto() {
    final prefixo = "DDA";
    if (_produtos.isEmpty) return "${prefixo}0001";
    final ultimosCodigos =
        _produtos
            .map((p) => int.tryParse(p.codigo.replaceAll(prefixo, "")) ?? 0)
            .toList();
    final proximoNumero =
        (ultimosCodigos.isEmpty
            ? 1
            : (ultimosCodigos.reduce((a, b) => a > b ? a : b) + 1));
    return "$prefixo${proximoNumero.toString().padLeft(4, '0')}";
  }
}
