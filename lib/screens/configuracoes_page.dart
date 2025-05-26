import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';

class ConfiguracoesPage extends StatefulWidget {
  const ConfiguracoesPage({Key? key}) : super(key: key);

  @override
  State<ConfiguracoesPage> createState() => _ConfiguracoesPageState();
}

class _ConfiguracoesPageState extends State<ConfiguracoesPage> {
  File? _profileImage;
  String _nome = '';
  static const _prefsKeyImage = 'profile_image_path';
  static const _prefsKeyNome = 'user_nome';

  final _nomeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserConfig();
  }

  Future<void> _loadUserConfig() async {
    final prefs = await SharedPreferences.getInstance();
    final path = prefs.getString(_prefsKeyImage);
    final nome = prefs.getString(_prefsKeyNome) ?? 'Bem-vinda, Neys!';
    if (path != null && File(path).existsSync()) {
      setState(() => _profileImage = File(path));
    }
    setState(() {
      _nome = nome;
      _nomeController.text = nome;
    });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final XFile? picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final dir = await getApplicationDocumentsDirectory();
      final String fileName =
          'profile_${DateTime.now().millisecondsSinceEpoch}.png';
      final File newImage = await File(
        picked.path,
      ).copy('${dir.path}/$fileName');
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsKeyImage, newImage.path);
      setState(() => _profileImage = newImage);
    }
  }

  Future<void> _removeImage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefsKeyImage);
    setState(() => _profileImage = null);
  }

  Future<void> _saveNome() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKeyNome, _nomeController.text.trim());
    setState(() {
      _nome = _nomeController.text.trim();
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Nome atualizado!')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configurações')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.white,
                  backgroundImage:
                      _profileImage != null
                          ? FileImage(_profileImage!)
                          : const AssetImage('assets/user_placeholder.png')
                              as ImageProvider,
                ),
                Positioned(
                  bottom: 0,
                  right: 4,
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.brown[300],
                      ),
                      padding: const EdgeInsets.all(4),
                      child: const Icon(
                        Icons.edit,
                        size: 22,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                if (_profileImage != null)
                  Positioned(
                    top: 0,
                    right: 4,
                    child: GestureDetector(
                      onTap: _removeImage,
                      child: Container(
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.redAccent,
                        ),
                        padding: const EdgeInsets.all(3),
                        child: const Icon(
                          Icons.delete,
                          size: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _nomeController,
              decoration: InputDecoration(
                labelText: 'Nome do usuário',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.save),
                  onPressed: _saveNome,
                ),
              ),
              onSubmitted: (_) => _saveNome(),
            ),
            const SizedBox(height: 30),
            // Aqui você pode adicionar mais opções futuramente!
            // Exemplo: configurações de tema, preferências, etc.
          ],
        ),
      ),
    );
  }
}
