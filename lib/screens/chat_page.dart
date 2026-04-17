import 'package:flutter/material.dart';
import '../widgets/typing_indicator.dart';

// ───────────────────────────────────────────
// 채팅 페이지
// ───────────────────────────────────────────

class _ChatItem {
  final String text;
  final bool isMe;
  const _ChatItem({required this.text, required this.isMe});
}

// FAQ 데이터 (자주 묻는 질문)
const List<Map<String, String>> _faqList = [
  {
    'q': '플라스틱은 모두 재활용 가능한가요?',
    'a':
        '오염이 심하거나 복합 재질(플라스틱+금속 등)이면 일반쓰레기로 분류됩니다.\n용기에 표시된 재질 마크를 확인하고, 깨끗이 씻어 배출하세요.',
  },
  {
    'q': '음식물이 묻은 종이는?',
    'a': '피자 박스처럼 기름이 심하게 밴 종이는 일반쓰레기입니다.\n약간 묻은 경우 오염 부분을 제거 후 배출 가능합니다.',
  },
  {
    'q': '유리병 뚜껑은 어떻게 버려요?',
    'a': '금속 뚜껑은 캔류로, 플라스틱 뚜껑은 플라스틱으로 분리해서 배출합니다.\n유리병 본체는 유리 수거함에 따로 넣어주세요.',
  },
  {
    'q': '영수증(감열지)은 어디에 버려요?',
    'a': '영수증, 택배 송장, 코팅지는 일반쓰레기입니다.\n재활용 표시가 있어도 감열 처리된 종이는 재활용이 안 됩니다.',
  },
  {
    'q': '깨진 유리는 어떻게 버려요?',
    'a':
        '신문지나 종이로 단단히 싸서 \'깨진 유리\'라고 표시 후\n일반쓰레기 봉투에 넣어 배출하세요.\n\n⚠️ 유리 수거함에 넣으면 안 돼요!',
  },
  {
    'q': '건전지·배터리는 어디에 버려요?',
    'a':
        '폐건전지 전용 수거함에 배출해요! 🔋\n\n대형마트, 주민센터, 아파트 단지 등에 있어요.\n충전식 배터리(리튬이온)는 전자제품 매장 수거함에 배출하세요.\n\n🚨 일반쓰레기로 버리면 화재 위험!',
  },
];

// 키워드 → 카테고리 매핑
const Map<String, String> _keywordMap = {
  '페트병': '페트병',
  '페트': '페트병',
  'pet': '페트병',
  'PET': '페트병',
  '종이': '종이',
  '박스': '박스',
  '신문': '신문지',
  '신문지': '신문지',
  '우유팩': '우유팩',
  '종이컵': '종이컵',
  '영수증': '영수증',
  '유리': '유리병',
  '유리병': '유리병',
  '술병': '유리병',
  '소스병': '유리병',
  '캔': '캔',
  '음료캔': '캔',
  '통조림': '통조림',
  '부탄가스': '부탄가스',
  '플라스틱': '플라스틱',
  '비닐': '비닐',
  '봉투': '비닐봉투',
  '스티로폼': '스티로폼',
  '발포스티렌': '스티로폼',
  '건전지': '건전지',
  '배터리': '건전지',
  '형광등': '형광등',
  '의약품': '의약품',
  '약': '의약품',
};

// 카테고리별 기본 답변
const Map<String, String> _baseAnswers = {
  '페트병':
      '페트병 분리배출 방법이에요! ♻️\n\n① 라벨 제거 (비닐 라벨은 비닐류로!)\n② 내용물 비우고 헹구기\n③ 찌그러트려 뚜껑 닫기\n④ 플라스틱 수거함에 배출',
  '종이': '종이류 분리배출 방법이에요! 📄\n\n① 테이프·스티커 제거\n② 납작하게 펼치기\n③ 끈으로 묶어서 종이류 수거함에 배출',
  '박스':
      '박스 분리배출 방법이에요! 📦\n\n① 테이프·스티커 완전히 제거\n② 납작하게 펼치기\n③ 끈으로 묶거나 박스 수거함에 배출',
  '신문지':
      '신문지는 종이류로 배출해요! 📰\n\n① 납작하게 펼치거나 묶기\n② 종이류 수거함에 배출\n\n⚠️ 비에 젖었거나 너무 오염된 경우 일반쓰레기로!',
  '우유팩':
      '우유팩은 일반 종이와 달라요! 🥛\n\n① 내부를 깨끗이 헹구기\n② 납작하게 펼치기\n③ 우유팩 전용 수거함에 배출\n\n⚠️ 일반 종이류 수거함이 아닌 전용 수거함이에요!',
  '종이컵':
      '종이컵도 전용 수거함이 있어요! ☕\n\n① 이물질 제거 후 헹구기\n② 종이컵 전용 수거함에 배출\n\n⚠️ 일반 종이류와 혼합 배출 불가예요!',
  '영수증':
      '영수증은 재활용이 안 돼요! 🧾\n\n영수증, 택배 송장, 코팅지는 감열지라서\n재활용 표시가 있어도 일반쓰레기로 버려야 해요.',
  '유리병':
      '유리병 분리배출 방법이에요! 🍶\n\n① 내용물 비우고 헹구기\n② 뚜껑 분리 (금속→캔류, 플라스틱→플라스틱)\n③ 유리 전용 수거함에 배출',
  '캔': '캔류 분리배출 방법이에요! 🥤\n\n① 내용물 비우고 헹구기\n② 찌그러트리기\n③ 캔 전용 수거함에 배출',
  '통조림': '통조림 캔 분리배출 방법이에요! 🥫\n\n① 내용물 완전히 비우기\n② 물로 헹구기\n③ 캔 전용 수거함에 배출',
  '부탄가스':
      '부탄가스 캔은 주의가 필요해요! ⚠️\n\n① 가스를 완전히 소진시키기\n② 구멍을 뚫어 잔여 가스 완전히 빼기\n③ 캔 전용 수거함에 배출\n\n🚨 가스가 남은 상태로 버리면 위험해요!',
  '플라스틱':
      '플라스틱 분리배출 방법이에요! ♻️\n\n① 라벨 제거\n② 내용물 비우고 헹구기\n③ 찌그러트리기\n④ 플라스틱 수거함에 배출',
  '비닐': '비닐류 분리배출 방법이에요! 🛍️\n\n① 음식물 등 이물질 제거\n② 테이프·스티커 제거\n③ 비닐 전용 수거함에 배출',
  '비닐봉투':
      '비닐봉투 분리배출 방법이에요! 🛍️\n\n깨끗한 비닐봉투는 재활용 가능해요!\n\n① 이물질 제거\n② 비닐 전용 수거함에 배출\n\n⚠️ 음식물이 묻은 경우 일반쓰레기로!',
  '스티로폼':
      '스티로폼 분리배출 방법이에요! 📦\n\n① 테이프·스티커 완전히 제거\n② 이물질 제거\n③ 스티로폼 전용 수거함에 배출\n\n⚠️ 플라스틱 수거함이 아닌 전용 수거함이에요!',
  '건전지':
      '건전지는 전용 수거함이 있어요! 🔋\n\n① 폐건전지 전용 수거함에 배출\n   (마트, 주민센터, 아파트 단지 등)\n\n⚠️ 일반쓰레기나 재활용 수거함에 넣으면 안 돼요!',
  '형광등':
      '형광등은 전용 수거함이 있어요! 💡\n\n① 깨지지 않게 조심해서 형광등 전용 수거함에 배출\n   (주민센터, 아파트 단지 등)\n\n⚠️ 깨진 경우 신문지로 싸서 일반쓰레기로!',
  '의약품':
      '의약품은 전용 수거함이 있어요! 💊\n\n① 약국이나 보건소의 폐의약품 수거함에 배출\n\n⚠️ 변기나 하수구에 버리면 수질 오염돼요!',
};

// 카테고리별 꼬리질문 트리
const Map<String, List<Map<String, String>>> _followUpTree = {
  '페트병': [
    {
      'q': '오염됐어요',
      'a':
          '오염 정도에 따라 달라요!\n\n조금 묻은 경우 → 물로 헹궈서 배출 가능\n기름·음식물이 심하게 묻은 경우 → 일반쓰레기로 버려야 해요 🗑️',
    },
    {
      'q': '라벨은 어떻게 해요?',
      'a':
          '라벨은 꼭 제거해야 해요! 🏷️\n\n비닐 라벨 → 비닐류 수거함\n종이 라벨 → 종이류 수거함\n잘 안 떼어지면 물에 불려서 제거하세요!',
    },
    {
      'q': '뚜껑은요?',
      'a': '뚜껑을 닫아서 버려도 돼요! 🔵\n\n찌그러트린 후 뚜껑을 닫으면\n부피도 줄고 재활용도 더 잘 돼요 😊',
    },
    {
      'q': '색깔 있는 페트병은요?',
      'a':
          '색깔 있는 페트병도 재활용 가능해요! ♻️\n\n다만 무색 투명 페트병이 재활용 가치가 더 높아요.\n색깔 페트병도 라벨 제거 후 동일하게 배출하면 돼요!',
    },
  ],
  '유리병': [
    {
      'q': '깨진 유리는요?',
      'a':
          '깨진 유리는 따로 처리해야 해요! 🚨\n\n① 신문지나 종이로 꼼꼼히 싸기\n② "깨진 유리"라고 표시\n③ 일반쓰레기 봉투에 배출\n\n⚠️ 유리 수거함에 넣으면 환경미화원이 다칠 수 있어요!',
    },
    {
      'q': '뚜껑은 어떻게 해요?',
      'a': '뚜껑은 재질에 따라 분리해요! 🔩\n\n금속 뚜껑 → 캔류 수거함\n플라스틱 뚜껑 → 플라스틱 수거함',
    },
    {
      'q': '내용물이 남아있어요',
      'a':
          '내용물을 비워야 해요! 💧\n\n물로 한두 번 헹궈주세요.\n완벽히 깨끗하지 않아도 되지만\n남은 음식물은 제거해야 해요!',
    },
  ],
  '캔': [
    {
      'q': '부탄가스 캔은요?',
      'a':
          '부탄가스 캔은 반드시 가스를 빼야 해요! ⚠️\n\n① 가스 완전히 소진\n② 구멍을 뚫어 잔여가스 제거\n③ 캔 수거함에 배출\n\n🚨 가스가 남은 상태로 버리면 폭발 위험이 있어요!',
    },
    {
      'q': '음료 남아있어요',
      'a':
          '내용물을 완전히 비워야 해요! 🥤\n\n물로 한 번 헹구면 더 좋아요.\n찌그러트려서 부피를 줄이면 수거함 공간도 아낄 수 있어요!',
    },
  ],
  '종이': [
    {
      'q': '음식물 묻었어요',
      'a':
          '오염 정도에 따라 달라요! 📄\n\n조금 묻은 경우 → 오염 부분 제거 후 배출 가능\n기름이 심하게 밴 경우 (피자박스 등) → 일반쓰레기\n\n⚠️ 기름 묻은 종이는 재활용 과정에서 다른 종이를 오염시켜요!',
    },
    {
      'q': '코팅된 종이는요?',
      'a': '코팅지는 재활용이 안 돼요! 🚫\n\n코팅지, 영수증, 방수 처리된 종이는\n모두 일반쓰레기로 버려야 해요.',
    },
    {
      'q': '책은요?',
      'a':
          '책은 종이류로 배출 가능해요! 📚\n\n스프링 제본 → 스프링 제거 후 배출\n양장본 하드커버 → 커버 분리 후 배출\n일반 종이 묶음과 함께 배출하면 돼요!',
    },
  ],
  '비닐': [
    {
      'q': '음식물 묻었어요',
      'a':
          '음식물이 묻은 비닐은 재활용이 어려워요 😢\n\n조금 묻은 경우 → 씻어서 건조 후 배출 가능\n많이 오염된 경우 → 일반쓰레기로 버려야 해요\n\n치킨봉투, 과자봉지 등 기름기가 많은 건 일반쓰레기예요!',
    },
    {
      'q': '뽁뽁이(에어캡)는요?',
      'a':
          '뽁뽁이(에어캡)는 비닐류로 배출해요! 💨\n\n깨끗한 상태라면 비닐 수거함에 배출 가능해요.\n오염된 경우 일반쓰레기로!',
    },
    {
      'q': '지퍼백은요?',
      'a':
          '깨끗한 지퍼백은 재활용 가능해요! 🤐\n\n이물질 제거 후 비닐 수거함에 배출하면 돼요.\n오염된 경우는 일반쓰레기로!',
    },
  ],
  '스티로폼': [
    {
      'q': '테이프 붙어있어요',
      'a':
          '테이프는 꼭 제거해야 해요! 🏷️\n\n테이프, 스티커를 모두 제거한 후\n스티로폼 전용 수거함에 배출해요.\n\n테이프가 붙은 채로 버리면 재활용이 안 돼요!',
    },
    {
      'q': '음식 담았던 용기는요?',
      'a':
          '음식 용기 스티로폼은 깨끗이 씻어야 해요! 🍱\n\n① 음식물 완전히 제거\n② 물로 깨끗이 씻기\n③ 스티로폼 전용 수거함에 배출\n\n⚠️ 오염이 심한 경우 일반쓰레기로!',
    },
  ],
  '건전지': [
    {
      'q': '어디서 버려요?',
      'a':
          '폐건전지 전용 수거함 위치예요! 🔋\n\n• 대형마트\n• 주민센터\n• 아파트 단지 내 수거함\n• 편의점 (일부)\n\n수거함이 없으면 주민센터에 문의하세요!',
    },
    {
      'q': '충전식 배터리도요?',
      'a':
          '충전식 배터리(리튬이온 등)도 전용 수거함이에요! ⚡\n\n핸드폰 배터리, 보조배터리 등은\n전자제품 매장이나 주민센터 수거함에 배출해요.\n\n🚨 일반쓰레기로 버리면 화재 위험이 있어요!',
    },
  ],
  '형광등': [
    {
      'q': '어디서 버려요?',
      'a':
          '형광등 전용 수거함 위치예요! 💡\n\n• 주민센터\n• 아파트 단지 내 수거함\n• 대형마트 (일부)\n\n수거함이 없으면 주민센터에 문의하세요!',
    },
    {
      'q': '깨졌어요',
      'a':
          '깨진 형광등은 위험해요! 🚨\n\n① 환기 먼저 하기 (수은 증기 위험)\n② 장갑 끼고 조각 수거\n③ 신문지로 싸서 밀봉\n④ 일반쓰레기로 배출\n\n⚠️ 맨손으로 만지지 마세요!',
    },
  ],
};

String? _detectKeyword(String text) {
  final lower = text.toLowerCase().replaceAll(' ', '');
  for (final entry in _keywordMap.entries) {
    if (lower.contains(entry.key.toLowerCase())) {
      return entry.value;
    }
  }
  return null;
}

class ChatQuestionPage extends StatefulWidget {
  const ChatQuestionPage({super.key});
  @override
  State<ChatQuestionPage> createState() => _ChatQuestionPageState();
}

class _ChatQuestionPageState extends State<ChatQuestionPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<_ChatItem> _messages = [];
  bool _isTyping = false;
  List<Map<String, String>> _currentFollowUps = [];
  String? _lastCategory;

  // FAQ 모드 빌드
  String _buildFaqMenu() {
    final buffer = StringBuffer();
    buffer.writeln('자주 묻는 질문이에요! ❓\n');
    for (int i = 0; i < _faqList.length; i++) {
      buffer.writeln('${i + 1}. ${_faqList[i]['q']}');
    }
    buffer.writeln('\n번호를 입력하면 답변을 알려드려요!');
    return buffer.toString();
  }

  @override
  void initState() {
    super.initState();
    _messages.add(
      _ChatItem(
        text:
            '안녕하세요! 버리는 방법이 헷갈리는 쓰레기가 있으신가요?\n\n품목 이름을 입력하거나, 아래 버튼을 눌러보세요 😊',
        isMe: false,
      ),
    );
    _currentFollowUps = [
      {'q': '❓ 자주 묻는 질문', 'a': ''},
      {'q': '페트병은요?', 'a': ''},
      {'q': '스티로폼은요?', 'a': ''},
    ];
  }

  void _sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    _controller.clear();
    FocusScope.of(context).unfocus();

    setState(() {
      _messages.add(_ChatItem(text: text, isMe: true));
      _isTyping = true;
      _currentFollowUps = [];
    });
    _scrollToBottom();

    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;

    String reply = '';
    List<Map<String, String>> followUps = [];

    // FAQ 번호 입력 체크 (1~6)
    final trimmed = text.trim().replaceAll(RegExp(r'[^0-9]'), '');
    final faqNum = trimmed.isNotEmpty ? int.tryParse(trimmed) : null;
    if (faqNum != null && faqNum >= 1 && faqNum <= _faqList.length) {
      final faq = _faqList[faqNum - 1];
      reply = '❓ ${faq['q']}\n\n${faq['a']}';
      _lastCategory = null;
      followUps = [
        {'q': '❓ 자주 묻는 질문', 'a': ''},
        {'q': '다른 품목 물어보기', 'a': ''},
      ];

      setState(() {
        _isTyping = false;
        _messages.add(_ChatItem(text: reply, isMe: false));
        _currentFollowUps = followUps;
      });
      _scrollToBottom();
      return;
    }

    // 꼬리질문 답변인지 확인
    bool isFollowUp = false;
    if (_lastCategory != null) {
      final tree = _followUpTree[_lastCategory!] ?? [];
      for (final item in tree) {
        if (item['q'] == text) {
          reply = item['a']!;
          isFollowUp = true;
          followUps = tree.where((t) => t['q'] != text).take(2).toList();
          followUps.add({'q': '다른 품목 물어보기', 'a': ''});
          break;
        }
      }
    }

    if (!isFollowUp) {
      final keyword = _detectKeyword(text);
      if (keyword != null && _baseAnswers.containsKey(keyword)) {
        reply = _baseAnswers[keyword]!;
        _lastCategory = keyword;
        followUps = (_followUpTree[keyword] ?? []).take(3).toList();
      } else if (text == '다른 품목 물어보기') {
        reply = '어떤 품목이 궁금하세요? 😊\n\n품목 이름을 직접 입력하거나 아래 버튼을 눌러보세요!';
        _lastCategory = null;
        followUps = [
          {'q': '❓ 자주 묻는 질문', 'a': ''},
          {'q': '페트병은요?', 'a': ''},
          {'q': '유리병은요?', 'a': ''},
          {'q': '건전지는요?', 'a': ''},
        ];
      } else {
        reply =
            '"$text"에 대한 정보를 찾지 못했어요 😅\n\n품목 이름을 더 정확하게 입력해보세요!\n예) 페트병, 유리병, 스티로폼, 건전지 등';
        _lastCategory = null;
        followUps = [
          {'q': '❓ 자주 묻는 질문', 'a': ''},
          {'q': '페트병은요?', 'a': ''},
          {'q': '비닐봉투는요?', 'a': ''},
        ];
      }
    }

    setState(() {
      _isTyping = false;
      _messages.add(_ChatItem(text: reply, isMe: false));
      _currentFollowUps = followUps;
    });
    _scrollToBottom();
  }

  void _onFollowUpTap(Map<String, String> item) {
    if (item['q'] == '❓ 자주 묻는 질문') {
      // FAQ 메뉴 표시
      setState(() {
        _messages.add(const _ChatItem(text: '❓ 자주 묻는 질문', isMe: true));
        _isTyping = true;
        _currentFollowUps = [];
      });
      _scrollToBottom();

      Future.delayed(const Duration(milliseconds: 600), () {
        if (!mounted) return;
        setState(() {
          _isTyping = false;
          _messages.add(_ChatItem(text: _buildFaqMenu(), isMe: false));
          _currentFollowUps = [
            {'q': '다른 품목 물어보기', 'a': ''},
          ];
          _lastCategory = null;
        });
        _scrollToBottom();
      });
      return;
    }

    if (item['q'] == '다른 품목 물어보기' || item['a'] == '') {
      String query = item['q']!
          .replaceAll('은요?', '')
          .replaceAll('는요?', '')
          .replaceAll('은요', '')
          .trim();
      _sendMessage(query);
    } else {
      _sendMessage(item['q']!);
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          title: const Text('AI 채팅 도우미'),
          backgroundColor: const Color(0xFFF6F1F6),
          surfaceTintColor: Colors.transparent,
          foregroundColor: const Color(0xFF222222),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  controller: _scrollController,
                  padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
                  children: [
                    Center(
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          '오늘',
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF999999),
                          ),
                        ),
                      ),
                    ),
                    ..._messages.map((m) => _buildBubble(m)),
                    if (!_isTyping && _currentFollowUps.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: _currentFollowUps
                              .map(
                                (item) => GestureDetector(
                                  onTap: () => _onFollowUpTap(item),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: item['q'] == '❓ 자주 묻는 질문'
                                          ? const Color(0xFFE3F2FD)
                                          : const Color(0xFFFFF9C4),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: item['q'] == '❓ 자주 묻는 질문'
                                            ? const Color(0xFF90CAF9)
                                            : const Color(0xFFFDD835),
                                      ),
                                    ),
                                    child: Text(
                                      item['q']!,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: item['q'] == '❓ 자주 묻는 질문'
                                            ? const Color(0xFF1565C0)
                                            : const Color(0xFF7A6000),
                                      ),
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    if (_isTyping)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.only(top: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          decoration: const BoxDecoration(
                            color: Color(0xFFF2EEF3),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(18),
                              topRight: Radius.circular(18),
                              bottomRight: Radius.circular(18),
                              bottomLeft: Radius.circular(4),
                            ),
                          ),
                          child: const TypingIndicator(),
                        ),
                      ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 16),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: Color(0xFFEAEAEA))),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        textInputAction: TextInputAction.send,
                        minLines: 1,
                        maxLines: 4,
                        onSubmitted: _sendMessage,
                        decoration: InputDecoration(
                          hintText: '품목 이름 또는 번호 입력...',
                          hintStyle: const TextStyle(color: Color(0xFFBBBBBB)),
                          filled: true,
                          fillColor: const Color(0xFFF7F4F8),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => _sendMessage(_controller.text),
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFDD835),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.send_rounded,
                          color: Color(0xFF5D4037),
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBubble(_ChatItem m) {
    return Align(
      alignment: m.isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: m.isMe ? const Color(0xFFFFE978) : const Color(0xFFF2EEF3),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(m.isMe ? 18 : 4),
            bottomRight: Radius.circular(m.isMe ? 4 : 18),
          ),
        ),
        child: Text(
          m.text,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF222222),
            height: 1.5,
          ),
        ),
      ),
    );
  }
}
