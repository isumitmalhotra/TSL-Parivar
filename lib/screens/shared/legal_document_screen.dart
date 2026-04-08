import 'package:flutter/material.dart';

import '../../design_system/design_system.dart';

/// Lightweight in-app legal page so links always work even when external site is blocked.
class LegalDocumentScreen extends StatelessWidget {
  final String title;
  final List<String> sections;

  const LegalDocumentScreen({
    super.key,
    required this.title,
    required this.sections,
  });

  static const List<String> privacyPolicySections = [
    'Effective date: April 2, 2026',
    'TSL Parivar collects only the data required to provide dealer, mistri, and architect workflows. This may include your phone number, profile details, role, delivery activity, rewards activity, and notification preferences.',
    'We use this data to authenticate your account, link role-based workflows, process orders and deliveries, and send operational notifications. We do not sell personal information.',
    'Data is stored in secured backend systems and access is restricted based on your account role. We apply technical and organizational safeguards to reduce unauthorized access risk.',
    'If you need data correction, deletion, or support, contact support@tslsteel.com. Some records may be retained where legally required or needed for operational audit trails.',
  ];

  static const List<String> termsOfServiceSections = [
    'Effective date: April 2, 2026',
    'By using TSL Parivar, you agree to provide accurate account details and use the app only for lawful business operations related to TSL workflows.',
    'You are responsible for activity performed from your account. Keep your login and OTP access secure and report unauthorized access promptly.',
    'Features, rewards, and operational flows may change over time. Misuse, fraud, or policy violations can result in restricted access or account suspension.',
    'For support, disputes, or policy clarifications, contact support@tslsteel.com.',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(title),
        backgroundColor: AppColors.cardWhite,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(AppSpacing.lg),
        itemCount: sections.length,
        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
        itemBuilder: (context, index) {
          return Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.cardWhite,
              borderRadius: BorderRadius.circular(16),
              boxShadow: AppShadows.xs,
            ),
            child: Text(
              sections[index],
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textPrimary,
                height: 1.45,
              ),
            ),
          );
        },
      ),
    );
  }
}
