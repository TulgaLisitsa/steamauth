double totpProgress() {
  return 1 - _getExpiration() / 30000;
}

int _getExpiration() {
  return 30000 - (new DateTime.now().millisecondsSinceEpoch % 30000);
}
