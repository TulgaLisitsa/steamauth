import 'dart:convert';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class Account {
  String id;
  String secret;
  String identity;

  Account.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    secret = map['secret'];
  }

  Map<String, String> toMap() => {'id': id, 'secret': secret};

  @override
  String toString() => id;
}

class AccountProvider {
  static Database _db;

  Future<Database> get db async {
    if (_db != null) return _db;

    String path =
        join((await getApplicationDocumentsDirectory()).path, 'account.db');

    _db = await openDatabase(path, version: 1, onCreate: (Database db, int v) {
      db.execute('''
          CREATE TABLE IF NOT EXISTS Account(id TEXT PRIMARY KEY, secret TEXT NOT NULL)
        ''');
    });

    return _db;
  }

  Future<List<Account>> getAccounts() async {
    List<Account> accounts = List();

    List<Map<String, dynamic>> list = await getRawAccounts();

    for (Map<String, dynamic> map in list) {
      accounts.add(Account.fromMap(map));
    }

    return accounts;
  }

  Future<List<Map<String, dynamic>>> getRawAccounts() async {
    Database client = await db;

    return client.rawQuery('SELECT * FROM Account');
  }

  Future<int> addAccount(Map<String, String> account) async {
    Database client = await db;
    await client.transaction((tx) async {
      return await tx.rawInsert(
          "REPLACE INTO Account (id, secret) VALUES ('${account['id']}', '${account['secret']}')");
    });

    return -1;
  }

  Future<int> deleteAccount(String id) async {
    Database client = await db;
    return await client.rawDelete('DELETE FROM Account WHERE id = ?', [id]);
  }

  Future<int> import(String text) async {
    Database client = await db;
    List accounts = json.decode(text);
    String transaction = "REPLACE INTO Account (id, secret) VALUES ";

    for(Map<String, dynamic> account in accounts) {
      await client.transaction((tx) async {
        tx.rawInsert(
            transaction + "('${account['id']}', '${account['secret']}')");
      });
    }

    return -1;
  }

  Future dispose() async => (await db).close();
}
