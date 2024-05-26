import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:share_plus/share_plus.dart';
import 'services/frases.dart';

void main() {
  runApp(GeradorDeFrasesApp());
}

class GeradorDeFrasesApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Inspirações Diárias',
      theme: ThemeData(
        primaryColor: Colors.deepPurple,
        colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.deepPurple)
            .copyWith(secondary: Colors.orange),
      ),
      darkTheme: ThemeData(
        primaryColor: Colors.deepPurple,
        colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.deepPurple)
            .copyWith(secondary: Colors.orange),
      ),
      themeMode: ThemeMode.system,
      home: FrasePage(),
    );
  }
}

class FrasePage extends StatefulWidget {
  @override
  _FrasePageState createState() => _FrasePageState();
}

class _FrasePageState extends State<FrasePage> {
  List<String> _frases = frasesMotivacionais; // Use a lista de frases importada
  final List<String> _favoritas = [];
  String _fraseAtual = "Clique para gerar uma frase motivacional!";
  bool _isLoading = false;
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _loadFavoritas();
    _loadSettings();
  }

  void _loadFavoritas() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _favoritas.addAll((prefs.getStringList('favoritas') ?? []));
    });
  }

  void _salvarFavoritas() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList('favoritas', _favoritas);
  }

  void _loadSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    });
  }

  void _saveSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isDarkMode', _isDarkMode);
  }

  void _gerarFrase() {
    setState(() {
      _fraseAtual = (_frases..shuffle()).first;
    });
  }

  void _toggleFavorita() {
    setState(() {
      if (_favoritas.contains(_fraseAtual)) {
        _favoritas.remove(_fraseAtual);
      } else {
        _favoritas.add(_fraseAtual);
      }
      _salvarFavoritas();
    });
  }

  void _exibirFavoritas() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => FavoritasPage(_favoritas)),
    );
  }

  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
      _saveSettings();
    });
  }

  void _compartilharFrase() {
    Share.share(_fraseAtual);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Inspirações Diárias'),
        actions: [
          IconButton(
            icon: Icon(Icons.favorite),
            onPressed: _exibirFavoritas,
          ),
          IconButton(
            icon: Icon(Icons.brightness_6),
            onPressed: _toggleTheme,
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _fraseAtual,
                style: TextStyle(fontSize: 24, fontStyle: FontStyle.italic),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _gerarFrase,
                child: Text('Gerar Nova Frase'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _toggleFavorita,
                child: Text(
                  _favoritas.contains(_fraseAtual)
                      ? 'Remover dos Favoritos'
                      : 'Adicionar aos Favoritos',
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _compartilharFrase,
                child: Text('Compartilhar Frase'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FavoritasPage extends StatelessWidget {
  final List<String> favoritas;

  FavoritasPage(this.favoritas);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Frases Favoritas'),
      ),
      body: ListView.builder(
        itemCount: favoritas.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(favoritas[index]),
          );
        },
      ),
    );
  }
}
