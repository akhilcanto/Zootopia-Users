import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:zootopia/Users/CheckoutPage.dart';
import 'package:zootopia/Users/function/AppbarZootioia.dart';

class Cart extends StatefulWidget {
  @override
  _CartState createState() => _CartState();
}

class _CartState extends State<Cart> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> cartItems = []; // Store full product details
  List<String> productIds = [];
  double deliveryFee = 50.0;
  double discount = 0.0;
  double totalAmount = 0.0;
bool isloading= true;
  @override
  void initState() {
    super.initState();
    fetchCartItems();
  }

  Future<void> fetchCartItems() async {
    User? user = _auth.currentUser;
    if (user == null) return;

    var cartSnapshot = await _firestore.collection('Users').doc(user.uid).collection('cart').get();

    List<Map<String, dynamic>> cartList = [];
    List<String> ids = [];
    for (var doc in cartSnapshot.docs) {
      String productId = doc['productId'];
      ids.add(productId);

      // Fetch product details from 'Products' collection
      var productSnapshot = await _firestore.collection('products').doc(productId).get();

      if (productSnapshot.exists) {
        cartList.add({
          'id': productId,
          'name': productSnapshot['name'],
          'price': (productSnapshot['price'] as num).toDouble(),
          'imageUrl': productSnapshot['imageUrl'],
          'quantity': doc['quantity'],
        });
      }
    }

    setState(() {
      cartItems = cartList;
      productIds = ids;

      calculateTotal();
      isloading= false;
    });
  }


  Future<void> updateQuantity(String productId, int newQuantity) async {
    User? user = _auth.currentUser;
    if (user == null) return;

    await _firestore.collection('Users').doc(user.uid).collection('cart').doc(productId).update({'quantity': newQuantity});
    fetchCartItems(); // Refresh cart after update
  }

  Future<void> deleteCartItem(String productId) async {
    User? user = _auth.currentUser;
    if (user == null) return;

    await _firestore.collection('Users').doc(user.uid).collection('cart').doc(productId).delete();
    fetchCartItems(); // Refresh cart after delete
  }

  void calculateTotal() {
    double subtotal = 0.0;
    for (var item in cartItems) {
      double price = (item['price'] as num).toDouble();
      int quantity = item['quantity'] as int;
      subtotal += price * quantity;
    }
    setState(() {
      totalAmount = subtotal + deliveryFee - discount;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: zootopiaAppBar(),
      body: isloading? Center(child: CircularProgressIndicator(),):cartItems.isEmpty
          ? Center(child: Text("Your cart is empty"))
          : Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: cartItems.length,
              itemBuilder: (context, index) {
                var cartItem = cartItems[index];
                String productId = cartItem['id']; // Get product ID
                String productName = cartItem['name'];
                double price = (cartItem['price'] as num).toDouble();
                String imageUrl = cartItem['imageUrl'];
                int quantity = cartItem['quantity'];

                return Card(
                  margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                  child: ListTile(
                    leading: imageUrl.isNotEmpty
                        ? Image.network(imageUrl, width: 90, height: 90, fit: BoxFit.cover)
                        : Icon(Icons.image_not_supported, size: 50),
                    title: Text(productName, style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('₹$price x $quantity'),
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(Icons.remove),
                              onPressed: () {
                                if (quantity > 1) {
                                  updateQuantity(productId, quantity - 1);
                                }
                              },
                            ),
                            Text(quantity.toString()),
                            IconButton(
                              icon: Icon(Icons.add),
                              onPressed: () {
                                updateQuantity(productId, quantity + 1);
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () => deleteCartItem(productId),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Delivery Fee:'),
                    Text('₹$deliveryFee'),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Discount:'),
                    Text('₹$discount'),
                  ],
                ),
                Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Order Total:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text('₹$totalAmount', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CheckoutPage(totalAmount: totalAmount, cartProducts: cartItems),
                  ),
                );

              },

              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[900],
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 30),
              ),
              child: Text('Proceed to Buy', style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}
