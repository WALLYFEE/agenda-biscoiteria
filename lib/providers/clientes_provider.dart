import 'package:flutter/material.dart';
import '../models/cliente.dart';

class ClientesProvider extends ChangeNotifier {
  final List<Cliente> _clientes = [];

  List<Cliente> get clientes => List.unmodifiable(_clientes);

  void adicionarCliente(Cliente cliente) {
    _clientes.add(cliente);
    notifyListeners();
  }

  void atualizarCliente(int index, Cliente cliente) {
    _clientes[index] = cliente;
    notifyListeners();
  }

  void excluirCliente(int index) {
    _clientes.removeAt(index);
    notifyListeners();
  }
}
