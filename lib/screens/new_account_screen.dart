import 'dart:convert';

import 'package:flutter/material.dart';

import '../models/account.dart';

class NewAccountScreen extends StatefulWidget {
  final String title;

  NewAccountScreen({Key key, this.title}) : super(key: key);

  @override
  _NewAccountScreenState createState() => _NewAccountScreenState();
}

class _NewAccountScreenState extends State<NewAccountScreen> {
  String _name;
  String _secret;
  bool _obscureText = true;

  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 24.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                new TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Account name',
                  ),
                  validator: (value) {
                    if (value.isNotEmpty && value.length > 2) {
                      _name = value.toLowerCase();
                    } else {
                      return 'Please enter the name of this account';
                    }
                  },
                  autocorrect: false,
                ),
                const Padding(padding: const EdgeInsets.only(top: 20.0)),
                new TextFormField(
                  decoration: new InputDecoration(
                    contentPadding: new EdgeInsets.symmetric(vertical: 10.0),
                    labelText: 'Shared secret',
                    suffixIcon: GestureDetector(
                      onTap: () {
                        setState(() {
                          _obscureText = !_obscureText;
                        });
                      },
                      child: Icon(_obscureText
                          ? Icons.visibility
                          : Icons.visibility_off),
                    ),
                  ),
                  obscureText: _obscureText,
                  validator: (value) {
                    if (_secretValidator(value)) {
                      _secret = value;
                    } else {
                      return 'Please enter the shared secret';
                    }
                  },
                  autocorrect: false,
                ),
                new Container(
                  padding: new EdgeInsets.only(top: 42.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      new RaisedButton(
                          child: new Text('ADD'),
                          color: Theme.of(context).primaryColor,
                          textColor: Colors.white,
                          onPressed: () {
                            if (_formKey.currentState.validate()) {
                              Navigator.pop(
                                  context,
                                  Account.fromMap(
                                      {'id': _name, 'secret': _secret}));
                            }
                          })
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool _secretValidator(String value) {
    bool res = value.isNotEmpty && value.length % 4 == 0;

    try {
      Base64Codec().decode(value).buffer;
    } on FormatException {
      res = res && false;
    }

    return res;
  }
}
