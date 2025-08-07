import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class OrderHistoryPage extends StatelessWidget {
  const OrderHistoryPage({super.key});

  Future<void> _cancelOrder(BuildContext context, DocumentSnapshot order) async {
    final orderId = order.id;
    final List products = order['productIds'];

    try {
      for (var product in products) {
        final productRef = FirebaseFirestore.instance
            .collection('products')
            .doc(product['id']);

        final productSnap = await productRef.get();
        if (productSnap.exists) {
          final currentStock = productSnap['stock'] ?? 0;
          await productRef.update({
            'stock': currentStock + (product['quantity'] ?? 0),
          });
        }
      }

      await FirebaseFirestore.instance
          .collection('orders')
          .doc(orderId)
          .update({'deliveryStatus': 'cancelled'});

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Order cancelled and stock updated.")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error cancelling order: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final String userId = FirebaseAuth.instance.currentUser!.uid;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Order History", style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.black,
          iconTheme: const IconThemeData(color: Colors.white),
          bottom: const TabBar(
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: 'Active Orders'),
              Tab(text: 'Cancelled'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            OrderList(statusType: 'active', userId: userId),
            OrderList(statusType: 'cancelled', userId: userId),
          ],
        ),
      ),
    );
  }

  Widget OrderList({required String statusType, required String userId}) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('orders')
          .where('uid', isEqualTo: userId)
          // .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

        final allOrders = snapshot.data!.docs;

        final filteredOrders = allOrders.where((order) {
          final status = order['deliveryStatus'];
          if (statusType == 'cancelled') return status == 'cancelled';
          return status != 'cancelled'; // Active includes delivered, shipped, etc.
        }).toList();

        if (filteredOrders.isEmpty) {
          return const Center(child: Text("No orders found."));
        }

        return ListView.builder(
          itemCount: filteredOrders.length,
          itemBuilder: (context, index) {
            final order = filteredOrders[index];
            final List products = order['productIds'];
            final shipping = order['shippingAddress'];
            final orderDate = (order['timestamp'] as Timestamp).toDate();
            final formattedDate = DateFormat('dd MMM yyyy – hh:mm a').format(orderDate);
            final deliveryStatus = order['deliveryStatus'];

            return Card(
              margin: const EdgeInsets.all(10),
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: ExpansionTile(
                title: Text("Order ID: ${order['orderId']}"),
                subtitle: Text(
                  "Total: ₹${order['amount']} \nDelivery Status: ${deliveryStatus.toString().toUpperCase()}",
                  style: const TextStyle(color: Colors.blue),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: Text("Order Date: $formattedDate"),
                  ),
                  ...products.map((item) {
                    return ListTile(
                      leading: Image.network(item['imageUrl'], width: 50, height: 50, fit: BoxFit.cover),
                      title: Text(item['name']),
                      subtitle: Text("₹${item['price']} x ${item['quantity']}"),
                    );
                  }).toList(),
                  const Divider(),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Payment: ${order['status']}", style: const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        const Text("Shipping Address:", style: TextStyle(fontWeight: FontWeight.bold)),
                        Text("${shipping['name']}, ${shipping['address']}, ${shipping['city']}, ${shipping['state']}, ${shipping['zip']}, ${shipping['country']}"),
                        Text("Phone: ${shipping['phone']}"),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (deliveryStatus != 'cancelled' && deliveryStatus != 'delivered')
                    Padding(
                      padding: const EdgeInsets.only(right: 12.0, bottom: 8),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                          onPressed: () => _cancelOrder(context, order),
                          child: const Text("Cancel Order"),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
