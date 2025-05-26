import 'package:flutter/material.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:provider/provider.dart';
import '../models/cliente.dart';
import '../providers/clientes_provider.dart';

class CadastroClientesPage extends StatefulWidget {
  const CadastroClientesPage({Key? key}) : super(key: key);

  @override
  State<CadastroClientesPage> createState() => _CadastroClientesPageState();
}

class _CadastroClientesPageState extends State<CadastroClientesPage> {
  final _formKey = GlobalKey<FormState>();

  TipoPessoa _tipoPessoa = TipoPessoa.fisica;
  late MaskedTextController _cpfCnpjController;
  late MaskedTextController _contatoController;
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _enderecoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _cpfCnpjController = MaskedTextController(mask: '000.000.000-00');
    _contatoController = MaskedTextController(mask: '(00)00000-0000');
  }

  void _atualizarMascaraCPF_CNPJ(TipoPessoa tipo) {
    final value = _cpfCnpjController.text;
    setState(() {
      _tipoPessoa = tipo;
      _cpfCnpjController = MaskedTextController(
        mask:
            tipo == TipoPessoa.fisica ? '000.000.000-00' : '00.000.000/0000-00',
      )..text = value.replaceAll(RegExp(r'\D'), '');
    });
  }

  void _limparCampos() {
    _nomeController.clear();
    _cpfCnpjController.text = '';
    _enderecoController.clear();
    _contatoController.text = '';
    setState(() {
      _tipoPessoa = TipoPessoa.fisica;
      _cpfCnpjController = MaskedTextController(mask: '000.000.000-00');
      _contatoController = MaskedTextController(mask: '(00)00000-0000');
    });
  }

  void _mostrarDialogoCadastro([Cliente? cliente, int? index]) {
    if (cliente != null) {
      _nomeController.text = cliente.nome;
      _cpfCnpjController = MaskedTextController(
        mask:
            cliente.tipoPessoa == TipoPessoa.fisica
                ? '000.000.000-00'
                : '00.000.000/0000-00',
      )..text = cliente.cpfCnpj;
      _enderecoController.text = cliente.endereco;
      _contatoController = MaskedTextController(mask: '(00)00000-0000')
        ..text = cliente.contato;
      _tipoPessoa = cliente.tipoPessoa;
    } else {
      _limparCampos();
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
              child: StatefulBuilder(
                builder: (context, setLocalState) {
                  return SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          cliente == null ? 'Novo Cliente' : 'Editar Cliente',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: RadioListTile<TipoPessoa>(
                                title: const Text('Pessoa Física'),
                                value: TipoPessoa.fisica,
                                groupValue: _tipoPessoa,
                                onChanged: (value) {
                                  setLocalState(() {
                                    _atualizarMascaraCPF_CNPJ(
                                      TipoPessoa.fisica,
                                    );
                                  });
                                },
                              ),
                            ),
                            Expanded(
                              child: RadioListTile<TipoPessoa>(
                                title: const Text('Jurídica'),
                                value: TipoPessoa.juridica,
                                groupValue: _tipoPessoa,
                                onChanged: (value) {
                                  setLocalState(() {
                                    _atualizarMascaraCPF_CNPJ(
                                      TipoPessoa.juridica,
                                    );
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                        TextFormField(
                          controller: _nomeController,
                          decoration: const InputDecoration(labelText: 'Nome'),
                          validator:
                              (v) =>
                                  v!.trim().isEmpty ? 'Informe o nome' : null,
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _cpfCnpjController,
                          decoration: InputDecoration(
                            labelText:
                                _tipoPessoa == TipoPessoa.fisica
                                    ? 'CPF'
                                    : 'CNPJ',
                          ),
                          keyboardType: TextInputType.number,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return _tipoPessoa == TipoPessoa.fisica
                                  ? 'Informe o CPF'
                                  : 'Informe o CNPJ';
                            }
                            if (_tipoPessoa == TipoPessoa.fisica &&
                                v.length < 14) {
                              return 'CPF incompleto';
                            }
                            if (_tipoPessoa == TipoPessoa.juridica &&
                                v.length < 18) {
                              return 'CNPJ incompleto';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _enderecoController,
                          decoration: const InputDecoration(
                            labelText: 'Endereço',
                          ),
                          validator:
                              (v) =>
                                  v!.trim().isEmpty
                                      ? 'Informe o endereço'
                                      : null,
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _contatoController,
                          decoration: const InputDecoration(
                            labelText: 'Contato (telefone)',
                          ),
                          keyboardType: TextInputType.number,
                          validator:
                              (v) =>
                                  v!.trim().isEmpty
                                      ? 'Informe o contato'
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
                                final novoCliente = Cliente(
                                  id:
                                      cliente?.id ??
                                      DateTime.now().millisecondsSinceEpoch,
                                  nome: _nomeController.text.trim(),
                                  cpfCnpj: _cpfCnpjController.text.trim(),
                                  tipoPessoa: _tipoPessoa,
                                  endereco: _enderecoController.text.trim(),
                                  contato: _contatoController.text.trim(),
                                );
                                final provider = Provider.of<ClientesProvider>(
                                  context,
                                  listen: false,
                                );
                                if (cliente == null) {
                                  provider.adicionarCliente(novoCliente);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Cliente cadastrado!'),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                } else {
                                  provider.atualizarCliente(
                                    index!,
                                    novoCliente,
                                  );
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Cliente editado!'),
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
                  );
                },
              ),
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastro de Clientes'),
      ),
      body: Consumer<ClientesProvider>(
        builder: (context, provider, child) {
          return provider.clientes.isEmpty
              ? const Center(child: Text('Nenhum cliente cadastrado.'))
              : ListView.builder(
                itemCount: provider.clientes.length,
                itemBuilder: (context, index) {
                  final cliente = provider.clientes[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        child: Text(
                          cliente.nome.isNotEmpty ? cliente.nome[0] : '?',
                        ),
                        backgroundColor: Colors.brown[200],
                      ),
                      title: Text(
                        cliente.nome,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        '${cliente.tipoPessoa == TipoPessoa.fisica ? "CPF" : "CNPJ"}: ${cliente.cpfCnpj}\n${cliente.endereco}\n${cliente.contato}',
                      ),
                      isThreeLine: true,
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed:
                                () => _mostrarDialogoCadastro(cliente, index),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              Provider.of<ClientesProvider>(
                                context,
                                listen: false,
                              ).excluirCliente(index);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Cliente removido!'),
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
