
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:get_it/get_it.dart';
import "package:socket_io_client/socket_io_client.dart";
import "package:socket_io_client/socket_io_client.dart" as IO;
import 'package:http/http.dart' as http;
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

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
    print(token);
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
    print(responseJson);
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
   String _publicKey;
   bool isLoggedIn = false;
   User();

   Map<String, dynamic> toJson(){
     return {
       "display_name":_displayName,
       "user_id":_userId,
       "email":_email,
       "phone":_phone,
       "first_name":_firstName,
       "last_name":_lastName,
       "public_key": _publicKey
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
     _publicKey = json['p_key'];
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

  Map<String,dynamic> toMap(){
    return {
      "messageId":messageId,
      "message":message,
      "senderId":senderId,
      "groupId":groupId,
      "reply_to":replyTo,
      "created_at":createdAt
    };
  }

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
class DBService{
  Future<Database> database;
  void initDb() async{
    this.database = openDatabase( join(await getDatabasesPath(),'cryptDb.db'),
      onCreate: (db,version) async{
        await db.execute("CREATE TABLE IF NOT EXISTS room (roomId INTEGER,roomName VARCHAR(30),roomType VARCHAR(30),display_name VARCHAR(30),lastMessage INTEGER,UNIQUE(roomId))");
        await db.execute("CREATE TABLE IF NOT EXISTS room_messages (messageId INTEGER,message TEXT,senderId INTEGER,groupId INTEGER,reply_to INTEGER,created_at VARCHAR(20),UNIQUE(messageId))");
        await db.execute("CREATE TABLE IF NOT EXISTS chat_mates (user_Id INTEGER,display_name TEXT,first_name VARCHAR(30),last_name VARCHAR(30),phone VARCHAR(30),email VARCHAR(30),public_key TEXT,UNIQUE(user_id))");
        await db.execute("CREATE TABLE IF NOT EXISTS room_members (user_Id INTEGER,room_id INTEGER,UNIQUE(user_id,room_id))");
      },
      version: 1,
    );
  }
  Future<Set<Room>> getRooms() async{
    Database db = await this.database;
     List<Map<String,dynamic>> rooms = await db.query("room");
     return List.generate(rooms.length,(i){
       return Room(
         roomId:rooms[i]['roomId'].toString(),
         roomName:rooms[i]['roomName'],
         roomType: rooms[i]['roomType'],
         lastMessage: rooms[i]['lastMessage']
       );
     }).toSet();
  }
  Future<void> createRoom(Room room)async{
    Database db = await this.database;
    await db.insert("room", room.toMap(),conflictAlgorithm: ConflictAlgorithm.ignore);
  }
  Future<dynamic> getRoomFromPhone(String phone) async{
    Database db = await this.database;
    List<Map<String,dynamic>> chatmate = await db.query("chat_mates",whereArgs: [phone],where: "phone = ?");
    List<Map<String,dynamic>> echatmate = await db.query("chat_mates",whereArgs: [phone],where: "email = ?");
    if(chatmate.length == 1){
      List<Map<String,dynamic>> rooms = await db.rawQuery("SELECT room.* FROM room INNER JOIN room_members ON room_members.room_id = room.roomId WHERE room_members.user_I = ?",[chatmate[0]['user_Id']]);
      rooms.forEach((element) {if(element['group_type'] == 0){
        return Room.fromJson(element);
      }
      });
      return "no room";
    }
    if(echatmate.length == 1){
      List<Map<String,dynamic>> rooms = await db.rawQuery("SELECT room.* FROM room INNER JOIN room_members ON room_members.room_id = room.roomId WHERE room_members.user_I = ?",[echatmate[0]['user_Id']]);
      rooms.forEach((element) {if(element['group_type'] == 0){
        return Room.fromJson(element);
      }
      });
      return "no room";
    }
    return "no record";
  }
  Future<Set<RoomMessages>> getRoomMessages(int rid) async{
    Database db = await this.database;
    List<Map<String,dynamic>> roomMessages = await db.query("room_messages",where: "groupId = ?",whereArgs: [rid]);
    return List.generate(roomMessages.length,(i){
      return RoomMessages(
          message:roomMessages[i]['message'],
          messageId:roomMessages[i]['messageId'].toString(),
          senderId: roomMessages[i]['senderId'].toString(),
          groupId: roomMessages[i]['groupId'].toString()
      );
    }).toSet();
  }
  Future<void> addRoomMember(ChatMates member,int roomId)async{
    Database db = await this.database;
    await db.insert("chat_mates", member.toMap(),conflictAlgorithm: ConflictAlgorithm.ignore);
    await db.insert("room_members", {"user_id":int.parse(member.userId),"room_id":roomId},conflictAlgorithm: ConflictAlgorithm.ignore);
  }
  Future<Set<ChatMates>> getRoomMembers(int rid)async{
    Database db = await this.database;
    List<Map<String,dynamic>> members = await db.rawQuery("SELECT chat_mates.* from chat_mates LEFT JOIN room_members ON room_members.user_Id = chat_mates.user_Id WHERE room_members.room_Id = ? ",[rid]);
    return Set.from(members.map((e) => ChatMates.fromIJson(e)));
  }
  Future<String> deleteRoomMessages(int rid)async{
    Database db = await this.database;
    await db.delete("room_messages",where: "groupId = ?",whereArgs: [rid]);
    return "Messages deleted";
  }
  Future<String> deleteAllMessages()async{
    Database db = await this.database;
    await db.delete("room_messages");
    return "Messages deleted";
  }
  Future<String> deleteRoom(int rid)async{
    Database db = await this.database;
    await db.delete("room",where: "groupId = ?",whereArgs: [rid]);
    return "Room deleted";
  }
  Future<String> deleteAllRooms()async{
    Database db = await this.database;
    await db.delete("room");
    return "Rooms deleted";
  }
  Future<void> createRoomMessage(RoomMessages roomMessage)async{
    Database db = await this.database;
    await db.insert("room_messages", roomMessage.toMap(),conflictAlgorithm: ConflictAlgorithm.ignore);
  }
}
class Room{
  final String roomId;
  final String roomName;
  final String roomType;
  int lastMessage;
  String displayName;

  Room({this.roomId,this.roomType,this.roomName,this.isNew,this.messages,this.lastMessage});

  List<RoomMessages> messages = [];
  bool isNew = false;
  Set<ChatMates> roomMembers = Set();

  Future<void> setUp() async{
    if(roomMembers.isEmpty){
      DBService dbService = GetIt.I<DBService>();
      roomMembers = await dbService.getRoomMembers(int.parse(roomId));
    }
    if(roomType =="0"){
      // User user = GetIt.I<User>();
      displayName = roomMembers.toList()[0].phone;
    }
  }
  // void fetchChatMembers() async{
  //   DBService dbService = GetIt.I<DBService>();
  //   roomMembers = await dbService.getRoomMembers(int.parse(roomId));
  // }
  void addMessage(RoomMessages message){
    messages.add(message);
  }
  Map<String,dynamic> toMap(){
    return {
      "roomId":roomId,
      "roomName":roomName,
      "roomType":roomType,
      "lastMessage":lastMessage,
      "display_name":displayName
    };
  }
  factory Room.fromJson(Map<String,dynamic> json){
    return Room(
      roomId: json['id'].toString(),
      roomType: json['is_group'].toString(),
      roomName: json['group_name'].toString(),
      messages: json['messages']==null?[]:json['messages'],
      isNew: json['is_new']==null?false:true
    );
  }
}
class ChatMates{
  final String displayName;
  final String firstName;
  final String lastName;
  final String publicKey;
  final String userId;
  final String email;
  final String phone;

  bool isOnline;
  bool isTyping;
  Map<String,dynamic> toMap(){
    return {
      "display_name": displayName,
      "user_id": userId!=null ? int.parse(userId):0,
      "first_name": firstName,
      "last_name": lastName,
      "public_Key": publicKey
    };
  }
  ChatMates({this.displayName,this.firstName,this.lastName,this.userId,this.publicKey,this.phone,this.email});
  factory ChatMates.fromJson(Map<String,dynamic> json){
    return ChatMates(
      displayName: json['display_name'].toString(),
      lastName: json['last_name'].toString(),
      firstName: json['first_name'].toString(),
      userId: json['id'].toString(),
      publicKey: json['p_key'].toString(),
      email:  json['email'],
      phone:  json['phone'],
    );
  }
  factory ChatMates.fromIJson(Map<String,dynamic> json){
    return ChatMates(
      displayName: json['display_name'].toString(),
      lastName: json['last_name'].toString(),
      firstName: json['first_name'].toString(),
      userId: json['user_Id'].toString(),
      publicKey: json['p_key'].toString(),
      email:  json['email'],
      phone:  json['phone'],
    );
  }
}
Map<String,dynamic> userToChatMate(){
  Map<String,dynamic> user = GetIt.I<User>().toJson();
  return user;
}

class SocketService{
  final _socketResponse = StreamController<Map<String,dynamic>>.broadcast();
  // final _roomEvents = StreamController<Map>();
  final user = GetIt.I<User>();
  final dbService = GetIt.I<DBService>();
  IO.Socket socket;
  void Function(Map<String,dynamic>) get addResponse => _socketResponse.sink.add;
  Stream<Map<String,dynamic>> get getResponse => _socketResponse.stream;
  void dispose(){
    _socketResponse.close();
  }
  void getInitialRoomMessages(int roomId) async{
    Set<RoomMessages> messages = await dbService.getRoomMessages(roomId);
    Map<String,dynamic> data = {
      "type":"room messages",
      "room": roomId.toString(),
      "messages": messages
    };
    this.addResponse(data);
  }
  void clearDb() async{
    await dbService.deleteAllMessages();
    await dbService.deleteAllRooms();
  }

  void requestChat(){

  }

  void getInitialRooms() async{
    Set<Room> rooms = await dbService.getRooms();
    Map<String,dynamic> data = {
      "type":"your rooms",
      "rooms": rooms
    };
    this.addResponse(data);
  }
  Map<String,dynamic> userDetails = {
    "user_id":""
  };
  void emitEvent(String eventName,Map<String,dynamic> data){
    this.socket.emit(eventName,jsonEncode(data));
  }
  void connectAndListen(){

    this.socket = IO.io("http://192.168.43.159:2020",OptionBuilder().setTransports(['websocket']).build());
    this.socket.onConnect((_){
      this.socket.emitWithAck('online', jsonEncode({"id":user.gUserId}));
      print("connected");
    });
    this.socket.on('new message',(data){
      data = {
        "type": "room_message",
        "data":data
      };
      this.addResponse(data);
    });
    this.socket.on('your rooms',(dat){
      Map<String,dynamic> data = {
        "type": "your rooms",
        "rooms":List<Room>.from(jsonDecode(dat).map((datum)=>Room.fromJson(datum))),
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
