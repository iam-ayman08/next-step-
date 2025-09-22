import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user_model.dart';
import '../models/application_model.dart';
import '../models/mentorship_model.dart';
import '../models/profile_model.dart';
import '../models/scholarship_model.dart';
import '../models/project_model.dart';
import '../models/alumni_expertise_model.dart';
import '../models/notification_model.dart';
import '../utils/config.dart';

class ApiService {
  late Dio _dio;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // Singleton pattern
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal() {
    _initializeDio();
  }

  Future<void> initialize() async {
    // Any additional async initialization can be done here
    print('API service initialized successfully');
  }

  void _initializeDio() {
    _dio = Dio(
      BaseOptions(
        baseUrl: appConfig.baseUrl, // Should be http://localhost:8000/api/v1
        connectTimeout: Duration(seconds: appConfig.connectionTimeout),
        receiveTimeout: Duration(seconds: appConfig.receiveTimeout),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    // Add interceptors for auth token and error handling
    _dio.interceptors.addAll([
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Add JWT token to requests
          final token = await _secureStorage.read(key: 'auth_token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onResponse: (response, handler) {
          handler.next(response);
        },
        onError: (DioException error, handler) async {
          if (error.response?.statusCode == 401) {
            // Token expired, try refresh or logout
            await logout();
          }
          handler.next(error);
        },
      ),
      LogInterceptor(requestBody: true, responseBody: true), // Debug logs
    ]);
  }

  // Authentication Methods
  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await _dio.post(
        '/auth/login',
        data: {
          'username': username,
          'password': password,
        },
      );

      final data = response.data;
      if (data['access_token'] != null) {
        final token = data['access_token'];
        await _secureStorage.write(key: 'auth_token', value: token);
      }

      return data;
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response?.data['detail'] ?? 'Login failed');
      } else {
        throw Exception('Network error');
      }
    }
  }

  Future<Map<String, dynamic>> register(String username, String email, String password, String name, String role) async {
    try {
      final response = await _dio.post(
        '/auth/register',
        data: {
          'username': username,
          'email': email,
          'password': password,
          'name': name,
          'role': role,
        },
      );

      final data = response.data;
      if (data['access_token'] != null) {
        final token = data['access_token'];
        await _secureStorage.write(key: 'auth_token', value: token);
      }

      return data;
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response?.data['detail'] ?? 'Registration failed');
      } else {
        throw Exception('Network error');
      }
    }
  }

  Future<Map<String, dynamic>> verifyToken() async {
    try {
      final token = await _secureStorage.read(key: 'auth_token');
      if (token == null) {
        throw Exception('No token found');
      }

      final response = await _dio.post(
        '/auth/verify',
        data: token, // Send token as string, not JSON
      );

      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response?.data['detail'] ?? 'Token verification failed');
      } else {
        throw Exception('Network error');
      }
    }
  }

  Future<void> logout() async {
    try {
      await _secureStorage.delete(key: 'auth_token');
    } catch (e) {
      print('Logout error: $e');
    }
  }

  Future<String?> getStoredToken() async {
    return await _secureStorage.read(key: 'auth_token');
  }

  // User Methods
  Future<UserModel> getCurrentUser() async {
    try {
      final response = await _dio.get('/users/me');
      return UserModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['detail'] ?? 'Failed to get user profile',
      );
    }
  }

  Future<UserModel> updateUser(Map<String, dynamic> updates) async {
    try {
      final response = await _dio.put('/users/me', data: updates);
      return UserModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['detail'] ?? 'Failed to update user',
      );
    }
  }

  Future<List<UserModel>> getUsers({int skip = 0, int limit = 100}) async {
    try {
      final response = await _dio.get(
        '/users/',
        queryParameters: {'skip': skip, 'limit': limit},
      );

      return (response.data as List)
          .map((userJson) => UserModel.fromJson(userJson))
          .toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data['detail'] ?? 'Failed to get users');
    }
  }

  Future<UserModel> getUser(String userId) async {
    try {
      final response = await _dio.get('/users/$userId');
      return UserModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['detail'] ?? 'Failed to get user',
      );
    }
  }

  // Profile Methods
  Future<ProfileModel> getProfile() async {
    try {
      final response = await _dio.get('/profiles/');
      return ProfileModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['detail'] ?? 'Failed to get profile',
      );
    }
  }

  Future<ProfileModel> createProfile(Map<String, dynamic> profileData) async {
    try {
      final response = await _dio.post('/profiles/', data: profileData);
      return ProfileModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['detail'] ?? 'Failed to create profile',
      );
    }
  }

  Future<ProfileModel> updateProfile(Map<String, dynamic> updates) async {
    try {
      final response = await _dio.put('/profiles/', data: updates);
      return ProfileModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['detail'] ?? 'Failed to update profile',
      );
    }
  }

  Future<void> deleteProfile() async {
    try {
      await _dio.delete('/profiles/');
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['detail'] ?? 'Failed to delete profile',
      );
    }
  }

  // Application Methods
  Future<List<ApplicationModel>> getApplications({int skip = 0, int limit = 100}) async {
    try {
      final response = await _dio.get(
        '/applications/',
        queryParameters: {'skip': skip, 'limit': limit},
      );

      return (response.data as List)
          .map((appJson) => ApplicationModel.fromJson(appJson))
          .toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data['detail'] ?? 'Failed to get applications');
    }
  }

  Future<ApplicationModel> createApplication(Map<String, dynamic> appData) async {
    try {
      final response = await _dio.post('/applications/', data: appData);
      return ApplicationModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['detail'] ?? 'Failed to create application',
      );
    }
  }

  Future<ApplicationModel> getApplication(String applicationId) async {
    try {
      final response = await _dio.get('/applications/$applicationId');
      return ApplicationModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['detail'] ?? 'Failed to get application',
      );
    }
  }

  Future<ApplicationModel> updateApplication(String applicationId, Map<String, dynamic> updates) async {
    try {
      final response = await _dio.put('/applications/$applicationId', data: updates);
      return ApplicationModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['detail'] ?? 'Failed to update application',
      );
    }
  }

  Future<void> deleteApplication(String applicationId) async {
    try {
      await _dio.delete('/applications/$applicationId');
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['detail'] ?? 'Failed to delete application',
      );
    }
  }

  Future<Map<String, dynamic>> getApplicationStats() async {
    try {
      final response = await _dio.get('/applications/stats/summary');
      return response.data;
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['detail'] ?? 'Failed to get application stats',
      );
    }
  }

  // Mentorship Methods
  Future<List<MentorshipModel>> getMentorships({int skip = 0, int limit = 100}) async {
    try {
      final response = await _dio.get(
        '/mentorship/',
        queryParameters: {'skip': skip, 'limit': limit},
      );

      return (response.data as List)
          .map((mentorshipJson) => MentorshipModel.fromJson(mentorshipJson))
          .toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data['detail'] ?? 'Failed to get mentorships');
    }
  }

  Future<MentorshipModel> requestMentorship(String mentorId, {String? message}) async {
    try {
      final response = await _dio.post(
        '/mentorship/request',
        data: {'mentor_id': mentorId, 'message': message},
      );
      return MentorshipModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['detail'] ?? 'Failed to request mentorship',
      );
    }
  }

  Future<MentorshipModel> getMentorship(String mentorshipId) async {
    try {
      final response = await _dio.get('/mentorship/$mentorshipId');
      return MentorshipModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['detail'] ?? 'Failed to get mentorship',
      );
    }
  }

  Future<MentorshipModel> updateMentorship(String mentorshipId, Map<String, dynamic> updates) async {
    try {
      final response = await _dio.put('/mentorship/$mentorshipId', data: updates);
      return MentorshipModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['detail'] ?? 'Failed to update mentorship',
      );
    }
  }

  Future<void> deleteMentorship(String mentorshipId) async {
    try {
      await _dio.delete('/mentorship/$mentorshipId');
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['detail'] ?? 'Failed to delete mentorship',
      );
    }
  }

  Future<List<MentorshipModel>> getPendingRequests() async {
    try {
      final response = await _dio.get('/mentorship/requests/pending');
      return (response.data as List)
          .map((mentorshipJson) => MentorshipModel.fromJson(mentorshipJson))
          .toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data['detail'] ?? 'Failed to get pending requests');
    }
  }

  Future<List<MentorshipModel>> getActiveMentees() async {
    try {
      final response = await _dio.get('/mentorship/mentees/active');
      return (response.data as List)
          .map((mentorshipJson) => MentorshipModel.fromJson(mentorshipJson))
          .toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data['detail'] ?? 'Failed to get active mentees');
    }
  }

  // Health check
  Future<Map<String, dynamic>> healthCheck() async {
    try {
      final response = await _dio.get('/health');
      return response.data;
    } catch (e) {
      return {'success': false, 'message': 'Backend unavailable'};
    }
  }

  // Scholarship Methods
  Future<List<ScholarshipModel>> getScholarships({
    int skip = 0,
    int limit = 10,
    String? category,
    String status = "active"
  }) async {
    try {
      final response = await _dio.get(
        '/scholarships/',
        queryParameters: {
          'skip': skip,
          'limit': limit,
          if (category != null) 'category': category,
          'status': status,
        },
      );

      final data = response.data;
      return (data['scholarships'] as List)
          .map((scholarshipJson) => ScholarshipModel.fromJson(scholarshipJson))
          .toList();
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['detail'] ?? 'Failed to get scholarships',
      );
    }
  }

  Future<ScholarshipModel> getScholarship(String scholarshipId) async {
    try {
      final response = await _dio.get('/scholarships/$scholarshipId');
      return ScholarshipModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['detail'] ?? 'Failed to get scholarship',
      );
    }
  }

  Future<ScholarshipModel> createScholarship(Map<String, dynamic> scholarshipData) async {
    try {
      final response = await _dio.post('/scholarships/', data: scholarshipData);
      return ScholarshipModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['detail'] ?? 'Failed to create scholarship',
      );
    }
  }

  Future<ScholarshipModel> updateScholarship(String scholarshipId, Map<String, dynamic> updates) async {
    try {
      final response = await _dio.put('/scholarships/$scholarshipId', data: updates);
      return ScholarshipModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['detail'] ?? 'Failed to update scholarship',
      );
    }
  }

  Future<void> deleteScholarship(String scholarshipId) async {
    try {
      await _dio.delete('/scholarships/$scholarshipId');
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['detail'] ?? 'Failed to delete scholarship',
      );
    }
  }

  Future<ScholarshipModel> applyForScholarship(String scholarshipId, Map<String, dynamic> applicationData) async {
    try {
      final response = await _dio.post(
        '/scholarships/$scholarshipId/apply',
        data: applicationData,
      );
      return ScholarshipModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['detail'] ?? 'Failed to apply for scholarship',
      );
    }
  }

  Future<List<dynamic>> getScholarshipApplications(String scholarshipId) async {
    try {
      final response = await _dio.get('/scholarships/$scholarshipId/applications');
      return response.data as List<dynamic>;
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['detail'] ?? 'Failed to get scholarship applications',
      );
    }
  }

  Future<Map<String, dynamic>> reviewScholarshipApplication(
    String applicationId,
    String status,
    {String? reviewNotes}
  ) async {
    try {
      final response = await _dio.put(
        '/scholarships/applications/$applicationId',
        data: {
          'status': status,
          if (reviewNotes != null) 'review_notes': reviewNotes,
        },
      );
      return response.data;
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['detail'] ?? 'Failed to review application',
      );
    }
  }

  // Project Methods
  Future<List<ProjectModel>> getProjects({
    int skip = 0,
    int limit = 10,
    String? category,
    String status = "pending",
    String? fundingType
  }) async {
    try {
      final response = await _dio.get(
        '/projects/',
        queryParameters: {
          'skip': skip,
          'limit': limit,
          if (category != null) 'category': category,
          'status': status,
          if (fundingType != null) 'funding_type': fundingType,
        },
      );

      final data = response.data;
      return (data['projects'] as List)
          .map((projectJson) => ProjectModel.fromJson(projectJson))
          .toList();
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['detail'] ?? 'Failed to get projects',
      );
    }
  }

  Future<ProjectModel> getProject(String projectId) async {
    try {
      final response = await _dio.get('/projects/$projectId');
      return ProjectModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['detail'] ?? 'Failed to get project',
      );
    }
  }

  Future<ProjectModel> createProject(Map<String, dynamic> projectData) async {
    try {
      final response = await _dio.post('/projects/', data: projectData);
      return ProjectModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['detail'] ?? 'Failed to create project',
      );
    }
  }

  Future<ProjectModel> updateProject(String projectId, Map<String, dynamic> updates) async {
    try {
      final response = await _dio.put('/projects/$projectId', data: updates);
      return ProjectModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['detail'] ?? 'Failed to update project',
      );
    }
  }

  Future<void> deleteProject(String projectId) async {
    try {
      await _dio.delete('/projects/$projectId');
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['detail'] ?? 'Failed to delete project',
      );
    }
  }

  Future<ProjectModel> provideProjectSupport(String projectId, Map<String, dynamic> supportData) async {
    try {
      final response = await _dio.post(
        '/projects/$projectId/support',
        data: supportData,
      );
      return ProjectModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['detail'] ?? 'Failed to provide project support',
      );
    }
  }

  Future<List<dynamic>> getProjectSupporters(String projectId) async {
    try {
      final response = await _dio.get('/projects/$projectId/support');
      return response.data as List<dynamic>;
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['detail'] ?? 'Failed to get project supporters',
      );
    }
  }

  Future<List<dynamic>> getMyProjectSupports() async {
    try {
      final response = await _dio.get('/projects/my-supports');
      return response.data as List<dynamic>;
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['detail'] ?? 'Failed to get project supports',
      );
    }
  }

  // Alumni Expertise Methods
  Future<AlumniExpertiseModel> addAlumniExpertise(Map<String, dynamic> expertiseData) async {
    try {
      final response = await _dio.post('/alumni/expertise', data: expertiseData);
      return AlumniExpertiseModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['detail'] ?? 'Failed to add alumni expertise',
      );
    }
  }

  Future<List<AlumniExpertiseModel>> getAlumniExpertise({
    String? expertiseArea,
    String availabilityStatus = "available",
    int skip = 0,
    int limit = 10
  }) async {
    try {
      final response = await _dio.get(
        '/alumni/expertise',
        queryParameters: {
          if (expertiseArea != null) 'expertise_area': expertiseArea,
          'availability_status': availabilityStatus,
          'skip': skip,
          'limit': limit,
        },
      );

      final data = response.data;
      return (data['expertise'] as List)
          .map((expertiseJson) => AlumniExpertiseModel.fromJson(expertiseJson))
          .toList();
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['detail'] ?? 'Failed to get alumni expertise',
      );
    }
  }

  Future<AlumniExpertiseModel> getAlumniExpertiseById(String expertiseId) async {
    try {
      final response = await _dio.get('/alumni/expertise/$expertiseId');
      return AlumniExpertiseModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['detail'] ?? 'Failed to get alumni expertise',
      );
    }
  }

  Future<AlumniExpertiseModel> updateAlumniExpertise(String expertiseId, Map<String, dynamic> updates) async {
    try {
      final response = await _dio.put('/alumni/expertise/$expertiseId', data: updates);
      return AlumniExpertiseModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['detail'] ?? 'Failed to update alumni expertise',
      );
    }
  }

  Future<void> deleteAlumniExpertise(String expertiseId) async {
    try {
      await _dio.delete('/alumni/expertise/$expertiseId');
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['detail'] ?? 'Failed to delete alumni expertise',
      );
    }
  }

  // Notification Methods
  Future<List<dynamic>> getNotifications({
    int skip = 0,
    int limit = 50,
    bool unreadOnly = false,
    String? typeFilter,
  }) async {
    try {
      final response = await _dio.get(
        '/notifications/',
        queryParameters: {
          'skip': skip,
          'limit': limit,
          if (unreadOnly) 'unread_only': true,
          if (typeFilter != null) 'type_filter': typeFilter,
        },
      );
      return response.data as List<dynamic>;
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['detail'] ?? 'Failed to get notifications',
      );
    }
  }

  Future<Map<String, dynamic>> getNotification(String notificationId) async {
    try {
      final response = await _dio.get('/notifications/$notificationId');
      return response.data;
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['detail'] ?? 'Failed to get notification',
      );
    }
  }

  Future<Map<String, dynamic>> createNotification(Map<String, dynamic> notificationData) async {
    try {
      final response = await _dio.post('/notifications/', data: notificationData);
      return response.data;
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['detail'] ?? 'Failed to create notification',
      );
    }
  }

  Future<Map<String, dynamic>> updateNotification(String notificationId, Map<String, dynamic> updates) async {
    try {
      final response = await _dio.put('/notifications/$notificationId', data: updates);
      return response.data;
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['detail'] ?? 'Failed to update notification',
      );
    }
  }

  Future<void> deleteNotification(String notificationId) async {
    try {
      await _dio.delete('/notifications/$notificationId');
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['detail'] ?? 'Failed to delete notification',
      );
    }
  }

  Future<Map<String, dynamic>> markAllNotificationsRead() async {
    try {
      final response = await _dio.post('/notifications/mark-all-read');
      return response.data;
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['detail'] ?? 'Failed to mark notifications as read',
      );
    }
  }

  Future<Map<String, dynamic>> getNotificationStats() async {
    try {
      final response = await _dio.get('/notifications/stats/summary');
      return response.data;
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['detail'] ?? 'Failed to get notification stats',
      );
    }
  }

  // File Upload Methods
  Future<Map<String, dynamic>> uploadFile(
    String filePath,
    String fileType, {
    String? description,
  }) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath),
        'file_type': fileType,
        if (description != null) 'description': description,
      });

      final response = await _dio.post('/uploads/upload', data: formData);
      return response.data;
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['detail'] ?? 'Failed to upload file',
      );
    }
  }

  Future<List<dynamic>> uploadMultipleFiles(
    List<String> filePaths,
    String fileType, {
    String? description,
  }) async {
    try {
      final formData = FormData();

      for (var filePath in filePaths) {
        formData.files.add(MapEntry(
          'files',
          await MultipartFile.fromFile(filePath),
        ));
      }

      formData.fields.add(MapEntry('file_type', fileType));
      if (description != null) {
        formData.fields.add(MapEntry('description', description));
      }

      final response = await _dio.post('/uploads/upload/multiple', data: formData);
      return response.data as List<dynamic>;
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['detail'] ?? 'Failed to upload files',
      );
    }
  }

  Future<Map<String, dynamic>> getFileInfo(String filename) async {
    try {
      final response = await _dio.get('/uploads/files/$filename');
      return response.data;
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['detail'] ?? 'Failed to get file info',
      );
    }
  }

  Future<void> deleteFile(String filename) async {
    try {
      await _dio.delete('/uploads/files/$filename');
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['detail'] ?? 'Failed to delete file',
      );
    }
  }

  Future<Map<String, dynamic>> listUploadedFiles() async {
    try {
      final response = await _dio.get('/uploads/files');
      return response.data;
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['detail'] ?? 'Failed to list files',
      );
    }
  }

  // Specialized upload methods
  Future<Map<String, dynamic>> uploadResume(String filePath) async {
    return await uploadFile(filePath, 'resume', description: 'Resume document');
  }

  Future<Map<String, dynamic>> uploadTranscript(String filePath) async {
    return await uploadFile(filePath, 'transcript', description: 'Academic transcript');
  }

  Future<Map<String, dynamic>> uploadCertificate(String filePath, String certType) async {
    return await uploadFile(
      filePath,
      'certificate_$certType',
      description: 'Certificate - $certType'
    );
  }

  Future<Map<String, dynamic>> uploadProjectDocument(String filePath, String projectName) async {
    return await uploadFile(
      filePath,
      'project_document',
      description: 'Project document for $projectName'
    );
  }

  // AI Methods
  Future<Map<String, dynamic>> chatCompletion(List<Map<String, dynamic>> messages, {
    String? model,
    int? maxTokens,
    double? temperature,
  }) async {
    try {
      final requestData = {
        'messages': messages,
        if (model != null) 'model': model,
        if (maxTokens != null) 'max_tokens': maxTokens,
        if (temperature != null) 'temperature': temperature,
      };

      final response = await _dio.post('/ai/chat/completions', data: requestData);
      return response.data;
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['detail'] ?? 'Failed to get AI completion',
      );
    }
  }
}
