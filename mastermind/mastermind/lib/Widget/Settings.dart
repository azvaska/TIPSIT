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
                    SettingsSection(
                      title: const Text('Help'),
                      tiles: [
                        SettingsTile(
                          title: const Text('How to play'),
                          value: const Text("""
The game is played using:

    a decoding board, with a shield at one end covering a row of four large holes, and twelve (or ten, or eight, or six) additional rows containing four large holes next to a set of four small holes;
    code pegs of six different colors (or more; see Variations below), with round heads, which will be placed in the large holes on the board; and
    key pegs, some colored black, some white, which are flat-headed and smaller than the code pegs; they will be placed in the small holes on the board.

The two players decide in advance how many games they will play, which must be an even number. One player becomes the codemaker, the other the codebreaker.[3]: 120  The codemaker chooses a pattern of four code pegs. Players decide in advance whether duplicates and blanks are allowed. If so, the codemaker may even choose four same-colored code pegs or four blanks. If blanks are not allowed in the code, the codebreaker may not use blanks in their guesses. The codemaker places the chosen pattern in the four holes covered by the shield, visible to the codemaker but not to the codebreaker.[4]

The codebreaker tries to guess the pattern, in both order and color, within eight to twelve turns. Each guess is made by placing a row of code pegs on the decoding board.[3]: 120  Once placed, the codemaker provides feedback by placing from zero to four key pegs in the small holes of the row with the guess. A colored or black key peg is placed for each code peg from the guess which is correct in both color and position. A white key peg indicates the existence of a correct color code peg placed in the wrong position.[5]
Screenshot of software implementation (ColorCode) illustrating the example.

If there are duplicate colors in the guess, they cannot all be awarded a key peg unless they correspond to the same number of duplicate colors in the hidden code. For example, if the hidden code is red-red-blue-blue and the player guesses red-red-red-blue, the codemaker will award two colored key pegs for the two correct reds, nothing for the third red as there is not a third red in the code, and a colored key peg for the blue. No indication is given of the fact that the code also includes a second blue.[6]

Once feedback is provided, another guess is made; guesses and feedback continue to alternate until either the codebreaker guesses correctly, or all rows on the decoding board are full.

Traditionally, players can only earn points when playing as the codemaker. The codemaker gets one point for each guess the codebreaker makes. An extra point is earned by the codemaker if the codebreaker is unable to guess the exact pattern within the given number of turns. (An alternative is to score based on the number of key pegs placed.) The winner is the one who has the most points after the agreed-upon number of games are played. 

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
