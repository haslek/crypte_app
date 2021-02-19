import 'dart:async';

import 'package:cryptem_app/utils.dart';
import 'package:encrypt/encrypt.dart' as encryption_lib;
import 'package:encrypt/encrypt_io.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MessageRoomScreen extends StatefulWidget {
  MessageRoomScreen({Key key,@required this.room}) : super(key: key);
  final Room room;
  @override
  _MessageRoomScreenState createState() => _MessageRoomScreenState();
}

class _MessageRoomScreenState extends State<MessageRoomScreen> {
  Set<ChatMates> members;
  SocketService socketService = GetIt.instance<SocketService>();
  DBService dbService = GetIt.I<DBService>();
  User user = GetIt.I<User>();
  final _textController = TextEditingController();
  // Set<RoomMessages> rMessages = Set();
  List<RoomMessages> rMessages = [];
  String nMessage;
  String roomPubKey;
  String displayName;
  final parser = encryption_lib.RSAKeyParser();
  bool roomSet = false;
  bool iJustTyped = false;
  encryption_lib.Encrypter decrypter;
  ScrollController _scrollController = new ScrollController();

  @override
  void initState(){
    super.initState();
    setRoomUp();
    print("setting up");
    socketService.getInitialRoomMessages(int.parse(widget.room.roomId));
  }
  Future<void> setRoomUp()async{
    String privKey;
    if(widget.room.roomType == "0"){
      privKey = await getPrivKey();
    }else{
      privKey = widget.room.privateKey;
    }
    // print("private key: "+privKey);
    final privateKey = parser.parse(privKey);
    Set<ChatMates> roomMembers = await dbService.getRoomMembers(int.parse(widget.room.roomId));
    setState(() {
      widget.room.roomMembers = roomMembers;
      List<ChatMates> chatMates = widget.room.roomMembers.toList();
      print("room iden: ");
      print(widget.room.toMap());
      print("num chats: ");
      print(chatMates.length);
      if(chatMates.length == 1){
        displayName = chatMates[0].phone;
        roomPubKey = chatMates[0].publicKey;
        print("room pub: "+roomPubKey);
      }else{
        displayName = widget.room.displayName;
        roomPubKey = widget.room.publicKey;
      }
      widget.room.roomMembers = roomMembers;
      decrypter = encryption_lib.Encrypter(encryption_lib.RSA(privateKey: privateKey));
      roomSet = true;

    });
  }
  Future<String> getPrivKey()async{
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("pKey");
  }
  String decryptMessage(RoomMessages message){
    return decrypter.decrypt64(message.message);
  }
  Future<void> sendMessage(String messageText)async{
    final myPubKey = parser.parse(user.gPubKey);
    final groupPubKey = parser.parse(roomPubKey);
    final encrypter =  encryption_lib.Encrypter(encryption_lib.RSA(publicKey: myPubKey));
    final roomEncrypter = encryption_lib.Encrypter(encryption_lib.RSA(publicKey: groupPubKey));
    final encryptedText = encrypter.encrypt(messageText);
    final roomEncryptedText = roomEncrypter.encrypt(messageText);
    RoomMessages newRoomMessage = RoomMessages(message: roomEncryptedText.base64,groupId: widget.room.roomId,senderId: user.gUserId,);
    RoomMessages mNewRoomMessage = RoomMessages(message: encryptedText.base64,groupId: widget.room.roomId,senderId: user.gUserId,);
    socketService.emitEvent("new message", {"group_name":widget.room.roomName,
      "message":newRoomMessage.toiMap(),
      "for_me":mNewRoomMessage.toiMap(),
      "group_id":widget.room.roomId});
    iJustTyped = true;
  }
  
  @override
  Widget build(BuildContext context) {
    // if (!roomSet) {
    //   setRoomUp();
    // }
    return WillPopScope(
      onWillPop: ()=> Navigator.popAndPushNamed(context, "/message_dash"),
      child: Container(
        padding: EdgeInsets.all(8.0),
        child: Scaffold(
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(100),
            child: AppBar(
              centerTitle: true,
              title: Text(displayName==null?"Welcome ":displayName),
              // flexibleSpace: ,
            ),
          ),
          body: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: StreamBuilder<Map<String,dynamic>>(
                    stream: socketService.getResponse,
                    builder: (context, snapshot) {
                      if(snapshot.hasData){
                        print("I got data");
                        Map<String,dynamic> data = snapshot.data;
                        print(data);
                        if(data['type'] == "room messages" && data['room'] == widget.room.roomId){
                          Set<RoomMessages> newMessages = Set.from(data['messages']);
                          // rMessages.addAll(newMessages);
                          newMessages.forEach((roomMessage) {
                            rMessages.insert(0, roomMessage);
                            // dbService.createRoomMessage(roomMessage);
                          });
                        }
                      }
                      // List<RoomMessages> builderList = rMessages.toList();
                      return ListView.builder(
                        itemCount: rMessages.length,
                        shrinkWrap: true,
                        reverse: true,
                        controller: _scrollController,
                        padding: EdgeInsets.only(top: 10,bottom: 10),
                        itemBuilder: (context,index){
                          return Container(
                            padding: EdgeInsets.only(left: 14,right: 14,top: 10,bottom: 10),
                              child: Align(
                                alignment: rMessages[index].senderId != user.gUserId?Alignment.topLeft:Alignment.topRight,
                                  child: Container(
                                    padding: EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      color: rMessages[index].senderId != user.gUserId?Colors.grey.shade200:Colors.orange.shade400
                                    ),
                                      child: Text(decryptMessage(rMessages[index])),
                                  ),
                              )
                          );
                        },
                      );
                    }
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(child: TextField(
                          controller: _textController,
                          maxLines: 10,
                          minLines: 1,
                          decoration: InputDecoration(
                            hintText: "Type your message..",
                            border: OutlineInputBorder(),
                            suffixIcon: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                    icon: Icon(Icons.camera_alt_outlined),
                                  onPressed: (){

                                  },
                                ),
                                IconButton(
                                  icon: Icon(Icons.attach_file),
                                  onPressed: (){

                                  },
                                ),
                              ],
                            )
                          ),
                        )),
                        RawMaterialButton(
                          onPressed: () async{
                            if (_textController.text != '') {
                              await sendMessage(_textController.text);

                                _textController.text = '';
                            }
                          },
                          elevation: 2.0,
                          fillColor: Colors.grey,
                          child: Icon(Icons.send),
                          shape: CircleBorder(),
                          padding: EdgeInsets.all(10.0),
                          // materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
