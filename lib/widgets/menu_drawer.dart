import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../screens/configuracoes_page.dart';
import '../screens/cadastro_produtos_page.dart';
import '../screens/cadastro_clientes_page.dart';

class MenuDrawer extends StatefulWidget {
  final VoidCallback onFinanceiro;

  const MenuDrawer({Key? key, required this.onFinanceiro}) : super(key: key);

  @override
  State<MenuDrawer> createState() => _MenuDrawerState();
}

class _MenuDrawerState extends State<MenuDrawer> {
  File? _profileImage;
  static const _prefsKey = 'profile_image_path';

  String _nomeUsuario = 'Bem-vinda, Neys!';

  @override
  void initState() {
    super.initState();
    _loadNome();
    _loadProfileImage();
  }

  Future<void> _loadNome() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _nomeUsuario = prefs.getString('user_nome') ?? 'Bem-vinda, Neys!';
    });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final XFile? picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      // Salva a imagem no diretório do app
      final dir = await getApplicationDocumentsDirectory();
      final String fileName =
          'profile_${DateTime.now().millisecondsSinceEpoch}.png';
      final File newImage = await File(
        picked.path,
      ).copy('${dir.path}/$fileName');

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsKey, newImage.path);

      setState(() => _profileImage = newImage);
    }
  }

  Future<void> _removeImage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefsKey);
    setState(() => _profileImage = null);
  }

  Future<void> _loadProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    final path = prefs.getString(_prefsKey);
    if (path != null && File(path).existsSync()) {
      setState(() => _profileImage = File(path));
    } else {
      setState(() => _profileImage = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: Color(0xFF7B3F00)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 38,
                  backgroundColor: Colors.white,
                  backgroundImage:
                      _profileImage != null
                          ? FileImage(_profileImage!)
                          : const AssetImage('assets/user_placeholder.png')
                              as ImageProvider,
                ),
                const SizedBox(height: 10),
                Text(
                  _nomeUsuario,
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                ),
              ],
            ),
          ),

          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Pedidos'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.attach_money),
            title: const Text('Módulo Financeiro'),
            onTap: () {
              Navigator.pop(context);
              widget.onFinanceiro();
            },
          ),
          ListTile(
            leading: const Icon(Icons.cookie_outlined),
            title: const Text('Produtos'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CadastroProdutosPage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Clientes'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CadastroClientesPage()),
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Configurações'),
            onTap: () async {
              Navigator.pop(context);
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ConfiguracoesPage()),
              );
              _loadNome();
              _loadProfileImage();
            },
          ),
        ],
      ),
    );
  }
}
