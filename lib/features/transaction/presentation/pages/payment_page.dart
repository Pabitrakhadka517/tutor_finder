import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../core/config/esewa_config.dart';
import '../providers/transaction_providers.dart';
import 'esewa_webview_page.dart';

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

class _PaymentPageState extends ConsumerState<PaymentPage> {
  String _selectedMethod = 'eSewa';
  bool _submitting = false;

  Future<void> _startPayment() async {
    if (_submitting) return;

    setState(() => _submitting = true);

    final notifier = ref.read(transactionNotifierProvider.notifier);

    final initialized = await notifier.initBookingPayment(widget.bookingId);
    if (!mounted) return;

    if (!initialized) {
      setState(() => _submitting = false);
      final err =
          ref.read(transactionNotifierProvider).error ??
          'Failed to initialize payment';
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(err), backgroundColor: Colors.red));
      return;
    }

    final paymentInit = ref.read(transactionNotifierProvider).paymentInit;
    if (paymentInit == null) {
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Payment payload missing from backend response'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final result = await Navigator.of(context).push<EsewaWebViewResult>(
      MaterialPageRoute(
        builder: (_) => EsewaWebViewPage(paymentInit: paymentInit),
      ),
    );

    if (!mounted) return;

    if (result == null || result.isCancelled || !result.isSuccess) {
      setState(() => _submitting = false);
      await Navigator.of(context).pushNamed(
        AppRoutes.paymentFailure,
        arguments: {
          'message':
              result?.message ??
              'Payment cancelled or failed before verification.',
        },
      );
      return;
    }

    final callbackData = result.callbackData;
    final transactionUUID = _pickString(callbackData, const [
      'transaction_uuid',
      'transactionUUID',
      'transactionUuid',
    ]);
    final transactionCode = _pickString(callbackData, const [
      'transaction_code',
      'transactionCode',
    ]);
    final safeTransactionCode = transactionCode.isNotEmpty
        ? transactionCode
        : 'ESEWA_${DateTime.now().millisecondsSinceEpoch}';
    final amount = _pickDouble(callbackData, const [
      'total_amount',
      'amount',
    ], fallback: paymentInit.amount);

    final strictValidationError = _validateCallbackStrict(
      callbackData: callbackData,
      expectedTransactionUUID: paymentInit.transactionUuid,
      callbackTransactionUUID: transactionUUID,
      expectedAmount: paymentInit.amount,
      callbackAmount: amount,
    );

    if (strictValidationError != null) {
      setState(() => _submitting = false);
      await Navigator.of(context).pushNamed(
        AppRoutes.paymentFailure,
        arguments: {'message': strictValidationError},
      );
      return;
    }

    final verified = await notifier.verifyBookingPayment(
      transactionUUID: transactionUUID.isNotEmpty
          ? transactionUUID
          : paymentInit.transactionUuid,
      amount: amount,
      transactionCode: safeTransactionCode,
      callbackData: callbackData,
    );

    if (!mounted) return;
    setState(() => _submitting = false);

    if (verified) {
      await Navigator.of(context).pushNamed(
        AppRoutes.paymentSuccess,
        arguments: {
          'bookingId': widget.bookingId,
          'tutorName': widget.tutorName,
          'amount': amount,
        },
      );
      if (mounted) {
        Navigator.of(context).pop(true);
      }
      return;
    }

    await Navigator.of(context).pushNamed(
      AppRoutes.paymentFailure,
      arguments: {
        'message':
            ref.read(transactionNotifierProvider).error ??
            'Payment verification failed',
      },
    );
  }

  static String _pickString(Map<String, dynamic> source, List<String> keys) {
    for (final key in keys) {
      final value = source[key]?.toString();
      if (value != null && value.isNotEmpty) return value;
    }
    return '';
  }

  static double _pickDouble(
    Map<String, dynamic> source,
    List<String> keys, {
    required double fallback,
  }) {
    for (final key in keys) {
      final value = source[key];
      if (value is num) return value.toDouble();
      final parsed = double.tryParse(
        value?.toString().replaceAll(',', '') ?? '',
      );
      if (parsed != null) return parsed;
    }
    return fallback;
  }

  static String? _validateCallbackStrict({
    required Map<String, dynamic> callbackData,
    required String expectedTransactionUUID,
    required String callbackTransactionUUID,
    required double expectedAmount,
    required double callbackAmount,
  }) {
    if (!EsewaConfig.strictMode) {
      return null;
    }

    if (callbackTransactionUUID.isEmpty) {
      return 'Invalid payment callback: missing transaction UUID.';
    }

    if (callbackTransactionUUID != expectedTransactionUUID) {
      return 'Invalid payment callback: transaction UUID mismatch.';
    }

    if ((callbackAmount - expectedAmount).abs() > 0.01) {
      return 'Invalid payment callback: amount mismatch.';
    }

    final status = callbackData['status']?.toString();
    if (status != null && status.isNotEmpty && status != 'COMPLETE') {
      return 'Payment is not complete. eSewa status: $status';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(transactionNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Complete Payment')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Payment Method',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
            ),
            const SizedBox(height: 12),
            _PaymentMethodOption(
              title: 'eSewa',
              subtitle: 'Secure digital wallet payment',
              isSelected: _selectedMethod == 'eSewa',
              onTap: () {
                setState(() => _selectedMethod = 'eSewa');
              },
            ),
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SummaryRow(title: 'Tutor', value: widget.tutorName),
                    _SummaryRow(
                      title: 'Amount',
                      value: 'Rs. ${widget.price.toStringAsFixed(2)}',
                    ),
                    _SummaryRow(title: 'Booking', value: widget.bookingId),
                  ],
                ),
              ),
            ),
            if (state.error != null) ...[
              const SizedBox(height: 12),
              Text(state.error!, style: const TextStyle(color: Colors.red)),
            ],
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _selectedMethod == 'eSewa' && !_submitting
                    ? _startPayment
                    : null,
                child: state.isLoading || _submitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Continue with eSewa'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PaymentMethodOption extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _PaymentMethodOption({
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Colors.grey.shade300,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Colors.grey,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [Text(title), Text(subtitle)],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String title;
  final String value;

  const _SummaryRow({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(title, style: TextStyle(color: Colors.grey.shade700)),
          ),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
