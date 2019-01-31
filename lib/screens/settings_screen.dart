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

  @override
  Widget build(BuildContext context) {
    focusNode = FocusNode();

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
                _exportDialog(context, list.toString());
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

  @override
  void dispose() {
    // Clean up the focus node when the Form is disposed
    focusNode.dispose();

    super.dispose();
  }

  Future _exportDialog(BuildContext context, String list) async {
    TextEditingController controller = TextEditingController(text: list);

    return showDialog<Null>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Export accounts'),
          content: EditableText(
            cursorColor: Theme.of(context).cursorColor,
            focusNode: focusNode,
            style: Theme.of(context).textTheme.body1,
            autocorrect: false,
            autofocus: true,
            keyboardType: TextInputType.multiline,
            maxLines: null,
            controller: controller,
          ),
        );
      }
    );
  }
}
