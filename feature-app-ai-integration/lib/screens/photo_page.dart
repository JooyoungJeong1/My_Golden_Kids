import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:http_parser/http_parser.dart';
import '../services/api_service.dart';

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
  String _errorMessage = '';
  Map<String, dynamic>? _topItem; // 신뢰도 가장 높은 1개만
  XFile? _pickedImage;
  final ImagePicker _picker = ImagePicker();

  // 추가: 이물질/다중포장재 여부
  bool? _contamination;
  bool? _multiPackaging;

  Future<void> _analyze(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image == null) return;

    setState(() {
      _pickedImage = image;
      _isAnalyzing = true;
      _showResult = false;
      _errorMessage = '';
      _topItem = null;
      _contamination = null;
      _multiPackaging = null;
    });

    try {
      final baseUrl = await ApiService.getBaseUrl();
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

      if (data['result'] == 'unknown' || (data['items'] as List).isEmpty) {
        setState(() {
          _isAnalyzing = false;
          _showResult = true;
          _errorMessage = data['message'] ?? '물체를 인식하기 어려워요.';
          _contamination = null;
          _multiPackaging = null;
        });
      } else {
        // 신뢰도 가장 높은 1개만 선택
        final items = (data['items'] as List)
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();
        items.sort(
          (a, b) =>
              ((b['confidence'] as num)).compareTo((a['confidence'] as num)),
        );

        setState(() {
          _isAnalyzing = false;
          _showResult = true;
          _topItem = items.first;
          // 최상위 필드에서 이물질/다중포장재 파싱
          _contamination = data['contamination'] == true;
          _multiPackaging = data['multi_packaging'] == true;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isAnalyzing = false;
        _showResult = true;
        _errorMessage = '서버 연결에 실패했어요. 다시 시도해주세요.';
        _contamination = null;
        _multiPackaging = null;
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

              // 사진 업로드 영역
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
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // 업로드된 사진
                        if (_pickedImage != null)
                          Image.file(
                            File(_pickedImage!.path),
                            fit: BoxFit.cover,
                          ),

                        // 사진 없을 때 기본 UI
                        if (_pickedImage == null)
                          const Column(
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

                        // 분석 중 오버레이
                        if (_isAnalyzing)
                          Container(
                            color: Colors.black.withValues(alpha: 0.45),
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
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
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),

                        // 분석 완료/실패 오버레이 (잠깐 표시)
                        if (_showResult && !_isAnalyzing)
                          Positioned(
                            bottom: 10,
                            left: 0,
                            right: 0,
                            child: Center(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: _errorMessage.isNotEmpty
                                      ? const Color(0xFFE53935)
                                      : const Color(0xFF4CAF50),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  _errorMessage.isNotEmpty ? '인식 실패' : '분석 완료!',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 버튼
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

              // 결과 표시
              if (_showResult) ...[
                const SizedBox(height: 16),

                // 감지 실패
                if (_errorMessage.isNotEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFEBEE),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFFFCDD2)),
                    ),
                    child: Column(
                      children: [
                        const Text('😅', style: TextStyle(fontSize: 32)),
                        const SizedBox(height: 8),
                        Text(
                          _errorMessage,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFFB71C1C),
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),

                // 감지 성공 - 신뢰도 1위만 표시
                if (_topItem != null)
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
                          _topItem!['name'] ?? '',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF222222),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _topItem!['steps'] ?? '',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF444444),
                            height: 1.6,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 6,
                          children: ((_topItem!['badges'] as List?) ?? []).map((
                            b,
                          ) {
                            final badge = Map<String, String>.from(b as Map);
                            return _buildBadge(
                              badge['label']!,
                              Color(
                                int.parse('FF${badge['bgColor']}', radix: 16),
                              ),
                              Color(
                                int.parse('FF${badge['textColor']}', radix: 16),
                              ),
                            );
                          }).toList(),
                        ),

                        // 구분선
                        const SizedBox(height: 12),
                        const Divider(height: 1, color: Color(0xFFB2DFDB)),
                        const SizedBox(height: 12),

                        // 다중포장재 여부
                        Row(
                          children: [
                            const Text(
                              '📦 다중포장재',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF333333),
                              ),
                            ),
                            const Spacer(),
                            _buildStatusChip(
                              _multiPackaging ?? false,
                              trueLabel: '해당',
                              falseLabel: '해당 없음',
                              dangerIfTrue: false,
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        // 이물질 여부
                        Row(
                          children: [
                            const Text(
                              '🔬 이물질',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF333333),
                              ),
                            ),
                            const Spacer(),
                            _buildStatusChip(
                              _contamination ?? false,
                              trueLabel: '있음',
                              falseLabel: '이상 없음',
                              dangerIfTrue: true,
                            ),
                          ],
                        ),

                        // 이물질 있을 때 경고 메시지
                        if (_contamination == true) ...[
                          const SizedBox(height: 8),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFEBEE),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text(
                              '⚠️ 이물질을 제거한 후 배출해주세요.',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFFB71C1C),
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
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

  Widget _buildStatusChip(
    bool isTrue, {
    required String trueLabel,
    required String falseLabel,
    bool dangerIfTrue = false,
  }) {
    final Color bg = isTrue
        ? (dangerIfTrue ? const Color(0xFFFFCDD2) : const Color(0xFFFFF9C4))
        : const Color(0xFFDCEDC8);
    final Color fg = isTrue
        ? (dangerIfTrue ? const Color(0xFFB71C1C) : const Color(0xFFF57F17))
        : const Color(0xFF33691E);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isTrue ? trueLabel : falseLabel,
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: fg),
      ),
    );
  }
}
