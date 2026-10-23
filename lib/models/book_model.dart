class Book {
  final String id;
  final String title;
  final String author;
  final double rating;
  final String coverUrl;
  final int totalPages;
  final String language;
  final List<String> chapters;
  final String description;
  final String content;

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.rating,
    required this.coverUrl,
    required this.totalPages,
    required this.language,
    required this.chapters,
    required this.description,
    required this.content,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'],
      title: json['title'],
      author: json['author'],
      rating: json['rating'].toDouble(),
      coverUrl: json['coverUrl'],
      totalPages: json['totalPages'],
      language: json['language'],
      chapters: List<String>.from(json['chapters']),
      description: json['description'],
      content: json['content'],
    );
  }
}
