import 'package:appchatfakezalo/Authenticate/Methods.dart';
import 'package:appchatfakezalo/Screens/ChatRoom.dart';
import 'package:appchatfakezalo/group_chats/group_chat_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  Map<String, dynamic>? userMap;
  bool isLoading = false;
  final TextEditingController _search = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this);
    setStatus("Online");
  }

  void setStatus(String status) async {
    await _firestore.collection('users').doc(_auth.currentUser!.uid).update({
      "status": status,
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // online
      setStatus("Online");
    } else {
      // offline
      setStatus("Offline");
    }
  }

  String chatRoomId(String user1, String user2) {
    if (user1[0].toLowerCase().codeUnits[0] >
        user2.toLowerCase().codeUnits[0]) {
      return "$user1$user2";
    } else {
      return "$user2$user1";
    }
  }

  void onSearch() async {
    FirebaseFirestore _firestore = FirebaseFirestore.instance;

    setState(() {
      isLoading = true;
    });

    await _firestore
        .collection('users')
        .where("email", isEqualTo: _search.text)
        .get()
        .then((value) {
      setState(() {
        userMap = value.docs[0].data();
        isLoading = false;
      });
      print(userMap);
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text("Home Screen"),
        actions: [
          IconButton(icon: Icon(Icons.logout), onPressed: () => logOut(context))
        ],
      ),
      body: isLoading
          ? Center(
              child: Container(
                height: size.height / 20,
                width: size.height / 20,
                child: CircularProgressIndicator(),
              ),
            )
          : Column(
              children: [
                SizedBox(
                  height: size.height / 20,
                ),
                Container(
                  height: size.height / 14,
                  width: size.width,
                  alignment: Alignment.center,
                  child: Container(
                    height: size.height / 15,
                    width: size.width / 1.1,
                    child: Stack(

                      children: [
                        Container(
                          width: size.width / 1.36,
                          child: TextField(
                            controller: _search,
                            style: TextStyle(fontSize: 18),
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.fromLTRB(22, 0, 0, 0),
                              icon: Icon(Icons.search),
                              hintText: "Search",
                              border: OutlineInputBorder(

                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 0.0),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 2, 0, 6),
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: Container(
                                height: size.height / 15,
                                width: size.width / 7,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: Colors.blue,
                                    border: Border.all(
                                      width: 2,
                                      color: Colors.blue,
                                    )
                                ),
                                // margin: EdgeInsets.symmetric(vertical: 4.0),
                                child: ElevatedButton(
                                  onPressed: onSearch,
                                  child: Icon(
                                    Icons.search,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: size.height / 50,
                ),
                // ElevatedButton(
                //   onPressed: onSearch,
                //   child: Text("Search"),
                // ),
                SizedBox(
                  height: size.height / 30,
                ),
                userMap != null
                    ? Container(
                      width: size.width / 1.1,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.grey.shade300,
                        border: Border.all(
                          width: 2,
                          color: Colors.grey.shade300,
                        )
                      ),

                      child: ListTile(
                          onTap: () {
                            String roomId = chatRoomId(
                                _auth.currentUser!.displayName!,
                                userMap!['name']);

                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => ChatRoom(
                                  chatRoomId: roomId,
                                  userMap: userMap!,
                                ),
                              ),
                            );
                          },
                          // tileColor: Colors.grey.shade300,

                          leading: Icon(Icons.account_circle, color: Colors.black, size: 42.0),
                          title: Text(
                            userMap!['name'],
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 17,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          subtitle: Text(userMap!['email']),
                          trailing: Padding(
                            padding: const EdgeInsets.fromLTRB(0, 6, 16, 0),
                            child: Icon(Icons.chat, color: Colors.black),
                          ),
                        ),
                    )
                    : Container(),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.group),
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => GroupChatHomeScreen(),
          ),
        ),
      ),
    );
  }
}
