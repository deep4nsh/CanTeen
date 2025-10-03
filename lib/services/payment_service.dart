import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:flutter/material.dart';
import '../src/models/order.dart';

class PaymentService {
  static final Razorpay _razorpay = Razorpay();

  static void init() {
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  static void openCheckout({
    required BuildContext context,
    required double amount,  // In paise
    required String orderId,  // Backend order ID
    required Function(Order) onSuccess,
  }) async {
    var options = {
      'key': 'rzp_test_xxx',  // Your key
      'amount': (amount * 100).toInt(),
      'name': 'Canteen CMS',
      'description': 'Order Payment',
      'prefill': {'contact': '', 'email': ''},
      'external': {
        'wallets': ['paytm']
      },
      'order_id': orderId,
    };
    _razorpay.open(options);
  }

  static void _handlePaymentSuccess(PaymentSuccessResponse response) {
    // Call backend to verify & update order
    // Generate PDF bill
    // Notify via FCM
    print('Payment Success: ${response.paymentId}');
  }

  static void _handlePaymentError(PaymentFailureResponse response) {
    print('Payment Error: ${response.code} - ${response.message}');
    // Show error dialog
  }

  static void _handleExternalWallet(ExternalWalletResponse response) {
    print('External wallet: ${response.walletName}');
  }
}