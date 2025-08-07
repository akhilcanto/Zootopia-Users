import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zootopia/Starting/userSelection.dart';
import 'package:zootopia/Users/Login_Page.dart';
import 'package:zootopia/Users/OrderHistoryPage.dart';
import 'package:zootopia/Users/Session.dart';
import 'package:zootopia/Users/profile_page.dart';
import 'package:zootopia/Users/wish_list_display.dart';

class MyDrawer extends StatefulWidget {
  @override
  _MyDrawerState createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  String? _userEmail = "Loading...";
  String? _userName = "User";
  String? _userPhoto;

  @override
  void initState() {
    super.initState();
    _loadUserSession();
  }

  Future<void> _loadUserSession() async {
    Map<String, String?> sessionData = await SessionUser.getSession();
    Map<String, dynamic>? userDetails = await SessionUser.getUserDetails();

    setState(() {
      _userName = userDetails ?['name'] ?? "Unknown User";
      _userEmail = sessionData['email'] ?? "No Email Found";
      _userPhoto = sessionData['imageUrl'] ?? ""; // Get image from shared preferences
    });
  }


  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(_userName!),
            accountEmail: Text(_userEmail!),
            currentAccountPicture: CircleAvatar(
              backgroundImage: _userPhoto != null && _userPhoto!.isNotEmpty
                  ? NetworkImage(_userPhoto!)
                  : AssetImage("asset/kitty-cat-kitten-pet-45201.jpeg") as ImageProvider,
            ),
            decoration: BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.horizontal(
                right: Radius.circular(30),
              ),
            ),
          ), ListTile(
            leading: Icon(Icons.favorite, color: Colors.red),
            title: Text(
              "Wish List",
              style: TextStyle(color: Colors.black),
            ),
            onTap: () async {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => WishlistPage()),
              );
            },
          ),

          ListTile(
            leading: Icon(Icons.person, color: Colors.red),
            title: Text(
              "Profile",
              style: TextStyle(color: Colors.black),
            ),
            onTap: () async {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfilePage()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.shopping_bag, color: Colors.red),
            title: Text(
              "Orders",
              style: TextStyle(color: Colors.black),
            ),
            onTap: () async {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => OrderHistoryPage()),
              );
            },
          ),

          ListTile(
            leading: Icon(Icons.logout, color: Colors.red),
            title: Text(
              "Logout",
              style: TextStyle(color: Colors.black),
            ),
            onTap: () async {
              SessionUser.clearSession();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => Userselection()),
              );
            },
          ),

        ],
      ),
    );
  }
}

