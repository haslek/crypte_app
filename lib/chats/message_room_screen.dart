import 'package:cryptem_app/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

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
  Set<RoomMessages> rMessages = Set();
  String nMessage;
  @override
  void initState(){
    super.initState();
    widget.room.setUp();
    socketService.getInitialRoomMessages(int.parse(widget.room.roomId));
  }
  Future<void> setRoomUp()async{
    await widget.room.setUp();
  }

  @override
  Widget build(BuildContext context) {
    List<ChatMates> chatMates = widget.room.roomMembers.toList();
    String displayName = '';
    if(chatMates.length == 1){
      displayName = chatMates[0].phone;
    }else{
      displayName = widget.room.displayName;
    }
    return Container(
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
                      Map<String,dynamic> data = snapshot.data;
                      if(data['type'] == "room messages" && data['room'] == widget.room.roomId){
                        Set<RoomMessages> newMessages = Set.from(data['messages']);
                        rMessages.addAll(newMessages);
                        newMessages.forEach((roomMessage) {dbService.createRoomMessage(roomMessage);});
                      }
                    }
                    List<RoomMessages> builderList = rMessages.toList();
                    return ListView.builder(
                      itemCount: builderList.length,
                      padding: EdgeInsets.only(top: 10,bottom: 10),
                      itemBuilder: (context,index){
                        return Container(
                          padding: EdgeInsets.only(left: 14,right: 14,top: 10,bottom: 10),
                            child: Align(
                              alignment: builderList[index].senderId== user.gUserId?Alignment.topLeft:Alignment.topRight,
                                child: Container(
                                  padding: EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    color: builderList[index].senderId== user.gUserId?Colors.grey.shade200:Colors.orange.shade400
                                  ),
                                    child: Text(builderList[index].message)
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
                        onPressed: (){
                          RoomMessages newRoomMessage = RoomMessages(message: _textController.text,groupId: widget.room.roomId);
                          if (_textController.text != '') {
                            setState(() {
                              rMessages.add(newRoomMessage);
                              dbService.createRoomMessage(newRoomMessage);
                              // print(newRoomMessage.message);
                              _textController.text = '';
                            });
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
    );
  }
}
