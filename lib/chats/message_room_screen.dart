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
  SocketService socketService = GetIt.instance<SocketService>();
  final _textController = TextEditingController();
  List<RoomMessages> rMessages = [];
  String nMessage;
  @override
  void initState(){
    super.initState();
    rMessages = widget.room.messages;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8.0),
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(100),
          child: AppBar(
            centerTitle: true,
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
                      if(data['type'] == "room messages" && data['room_id'] == widget.room.roomId){
                        rMessages.addAll(data['messages']);
                      }
                    }
                    return ListView.builder(
                      itemCount: rMessages.length,
                      itemBuilder: (context,index){
                        return Text(rMessages[index].message);
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
                          setState(() {
                            rMessages.add(newRoomMessage);
                            // print(newRoomMessage.message);
                            _textController.text = '';
                          });
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
