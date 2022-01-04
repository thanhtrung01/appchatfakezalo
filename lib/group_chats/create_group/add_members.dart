import 'package:appchatfakezalo/group_chats/create_group/create_group.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AddMembersInGroup extends StatefulWidget {
  const AddMembersInGroup({Key? key}) : super(key: key);

  @override
  State<AddMembersInGroup> createState() => _AddMembersInGroupState();
}

class _AddMembersInGroupState extends State<AddMembersInGroup> {
  final TextEditingController _search = TextEditingController();
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  FirebaseAuth _auth = FirebaseAuth.instance;
  List<Map<String, dynamic>> membersList = [];
  bool isLoading = false;
  Map<String, dynamic>? userMap;

  @override
  void initState() {
    super.initState();
    getCurrentUserDetails();
  }

  void getCurrentUserDetails() async {
    await _firestore
        .collection('users')
        .doc(_auth.currentUser!.uid)
        .get()
        .then((map) {
      setState(() {
        membersList.add({
          "name": map['name'],
          "email": map['email'],
          "uid": map['uid'],
          "isAdmin": true,
        });
      });
    });
  }

  void onSearch() async {
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

  void onResultTap() {
    bool isAlreadyExist = false;

    for (int i = 0; i < membersList.length; i++) {
      if (membersList[i]['uid'] == userMap!['uid']) {
        isAlreadyExist = true;
      }
    }

    if (!isAlreadyExist) {
      setState(() {
        membersList.add({
          "name": userMap!['name'],
          "email": userMap!['email'],
          "uid": userMap!['uid'],
          "isAdmin": false,
        });

        userMap = null;
      });
    }
  }

  void onRemoveMembers(int index) {
    if (membersList[index]['uid'] != _auth.currentUser!.uid) {
      setState(() {
        membersList.removeAt(index);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text("Add Members"),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: ListView.builder(
                itemCount: membersList.length,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      SizedBox(
                        height: size.height / 40,
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                        child: Container(
                          width: size.width,
                          alignment: Alignment.center,
                          child: Container(
                            width: size.width / 1.1,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: Colors.grey.shade300,
                                border: Border.all(
                                  width: 2,
                                  color: Colors.grey.shade300,
                                )
                            ),
                            child: ListTile(
                              onTap: () => onRemoveMembers(index),
                              leading: Icon(Icons.account_circle, size: 42),
                              title: Text(membersList[index]['name']),
                              subtitle: Text(membersList[index]['email']),
                              trailing: Icon(Icons.close),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            SizedBox(
              height: size.height / 20,
            ),
            Container(
              height: size.height / 14,
              width: size.width,
              alignment: Alignment.center,
              child: Container(
                height: size.height / 14,
                width: size.width / 1.1,
                child: Stack(
                  children: [
                    Container(
                      width: size.width / 1.36,
                      child: TextField(
                        controller: _search,
                        decoration: InputDecoration(
                          hintText: "Search",
                          contentPadding: EdgeInsets.fromLTRB(22, 0, 0, 0),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 0.0),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 2, 0, 10),
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

                    // ElevatedButton(
                    //   onPressed: onSearch,
                    //   child: Text("Search"),
                    // )
                  ],
                ),
              ),
            ),
            SizedBox(
              height: size.height / 50,
            ),
            isLoading
                ? Container(
                    height: size.height / 12,
                    width: size.height / 12,
                    alignment: Alignment.center,
                    child: CircularProgressIndicator(),
                  )
                :
                SizedBox()
            // ElevatedButton(
            //         onPressed: onSearch,
            //         child: Text("Search"),
            //       )
            ,
            userMap != null
                ? ListTile(
                    onTap: onResultTap,
                    leading: Icon(Icons.account_box),
                    title: Text(userMap!['name']),
                    subtitle: Text(userMap!['email']),
                    trailing: Icon(Icons.add),
                  )
                : SizedBox(),
          ],
        ),
      ),
      floatingActionButton: membersList.length >= 2
          ? FloatingActionButton(
              child: Icon(Icons.forward),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => CreateGroup(
                    membersList: membersList,
                  ),
                ),
              ),
            )
          : SizedBox(),
    );
  }
}
