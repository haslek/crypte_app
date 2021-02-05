
import 'dart:async';
import "package:socket_io_client/socket_io_client.dart";
import "package:socket_io_client/socket_io_client.dart" as IO;

class SocketService{
  final _socketResponse = StreamController<String>();
  IO.Socket socket;
  void Function(String) get addResponse => _socketResponse.sink.add;

  Stream<String> get getResponse => _socketResponse.stream;

  void dispose(){
    _socketResponse.close();
  }
  void connectAndListen(){
    this.socket = IO.io("http://localhost:3000",OptionBuilder().setTransports(['websocket']).build());
    this.socket.onConnect((_){
      print("Connected");
    });
    this.socket.on('new message',(data)=>this.addResponse);
    this.socket.onDisconnect((_)=>print("Disconnected"));
  }

}