import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TermsAndConditionsPage extends StatefulWidget {
  const TermsAndConditionsPage({super.key});

  @override
  State<TermsAndConditionsPage> createState() => _TermsAndConditionsPageState();
}

class _TermsAndConditionsPageState extends State<TermsAndConditionsPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Terms & Conditions',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).appBarTheme.titleTextStyle?.color,
          ),
        ),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Center(
              child: Text(
                'Terms and Conditions',
                style: GoogleFonts.inter(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                'Last Updated: September 20, 2025',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey[400]
                      : Colors.grey[600],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Content
            _buildSection(
              context,
              '1. Introduction',
              'Welcome to NextStep ("we," "us," or "our"), an alumni networking and career development platform. These Terms and Conditions ("Terms") constitute a legally binding agreement between you and NextStep. By accessing, registering, or using our services, you agree to be bound by these Terms. If you do not agree with these Terms, please do not use our services.',
            ),

            _buildSection(
              context,
              '2. Description of Service',
              'NextStep provides a comprehensive platform that includes, but is not limited to:\n\n'
              '• Professional networking between alumni, students, and employers\n'
              '• Career development tools and resources\n'
              '• AI-powered resume building and analysis\n'
              '• Job and internship opportunity listings\n'
              '• Mentorship program connections\n'
              '• Skill assessment and career guidance\n'
              '• Professional forums and community features\n'
              '• Profile analytics and engagement tracking\n'
              '• Academic and professional achievement tracking',
            ),

            _buildSection(
              context,
              '3. User Eligibility and Account Creation',
              '3.1 Eligibility Requirements: To use NextStep, you must:\n'
              '• Be at least 13 years old, or the age of majority in your jurisdiction\n'
              '• Be currently enrolled as a student, employed, or a recent graduate/alumni\n'
              '• Provide accurate, current, and complete information during registration\n\n'
              '3.2 Account Creation: You may need to create an account to access certain features. You are responsible for maintaining the confidentiality of your account credentials and agree to notify us immediately of any unauthorized access.\n\n'
              '3.3 Account Suspension: We reserve the right to suspend or terminate accounts that violate these Terms or engage in prohibited activities.',
            ),

            _buildSection(
              context,
              '4. User Conduct and Responsibilities',
              '4.1 Acceptable Use: You agree to use NextStep only for lawful purposes and in accordance with these Terms. You shall not:\n'
              '• Post, transmit, or share content that is harmful, offensive, discriminatory, or illegal\n'
              '• Impersonate others or misrepresent your identity or qualifications\n'
              '• Use the platform for spam, solicitation, or commercial purposes without permission\n'
              '• Attempt to gain unauthorized access to our systems or user data\n'
              '• Distribute malware, viruses, or harmful code\n\n'
              '4.2 Content Guidelines: All user-generated content must adhere to our community standards and shall not contain:\n'
              '• Harmful, harassing, or abusive content\n'
              '• Discriminatory or hate speech\n'
              '• Copyright infringing material\n'
              '• False or misleading information\n'
              '• Spam or unsolicited advertisements',
            ),

            _buildSection(
              context,
              '5. Intellectual Property Rights',
              '5.1 Our Content: All content, trademarks, logos, and intellectual property on NextStep are owned by us or licensed to us. You may not reproduce, distribute, or create derivative works without permission.\n\n'
              '5.2 User Content: You retain ownership of content you submit but grant us a license to use, display, and distribute it within our platform. This license survives account termination.\n\n'
              '5.3 AI-Generated Content: For content generated by our AI services, you agree that such content may be used to improve our AI models, in accordance with our Privacy Policy.',
            ),

            _buildSection(
              context,
              '6. Privacy and Data Protection',
              'Your privacy is important to us. Our Privacy Policy explains how we collect, use, and protect your personal information. By using NextStep, you consent to our data practices as described in our Privacy Policy, which is incorporated by reference into these Terms.',
            ),

            _buildSection(
              context,
              '7. Career Services and Disclaimers',
              '7.1 Career Advice: NextStep provides informational content about careers, but is not a substitute for professional counseling. We do not guarantee job placements, internships, or career outcomes.\n\n'
              '7.2 Third-Party Content: We may provide information about opportunities from third parties. We do not endorse, guarantee, or assume responsibility for third-party offerings.\n\n'
              '7.3 AI Assistance: Our AI-powered services are tools to assist your career development. Final decisions about careers, resumes, and applications remain your responsibility.',
            ),

            _buildSection(
              context,
              '8. Payment Terms (if applicable)',
              '8.1 Subscription Services: If you subscribe to premium features, you agree to pay all applicable fees. Subscriptions may auto-renew unless cancelled.\n\n'
              '8.2 Refunds: Refund policies will be provided for applicable services.\n\n'
              '8.3 Price Changes: We reserve the right to modify pricing with advance notice.',
            ),

            _buildSection(
              context,
              '9. Service Availability and Modifications',
              '9.1 Availability: We strive to provide continuous service but make no guarantees about uptime or availability.\n\n'
              '9.2 Service Changes: We may modify or discontinue services with notice.\n\n'
              '9.3 Maintenance: Planned outages will be communicated in advance when possible.',
            ),

            _buildSection(
              context,
              '10. Termination and Account Deletion',
              '10.1 User Termination: You may request account deletion at any time by contacting support.\n\n'
              '10.2 Our Termination: We may terminate or suspend access for violations of these Terms.\n\n'
              '10.3 Data Deletion: Upon account deletion, we may retain certain data as required by law.',
            ),

            _buildSection(
              context,
              '11. Limitation of Liability',
              'To the maximum extent permitted by law, NextStep shall not be liable for any indirect, incidental, special, consequential, or punitive damages. Our total liability shall not exceed the amount paid by you for the service in the 12 months preceding the claim.',
            ),

            _buildSection(
              context,
              '12. Indemnification',
              'You agree to indemnify and hold NextStep harmless from any claims, damages, or expenses arising from your use of the service, violation of these Terms, or infringement of third-party rights.',
            ),

            _buildSection(
              context,
              '13. Governing Law and Dispute Resolution',
              '13.1 Governing Law: These Terms are governed by the laws of the jurisdiction where our company is headquartered.\n\n'
              '13.2 Dispute Resolution: We encourage amicable resolution of disputes. For unresolved disputes, you agree to resolve claims through binding arbitration.',
            ),

            _buildSection(
              context,
              '14. Changes to Terms',
              'We may update these Terms periodically. Significant changes will be communicated via email or in-app notifications. Continued use constitutes acceptance of updated Terms.',
            ),

            _buildSection(
              context,
              '15. Contact Information',
              'If you have questions about these Terms, please contact us at:\n\n'
              'Email: legal@nextstep.com\n'
              'Address: [Company Address]\n'
              'Phone: [Contact Phone Number]',
            ),

            const SizedBox(height: 40),

            // Acceptance Checkbox (Optional)
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Acknowledgment',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'By using NextStep, you acknowledge that you have read, understood, and agree to be bound by these Terms and Conditions.',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          content,
          style: GoogleFonts.inter(
            fontSize: 14,
            height: 1.6,
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
