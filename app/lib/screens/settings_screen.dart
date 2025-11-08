import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:w_anchor/providers/settings_provider.dart';
import 'package:w_anchor/utils/constants.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    if (settings.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        const Text(
          'Theme',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SegmentedButton<AppTheme>(
          segments: const [
            ButtonSegment(
                value: AppTheme.system,
                label: Text('System'),
                icon: Icon(Icons.brightness_auto)),
            ButtonSegment(
                value: AppTheme.light,
                label: Text('Light'),
                icon: Icon(Icons.brightness_5)),
            ButtonSegment(
                value: AppTheme.dark,
                label: Text('Dark'),
                icon: Icon(Icons.brightness_2)),
          ],
          selected: {settings.theme},
          onSelectionChanged: (newSelection) {
            context.read<SettingsProvider>().setTheme(newSelection.first);
          },
        ),

        const Divider(height: 40),
        const Text(
          'Alarm Radius',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(
          '${settings.alarmRadius.toStringAsFixed(0)} meters',
          style: const TextStyle(fontSize: 16, color: Colors.grey),
        ),
        Slider(
          year2023: false,
          value: settings.alarmRadius,
          min: 10,
          max: 100,
          divisions: 9,
          label: settings.alarmRadius.toStringAsFixed(0),
          onChanged: (newValue) {
            context.read<SettingsProvider>().setAlarmRadius(newValue);
          },
        ),
      ],
    );
  }
}