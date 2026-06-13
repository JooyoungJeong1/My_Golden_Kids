import 'package:flutter/material.dart';
import '../models/category.dart';
import '../models/user_session.dart';
import '../widgets/category_card.dart';
import 'chat_page.dart';
import 'photo_page.dart';
import 'community_page.dart';
import 'my_page.dart';
import 'guide_page.dart';
import 'category_detail_page.dart';
import '../services/api_service.dart';

// ───────────────────────────────────────────
// 메인 화면 (하단 네비게이션)
// ───────────────────────────────────────────

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomeScreen(),
    const CommunityPage(),
    const MyPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Color(0xFFEAEAEA), width: 1)),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF5D4037),
          unselectedItemColor: const Color(0xFF999999),
          selectedFontSize: 11,
          unselectedFontSize: 11,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: '홈'),
            BottomNavigationBarItem(
              icon: Icon(Icons.forum_rounded),
              label: '커뮤니티',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_rounded),
              label: '마이페이지',
            ),
          ],
        ),
      ),
    );
  }
}

// ───────────────────────────────────────────
// 홈 화면
// ───────────────────────────────────────────

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isAiConnected = false;

  static final List<String> _tips = [
    '페트병은 라벨을 떼고 압축해 배출해요!',
    '배달 플라스틱 용기는 헹군 뒤 물기 빼고 배출해요!',
    '샴푸통은 내용물을 비우고 헹궈 배출해요!',
    '요거트 용기는 비닐을 떼고 헹궈 배출해요!',
    '빨대는 재활용이 어려워 종량제봉투에 버려요!',
    '투명 페트병은 전용 수거함에 따로 넣어요!',

    '과자 봉지는 내용물을 비우고 비닐로 배출해요!',
    '에어캡(뽁뽁이)은 테이프를 떼고 비닐로 배출해요!',
    '일회용 비닐은 내용물 털어 비닐로 분리해요!',

    '유리병은 뚜껑과 라벨을 떼고 헹궈 배출해요!',
    '색깔별 수거함이 있으면 유리병도 색깔별로 배출해요!',
    '깨진 유리는 신문지에 싸서 종량제봉투에 버려요!',
    '내열유리 식기는 유리류로 재활용 안 돼요!',

    '음료 캔은 비우고 헹궈 압축해 배출해요!',
    '통조림 캔은 뚜껑 날에 주의해요!',
    '통조림 캔 뚜껑은 안으로 접어 배출해요!',
    '부탄가스는 가스 제거 후 캔류로 배출해요!',
    '에어로졸 캔은 가스 제거 후 캔류로 배출해요!',
    '기름 묻은 캔은 닦고 헹궈 배출해요!',
    '캔류는 유리와 섞지 말고 따로 배출해요!',

    '종이팩은 펼쳐 말린 뒤 접어 배출해요!',
    '영수증은 종량제봉투에 버려요!',
    '피자박스는 기름 묻은 부분만 버려요!',
    '택배상자는 테이프·전표 떼고 접어 배출해요!',
    '휴지·티슈는 종량제봉투에 버려요!',
    '책·노트는 스프링 빼고 종이류로 배출해요!',
    '종이쇼핑백은 끈을 떼고 종이류로 배출해요!',
    '우유팩은 종이류가 아닌 전용 수거함에 따로 배출해야 해요!',

    '형광등은 깨지지 않게 전용수거함에 배출해요!',
    '재활용품은 비우고 헹구는 게 기본이에요!',
    '재질이 헷갈리면 재활용 표시 마크를 확인해요!',
    '하루 하나라도 꾸준히 실천하면 큰 변화예요!',
    '장볼 때 장바구니 챙겨 비닐 사용 줄여봐요!',
    '텀블러 사용으로 일회용 컵을 대신해봐요!',
    '포장 적은 제품을 골라 쓰레기량 줄여봐요!',
    '필요 없는 빨대·일회용 수저는 거절해요!',
    '동네 분리배출 요일과 기준을 미리 확인해요!',
    '재활용품은 젖지 않게 말려서 배출해요!',
    '집에 분리수거 구역을 따로 만들어 두세요!',
    '헌옷은 깨끗할 때만 수거함에 넣어주세요!',
    '스티로폼은 스티로폼 전용 수거함에 넣어야 해요!',
    '건전지와 형광등은 각각 전용 수거함이 따로 있어요!',
  ]; //오늘의 팁 문구

  late String _todayTip;

  @override
  void initState() {
    super.initState();
    _checkAiConnection();
    _tips.shuffle();
    _todayTip = _tips.first;
  }

  Future<void> _checkAiConnection() async {
    final connected = await ApiService.checkConnection();
    if (mounted) setState(() => _isAiConnected = connected);
  }

  void _refreshTip() {
    setState(() {
      _tips.shuffle();
      _todayTip = _tips.first;
    });
  }

  static const List<CategoryItem> categories = [
    CategoryItem(
      label: '종이류',
      subtitle: '박스·신문·책',
      bgColor: Color(0xFFFFFFFF),
      imageUrl: 'assets/images/종이류.png',
    ),
    CategoryItem(
      label: '캔류',
      subtitle: '음료·통조림',
      bgColor: Color(0xFFFFFFFF),
      imageUrl: 'assets/images/캔류.png',
    ),
    CategoryItem(
      label: '유리',
      subtitle: '병·깨진유리',
      bgColor: Color(0xFFFFFFFF),
      imageUrl: 'assets/images/유리류.png',
    ),
    CategoryItem(
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
        centerTitle: true,
        title: Image.asset('assets/images/앱로고.png', height: 60),
        actions: [
          GestureDetector(
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MyPage()),
              );
              setState(() {});
              _refreshTip();
            },
            child: UserSession.isLoggedIn
                ? Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: const BoxDecoration(
                            color: Color(0xFFFDD835),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              UserSession.profileEmoji,
                              style: const TextStyle(fontSize: 18),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          UserSession.nickname ?? '',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF222222),
                          ),
                        ),
                      ],
                    ),
                  )
                : const Padding(
                    padding: EdgeInsets.only(right: 12),
                    child: Icon(
                      Icons.account_circle_outlined,
                      color: Color(0xFF555555),
                      size: 26,
                    ),
                  ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(14, 15, 14, 16),
          // 앱바 - 배너 간격(왼쪽, 위, 오른쪽, 아래)
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeroBanner(context),
              const SizedBox(height: 8), // 베너 - 팁 간격
              _buildTodayTip(),
              const SizedBox(height: 8), // 팁 - 4단계 간격
              // 4단계 분리배출 가이드 (커뮤니티 자리로 이동)
              _buildGuideButton(context),
              const SizedBox(height: 20), // 4단계 - 카테고리 간격
              const Text(
                '카테고리별 배출법',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF222222),
                ),
              ),
              const SizedBox(height: 12), // 제목 - 그리드 간격
              GridView.builder(
                itemCount: categories.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 9,
                  mainAxisSpacing: 9,
                  childAspectRatio: 0.95,
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
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFDE7),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFFFF176), width: 1.5),
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
              ),
              const SizedBox(height: 6),
              const Text(
                '버리기 전에 한 번만',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF222222),
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                '쓰레기 종류를 모르겠을 때\n채팅이나 사진으로 바로 물어보세요',
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF555555),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 10),
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
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF7E079),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: Text(
                            '💬 채팅으로',
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
                        ),
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
      height: 65,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFC8E6C9)),
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
                    fontSize: 13, // "오늘의 팁" 글자 크기
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2E7D32),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _todayTip,
                  style: const TextStyle(
                    fontSize: 12, // 오늘의 팁 작은 글자 크기
                    color: Color(0xFF1B5E20),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
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
        height: 65,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFEDE7F6),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color.fromARGB(255, 219, 199, 249)),
        ),
        child: const Row(
          children: [
            Text('📋', style: TextStyle(fontSize: 20)),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                '4단계 분리배출 가이드',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF4527A0),
                ),
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: Color(0xFF4527A0)),
          ],
        ),
      ),
    );
  }
}
