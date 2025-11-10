import 'package:flutter/material.dart';
import '../widgets/bottom_sheet_option_Modal.dart';
import '../screens/equipment_list_screen.dart';
import '../../core/services/auth_service.dart';
import './historic_screen.dart';
import './dasboard_screen2.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentPageIndex = 0;

  final List<Widget> _pages = [
    const EquipmentListScreen(),
    const HistoricScreen(),
    const DashboardScreen(),
  ];
  final _auth = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 250, 250, 250),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text("Checklist App", style: TextStyle(color: Colors.black)),
      ),

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
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      
      bottomNavigationBar: NavigationBar(
        backgroundColor: Colors.white,
        onDestinationSelected: (int index) {
          if (index == 3) {
            _auth.logout();
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
            icon: Icon(Icons.logout_outlined),
            label: "Sair",
          ),
        ],
      ),
    );
  }
}