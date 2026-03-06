import 'package:flutter/material.dart';

class PaymentSuccessPage extends StatelessWidget {
  final String bookingId;
  final String tutorName;
  final double amount;

  const PaymentSuccessPage({
    super.key,
    required this.bookingId,
    required this.tutorName,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Payment Success')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 80),
            const SizedBox(height: 12),
            const Text(
              'Payment verified successfully',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Rs. ${amount.toStringAsFixed(2)} paid for session with $tutorName.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              'Booking: $bookingId',
              style: TextStyle(color: Colors.grey.shade700),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Done'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
