import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:zootopia/Users/Cart.dart';
import 'package:zootopia/Users/ProductDetailPage.dart';
import 'package:zootopia/Users/wish_list_display.dart';

class Products extends StatefulWidget {
  @override
  _ProductsState createState() => _ProductsState();
}

class _ProductsState extends State<Products> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String searchQuery = "";

  String? get userId => _auth.currentUser?.uid;

  CollectionReference get _cartCollection =>
      _firestore.collection('Users').doc(userId).collection('cart');

  CollectionReference get _wishlistCollection =>
      _firestore.collection('Users').doc(userId).collection('wishlist');



  Future<void> toggleWishlist(String productId, String name, double price, String imageUrl, String brand, String description ) async {
    if (userId == null) return;

    DocumentReference wishlistItemRef = _wishlistCollection.doc(productId);
    DocumentSnapshot doc = await wishlistItemRef.get();

    if (doc.exists) {
      await wishlistItemRef.delete();
    } else {
      await wishlistItemRef.set({
        'productId': productId,
        'name': name,
        'price': price,
        'imageUrl': imageUrl,
        'brand': brand,
        'description':description
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Colors.black,
        title: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
            boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
          ),
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: TextField(
            onChanged: (value) {
              setState(() {
                searchQuery = value.toLowerCase();
              });
            },
            style: TextStyle(color: Colors.black),
            cursorColor: Colors.black,
            decoration: InputDecoration(
              hintText: 'Search products...',
              hintStyle: TextStyle(color: Colors.grey),
              border: InputBorder.none,
            ),
          ),
        ),
        actions: [
          StreamBuilder<QuerySnapshot>(
            stream: _cartCollection.snapshots(),
            builder: (context, snapshot) {
              int itemCount = snapshot.data?.docs.length ?? 0;
              return Stack(
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.favorite, color: Colors.red),
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => WishlistPage()));
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.shopping_cart, color: Colors.white),
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => Cart()));
                        },
                      ),

                    ],
                  ),
                  if (itemCount > 0)
                    Positioned(
                      right: 5,
                      top: 5,
                      child: Container(
                        padding: EdgeInsets.all(5),
                        decoration: BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                        child: Text(
                          '$itemCount',
                          style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),

                ],
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('products').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No products available'));
          }

          var products = snapshot.data!.docs.where((product) {
            return product['name'].toString().toLowerCase().contains(searchQuery.toLowerCase()) ||
                product['category'].toString().toLowerCase().contains(searchQuery.toLowerCase());
          }).toList();

          return GridView.builder(
            padding: EdgeInsets.all(10),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.6,
            ),
            itemCount: products.length,
            itemBuilder: (context, index) {
              var product = products[index];

              return StreamBuilder<DocumentSnapshot>(
                stream: _wishlistCollection.doc(product.id).snapshots(),
                builder: (context, wishlistSnapshot) {
                  bool isWishlisted = wishlistSnapshot.data?.exists ?? false;

                  return GestureDetector(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,  // Enables full-page drag
                        builder: (context) => ProductDetailsPage(product: product),
                      );

                    },
                    child: Card(
                      elevation: 6,
                      shadowColor: Colors.black45,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Stack(
                            children: [
                              Container(
                                height: 150,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
                                  image: DecorationImage(
                                    image: NetworkImage(product['imageUrl']),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 10,
                                right: 10,
                                child: GestureDetector(
                                  onTap: () => toggleWishlist(
                                    product.id,
                                    product['name'],
                                    product['price'].toDouble(),
                                    product['imageUrl'],
                                    product['brand'],
                                    product['description'],
                                  ),
                                  child: Icon(
                                    isWishlisted ? Icons.favorite : Icons.favorite_border,
                                    color: isWishlisted ? Colors.red : Colors.grey,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product['name'],
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: 3),
                                Text(
                                  product['brand'] ?? 'Unknown Brand',
                                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  '₹${product['price']}',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
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

  // void _showProductDetails(BuildContext context, QueryDocumentSnapshot product) {
  //   showModalBottomSheet(
  //     context: context,
  //     isScrollControlled: true,
  //     builder: (context) {
  //       return Padding(
  //         padding: EdgeInsets.all(16.0),
  //         child: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             Center(
  //               child: Image.network(
  //                 product['imageUrl'],
  //                 height: 250,
  //                 width: 250,
  //                 fit: BoxFit.cover,
  //               ),
  //             ),
  //             SizedBox(height: 20),
  //             Text(
  //               product['name'],
  //               style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
  //             ),
  //             SizedBox(height: 5),
  //             Text(
  //               'Brand: ${product['brand'] ?? 'Unknown'}',
  //               style: TextStyle(fontSize: 16, color: Colors.grey),
  //             ),
  //             SizedBox(height: 10),
  //             Text(
  //               '₹${product['price']}',
  //               style: TextStyle(fontSize: 18, color: Colors.green, fontWeight: FontWeight.bold),
  //             ),
  //             SizedBox(height: 10),
  //             Text(
  //               product['description'] ?? 'No description available.',
  //               style: TextStyle(fontSize: 16),
  //             ),
  //             SizedBox(height: 20),
  //             ElevatedButton(
  //               onPressed: () {
  //                 addToCart(
  //                   product.id,
  //                   product['name'],
  //                   product['price'].toDouble(),
  //                   product['imageUrl'],
  //                 );
  //                 Navigator.pop(context);
  //               },
  //               style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
  //               child: Text('Add to Cart', style: TextStyle(color: Colors.white)),
  //             ),
  //           ],
  //         ),
  //       );
  //     },
  //   );
  // }
}
