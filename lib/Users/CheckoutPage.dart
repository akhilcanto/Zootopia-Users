// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
//
// class AddressInputPage extends StatefulWidget {
//   @override
//   _AddressInputPageState createState() => _AddressInputPageState();
// }
//
// class _AddressInputPageState extends State<AddressInputPage> {
//   final _formKey = GlobalKey<FormState>();
//   TextEditingController nameController = TextEditingController();
//   TextEditingController phoneController = TextEditingController();
//   TextEditingController streetController = TextEditingController();
//   TextEditingController postalCodeController = TextEditingController();
//   TextEditingController countryController = TextEditingController();
//
//   String? selectedState;
//   String? selectedDistrict;
//   String? selectedCity;
//
//   List<String> states = [];
//   List<String> districts = [];
//   List<String> cities = [];
//
//   @override
//   void initState() {
//     super.initState();
//     fetchStates();
//   }
//
//   /// Fetch States from Firestore
//   Future<void> fetchStates() async {
//     FirebaseFirestore.instance.collection('locations').get().then((snapshot) {
//       List<String> stateList = snapshot.docs.map((doc) => doc.id).toList();
//       setState(() {
//         states = stateList;
//       });
//     });
//   }
//
//   /// Fetch Districts when a State is selected
//   Future<void> fetchDistricts(String state) async {
//     FirebaseFirestore.instance.collection('locations').doc(state).get().then((doc) {
//       if (doc.exists && doc.data()!.containsKey('districts')) {
//         var districtData = doc['districts'];
//
//         List<String> districtList = [];
//
//         // Check if districts is a map or a list
//         if (districtData is Map<String, dynamic>) {
//           districtList = districtData.keys.toList();  // Convert map keys to a list
//         } else if (districtData is List<dynamic>) {
//           districtList = List<String>.from(districtData);
//         }
//
//         setState(() {
//           districts = districtList;
//           selectedDistrict = null;
//           cities = [];
//         });
//
//       } else {
//         print("No districts found for state: $state");
//         setState(() {
//           districts = [];
//           selectedDistrict = null;
//           cities = [];
//         });
//       }
//     }).catchError((error) {
//       print("Error fetching districts: $error");
//     });
//   }
//
//
//   /// Fetch Cities when a District is selected
//   Future<void> fetchCities(String state, String district) async {
//     FirebaseFirestore.instance.collection('locations').doc(state).get().then((doc) {
//       if (doc.exists && doc.data()!.containsKey('districts')) {
//         var districtData = doc['districts'];
//
//         if (districtData is Map<String, dynamic> && districtData.containsKey(district)) {
//           var cityList = districtData[district];
//
//           setState(() {
//             cities = List<String>.from(cityList);
//             selectedCity = null;
//           });
//         } else {
//           print("No cities found for district: $district");
//           setState(() {
//             cities = [];
//             selectedCity = null;
//           });
//         }
//       } else {
//         print("No districts found for state: $state");
//         setState(() {
//           cities = [];
//           selectedCity = null;
//         });
//       }
//     }).catchError((error) {
//       print("Error fetching cities: $error");
//     });
//   }
//
//
//   /// Save Address to Firestore
//   void saveAddress() {
//     if (_formKey.currentState!.validate() && selectedState != null && selectedDistrict != null && selectedCity != null) {
//       FirebaseFirestore.instance.collection('addresses').add({
//         'name': nameController.text,
//         'phone': phoneController.text,
//         'street': streetController.text,
//         'postalCode': postalCodeController.text,
//         'country': countryController.text,
//         'state': selectedState,
//         'district': selectedDistrict,
//         'city': selectedCity,
//       });
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Address Saved!')));
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Enter Address")),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Form(
//           key: _formKey,
//           child: ListView(
//             children: [
//               TextFormField(
//                 controller: nameController,
//                 decoration: InputDecoration(labelText: "Full Name",border: OutlineInputBorder(borderRadius: BorderRadius.circular(25))),
//                 validator: (value) => value!.isEmpty ? "Enter Name" : null,
//               ),
//               TextFormField(
//                 controller: phoneController,
//                 decoration: InputDecoration(labelText: "Phone Number"),
//                 keyboardType: TextInputType.phone,
//                 validator: (value) => value!.isEmpty ? "Enter Phone Number" : null,
//               ),
//               TextFormField(
//                 controller: streetController,
//                 decoration: InputDecoration(labelText: "Street Address"),
//                 validator: (value) => value!.isEmpty ? "Enter Street Address" : null,
//               ),
//
//               /// State Dropdown
//               DropdownButtonFormField(
//                 value: selectedState,
//                 hint: Text("Select State"),
//                 isExpanded: true,
//                 items: states.map((state) {
//                   return DropdownMenuItem(
//                     value: state,
//                     child: Text(state),
//                   );
//                 }).toList(),
//                 onChanged: (value) {
//                   if (value != null) {
//                     setState(() {
//                       selectedState = value;
//                       selectedDistrict = null;
//                       selectedCity = null;
//                       districts = [];
//                       cities = [];
//                     });
//                     fetchDistricts(value);
//                   }
//                 },
//               ),
//
//               SizedBox(height: 10),
//
//               /// District Dropdown
//               DropdownButtonFormField(
//                 value: selectedDistrict,
//                 hint: Text("Select District"),
//                 isExpanded: true,
//                 items: districts.map((district) {
//                   return DropdownMenuItem(
//                     value: district,
//                     child: Text(district),
//                   );
//                 }).toList(),
//                 onChanged: (value) {
//                   if (value != null) {
//                     setState(() {
//                       selectedDistrict = value;
//                       selectedCity = null;
//                       cities = [];
//                     });
//                     if (selectedState != null) {
//                       fetchCities(selectedState!, value);
//                     }
//                   }
//                 },
//               ),
//
//               SizedBox(height: 10),
//
//               /// City Dropdown
//               DropdownButtonFormField(
//                 value: selectedCity,
//                 hint: Text("Select City"),
//                 isExpanded: true,
//                 items: cities.map((city) {
//                   return DropdownMenuItem(
//                     value: city,
//                     child: Text(city),
//                   );
//                 }).toList(),
//                 onChanged: (value) {
//                   if (value != null) {
//                     setState(() {
//                       selectedCity = value;
//                     });
//                   }
//                 },
//               ),
//
//               SizedBox(height: 10),
//
//               TextFormField(
//                 controller: postalCodeController,
//                 decoration: InputDecoration(labelText: "Postal Code"),
//                 keyboardType: TextInputType.number,
//                 validator: (value) => value!.isEmpty ? "Enter Postal Code" : null,
//               ),
//               TextFormField(
//                 controller: countryController,
//                 decoration: InputDecoration(labelText: "Country"),
//                 validator: (value) => value!.isEmpty ? "Enter Country" : null,
//               ),
//
//               SizedBox(height: 20),
//
//               ElevatedButton(
//                 onPressed: saveAddress,
//                 child: Text("Save Address"),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zootopia/Users/Payment.dart';
import 'package:zootopia/Users/function/AppbarZootioia.dart';

class CheckoutPage extends StatefulWidget {
  final double totalAmount;
  final List<Map<String, dynamic>> cartProducts;

  const CheckoutPage({required this.totalAmount, required this.cartProducts});

  @override
  _CheckoutPageState createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  User? _currentUser = FirebaseAuth.instance.currentUser;
  String? selectedAddressId;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _zipController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _landmarkController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  Stream<QuerySnapshot> _getUserAddresses() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return const Stream.empty(); // Return an empty stream if user is not logged in

    return FirebaseFirestore.instance
        .collection('Users')
        .doc(user.uid)
        .collection('Addresses') // Fetch from the user's addresses subcollection
        .orderBy('timestamp', descending: true) // Order addresses by latest added
        .snapshots();
  }


  void _confirmOrder() {
    if (selectedAddressId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please select an address")),
      );
      return;
    }

    // Fetch the selected address details
    FirebaseFirestore.instance
        .collection('Users')
        .doc(_currentUser!.uid)
        .collection('Addresses')
        .doc(selectedAddressId)
        .get()
        .then((doc) {
      if (doc.exists) {
        Map<String, String> shippingAddress = {
          'name': doc['name'] ?? '',
          'address': doc['address'] ?? '',
          'city': doc['city'] ?? '',
          'state': doc['state'] ?? '',
          'zip': doc['zip'] ?? '',
          'country': doc['country'] ?? '',
          'landmark': doc['landmark'] ?? '',
          'phone': doc['phone'] ?? '',
          'amount': widget.totalAmount.toString(),
          'email': _currentUser!.email ?? '',
        };

        // Navigate to the PaymentScreen with correct data
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PaymentScreen(
              shippingAddress: shippingAddress, cartProducts: widget.cartProducts,
              // productIds: widget.productIds,
            ),
          ),
        );
      }
    });
  }

  void _addNewAddress() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return SingleChildScrollView(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Add New Address", style: GoogleFonts.lora(fontSize: 22, fontWeight: FontWeight.bold)),
                SizedBox(height: 16),
                _buildTextField(_nameController, "Full Name"),
                _buildTextField(_addressController, "Address"),
                _buildTextField(_cityController, "City"),
                _buildTextField(_stateController, "State"),
                _buildTextField(_zipController, "ZIP Code"),
                _buildTextField(_countryController, "Country"),
                _buildTextField(_landmarkController, "Landmark (optional)"),
                _buildTextField(_phoneController, "Phone Number"),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _saveAddress,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      "Save Address",
                      style: GoogleFonts.lora(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  void _saveAddress() async {
    if (_nameController.text.isEmpty ||
        _addressController.text.isEmpty ||
        _cityController.text.isEmpty ||
        _stateController.text.isEmpty ||
        _zipController.text.isEmpty ||
        _countryController.text.isEmpty ||
        _phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please fill all required fields")),
      );
      return;
    }

    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("User not logged in")),
      );
      return;
    }

    // Reference to the user's address subcollection
    CollectionReference addressRef = FirebaseFirestore.instance
        .collection('Users')
        .doc(user.uid)
        .collection('Addresses');

    await addressRef.add({
      'name': _nameController.text,
      'address': _addressController.text,
      'city': _cityController.text,
      'state': _stateController.text,
      'zip': _zipController.text,
      'country': _countryController.text,
      'landmark': _landmarkController.text.isNotEmpty ? _landmarkController.text : null, // Avoid storing empty values
      'phone': _phoneController.text,
      'timestamp': FieldValue.serverTimestamp(), // For sorting addresses
    });

    // Clear controllers
    _nameController.clear();
    _addressController.clear();
    _cityController.clear();
    _stateController.clear();
    _zipController.clear();
    _countryController.clear();
    _landmarkController.clear();
    _phoneController.clear();

    Navigator.pop(context); // Close the bottom sheet
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: zootopiaAppBar(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Select Address:", style: GoogleFonts.lora(fontSize: 18, fontWeight: FontWeight.bold)),
                TextButton(
                  onPressed: _addNewAddress,
                  child: Text("+ Add New", style: GoogleFonts.lora(color: Colors.red, fontSize: 16)),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _getUserAddresses(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text("No saved addresses. Add one first."));
                }

                var addresses = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: addresses.length,
                  itemBuilder: (context, index) {
                    var address = addresses[index];
                    return Card(
                      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      elevation: 2,
                      child: RadioListTile(
                        title: Text(address['name'], style: GoogleFonts.lora(fontWeight: FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("${address['address']}, ${address['city']}"),
                            Text("${address['state']}, ${address['zip']}"),
                            Text("${address['country']}"),
                            if (address['landmark'] != null && address['landmark'].isNotEmpty)
                              Text("Landmark: ${address['landmark']}"),
                            Text("Phone: ${address['phone']}"),
                          ],
                        ),
                        value: address.id,
                        groupValue: selectedAddressId,
                        onChanged: (value) {
                          setState(() {
                            selectedAddressId = value as String?;
                          });
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Total: ₹${widget.totalAmount.toStringAsFixed(2)}",
                    style: GoogleFonts.lora(fontSize: 22, fontWeight: FontWeight.bold)),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _confirmOrder,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      "Proceed to Payment",
                      style: GoogleFonts.lora(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
