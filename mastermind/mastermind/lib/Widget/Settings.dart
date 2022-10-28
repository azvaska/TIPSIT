// ignore: file_names
import 'package:settings_ui/settings_ui.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'utils.dart';

class SettingsData {
  bool allowDuplicates = true;
  int nRows;
  int bestTime;
  SettingsData(
      {this.nRows = 6,
      this.allowDuplicates = true,
      this.bestTime = Utils.maxInt});
}

class Settings extends StatefulWidget {
  final SettingsData settings;
  const Settings(this.settings, {super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  late SharedPreferences prefs;
  String currentTimeText = "Not yet set";
  @override
  void initState() {
    super.initState();
    getBestTime();
  }

  getBestTime() async {
    prefs = await SharedPreferences.getInstance();
    widget.settings.bestTime = prefs.getInt(Utils.bestTimeKey) ?? -1;
    if (widget.settings.bestTime == -1) {
      setState(() {
        currentTimeText = "Not yet set";
      });
      return;
    }
    setState(() {
      currentTimeText = Utils.formatTime(widget.settings.bestTime);
    });
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).viewPadding.top;
    return Scaffold(
        backgroundColor: const Color.fromARGB(255, 88, 91, 93),
        body: WillPopScope(
            onWillPop: () async {
              Navigator.pop(context, widget.settings);
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
                    settingsListBackground: Color.fromARGB(255, 209, 212, 214),
                  ),
                  sections: [
                    SettingsSection(
                      title: const Text(textScaleFactor: 1.4, 'Common'),
                      tiles: [
                        SettingsTile.switchTile(
                          title: const Text('Allow duplicates'),
                          description: const Text(
                              textScaleFactor: 1.3,
                              'Allow the presence of duplicated colors in the combination'),
                          leading: const Icon(Icons.filter_none),
                          onToggle: (bool value) {
                            setState(() {
                              widget.settings.allowDuplicates = value;
                            });
                          },
                          initialValue: widget.settings.allowDuplicates,
                        ),
                        SettingsTile(
                          title: const Text(textScaleFactor: 1.1, 'Rows'),
                          value: Slider(
                            min: 1,
                            max: 15,
                            onChanged: (double value) {
                              setState(() {
                                widget.settings.nRows = value.toInt();
                              });
                            },
                            value: widget.settings.nRows.toDouble(),
                          ),
                          leading: const Icon(Icons.list),
                          trailing: Text(
                              textScaleFactor: 1.3,
                              widget.settings.nRows.toString()),
                        ),
                        SettingsTile(
                          title: const Text('Best Time'),
                          value: Text(textScaleFactor: 1.3, currentTimeText),
                          leading: const Icon(Icons.timer),
                          trailing: TextButton(
                              onPressed: () => {
                                    Future.delayed(Duration.zero, () async {
                                      await prefs.remove(Utils.bestTimeKey);
                                      setState(() {
                                        widget.settings.bestTime = Utils.maxInt;
                                        currentTimeText = "Not yet set";
                                      });
                                    })
                                  },
                              child: const Text("Reset")),
                        ),
                      ],
                    ),
                    SettingsSection(
                      title: const Text(textScaleFactor: 1.4, 'Help'),
                      tiles: [
                        SettingsTile(
                          title: const Text('How to play'),
                          value: const Text(textScaleFactor: 1.3, """
The game consists in guessing the pattern, in both order and color, within a selectable number of guesses (changeable with the settings option).
Each guess is made by selecting 4 colors (clicking the color at the top and tapping on the empty circle that is colored gray) and then clicking the checkmark to confirm the guess.
Then it will show on the right of the sequence of colors a feedback with four Colored circles.
 
A black circle indicates that there is not that color for every circle in the guessed code that is correct in both color and location.
A white circle indicates the existence of a correct color circle placed in the wrong position.
A green circle indicates the existence of a correct color in the proper position.
 
If there are duplicated colors in the guess, a Circle will be awarded for the same number of duplicate colors in the hidden code if the guess contained.
 
For example, if the hidden code is red-red-blue-blue and the player guesses red-red-red-blue, they will be awarded two Green pegs for the two correct reds, nothing for the third red as there is not a third red in the code, and a white circle for the blue.
No indication is given that the code also includes a second blue.
The game is over if the number of tries is 0 or if the player guesses the right combination
"""),
                          leading: const Icon(Icons.help),
                        ),
                      ],
                    ),
                  ],
                ))
              ],
            )));
  }
}
