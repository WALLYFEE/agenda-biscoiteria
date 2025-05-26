// lib/providers/pedidos_provider.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/pedido.dart';
import '../models/conta_a_pagar.dart';

class PedidosProvider with ChangeNotifier {
  List<Pedido> _pedidos = [];
  List<ContaAPagar> _contas = [];
  String _ordenacao = 'padrao';

  List<Pedido> get pedidos => _pedidos;
  List<ContaAPagar> get contas => _contas;
  String get ordenacao => _ordenacao;

  PedidosProvider() {
    carregarDados();
  }

  void carregarDados() async {
    final prefs = await SharedPreferences.getInstance();
    final String? pedidosString = prefs.getString('pedidos');
    if (pedidosString != null) {
      final List<dynamic> pedidosJson = jsonDecode(pedidosString);
      _pedidos = pedidosJson.map((p) => Pedido.fromMap(p)).toList();
    }
    final String? contasString = prefs.getString('contas');
    if (contasString != null) {
      final List<dynamic> contasJson = jsonDecode(contasString);
      _contas = contasJson.map((c) => ContaAPagar.fromMap(c)).toList();
    }
    notifyListeners();
  }

  Future<void> salvarDados() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'pedidos',
      jsonEncode(_pedidos.map((p) => p.toMap()).toList()),
    );
    await prefs.setString(
      'contas',
      jsonEncode(_contas.map((c) => c.toMap()).toList()),
    );
  }

  void adicionarPedido(Pedido pedido) {
    _pedidos.add(pedido);
    salvarDados();
    notifyListeners();
  }

  void atualizarPedido(int index, Pedido pedido) {
    if (index >= 0 && index < _pedidos.length) {
      _pedidos[index] = pedido;
      salvarDados();
      notifyListeners();
    }
  }

  void excluirPedido(int index) {
    if (index >= 0 && index < _pedidos.length) {
      _pedidos.removeAt(index);
      salvarDados();
      notifyListeners();
    }
  }

  void concluirPedido(int index) {
    if (index >= 0 && index < _pedidos.length) {
      _pedidos[index].concluido = !_pedidos[index].concluido;
      salvarDados();
      notifyListeners();
    }
  }

  void adicionarConta(ContaAPagar conta) {
    _contas.add(conta);
    salvarDados();
    notifyListeners();
  }

  void atualizarConta(int index, ContaAPagar conta) {
    if (index >= 0 && index < _contas.length) {
      _contas[index] = conta;
      salvarDados();
      notifyListeners();
    }
  }

  void excluirConta(int index) {
    if (index >= 0 && index < _contas.length) {
      _contas.removeAt(index);
      salvarDados();
      notifyListeners();
    }
  }

  void setOrdenacao(String novaOrdenacao) {
    _ordenacao = novaOrdenacao;
    notifyListeners();
  }
}
