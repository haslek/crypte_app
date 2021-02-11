import 'package:cryptem_app/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Widget singlePrivateMessage(RoomMessages messages){
  return Card(
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      children: [
        Flexible(child: Text(messages.message)),
        Flexible(
          child: Text(
            messages.createdAt,style: TextStyle(fontSize: 5.0,fontStyle:FontStyle.italic),
          ),
        )
      ],
    ),

  );
}