import 'package:flutter/material.dart';
import '../models/community.dart';
import '../models/user_session.dart';
import 'my_page.dart';
import '../services/log_service.dart';

// ───────────────────────────────────────────
// 커뮤니티 메인 페이지
// ───────────────────────────────────────────

class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key});
  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  int _tabIndex = 0; // 0: 전체, 1: 내 글, 2: 내 댓글
  final List<CommunityPost> _posts = [
    CommunityPost(
      author: '지구수호자',
      sessionId: '',
      title: '우유팩은 종이류인가요?',
      content: '겉보기엔 종이 같은데 안쪽 코팅이 있어서 헷갈려요. 어떻게 버리면 되나요?',
      likes: 12,
      comments: [
        CommunityComment(
          author: '분리배출왕',
          content: '일반 종이랑은 다르고, 보통 우유팩 전용 수거함이 있으면 거기로 버려야 해요.',
        ),
        CommunityComment(
          author: '관리자',
          content: '지역별 기준이 조금 달라서 주민센터 안내도 같이 확인해보세요.',
        ),
      ],
    ),
    CommunityPost(
      author: '초보분리러',
      sessionId: '',
      title: '음식물 묻은 비닐은 재활용 안 되죠?',
      content: '치킨 포장 비닐처럼 기름이 많이 묻은 건 일반쓰레기 맞나요?',
      likes: 5,
      comments: [
        CommunityComment(author: '환경친구', content: '네 맞아요. 오염이 심하면 재활용이 어렵습니다.'),
      ],
    ),
  ]; // 하드코딩:: 게시글 작성 전 보이게 만든 게시물, 댓글

  void _openWritePage() async {
    final newPost = await Navigator.push<CommunityPost>(
      context,
      MaterialPageRoute(builder: (_) => const CommunityWritePage()),
    );
    if (newPost != null) setState(() => _posts.insert(0, newPost));
  }

  void _openDetailPage(int index) async {
    final updatedPost = await Navigator.push<CommunityPost>(
      context,
      MaterialPageRoute(
        builder: (_) => CommunityDetailPage(post: _posts[index]),
      ),
    );
    if (updatedPost != null) setState(() => _posts[index] = updatedPost);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('커뮤니티'),
        backgroundColor: const Color(0xFFF6F1F6),
        surfaceTintColor: Colors.transparent,
        foregroundColor: const Color(0xFF222222),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(44),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Row(
              children: [
                _buildTab('전체 글', 0),
                const SizedBox(width: 8),
                _buildTab('내가 쓴 글', 1),
                const SizedBox(width: 8),
                _buildTab('내가 쓴 댓글', 2),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: _tabIndex == 0
          ? FloatingActionButton(
              onPressed: _openWritePage,
              backgroundColor: const Color(0xFFFDD835),
              foregroundColor: const Color(0xFF5D4037),
              child: const Icon(Icons.edit_rounded),
            )
          : null,
      body: SafeArea(child: _buildBody()),
    );
  }

  Widget _buildTab(String label, int index) {
    final isSelected = _tabIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _tabIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFDD835) : const Color(0xFFF0EEF1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: isSelected
                ? const Color(0xFF5D4037)
                : const Color(0xFF888888),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginRequired() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🔒', style: TextStyle(fontSize: 40)),
          const SizedBox(height: 12),
          const Text(
            '로그인 후 확인할 수 있어요',
            style: TextStyle(fontSize: 14, color: Color(0xFF777777)),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MyPage()),
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFFDD835),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                '로그인하러 가기',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF5D4037),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    List<CommunityPost> filtered;

    if (_tabIndex == 0) {
      filtered = _posts.where((p) {
        // 신고 3개 이상이면 전체 숨김
        if (p.isHidden) return false;
        // 로그인한 사용자가 신고한 게시글은 해당 사용자에게만 숨김
        if (UserSession.isLoggedIn &&
            p.reportedBy.contains(UserSession.email!)) {
          return false;
        }
        return true;
      }).toList();
    } else if (_tabIndex == 1) {
      if (!UserSession.isLoggedIn) return _buildLoginRequired();
      final myNames = [UserSession.nickname!, ...UserSession.guestNicknames];
      filtered = _posts.where((p) => myNames.contains(p.author)).toList();
    } else {
      if (!UserSession.isLoggedIn) return _buildLoginRequired();
      final myNames = [UserSession.nickname!, ...UserSession.guestNicknames];
      filtered = _posts
          .where((p) => p.comments.any((c) => myNames.contains(c.author)))
          .toList();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final post = filtered[index];
        final realIndex = _posts.indexOf(post);
        return GestureDetector(
          onTap: () => _openDetailPage(realIndex),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFEAEAEA)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF222222),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  post.content,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF555555),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Text(
                      post.author,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF888888),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '댓글 ${post.comments.length}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF999999),
                      ),
                    ),
                    const Spacer(),
                    // 목록에서 공감 버튼 탭 가능
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          if (post.isLiked) {
                            post.isLiked = false;
                            post.likes--;
                          } else {
                            post.isLiked = true;
                            post.likes++;
                          }
                        });
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            post.isLiked
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            size: 16,
                            color: post.isLiked
                                ? const Color(0xFFE53935)
                                : const Color(0xFF999999),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${post.likes}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: post.isLiked
                                  ? const Color(0xFFE53935)
                                  : const Color(0xFF888888),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ───────────────────────────────────────────
// 글쓰기 페이지
// ───────────────────────────────────────────

class CommunityWritePage extends StatefulWidget {
  const CommunityWritePage({super.key});
  @override
  State<CommunityWritePage> createState() => _CommunityWritePageState();
}

class _CommunityWritePageState extends State<CommunityWritePage> {
  final TextEditingController _authorController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (UserSession.isLoggedIn) _authorController.text = UserSession.nickname!;
  }

  void _submit() {
    if (_authorController.text.trim().isEmpty ||
        _titleController.text.trim().isEmpty ||
        _contentController.text.trim().isEmpty) {
      return;
    }
    final post = CommunityPost(
      author: _authorController.text.trim(),
      sessionId: UserSession.deviceSessionId,
      title: _titleController.text.trim(),
      content: _contentController.text.trim(),
      comments: [],
    );
    Navigator.pop(context, post);
  }

  @override
  void dispose() {
    _authorController.dispose();
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('글쓰기'),
        backgroundColor: const Color(0xFFF6F1F6),
        surfaceTintColor: Colors.transparent,
        foregroundColor: const Color(0xFF222222),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextField(
              controller: _authorController,
              readOnly: UserSession.isLoggedIn,
              decoration: InputDecoration(
                hintText: '닉네임',
                filled: true,
                fillColor: UserSession.isLoggedIn
                    ? const Color(0xFFEEEEEE)
                    : const Color(0xFFF7F4F8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: '제목',
                filled: true,
                fillColor: const Color(0xFFF7F4F8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _contentController,
              maxLines: 8,
              decoration: InputDecoration(
                hintText: '내용을 입력하세요',
                alignLabelWithHint: true,
                filled: true,
                fillColor: const Color(0xFFF7F4F8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 18),
            GestureDetector(
              onTap: _submit,
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFFFDD835),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Center(
                  child: Text(
                    '게시글 등록',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF5D4037),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ───────────────────────────────────────────
// 게시글 상세 페이지
// ───────────────────────────────────────────

class CommunityDetailPage extends StatefulWidget {
  final CommunityPost post;
  const CommunityDetailPage({super.key, required this.post});
  @override
  State<CommunityDetailPage> createState() => _CommunityDetailPageState();
}

class _CommunityDetailPageState extends State<CommunityDetailPage> {
  late CommunityPost _post;
  final TextEditingController _authorController = TextEditingController();
  final TextEditingController _commentController = TextEditingController();

  void _reportPost() {
    if (!UserSession.isLoggedIn) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('게시글 신고'),
        content: const Text('이 게시글을 신고하시겠어요?\n신고는 취소할 수 없어요.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _post.reportedBy.add(UserSession.email!);
                _post.reportCount++;
              });

              // TODO: 백엔드 연결 시 아래 주석 해제
              // await ApiService.reportPost(postId: _post.id, userEmail: UserSession.email!);

              LogService.log(
                action: 'report_post',
                detail: '게시글 신고: ${_post.title}',
                userEmail: UserSession.email,
              );

              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('신고가 접수되었어요.')));

              // 신고한 사람에게는 바로 목록에서 안 보이도록 돌아감
              Navigator.pop(context, _post);
            },
            child: const Text('신고', style: TextStyle(color: Color(0xFFE53935))),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _post = CommunityPost(
      author: widget.post.author,
      sessionId: widget.post.sessionId,
      title: widget.post.title,
      content: widget.post.content,
      comments: List.from(widget.post.comments),
      likes: widget.post.likes,
      isLiked: widget.post.isLiked,
    );
    if (UserSession.isLoggedIn) _authorController.text = UserSession.nickname!;
  }

  void _addComment() {
    if (_authorController.text.trim().isEmpty ||
        _commentController.text.trim().isEmpty) {
      return;
    }
    setState(() {
      _post.comments.add(
        CommunityComment(
          author: _authorController.text.trim(),
          content: _commentController.text.trim(),
        ),
      );
    });
    _authorController.clear();
    _commentController.clear();
  }

  @override
  void dispose() {
    _authorController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('게시글'),
        backgroundColor: const Color(0xFFF6F1F6),
        surfaceTintColor: Colors.transparent,
        foregroundColor: const Color(0xFF222222),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context, _post),
        ),
        actions: [
          if (UserSession.isLoggedIn && _post.canReport(UserSession.email!))
            IconButton(
              icon: const Text('🚨', style: TextStyle(fontSize: 20)),
              onPressed: _reportPost,
            ),
          if (UserSession.isLoggedIn && !_post.canReport(UserSession.email!))
            const Padding(
              padding: EdgeInsets.only(right: 12),
              child: Text('🚨', style: TextStyle(fontSize: 20)),
            ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              _post.title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFF222222),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _post.author,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFF888888),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _post.content,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF444444),
                height: 1.6,
              ),
            ),
            const SizedBox(height: 14),
            GestureDetector(
              onTap: () {
                setState(() {
                  if (_post.isLiked) {
                    _post.isLiked = false;
                    _post.likes--;
                  } else {
                    _post.isLiked = true;
                    _post.likes++;
                  }
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: _post.isLiked
                      ? const Color(0xFFFFEBEE)
                      : const Color(0xFFF7F4F8),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _post.isLiked
                        ? const Color(0xFFFFCDD2)
                        : const Color(0xFFEAEAEA),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _post.isLiked
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      size: 18,
                      color: _post.isLiked
                          ? const Color(0xFFE53935)
                          : const Color(0xFF777777),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '공감 ${_post.likes}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: _post.isLiked
                            ? const Color(0xFFE53935)
                            : const Color(0xFF555555),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              '댓글',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: Color(0xFF222222),
              ),
            ),
            const SizedBox(height: 10),
            if (_post.comments.isEmpty)
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F4F8),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Text(
                  '아직 댓글이 없어요. 첫 댓글을 남겨보세요!',
                  style: TextStyle(fontSize: 13, color: Color(0xFF777777)),
                ),
              ),
            ..._post.comments.map(
              (comment) => Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F4F8),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      comment.author,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF777777),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      comment.content,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF444444),
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFEAEAEA)),
              ),
              child: Column(
                children: [
                  TextField(
                    controller: _authorController,
                    readOnly: UserSession.isLoggedIn,
                    decoration: InputDecoration(
                      hintText: '닉네임',
                      filled: true,
                      fillColor: UserSession.isLoggedIn
                          ? const Color(0xFFEEEEEE)
                          : const Color(0xFFF7F4F8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _commentController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: '댓글을 입력하세요',
                      filled: true,
                      fillColor: const Color(0xFFF7F4F8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: _addComment,
                    child: Container(
                      width: double.infinity,
                      height: 46,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFDD835),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Text(
                          '댓글 등록',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF5D4037),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
