class EsewaConfig {
  EsewaConfig._();

  static const String _sandboxFormUrl =
      'https://rc-epay.esewa.com.np/api/epay/main/v2/form';
  static const String _productionFormUrl =
      'https://epay.esewa.com.np/api/epay/main/v2/form';
  static const String _legacySandboxFormUrl =
      'https://uat.esewa.com.np/epay/main';
  static const String _legacyProductionFormUrl =
      'https://esewa.com.np/epay/main';

  static const bool useProduction = bool.fromEnvironment(
    'ESEWA_PRODUCTION',
    defaultValue: false,
  );

  static const String formUrlOverride = String.fromEnvironment(
    'ESEWA_FORM_URL',
    defaultValue: '',
  );

  static const bool strictMode = bool.fromEnvironment(
    'ESEWA_STRICT_MODE',
    defaultValue: true,
  );

  static const bool _allowLegacyApiFallbackFromEnv = bool.fromEnvironment(
    'ESEWA_ALLOW_LEGACY_API_FALLBACK',
    defaultValue: false,
  );

  static const bool _allowUnsignedFormFallbackFromEnv = bool.fromEnvironment(
    'ESEWA_ALLOW_UNSIGNED_FORM_FALLBACK',
    defaultValue: false,
  );

  static const String appSuccessUrl = String.fromEnvironment(
    'ESEWA_APP_SUCCESS_URL',
    defaultValue: '',
  );

  static const String appFailureUrl = String.fromEnvironment(
    'ESEWA_APP_FAILURE_URL',
    defaultValue: '',
  );

  static String get formUrl {
    if (formUrlOverride.trim().isNotEmpty) {
      return formUrlOverride;
    }
    return useProduction ? _productionFormUrl : _sandboxFormUrl;
  }

  static String get legacyFormUrl {
    if (formUrlOverride.trim().isNotEmpty) {
      return formUrlOverride;
    }
    return useProduction ? _legacyProductionFormUrl : _legacySandboxFormUrl;
  }

  /// In debug, fallback is enabled by default so legacy backend routes still work.
  /// In release/profile, fallback stays disabled unless explicitly enabled.
  static bool get allowLegacyApiFallback {
    return _allowLegacyApiFallbackFromEnv;
  }

  /// In debug, unsigned form fallback is enabled by default for legacy payloads.
  /// In release/profile, it is disabled unless explicitly enabled.
  static bool get allowUnsignedFormFallback {
    return _allowUnsignedFormFallbackFromEnv;
  }

  static String resolveSuccessUrl(String backendSuccessUrl) {
    if (appSuccessUrl.trim().isNotEmpty) {
      return appSuccessUrl;
    }
    return backendSuccessUrl;
  }

  static String resolveFailureUrl(String backendFailureUrl) {
    if (appFailureUrl.trim().isNotEmpty) {
      return appFailureUrl;
    }
    return backendFailureUrl;
  }
}
