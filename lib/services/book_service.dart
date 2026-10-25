import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:inkflow/constants.dart';

class BookService {
  final String _apiKey = kGoogleBooksApiKey;

  Future<List<Map<String, dynamic>>> fetchBooks(String query) async {
    final String url =
        'https://www.googleapis.com/books/v1/volumes?q=$query&key=$_apiKey';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['items'] == null) {
        return [];
      }
      return (data['items'] as List).map((item) {
        final volumeInfo = item['volumeInfo'] ?? {};
        return {
          'title': volumeInfo['title'] ?? 'No Title',
          'authors': (volumeInfo['authors'] as List?)?.join(', ') ?? 'Unknown',
          'pageCount': volumeInfo['pageCount'] ?? 0,
          'description': volumeInfo['description'] ?? 'No Description',
          'thumbnail': volumeInfo['imageLinks']?['thumbnail'] ?? '',
        };
      }).toList();
    } else {
      throw Exception('Failed to load books: ${response.statusCode}');
    }
  }
}
