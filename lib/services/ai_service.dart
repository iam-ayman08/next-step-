import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class AIService {
  static AIService? _instance;

  // For security, the API key should be stored in environment variables
  // or obtained from a secure key management service
  final String _apiKey;

  static const String _baseUrl = 'https://api.openai.com/v1';
  static const String _model = 'gpt-4o-mini'; // Updated to more reliable model
  static const int _maxRetries = 3;
  static const Duration _timeout = Duration(seconds: 30);

  static const String _openaiApiKey =
      'your-openai-api-key-here'; // Replace with actual API key

  // Public getter to access the API key constant
  static String get openaiApiKey => _openaiApiKey;

  AIService._(this._apiKey);

  factory AIService(String apiKey) {
    if (_instance == null || _instance!._apiKey != apiKey) {
      _instance = AIService._(apiKey);
    }
    return _instance!;
  }

  static Future<bool> initialize() async {
    // Test connection during initialization
    final aiService = AIService(_openaiApiKey);
    final isConnected = await aiService.testConnection();

    if (isConnected) {
      debugPrint('AI service initialized and tested successfully');
      return true;
    } else {
      debugPrint('AI service initialization failed - API key may be invalid or service unavailable');
      return false;
    }
  }

  Future<String> generateResponse(
    String prompt, {
    int maxTokens = 150,
    double temperature = 0.7,
  }) async {
    debugPrint('Generating AI response for prompt: $prompt');

    for (int attempt = 1; attempt <= _maxRetries; attempt++) {
      try {
        final response = await http
            .post(
              Uri.parse('$_baseUrl/chat/completions'),
              headers: {
                'Content-Type': 'application/json',
                'Authorization': 'Bearer $_apiKey',
              },
              body: jsonEncode({
                'model': _model,
                'messages': [
                  {'role': 'user', 'content': prompt},
                ],
                'max_tokens': maxTokens,
                'temperature': temperature,
              }),
            )
            .timeout(_timeout);

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);

          // Check if the response contains an error message
          if (data.containsKey('error')) {
            final error = data['error'];
            final errorMessage =
                error['message']?.toString() ?? 'Unknown API error';

            if (errorMessage.contains(
              'The language model did not provide any assistant messages',
            )) {
              throw Exception(
                'The AI service is temporarily unavailable. Please try again.',
              );
            }
            throw Exception('OpenAI API Error: $errorMessage');
          }

          final content = data['choices']?[0]?['message']?['content']
              ?.toString()
              .trim();

          if (content != null && content.isNotEmpty) {
            debugPrint('AI response generated successfully');
            return content;
          } else {
            // Handle empty content more gracefully
            debugPrint('Received empty content from OpenAI API');
            return 'I apologize, but I couldn\'t generate a response right now. Please try rephrasing your question.';
          }
        } else if (response.statusCode == 429) {
          // Rate limit exceeded, wait before retry
          if (attempt < _maxRetries) {
            await Future.delayed(Duration(seconds: attempt * 2));
            continue;
          }
          throw Exception('Rate limit exceeded. Please try again later.');
        } else if (response.statusCode == 401) {
          throw Exception('Invalid API key. Please check your OpenAI API key.');
        } else if (response.statusCode == 400) {
          // Bad request - often due to model issues or invalid parameters
          final data = jsonDecode(response.body);
          final error =
              data['error']?['message'] ?? 'Bad request to AI service';
          throw Exception('Request error: $error');
        } else {
          final data = jsonDecode(response.body);
          final error = data['error']?['message'] ?? 'Unknown API error';
          throw Exception('API Error: ${response.statusCode} - $error');
        }
      } catch (e) {
        if (attempt == _maxRetries) {
          debugPrint(
            'AI response generation failed after $_maxRetries attempts: $e',
          );
          return 'Sorry, I encountered an error: $e. Please try again.';
        }
        // Wait before retry
        await Future.delayed(Duration(seconds: attempt));
      }
    }

    return 'Sorry, I was unable to generate a response. Please try again.';
  }

  Future<String> improveResume(
    String resumeText, {
    int maxTokens = 500,
    double temperature = 0.3,
  }) async {
    // Truncate resume text if too long to avoid token limits
    final truncatedResume = _truncateText(resumeText, 3000);

    final prompt =
        'Improve this resume professionally. Make it concise, use action verbs, highlight achievements, and follow best practices:\n\n$truncatedResume\n\nImproved version:';

    return generateResponse(
      prompt,
      maxTokens: maxTokens,
      temperature: temperature,
    );
  }

  Future<String> generateResumeSuggestions(
    String currentContent,
    String field,
  ) async {
    // Truncate content if too long
    final truncatedContent = _truncateText(currentContent, 1000);

    final prompt =
        'For resume section "$field", provide 2-3 specific improvement suggestions:\n\n$truncatedContent\n\nSuggestions:';

    return generateResponse(prompt, maxTokens: 200, temperature: 0.5);
  }

  Future<List<String>> generateSkillSuggestions(
    String skills,
    String jobTitle,
  ) async {
    // Truncate inputs if too long
    final truncatedSkills = _truncateText(skills, 150);
    final truncatedJobTitle = _truncateText(jobTitle, 100);

    final prompt =
        'Current skills: $truncatedSkills\nTarget role: $truncatedJobTitle\nSuggest 5-7 additional relevant skills (one per line):';

    final response = await generateResponse(
      prompt,
      maxTokens: 120,
      temperature: 0.6,
    );

    // Parse response into list
    return response
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty && !line.startsWith('-'))
        .map((line) => line.startsWith('-') ? line.substring(1).trim() : line)
        .where((line) => line.isNotEmpty)
        .take(7)
        .toList();
  }

  Future<String> generateInterviewTips(String skills, String position) async {
    // Truncate inputs if too long
    final truncatedSkills = _truncateText(skills, 200);
    final truncatedPosition = _truncateText(position, 100);

    final prompt =
        'Generate 5 interview tips for skills: $truncatedSkills, position: $truncatedPosition. Focus on preparation, communication, research, follow-up, and confidence. Number them.';

    return generateResponse(prompt, maxTokens: 300, temperature: 0.7);
  }

  Future<String> analyzeResumeStrength(
    String resumeText, {
    int maxTokens = 200,
    double temperature = 0.3,
  }) async {
    // Truncate resume text if too long
    final truncatedResume = _truncateText(resumeText, 2000);

    final prompt =
        'Analyze this resume and rate it 1-10. Provide brief feedback:\n\n$truncatedResume\n\nFormat: Score: X/10\n\nStrengths:\n- [point]\n\nImprovements:\n- [point]';

    return generateResponse(
      prompt,
      maxTokens: maxTokens,
      temperature: temperature,
    );
  }

  // Test the API connection
  Future<bool> testConnection() async {
    try {
      final response = await generateResponse('Hello', maxTokens: 10);
      return response.isNotEmpty;
    } catch (e) {
      debugPrint('AI service connection test failed: $e');
      return false;
    }
  }

  // Helper method to truncate text to avoid token limits
  String _truncateText(String text, int maxLength) {
    if (text.length <= maxLength) {
      return text;
    }

    // Find the last complete sentence within the limit
    final truncated = text.substring(0, maxLength);
    final lastSentenceEnd = truncated.lastIndexOf('.');

    if (lastSentenceEnd > maxLength * 0.8) {
      return truncated.substring(0, lastSentenceEnd + 1);
    } else {
      // If no good sentence break, truncate at word boundary
      final lastSpace = truncated.lastIndexOf(' ');
      if (lastSpace > maxLength * 0.9) {
        return truncated.substring(0, lastSpace) + '...';
      }
      return truncated + '...';
    }
  }
}
