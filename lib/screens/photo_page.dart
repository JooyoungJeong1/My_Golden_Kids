import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:http_parser/http_parser.dart';

const String baseUrl = 'http://211.104.25.94:8000';

// ───────────────────────────────────────────
// 사진 페이지
// ───────────────────────────────────────────

class PhotoQuestionPage extends StatefulWidget {
  const PhotoQuestionPage({super.key});
  @override
  State<PhotoQuestionPage> createState() => _PhotoQuestionPageState();
}

class _PhotoQuestionPageState extends State<PhotoQuestionPage> {
  bool _isAnalyzing = false;
  bool _showResult = false;
  String _resultName = '';
  String _resultSteps = '';
  List<Map<String, String>> _resultBadges = [];
  final ImagePicker _picker = ImagePicker();

  Future<void> _analyze(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image == null) return;

    setState(() {
      _isAnalyzing = true;
      _showResult = false;
    });

    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/photo/analyze'),
      );
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          await image.readAsBytes(),
          filename: image.name,
          contentType: MediaType('image', 'jpeg'),
        ),
      );
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      final data = jsonDecode(utf8.decode(response.bodyBytes));

      if (!mounted) return;
      setState(() {
        _isAnalyzing = false;
        _showResult = true;
        final item = data['items'][0];
        _resultName = item['name'] ?? '';
        _resultSteps = item['steps'] ?? '';
        _resultBadges = (item['badges'] as List)
            .map((e) => Map<String, String>.from(e as Map))
            .toList();
});
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isAnalyzing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('사진으로 물어보기'),
        backgroundColor: const Color(0xFFF6F1F6),
        surfaceTintColor: Colors.transparent,
        foregroundColor: const Color(0xFF222222),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () => _analyze(ImageSource.gallery),
                child: Container(
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7F4F8),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFFD0C8D8),
                      width: 2,
                    ),
                  ),
                  child: _isAnalyzing
                      ? const Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircularProgressIndicator(
                                color: Color(0xFFFDD835),
                                strokeWidth: 3,
                              ),
                              SizedBox(height: 12),
                              Text(
                                '분석 중...',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF888888),
                                ),
                              ),
                            ],
                          ),
                        )
                      : _showResult
                      ? const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.check_circle_rounded,
                              size: 48,
                              color: Color(0xFF4CAF50),
                            ),
                            SizedBox(height: 8),
                            Text(
                              '분석 완료!',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF2E7D32),
                              ),
                            ),
                          ],
                        )
                      : const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.camera_alt_outlined,
                              size: 40,
                              color: Color(0xFF888888),
                            ),
                            SizedBox(height: 8),
                            Text(
                              '사진을 선택하세요',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF888888),
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              '탭하여 업로드',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFFBBBBBB),
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _analyze(ImageSource.gallery),
                      child: Container(
                        height: 46,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFDD835),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Center(
                          child: Text(
                            '📁 갤러리에서 선택',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF5D4037),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _analyze(ImageSource.camera),
                      child: Container(
                        height: 46,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: const Color(0xFFDDDDDD),
                            width: 1.5,
                          ),
                        ),
                        child: const Center(
                          child: Text(
                            '📸 카메라 촬영',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF333333),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              if (_showResult) ...[
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFC8E6C9)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '🔍 AI 분석 결과',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF2E7D32),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _resultName,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF222222),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _resultSteps,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF444444),
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 6,
                        children: _resultBadges
                            .map(
                              (b) => _buildBadge(
                                b['label']!,
                                Color(
                                  int.parse('FF${b['bgColor']}', radix: 16),
                                ),
                                Color(
                                  int.parse('FF${b['textColor']}', radix: 16),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(String text, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: fg),
      ),
    );
  }
}
