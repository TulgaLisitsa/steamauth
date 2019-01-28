import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:steam_auth/util/totp.dart';

import '../models/account.dart';
import 'countdown_indicator.dart';

typedef void ItemEditor(int x);
typedef void ItemDeleter(int x);
typedef void ItemSelector(int x);

class AccountList extends StatefulWidget {
  final int selected;
  final List<Account> accounts;
  final ItemSelector selector;

  const AccountList({Key key, this.accounts, this.selected, this.selector});

  @override
  _AccountListState createState() => _AccountListState();
}

class _AccountListState extends State<AccountList> {
  Timer timer;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(
        new Duration(milliseconds: DateTime.now().millisecondsSinceEpoch % 500),
        callback);
  }

  void callback(Timer timer) => setState(() {});

  @override
  Widget build(BuildContext context) {
    return ListTileTheme(
      dense: true,
      style: ListTileStyle.list,
      selectedColor: Theme.of(context).primaryColorDark,
      contentPadding: EdgeInsets.symmetric(horizontal: 21.0, vertical: 16.0),
      child: ListView.builder(
          shrinkWrap: false,
          itemCount: widget.accounts.length,
          itemBuilder: (context, index) {
            final item = widget.accounts[index];
            final selected = index == widget.selected;

            return Container(
              margin: EdgeInsets.only(top: 20.0),
              child: Material(
                color:
                    selected ? Theme.of(context).highlightColor : Colors.white,
                child: ListTile(
                  selected: selected,
                  title: Padding(
                    padding: EdgeInsets.only(bottom: 6.0),
                    child: Text(item.getAuthCode(0),
                        style: Theme.of(context).primaryTextTheme.display1),
                  ),
                  subtitle: Padding(
                      padding: EdgeInsets.only(top: 6.0),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                              child: Text(
                            item.id,
                            style: Theme.of(context).primaryTextTheme.caption,
                          )),
                          Expanded(
                              flex: 0,
                              child:
                                  CountdownIndicator(progress: totpProgress)),
                        ],
                      )),
                  onLongPress: () {
                    widget.selector(index);
                    Clipboard.setData(ClipboardData(text: item.getAuthCode(0)));
                    Scaffold.of(context).showSnackBar(SnackBar(
                        content: Text("${item.id}'s code has been copied!")));
                  },
                  onTap: () {
                    if (widget.selected >= 0) {
                      if (!selected) {
                        widget.selector(index);
                      } else {
                        widget.selector(-1);
                      }
                    }
                  },
                ),
              ),
            );
          }),
    );
  }
}
