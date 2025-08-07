import 'package:flutter/material.dart';
import 'package:zootopia/Users/function/AppbarZootioia.dart';
import 'package:zootopia/Users/function/DrawerBar.dart';
import 'package:zootopia/Users/qr_code_generator.dart';


class QRCode extends StatefulWidget {
  const QRCode({super.key});

  @override
  State<QRCode> createState() => _QRCodeState();
}

class _QRCodeState extends State<QRCode> {
  final _petNameController = TextEditingController();
  final _ownerNameController = TextEditingController();
  final _ownerAddressController = TextEditingController();
  final _ownerPhoneController = TextEditingController();
  final _ownerEmailController = TextEditingController();
  String _qrData = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: zootopiaAppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            children: [
              Text("Enter Details for QR Code",
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
              const SizedBox(
                height: 30,
              ),
              TextFormField(
                controller: _petNameController,
                decoration: InputDecoration(
                  hintText: 'Pet Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
              ),
              const SizedBox(
                height: 16,
              ),
              TextFormField(
                controller: _ownerNameController,
                decoration: InputDecoration(
                  hintText: 'Pet owner name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
              ),
              const SizedBox(
                height: 16,
              ),
              TextFormField(
                controller: _ownerAddressController,
                decoration: InputDecoration(
                  hintText: 'Owner address',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
              ),
              const SizedBox(
                height: 16,
              ),
              TextFormField(
                controller: _ownerPhoneController,
                decoration: InputDecoration(
                  hintText: 'Owner Phone number',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
              ),
              const SizedBox(
                height: 16,
              ),
              TextFormField(
                controller: _ownerEmailController,
                decoration: InputDecoration(
                  hintText: 'Owner email address ',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _qrData = 'Pet Name : ${_petNameController.text},\n'
                              'Pet Owner Name : ${_ownerNameController.text},\n'
                              'Address : ${_ownerAddressController.text}, \n'
                              'Phone_no : ${_ownerPhoneController.text}, \n'
                              'Email : ${_ownerEmailController.text}, \n';
                  });
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => QRCodeGenerator(qrData: _qrData, pet_name: _petNameController.text ),
                      ));
                },
                child: const Text('Generate QR code'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
