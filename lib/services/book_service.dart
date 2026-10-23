import 'dart:convert';
import 'package:http/http.dart' as http;

class BookService {
  final String _apiKey = 'AIzaSyDJN3_7ORDyMtHvDClxxAAQtsH2TlAlSxc';

  Future<List<Map<String, dynamic>>> fetchBooks(String query) async {
    final String url =
        'https://www.googleapis.com/books/v1/volumes?q=$query&key=$_apiKey';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return (data['items'] as List).map((item) {
        final volumeInfo = item['volumeInfo'];
        return {
          'title': volumeInfo['title'] ?? 'No Title',
          'authors': volumeInfo['authors']?.join(', ') ?? 'Unknown',
          'pageCount': volumeInfo['pageCount'] ?? 0,
          'description': volumeInfo['description'] ?? 'No Description',
          'thumbnail': volumeInfo['imageLinks']?['thumbnail'] ?? '',
        };
      }).toList();
    } else {
      throw Exception('Failed to load books');
    }
  }
}
