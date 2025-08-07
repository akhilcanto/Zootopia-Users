import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:zootopia/Users/List_Doctors_Users.dart';
import 'package:zootopia/Users/function/AppbarZootioia.dart';

class HospitalListScreen extends StatefulWidget {
  @override
  _HospitalListScreenState createState() => _HospitalListScreenState();
}

class _HospitalListScreenState extends State<HospitalListScreen> {
  String searchQuery = "";
  List<Map<String, String>> hospitals = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchHospitals();
  }

  Future<void> fetchHospitals() async {
    setState(() {
      isLoading = true;
      hospitals.clear();
    });

    QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection("Hospital").get();

    List<Map<String, String>> hospitalList = querySnapshot.docs.map((doc) {
      return {
        "id": doc.id,
        "name": doc["hospitalname"]?.toString() ?? "Unknown",
        "district": doc["district"]?.toString() ?? "Unknown",
        "state": doc["state"]?.toString() ?? "Unknown",
        "city": doc["city"]?.toString() ?? "Unknown",
        "description": doc["description"]?.toString() ?? "No description available",
        "imageUrl": doc["imageUrl"]?.toString() ?? "",
      };
    }).toList();

    setState(() {
      hospitals = hospitalList;
      isLoading = false;
    });
  }

  List<Map<String, String>> getFilteredHospitals() {
    String query = searchQuery.trim().toLowerCase();
    return hospitals.where((hospital) {
      return hospital["name"]!.toLowerCase().contains(query) ||
          hospital["district"]!.toLowerCase().contains(query) ||
          hospital["state"]!.toLowerCase().contains(query) ||
          hospital["city"]!.toLowerCase().contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: zootopiaAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Search by State, District, City, or Hospital Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[100],
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
            ),
            SizedBox(height: 20),
            Expanded(
              child: Stack(
                children: [
                  ListView.builder(
                    itemCount: getFilteredHospitals().length,
                    itemBuilder: (context, index) {
                      var hospital = getFilteredHospitals()[index];

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => DoctorListScreen(
                                    hospitalId: hospital['id']!,
                                  )));
                        },
                        child: Card(
                            elevation: 4,
                            margin: EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: hospital["imageUrl"]!.isNotEmpty
                                        ? FadeInImage.assetNetwork(
                                      placeholder: "asset/Hospital/Loading_photo.png",
                                      image: hospital["imageUrl"]!,
                                      width: 120,
                                      height: 100,
                                      fit: BoxFit.cover,
                                      imageErrorBuilder: (context, error, stackTrace) =>
                                          Icon(Icons.broken_image, size: 50, color: Colors.grey),
                                    )
                                        : Image.asset(
                                      "asset/Hospital/no_image.png",
                                      width: 120,
                                      height: 100,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  SizedBox(width: 15),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          hospital['name']!,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                          ),
                                        ),
                                        SizedBox(height: 5),
                                        Text(
                                          "${hospital['district']!}, ${hospital['state']!}",
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                        SizedBox(height: 5),
                                        Text(
                                          hospital['description']!,
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                        SizedBox(height: 10),
                                        Align(
                                          alignment: Alignment.centerRight,
                                          child: IconButton(
                                            icon: Icon(Icons.info_outline, color: Colors.blue),
                                            onPressed: () {
                                              // Navigate to details page
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            )),
                      );
                    },
                  ),
                  if (isLoading)
                    Center(
                      child: Container(
                        color: Colors.white.withOpacity(0.8),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
