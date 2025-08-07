import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class PetCard extends StatelessWidget {
  final String petName;
  final String description;
  final String imageUrl;
  final double price;
  final double rating;
  final bool isFavorite;

  const PetCard({
    Key? key,
    required this.petName,
    required this.description,
    required this.imageUrl,
    required this.price,
    required this.rating,
    this.isFavorite = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Row(
          children: [
            // Pet Image
            ClipRRect(
              borderRadius: BorderRadius.circular(40),
              child: imageUrl.isEmpty
                  ? Image.asset(
                'asset/no-image.png',
                width: 150,
                height: 150,
                fit: BoxFit.cover,
              )
                  : Image.network(
                imageUrl,
                width: 150,
                height: 150,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Image.asset(
                    'asset/default_pet.png',
                    width: 150,
                    height: 150,
                    fit: BoxFit.cover,
                  );
                },
              ),
            ),
            const SizedBox(width: 12),

            // Pet Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    petName,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    description,
                    style: TextStyle(fontSize: 14, color: Colors.grey),
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
