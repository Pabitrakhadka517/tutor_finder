import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/tutor_providers.dart';
import '../widgets/document_capture_widget.dart';

/// Page for tutors to submit their profile for verification.
/// The backend endpoint POST /api/tutors/my/verify/submit sets status to PENDING.
class VerificationSubmissionPage extends ConsumerStatefulWidget {
  const VerificationSubmissionPage({super.key});

  @override
  ConsumerState<VerificationSubmissionPage> createState() =>
      _VerificationSubmissionPageState();
}

class _VerificationSubmissionPageState
    extends ConsumerState<VerificationSubmissionPage> {
  bool _isSubmitting = false;
  bool _submitted = false;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _submitForVerification() async {
    setState(() => _isSubmitting = true);

    final repo = ref.read(tutorRepositoryProvider);
    final result = await repo.submitForVerification();

    result.fold(
      (failure) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed: ${failure.message}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      (_) {
        if (mounted) {
          setState(() => _submitted = true);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Verification request submitted! Our team will review your profile.',
              ),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );
        }
      },
    );

    if (mounted) setState(() => _isSubmitting = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verification'),
        backgroundColor: Colors.cyan.shade700,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildStatusCard(),
            const SizedBox(height: 32),
            _buildRequirements(),
            const SizedBox(height: 32),
            if (!_submitted) _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    late Color color;
    late IconData icon;
    late String title;
    late String subtitle;

    if (_submitted) {
      color = Colors.orange;
      icon = Icons.hourglass_top;
      title = 'Pending Review';
      subtitle =
          'Your verification request is being reviewed. This usually takes 1-3 business days.';
    } else {
      color = Colors.cyan;
      icon = Icons.shield_outlined;
      title = 'Get Verified';
      subtitle =
          'Submit your profile for verification to build trust with students and get discovered easily.';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withValues(alpha: 0.1), color.withValues(alpha: 0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 48),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequirements() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DocumentCaptureWidget(
          label: '1. National ID / Citizenship (Photo)',
          onFileCaptured: (file) {
            // Logic to store ID photo for submission
          },
        ),
        const SizedBox(height: 20),
        DocumentCaptureWidget(
          label: '2. Educational Certificate (Photo)',
          onFileCaptured: (file) {
            // Logic to store Certificate photo for submission
          },
        ),
        const SizedBox(height: 32),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Verification Requirements Status',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade900,
                ),
              ),
              const SizedBox(height: 16),
              _requirementItem(
                Icons.person,
                'Complete Profile',
                'Full name, bio, and profile picture',
              ),
              _requirementItem(
                Icons.school,
                'Education Details',
                'Add your qualifications and experience',
              ),
              _requirementItem(
                Icons.subject,
                'Subject Expertise',
                'List at least one subject you teach',
              ),
              _requirementItem(
                Icons.attach_money,
                'Hourly Rate',
                'Set your tutoring rate',
              ),
              _requirementItem(
                Icons.schedule,
                'Availability',
                'Add at least one availability slot',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _requirementItem(IconData icon, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.cyan.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.cyan.shade700, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _isSubmitting ? null : _submitForVerification,
        icon: _isSubmitting
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.send),
        label: Text(
          _isSubmitting ? 'Submitting...' : 'Submit for Verification',
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.cyan.shade700,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
