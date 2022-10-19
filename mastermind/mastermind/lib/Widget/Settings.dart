import 'dart:io';
import 'package:settings_ui/settings_ui.dart';
import 'package:flutter/material.dart';

class Settings extends StatefulWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  TextStyle headingStyle = const TextStyle(
      fontSize: 16, fontWeight: FontWeight.w600, color: Colors.red);
  bool allowDuplicates = true;
  bool notificationsEnabled = true;
  int nRows = 5;
  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).viewPadding.top;
    return Scaffold(
        backgroundColor: Colors.blueGrey,
        body: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(0.0, height, 0.0, 0.0),
              child: const Align(
                  alignment: Alignment.centerLeft, child: BackButton()),
            ),
            Expanded(
                child: SettingsList(
              lightTheme: const SettingsThemeData(
                settingsListBackground: Color.fromARGB(255, 184, 196, 201),
              ),
              sections: [
                SettingsSection(
                  title: const Text('Common'),
                  tiles: [
                    SettingsTile.switchTile(
                      title: const Text('Allow duplicates'),
                      description: const Text(
                          'Allow the presence of duplicated colors in the combination'),
                      leading: const Icon(Icons.hail),
                      onToggle: (bool value) {
                        setState(() {
                          allowDuplicates = value;
                        });
                      },
                      initialValue: allowDuplicates,
                    ),
                    SettingsTile(
                      title: const Text('Rows'),
                      value: Slider(
                        min: 1,
                        max: 15,
                        onChanged: (double value) {
                          setState(() {
                            nRows = value.toInt();
                            print(nRows);
                          });
                        },
                        value: nRows.toDouble(),
                      ),
                      leading: const Icon(Icons.list),
                      trailing: Text(nRows.toString()),
                    ),
                  ],
                ),
              ],
            ))
          ],
        ));
  }
}
