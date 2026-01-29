class Phrase {
  final String title;
  final String text;
  final String author;

  const Phrase({required this.title, required this.text, required this.author});

  factory Phrase.fromJson(Map<String, dynamic> json) => Phrase(
        title: (json['title'] ?? '').toString(),
        text: (json['text'] ?? '').toString(),
        author: (json['author'] ?? '').toString(),
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Phrase &&
          runtimeType == other.runtimeType &&
          title == other.title &&
          text == other.text &&
          author == other.author;

  @override
  int get hashCode => title.hashCode ^ text.hashCode ^ author.hashCode;
}
