

import 'package:flutter/cupertino.dart';

class Call extends StatefulWidget {

  String id;
  Call(this.id);
  @override
  _CallState createState() {
    return _CallState(id);
  }
}

class _CallState extends State<Call> {
  String id = '';

  _CallState(this.id);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text('id is $id'),
    );
  }
}
