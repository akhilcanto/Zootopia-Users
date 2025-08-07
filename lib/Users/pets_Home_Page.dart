import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:zootopia/Users/Notification_page.dart';
import 'package:zootopia/Users/Pet_Card.dart';
import 'package:zootopia/Users/function/AppbarZootioia.dart';
import 'package:zootopia/Users/function/DrawerBar.dart';
import 'package:zootopia/Users/pet_Profile.dart';
import 'package:zootopia/Users/add_Pets_1.dart';

class PetsPage extends StatefulWidget {
  const PetsPage({super.key});

  @override
  State<PetsPage> createState() => _PetsPageState();
}

class _PetsPageState extends State<PetsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

       drawer: MyDrawer(),
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Colors.black,
        toolbarHeight: 70,
        title: Image.asset('asset/ZootopiaAppWhite.png', height: 40),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) =>  VaccinationNotifications()),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => PetName()),
          );
        },
        backgroundColor: Colors.grey,
        child: const Icon(
          Icons.add,
          color: Colors.black,
          size: 40,
        ),
      ),
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, userSnapshot) {
          if (userSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!userSnapshot.hasData || userSnapshot.data == null) {
            return const Center(child: Text("User not logged in"));
          }

          String userId = userSnapshot.data!.uid; // Current user's UID

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('Pets_details')
                .where('ownerID', isEqualTo: userId) // Filter by user ID
                .orderBy('createdAt', descending: true) // Ensure correct ordering
                .snapshots(),
            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text("No pet data available."));
              }

              var petDocs = snapshot.data!.docs;

              return ListView.builder(
                itemCount: petDocs.length,
                itemBuilder: (context, index) {
                  var pet = petDocs[index].data() as Map<String, dynamic>?;

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PetProfile(PetID: petDocs[index].id),
                        ),
                      );
                    },
                    child: PetCard(
                      petName: pet?['petName'] ?? 'Unknown Pet',
                      description: pet?['petdescription']?? 'Adorable and friendly!',
                      imageUrl: pet?['imageUrl'] ?? '',
                      price: 75, // Hardcoded, consider removing if unused
                      rating: 3.5,
                      isFavorite: true,
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
//
// class ZootopiaAppBara extends StatefulWidget implements PreferredSizeWidget {
// @override
// _ZootopiaAppBaraState createState() => _ZootopiaAppBaraState();
//
// @override
// Size get preferredSize => const Size.fromHeight(70);
// }
//
// class _ZootopiaAppBaraState extends State<ZootopiaAppBara> {
//   int notificationCount = 0;
//   List<Map<String, dynamic>> notifications = [];
//
//   @override
//   void initState() {
//     super.initState();
//     _fetchNotifications();
//   }
//
//   // Fetch only today's and tomorrow's vaccinations
//   void _fetchNotifications() {
//     String petId = "pet_123"; // Replace with the actual pet ID
//     DateTime now = DateTime.now();
//     DateTime todayStart = DateTime(now.year, now.month, now.day); // Start of today
//     DateTime tomorrowEnd = todayStart.add(Duration(days: 1, hours: 23, minutes: 59, seconds: 59)); // End of tomorrow
//
//     FirebaseFirestore.instance
//         .collection('pets')
//         .doc(petId)
//         .collection('vaccinations')
//         .where('dueDate', isGreaterThanOrEqualTo: todayStart.toIso8601String()) // From today
//         .where('dueDate', isLessThanOrEqualTo: tomorrowEnd.toIso8601String()) // Until tomorrow
//         .orderBy('dueDate', descending: false)
//         .snapshots()
//         .listen((snapshot) {
//       setState(() {
//         notifications = snapshot.docs.map((doc) {
//           var data = doc.data();
//           return {
//             'vaccineName': data['vaccineName'],
//             'dueDate': data['dueDate'].split("T")[0], // Extract date
//           };
//         }).toList();
//         notificationCount = notifications.length;
//       });
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return AppBar(
//       iconTheme: const IconThemeData(color: Colors.white),
//       backgroundColor: Colors.black,
//       toolbarHeight: 70,
//       title: Image.asset('asset/ZootopiaAppWhite.png', height: 40),
//       centerTitle: true,
//       actions: [
//         Stack(
//           children: [
//             PopupMenuButton(
//               icon: const Icon(Icons.notifications),
//               itemBuilder: (context) {
//                 return notifications.isEmpty
//                     ? [const PopupMenuItem(child: Text("No new notifications"))]
//                     : notifications.map((notif) {
//                   return PopupMenuItem(
//                     child: ListTile(
//                       title: Text(notif['vaccineName']),
//                       subtitle: Text('Due on: ${notif['dueDate']}'),
//                     ),
//                   );
//                 }).toList();
//               },
//             ),
//             if (notificationCount > 0)
//               Positioned(
//                 right: 12,
//                 top: 12,
//                 child: Container(
//                   padding: const EdgeInsets.all(4),
//                   decoration: const BoxDecoration(
//                     color: Colors.red,
//                     shape: BoxShape.circle,
//                   ),
//                   constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
//                   child: Text(
//                     '$notificationCount',
//                     style: const TextStyle(color: Colors.white, fontSize: 12),
//                     textAlign: TextAlign.center,
//                   ),
//                 ),
//               ),
//           ],
//         ),
//       ],
//     );
//   }
// }
