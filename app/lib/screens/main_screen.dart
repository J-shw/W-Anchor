import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:w_anchor/providers/anchor_provider.dart';
import 'package:w_anchor/screens/anchor_screen.dart';
import 'package:w_anchor/screens/history_screen.dart';
import 'package:w_anchor/screens/settings_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _pages = <Widget>[
    AnchorScreen(),
    HistoryScreen(),
    SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();

    if (_selectedIndex == 0) {
      Provider.of<AnchorProvider>(context, listen: false).startGpsStream();
    }
  }

  void _onItemTapped(int index) {
    final provider = Provider.of<AnchorProvider>(context, listen: false);

    if (index == 0) {
      provider.startGpsStream();
    } else {
      provider.stopGpsStream();
    }

    if (index == 1) {
      provider.loadHistory();
    }

    setState(() {
      _selectedIndex = index;
    });
  }

  Widget? _buildFab(BuildContext context) {
    if (_selectedIndex != 0) return null;

    final provider = context.watch<AnchorProvider>();

    if (provider.isLoading) return null;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return ScaleTransition(scale: animation, child: child);
      },
      child: provider.activeSession == null
          ? FloatingActionButton.extended(
              key: const ValueKey('set_anchor'),
              onPressed: () => provider.startAnchoring(),
              label: const Text('Set Anchor'),
              icon: const Icon(Icons.anchor),
            )
          : FloatingActionButton.extended(
              key: const ValueKey('stop_anchor'),
              onPressed: () => provider.stopAnchoring(),
              label: const Text('Stop Anchoring'),
              icon: const Icon(Icons.not_interested),
              backgroundColor: Colors.red,
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<PreferredSizeWidget?> appBars = [
      null, 
      AppBar(title: const Text('Anchoring History')),
      AppBar(title: const Text('Settings')),
    ];

    return Scaffold(
      appBar: appBars[_selectedIndex],
      body: _pages[_selectedIndex],
      floatingActionButton: _buildFab(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.anchor),
            label: 'Anchor',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}