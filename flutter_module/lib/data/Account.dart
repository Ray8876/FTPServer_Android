class AccountItem {

  int id = -1;
  String account = '';
  String password = '';
  String path = '';
  bool writable = false;

  String toString() {
    Map mp = new Map();

    mp['id'] = id;
    mp['account'] = account;
    mp['password'] = password;
    mp['path'] = path;
    mp['writable'] = writable;

    return mp.toString();
  }

}