import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProductDetailsPage extends StatefulWidget {
  final QueryDocumentSnapshot product;

  ProductDetailsPage({required this.product});

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> with SingleTickerProviderStateMixin {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  String? get userId => _auth.currentUser?.uid;
  CollectionReference get _cartCollection =>
      _firestore.collection('Users').doc(userId).collection('cart');

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: Duration(milliseconds: 300), vsync: this);
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  Future<void> addToCart() async {
    if (userId == null) return;

    DocumentReference cartItemRef = _cartCollection.doc(widget.product.id);
    DocumentSnapshot doc = await cartItemRef.get();

    if (doc.exists) {
      await cartItemRef.update({'quantity': FieldValue.increment(1)});
    } else {
      await cartItemRef.set({
        'productId': widget.product.id,
        'userId': userId,
        'quantity': 1,
      });
    }

    _controller.forward().then((_) => _controller.reverse());

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added to cart 🎉'),
        duration: Duration(seconds: 2),
      ),
    );
    // Navigator.pop(context);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          Hero(
              tag: widget.product.id,
              child: Image.network(
                widget.product['imageUrl'],
                width: double.infinity,
                height: MediaQuery.of(context).size.height * 0.5, // Half-screen height
                fit: BoxFit.cover,
              ),
            ),


          // Gradient Overlay for better readability
          Container(
            height: MediaQuery.of(context).size.height * 0.5,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.black.withOpacity(0.3), Colors.transparent],
              ),
            ),
          ),

          // Draggable Product Details Sheet
          DraggableScrollableSheet(
            initialChildSize: 0.5,
            minChildSize: 0.5,
            maxChildSize: 0.9,
            builder: (context, scrollController) {
              return Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                  boxShadow: [
                    BoxShadow(color: Colors.black26, blurRadius: 10),
                  ],
                ),
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.product['name'],
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          // Icon(Icons.currency_exchange, color: Colors.green, size: 22),
                          Text(
                            '₹${widget.product['price']}',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green.shade700),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Brand: ${widget.product['brand'] ?? 'Unknown'}',
                        style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                      ),
                      SizedBox(height: 15),
                      Container(
                        padding: EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(color: Colors.black12, blurRadius: 10),
                          ],
                        ),
                        child: Text(
                          widget.product['description'] ?? 'No description available.',
                          style: TextStyle(fontSize: 16, color: Colors.black87),
                        ),
                      ),
                      SizedBox(height: 20),
                      ScaleTransition(
                        scale: _scaleAnimation,
                        child: ElevatedButton.icon(
                          onPressed: addToCart,
                          icon: Icon(Icons.shopping_cart, color: Colors.white),
                          label: Text(
                            'Add to Cart',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            minimumSize: Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
