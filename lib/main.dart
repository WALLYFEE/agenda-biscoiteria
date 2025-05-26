import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'providers/pedidos_provider.dart';
import 'providers/produtos_provider.dart';
import 'providers/clientes_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PedidosProvider()),
        ChangeNotifierProvider(create: (_) => ProdutosProvider()),
        ChangeNotifierProvider(create: (_) => ClientesProvider()),
      ],
      child: const NeysApp(),
    ),
  );
}
