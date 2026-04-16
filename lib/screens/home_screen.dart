import 'package:flutter/material.dart';
import '../models/category.dart';
import '../models/user_session.dart';
import '../widgets/category_card.dart';
import 'chat_page.dart';
import 'photo_page.dart';
import 'community_page.dart';
import 'my_page.dart';
import 'guide_page.dart';
import 'faq_page.dart';
import 'category_detail_page.dart';
import 'package:google_fonts/google_fonts.dart';

// ───────────────────────────────────────────
// 홈 화면
// ───────────────────────────────────────────

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final bool _isAiConnected = false;

  static final List<String> _tips = [
    '페트병은 라벨 제거 후 찌그러트려서 배출하면 더 많이 재활용돼요!',
    '우유팩은 종이류가 아닌 전용 수거함에 따로 배출해야 해요!',
    '비닐 라벨이 붙은 유리병은 라벨을 먼저 제거한 뒤 배출하세요!',
    '음식물 묻은 비닐은 재활용이 안 돼요. 깨끗한 것만 비닐류로 배출하세요!',
    '스티로폼은 플라스틱 수거함이 아닌 스티로폼 전용 수거함에 넣어야 해요!',
    '깨진 유리는 신문지로 싸서 일반쓰레기봉투에 넣어주세요!',
    '건전지와 형광등은 각각 전용 수거함이 따로 있어요!',
  ];
  //오늘의 팁 문구
  late String _todayTip;

  @override
  void initState() {
    super.initState();
    _checkAiConnection();
    _tips.shuffle();
    _todayTip = _tips.first;
  }

  Future<void> _checkAiConnection() async {
    // TODO: 실제 AI API 연결 시 아래 주석 해제
    // try {
    //   final response = await http.get(Uri.parse('YOUR_API_URL/health'));
    //   if (mounted) setState(() => _isAiConnected = response.statusCode == 200);
    // } catch (e) {
    //   if (mounted) setState(() => _isAiConnected = false);
    // }
  }

  void _refreshTip() {
    setState(() {
      _tips.shuffle();
      _todayTip = _tips.first;
    });
  }

  static const List<CategoryItem> categories = [
    CategoryItem(
      //icon: '📄',
      label: '종이류',
      subtitle: '박스·신문·책',
      bgColor: Color(0xFFFFFFFF),
      imageUrl: 'assets/images/종이류.png',
    ),
    CategoryItem(
      //icon: '🥤',
      label: '캔류',
      subtitle: '음료·통조림',
      bgColor: Color(0xFFFFFFFF),
      imageUrl: 'assets/images/캔류.png',
    ),
    CategoryItem(
      //icon: '🍶',
      label: '유리',
      subtitle: '병·깨진유리',
      bgColor: Color(0xFFFFFFFF),
      imageUrl: 'assets/images/유리류.png',
    ),
    CategoryItem(
      //icon: '♻️',
      label: '플라스틱',
      subtitle: 'PET·PP·PE',
      bgColor: Color(0xFFFFFFFF),
      imageUrl: 'assets/images/플라스틱류.png',
    ),
    CategoryItem(
      label: '비닐',
      subtitle: '봉투·랩·필름',
      bgColor: Color(0xFFFFFFFF),
      imageUrl: 'assets/images/비닐류.png',
    ),
    CategoryItem(
      //icon: '🗑️',
      label: '기타·처치곤란',
      subtitle: '사진으로 확인하기',
      bgColor: Color(0xFFFFF9C4),
      isAi: true,
      imageUrl: 'assets/images/기타처치곤란.png',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6F1F6),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        title: Text(
          '버릴래말래',
          style: GoogleFonts.notoSans(
            color: Color(0xFF222222),
            fontWeight: FontWeight.w800,
            fontSize: 25,
          ), // 제목 색 //gamjaFlower 나쁘지 않음 (본문에도)
        ),
        actions: [
          IconButton(
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MyPage()),
              );
              _refreshTip(); // 돌아왔을 때 아이콘 갱신
            },
            icon: Icon(
              UserSession.isLoggedIn
                  ? Icons.account_circle_rounded
                  : Icons.account_circle_outlined,
              color: const Color(0xFF555555),
              size: 26,
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeroBanner(context),
              const SizedBox(height: 12),
              _buildTodayTip(),
              const SizedBox(height: 12),
              _buildCommunityButton(context),
              const SizedBox(height: 18),
              const Text(
                '카테고리별 배출법',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF222222),
                ),
              ),
              const SizedBox(height: 12),
              GridView.builder(
                itemCount: categories.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 9,
                  mainAxisSpacing: 9,
                  childAspectRatio: 0.88,
                ),
                itemBuilder: (context, index) {
                  return CategoryCard(
                    item: categories[index],
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => categories[index].isAi
                              ? const PhotoQuestionPage()
                              : CategoryDetailPage(item: categories[index]),
                        ),
                      );
                      _refreshTip();
                    },
                  );
                },
              ),
              const SizedBox(height: 16),
              _buildGuideButton(context),
              const SizedBox(height: 10),
              _buildFaqButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroBanner(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFDE7), // 배너 배경색
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFFFFF176),
              width: 1.5,
            ), // 배너 테두리색
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'AI 분리배출 도우미',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFF9A825),
                  letterSpacing: 1,
                ),
              ), // 소제목 색
              const SizedBox(height: 6),
              const Text(
                '버리기 전에 한 번만',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF222222),
                ),
              ), // 제목 색
              const SizedBox(height: 4),
              const Text(
                '쓰레기 종류를 모르겠을 때\n채팅이나 사진으로 바로 물어보세요',
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF555555),
                  height: 1.4,
                ),
              ), // 배너 본문 텍스트 색
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ChatQuestionPage(),
                        ),
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF7E079),
                          borderRadius: BorderRadius.circular(12),
                        ), // 버튼 배경색
                        child: const Center(
                          child: Text(
                            '💬 채팅으로',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF5D4037),
                            ),
                          ),
                        ), // 버튼 텍스트 색
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const PhotoQuestionPage(),
                        ),
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFFFF),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFFFAE275),
                            width: 1.5,
                          ),
                          // '📷 사진으로' 버튼 테두리색
                        ),
                        child: const Center(
                          child: Text(
                            '📷 사진으로',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF333333),
                            ),
                          ),
                        ), // 버튼 텍스트 색
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Positioned(
          top: 12,
          right: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: _isAiConnected
                        ? const Color(0xFF4CAF50)
                        : const Color(0xFFE53935),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  _isAiConnected ? 'AI 연결됨' : 'AI 연결 안됨',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: _isAiConnected
                        ? const Color(0xFF4CAF50)
                        : const Color(0xFFE53935),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTodayTip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9), // tip 박스 배경색
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFC8E6C9)), // tip 박스 테두리색
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('💡', style: TextStyle(fontSize: 20)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '오늘의 팁',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2E7D32),
                  ),
                ), // 제목 색
                const SizedBox(height: 2),
                Text(
                  _todayTip,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF1B5E20),
                    height: 1.4,
                  ),
                ), // tip 본문 텍스트 색
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommunityButton(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CommunityPage()),
        );
        _refreshTip();
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF9C4), // 커뮤니티 버튼 배경색
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFFDD835),
            width: 1.5,
          ), // 커뮤니티 버튼 테두리색
        ),
        child: const Row(
          children: [
            Text('💬', style: TextStyle(fontSize: 20)),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                '여러분의 의견을 남겨주세요!',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF5D4037),
                ),
              ),
            ), // 커뮤니티 버튼 텍스트 색
            Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFF5D4037),
            ), // 커뮤니티 버튼 아이콘 색
          ],
        ),
      ),
    );
  }

  Widget _buildGuideButton(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const DisposalGuidePage()),
        );
        _refreshTip();
      },
      child: Container(
        width: double.infinity,
        height: 48,
        decoration: BoxDecoration(
          color: const Color(0xFFEDE7F6), // '4단계 분리배출 가이드' 버튼 배경
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('📋', style: TextStyle(fontSize: 15)),
            SizedBox(width: 8),
            Text(
              '4단계 분리배출 가이드',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF4527A0),
              ),
            ), // 버튼 텍스트
          ],
        ),
      ),
    );
  }

  Widget _buildFaqButton(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const FaqPage()),
        );
        _refreshTip();
      },
      child: Container(
        width: double.infinity,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: const Color(0xFFE0E0E0),
            width: 1.5,
          ), // '자주 묻는 질문' 버튼 테두리
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('❓', style: TextStyle(fontSize: 14)),
            SizedBox(width: 6),
            Text(
              '자주 묻는 질문',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF333333),
              ),
            ), // 버튼 텍스트
          ],
        ),
      ),
    );
  }
}
