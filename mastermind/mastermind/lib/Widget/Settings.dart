import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:settings_ui/settings_ui.dart';
class Settings extends StatelessWidget {
  const Settings({super.key});

  @override
  Widget build(BuildContext context) {
    return    SettingsList(
        sections: [
          SettingsSection(
            title: Text('General'),
            tiles: [
              SettingsTile.navigation(
                title: Text('Abstract settings screen'),
                leading: Icon(CupertinoIcons.wrench),
                description: Text('UI created to show plugin\'s possibilities'),
                onPressed: (context) {
                  Navigation.navigateTo(
                    context: context,
                    screen: CrossPlatformSettingsScreen(),
                    style: NavigationRouteStyle.material,
                  );
                },
              )
            ],
          ),
          SettingsSection(
            title: Text('Replications'),
            tiles: [
              SettingsTile.navigation(
                leading: Icon(CupertinoIcons.settings),
                title: Text('iOS Developer Screen'),
                onPressed: (context) {
                  Navigation.navigateTo(
                    context: context,
                    screen: IosDeveloperScreen(),
                    style: NavigationRouteStyle.cupertino,
                  );
                },
              ),
              SettingsTile.navigation(
                leading: Icon(Icons.settings),
                title: Text('Android Settings Screen'),
                onPressed: (context) {
                  Navigation.navigateTo(
                    context: context,
                    screen: AndroidSettingsScreen(),
                    style: NavigationRouteStyle.material,
                  );
                },
              ),
              SettingsTile.navigation(
                leading: Icon(Icons.web),
                title: Text('Web Settings'),
                onPressed: (context) {
                  Navigation.navigateTo(
                    context: context,
                    screen: WebChromeSettings(),
                    style: NavigationRouteStyle.material,
                  );
                },
              ),
            ],
          ),
        ],
      
  }
}