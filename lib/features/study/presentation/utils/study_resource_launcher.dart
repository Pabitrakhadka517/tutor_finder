import 'package:url_launcher/url_launcher.dart';

import '../../../../core/api/api_endpoints.dart';
import '../../domain/entities/study_resource_entity.dart';

class StudyResourceLauncher {
  StudyResourceLauncher._();

  static Future<bool> open(StudyResourceEntity resource) async {
    final uri = _resolveUri(resource.url);
    if (uri == null) return false;

    try {
      final external = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (external) return true;

      return await launchUrl(uri, mode: LaunchMode.platformDefault);
    } catch (_) {
      return false;
    }
  }

  static Uri? _resolveUri(String? rawUrl) {
    final raw = (rawUrl ?? '').trim();
    if (raw.isEmpty) return null;

    final normalized = raw.replaceAll('\\', '/');
    final isAbsolute =
        normalized.startsWith('http://') || normalized.startsWith('https://');

    final candidate = isAbsolute
        ? normalized
        : (ApiEndpoints.getImageUrl(normalized) ?? normalized);

    final encodedCandidate = Uri.encodeFull(candidate);

    try {
      final uri = Uri.parse(encodedCandidate);
      if (!uri.hasScheme) return null;
      return uri;
    } catch (_) {
      return null;
    }
  }
}
