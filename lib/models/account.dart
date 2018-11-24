import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

final String _chars = '23456789BCDFGHJKMNPQRTVWXY';

class Account {
  String id;
  String secret;

  Account.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    secret = map['secret'];
  }

  Map<String, String> toMap() => {'id': id, 'secret': secret};

  @override
  String toString() => id;

  String getAuthCode(int offset) {
    String result = '';

    // Convert the shared secret from a Base64 String to an int8[]
    final Int8List key = Base64Codec().decode(secret).buffer.asInt8List();

    // Initialize the SHA1 mac with the decoded secret
    final Hmac mac = new Hmac(sha1, key);

    // Create an empty byte buffer
    ByteData byteData = ByteData.view(new Int8List(8).buffer);

    // Put the current time in the empty byte buffer as a big endian int
    byteData.setInt32(4, _time(offset) ~/ 30, Endian.big);

    Int8List digest =
        Int8List.fromList(mac.convert(byteData.buffer.asInt8List()).bytes);

    int start = digest[19] & 0x0F;
    Int8List bytes = digest.sublist(start, start + 4);

    int complete = ByteData.view(bytes.buffer).getUint32(0, Endian.big) &
        0x7fffffff &
        -0x1;

    for (int i = 0; i < 5; i++) {
      result += (_chars[complete % _chars.length]);
      complete ~/= _chars.length;
    }

    return result;
  }
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
    Database client = await db;
    List<Account> accounts = List();

    (await client.rawQuery('SELECT * FROM Account')).forEach((map) {
      accounts.add(Account.fromMap(map));
    });

    return accounts;
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

  Future dispose() async => (await db).close();
}

double _time(offset) => (DateTime.now().millisecondsSinceEpoch / 1000) + offset;
