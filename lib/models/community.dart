class CommunityPost {
  final String author;
  final String sessionId;
  final String title;
  final String content;
  final List<CommunityComment> comments;
  int likes;
  bool isLiked;
  int reportCount;
  final List<String> reportedBy;
  int views;

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
    this.views = 0,
  }) : reportedBy = reportedBy ?? [];

  bool canReport(String userEmail) => !reportedBy.contains(userEmail);
}

class CommunityComment {
  final String author;
  final String content;
  CommunityComment({required this.author, required this.content});
}
