 import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override  
  // ignore: library_private_types_in_public_api
  _SettingsScreenState createState() => _SettingsScreenState();
}

 class _SettingsScreenState extends State<SettingsScreen> {
  Color selectedColor = Colors.red;

  void changeColor(Color newColor) {
    setState(() {
      selectedColor = newColor;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Botão para mudar para o tema Red
            ElevatedButton(
              onPressed: () => changeColor(Colors.red),
              child: const Text('Red Theme'),
            ),
            const SizedBox(height: 10),
            // Botão para mudar para o tema Green
            ElevatedButton(
              onPressed: () => changeColor(Colors.green),
              child: const Text('Theme'),
            ),
            const SizedBox(height: 10),
            // Botão para mudar para o tema Blue
            ElevatedButton(
              onPressed: () => changeColor(Colors.blue),
              child: const Text('Notes'),
            ),
          ],
        ),
      ),
      backgroundColor: selectedColor, // Cor de fundo muda conforme a seleção
    );
  }
}

void main() {
  runApp(const MaterialApp(
    home: SettingsScreen(),
  ));
}
