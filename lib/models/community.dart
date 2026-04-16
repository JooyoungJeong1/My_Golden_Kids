class CommunityPost {
  final String author;
  final String sessionId;
  final String title;
  final String content;
  final List<CommunityComment> comments;
  int likes;
  bool isLiked;
  int reportCount; // 신고 누적 수
  final List<String> reportedBy; // 신고한 유저 이메일 목록

  // 신고 3개 이상이면 숨김
  bool get isHidden => reportCount >= 3;

  CommunityPost({
    required this.author,
    required this.sessionId,
    required this.title,
    required this.content,
    required this.comments,
    this.likes = 0,
    this.isLiked = false,
    this.reportCount = 0,
    List<String>? reportedBy,
  }) : reportedBy = reportedBy ?? [];

  // 해당 유저가 신고 가능한지 확인
  bool canReport(String userEmail) => !reportedBy.contains(userEmail);
}

class CommunityComment {
  final String author;
  final String content;
  CommunityComment({required this.author, required this.content});
}
