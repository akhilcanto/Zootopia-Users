import 'package:flutter/material.dart';
import 'package:zootopia/Users/ChatListing.dart';
import 'package:zootopia/Users/Shoping_Page.dart';
import 'package:zootopia/Users/pets_Home_Page.dart';
import 'package:zootopia/Users/QR.dart';
import 'package:zootopia/Users/View_Hospitals.dart';
import 'package:zootopia/Users/profile_page.dart';
class Bottomnavbar extends StatefulWidget {
  final int initialIndex;
  const Bottomnavbar({super.key, this.initialIndex = 0});

  @override
  State<Bottomnavbar> createState() => _BottomnavBarState();
}

class _BottomnavBarState extends State<Bottomnavbar> {
  late int _selectedindex;

  @override
  void initState() {
    super.initState();
    _selectedindex = widget.initialIndex; // Set the initial index
  }

  final List<Widget> _pages = [
    // Home(),
    // Notifications(),
    // ChatList(),
    // ChatScreen
    PetsPage(),
    Products(),
    QRCode(),
    HospitalListScreen(),
    ChatListScreen(),
    // const ProfilePage(),
    // SearchCompanyPage()
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedindex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedindex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedindex,
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.white60,
        backgroundColor: Colors.black,
        type: BottomNavigationBarType.fixed,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_bag), label: 'Shopping'),
          BottomNavigationBarItem(icon: Icon(Icons.qr_code), label: 'QR'),
          BottomNavigationBarItem(icon: Icon(Icons.local_hospital), label: 'Hospitals'),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chat'),
          // BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
