class Article {
  final String? source;
  final String? author;
  final String? title;
  final String? description;
  final String? url;
  final String? urlToImage;
  final DateTime? publishedAt;
  final String? content;
  final String? state;

  Article({
    this.source,
    this.author,
    required this.title,
    this.description,
    required this.url,
    this.urlToImage,
    required this.publishedAt,
    this.content,
    this.state,
  });

  Map <String, dynamic> toJson() {
    return {
      'source': {'name': source},
      'author': author,
      'title': title,
      'description': description,
      'url': url,
      'urlToImage': urlToImage,
      'publishedAt': publishedAt?.toIso8601String(),
      'content': content,
      'state': state
    };
  }

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      source: json['source'] != null ? json['source']['name'] : null,
      author: json['author'],
      title: json['title'],
      description: json['description'],
      url: json['url'],
      urlToImage: json['urlToImage'],
      publishedAt: DateTime.parse(json['publishedAt']),
      content: json['content'],
      state: json['state'] ?? 'New',
    );
  }

  factory Article.fromMap(Map<String, dynamic> map) {
    return Article(
      source: map['source'] as String?,
      author: map['author'] as String?,
      title: map['title'] as String?,
      description: map['description'] as String?,
      url: map['url'] as String?,
      urlToImage: map['urlToImage'] as String?,
      publishedAt: DateTime.parse(map['publishedAt']) as DateTime?,
      content: map['content'] as String?,
      state: map['state'] as String?,
    );
  }
}