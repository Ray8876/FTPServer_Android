import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_module/data/Account.dart';

import 'directoryPicker.dart';

const platform = const MethodChannel('top.ray8876.one_click_ftp/SetUserList');

class AccountPage extends StatefulWidget {
  final String path;
  final List<AccountItem> userList;

  AccountPage({Key key, this.userList, this.path}) : super(key: key);

  @override
  _AccountPageState createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        brightness: Brightness.light,
        //backgroundColor: Colors.white,
        leading: BackButton(),
        title: const Text('账户设置'),
        actions: <Widget>[
          FlatButton(
            child: Row(
              children: <Widget>[
                Icon(
                  Icons.add,
                  color: Colors.white,
                ),
                Text(
                  '添加用户',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                )
              ],
            ),
            onPressed: () {
              String _account = '';
              String _password = '';
              String _path = widget.path;
              bool _writable = false;

              bool _obscureText = true;

              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext context) {
                  return StatefulBuilder(builder: (context, state) {
                    return SimpleDialog(
                      title: SizedBox(
                        height: 30,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text('添加用户'),
                            IconButton(
                              icon: Icon(
                                Icons.close,
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            )
                          ],
                        ),
                      ),
                      children: <Widget>[
                        SingleChildScrollView(
                          child: Container(
                            margin: EdgeInsets.only(left: 10, right: 10),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                children: <Widget>[
                                  TextFormField(
                                    keyboardType: TextInputType.text,
                                    decoration: InputDecoration(
                                      border: UnderlineInputBorder(),
                                      filled: true,
                                      hintText: '支持字母和数字，最大18位',
                                      hintStyle: TextStyle(
                                        fontSize: 12,
                                      ),
                                      icon: Icon(Icons.person_outline),
                                      labelText: '用户名',
                                    ),
                                    onChanged: (String value) {
                                      _account = value;
                                    },
                                    inputFormatters: [
                                      WhitelistingTextInputFormatter(
                                        RegExp("[a-zA-Z]|[0-9]")),
                                      //只能输入字母或数字
                                      LengthLimitingTextInputFormatter(18),
                                      //最大长度
                                    ],
                                    validator: (value) {
                                      if (value.isEmpty) {
                                        return '请输入用户名';
                                      }
                                      return null;
                                    },
                                  ),
                                  SizedBox(
                                    height: 8,
                                  ),
                                  TextFormField(
                                    keyboardType: TextInputType.text,
                                    obscureText: _obscureText,
                                    onChanged: (String value) {
                                      _password = value;
                                    },
                                    inputFormatters: [
                                      WhitelistingTextInputFormatter(
                                        RegExp("[a-zA-Z]|[0-9]")),
                                      //只能输入字母或数字
                                      LengthLimitingTextInputFormatter(18),
                                      //最大长度
                                    ],
                                    decoration: InputDecoration(
                                      border: UnderlineInputBorder(),
                                      filled: true,
                                      icon: Icon(Icons.lock_outline),
                                      labelText: '密码',
                                      hintText: '支持字母和数字，最大18位',
                                      hintStyle: TextStyle(
                                        fontSize: 12,
                                      ),
                                      suffixIcon: new GestureDetector(
                                        onTap: () {
                                          state(() {
                                            _obscureText = !_obscureText;
                                          });
                                        },
                                        child: new Icon(_obscureText
                                          ? Icons.visibility
                                          : Icons.visibility_off),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 8,
                                  ),
                                  Container(
                                    height: 50,
                                    margin:
                                    EdgeInsets.only(left: 10, right: 10),
                                    child: new GestureDetector(
                                      onTap: () async {
                                        String tempPath = await Navigator
                                          .push(context, PageRouteBuilder(
                                          pageBuilder: (BuildContext
                                          context,
                                            Animation animation,
                                            Animation
                                            secondaryAnimation) {
                                            return new FadeTransition(
                                              opacity: animation,
                                              child: DirectoryPickerView(_path),
                                            );
                                          }));
                                        if (tempPath != null) {
                                          state(() {
                                            _path = tempPath;
                                          });
                                        }
                                      },
                                      child: Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          Text(
                                            'FTP路径  ',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          Hero(
                                            tag: 'path',
                                            child: Text(
                                              _path,
                                              overflow: TextOverflow.fade,
                                              maxLines: 3,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 8,
                                  ),
                                  Container(
                                    height: 50,
                                    margin:
                                    EdgeInsets.only(left: 10, right: 10),
                                    child: Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Text(
                                          '写入权限  ',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        Switch(
                                          value: _writable,
                                          onChanged: (bool value) {
                                            state(() {
                                              _writable = value;
                                            });
                                          },
                                        )
                                      ],
                                    ),
                                  ),
                                  RaisedButton(
                                    child: Text('添加用户'),
                                    color: Colors.blue,
                                    textColor: Colors.white,
                                    onPressed: () async {
                                      if (!_formKey.currentState.validate()) {
                                        return;
                                      }
                                      Map<String, dynamic> mp = new Map();
                                      mp['action'] = 'add';
                                      mp['account'] = _account;
                                      mp['password'] = _password;
                                      mp['path'] = _path;
                                      mp['writable'] = _writable;

                                      String result = await platform
                                        .invokeMethod(json.encode(mp));
                                      print('添加用户' + result);

                                      await getNewUserList();
//                                        setState(() {
//                                          print('update!!');
//                                          getNewUserList();
//                                        });
//                                        print('im close');
                                      Navigator.pop(context);
                                    },
                                  )
                                ],
                              ),
                            ),
                          ),
                        )
                      ],
                      elevation: 20,
                      // 设置成 圆角
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    );
                  });
                });
            },
          )
        ],
      ),
      body: _buildUserList(),
    );
  }

  Widget _buildUserList() {
    return ListView.builder(
      itemCount: widget.userList == null ? 0 : widget.userList.length,
      itemBuilder: (context, index) {
        final String item = widget.userList[index].id.toString();
        // Each Dismissible must contain a Key. Keys allow Flutter to uniquely
        // identify Widgets.
        return Dismissible(
          key: Key(item),
          confirmDismiss: (direction) async {
            return await _showConfirmationDialog(context, index);
          },
          onDismissed: (DismissDirection dir) async {
            Map<String, dynamic> mp = new Map();
            mp['action'] = 'delete';
            mp['id'] = widget.userList[index].id;
            String result = await platform.invokeMethod(json.encode(mp));
            print('删除用户' + result);
//                setState(() {
//                  getNewUserList();
//                });
          },
          background: Container(
            color: Colors.redAccent,
            child: Icon(Icons.delete, color: Colors.white),
            alignment: Alignment.centerLeft,
          ),
          secondaryBackground: Container(
            color: Colors.redAccent,
            child: Icon(Icons.delete, color: Colors.white),
            alignment: Alignment.centerRight,
          ),
          child: Container(
            height: 60,

            //title: Center(child: Text('${widget.userList[index]}')),
            padding: EdgeInsets.only(
              right: 10,
            ),
            child: Row(
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(
                    left: 15, top: 10, bottom: 10, right: 10),
                  child: Icon(
                    Icons.account_circle,
                    size: 40,
                  ),
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Container(
                                width: 100,
                                child: Text(
                                  widget.userList[index].account,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14),
                                ),
                              ),
                              Text(widget.userList[index].password == ''
                                ? '无密码'
                                : '有密码'),
                            ],
                          ),
                          Text(
                            'id: ' + widget.userList[index].id.toString(),
                            style: TextStyle(fontWeight: FontWeight.w500),
                          )
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(widget.userList[index].path),
                          Text(widget.userList[index].writable
                            ? '可写入'
                            : '不可写入'),
                        ],
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        );
      });
  }

  Future<bool> _showConfirmationDialog(BuildContext context, int index) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('删除用户'),
          content: Text('是否删除用户ID：' +
            widget.userList[index].id.toString() +
            ' 用户名：' +
            widget.userList[index].account +
            ' ?（此操作不可撤销！！！）'),
          actions: <Widget>[
            FlatButton(
              child: Text('手滑了..'),
              onPressed: () {
                Navigator.pop(context, false);
              },
            ),
            FlatButton(
              child: Text('删除'),
              onPressed: () {
                Navigator.pop(context, true);
              },
            ),
          ],
          elevation: 20,
          // 设置成 圆角
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        );
      },
    );
  }

  Future<void> getNewUserList() async {
    try {
      Map<String, dynamic> mp = new Map();
      mp['action'] = 'get';
      String result = await platform.invokeMethod(json.encode(mp));
      List<Object> _userList = json.decode(result.toString());

      //print(_userList);
      setState(() {
        widget.userList.clear();
        _userList.forEach((i) {
          Map<String, dynamic> _item = json.decode(i.toString());
          AccountItem accountItem = new AccountItem();
          accountItem.id = _item['id'];
          accountItem.account = _item['account'];
          accountItem.password = _item['password'];
          accountItem.path = _item['path'];
          accountItem.writable = _item['writable'];
          //print(_item);
          widget.userList.add(accountItem);
        });
      });
    } on PlatformException catch (e) {
      print(e.toString());
    }
  }
}
