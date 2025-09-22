import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'api_service.dart';

class AIService {
  static AIService? _instance;

  // For backwards compatibility, keep API key reference (though no longer used for Lightning API)
  static const String openaiApiKey =
      'd9601d2b-481b-494c-93e9-3e273eea4021/aymanmohamed1937/vision-model';

  AIService._();

  factory AIService([String? apiKey]) {
    _instance ??= AIService._();
    return _instance!;
  }

  static Future<bool> initialize() async {
    // Test connection during initialization through backend
    final apiService = ApiService();
    try {
      final response = await apiService.chatCompletion([
        {'role': 'user', 'content': 'Hello'}
      ], maxTokens: 10);
      debugPrint('AI service initialized and tested successfully');
      return true;
    } catch (e) {
      debugPrint('AI service initialization failed: $e');
      return false;
    }
  }

  Future<String> generateResponse(
    String prompt, {
    int maxTokens = 150,
    double temperature = 0.7,
  }) async {
    debugPrint('Generating AI response for prompt: $prompt');

    final fullPrompt = 'You are an AI created to guide students. Help them with their educational and career goals, providing advice on studies, career planning, resume building, interviews, and professional development.\n\nUser: $prompt\n\nAssistant:';

    try {
      final apiService = ApiService();
      final response = await apiService.chatCompletion([
        {'role': 'user', 'content': fullPrompt}
      ], maxTokens: maxTokens, temperature: temperature);

      final content = response['choices']?[0]?['message']?['content']
          ?.toString()
          .trim();

      if (content != null && content.isNotEmpty) {
        debugPrint('AI response generated successfully');
        return content;
      } else {
        debugPrint('Received empty content from AI API');
        return 'I apologize, but I couldn\'t generate a response right now. Please try rephrasing your question.';
      }
    } catch (e) {
      debugPrint('AI response generation failed: $e');
      return 'Sorry, I encountered an error: ${e.toString()}. Please try again.';
    }
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
