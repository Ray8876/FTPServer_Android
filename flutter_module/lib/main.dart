import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter_module/page/helpPage.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';
import 'dart:io';

import 'page/easyModePage.dart';
import 'page/advancedModePage.dart';
import 'utils/deviceUtil.dart';
import 'wave/config.dart';
import 'wave/wave.dart';


int isAdvanced = 0;
int isRun = 0;
AnimationController animationController;

const platform = const MethodChannel('top.ray8876.one_click_ftp/StartFTP');
const eventChannel = const EventChannel("top.ray8876.one_click_ftp/EventInfo");
String address = '';


void main() {
  runApp(new MyApp());
  if (Platform.isAndroid) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
  }
}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    DeviceUtil.setBarStatus(true);
    return BotToastInit(
      child: MaterialApp(
        title: '一键FTP',
        navigatorObservers: [BotToastNavigatorObserver()],
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: MyHomePage(title: '一键FTP'),
      ));
  }
}

class MyHomePage extends StatefulWidget {
  final String title;

  MyHomePage({Key key, this.title}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {

  GlobalKey<_MyStatusCardState> key = GlobalKey();
  final List<Widget> _pages = List();
  PageController _controller;

  static Color _color1 = Colors.white;
  static Color _color2 = Colors.blue[600];
  static Color _color3 = Colors.blue[200];
  static Color _highlightColor = Colors.blue;

  Color _textColorEasy = _color1;
  Color _textColorAdvanced = _color3;
  Color _buttonColorEasy = _color2;
  Color _buttonColorAdvanced = _color1;

  void _easyMode() {
    if (isAdvanced == 1) {
      setState(() {
        _textColorEasy = _color1;
        _textColorAdvanced = _color3;
        _buttonColorEasy = _color2;
        _buttonColorAdvanced = _color1;
      });

      isAdvanced = 0;
      _changePage(0);
    }
  }

  void _advancedMode() {
    if (isAdvanced == 0) {
      setState(() {
        _textColorEasy = _color3;
        _textColorAdvanced = _color1;
        _buttonColorEasy = _color1;
        _buttonColorAdvanced = _color2;
      });
      _changePage(1);
      isAdvanced = 1;
    }
  }

  void _changePage(int _index) {
    _controller.animateToPage(
      _index % 2, //跳转到的位置
      duration: Duration(milliseconds: 666), //跳转的间隔时间
      curve: Curves.easeInOut, //跳转动画
    );
  }

  void _sendUpdateMyCard() {
    key.currentState.updateMyCard();
  }


  @override
  void initState() {
    super.initState();
    if (animationController == null) {
      animationController = AnimationController(
        vsync: this,
        duration: Duration(seconds: 1),
      );
      animationController.forward();
    }
    _pages..add(EasyModePage())..add(AdvancedModePage());
    _controller = PageController(initialPage: isAdvanced);

  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  Widget _buildPageWidget() {
    return PageView.builder(
      controller: _controller,
      itemCount: _pages.length,
      physics: NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        return _pages[index];
      },
      onPageChanged: (index) {
        if (index != _controller.page) {
          setState(() {
            isAdvanced = index;
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        elevation: 2,
        highlightElevation: 6,
        tooltip: "按这么长时间干嘛",
        child: AnimatedIcon(
          size: 30,
          icon: AnimatedIcons.pause_play,
          progress: animationController,
        ),
        onPressed: () {
          _startFTP();
        },
      ),
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        notchMargin: 6.0, // FloatingActionButton和BottomAppBar 之间的差距
        color: _color1,
        child: Row(

          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Container(
              height: 50,
              padding: EdgeInsets.all(5),
              child: RaisedButton(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                onPressed: () {
                  _easyMode();
                },
                child: Text("简易模式"),
                textColor: _textColorEasy,
                color: _buttonColorEasy,
                highlightColor: _highlightColor,
              ),
            ),
            Container(
              height: 0,
              margin: EdgeInsets.all(25),
            ),
            Container(
              height: 50,
              padding: EdgeInsets.all(5),
              child: RaisedButton(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                onPressed: () {
                  _advancedMode();
                },
                child: Text("高级模式"),
                textColor: _textColorAdvanced,
                color: _buttonColorAdvanced,
                highlightColor: _highlightColor,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: <Widget>[
          SafeArea(
            child: Text(""),
          ),
          MyStatusCard(key),
          Expanded(child: (
            _buildPageWidget()
          )
          ),
//              MyBottomAppBar(
//                  changePage: (index) => _changePage(index),
//                  sendUpdateMyCard:(){_sendUpdateMyCard();}
//              ),
        ]
      )
    );
  }

  void startListen() {
    eventChannel.receiveBroadcastStream().listen(_onEvent, onError: _onError);
  }

//接收activity传递来的参数obj
  void _onEvent(Object obj) {
    Map<String, dynamic> _obj = json.decode(obj.toString());
    switch (_obj['status']) {
      case 'error':
        {
          showToast("FTP", _obj['info'], new Icon(
            Icons.error,
            color: Colors.redAccent,
          ));
          break;
        }
      case 'run':
        {
          address = _obj['info'];
          isRun = 1;
          _sendUpdateMyCard();
          animationController.reverse();
          break;
        }
      case 'stop':
        {
          isRun = 0;
          _sendUpdateMyCard();
          animationController.forward();
          break;
        }
    }
  }

  void _onError(Object obj) {
    showToast("FTP", obj.toString(), new Icon(
      Icons.error,
      color: Colors.redAccent,
    ));
  }

  Future<void> _startFTP() async {
    startListen();

    if (isAdvanced == 0) {
      try {
        await platform.invokeMethod('StartFTP1');
      } on PlatformException catch (e) {
        print(e.toString());
      }
    } else {
      try {
        String result = await platform.invokeMethod('StartFTP2');
        if (result == "0") {
          showToast('请添加用户', '“高级模式”至少需要有一名用户，否则请切换到“简易模式”。', new Icon(
            Icons.cancel,
            color: Colors.redAccent,
          ));
        }
      } on PlatformException catch (e) {
        print(e.toString());
      }
    }

    //BotToast.showText(text: "startFTP_result:" + result.toString());
  }
}


class MyStatusCard extends StatefulWidget {
  MyStatusCard(Key key) : super(key: key);

  @override
  _MyStatusCardState createState() => _MyStatusCardState();
}

class _MyStatusCardState extends State<MyStatusCard> {

  void updateMyCard() {
    setState(() {});
  }

  MaskFilter _blur;
  double myCardHeight = 150;

//  final List<MaskFilter> _blurs = [
//    null,
//    MaskFilter.blur(BlurStyle.normal, 10.0),
//    MaskFilter.blur(BlurStyle.inner, 10.0),
//    MaskFilter.blur(BlurStyle.outer, 10.0),
//    MaskFilter.blur(BlurStyle.solid, 16.0),
//  ];
//  int _blurIndex = 0;
//  MaskFilter _nextBlur() {
//    if (_blurIndex == _blurs.length - 1) {
//      _blurIndex = 0;
//    } else {
//      _blurIndex = _blurIndex + 1;
//    }
//    _blur = _blurs[_blurIndex];
//    return _blurs[_blurIndex];
//  }

  _buildCard({Config config, Color backgroundColor = Colors.transparent}) {
    return Container(
      height: myCardHeight,
      width: double.infinity,
      child: Card(
        elevation: 4.0,
        margin: EdgeInsets.only(right: 20.0, left: 20.0, bottom: 5.0),
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16.0))),
        child: WaveWidget(
          config: config,
          backgroundColor: backgroundColor,
          size: Size(double.infinity, double.infinity),
          waveAmplitude: 0,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 800),
          switchInCurve: Curves.easeInExpo,
          switchOutCurve: Curves.easeOutBack,
          transitionBuilder: (Widget child, Animation<double> animation) {
            var tween = Tween<Offset>(begin: Offset(-1, 0), end: Offset(0, 0));
            return SlideTransition(
              child: child,
              position: tween.animate(animation),
            );
          },
          child: Builder(
            key: ValueKey<int>(isRun),
            builder: (context) {
              if (isRun == 0) {
                return Stack(
                  children: <Widget>[
                    _buildCard(
                      config: CustomConfig(
                        colors: [
                          Colors.grey[800],
                          Colors.grey[600],
                          Colors.grey[400],
                          Colors.grey[200],
                        ],
                        durations: [32000, 21000, 18000, 5000],
                        heightPercentages: [0.25, 0.26, 0.28, 0.31],
                        blur: _blur,
                      ),
                      backgroundColor: Colors.white
                    ),
                    Container(
                      height: myCardHeight - 15,
                      width: double.infinity,
                      margin: EdgeInsets.only(left: 25, right: 25, top: 6),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(
                                "  状态：  未运行",
                                textAlign: TextAlign.left,
                                overflow: TextOverflow.fade,
                                maxLines: 1,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 2.0,
                                  color: Colors.grey[700],
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  Navigator.push(context, MaterialPageRoute(
                                    builder: (BuildContext context) => HelpPage()));
                                },
                                icon: Hero(
                                  tag: 'help',
                                  child: Icon(Icons.help_outline),
                                ),
                              )
                            ],
                          ),
                        ],
                      )
                    ),
                  ],
                );
              }
              else
                return Stack(
                  children: <Widget>[
                    _buildCard(
                      config: CustomConfig(
                        colors: [
                          Colors.white70,
                          Colors.white54,
                          Colors.white30,
                          Colors.white24,
                        ],
                        durations: [32000, 21000, 18000, 5000],
                        heightPercentages: [0.25, 0.26, 0.28, 0.31],
                        blur: _blur,
                      ),
                      backgroundColor: Colors.blue[600]
                    ),
                    Container(
                      height: myCardHeight - 15,
                      width: double.infinity,
                      margin: EdgeInsets.only(left: 25, right: 25, top: 6),
                      padding: EdgeInsets.only(bottom: 10),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(
                                "  状态：  运行中",
                                textAlign: TextAlign.left,
                                overflow: TextOverflow.fade,
                                maxLines: 1,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 2.0,
                                  color: Colors.white,
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  Navigator.push(context, MaterialPageRoute(
                                    builder: (BuildContext context) => HelpPage()));
                                },
                                icon: Hero(
                                  tag: 'help',
                                  child: Icon(Icons.help_outline, color: Colors.white,),
                                ),
                              )
                            ],
                          ),
                          GestureDetector(
                            onTap: () {
                              ClipboardData data = new ClipboardData(text: address);
                              Clipboard.setData(data);
                              showToast("已复制到剪贴板", address, new Icon(
                                Icons.library_books,
                                color: Colors.green,
                              ));
                            },
                            child: Container(
                              alignment: Alignment.center,
                              child: Text(
                                address,
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.blue[900],
                                ),
                              ),
                            ),
                          )

                        ],
                      )
                    ),
                  ],
                );
            },),

        )
      ],
    );
  }
}

void showToast(String str1, String str2, Icon icon) {
  BotToast.showNotification(
    leading: (_) =>
      SizedBox.fromSize(
        size: const Size(40, 40),
        child: ClipOval(
          child: icon
        )),
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
    onlyOne: true,
    duration: Duration(seconds: 3)
  );
}

