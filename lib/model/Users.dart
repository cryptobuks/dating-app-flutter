

import 'package:firebase_database/firebase_database.dart';

class Users{
  String key;
  int users;
  bool available;
  int channel;


  Users(this.users,this.available);


  Users.fromSnapshot(DataSnapshot snapShot):
      this.key = snapShot.key,
      this.users = snapShot.value['users'],
      this.available = snapShot.value['available'],
      this.channel = snapShot.value['channel'];


  toJson() {
    return {
      "key": key,
      "users": users,
      "channel":channel,
      "available": available,
    };
  }
}