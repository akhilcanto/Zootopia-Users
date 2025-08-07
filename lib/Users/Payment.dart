import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:zootopia/Users/bottomnavbar.dart';
import 'package:zootopia/Users/function/AppbarZootioia.dart';

class PaymentScreen extends StatefulWidget {
  final Map<String, String?> shippingAddress; // Allow null values
  final List<Map<String, dynamic>> cartProducts;

  const PaymentScreen({super.key, required this.shippingAddress, required this.cartProducts});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {

  final _razorpay = Razorpay();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    // ScaffoldMessenger.of(context).showSnackBar(
    //   SnackBar(content: Text('Payment Successful! Order placed.')),
    // );
    // Get the current user's UID
    final User? user = _auth.currentUser;
    final String uid = user?.uid ?? '';

    // Prepare initial order data (without payment details)
    final orderData = {
      'uid': uid, // Add the user's UID
      'productIds': widget.cartProducts, // Add the list of product IDs
      'amount': widget.shippingAddress['amount'],
      'email': widget.shippingAddress['email'] ?? '', // Handle null email
      'shippingAddress': widget.shippingAddress, // Phone is included here
      'timestamp': FieldValue.serverTimestamp(),
      'status': 'pending', // Initial status
      'deliveryStatus': 'processing'
    };

    try {
      // Step 1: Create the Firestore document first
      DocumentReference orderRef = await FirebaseFirestore.instance.collection('orders').add(orderData);
      final String orderId = orderRef.id;
      await orderRef.update({
        'orderId': orderId, // Add the document ID as the orderId
        'paymentId': response.paymentId,
        'status': 'completed', // Update status to completed
      });

      // To reduce quantity from product collection
      for (var product in widget.cartProducts) {
        String productId = product['id']; // Firestore product ID
        int purchasedQuantity = product['quantity'];

        DocumentReference productRef = FirebaseFirestore.instance.collection('products').doc(productId);
        DocumentSnapshot productSnapshot = await productRef.get();

        if (productSnapshot.exists) {
          int currentQuantity = productSnapshot['stock'] ?? 0;
          int newQuantity = (currentQuantity - purchasedQuantity).clamp(0, currentQuantity); // Prevent negative stock

          await productRef.update({'stock': newQuantity});
        }
      }

      // cart clear cheyan ullathu
      final cartCollection = FirebaseFirestore.instance.collection('Users').doc(uid).collection('cart');
      final cartSnapshot = await cartCollection.get();

      for (var doc in cartSnapshot.docs) {
        await doc.reference.delete(); // Delete each cart item
      }


      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order placed successfully!')),
      );

      // Navigate to the ProductList screen
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => Bottomnavbar(initialIndex: 1),
        ),
            (route) => false,
      );

      isLoading= false;

    } catch (e) {
      debugPrint('Error saving order: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save order: $e')),
      );
    }

  }

  void _handlePaymentError(PaymentFailureResponse response) {
    setState(() => isLoading = false); // Stop loading on failure
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Payment Failed: ${response.message}')),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    setState(() => isLoading = false); // Stop loading on failure
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('External Wallet: ${response.walletName}')),
    );
  }

  void _openRazorpay() {
   setState(() {
     isLoading= true;
   });
    // Parse the amount as a double first, then convert it to an integer
    final amountInRupees = double.parse(widget.shippingAddress['amount']!);
    final amountInPaise = (amountInRupees * 100).toInt(); // Convert to paise

    final options = {
      'key': 'rzp_test_zrejXWOWxRf29k',
      'amount': amountInPaise,
      'currency': 'INR',
      'name': 'Zootopia',
      'description': 'Payment for Order',
      'prefill': {
        'contact': widget.shippingAddress['phone'] ?? '',
        'email': widget.shippingAddress['email'] ?? '',
      },
      'notes': {'country': 'India'},
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final shippingAddress = widget.shippingAddress;

    return Scaffold(
      appBar: zootopiaAppBar(),
      body:isLoading? Center(child: CircularProgressIndicator(),): SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Shipping Address Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Shipping Address',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF380230), // Deep Purple
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildDetailRow('Name', shippingAddress['name'] ?? 'N/A'),
                    _buildDetailRow('Address', shippingAddress['address'] ?? 'N/A'),
                    _buildDetailRow('State', shippingAddress['state'] ?? 'N/A'),
                    _buildDetailRow('District', shippingAddress['district'] ?? 'N/A'),
                    _buildDetailRow('City', shippingAddress['city'] ?? 'N/A'),
                    _buildDetailRow('Zip', shippingAddress['zip'] ?? 'N/A'),
                    _buildDetailRow('Country', shippingAddress['country'] ?? 'N/A'),
                    _buildDetailRow('Phone', shippingAddress['phone'] ?? 'N/A'),
                    _buildDetailRow('Email', shippingAddress['email'] ?? 'N/A'),

                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Product List Section
            Text(
              'Products in Cart',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF380230),
              ),
            ),
            const SizedBox(height: 12),

            // Display Cart Products
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: widget.cartProducts.length,
              itemBuilder: (context, index) {
                final product = widget.cartProducts[index];
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 6),
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    leading: product['imageUrl'] != null
                        ? Image.network(
                      product['imageUrl'],
                      width: 60,
                      height: 80,
                      fit: BoxFit.cover,
                    )
                        : Icon(Icons.shopping_cart, size: 50, color: Colors.grey),
                    title: Text(
                      product['name'] ?? 'Unknown Product',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text('Price: ₹${product['price']} \nQuantity: ${product['quantity']}\n\nTotal: ₹${(product['price'] * product['quantity']).toStringAsFixed(2)}'),
                    // trailing: Text(
                    //   '₹${(product['price'] * product['quantity']).toStringAsFixed(2)}',
                    //   style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                    // ),
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            // Payment Details Section
            Text(
              'Order Total : ₹${shippingAddress['amount']}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF380230),
              ),
            ),
            const SizedBox(height: 24),

            // Pay Button
            Center(
              child: ElevatedButton(
                onPressed: _openRazorpay,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  "Pay ₹${shippingAddress['amount']}",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                  fontSize: 16,
                  color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
//
//   Widget _buildPaymentDetailRow(String label, String value) {
//     return Card(
//       elevation: 2,
//       margin: EdgeInsets.symmetric(vertical: 6),
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(12.0),
//         child: Row(
//           children: [
//             Text(
//               '$label: ',
//               style: TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.bold,
//                 color: Color(0xFF380230), // Deep Purple
//               ),
//             ),
//             Text(
//               value,
//               style: TextStyle(
//                   fontSize: 16,
//                   color: Colors.black87),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
}