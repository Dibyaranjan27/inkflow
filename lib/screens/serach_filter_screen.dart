import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:inkflow/screens/details_screen.dart';
import 'package:http/http.dart' as http;

class SearchResultsScreen extends StatelessWidget {
  final String query;

  SearchResultsScreen({required this.query});

  Future<List<dynamic>> _fetchBooks(String query) async {
    final String apiKey =
        'AIzaSyDJN3_7ORDyMtHvDClxxAAQtsH2TlAlSxc'; // Replace with your Google Books API key
    final String url =
        'https://www.googleapis.com/books/v1/volumes?q=$query&key=$apiKey';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['items'] ?? [];
    } else {
      throw Exception('Failed to load books');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search Results'),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _fetchBooks(query),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No books found.'));
          }

          final books = snapshot.data!;

          return ListView.builder(
            itemCount: books.length,
            itemBuilder: (context, index) {
              final book = books[index]['volumeInfo'];
              return ListTile(
                title: Text(book['title'] ?? 'No Title'),
                subtitle: Text(book['authors']?.join(', ') ?? 'Unknown Author'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetailsScreen(book),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
