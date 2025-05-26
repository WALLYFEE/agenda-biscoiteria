// lib/utils/format_utils.dart
String limparMascaraMoeda(String valor) {
  return valor.replaceAll('R\$ ', '').replaceAll('.', '').replaceAll(',', '.');
}

double converterParaDouble(String valor) {
  return double.tryParse(limparMascaraMoeda(valor)) ?? 0.0;
}

String formatarMoeda(double valor) {
  return 'R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')}';
}
