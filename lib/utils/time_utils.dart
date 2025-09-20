class TimeUtils {
  /// 작성 시간을 상대적 시간으로 변환
  /// 예: "방금 전", "5분 전", "2시간 전", "3일 전", "1달 전", "1년 전"
  static String getRelativeTime(DateTime createdAt) {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    // 1분 미만
    if (difference.inSeconds < 60) {
      return '방금 전';
    }

    // 1시간 미만
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}분 전';
    }

    // 1일 미만
    if (difference.inHours < 24) {
      return '${difference.inHours}시간 전';
    }

    // 1달 미만 (30일 기준)
    if (difference.inDays < 30) {
      return '${difference.inDays}일 전';
    }

    // 1년 미만 (365일 기준)
    if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '${months}달 전';
    }

    // 1년 이상
    final years = (difference.inDays / 365).floor();
    return '${years}년 전';
  }
}