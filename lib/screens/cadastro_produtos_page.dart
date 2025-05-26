import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/produto.dart';
import '../providers/produtos_provider.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';

class CadastroProdutosPage extends StatefulWidget {
  const CadastroProdutosPage({Key? key}) : super(key: key);

  @override
  State<CadastroProdutosPage> createState() => _CadastroProdutosPageState();
}

class _CadastroProdutosPageState extends State<CadastroProdutosPage> {
  final _descricaoController = TextEditingController();
  final _precoVendaController = MoneyMaskedTextController(
    decimalSeparator: ',',
    thousandSeparator: '.',
    leftSymbol: 'R\$ ',
  );
  final _precoCustoController = MoneyMaskedTextController(
    decimalSeparator: ',',
    thousandSeparator: '.',
    leftSymbol: 'R\$ ',
  );
  final _formKey = GlobalKey<FormState>();
  String? _codigoAtual;

  void _limparCampos() {
    _descricaoController.clear();
    _precoVendaController.updateValue(0);
    _precoCustoController.updateValue(0);
    _codigoAtual = null;
  }

  void _mostrarDialogoCadastro([Produto? produto, int? index]) {
    final provider = Provider.of<ProdutosProvider>(context, listen: false);

    if (produto == null) {
      _descricaoController.clear();
      _precoVendaController.updateValue(0);
      _precoCustoController.updateValue(0);
      _codigoAtual = provider.gerarCodigoAuto();
    } else {
      _descricaoController.text = produto.descricao;
      _precoVendaController.text = produto.precoVenda;
      _precoCustoController.text = produto.precoCusto;
      _codigoAtual = produto.codigo;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder:
          (context) => Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              left: 16,
              right: 16,
              top: 24,
            ),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      produto == null ? 'Novo Produto' : 'Editar Produto',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      initialValue: _codigoAtual,
                      decoration: const InputDecoration(labelText: 'Código'),
                      readOnly: true,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _descricaoController,
                      decoration: const InputDecoration(labelText: 'Descrição'),
                      validator:
                          (v) =>
                              v!.trim().isEmpty ? 'Informe a descrição' : null,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _precoVendaController,
                      decoration: const InputDecoration(
                        labelText: 'Preço de venda',
                      ),
                      keyboardType: TextInputType.number,
                      validator:
                          (v) =>
                              _precoVendaController.numberValue <= 0
                                  ? 'Informe o preço de venda'
                                  : null,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _precoCustoController,
                      decoration: const InputDecoration(
                        labelText: 'Preço de custo',
                      ),
                      keyboardType: TextInputType.number,
                      validator:
                          (v) =>
                              _precoCustoController.numberValue <= 0
                                  ? 'Informe o preço de custo'
                                  : null,
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.save, color: Colors.white),
                        label: const Text(
                          'Salvar',
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                        ),
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            final novoProduto = Produto(
                              id:
                                  produto?.id ??
                                  DateTime.now().millisecondsSinceEpoch,
                              codigo: _codigoAtual!,
                              descricao: _descricaoController.text.trim(),
                              precoVenda: _precoVendaController.text,
                              precoCusto: _precoCustoController.text,
                            );
                            if (produto == null) {
                              provider.adicionarProduto(novoProduto);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Produto cadastrado!'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            } else {
                              provider.atualizarProduto(index!, novoProduto);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Produto editado!'),
                                  backgroundColor: Colors.blue,
                                ),
                              );
                            }
                            Navigator.pop(context);
                            _limparCampos();
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastro de Produtos'),
       
      ),
      body: Consumer<ProdutosProvider>(
        builder: (context, provider, child) {
          return provider.produtos.isEmpty
              ? const Center(child: Text('Nenhum produto cadastrado.'))
              : ListView.builder(
                itemCount: provider.produtos.length,
                itemBuilder: (context, index) {
                  final produto = provider.produtos[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        child: Text(produto.codigo.replaceAll("DDA", "")),
                        backgroundColor: Colors.brown[200],
                      ),
                      title: Text(
                        produto.descricao,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        'Venda: ${produto.precoVenda}   Custo: ${produto.precoCusto}',
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed:
                                () => _mostrarDialogoCadastro(produto, index),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              Provider.of<ProdutosProvider>(
                                context,
                                listen: false,
                              ).excluirProduto(index);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Produto removido!'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _mostrarDialogoCadastro(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
