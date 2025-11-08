import 'package:flutter/material.dart';

class MainNavigationBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onDestinationSelected;

  const MainNavigationBar({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {

    return NavigationBar(
      selectedIndex: selectedIndex,
      onDestinationSelected: onDestinationSelected,
      indicatorColor: Theme.of(context).colorScheme.primaryContainer,
      destinations: <Widget>[
        NavigationDestination(
          selectedIcon: Icon(Icons.anchor_rounded),
          icon: Icon(Icons.anchor_sharp),
          label: "Anchor",
        ),
        NavigationDestination(
          selectedIcon: Icon(Icons.timeline_rounded),
          icon: Icon(Icons.timeline_sharp),
          label: "History",
        ),
        NavigationDestination(
          selectedIcon: Icon(Icons.settings),
          icon: Icon(Icons.settings_outlined),
          label: "Settings",
        ),
      ],
    );
  }
}