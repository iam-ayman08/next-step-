import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'dart:io';
import '../services/api_service.dart';

class FileUploadWidget extends StatefulWidget {
  final String uploadType; // 'resume', 'transcript', 'certificate', 'project'
  final String label;
  final Function(Map<String, dynamic>)? onUploadSuccess;
  final VoidCallback? onUploadStart;
  final VoidCallback? onUploadComplete;

  const FileUploadWidget({
    Key? key,
    required this.uploadType,
    required this.label,
    this.onUploadSuccess,
    this.onUploadStart,
    this.onUploadComplete,
  }) : super(key: key);

  @override
  State<FileUploadWidget> createState() => _FileUploadWidgetState();
}

class _FileUploadWidgetState extends State<FileUploadWidget>
    with TickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  bool _isUploading = false;
  double _uploadProgress = 0.0;
  String? _uploadedFileName;
  String? _uploadedFilePath;
  String? _errorMessage;

  late AnimationController _pulseController;
  late AnimationController _progressController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _progressController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadFile() async {
    try {
      setState(() {
        _errorMessage = null;
        _isUploading = true;
        _uploadProgress = 0.0;
      });

      widget.onUploadStart?.call();

      // Pick file
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png', 'txt'],
      );

      if (result != null) {
        File file = File(result.files.single.path!);

        // Validate file size (10MB limit)
        int fileSize = await file.length();
        if (fileSize > 10 * 1024 * 1024) {
          throw Exception('File size must be less than 10MB');
        }

        // Upload file with progress tracking
        String filePath = file.path;
        String fileName = result.files.single.name;

        // Simulate progress updates
        _simulateProgress();

        final response = await _apiService.uploadFile(
          filePath,
          widget.uploadType,
          description: '${widget.label} upload',
        );

        setState(() {
          _isUploading = false;
          _uploadedFileName = fileName;
          _uploadedFilePath = response['file_path'];
          _uploadProgress = 1.0;
        });

        widget.onUploadSuccess?.call(response);
        widget.onUploadComplete?.call();

        _showSuccessSnackBar(fileName);

      } else {
        setState(() {
          _isUploading = false;
        });
      }

    } catch (e) {
      setState(() {
        _isUploading = false;
        _errorMessage = e.toString();
      });

      _showErrorSnackBar(e.toString());
    }
  }

  void _simulateProgress() {
    const totalSteps = 10;
    for (int i = 1; i <= totalSteps; i++) {
      Future.delayed(Duration(milliseconds: i * 200), () {
        if (mounted && _isUploading) {
          setState(() {
            _uploadProgress = i / totalSteps;
          });
        }
      });
    }
  }

  void _showSuccessSnackBar(String fileName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Text('$fileName uploaded successfully'),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showErrorSnackBar(String error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(error)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_pulseController, _progressController]),
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: _isUploading
                  ? Theme.of(context).colorScheme.primary
                  : Colors.grey.shade300,
              width: _isUploading ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(12),
            color: _isUploading
                ? Theme.of(context).colorScheme.primary.withOpacity(0.05)
                : Colors.grey.shade50,
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Upload Icon
                AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _isUploading ? _pulseAnimation.value : 1.0,
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _isUploading
                              ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                              : Colors.grey.shade100,
                          border: Border.all(
                            color: _isUploading
                                ? Theme.of(context).colorScheme.primary
                                : Colors.grey.shade300,
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          _getIconForUploadType(),
                          size: 30,
                          color: _isUploading
                              ? Theme.of(context).colorScheme.primary
                              : Colors.grey.shade600,
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 16),

                // Label
                Text(
                  widget.label,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: _isUploading
                        ? Theme.of(context).colorScheme.primary
                        : null,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 8),

                // Status Text
                if (_uploadedFileName != null)
                  Text(
                    'Uploaded: ${_uploadedFileName!}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.green.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  )
                else if (_errorMessage != null)
                  Text(
                    'Error: ${_errorMessage!}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.red.shade700,
                    ),
                  )
                else
                  Text(
                    'Tap to select file',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),

                const SizedBox(height: 16),

                // Upload Button or Progress
                if (_isUploading) ...[
                  // Progress Bar
                  Container(
                    height: 4,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2),
                      color: Colors.grey.shade200,
                    ),
                    child: AnimatedBuilder(
                      animation: _progressAnimation,
                      builder: (context, child) {
                        return FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: _uploadProgress,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(2),
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Progress Text
                  Text(
                    '${(_uploadProgress * 100).round()}%',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Cancel Button
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _isUploading = false;
                        _uploadProgress = 0.0;
                      });
                    },
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ] else ...[
                  // Upload Button
                  ElevatedButton.icon(
                    onPressed: _pickAndUploadFile,
                    icon: const Icon(Icons.upload_file),
                    label: Text(_uploadedFileName != null ? 'Upload Another' : 'Choose File'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],

                // File Requirements
                const SizedBox(height: 8),
                Text(
                  'Supported: PDF, DOC, DOCX, JPG, PNG (Max 10MB)',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade500,
                    fontSize: 10,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  IconData _getIconForUploadType() {
    switch (widget.uploadType) {
      case 'resume':
        return Icons.description;
      case 'transcript':
        return Icons.school;
      case 'certificate':
        return Icons.workspace_premium;
      case 'project':
        return Icons.folder;
      default:
        return Icons.file_present;
    }
  }
}
