class PostSearchResult {
  final String id;
  final String text;
  final String? image;
  final String authorName;

  PostSearchResult({
    required this.id,
    required this.text,
    this.image,
    required this.authorName,
  });

  factory PostSearchResult.fromJson(Map<String, dynamic> json) {
    return PostSearchResult(
      id: json['_id'],
      text: json['text'],
      image: json['image'],
      authorName: json['author']?['username'] ?? 'Unknown',
    );
  }
}
