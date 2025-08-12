class MemoTopicModel {
  MemoTopicModel({
    this.header,
    this.url,
    this.postCount,
    this.followerCount,
    this.lastPost
  });

  final String? header;
  final String? url;
  final int? postCount;
  final int? followerCount;
  final String? lastPost;
}