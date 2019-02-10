import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

import '../models/account.dart';

class SettingsScreen extends StatefulWidget {
  final String title;

  SettingsScreen({Key key, this.title}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  FocusNode focusNode;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    focusNode = FocusNode();

    return Scaffold(
      key: _scaffoldKey,
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
                _exportDialog(context, json.encode(list));
              });
            },
          ),
          ListTile(
            title: const Text('Import accounts'),
            subtitle: const Text('Import a collection of accounts'),
            onTap: () {
              _importDialog(context);

            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    // Clean up the focus node when the Form is disposed
    focusNode.dispose();

    super.dispose();
  }

  Future _exportDialog(BuildContext context, String list) async {
    return showDialog<Null>(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Export accounts'),
            content: Text(list),
            actions: <Widget>[
              FlatButton(
                child: Text('COPY'),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: list));
                  _scaffoldKey.currentState.showSnackBar(SnackBar(
                      content: Text("Your codes have been exported!")));
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        });
  }

  Future _importDialog(BuildContext context) async {
    TextEditingController controller = TextEditingController();

    return showDialog<Null>(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Import accounts'),
            content: TextField(
              autocorrect: false,
              autofocus: true,
              keyboardType: TextInputType.multiline,
              maxLines: null,
              controller: controller,
            ),
            actions: <Widget>[
              FlatButton(
                child: Text('IMPORT'),
                onPressed: () {
                  _scaffoldKey.currentState.showSnackBar(SnackBar(
                      content: Text("Your codes have been imported!")));
                  AccountProvider().import(controller.text);
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        });
  }
}
