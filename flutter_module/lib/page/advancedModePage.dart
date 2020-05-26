import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:bot_toast/bot_toast.dart';
import '../data/Account.dart';
import 'accountPage.dart';

typedef MyItemBodyBuilder<T> = Widget Function(MyItem<T> item);
typedef ValueToString<T> = String Function(T value);

const platform = const MethodChannel('top.ray8876.one_click_ftp/SetData2');

List<MyItem<dynamic>> _myItems;
bool _inputIsValid = true;
bool _isInit = false;
List<AccountItem> userList = new List<AccountItem>();

int port = 8876;
FocusNode _portFocus = FocusNode();
String charset = 'UTF-8';
String path = '';

class DualHeaderWithHint extends StatelessWidget {
  const DualHeaderWithHint({
    this.name,
    this.value,
    this.hint,
    this.showHint,
  });

  final String name;
  final String value;
  final String hint;
  final bool showHint;

  Widget _crossFade(Widget first, Widget second, bool isExpanded) {
    return AnimatedCrossFade(
      firstChild: first,
      secondChild: second,
      firstCurve: const Interval(0.0, 0.6, curve: Curves.fastOutSlowIn),
      secondCurve: const Interval(0.4, 1.0, curve: Curves.fastOutSlowIn),
      sizeCurve: Curves.fastOutSlowIn,
      crossFadeState:
      isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
      duration: const Duration(milliseconds: 200),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextTheme textTheme = theme.textTheme;

    return Row(
      children: <Widget>[
        Expanded(
          flex: 2,
          child: Container(
            margin: const EdgeInsets.only(left: 24.0),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                name,
                style: textTheme.caption.copyWith(fontSize: 15.0),
              ),
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Container(
            margin: const EdgeInsets.only(left: 24.0),
            child: _crossFade(
              Text(value, style: textTheme.caption.copyWith(fontSize: 15.0)),
              Text(hint, style: textTheme.caption.copyWith(fontSize: 15.0)),
              showHint,
            ),
          ),
        ),
      ],
    );
  }
}

class CollapsibleBody extends StatelessWidget {
  const CollapsibleBody({
    this.margin = EdgeInsets.zero,
    this.child,
    this.onSave,
    this.onCancel,
  });

  final EdgeInsets margin;
  final Widget child;
  final VoidCallback onSave;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextTheme textTheme = theme.textTheme;

    return Column(
      children: <Widget>[
        Container(
          margin: const EdgeInsets.only(
            left: 24.0,
            right: 24.0,
            bottom: 24.0,
          ) -
            margin,
          child: Center(
            child: DefaultTextStyle(
              style: textTheme.caption.copyWith(fontSize: 15.0),
              child: child,
            ),
          ),
        ),
        const Divider(height: 1.0),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Container(
                margin: const EdgeInsets.only(right: 8.0),
                child: FlatButton(
                  onPressed: onCancel,
                  child: const Text('取消',
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 15.0,
                      fontWeight: FontWeight.w500,
                    )),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(right: 8.0),
                child: FlatButton(
                  onPressed: onSave,
                  textTheme: ButtonTextTheme.accent,
                  child: const Text('保存'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class MyItem<T> {
  MyItem({
    this.name,
    this.value,
    this.hint,
    this.builder,
    this.valueToString,
  }) : textController = TextEditingController(text: valueToString(value));

  final String name;
  final String hint;
  final TextEditingController textController;
  final MyItemBodyBuilder<T> builder;
  final ValueToString<T> valueToString;
  T value;
  bool isExpanded = false;

  ExpansionPanelHeaderBuilder get headerBuilder {
    return (BuildContext context, bool isExpanded) {
      return DualHeaderWithHint(
        name: name,
        value: valueToString(value),
        hint: hint,
        showHint: isExpanded,
      );
    };
  }

  Widget build() => builder(this);
}

class AdvancedModePage extends StatefulWidget {
  //static const String routeName = '/material/expansion_panels';

  @override
  _AdvancedModePageState createState() => _AdvancedModePageState();
}

class _AdvancedModePageState extends State<AdvancedModePage>
  with AutomaticKeepAliveClientMixin {
  @protected
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    Timer.periodic(Duration(milliseconds: 500), (timer) {
      if (_isInit)
        timer.cancel();
      else
        _getInitialValue();
    });
    if (_myItems != null)
      return Container(
        child: SingleChildScrollView(
          child: SafeArea(
            top: false,
            bottom: false,
            child: Container(
              margin: const EdgeInsets.all(24.0),
              child: Column(
                children: <Widget>[
                  ExpansionPanelList(
                    expansionCallback: (int index, bool isExpanded) {
                      _portFocus.unfocus();
                      setState(() {
                        _myItems[index].isExpanded = !isExpanded;
                      });
                    },
                    children:
                    _myItems.map<ExpansionPanel>((MyItem<dynamic> item) {
                      return ExpansionPanel(
                        isExpanded: item.isExpanded,
                        headerBuilder: item.headerBuilder,
                        body: item.build(),
                      );
                    }).toList(),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(context, PageRouteBuilder(pageBuilder:
                        (BuildContext context, Animation animation,
                        Animation secondaryAnimation) {
                        return new FadeTransition(
                          opacity: animation,
                          child: AccountPage(
                            userList: userList,
                            path: path,
                          ),
                        );
                      })).then((value) {
                        _getInitialValue();
                      });
                    },
                    child: Container(
                      margin: EdgeInsets.only(top: 24, bottom: 24),
                      padding: EdgeInsets.only(left: 24, right: 24),
                      height: 60,
                      width: double.maxFinite,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(2.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black38,
                            //offset: Offset(0.0, 15.0), //阴影xy轴偏移量
                            blurRadius: 2.0, //阴影模糊程度
                            spreadRadius: 0.0 //阴影扩散程度
                          )
                        ]),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            '账户',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 15,
                            ),
                          ),
                          Text('当前账户数：' + userList.length.toString()),
                          Icon(
                            Icons.settings,
                            color: Colors.grey[600],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              )),
          ),
        ),
      );
    else
      return Center(
        child: Container(
          margin: EdgeInsets.all(30),
          height: 30,
          width: 30,
          child: CircularProgressIndicator(),
        ),
      );
  }

  Future<void> _getInitialValue() async {
    String result;
    try {
      result = await platform.invokeMethod('GetInitialValue');
      if (result != null) {
        Map<String, dynamic> _obj = json.decode(result.toString());
        setState(() {
          port = _obj['port'];
          charset = _obj['charset'];
          path = _obj['path'];
          List<Object> _userList = _obj['userList'];
          userList.clear();
          //print(_userList);
          _userList.forEach((i) {
            Map<String, dynamic> _item = json.decode(i.toString());
            AccountItem accountItem = new AccountItem();
            accountItem.id = _item['id'];
            accountItem.account = _item['account'];
            accountItem.password = _item['password'];
            accountItem.path = _item['path'];
            accountItem.writable = _item['writable'];
            //print(_item);
            userList.add(accountItem);
          });
          if (!_isInit) initItems();
        });
        _isInit = true;
      }
    } on PlatformException catch (e) {
      print(e.toString());
    }

    print("getInitialValueresult:" + result.toString());
  }

  Future<void> _setInitialValue() async {
    String result;
    Map<String, dynamic> mp = new Map();
    mp['port'] = port;
    mp['charset'] = charset;
    //print(json.encode(mp));
    try {
      result = await platform.invokeMethod(json.encode(mp));
      if (result != null) {
        showToast(
          '已保存',
          '下次启动FTP时生效',
          new Icon(
            Icons.check_circle,
            color: Colors.greenAccent,
          ));
      }
    } on PlatformException catch (e) {
      print(e.toString());
    }
    print('保存数据' + result.toString());
  }

  void initItems() {
    _myItems = <MyItem<dynamic>>[
      MyItem<int>(
        name: '端口号',
        value: port,
        hint: '修改端口号',
        valueToString: (int port) => port.toString(),
        builder: (MyItem<int> item) {
          void close() {
            setState(() {
              item.isExpanded = false;
            });
          }

          return Form(
            child: Builder(
              builder: (BuildContext context) {
                return CollapsibleBody(
                  margin: const EdgeInsets.symmetric(horizontal: 16.0),
                  onSave: () {
                    if (!_inputIsValid) return;
                    Form.of(context).save();
                    port = item.value;
                    _setInitialValue();
                    _portFocus.unfocus();
                    close();
                  },
                  onCancel: () {
                    _portFocus.unfocus();
                    close();
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: TextFormField(
                      focusNode: _portFocus,
                      controller: item.textController,
                      decoration: InputDecoration(
                        hintText: item.hint,
                        labelText: item.name,
                        errorText:
                        _inputIsValid ? null : "请输入1024~65535之间的数字"),
                      onSaved: (String value) {
                        if (!_inputIsValid) return;
                        item.value = int.parse(value);
                      },
                      onChanged: (String value) {
                        int val = int.parse(value);
                        if (val == null || val < 1024 || val > 65535) {
                          setState(() {
                            _inputIsValid = false;
                          });
                        } else {
                          setState(() {
                            _inputIsValid = true;
                          });
                        }
                      }),
                  ),
                );
              },
            ),
          );
        },
      ),
      MyItem<String>(
        name: '编码',
        value: charset,
        hint: '选择编码方式',
        valueToString: (String value) => value,
        builder: (MyItem<String> item) {
          void close() {
            setState(() {
              item.isExpanded = false;
            });
          }

          return Form(
            child: Builder(builder: (BuildContext context) {
              return CollapsibleBody(
                onSave: () {
                  Form.of(context).save();
                  charset = item.value;
                  _setInitialValue();
                  close();
                },
                onCancel: () {
                  close();
                },
                child: FormField<String>(
                  initialValue: item.value,
                  onSaved: (String result) {
                    item.value = result;
                  },
                  builder: (FormFieldState<String> field) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        RadioListTile<String>(
                          value: 'UTF-8',
                          title: const Text('UTF-8'),
                          groupValue: field.value,
                          onChanged: field.didChange,
                        ),
                        RadioListTile<String>(
                          value: "GBK",
                          title: const Text('GBK'),
                          groupValue: field.value,
                          onChanged: field.didChange,
                        ),
                      ],
                    );
                  },
                ),
              );
            }),
          );
        },
      ),
    ];
  }
}

void showToast(String str1, String str2, Icon icon) {
  BotToast.showNotification(
    leading: (_) =>
      SizedBox.fromSize(
        size: const Size(40, 40), child: ClipOval(child: icon)),
    title: (_) => Text(str1),
    subtitle: (_) => Text(str2),
    trailing: (cancel) =>
      IconButton(
        icon: Icon(Icons.cancel),
        onPressed: cancel,
      ),
    enableSlideOff: true,
    crossPage: true,
    contentPadding: EdgeInsets.all(2),
    onlyOne: false,
    duration: Duration(seconds: 2));
}
