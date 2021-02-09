
import 'dart:async';
import "package:socket_io_client/socket_io_client.dart";
import "package:socket_io_client/socket_io_client.dart" as IO;

class User{
   String displayName;
   String userId;
   String email;
   String phone;
   String firstName;
   String lastName;
   User({this.displayName,this.email,this.firstName,this.lastName,this.phone,this.userId});

   Map<String, dynamic> toJson(){
     return {
       "display_name":displayName,
       "user_id":userId,
       "email":email,
       "phone":phone,
       "first_name":firstName,
       "last_name":lastName
     };
   }

   factory User.fromJson(Map<String,dynamic> json) {
     return User(
       displayName: json['display_name'],
       email: json['email'],
       phone: json['phone'],
       userId: json['id'],
       firstName: json['first_name'],
       lastName: json['last_name']
     );
   }
}

class SocketService{
  final _socketResponse = StreamController<String>();
  IO.Socket socket;
  void Function(String) get addResponse => _socketResponse.sink.add;

  Stream<String> get getResponse => _socketResponse.stream;

  void dispose(){
    _socketResponse.close();
  }
  Map<String,dynamic> userDetails = {
    "user_id":""
  };
  void connectAndListen(){
    this.socket = IO.io("http://localhost:3000",OptionBuilder().setTransports(['websocket']).build());
    this.socket.onConnect((_){
      print("Connected");
      this.socket.emit("online",);
    });
    this.socket.on('new message',(data)=>this.addResponse);
    this.socket.onDisconnect((_)=>print("Disconnected"));
  }

}