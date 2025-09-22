import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AchievementsPage extends StatefulWidget {
  const AchievementsPage({super.key});

  @override
  State<AchievementsPage> createState() => _AchievementsPageState();
}

class _AchievementsPageState extends State<AchievementsPage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  final UserAchievements achievements = UserAchievements();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Widget _buildBadgeCard(Map<String, dynamic> badge, bool isUnlocked) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey[850]!.withValues(alpha: 0.9)
                  : Colors.white,
              Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey[800]!.withValues(alpha: 0.7)
                  : Colors.grey[50]!.withValues(alpha: 0.9),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: isUnlocked
              ? [
                  BoxShadow(
                    color: badge['color'].withValues(alpha: 0.15),
                    spreadRadius: 2,
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    spreadRadius: 1,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
          border: Border.all(
            color: isUnlocked
                ? (badge['color'] as Color).withValues(alpha: 0.2)
                : Colors.grey[300]!.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    isUnlocked
                        ? badge['color'].withValues(alpha: 0.25)
                        : Colors.grey[300]!.withValues(alpha: 0.5),
                    isUnlocked
                        ? badge['color'].withValues(alpha: 0.15)
                        : Colors.grey[200]!.withValues(alpha: 0.5),
                  ],
                ),
                shape: BoxShape.circle,
                border: Border.all(
                  color: isUnlocked ? badge['color'] : Colors.grey[400]!,
                  width: 2,
                ),
                boxShadow: isUnlocked
                    ? [
                        BoxShadow(
                          color: badge['color'].withValues(alpha: 0.3),
                          spreadRadius: 1,
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Icon(
                badge['icon'],
                color: isUnlocked ? badge['color'] : Colors.grey[400],
                size: 28,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              badge['name'],
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).textTheme.bodyMedium?.color,
                letterSpacing: -0.3,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              badge['description'],
              style: GoogleFonts.inter(
                fontSize: 13,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey[300]
                    : Colors.grey[600],
                height: 1.4,
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.center,
            ),
            if (isUnlocked)
              Container(
                margin: const EdgeInsets.only(top: 12),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      badge['color'].withValues(alpha: 0.15),
                      badge['color'].withValues(alpha: 0.08),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: badge['color'].withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  'Unlocked ${badge['unlockedAt']}',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: badge['color'],
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                  ),
                ),
              )
            else if (badge.containsKey('progress'))
              Column(
                children: [
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey[700]!.withValues(alpha: 0.5)
                          : Colors.grey[100]!.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        LinearProgressIndicator(
                          value: badge['progress'],
                          backgroundColor:
                              Theme.of(context).brightness == Brightness.dark
                              ? Colors.grey[600]
                              : Colors.grey[300],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            badge['color'],
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${(badge['progress'] * 100).toInt()}% complete',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                ? Colors.grey[300]
                                : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard(Map<String, dynamic> feature) {
    bool isLocked = feature['locked'];
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isLocked
              ? (Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey.shade800
                        : Colors.white)
                    .withValues(alpha: 0.7)
              : Theme.of(context).brightness == Brightness.dark
              ? Colors.grey.shade800
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isLocked
              ? null
              : [
                  BoxShadow(
                    color: Theme.of(
                      context,
                    ).colorScheme.secondary.withValues(alpha: 0.1),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
          border: Border.all(
            color: isLocked
                ? Colors.grey[400]!
                : Theme.of(
                    context,
                  ).colorScheme.secondary.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    feature['name'],
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                ),
                if (isLocked)
                  const Icon(Icons.lock, color: Colors.grey, size: 20)
                else
                  Icon(Icons.check_circle, color: Colors.green, size: 20),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              feature['description'],
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey[400]
                    : Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            if (isLocked)
              LinearProgressIndicator(
                value: feature['points'] / feature['requiredPoints'],
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).colorScheme.secondary,
                ),
              ),
            if (isLocked) const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.stars,
                  size: 16,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                const SizedBox(width: 4),
                Text(
                  '${feature['points']}/${feature['requiredPoints']} points',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.secondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                if (isLocked)
                  Text(
                    '${feature['requiredPoints'] - feature['points']} more needed',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey[500]
                          : Colors.grey[400],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Achievements',
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
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            ScaleTransition(
              scale: _scaleAnimation,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.amber[400]!.withValues(alpha: 0.1),
                      Colors.amber[300]!.withValues(alpha: 0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.amber[400]!.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [Colors.amber[500]!, Colors.amber[300]!],
                        ),
                      ),
                      child: const Icon(
                        Icons.emoji_events,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Your Journey',
                            style: GoogleFonts.inter(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(
                                context,
                              ).textTheme.bodyMedium?.color,
                            ),
                          ),
                          Text(
                            '${achievements.unlockedBadges.length} badges unlocked',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: Colors.amber[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Unlocked Badges
            FadeTransition(
              opacity: _fadeAnimation,
              child: Text(
                'Unlocked Badges',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
            ),

            const SizedBox(height: 16),

            if (achievements.unlockedBadges.isEmpty)
              Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.emoji_events_outlined,
                      size: 60,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No badges unlocked yet',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey[400]
                            : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              )
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.85,
                ),
                itemCount: achievements.unlockedBadges.length,
                itemBuilder: (context, index) {
                  return _buildBadgeCard(
                    achievements.unlockedBadges[index],
                    true,
                  );
                },
              ),

            const SizedBox(height: 32),

            // Available Badges
            FadeTransition(
              opacity: _fadeAnimation,
              child: Text(
                'Earn More Badges',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
            ),

            const SizedBox(height: 16),

            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.85,
              ),
              itemCount: achievements.availableBadges.length,
              itemBuilder: (context, index) {
                return _buildBadgeCard(
                  achievements.availableBadges[index],
                  false,
                );
              },
            ),

            const SizedBox(height: 32),

            // Unlockable Features
            FadeTransition(
              opacity: _fadeAnimation,
              child: Text(
                'Premium Features',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
            ),

            const SizedBox(height: 16),

            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: achievements.unlockableFeatures.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                return _buildFeatureCard(
                  achievements.unlockableFeatures[index],
                );
              },
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class UserAchievements {
  List<Map<String, dynamic>> unlockedBadges = [
    {
      'name': 'First Steps',
      'description': 'Completed your profile',
      'icon': Icons.start,
      'color': Colors.blue,
      'unlockedAt': '2024-09-10',
    },
    {
      'name': 'Network Builder',
      'description': 'Connected with 5+ people',
      'icon': Icons.people,
      'color': Colors.green,
      'unlockedAt': '2024-09-12',
    },
    {
      'name': 'Mentor Seeker',
      'description': 'Requested mentorship',
      'icon': Icons.school,
      'color': Colors.purple,
      'unlockedAt': '2024-09-14',
    },
  ];

  List<Map<String, dynamic>> availableBadges = [
    {
      'name': 'Super Connector',
      'description': 'Connect with 20+ alumni',
      'icon': Icons.connect_without_contact,
      'color': Colors.orange,
      'progress': 0.7,
    },
    {
      'name': 'Profile Master',
      'description': 'Complete profile to 100%',
      'icon': Icons.verified,
      'color': Colors.teal,
      'progress': 0.85,
    },
    {
      'name': 'Opportunity Hunter',
      'description': 'Apply to 5 opportunities',
      'icon': Icons.business,
      'color': Colors.red,
      'progress': 0.4,
    },
    {
      'name': 'Mentor Guru',
      'description': 'Guide 10 mentees',
      'icon': Icons.star,
      'color': Colors.amber,
      'progress': 0.2,
    },
  ];

  List<Map<String, dynamic>> unlockableFeatures = [
    {
      'name': 'Premium Mentorship',
      'description': 'Access to premium mentors',
      'requiredPoints': 100,
      'points': 75,
      'locked': true,
    },
    {
      'name': 'Advanced Analytics',
      'description': 'Detailed profile insights',
      'requiredPoints': 150,
      'points': 120,
      'locked': true,
    },
    {
      'name': 'Priority Support',
      'description': '24/7 priority assistance',
      'requiredPoints': 200,
      'points': 180,
      'locked': true,
    },
    {
      'name': 'Exclusive Events',
      'description': 'Invite-only networking events',
      'requiredPoints': 250,
      'points': 230,
      'locked': true,
    },
  ];
}
