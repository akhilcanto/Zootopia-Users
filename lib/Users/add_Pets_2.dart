import 'dart:io';
import 'package:flutter/material.dart';
import 'package:zootopia/Users/add_Pets_3.dart';
import 'package:zootopia/Users/function/AppbarZootioia.dart';

class ChoosePetType extends StatefulWidget {
  final String petName;
  final String dob;
  final String gender;
  final File? petPhoto;

  ChoosePetType(
      {Key? key,
      required this.petName,
      required this.dob,
      required this.gender,
      required this.petPhoto});

  @override
  State<ChoosePetType> createState() => _ChoosePetTypeState();
}

class _ChoosePetTypeState extends State<ChoosePetType> {
  final List<Map<String, String>> petTypes = [
    {'category': 'Dog', 'icon': '🐶'},
    {'category': 'Cat', 'icon': '🐱'},
    {'category': 'Mouse', 'icon': '🐭'},
    {'category': 'Lizard', 'icon': '🦎'},
    {'category': 'Fish', 'icon': '🐟'},
    {'category': 'Ferret', 'icon': '🦦'},
    {'category': 'Chinchilla', 'icon': '🐹'},
    {'category': 'Snake', 'icon': '🐍'},
    {'category': 'Turtle', 'icon': '🐢'},
    {'category': 'Rabbit', 'icon': '🐰'},
    {'category': 'Guinea pig', 'icon': '🐹'},
    {'category': 'Horse', 'icon': '🐴'},
    {'category': 'Donkey', 'icon': '🐴'},
    {'category': 'Pig', 'icon': '🐷'},
    {'category': 'Goat', 'icon': '🐐'},
    {'category': 'Sheep', 'icon': '🐑'},
    {'category': 'Cattle', 'icon': '🐄'},
    {'category': 'Bird', 'icon': '🐦'},
    {'category': 'Chicken', 'icon': '🐔'},
    {'category': 'Duck', 'icon': '🦆'},
  ];

  String searchQuery = '';

  Future<void> _selectPet(BuildContext context,String Category) async {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => petBreed(petcategory: Category, petName: widget.petName, dob: widget.dob, gender: widget.gender, petPhoto: widget.petPhoto),
        ));
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, String>> filteredPets = petTypes
        .where((pet) => pet['category']!.toLowerCase().contains(searchQuery))
        .toList();

    return Scaffold(
      appBar: zootopiaAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: 'Search',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value.toLowerCase().trim();
                });
              },
            ),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.only(bottom: 10),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 15, // Increase spacing
                  mainAxisSpacing: 15,
                  childAspectRatio: 1.2, // Adjust aspect ratio for uniform spacing
                ),
                itemCount: filteredPets.length,
                itemBuilder: (context, index) {
                  final pet = filteredPets[index];
                  return GestureDetector(
                    onTap: () => _selectPet(context, pet['category']!), // Pass pet category
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.black,
                          child: Text(
                            pet['icon']!,
                            style: const TextStyle(fontSize: 30),
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          pet['category']!,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
