import 'package:flutter/material.dart';
import '../models/user_session.dart';
import '../services/api_service.dart';
import '../services/log_service.dart';
import 'my_page.dart';

// ───────────────────────────────────────────
// 커뮤니티 메인 페이지
// ───────────────────────────────────────────

class CommunityPage extends StatefulWidget {
  final int initialTab;
  const CommunityPage({super.key, this.initialTab = 0});
  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  late int _tabIndex;
  int _sortIndex = 0;
  List<dynamic> _posts = [];
  List<dynamic> _myPosts = [];
  List<dynamic> _myComments = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabIndex = widget.initialTab;
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final posts = await ApiService.getPosts();
      setState(() => _posts = posts);

      if (UserSession.isLoggedIn) {
        final myPosts = await ApiService.getMyPosts(userId: UserSession.userId);
        final myComments = await ApiService.getMyComments(
          userId: UserSession.userId,
        );
        setState(() {
          _myPosts = myPosts;
          _myComments = myComments;
        });
      }
    } catch (e) {
      debugPrint('데이터 로드 실패: $e');
    }
    setState(() => _isLoading = false);
  }

  List<dynamic> get _sortedPosts {
    final list = List<dynamic>.from(_posts);
    switch (_sortIndex) {
      case 1:
        list.sort((a, b) => (b['likes'] as int).compareTo(a['likes'] as int));
        break;
      case 2:
        list.sort(
          (a, b) => (b['comments'] as List).length.compareTo(
            (a['comments'] as List).length,
          ),
        );
        break;
      default:
        break; // 최신순은 서버에서 이미 정렬됨
    }
    return list;
  }

  bool _isMyPost(dynamic post) {
    if (UserSession.isLoggedIn && UserSession.userId != null) {
      return post['user_id'] == UserSession.userId;
    }
    return post['session_id'] == UserSession.deviceSessionId;
  }

  void _openWritePage() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const CommunityWritePage()),
    );
    if (result == true) _loadData();
  }

  void _openDetailPage(dynamic post) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => CommunityDetailPage(post: post)),
    );
    if (result == true) _loadData();
  }

  void _deletePost(dynamic post) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('게시글 삭제'),
        content: const Text('정말 삭제하시겠어요?\n삭제 후 복구할 수 없어요.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await ApiService.deletePost(
                  postId: post['id'],
                  userId: UserSession.userId,
                  sessionId: UserSession.deviceSessionId,
                );
                LogService.log(
                  action: 'delete_post',
                  detail: '게시글 삭제',
                  userEmail: UserSession.email,
                );
                _loadData();
              } catch (e) {
                debugPrint('삭제 실패: $e');
              }
            },
            child: const Text('삭제', style: TextStyle(color: Color(0xFFE53935))),
          ),
        ],
      ),
    );
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
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFFFDD835)),
              )
            : RefreshIndicator(onRefresh: _loadData, child: _buildBody()),
      ),
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

  Widget _buildSortButton(String label, int index) {
    final isSelected = _sortIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _sortIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF222222) : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : const Color(0xFF999999),
          ),
        ),
      ),
    );
  }

  Widget _buildPopularHighlight() {
    final visible = _posts
        .where((p) => ((p['views'] ?? 0) as int) >= 10)
        .toList();
    if (visible.isEmpty) return const SizedBox.shrink();
    visible.sort((a, b) => (b['views'] as int).compareTo(a['views'] as int));
    final popular = visible.first;

    return GestureDetector(
      onTap: () => _openDetailPage(popular),
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFFF8E1), Color(0xFFFFECB3)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFFFD54F), width: 1.5),
        ),
        child: Row(
          children: [
            const Text('🔥', style: TextStyle(fontSize: 24)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '지금 인기 게시글',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFF9A825),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    popular['title'],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF222222),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.favorite_rounded,
                        size: 13,
                        color: Color(0xFFE53935),
                      ),
                      const SizedBox(width: 3),
                      Text(
                        '${popular['likes']}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF999999),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.chat_bubble_outline_rounded,
                        size: 13,
                        color: Color(0xFF999999),
                      ),
                      const SizedBox(width: 3),
                      Text(
                        '${(popular['comments'] as List).length}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF999999),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Color(0xFFBBBBBB)),
          ],
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
    if (_tabIndex == 1) {
      if (!UserSession.isLoggedIn) return _buildLoginRequired();
      return _buildPostList(_myPosts);
    }
    if (_tabIndex == 2) {
      if (!UserSession.isLoggedIn) return _buildLoginRequired();
      return _buildCommentList(_myComments);
    }
    return _buildPostList(_sortedPosts, showPopular: true);
  }

  Widget _buildPostList(List<dynamic> posts, {bool showPopular = false}) {
    if (posts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _tabIndex == 1 ? '📝' : '💬',
              style: const TextStyle(fontSize: 40),
            ),
            const SizedBox(height: 12),
            Text(
              _tabIndex == 1 ? '아직 작성한 게시글이 없어요' : '게시글이 없어요',
              style: const TextStyle(fontSize: 14, color: Color(0xFF777777)),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        if (showPopular) _buildPopularHighlight(),
        Container(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: Row(
            children: [
              _buildSortButton('최신순', 0),
              _buildSortButton('공감순', 1),
              _buildSortButton('댓글순', 2),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];
              final isMine = _isMyPost(post);
              return GestureDetector(
                onTap: () => _openDetailPage(post),
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
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              post['title'],
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF222222),
                              ),
                            ),
                          ),
                          if (isMine)
                            GestureDetector(
                              onTap: () => _deletePost(post),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFEBEE),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  '삭제',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFFE53935),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        post['content'],
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
                            post['author'],
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF888888),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            '댓글 ${(post['comments'] as List).length}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF999999),
                            ),
                          ),
                          const Spacer(),
                          const Icon(
                            Icons.favorite_rounded,
                            size: 16,
                            color: Color(0xFFE53935),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${post['likes']}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF888888),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCommentList(List<dynamic> comments) {
    if (comments.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('💬', style: TextStyle(fontSize: 40)),
            SizedBox(height: 12),
            Text(
              '아직 작성한 댓글이 없어요',
              style: TextStyle(fontSize: 14, color: Color(0xFF777777)),
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: comments.length,
      itemBuilder: (context, index) {
        final comment = comments[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFEAEAEA)),
          ),
          child: Text(
            comment['content'],
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF444444),
              height: 1.5,
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
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  bool _isLoading = false;

  void _submit() async {
    if (_titleController.text.trim().isEmpty ||
        _contentController.text.trim().isEmpty) {
      return;
    }

    setState(() => _isLoading = true);
    try {
      await ApiService.createPost(
        authorNickname: UserSession.nickname ?? '익명',
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        userId: UserSession.userId,
        sessionId: UserSession.deviceSessionId,
      );
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      debugPrint('글쓰기 실패: $e');
    }
    setState(() => _isLoading = false);
  }

  @override
  void dispose() {
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
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFEEEEEE),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                UserSession.nickname ?? '익명',
                style: const TextStyle(fontSize: 14, color: Color(0xFF888888)),
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
              onTap: _isLoading ? null : _submit,
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFFFDD835),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: _isLoading
                      ? const CircularProgressIndicator(
                          color: Color(0xFF5D4037),
                        )
                      : const Text(
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
  final dynamic post;
  const CommunityDetailPage({super.key, required this.post});
  @override
  State<CommunityDetailPage> createState() => _CommunityDetailPageState();
}

class _CommunityDetailPageState extends State<CommunityDetailPage> {
  late Map<String, dynamic> _post;
  final TextEditingController _commentController = TextEditingController();
  bool _isLiked = false;

  @override
  void initState() {
    super.initState();
    _post = Map<String, dynamic>.from(widget.post);
  }

  bool get _isMyPost {
    if (UserSession.isLoggedIn && UserSession.userId != null) {
      return _post['user_id'] == UserSession.userId;
    }
    return _post['session_id'] == UserSession.deviceSessionId;
  }

  void _toggleLike() async {
    try {
      final result = await ApiService.toggleLike(
        postId: _post['id'],
        userId: UserSession.userId,
        sessionId: UserSession.deviceSessionId,
      );
      setState(() {
        _isLiked = result['liked'];
        _post['likes'] = result['likes'];
      });
    } catch (e) {
      debugPrint('좋아요 실패: $e');
    }
  }

  void _addComment() async {
    if (_commentController.text.trim().isEmpty) return;
    try {
      await ApiService.createComment(
        postId: _post['id'],
        authorNickname: UserSession.nickname ?? '익명',
        content: _commentController.text.trim(),
        userId: UserSession.userId,
        sessionId: UserSession.deviceSessionId,
      );
      _commentController.clear();
      // 댓글 목록 새로고침
      final posts = await ApiService.getPosts();
      final updated = posts.firstWhere(
        (p) => p['id'] == _post['id'],
        orElse: () => _post,
      );
      setState(() => _post = Map<String, dynamic>.from(updated));
    } catch (e) {
      debugPrint('댓글 작성 실패: $e');
    }
  }

  void _deletePost() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('게시글 삭제'),
        content: const Text('정말 삭제하시겠어요?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await ApiService.deletePost(
                postId: _post['id'],
                userId: UserSession.userId,
                sessionId: UserSession.deviceSessionId,
              );
              if (!mounted) return;
              Navigator.pop(context, true);
            },
            child: const Text('삭제', style: TextStyle(color: Color(0xFFE53935))),
          ),
        ],
      ),
    );
  }

  void _reportPost() {
    if (!UserSession.isLoggedIn) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('게시글 신고'),
        content: const Text('이 게시글을 신고하시겠어요?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await ApiService.reportPost(
                postId: _post['id'],
                reporterEmail: UserSession.email!,
              );
              if (!mounted) return;
              Navigator.pop(context, true);
            },
            child: const Text('신고', style: TextStyle(color: Color(0xFFE53935))),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final comments = (_post['comments'] as List?) ?? [];
    return Scaffold(
      appBar: AppBar(
        title: const Text('게시글'),
        backgroundColor: const Color(0xFFF6F1F6),
        surfaceTintColor: Colors.transparent,
        foregroundColor: const Color(0xFF222222),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context, true),
        ),
        actions: [
          if (_isMyPost)
            IconButton(
              icon: const Icon(
                Icons.delete_outline,
                size: 20,
                color: Color(0xFFE53935),
              ),
              onPressed: _deletePost,
            )
          else if (UserSession.isLoggedIn)
            IconButton(
              icon: const Text('🚨', style: TextStyle(fontSize: 20)),
              onPressed: _reportPost,
            ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              _post['title'],
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFF222222),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _post['author'],
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFF888888),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _post['content'],
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF444444),
                height: 1.6,
              ),
            ),
            const SizedBox(height: 14),
            GestureDetector(
              onTap: _toggleLike,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: _isLiked
                      ? const Color(0xFFFFEBEE)
                      : const Color(0xFFF7F4F8),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _isLiked
                        ? const Color(0xFFFFCDD2)
                        : const Color(0xFFEAEAEA),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _isLiked
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      size: 18,
                      color: _isLiked
                          ? const Color(0xFFE53935)
                          : const Color(0xFF777777),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '공감 ${_post['likes']}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: _isLiked
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
            if (comments.isEmpty)
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
            ...comments.map(
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
                      comment['author'],
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF777777),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      comment['content'],
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
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEEEEE),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        UserSession.nickname ?? '익명',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF888888),
                        ),
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
