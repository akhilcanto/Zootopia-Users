import 'package:flutter/material.dart';


AppBar DocAppBar() {
  return AppBar(
    iconTheme: IconThemeData(color: Colors.white),
    backgroundColor: Colors.black,
    toolbarHeight: 70,
    title: Image.asset('asset/Doctor/DocAppbar_black_bg.png', height: 30),
    centerTitle: true,
    // actions: [
    //   PopupMenuButton(
    //     icon: Icon(Icons.notifications),
    //     itemBuilder: (context) => [
    //       PopupMenuItem(
    //         child: Text("hi"),
    //         value: 1,
    //       )
    //     ],
    //   ),
    // ]

  );
}
