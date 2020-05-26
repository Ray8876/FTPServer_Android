import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:before_after/before_after.dart';

class HelpPage extends StatefulWidget {
  @override
  createState() => _HelpPageState();
}

class _HelpPageState extends State<HelpPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          child: Column(
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.fromLTRB(15, 15, 15, 2),
                    child: IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.arrow_back_ios, color: Colors.black,),
                    ),
                  ),
                  Hero(
                    tag: 'help',
                    child: Icon(Icons.help_outline, color: Colors.black,),
                  ),
                  Text("  帮助", style: TextStyle(fontSize: 20),)
                ],
              ),
              Expanded(
                flex: 1,
                child: BeforeAfter(
                  beforeImage: Image.asset('assets/Easy.jpg'),
                  afterImage: Image.asset('assets/Adv.jpg'),
                  isVertical: false,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}