import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class IndustryTrendsPage extends StatefulWidget {
  const IndustryTrendsPage({super.key});

  @override
  State<IndustryTrendsPage> createState() => _IndustryTrendsPageState();
}

class _IndustryTrendsPageState extends State<IndustryTrendsPage>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue[700]!.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.trending_up, color: Colors.blue[700], size: 24),
            ),
            const SizedBox(width: 12),
            Text(
              'Industry Trends',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).appBarTheme.titleTextStyle?.color,
              ),
            ),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: Theme.of(context).colorScheme.secondary,
          unselectedLabelColor: Colors.grey[500],
          indicatorColor: Theme.of(context).colorScheme.secondary,
          indicatorWeight: 3,
          tabs: [
            Tab(
              icon: Icon(Icons.dashboard),
              text: 'Overview',
            ),
            Tab(
              icon: Icon(Icons.attach_money),
              text: 'Salary Data',
            ),
            Tab(
              icon: Icon(Icons.psychology),
              text: 'Skills Demand',
            ),
            Tab(
              icon: Icon(Icons.business),
              text: 'Companies',
            ),
            Tab(
              icon: Icon(Icons.lightbulb),
              text: 'Tech Trends',
            ),
            Tab(
              icon: Icon(Icons.school),
              text: 'Learning',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildSalaryTab(),
          _buildSkillsTab(),
          _buildCompaniesTab(),
          _buildTechnologyTab(),
          _buildLearningTab(),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Market Overview Cards
          Text(
            'Market Overview',
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
          const SizedBox(height: 16),

          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.2,
            children: [
              _buildTrendCard(
                context,
                'IT & Software',
                '+12.5%',
                'Growing fast',
                Colors.green,
                Icons.computer,
              ),
              _buildTrendCard(
                context,
                'Healthcare',
                '+8.3%',
                'Stable growth',
                Colors.blue,
                Icons.local_hospital,
              ),
              _buildTrendCard(
                context,
                'Finance',
                '+6.1%',
                'Moderate growth',
                Colors.orange,
                Icons.money,
              ),
              _buildTrendCard(
                context,
                'AI/ML',
                '+28.7%',
                'Hot sector',
                Colors.purple,
                Icons.psychology,
              ),
            ],
          ),

          const SizedBox(height: 32),

          // Top Industries Section
          Text(
            'Top Growing Industries',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
          const SizedBox(height: 16),

          _buildIndustryCard(
            context,
            'Artificial Intelligence',
            'AI and machine learning are transforming every industry',
            ['Machine Learning', 'Deep Learning', 'NLP'],
            Colors.purple,
            Icons.smart_toy,
          ),

          const SizedBox(height: 16),

          _buildIndustryCard(
            context,
            'Cybersecurity',
            'Critical need as digital threats increase globally',
            ['Ethical Hacking', 'Cloud Security', 'Risk Management'],
            Colors.red,
            Icons.security,
          ),

          const SizedBox(height: 16),

          _buildIndustryCard(
            context,
            'Renewable Energy',
            'Sustainable solutions driving market growth',
            ['Solar Technology', 'Wind Energy', 'Battery Storage'],
            Colors.green,
            Icons.energy_savings_leaf,
          ),
        ],
      ),
    );
  }

  Widget _buildSalaryTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Salary Trends by Industry',
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
          const SizedBox(height: 16),

          _buildSalaryCard(
            'Software Engineer',
            '₹8,00,000 - ₹25,00,000',
            '+18% YoY',
            'Entry Level: ₹8L\nMid Level: ₹15L\nSenior Level: ₹25L+',
            Colors.blue,
          ),

          const SizedBox(height: 16),

          _buildSalaryCard(
            'Data Scientist',
            '₹10,00,000 - ₹30,00,000',
            '+22% YoY',
            'Entry Level: ₹10L\nMid Level: ₹18L\nSenior Level: ₹30L+',
            Colors.purple,
          ),

          const SizedBox(height: 16),

          _buildSalaryCard(
            'UX Designer',
            '₹6,00,000 - ₹18,00,000',
            '+12% YoY',
            'Entry Level: ₹6L\nMid Level: ₹12L\nSenior Level: ₹18L+',
            Colors.orange,
          ),

          const SizedBox(height: 32),

          Text(
            'Location-wise Salary Variations',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
          const SizedBox(height: 16),

          _buildLocationSalary('Mumbai', 'Premium: +20%', Colors.red),
          const SizedBox(height: 12),
          _buildLocationSalary('Delhi NCR', 'Premium: +15%', Colors.orange),
          const SizedBox(height: 12),
          _buildLocationSalary('Bangalore', 'Premium: +12%', Colors.yellow),
          const SizedBox(height: 12),
          _buildLocationSalary('Chennai', 'Base: No premium', Colors.green),
        ],
      ),
    );
  }

  Widget _buildSkillsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'In-Demand Skills 2024-2025',
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
          const SizedBox(height: 16),

          Text(
            'Top skills employers are looking for',
            style: GoogleFonts.inter(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),

          _buildSkillCategory(
            'Technical Skills',
            [
              _buildSkillItem('Python Programming', '95%', Colors.blue),
              _buildSkillItem('Machine Learning', '92%', Colors.purple),
              _buildSkillItem('Cloud Computing (AWS/Azure)', '90%', Colors.orange),
              _buildSkillItem('React/JavaScript', '88%', Colors.green),
              _buildSkillItem('Data Analysis', '85%', Colors.teal),
            ],
          ),

          const SizedBox(height: 24),

          _buildSkillCategory(
            'Soft Skills',
            [
              _buildSkillItem('Problem Solving', '87%', Colors.indigo),
              _buildSkillItem('Communication', '85%', Colors.pink),
              _buildSkillItem('Leadership', '82%', Colors.brown),
              _buildSkillItem('Team Collaboration', '80%', Colors.cyan),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompaniesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Top Hiring Companies',
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
          const SizedBox(height: 16),

          _buildCompanyCard(
            'Google',
            'Technology',
            '5000+ openings',
            '₹25L+ avg salary',
            Colors.blue,
          ),

          const SizedBox(height: 16),

          _buildCompanyCard(
            'Microsoft',
            'Technology',
            '3000+ openings',
            '₹22L+ avg salary',
            Colors.green,
          ),

          const SizedBox(height: 16),

          _buildCompanyCard(
            'Amazon',
            'E-commerce',
            '4000+ openings',
            '₹20L+ avg salary',
            Colors.orange,
          ),

          const SizedBox(height: 32),

          Text(
            'Emerging Startups',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
          const SizedBox(height: 16),

          _buildStartupCard(
            'Unicorn Startup',
            'FinTech',
            'Series B: ₹500Cr',
            '100+ hires planned',
          ),

          const SizedBox(height: 12),

          _buildStartupCard(
            'HealthTech Innovator',
            'Healthcare',
            'Series A: ₹200Cr',
            '50+ hires planned',
          ),
        ],
      ),
    );
  }

  Widget _buildTechnologyTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Emerging Technologies',
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
          const SizedBox(height: 16),

          _buildTechTrendCard(
            'Artificial Intelligence',
            'Machine Learning, Deep Learning, Neural Networks',
            'High Demand',
            Colors.purple,
            Icons.smart_toy,
          ),

          const SizedBox(height: 16),

          _buildTechTrendCard(
            'Blockchain',
            'Distributed Ledger, Smart Contracts, DeFi',
            'Growing',
            Colors.blue,
            Icons.account_balance,
          ),

          const SizedBox(height: 16),

          _buildTechTrendCard(
            'Internet of Things',
            'IoT Sensors, Edge Computing, Smart Devices',
            'Expanding',
            Colors.green,
            Icons.device_hub,
          ),

          const SizedBox(height: 32),

          Text(
            'Future Skills to Learn',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
          const SizedBox(height: 16),

          _buildSkillRecommendation('Quantum Computing', 'Beginner to Advanced'),
          const SizedBox(height: 12),
          _buildSkillRecommendation('AR/VR Development', 'Intermediate'),
          const SizedBox(height: 12),
          _buildSkillRecommendation('Sustainable Tech', 'All Levels'),
        ],
      ),
    );
  }

  Widget _buildLearningTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recommended Learning Paths',
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
          const SizedBox(height: 16),

          _buildLearningPath(
            'Full Stack Developer',
            '6-12 months',
            ['Frontend (React)', 'Backend (Node.js)', 'Database', 'DevOps'],
            Colors.blue,
          ),

          const SizedBox(height: 16),

          _buildLearningPath(
            'Data Scientist',
            '8-14 months',
            ['Statistics', 'Python', 'Machine Learning', 'SQL'],
            Colors.purple,
          ),

          const SizedBox(height: 16),

          _buildLearningPath(
            'UX/UI Designer',
            '4-8 months',
            ['Design Principles', 'Figma', 'User Research', 'Prototyping'],
            Colors.orange,
          ),

          const SizedBox(height: 32),

          Text(
            'Popular Certifications',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
          const SizedBox(height: 16),

          _buildCertificationCard('AWS Solutions Architect', 'Cloud Computing'),
          const SizedBox(height: 12),
          _buildCertificationCard('Google Data Analytics', 'Data & Analytics'),
          const SizedBox(height: 12),
          _buildCertificationCard('Cisco CCNA', 'Networking'),
        ],
      ),
    );
  }

  // Helper methods for building cards and components

  Widget _buildTrendCard(
    BuildContext context,
    String industry,
    String growth,
    String status,
    Color color,
    IconData icon,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              industry,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              growth,
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              status,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIndustryCard(
    BuildContext context,
    String title,
    String description,
    List<String> skills,
    Color color,
    IconData icon,
  ) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                      ),
                      Text(
                        'Trending Now 🔥',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              description,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.grey[700],
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Key Skills:',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: skills.map((skill) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: color.withOpacity(0.3), width: 1),
                  ),
                  child: Text(
                    skill,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: color,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSalaryCard(
    String role,
    String range,
    String yoy,
    String breakdown,
    Color color,
  ) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    role,
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green[200]!, width: 1),
                  ),
                  child: Text(
                    yoy,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.green[700],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Salary Range: $range',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Level Breakdown:',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              breakdown,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: Colors.grey[700],
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationSalary(String city, String premium, Color dotColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!, width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: dotColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              city,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
          ),
          Text(
            premium,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillCategory(String title, List<Widget> skills) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
        const SizedBox(height: 16),
        ...skills,
      ],
    );
  }

  Widget _buildSkillItem(String skill, String demand, Color color) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Text(
                skill,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '$demand demand',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompanyCard(
    String name,
    String industry,
    String openings,
    String salary,
    Color color,
  ) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(Icons.business, color: color, size: 32),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: GoogleFonts.inter(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                      ),
                      Text(
                        industry,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        openings,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.green[700],
                        ),
                      ),
                      Text(
                        'Open Positions',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        salary,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue[700],
                        ),
                      ),
                      Text(
                        'Avg Salary',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.grey[600],
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

  Widget _buildStartupCard(String name, String industry, String funding, String hires) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!, width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.rocket_launch, color: Colors.grey[600], size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
                Text(
                  '$industry • $funding',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Text(
            hires,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTechTrendCard(
    String title,
    String description,
    String status,
    Color color,
    IconData icon,
  ) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, color: color, size: 32),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: status == 'High Demand'
                              ? Colors.red[50]
                              : status == 'Growing'
                              ? Colors.orange[50]
                              : Colors.green[50],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          status,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: status == 'High Demand'
                                ? Colors.red[700]
                                : status == 'Growing'
                                ? Colors.orange[700]
                                : Colors.green[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              description,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.grey[700],
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkillRecommendation(String skill, String level) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!, width: 1),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  skill,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
                Text(
                  'Recommended for: $level',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.school, size: 16),
            label: const Text('Learn'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.secondary,
              foregroundColor: Theme.of(context).colorScheme.onSecondary,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLearningPath(String title, String duration, List<String> skills, Color color) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    duration,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Required Skills:',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: skills.map((skill) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: color.withOpacity(0.3), width: 1),
                  ),
                  child: Text(
                    skill,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: color,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCertificationCard(String title, String category) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!, width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.workspace_premium,
              color: Theme.of(context).colorScheme.secondary,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
                Text(
                  category,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.open_in_new,
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
        ],
      ),
    );
  }
}
