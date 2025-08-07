import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:zootopia/Users/AppointmentHistoryPage.dart';
import 'package:zootopia/Users/Edit_Pet.dart';
import 'package:zootopia/Users/Medical_History_Page.dart';
import 'package:zootopia/Users/Tracker.dart';
import 'package:zootopia/Users/function/AppbarZootioia.dart';
import 'package:zootopia/Users/User_Controller/Pet_Contoller.dart';
import 'package:zootopia/Users/VaccinationScreen.dart';

class PetProfile extends StatefulWidget {
  const PetProfile({super.key, required this.PetID});

  final String PetID;

  @override
  State<PetProfile> createState() => _PetProfileState();
}

class _PetProfileState extends State<PetProfile> {
  String? petName;
  String? _petPhoto;
  String? _petAge;
  String? _petGender;
  String? _petBreed;
  String? _petCategory;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchPetInfo();
  }

  void fetchPetInfo() async {
    Map<String, dynamic>? petData = await getPetDetails(widget.PetID);

    setState(() {
      _petAge = calculateAge(petData?['dob']);
      petName = petData?['petName'] ?? "Unknown Pet";
      _petPhoto = petData?['imageUrl'];
      _petGender = petData?['gender'];
      _petBreed = petData?['breed'];
      _petCategory = petData?['petcategory'];
      isLoading = false;
    });
  }


  void confirmDeletePet(String petID) {
    showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(
            title: Text("Delete Pet"),
            content: Text("Are you sure you want to delete this pet?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Cancel"),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(context); // Close the dialog
                  Navigator.pop(context); // Go back to the previous page

                  await deletePet(petID); // Delete the pet from Firestore

                },
                child: Text("Delete", style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );
  }


  String calculateAge(String? dob) {
    if (dob == null || dob.isEmpty) return "Unknown Age";
    try {
      DateTime birthDate = DateFormat("MMM d, yyyy").parse(dob);
      DateTime today = DateTime.now();
      int years = today.year - birthDate.year;
      int months = today.month - birthDate.month;
      if (months < 0) {
        years -= 1;
        months += 12;
      }
      return years > 0 ? "$years years, $months months" : "$months months";
    } catch (e) {
      return "Invalid DOB Format";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Colors.black,
        toolbarHeight: 70,
        title: Image.asset('asset/ZootopiaAppWhite.png', height: 40),
        centerTitle: true,
        actions: [

          IconButton(onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => TrackLocation(PetID: widget.PetID),));
          }, icon: const Icon(Icons.location_pin))
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: Icon(Icons.edit, size: 24, color: Colors.black),
                  onPressed: () async {
                    bool? isUpdated = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            EditPetScreen(petID: widget.PetID),
                      ),
                    );

                    // Refresh pet details only if an update cheythal mathram
                    if (isUpdated == true) {
                      fetchPetInfo();
                    }
                  },
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () => confirmDeletePet(widget.PetID),
                ),

              ],
            ),
            CircleAvatar(
              radius: 60,
              backgroundImage: _petPhoto != null && _petPhoto!.isNotEmpty
                  ? NetworkImage(_petPhoto!)
                  : AssetImage("asset/no-image.png") as ImageProvider,
            ),
            const SizedBox(height: 10),
            Text(
              petName ?? "Loading...",
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              _petAge ?? "Calculating age...",
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 10),
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _infoRow("Gender", _petGender),
                    _infoRow("Category", _petCategory),
                    _infoRow("Breed", _petBreed),
                    _infoRow("Pet ID", widget.PetID)
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                padding: const EdgeInsets.all(10),
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                children: [
                  _gridItem("Vaccination", Icons.medical_services, VaccinationScreen(petId: widget.PetID, petName: petName ?? "Unknown Pet" // If petName is null, pass a default value
                      )),
                  _gridItem("Medical Records", Icons.book,
                      MedicalHistoryPage(petID: widget.PetID)),
                  _gridItem("Appointment  History", Icons.meeting_room,
                      AppointmentHistoryPage(petID: widget.PetID)),

                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          Text(value ?? "N/A",
              style: TextStyle(fontSize: 16, color: Colors.grey[700])),
        ],
      ),
    );
  }

  Widget _actionButton(String label, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: Colors.blueAccent.withOpacity(0.1),
            child: Icon(icon, size: 28, color: Colors.blueAccent),
          ),
          const SizedBox(height: 5),
          Text(label, style: const TextStyle(
              fontSize: 14, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _gridItem(String label, IconData icon, Widget destinationScreen) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => destinationScreen),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.grey[200],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.blueAccent),
            const SizedBox(height: 10),
            Text(label, style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}