import 'dart:io';
import 'package:settings_ui/settings_ui.dart';
import 'package:flutter/material.dart';

class SettingsData {
  bool allowDuplicates = true;
  int nRows;
  SettingsData([this.nRows = 6, this.allowDuplicates = true]);
}

class Settings extends StatefulWidget {
  bool duplicates;
  int nMaxRows;
  Settings(this.duplicates, this.nMaxRows, {Key? key}) : super(key: key);

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  SettingsData settings = SettingsData();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    settings.allowDuplicates = widget.duplicates;
    settings.nRows = widget.nMaxRows;
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).viewPadding.top;
    return Scaffold(
        backgroundColor: Colors.blueGrey,
        body: WillPopScope(
            onWillPop: () async {
              Navigator.pop(context, settings);
              return false;
            },
            child: Column(
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
                              settings.allowDuplicates = value;
                            });
                          },
                          initialValue: settings.allowDuplicates,
                        ),
                        SettingsTile(
                          title: const Text('Rows'),
                          value: Slider(
                            min: 1,
                            max: 15,
                            onChanged: (double value) {
                              setState(() {
                                settings.nRows = value.toInt();
                              });
                            },
                            value: settings.nRows.toDouble(),
                          ),
                          leading: const Icon(Icons.list),
                          trailing: Text(settings.nRows.toString()),
                        ),
                      ],
                    ),
                  ],
                ))
              ],
            )));
  }
}
