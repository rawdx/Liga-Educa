class NewsItem {
  final String id;
  final String imagePath;
  final String tag;
  final String timeAgo;
  final String title;
  final String description;
  final String author;
  final String? content;

  const NewsItem({
    required this.id,
    required this.imagePath,
    required this.tag,
    required this.timeAgo,
    required this.title,
    required this.description,
    required this.author,
    this.content,
  });

  factory NewsItem.fromJson(Map<String, dynamic> json) {
    return NewsItem(
      id: json['id'] as String,
      imagePath: json['imagePath'] as String,
      tag: json['tag'] as String,
      timeAgo: json['timeAgo'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      author: json['author'] as String,
      content: json['content'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'imagePath': imagePath,
      'tag': tag,
      'timeAgo': timeAgo,
      'title': title,
      'description': description,
      'author': author,
      'content': content,
    };
  }
}
