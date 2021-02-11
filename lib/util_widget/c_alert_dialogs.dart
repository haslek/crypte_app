import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Future<void> showSuccessDialog(String message,BuildContext context)async{
  showDialog(
    context: context,
    child: AlertDialog(
      title: Text("Success",style: TextStyle(color: Colors.green,fontWeight: FontWeight.bold),),
      content: Text(message==null?"Request successful":message),
      actions: [
        FlatButton(onPressed: ()=>Navigator.pop(context), child: Text("Ok"))
      ],
    )
  );
}
Future<void> showFailureDialog(String message,BuildContext context) async{
  showDialog(
      context: context,
      child: AlertDialog(
        title: Text("Error",style: TextStyle(color: Colors.red,fontWeight: FontWeight.bold),),
        content: Text(message==null?"An error occurred":message),
        actions: [
          FlatButton(onPressed: ()=>Navigator.pop(context), child: Text("Dismiss"))
        ],
      )
  );
}