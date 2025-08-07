import 'package:flutter/material.dart';


AppBar careAppBar() {
  return AppBar(
    iconTheme: IconThemeData(color: Colors.white),
    backgroundColor: Colors.black,
    toolbarHeight: 70,
    title: Image.asset('asset/Hospital/zootopiacare+appbar.png', height: 35),
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
