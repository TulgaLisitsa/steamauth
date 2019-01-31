import 'package:flutter/material.dart';
import 'package:steam_auth/src/login.dart';

import '../models/account.dart';
import '../widgets/account_list.dart';

enum Choices { settings, help }

class HomeScreen extends StatefulWidget {
  final String title;

  HomeScreen({Key key, this.title}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selected = -1;
  List<Account> _accounts = List();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    _getAccounts();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text(widget.title),
          actions: _getToolbarActions(context),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            _showBottomSheet(context);
          },
          tooltip: 'Add Account',
          child: Icon(Icons.add),
        ),
        body: Stack(children: <Widget>[
          AccountList(
            accounts: _accounts,
            selected: _selected,
            selector: select,
          )
        ]));
  }

  @override
  void dispose() {
    AccountProvider().dispose();
    super.dispose();
  }

  _getAccounts() {
    AccountProvider().getAccounts().then((accounts) {
      _accounts = accounts;

      setState(() {
        _accounts.sort((a, b) => a.id.compareTo(b.id));
      });
    });
  }

  _addAccount(Account account) {
    AccountProvider().addAccount(account.toMap()).then((_) {
      _getAccounts();
    });
  }

  _delAccount(int index) {
    AccountProvider().deleteAccount(_accounts[index].id).then((_) {
      _getAccounts();
    });
  }

  _newAccount(BuildContext context) async {
    final result = (await Navigator.pushNamed(context, '/new')) as Account;

    if (result != null) {
      _addAccount(result);
    }

    select(-1);
  }

  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return ListView(
            shrinkWrap: true,
            children: <Widget>[
              ListTile(
                enabled: true,
                leading: Icon(Icons.person_add),
                title: Text('Add a new account'),
                onTap: () {
                  Navigator.pop(context);
                  Login().login('username', 'password');
                },
              ),
              ListTile(
                leading: Icon(Icons.keyboard),
                title: Text('Enter account details'),
                onTap: () {
                  Navigator.pop(context);
                  _newAccount(context);
                },
              ),
            ],
          );
        });
  }

  List<Widget> _getToolbarActions(BuildContext context) {
    return (_selected != -1)
        ? <Widget>[
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: () {
                _promptEdit(context);
              },
            ),
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                _promptDel(context);
              },
            ),
            _popupMenuButton()
          ]
        : <Widget>[_popupMenuButton()];
  }

  PopupMenuButton _popupMenuButton() => PopupMenuButton(
        onSelected: (val) {
          switch (val) {
            case Choices.settings:
              Navigator.pushNamed(context, '/settings');
              break;
            case Choices.help:
              break;
          }
        },
        itemBuilder: (BuildContext context) => <PopupMenuItem<Choices>>[
              PopupMenuItem(
                  value: Choices.settings,
                  child: ListTile(
                    title: Text('Settings'),
                  )),
              PopupMenuItem(
                  value: Choices.help,
                  child: ListTile(
                    title: Text('Help'),
                  )),
            ],
      );

  Future _promptEdit(BuildContext context) async {
    int index = _selected;
    Account account = _accounts[index];
    TextEditingController controller = TextEditingController(text: account.id);
    select(-1);

    return showDialog<Null>(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AlertDialog(
              title: Text('Rename'),
              content: TextField(
                autocorrect: false,
                decoration: InputDecoration(isDense: true),
                controller: controller,
                onSubmitted: (str) => controller.text = str,
              ),
              actions: <Widget>[
                new FlatButton(
                  child: Text('CANCEL'),
                  textColor: Theme.of(context).primaryColor,
                  onPressed: () => Navigator.of(context).pop(),
                ),
                new FlatButton(
                  child: Text('SAVE'),
                  textColor: Theme.of(context).primaryColor,
                  onPressed: () {
                    if (controller.text.isNotEmpty &&
                        controller.text.length > 2) {
                      _delAccount(index);
                      _addAccount(Account.fromMap({
                        'id': controller.text,
                        'secrent': account.secret,
                      }));
                      Navigator.of(context).pop();
                    }
                  },
                ),
              ]);
        });
  }

  Future _promptDel(BuildContext context) async {
    int index = _selected;
    Account account = _accounts[index];
    select(-1);

    return showDialog<Null>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Remove ${account.id}?'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                    'Removing this account will not remove your ability to generate codes, however it will not turn off 2-factor authentication. This may prevent you from signing into your account.')
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('CANCEL'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text('REMOVE ACCOUNT'),
              onPressed: () {
                final snackBar = SnackBar(
                  content: Text('${account.id} has been removed'),
                  action: new SnackBarAction(
                    label: 'Undo',
                    onPressed: () {
                      _addAccount(account);
                    },
                  ),
                );

                _delAccount(index);
                _scaffoldKey.currentState.showSnackBar(snackBar);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void select(int i) {
    setState(() {
      _selected = i;
    });
  }
}
