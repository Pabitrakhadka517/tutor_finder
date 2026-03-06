/// Response model for the forgot-password endpoint.
///
/// In development mode the backend returns optional [devResetLink] and
/// [emailPreviewUrl] fields so the developer can easily access the reset
/// token without checking emails.
class ForgotPasswordResponse {
  final String message;
  final String? devResetLink;
  final String? emailPreviewUrl;

  const ForgotPasswordResponse({
    required this.message,
    this.devResetLink,
    this.emailPreviewUrl,
  });

  factory ForgotPasswordResponse.fromJson(Map<String, dynamic> json) {
    return ForgotPasswordResponse(
      message: json['message'] as String? ?? '',
      devResetLink: json['devResetLink'] as String?,
      emailPreviewUrl: json['emailPreviewUrl'] as String?,
    );
  }

  /// Extract just the raw token from the devResetLink URL.
  /// The link format is: http://host/reset-password?token=<token>
  String? get resetToken {
    if (devResetLink == null) return null;
    final uri = Uri.tryParse(devResetLink!);
    return uri?.queryParameters['token'];
  }
}
