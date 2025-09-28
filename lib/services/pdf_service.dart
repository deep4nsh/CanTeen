import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'dart:io';

import '../models/order.dart';

class PDFService {
  static Future<String> generateBill(Order order, String userEmail) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Column(
          children: [
            pw.Text('Bill for Token: ${order.tokenNumber}'),
            pw.Text('Total: ₹${order.totalAmount}'),
            pw.Text('Items:'),
            ...order.items.map((item) => pw.Text('${item.menuItemId} x ${item.quantity} - ₹${item.price}')),
            pw.Text('Status: ${order.status}'),
          ],
        ),
      ),
    );

    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/bill_${order.id}.pdf');
    await file.writeAsBytes(await pdf.save());
    // Upload to backend or send via email (integrate mailer plugin if needed)
    return file.path;  // Or base64 encode for sharing
  }
}