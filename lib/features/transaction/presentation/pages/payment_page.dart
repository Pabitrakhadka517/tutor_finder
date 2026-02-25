import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/transaction_providers.dart';

/// Payment page for booking - initiates eSewa payment flow
class PaymentPage extends ConsumerStatefulWidget {
  final String bookingId;
  final String tutorName;
  final double price;

  const PaymentPage({
    super.key,
    required this.bookingId,
    required this.tutorName,
    required this.price,
  });

  @override
  ConsumerState<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends ConsumerState<PaymentPage>
    with WidgetsBindingObserver {
  bool _paymentInitiated = false;
  bool _processingPayment = false;
  bool _esewaOpened = false;
  String? _initError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initPayment();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// When user returns from eSewa browser, auto-verify the payment
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _esewaOpened) {
      _esewaOpened = false;
      _verifyPaymentAfterReturn();
    }
  }

  Future<void> _initPayment() async {
    setState(() => _initError = null);

    final success = await ref
        .read(transactionNotifierProvider.notifier)
        .initBookingPayment(widget.bookingId);

    if (mounted) {
      if (success) {
        setState(() => _paymentInitiated = true);
      } else {
        final error = ref.read(transactionNotifierProvider).error;
        setState(() => _initError = error ?? 'Failed to initialize payment');
      }
    }
  }

  /// Open eSewa payment URL in the external browser
  Future<void> _launchEsewaPayment() async {
    final state = ref.read(transactionNotifierProvider);
    if (state.paymentInit == null) return;

    final paymentInit = state.paymentInit!;
    final esewaUrl = Uri.parse(
      'https://rc-epay.esewa.com.np/api/epay/main/v2/form'
      '?amt=${paymentInit.amount.toStringAsFixed(0)}'
      '&psc=0&pdc=0&txAmt=0'
      '&tAmt=${paymentInit.amount.toStringAsFixed(0)}'
      '&pid=${paymentInit.transactionUuid}'
      '&scd=${paymentInit.productCode}'
      '&su=${Uri.encodeComponent(paymentInit.successUrl)}'
      '&fu=${Uri.encodeComponent(paymentInit.failureUrl)}',
    );

    try {
      final canOpen = await canLaunchUrl(esewaUrl);
      if (canOpen) {
        setState(() => _esewaOpened = true);
        await launchUrl(esewaUrl, mode: LaunchMode.externalApplication);
      } else {
        // Fallback: use in-app payment verification flow
        if (mounted) _processPaymentDirectly();
      }
    } catch (e) {
      // Fallback: direct payment verification
      if (mounted) _processPaymentDirectly();
    }
  }

  /// Direct payment processing (for test/development mode)
  Future<void> _processPaymentDirectly() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Confirm Payment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF60BB46).withAlpha(25),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Text(
                    'eSewa Payment',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Rs. ${widget.price.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF60BB46),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'to ${widget.tutorName}',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Proceed with this payment?',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF60BB46),
              foregroundColor: Colors.white,
            ),
            child: const Text('Pay Now'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await _processPayment();
    }
  }

  /// Process the payment verification with the backend
  Future<void> _processPayment() async {
    final state = ref.read(transactionNotifierProvider);
    if (state.paymentInit == null) return;

    setState(() => _processingPayment = true);

    final transactionCode = 'ESEWA_${DateTime.now().millisecondsSinceEpoch}';
    final success = await ref
        .read(transactionNotifierProvider.notifier)
        .processBookingPayment(
          transactionId: state.paymentInit!.transactionId,
          transactionCode: transactionCode,
        );

    if (!mounted) return;
    setState(() => _processingPayment = false);

    if (success) {
      _showSuccessDialog();
    } else {
      _showFailureDialog();
    }
  }

  /// Verify payment after returning from eSewa browser
  Future<void> _verifyPaymentAfterReturn() async {
    final state = ref.read(transactionNotifierProvider);
    if (state.paymentInit == null) return;

    setState(() => _processingPayment = true);

    // Try to verify the payment with the backend
    final transactionCode =
        'ESEWA_RETURN_${DateTime.now().millisecondsSinceEpoch}';
    final success = await ref
        .read(transactionNotifierProvider.notifier)
        .processBookingPayment(
          transactionId: state.paymentInit!.transactionId,
          transactionCode: transactionCode,
        );

    if (!mounted) return;
    setState(() => _processingPayment = false);

    if (success) {
      _showSuccessDialog();
    } else {
      // Payment may still be pending - show option to retry or confirm manually
      _showPendingDialog();
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 64),
            const SizedBox(height: 16),
            const Text(
              'Payment Successful!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Rs. ${widget.price.toStringAsFixed(0)} paid to ${widget.tutorName}',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 8),
            const Text(
              'A chat room has been created. You can now message your tutor!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pop(true);
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  void _showFailureDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, color: Colors.red[400], size: 64),
            const SizedBox(height: 16),
            const Text(
              'Payment Failed',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              ref.read(transactionNotifierProvider).error ??
                  'Something went wrong. Please try again.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _processPaymentDirectly();
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  void _showPendingDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.hourglass_bottom, color: Colors.orange[400], size: 64),
            const SizedBox(height: 16),
            const Text(
              'Payment Pending',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your payment is being processed. If you completed payment in eSewa, tap "Verify" to confirm.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.of(context).pop(false);
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _processPayment();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF60BB46),
              foregroundColor: Colors.white,
            ),
            child: const Text('Verify Payment'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final txState = ref.watch(transactionNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pay with eSewa'),
        backgroundColor: const Color(0xFF60BB46), // eSewa green
        foregroundColor: Colors.white,
      ),
      body: txState.isLoading && !_paymentInitiated
          ? const Center(child: CircularProgressIndicator())
          : (_initError != null ||
                (txState.error != null && !_paymentInitiated))
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text(
                    _initError ??
                        txState.error ??
                        'Payment initialization failed',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _initPayment,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // eSewa Logo Section
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFF60BB46).withAlpha(25),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: const Color(0xFF60BB46),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Center(
                            child: Text(
                              'eSewa',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Digital Payment',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Payment Details Card
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Payment Details',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Divider(height: 24),
                          _buildDetailRow('Tutor', widget.tutorName),
                          _buildDetailRow(
                            'Amount',
                            'Rs. ${widget.price.toStringAsFixed(0)}',
                          ),
                          if (txState.paymentInit != null) ...[
                            _buildDetailRow(
                              'Product Code',
                              txState.paymentInit!.productCode,
                            ),
                            _buildDetailRow(
                              'Transaction ID',
                              txState.paymentInit!.transactionUuid
                                  .substring(0, 8)
                                  .toUpperCase(),
                            ),
                          ],
                          _buildDetailRow('Payment Method', 'eSewa'),
                          const Divider(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Total',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Rs. ${widget.price.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF60BB46),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Commission info
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue, size: 20),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'A 10% platform commission will be deducted. The tutor receives the remaining amount.',
                            style: TextStyle(fontSize: 12, color: Colors.blue),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Pay Button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _paymentInitiated && !_processingPayment
                          ? _launchEsewaPayment
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF60BB46),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _processingPayment
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              'Pay Rs. ${widget.price.toStringAsFixed(0)} with eSewa',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Manual/Test Payment Button
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: OutlinedButton(
                      onPressed: _paymentInitiated && !_processingPayment
                          ? _processPaymentDirectly
                          : null,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF60BB46),
                        side: const BorderSide(color: Color(0xFF60BB46)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Confirm Payment Manually',
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Cancel Button
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Cancel Payment'),
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
