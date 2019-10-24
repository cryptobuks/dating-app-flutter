import 'dart:io';
import 'dart:math';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:date_it/model/Users.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../const.dart';
import '../../main.dart';
import './call.dart';

class IndexPage extends StatefulWidget {
  String currentUserId;

  IndexPage(this.currentUserId);

  @override
  State<StatefulWidget> createState() {
    return new IndexState();
  }
}

class IndexState extends State<IndexPage> {
  /// create a channelController to retrieve text value

  static Users user = new Users(0, false);



  var shouldICall = false;

  List<Users> calls = new List<Users>();

  final databaseReference = FirebaseDatabase.instance.reference();

  /// if channel textfield is validated to have error
  bool _validateError = false;

  @override
  void initState() {
    // TODO: implement initState
    user = new Users(0, true);
    databaseReference.child('Users').onChildAdded.listen(_onChildAdded);

    super.initState();
  }

  @override
  void dispose() {
    // dispose input controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Start Dating'),
        ),

        body: WillPopScope(

        child:Container(
          margin: EdgeInsets.all(0),
          child: Stack(
            children: <Widget>[
              Container(
                decoration: BoxDecoration(
                  image: DecorationImage( image: AssetImage('images/love.jpg'),
                    fit: BoxFit.fill,
                    alignment: Alignment.center
                  )

                ),),
              Center(
                child:Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Padding(
                          padding: EdgeInsets.only(bottom: 20),
                          child: RaisedButton(
                            onPressed: () => openChat(),
                            child: Text("      Chat Now     "),
                            color: Colors.blueAccent,
                            textColor: Colors.white,
                          )),

                      Padding(
                          padding: EdgeInsets.only(bottom: 20),
                          child: RaisedButton(
                            onPressed: () => onJoin(),
                            child: Text("Make video Call"),
                            color: Colors.blueAccent,
                            textColor: Colors.white,
                          ))
                    ],
                  ),),


            ],
          ),
        ),
          onWillPop: onBackPress,
        ),




    );
  }

  onJoin() async {
    // update input validation

    // await for camera and mic permissions before pushing video page
    await _handleCameraAndMic();

    shouldICall = getChannel();
    if (!shouldICall) {
      user.channel = 0;
    } else {
      user.users++;
      _onChildUpdate(user.key);
    }

    // push video page with given channel name
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => new CallPage(
                  channelName: user.channel,
                )));
  }

  _handleCameraAndMic() async {
    return await PermissionHandler().requestPermissions(
        [PermissionGroup.camera, PermissionGroup.microphone]);
  }

  void _onChildAdded(Event event) {
    print(
        'inside on child added ........................................................................................');
    calls.add(Users.fromSnapshot(event.snapshot));

    print('calls' + calls.length.toString());

    if (!shouldICall) {
      shouldICall = getChannel();
    }
  }

  void _onChildRemove(String key) {
    this.databaseReference.child("Users").child(key).remove();
  }

  void _onChildUpdate(String key) {
    try {
      if (user.users == 2) {
        user.available = false;
      }
      this.databaseReference.child("Users").child(key).update(user.toJson());
    } catch (e) {
      print(e);
    }
  }

  _getChannelId() {
    if (calls.length == 0) {
      databaseReference.child('Users').once().then((onValue) {
        onValue.value.forEach((key, val) {
          Users value = new Users(0, false);
          value.users = val['users'];
          value.available = val['available'];
          value.key = key;
          value.channel = val['channel'];

          //Users.fromSnapshot(onValue);
          //value = value.toJson();
          if (value.available && value.users < 2) {
            user = value;
            return;
          } else {
            user = null;
          }
          calls.add(value);
        });
      });
    }

    calls.forEach((value) {
      if (value.available && value.users < 2) {
        user = value;
        return;
      } else {
        user = null;
      }
    });
  }

  getChannel() {
    var flag = false;
    for (var i = 0; i < calls.length; i++) {
      Users u = calls[i];

      if (u.available && u.users < 2) {
        print(
            'true........................................................................................');
        user = u;
        _onChildUpdate(u.key);
        flag = true;
      } else {
        print(
            'false.........................................................................................');
        flag = false;
      }
    }

    return flag;
  }

  _getRandomId() {
    var value = new Random().nextInt(10000);
    user = new Users(0, true);
    user.channel = value;
    return value;
  }

  _addToFirebase() {
    databaseReference.child("Users").push().set(user.toJson());
  }

  openChat() {
    Navigator.push(context,MaterialPageRoute(builder: (context) => MainScreen(currentUserId: widget.currentUserId)));
  }

  Future<bool> onBackPress() {
    openDialog();
    return Future.value(false);
  }

  Future<Null> openDialog() async {
    switch (await showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            contentPadding: EdgeInsets.only(left: 0.0, right: 0.0, top: 0.0, bottom: 0.0),
            children: <Widget>[
              Container(
                color: themeColor,
                margin: EdgeInsets.all(0.0),
                padding: EdgeInsets.only(bottom: 10.0, top: 10.0),
                height: 140.0,
                child: Column(
                  children: <Widget>[
                    Container(
                      child: Icon(
                        Icons.exit_to_app,
                        size: 30.0,
                        color: Colors.white,
                      ),
                      margin: EdgeInsets.only(bottom: 10.0),
                    ),
                    Text(
                      'Exit app',
                      style: TextStyle(color: Colors.white, fontSize: 18.0, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Are you sure to exit app?',
                      style: TextStyle(color: Colors.white70, fontSize: 14.0),
                    ),
                  ],
                ),
              ),
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, 0);
                },
                child: Row(
                  children: <Widget>[
                    Container(
                      child: Icon(
                        Icons.cancel,
                        color: primaryColor,
                      ),
                      margin: EdgeInsets.only(right: 10.0),
                    ),
                    Text(
                      'CANCEL',
                      style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
                    )
                  ],
                ),
              ),
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, 1);
                },
                child: Row(
                  children: <Widget>[
                    Container(
                      child: Icon(
                        Icons.check_circle,
                        color: primaryColor,
                      ),
                      margin: EdgeInsets.only(right: 10.0),
                    ),
                    Text(
                      'YES',
                      style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
                    )
                  ],
                ),
              ),
            ],
          );
        })) {
      case 0:
        break;
      case 1:
        exit(0);
        break;
    }
  }
}
