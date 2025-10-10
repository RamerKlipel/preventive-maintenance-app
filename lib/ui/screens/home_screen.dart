import 'package:flutter/material.dart';
import '../widgets/bottom_sheet_option_Modal.dart';
import '../screens/equipment_list_screen.dart';

// A HomeScreen agora é apenas um StatefulWidget, sem o MaterialApp
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentPageIndex = 0;

  // 1. Crie a lista de telas que você quer exibir
  final List<Widget> _pages = [
    const EquipmentListScreen(),
    const Center(child: Text("Conteúdo do Histórico")),
    const Center(child: Text("Conteúdo do Dashboard")),
    const Center(child: Text("Conteúdo das Configurações")),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 250, 250, 250),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text("Checklist App", style: TextStyle(color: Colors.black)),
      ),

      // 2. Adicione o body para mostrar a página selecionada
      body: _pages[_currentPageIndex],

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            builder: (BuildContext context) {
              return const BottomSheetOptionModal();
            },
          );
        },
        backgroundColor: Colors.black,
        shape: const CircleBorder(), // Garante que o FAB seja um círculo perfeito
        child: const Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      
      bottomNavigationBar: NavigationBar(
        backgroundColor: Colors.white,
        onDestinationSelected: (int index) {
          // A lógica de logout/configurações para o último item
          if (index == 3) {
            // TODO: Chamar o dialog de logout/navegar para config
            print("Configurações/Sair clicado!");
          } else {
            setState(() {
              _currentPageIndex = index;
            });
          }
        },
        indicatorColor: Colors.black,
        selectedIndex: _currentPageIndex,
        destinations: const <Widget>[
          NavigationDestination(
            selectedIcon: Icon(Icons.home),
            icon: Icon(Icons.home_outlined),
            label: "Home",
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.history),
            icon: Icon(Icons.history_outlined),
            label: "Histórico",
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.bar_chart),
            icon: Icon(Icons.bar_chart_outlined),
            label: "Dashboard",
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.settings),
            icon: Icon(Icons.settings_outlined),
            label: "Configurações",
          ),
        ],
      ),
    );
  }
}