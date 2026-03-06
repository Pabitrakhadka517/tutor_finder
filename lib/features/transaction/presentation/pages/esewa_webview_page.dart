import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../../core/config/esewa_config.dart';
import '../../domain/entities/transaction_entity.dart';

class EsewaWebViewResult {
  final bool isSuccess;
  final bool isCancelled;
  final String? message;
  final Map<String, dynamic> callbackData;

  const EsewaWebViewResult({
    required this.isSuccess,
    required this.isCancelled,
    this.message,
    this.callbackData = const {},
  });
}

class EsewaWebViewPage extends StatefulWidget {
  final PaymentInitEntity paymentInit;

  const EsewaWebViewPage({super.key, required this.paymentInit});

  @override
  State<EsewaWebViewPage> createState() => _EsewaWebViewPageState();
}

class _EsewaWebViewPageState extends State<EsewaWebViewPage> {
  WebViewController? _controller;
  int _progress = 0;
  String? _loadError;
  late final String _successUrl;
  late final String _failureUrl;
  bool _isInitializing = true;
  Uri? _externalFallbackUri;

  @override
  void initState() {
    super.initState();

    _successUrl = EsewaConfig.resolveSuccessUrl(widget.paymentInit.successUrl);
    _failureUrl = EsewaConfig.resolveFailureUrl(widget.paymentInit.failureUrl);

    _initializeWebView();
  }

  Future<void> _initializeWebView() async {
    final paymentInit = widget.paymentInit;
    final missingSignature = paymentInit.signature.trim().isEmpty;
    if (missingSignature && !EsewaConfig.allowUnsignedFormFallback) {
      if (!mounted) return;
      Navigator.of(context).pop(
        const EsewaWebViewResult(
          isSuccess: false,
          isCancelled: false,
          message:
              'Signed eSewa payload is required. Backend must return signature and signed_field_names.',
        ),
      );
      return;
    }

    if (missingSignature || EsewaConfig.allowUnsignedFormFallback) {
      _externalFallbackUri = _buildLegacyEsewaUri();
    }

    try {
      final controller = WebViewController();
      await controller.setJavaScriptMode(JavaScriptMode.unrestricted);
      await controller.setNavigationDelegate(
        NavigationDelegate(
          onProgress: (p) {
            if (!mounted) return;
            setState(() => _progress = p);
          },
          onWebResourceError: (error) {
            if (!mounted) return;
            setState(() => _loadError = error.description);
          },
          onNavigationRequest: (request) {
            final uri = Uri.tryParse(request.url);
            if (uri == null) return NavigationDecision.navigate;

            if (_isCallbackUrl(_successUrl, uri)) {
              final data = _parseCallbackPayload(uri);
              debugPrint('[PaymentAudit] success callback received: $data');
              Navigator.of(context).pop(
                EsewaWebViewResult(
                  isSuccess: true,
                  isCancelled: false,
                  callbackData: data,
                ),
              );
              return NavigationDecision.prevent;
            }

            if (_isCallbackUrl(_failureUrl, uri)) {
              final data = _parseCallbackPayload(uri);
              debugPrint('[PaymentAudit] failure callback received: $data');
              Navigator.of(context).pop(
                EsewaWebViewResult(
                  isSuccess: false,
                  isCancelled: false,
                  message: 'eSewa redirected to failure URL',
                  callbackData: data,
                ),
              );
              return NavigationDecision.prevent;
            }

            return NavigationDecision.navigate;
          },
        ),
      );

      if (missingSignature) {
        await controller.loadHtmlString(_buildLegacyAutoSubmitFormHtml());
      } else {
        await controller.loadHtmlString(_buildAutoSubmitFormHtml());
      }

      if (!mounted) return;
      setState(() {
        _controller = controller;
        _isInitializing = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isInitializing = false;
        _loadError =
            'In-app WebView is not available on this run. ${error.toString()}';
      });
    }
  }

  Future<void> _openExternalFallback() async {
    final uri = _externalFallbackUri;
    if (uri == null) return;

    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open external browser.')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('External browser fallback failed: $e')),
      );
    }
  }

  Uri _buildLegacyEsewaUri() {
    final p = widget.paymentInit;
    final amount = _amountForGateway(p.amount);

    return Uri.parse(EsewaConfig.legacyFormUrl).replace(
      queryParameters: {
        'amt': amount,
        'psc': '0',
        'pdc': '0',
        'txAmt': '0',
        'tAmt': amount,
        'pid': p.transactionUuid,
        'scd': p.productCode,
        'su': _successUrl,
        'fu': _failureUrl,
      },
    );
  }

  bool _isCallbackUrl(String configuredUrl, Uri current) {
    final configured = Uri.tryParse(configuredUrl);
    if (configured == null) return false;
    return configured.scheme == current.scheme &&
        configured.host == current.host &&
        configured.path == current.path;
  }

  Map<String, dynamic> _parseCallbackPayload(Uri uri) {
    final qp = uri.queryParameters;

    try {
      final dataParam = qp['data'];
      if (dataParam != null && dataParam.isNotEmpty) {
        final decoded = utf8.decode(base64.decode(dataParam));
        final payload = jsonDecode(decoded);
        if (payload is Map<String, dynamic>) {
          return payload;
        }
      }
    } catch (e) {
      debugPrint('[PaymentAudit] data payload parse failed: $e');
    }

    return {for (final entry in qp.entries) entry.key: entry.value};
  }

  String _buildAutoSubmitFormHtml() {
    final p = widget.paymentInit;

    String esc(String value) => value
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#39;');

    final amount = _amountForGateway(p.amount);

    final html =
        '''
<!doctype html>
<html>
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Redirecting to eSewa</title>
    <style>
      body { font-family: Arial, sans-serif; display: grid; place-items: center; height: 100vh; margin: 0; }
      .box { text-align: center; }
    </style>
  </head>
  <body>
    <div class="box">
      <h3>Redirecting to eSewa...</h3>
      <p>Please wait.</p>
    </div>
    <form id="esewaForm" action="${esc(EsewaConfig.formUrl)}" method="POST">
      <input type="hidden" name="amount" value="${esc(amount)}" />
      <input type="hidden" name="tax_amount" value="0" />
      <input type="hidden" name="product_service_charge" value="0" />
      <input type="hidden" name="product_delivery_charge" value="0" />
      <input type="hidden" name="total_amount" value="${esc(amount)}" />
      <input type="hidden" name="transaction_uuid" value="${esc(p.transactionUuid)}" />
      <input type="hidden" name="product_code" value="${esc(p.productCode)}" />
      <input type="hidden" name="success_url" value="${esc(_successUrl)}" />
      <input type="hidden" name="failure_url" value="${esc(_failureUrl)}" />
      <input type="hidden" name="signed_field_names" value="${esc(p.signedFieldNames)}" />
      <input type="hidden" name="signature" value="${esc(p.signature)}" />
    </form>

    <script>
      document.getElementById('esewaForm').submit();
    </script>
  </body>
</html>
''';

    return html;
  }

  String _buildLegacyAutoSubmitFormHtml() {
    final p = widget.paymentInit;

    String esc(String value) => value
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#39;');

    final amount = _amountForGateway(p.amount);

    return '''
<!doctype html>
<html>
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Redirecting to eSewa</title>
    <style>
      body { font-family: Arial, sans-serif; display: grid; place-items: center; height: 100vh; margin: 0; }
      .box { text-align: center; }
    </style>
  </head>
  <body>
    <div class="box">
      <h3>Redirecting to eSewa...</h3>
      <p>Please wait.</p>
    </div>
    <form id="esewaLegacyForm" action="${esc(EsewaConfig.legacyFormUrl)}" method="POST">
      <input type="hidden" name="amt" value="${esc(amount)}" />
      <input type="hidden" name="psc" value="0" />
      <input type="hidden" name="pdc" value="0" />
      <input type="hidden" name="txAmt" value="0" />
      <input type="hidden" name="tAmt" value="${esc(amount)}" />
      <input type="hidden" name="pid" value="${esc(p.transactionUuid)}" />
      <input type="hidden" name="scd" value="${esc(p.productCode)}" />
      <input type="hidden" name="su" value="${esc(_successUrl)}" />
      <input type="hidden" name="fu" value="${esc(_failureUrl)}" />
    </form>

    <script>
      document.getElementById('esewaLegacyForm').submit();
    </script>
  </body>
</html>
''';
  }

  String _amountForGateway(double amount) {
    final normalized = amount.toStringAsFixed(2);
    return normalized
        .replaceFirst(RegExp(r'\.00$'), '')
        .replaceFirst(RegExp(r'(\.\d*?)0+$'), r'$1');
  }

  Future<bool> _onWillPop() async {
    Navigator.of(context).pop(
      const EsewaWebViewResult(
        isSuccess: false,
        isCancelled: true,
        message: 'Payment flow cancelled by user.',
      ),
    );
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (_, __) {
        _onWillPop();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('eSewa Payment'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _onWillPop,
          ),
        ),
        body: Column(
          children: [
            if (_progress < 100)
              LinearProgressIndicator(value: _progress / 100),
            if (_loadError != null)
              Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  _loadError!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            Expanded(
              child: _isInitializing
                  ? const Center(child: CircularProgressIndicator())
                  : _controller != null
                  ? WebViewWidget(controller: _controller!)
                  : Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.open_in_browser,
                              size: 40,
                              color: Colors.orange,
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'In-app payment view is unavailable.',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'You can continue in an external browser.',
                              textAlign: TextAlign.center,
                            ),
                            if (_externalFallbackUri != null) ...[
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: _openExternalFallback,
                                icon: const Icon(Icons.open_in_new),
                                label: const Text('Open in browser'),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
