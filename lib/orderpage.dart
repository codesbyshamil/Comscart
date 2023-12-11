import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

class Orders extends StatefulWidget {
  const Orders({Key? key});

  @override
  State<Orders> createState() => _OrdersState();
}

class _OrdersState extends State<Orders> {
  @override
  void initState() {
    super.initState();
  }

  Future<void> _saveInvoiceAsPdf(Map<String, dynamic>? invoiceData) async {
    var status = await Permission.manageExternalStorage.request();
    if (!status.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Permission denied to save PDF.'),
        ),
      );
      return;
    }

    if (invoiceData == null || invoiceData['Products'] == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Invoice data or Products list not available.'),
        ),
      );
      return;
    }

    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a5,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Invoice Details',
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 18,
                  decoration: pw.TextDecoration.underline,
                ),
              ),
              pw.SizedBox(height: 10), // Add spacing between sections

              // Add order details to the invoice
              pw.Text(
                'Order ID: ${invoiceData['OrderId']}',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),

              pw.Text(
                'Order Date: ${invoiceData['Datetime']}',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 20), // Add spacing between sections

              // Add products information to the invoice
              pw.Text(
                'Products:',
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              for (var product in invoiceData['Products'])
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Name: ${product['Name']}'),
                    pw.Text('Price: \$${product['Price']}'),
                    pw.SizedBox(height: 10), // Add spacing between products
                  ],
                ),
              pw.Text(
                'Order Total: \$${invoiceData['Total'].toString()}',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
            ],
          );
        },
      ),
    );

    try {
      String downloadsPath = '/storage/emulated/0/Download';
      String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final pdfPath =
          '$downloadsPath/invoice_${invoiceData['OrderId']}_$timestamp.pdf';
      final file = File(pdfPath);
      await file.writeAsBytes(await pdf.save());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Invoice PDF saved to Downloads'),
        ),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save invoice as PDF: $error'),
        ),
      );
      print('Error: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Orders')),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .snapshots(),
        builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(
              child: Text('No orders available.'),
            );
          }

          List<dynamic> orders = snapshot.data!.get('Orders') ?? [];

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (BuildContext context, int index) {
              var order = orders[index];
              List<dynamic> products = order['Products'] ?? [];
              var invoice = {
                'OrderId': order['OrderId'],
                'Total': order['Total'],
                'Datetime': order['Datetime'],
                'Products': products,
              };

              return Column(
                children: [
                  ListTile(
                    leading: Text(
                      '${index + 1}',
                      style: TextStyle(fontSize: 25),
                      textAlign: TextAlign.center,
                    ),
                    title: Text(
                      'Order Status : ${order['Order Status']}',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.green,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Order Price : \$${order['Total'].toString()}',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Order ID: #${order['OrderId']}',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          'Ordered on ${order['Datetime']}',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: products.length,
                    itemBuilder: (BuildContext context, int idx) {
                      var product = products[idx];
                      return ListTile(
                        title: Text('${product['Name']}'),
                        subtitle: Text('\$${product['Price']}'),
                        leading: Image.network('${product['Thumbnail']}'),
                      );
                    },
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _saveInvoiceAsPdf(invoice);
                    },
                    child: Text('Download Invoice'),
                  ),
                  Divider(),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
