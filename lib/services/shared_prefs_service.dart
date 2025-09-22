import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class SharedPrefsService {
  static const String _bookmarksKey = 'bookmarks';
  static const String _appliedJobsKey = 'applied_jobs';
  static const String _userNameKey = 'user_name';
  static const String _userEmailKey = 'user_email';
  static const String _userBioKey = 'user_bio';
  static const String _userTypeKey = 'user_type';
  static const String _skillsKey = 'skills';
  static const String _educationKey = 'education';
  static const String _appliedJobsHistoryKey = 'applied_jobs_history';
  static const String _savedSearchesKey = 'saved_searches';

  // Advanced Profile Features Keys
  static const String _profilePictureKey = 'profile_picture';
  static const String _socialLinksKey = 'social_links';
  static const String _portfolioProjectsKey = 'portfolio_projects';
  static const String _certificationsKey = 'certifications';
  static const String _contactInfoKey = 'contact_info';
  static const String _privacySettingsKey = 'privacy_settings';
  static const String _profileAnalyticsKey = 'profile_analytics';
  static const String _resumeKey = 'resume_data';
  static const String _activityTimelineKey = 'activity_timeline';
  static const String _skillsWithProficiencyKey = 'skills_with_proficiency';
  static const String _careerGoalsKey = 'career_goals';
  static const String _languagesKey = 'languages';
  static const String _awardsKey = 'awards';
  static const String _profileCompletionKey = 'profile_completion';

  static Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  // Bookmarks
  static Future<Set<String>> getBookmarks() async {
    final prefs = await _prefs;
    final bookmarksJson = prefs.getStringList(_bookmarksKey);
    if (bookmarksJson != null) {
      return bookmarksJson.toSet();
    }
    return {};
  }

  static Future<void> saveBookmarks(Set<String> bookmarks) async {
    final prefs = await _prefs;
    await prefs.setStringList(_bookmarksKey, bookmarks.toList());
  }

  static Future<void> addBookmark(String jobId) async {
    final bookmarks = await getBookmarks();
    bookmarks.add(jobId);
    await saveBookmarks(bookmarks);
  }

  static Future<void> removeBookmark(String jobId) async {
    final bookmarks = await getBookmarks();
    bookmarks.remove(jobId);
    await saveBookmarks(bookmarks);
  }

  // Applied Jobs (with status)
  static Future<Map<String, String>> getAppliedJobs() async {
    final prefs = await _prefs;
    final appliedJobsJson = prefs.getString(_appliedJobsKey);
    if (appliedJobsJson != null) {
      try {
        return Map<String, String>.from(json.decode(appliedJobsJson));
      } catch (e) {
        return {};
      }
    }
    return {};
  }

  static Future<void> saveAppliedJobs(Map<String, String> appliedJobs) async {
    final prefs = await _prefs;
    await prefs.setString(_appliedJobsKey, json.encode(appliedJobs));
  }

  static Future<void> addAppliedJob(String jobId, String status) async {
    final appliedJobs = await getAppliedJobs();
    appliedJobs[jobId] = status;
    await saveAppliedJobs(appliedJobs);
  }

  static Future<void> updateAppliedJobStatus(String jobId, String status) async {
    await addAppliedJob(jobId, status);
  }

  static Future<void> removeAppliedJob(String jobId) async {
    final appliedJobs = await getAppliedJobs();
    appliedJobs.remove(jobId);
    await saveAppliedJobs(appliedJobs);
  }

  // Applied Jobs History (for profile page)
  static Future<List<Map<String, String>>> getAppliedJobsHistory() async {
    final prefs = await _prefs;
    final historyJson = prefs.getStringList(_appliedJobsHistoryKey);
    if (historyJson != null) {
      return historyJson.map((item) => Map<String, String>.from(json.decode(item))).toList();
    }
    return [];
  }

  static Future<void> saveAppliedJobsHistory(List<Map<String, String>> history) async {
    final prefs = await _prefs;
    final historyJson = history.map((item) => json.encode(item)).toList();
    await prefs.setStringList(_appliedJobsHistoryKey, historyJson);
  }

  static Future<void> addAppliedJobHistory(Map<String, String> jobData) async {
    final history = await getAppliedJobsHistory();
    history.add(jobData);
    await saveAppliedJobsHistory(history);
  }

  // User Data
  static Future<String?> getUserName() async {
    final prefs = await _prefs;
    return prefs.getString(_userNameKey);
  }

  static Future<void> saveUserName(String name) async {
    final prefs = await _prefs;
    await prefs.setString(_userNameKey, name);
  }

  static Future<String?> getUserEmail() async {
    final prefs = await _prefs;
    return prefs.getString(_userEmailKey);
  }

  static Future<void> saveUserEmail(String email) async {
    final prefs = await _prefs;
    await prefs.setString(_userEmailKey, email);
  }

  static Future<String?> getUserBio() async {
    final prefs = await _prefs;
    return prefs.getString(_userBioKey);
  }

  static Future<void> saveUserBio(String bio) async {
    final prefs = await _prefs;
    await prefs.setString(_userBioKey, bio);
  }

  static Future<String?> getUserType() async {
    final prefs = await _prefs;
    return prefs.getString(_userTypeKey);
  }

  static Future<void> saveUserType(String type) async {
    final prefs = await _prefs;
    await prefs.setString(_userTypeKey, type);
  }

  static Future<List<String>> getSkills() async {
    final prefs = await _prefs;
    return prefs.getStringList(_skillsKey) ?? [];
  }

  static Future<void> saveSkills(List<String> skills) async {
    final prefs = await _prefs;
    await prefs.setStringList(_skillsKey, skills);
  }

  static Future<Map<String, String>> getEducation() async {
    final prefs = await _prefs;
    final educationJson = prefs.getString(_educationKey);
    if (educationJson != null) {
      try {
        return Map<String, String>.from(json.decode(educationJson));
      } catch (e) {
        return {};
      }
    }
    return {};
  }

  static Future<void> saveEducation(Map<String, String> education) async {
    final prefs = await _prefs;
    await prefs.setString(_educationKey, json.encode(education));
  }

  // Saved Searches
  static Future<List<Map<String, dynamic>>> getSavedSearches() async {
    final prefs = await _prefs;
    final searchesJson = prefs.getStringList(_savedSearchesKey);
    if (searchesJson != null) {
      return searchesJson.map((item) => Map<String, dynamic>.from(json.decode(item))).toList();
    }
    return [];
  }

  static Future<void> saveSavedSearches(List<Map<String, dynamic>> searches) async {
    final prefs = await _prefs;
    final searchesJson = searches.map((item) => json.encode(item)).toList();
    await prefs.setStringList(_savedSearchesKey, searchesJson);
  }

  static Future<void> addSavedSearch(Map<String, dynamic> search) async {
    final searches = await getSavedSearches();
    searches.add(search);
    await saveSavedSearches(searches);
  }

  static Future<void> removeSavedSearch(int index) async {
    final searches = await getSavedSearches();
    if (index >= 0 && index < searches.length) {
      searches.removeAt(index);
      await saveSavedSearches(searches);
    }
  }

  // Advanced Profile Features Methods

  // Profile Picture
  static Future<String?> getProfilePicture() async {
    final prefs = await _prefs;
    return prefs.getString(_profilePictureKey);
  }

  static Future<void> saveProfilePicture(String imagePath) async {
    final prefs = await _prefs;
    await prefs.setString(_profilePictureKey, imagePath);
  }

  // Social Media Links
  static Future<Map<String, String>> getSocialLinks() async {
    final prefs = await _prefs;
    final socialLinksJson = prefs.getString(_socialLinksKey);
    if (socialLinksJson != null) {
      try {
        return Map<String, String>.from(json.decode(socialLinksJson));
      } catch (e) {
        return {};
      }
    }
    return {};
  }

  static Future<void> saveSocialLinks(Map<String, String> socialLinks) async {
    final prefs = await _prefs;
    await prefs.setString(_socialLinksKey, json.encode(socialLinks));
  }

  // Portfolio Projects
  static Future<List<Map<String, dynamic>>> getPortfolioProjects() async {
    final prefs = await _prefs;
    final projectsJson = prefs.getStringList(_portfolioProjectsKey);
    if (projectsJson != null) {
      return projectsJson.map((item) => Map<String, dynamic>.from(json.decode(item))).toList();
    }
    return [];
  }

  static Future<void> savePortfolioProjects(List<Map<String, dynamic>> projects) async {
    final prefs = await _prefs;
    final projectsJson = projects.map((item) => json.encode(item)).toList();
    await prefs.setStringList(_portfolioProjectsKey, projectsJson);
  }

  static Future<void> addPortfolioProject(Map<String, dynamic> project) async {
    final projects = await getPortfolioProjects();
    projects.add(project);
    await savePortfolioProjects(projects);
  }

  // Certifications
  static Future<List<Map<String, String>>> getCertifications() async {
    final prefs = await _prefs;
    final certificationsJson = prefs.getStringList(_certificationsKey);
    if (certificationsJson != null) {
      return certificationsJson.map((item) => Map<String, String>.from(json.decode(item))).toList();
    }
    return [];
  }

  static Future<void> saveCertifications(List<Map<String, String>> certifications) async {
    final prefs = await _prefs;
    final certificationsJson = certifications.map((item) => json.encode(item)).toList();
    await prefs.setStringList(_certificationsKey, certificationsJson);
  }

  static Future<void> addCertification(Map<String, String> certification) async {
    final certifications = await getCertifications();
    certifications.add(certification);
    await saveCertifications(certifications);
  }

  // Contact Information
  static Future<Map<String, String>> getContactInfo() async {
    final prefs = await _prefs;
    final contactInfoJson = prefs.getString(_contactInfoKey);
    if (contactInfoJson != null) {
      try {
        return Map<String, String>.from(json.decode(contactInfoJson));
      } catch (e) {
        return {};
      }
    }
    return {};
  }

  static Future<void> saveContactInfo(Map<String, String> contactInfo) async {
    final prefs = await _prefs;
    await prefs.setString(_contactInfoKey, json.encode(contactInfo));
  }

  // Privacy Settings
  static Future<Map<String, bool>> getPrivacySettings() async {
    final prefs = await _prefs;
    final privacyJson = prefs.getString(_privacySettingsKey);
    if (privacyJson != null) {
      try {
        return Map<String, bool>.from(json.decode(privacyJson));
      } catch (e) {
        return {};
      }
    }
    return {};
  }

  static Future<void> savePrivacySettings(Map<String, bool> privacySettings) async {
    final prefs = await _prefs;
    await prefs.setString(_privacySettingsKey, json.encode(privacySettings));
  }

  // Profile Analytics
  static Future<Map<String, dynamic>> getProfileAnalytics() async {
    final prefs = await _prefs;
    final analyticsJson = prefs.getString(_profileAnalyticsKey);
    if (analyticsJson != null) {
      try {
        return Map<String, dynamic>.from(json.decode(analyticsJson));
      } catch (e) {
        return {};
      }
    }
    return {};
  }

  static Future<void> saveProfileAnalytics(Map<String, dynamic> analytics) async {
    final prefs = await _prefs;
    await prefs.setString(_profileAnalyticsKey, json.encode(analytics));
  }

  static Future<void> incrementProfileViews() async {
    final analytics = await getProfileAnalytics();
    int views = analytics['profileViews'] ?? 0;
    analytics['profileViews'] = views + 1;
    await saveProfileAnalytics(analytics);
  }

  // Resume/CV Data
  static Future<Map<String, String>> getResumeData() async {
    final prefs = await _prefs;
    final resumeJson = prefs.getString(_resumeKey);
    if (resumeJson != null) {
      try {
        return Map<String, String>.from(json.decode(resumeJson));
      } catch (e) {
        return {};
      }
    }
    return {};
  }

  static Future<void> saveResumeData(Map<String, String> resumeData) async {
    final prefs = await _prefs;
    await prefs.setString(_resumeKey, json.encode(resumeData));
  }

  // Activity Timeline
  static Future<List<Map<String, dynamic>>> getActivityTimeline() async {
    final prefs = await _prefs;
    final timelineJson = prefs.getStringList(_activityTimelineKey);
    if (timelineJson != null) {
      return timelineJson.map((item) => Map<String, dynamic>.from(json.decode(item))).toList();
    }
    return [];
  }

  static Future<void> saveActivityTimeline(List<Map<String, dynamic>> timeline) async {
    final prefs = await _prefs;
    final timelineJson = timeline.map((item) => json.encode(item)).toList();
    await prefs.setStringList(_activityTimelineKey, timelineJson);
  }

  static Future<void> addActivity(Map<String, dynamic> activity) async {
    final timeline = await getActivityTimeline();
    timeline.insert(0, activity); // Add to beginning for most recent first
    await saveActivityTimeline(timeline);
  }

  // Skills with Proficiency
  static Future<Map<String, String>> getSkillsWithProficiency() async {
    final prefs = await _prefs;
    final skillsJson = prefs.getString(_skillsWithProficiencyKey);
    if (skillsJson != null) {
      try {
        return Map<String, String>.from(json.decode(skillsJson));
      } catch (e) {
        return {};
      }
    }
    return {};
  }

  static Future<void> saveSkillsWithProficiency(Map<String, String> skills) async {
    final prefs = await _prefs;
    await prefs.setString(_skillsWithProficiencyKey, json.encode(skills));
  }

  // Career Goals
  static Future<List<String>> getCareerGoals() async {
    final prefs = await _prefs;
    return prefs.getStringList(_careerGoalsKey) ?? [];
  }

  static Future<void> saveCareerGoals(List<String> goals) async {
    final prefs = await _prefs;
    await prefs.setStringList(_careerGoalsKey, goals);
  }

  // Languages
  static Future<Map<String, String>> getLanguages() async {
    final prefs = await _prefs;
    final languagesJson = prefs.getString(_languagesKey);
    if (languagesJson != null) {
      try {
        return Map<String, String>.from(json.decode(languagesJson));
      } catch (e) {
        return {};
      }
    }
    return {};
  }

  static Future<void> saveLanguages(Map<String, String> languages) async {
    final prefs = await _prefs;
    await prefs.setString(_languagesKey, json.encode(languages));
  }

  // Awards and Recognition
  static Future<List<Map<String, String>>> getAwards() async {
    final prefs = await _prefs;
    final awardsJson = prefs.getStringList(_awardsKey);
    if (awardsJson != null) {
      return awardsJson.map((item) => Map<String, String>.from(json.decode(item))).toList();
    }
    return [];
  }

  static Future<void> saveAwards(List<Map<String, String>> awards) async {
    final prefs = await _prefs;
    final awardsJson = awards.map((item) => json.encode(item)).toList();
    await prefs.setStringList(_awardsKey, awardsJson);
  }

  static Future<void> addAward(Map<String, String> award) async {
    final awards = await getAwards();
    awards.add(award);
    await saveAwards(awards);
  }

  // Profile Completion
  static Future<int> getProfileCompletion() async {
    final prefs = await _prefs;
    return prefs.getInt(_profileCompletionKey) ?? 0;
  }

  static Future<void> saveProfileCompletion(int completion) async {
    final prefs = await _prefs;
    await prefs.setInt(_profileCompletionKey, completion);
  }

  static Future<void> updateProfileCompletion() async {
    int completion = 0;
    int totalFields = 15; // Total number of profile fields

    // Check each field and increment completion
    final userName = await getUserName();
    if (userName != null && userName.isNotEmpty) completion++;

    final userEmail = await getUserEmail();
    if (userEmail != null && userEmail.isNotEmpty) completion++;

    final userBio = await getUserBio();
    if (userBio != null && userBio.isNotEmpty) completion++;

    final skills = await getSkills();
    if (skills.isNotEmpty) completion++;

    final education = await getEducation();
    if (education.isNotEmpty) completion++;

    final profilePicture = await getProfilePicture();
    if (profilePicture != null && profilePicture.isNotEmpty) completion++;

    final socialLinks = await getSocialLinks();
    if (socialLinks.isNotEmpty) completion++;

    final portfolioProjects = await getPortfolioProjects();
    if (portfolioProjects.isNotEmpty) completion++;

    final certifications = await getCertifications();
    if (certifications.isNotEmpty) completion++;

    final contactInfo = await getContactInfo();
    if (contactInfo.isNotEmpty) completion++;

    final skillsWithProficiency = await getSkillsWithProficiency();
    if (skillsWithProficiency.isNotEmpty) completion++;

    final careerGoals = await getCareerGoals();
    if (careerGoals.isNotEmpty) completion++;

    final languages = await getLanguages();
    if (languages.isNotEmpty) completion++;

    final awards = await getAwards();
    if (awards.isNotEmpty) completion++;

    final resumeData = await getResumeData();
    if (resumeData.isNotEmpty) completion++;

    int percentage = ((completion / totalFields) * 100).round();
    await saveProfileCompletion(percentage);
  }

  // Clear all data
  static Future<void> clearAllData() async {
    final prefs = await _prefs;
    await prefs.clear();
  }

  // Logout (clear user-specific data but keep app data)
  static Future<void> logout() async {
    final prefs = await _prefs;
    // Clear user data but keep app data like bookmarks if needed
    await prefs.remove(_userNameKey);
    await prefs.remove(_userEmailKey);
    await prefs.remove(_userBioKey);
    await prefs.remove(_userTypeKey);
    await prefs.remove(_skillsKey);
    await prefs.remove(_educationKey);
    await prefs.remove(_appliedJobsHistoryKey);
    // Optionally clear applied jobs status too
    await prefs.remove(_appliedJobsKey);

    // Clear advanced profile data
    await prefs.remove(_profilePictureKey);
    await prefs.remove(_socialLinksKey);
    await prefs.remove(_portfolioProjectsKey);
    await prefs.remove(_certificationsKey);
    await prefs.remove(_contactInfoKey);
    await prefs.remove(_privacySettingsKey);
    await prefs.remove(_profileAnalyticsKey);
    await prefs.remove(_resumeKey);
    await prefs.remove(_activityTimelineKey);
    await prefs.remove(_skillsWithProficiencyKey);
    await prefs.remove(_careerGoalsKey);
    await prefs.remove(_languagesKey);
    await prefs.remove(_awardsKey);
    await prefs.remove(_profileCompletionKey);
  }
}
