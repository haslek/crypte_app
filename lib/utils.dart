
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:get_it/get_it.dart';
import "package:socket_io_client/socket_io_client.dart";
import "package:socket_io_client/socket_io_client.dart" as IO;
import 'package:http/http.dart' as http;

class ApiProvider {
  final String _baseUrl = "http://192.168.43.159/crypte_web_app/";
  Future<dynamic> get(String url, {String token}) async {
    var responseJson;
    Map<String,String> headers = {
      HttpHeaders.contentTypeHeader:"application/json",
    };
    if(token != null){
      headers[HttpHeaders.authorizationHeader] = token;
    }
    try {
      final response = await http.get(_baseUrl + url,headers: headers);
      responseJson = _response(response);
    } on SocketException {
      return 'No Internet connection';
    }
    return responseJson;
  }
  Future<dynamic> post(String url, Map<String,dynamic> data, {String token}) async {
    var responseJson;
    Map<String,String> headers = {
      HttpHeaders.contentTypeHeader:"application/json",
    };
    if(token != null){
      headers[HttpHeaders.authorizationHeader] = token;
    }
    try {
      final response = await http.post(_baseUrl + url,headers:headers,body: jsonEncode(data));
      responseJson = _response(response);
    } on SocketException {
      return 'No Internet connection';
    }
    return responseJson;
  }

  dynamic _response(http.Response response) {
    var responseJson;
    try {
      responseJson = json.decode(response.body.toString());
      print(responseJson);
    } on Exception catch (e) {
      // TODO
      return "Malformed data in response body";
    }
    switch (response.statusCode) {
      case 200:

        return responseJson;
      case 400:
        String error = 'Bad request\n';
        if(responseJson is Map){
          responseJson.forEach((key, value) {
            error = error+value.toString()+"\n";
          });
        }
        return error;
      case 401:

      case 403:
          return 'Unauthorized request';
      case 500:

      default:
            return 'Internal Sever error!';
    }
  }
}

class Response<T> {
  Status status;
  T data;
  String message;

  Response.loading(this.message) : status = Status.LOADING;
  Response.completed(this.data) : status = Status.COMPLETED;
  Response.error(this.message) : status = Status.ERROR;

  @override
  String toString() {
    return "Status : $status \n Message : $message \n Data : $data";
  }
}

enum Status { LOADING, COMPLETED, ERROR }

Future<Response> postCalls(String url,Map<String,dynamic> creds,{String token}) async{
  ApiProvider provider = new ApiProvider();
  var response;
  if(token != null){
    response = await provider.post(url, creds,token: token);
  }else{
    response = await provider.post(url, creds);
  }

  Response resp;
  if(response is Map){
    if(response.containsKey("error")){
      resp = Response.error(response['error']);

    }else{
      resp = Response.completed(response);
    }

  }else{
    resp = Response.error(response);
  }
  return resp;
}
Future<Response> getCalls(String url,{String token}) async{
  ApiProvider provider = new ApiProvider();
  var response = await provider.get(url);
  Response resp;
  if(response is Map){
    if(response.containsKey("error")){
      resp.message = response['error'];
      resp.status = Status.ERROR;
    }else{
      resp.data = response;
      resp.status = Status.COMPLETED;
    }
  }else{
    resp.message = response;
    resp.status = Status.ERROR;
  }
  return resp;
}
class User{
   String _displayName;

   // ignore: unnecessary_getters_setters
   String get gAccessToken => _accessToken;

  // ignore: unnecessary_getters_setters
  set accessToken(String value) {
    _accessToken = value;
  }

  String _userId;

   // ignore: unnecessary_getters_setters
   String get gDisplayName => _displayName;

  // ignore: unnecessary_getters_setters
  set displayName(String value) {
    _displayName = value;
  }

  String _email;
   String _phone;
   String _firstName;
   String _lastName;
   String _accessToken;
   String _otp;
   bool isLoggedIn = false;
   User();

   Map<String, dynamic> toJson(){
     return {
       "display_name":_displayName,
       "user_id":_userId,
       "email":_email,
       "phone":_phone,
       "first_name":_firstName,
       "last_name":_lastName
     };
   }
   void fromJson(Map<String,dynamic> json){
     _email = json['email'].toString();
     _phone = json['phone'].toString();
     _userId = json['id'].toString();
     _lastName = json['last_name'].toString();
     _firstName = json['first_name'].toString();
     _otp = json['otp'].toString();
     _accessToken = json['access_token'].toString();
   }
   void login(){
     isLoggedIn = true;
   }

   // ignore: unnecessary_getters_setters
   String get gUserId => _userId;

  // ignore: unnecessary_getters_setters
  set userId(String value) {
    _userId = value;
  }

   // ignore: unnecessary_getters_setters
   String get gEmail => _email;

  // ignore: unnecessary_getters_setters
  set email(String value) {
    _email = value;
  }

   String get gPhone => _phone;

  // ignore: unnecessary_getters_setters
  set phone(String value) {
    _phone = value;
  }

   // ignore: unnecessary_getters_setters
   String get gFirstName => _firstName;

  // ignore: unnecessary_getters_setters
  set firstName(String value) {
    _firstName = value;
  }

   // ignore: unnecessary_getters_setters
   String get gLastName => _lastName;

  // ignore: unnecessary_getters_setters
  set lastName(String value) {
    _lastName = value;
  }

   // ignore: unnecessary_getters_setters
   String get gOtp => _otp;

  // ignore: unnecessary_getters_setters
  set otp(String value) {
    _otp = value;
  }
}
class RoomMessages{
  final String messageId;
  final String message;
  final String senderId;
  final String createdAt;
  bool isReply;
  final String groupId;
  final String replyTo;

  RoomMessages({this.message,this.groupId,this.senderId,this.isReply,this.messageId,this.replyTo,this.createdAt});

  bool hasFile = false;
  bool visible = true;
  bool deleted = false;

  factory RoomMessages.fromJson(Map<String,dynamic> json){
    return RoomMessages(
      message: json['message'].toString(),
      messageId: json['id'].toString(),
      senderId: json['user_id'].toString(),
      groupId: json['group_id'].toString(),
      replyTo: json['replied_to'],
      isReply: json['replied_to']!=null,
      createdAt: json['created_at'].toString()
    );
  }
}
class Room{
  final String roomId;
  final String roomName;
  final String roomType;
  Room({this.roomId,this.roomType,this.roomName,this.isNew,this.messages});

  List<RoomMessages> messages = [];
  bool isNew = false;
  void addMessage(RoomMessages message){
    messages.add(message);
  }

  factory Room.fromJson(Map<String,dynamic> json){
    return Room(
      roomId: json['id'].toString(),
      roomType: json['is_group'].toString(),
      roomName: json['group_name'].toString()
    );
  }
}
class ChatMates{
  final String displayName;
  final String firstName;
  final String lastName;
  final String publicKey;
  final String userId;

  ChatMates({this.displayName,this.firstName,this.lastName,this.userId,this.publicKey});
  factory ChatMates.fromJson(Map<String,dynamic> json){
    return ChatMates(
      displayName: json['display_name'].toString(),
      lastName: json['last_name'].toString(),
      firstName: json['first_name'].toString(),
      userId: json['user_id'].toString(),
      publicKey: json['p_key'].toString()
    );
  }
}

class SocketService{
  final _socketResponse = StreamController<Map<String,dynamic>>.broadcast();
  // final _roomEvents = StreamController<Map>();
  final user = GetIt.I<User>();
  IO.Socket socket;
  void Function(Map<String,dynamic>) get addResponse => _socketResponse.sink.add;
  Stream<Map<String,dynamic>> get getResponse => _socketResponse.stream;
  void dispose(){
    _socketResponse.close();
  }
  Map<String,dynamic> userDetails = {
    "user_id":""
  };
  void connectAndListen(){

    this.socket = IO.io("http://192.168.43.159:2020",OptionBuilder().setTransports(['websocket']).build());
    this.socket.onConnect((_){
      this.socket.emitWithAck('online',jsonEncode({"id":user.gUserId}),ack: (data){
        print(data);
      });
      print("Connected "+this.user.gUserId);
    });
    this.socket.on('new message',(data){
      data = {
        "type": "room_message",
        "data":data
      };
      this.addResponse(data);
    });
    this.socket.on('your rooms',(data){
      print("emitted");
      print(data);
      data = {
        "type": "your rooms",
        "data":data
      };
      this.addResponse(data);
    });
    this.socket.on('your rooms',(data){
      data = {
        "type": "room",
        "data":data
      };
      this.addResponse(data);
    });
    this.socket.on('online',(data){
      data = {
        "type": "online",
        "data":data
      };
      this.addResponse(data);
    });
    this.socket.onDisconnect((_)=>print("Disconnected"));
  }

}