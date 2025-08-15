class MemoModelCreator {
  MemoModelCreator({
    this.name,
    this.created,
    this.lastActionDate,
    this.id,
    this.followerCount,
    this.actions,
    this.profileText
    // this.img128px
  });

  String? name;
  final String? created;
  final String? lastActionDate;
  final String? id;
  String? profileText;
  final int? followerCount;
  final int? actions;
  // final String? img128px; https://memo.cash/img/profilepics/17ZY9npgMXstBGXHDCz1umWUEAc9ZU1hSZ-128x128.jpg?id=6312
}