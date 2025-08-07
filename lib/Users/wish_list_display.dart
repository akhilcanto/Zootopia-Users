import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:zootopia/Users/ProductDetailPage.dart';
import 'package:zootopia/Users/function/AppbarZootioia.dart';

class WishlistPage extends StatefulWidget {
  @override
  _WishlistPageState createState() => _WishlistPageState();
}

class _WishlistPageState extends State<WishlistPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late User user;

  @override
  void initState() {
    super.initState();
    user = _auth.currentUser!;
  }

  @override
  Widget build(BuildContext context) {
    final _wishlistCollection = FirebaseFirestore.instance
        .collection('Users')
        .doc(user.uid)
        .collection('wishlist');

    return Scaffold(
      appBar: zootopiaAppBar(),
      body: StreamBuilder<QuerySnapshot>(
        stream: _wishlistCollection.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("Your wishlist is empty"));
          }

          var products = snapshot.data!.docs;

          return GridView.builder(
            padding: EdgeInsets.all(10),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.5,
            ),
            itemCount: products.length,
            itemBuilder: (context, index) {
              var product = products[index] as QueryDocumentSnapshot;

              return GestureDetector(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (context) => ProductDetailsPage(product: product),
                  );
                },
                child: Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 5,
                        child: ClipRRect(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
                          child: product['imageUrl'] != null &&
                              product['imageUrl'].toString().isNotEmpty
                              ? Image.network(
                            product['imageUrl'],
                            width: double.infinity,
                            fit: BoxFit.cover,
                          )
                              : Container(
                            color: Colors.grey.shade300,
                            child: Icon(Icons.image, size: 60),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product['name'] ?? 'Unnamed Product',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Spacer(),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.delete, color: Colors.red),
                                    onPressed: () async {
                                      await _wishlistCollection
                                          .doc(product.id)
                                          .delete();
                                    },
                                  ),
                                  Icon(Icons.favorite, color: Colors.red),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
