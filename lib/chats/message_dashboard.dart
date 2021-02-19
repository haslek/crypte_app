import 'package:cryptem_app/chats/message_room_screen.dart';
import 'package:cryptem_app/chats/search_friend_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get_it/get_it.dart';

import '../utils.dart';
class MessageDashboardScreen extends StatefulWidget {
  @override
  _MessageDashboardScreenState createState() => _MessageDashboardScreenState();
}

class _MessageDashboardScreenState extends State<MessageDashboardScreen> {
  final items = List<String>.generate(8, (index) => "$index");
  User user = GetIt.I<User>();
  SocketService socketService = GetIt.instance<SocketService>();
  DBService dbService = GetIt.I<DBService>();
  Set<Room> userRooms = Set();

  @override
  void initState(){
    super.initState();
    socketService.getInitialRooms();
    socketService.connectAndListen();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8.0),
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(80.0),
          child: AppBar(
            // centerTitle: true,
            actions: [
              IconButton(icon: Icon(Icons.cleaning_services),
                onPressed: (){
                  socketService.clearDb();
                },
                tooltip: "Clears all your chats and contacts. use with caution",
              ), Flexible(
                child: IconButton(icon: FaIcon(FontAwesomeIcons.search,color: Colors.white10,),onPressed: null,),
              )
            ],
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: CircleAvatar(
                    backgroundColor: Colors.amberAccent,
                    radius: 20.0,
                  ),
                ),
                Flexible(
                  child: Padding(
                    padding: EdgeInsets.zero,
                    child: Text(user.gDisplayName== null?"Welcome":user.gDisplayName),
                  ),
                ),
              ],
            ),
          ),
        ),
        body: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
              child: Padding(padding: EdgeInsets.all(1),
                child: Center(
                  child: Text("2 online friends"),
                ),
              ),
            ),
            Expanded(
              flex: 3,
                child: Padding(
                  padding: EdgeInsets.all(1.0),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                      itemCount: items.length,
                      itemBuilder: (context,index){
                        return CircleAvatar(
                          backgroundColor: Colors.white,
                          child: Text('${items[index]}'),
                          radius: 40.0,
                        );
                      }
                  ),
                )
            ),
            Expanded(child: Padding(
              padding: EdgeInsets.all(1.0),
              child: Center(
                child: Text("Recent Conversations"),
              ),
            )),
            Expanded(
              flex: 20,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(1, 10, 1, 1),
                    child: StreamBuilder<Map<String,dynamic>>(
                      stream: socketService.getResponse,
                      builder: (context, snapshot) {
                        if(snapshot.hasData){
                          Map<String,dynamic> data = snapshot.data;
                          if(data['type']== "your rooms"){
                            Set<Room> newRooms = Set.from(data['rooms']);
                            newRooms.forEach((room) {dbService.createRoom(room);});
                            userRooms.addAll(newRooms);
                          }
                        }
                        List<Room> builderList = userRooms.toList();
                        return ListView.builder(
                          itemCount: builderList.length,
                          itemBuilder: (context,index){
                            return InkWell(
                              onTap: (){
                                Navigator.push(context, MaterialPageRoute(builder: (context)=>MessageRoomScreen(room: builderList[index],)),);
                              },
                              child: PhysicalModel(
                                shape: BoxShape.rectangle,
                                color: Colors.white60,
                                elevation: 3.0,
                                shadowColor: Colors.black,
                                child: Container(
                                  decoration: BoxDecoration(
                                    // border: Border.all(color: Colors.black12,width: 2.0),
                                    borderRadius: BorderRadius.circular(10)
                                  ),
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      radius: 60,
                                      backgroundColor: Colors.black26,
                                    ),
                                    trailing: Text(builderList[index].roomType),
                                    title: Text(builderList[index].roomName),
                                    subtitle: Text(builderList[index].roomType),
                                  ),
                                ),
                              ),
                            );
                          }
                  );
                      }
                    ),
              )
            )
          ],
        ),
        floatingActionButton: FloatingActionButton(
          child: FaIcon(FontAwesomeIcons.commentMedical),
          onPressed: (){
            Navigator.push(context, MaterialPageRoute(builder: (context)=>RequestChatScreen()));
          },
        ),
      ),
    );
  }
}
