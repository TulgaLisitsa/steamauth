import 'package:flutter/material.dart';

import '../models/account.dart';

class SettingsScreen extends StatefulWidget {
  final String title;

  SettingsScreen({Key key, this.title}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _encrypt = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: ListView(
        children: <Widget>[
          ListTile(
            title: const Text('Export accounts'),
            subtitle: const Text('Export all stored accounts'),
            onTap: () {
              AccountProvider().getRawAccounts().then((list) {
                print(list.toString());
              });
            },
          ),
          ListTile(
            title: const Text('Import accounts'),
            subtitle: const Text('Import a collection of accounts'),
            onTap: () {
              AccountProvider().getRawAccounts().then((list) {
                print(list.toString());
              });
            },
          ),
        ],
      ),
    );
  }
}
