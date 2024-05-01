

import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'FullScreenImagePage.dart';

class GalleryPage extends StatefulWidget {
  @override
  _GalleryPageState createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  TextEditingController _searchController = TextEditingController();
  List<dynamic> _images = [];
  int _page = 1;
  bool _loading = false;
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadImages();
    _searchController.addListener(_onSearchChanged);
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.offset >=
        _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      _loadMoreImages();
    }
  }

  Future<void> _loadImages({String query = ''}) async {
    setState(() {
      _loading = true;
    });
    final response = await http.get(
        Uri.parse('https://pixabay.com/api/?key=43669347-2a783daecaf14093832a8380f&q=$query&page=$_page&per_page=20'));
    if (response.statusCode == 200) {
      setState(() {
        _images.addAll(json.decode(response.body)['hits']);
        _loading = false;
      });
    } else {
      throw Exception('Failed to load images');
    }
  }

  void _onSearchChanged() {
    if (_searchController.text.isEmpty) return;
    _images.clear();
    _page = 1;
    _loadImages(query: _searchController.text);
  }

  void _loadMoreImages() {
    if (_loading) return;
    _page++;
    _loadImages(query: _searchController.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search images...',
          ),
        ),
      ),
      body: GridView.builder(
        controller: _scrollController,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: MediaQuery.of(context).size.width ~/ 200, // Adjust according to your preference
          crossAxisSpacing: 4,
          mainAxisSpacing: 4,
        ),
        itemCount: _images.length,
        itemBuilder: (context, index) {
          // if (index == _images.length - 1) {
          //   _loadMoreImages();
          // }
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      FullScreenImagePage(imageUrl: _images[index]['largeImageURL']),
                ),
              );
            },
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                CachedNetworkImage(
                  imageUrl: _images[index]['previewURL'],
                  placeholder: (context, url) => CircularProgressIndicator(),
                  errorWidget: (context, url, error) => Icon(Icons.error),
                  fit: BoxFit.cover,
                ),
                Container(
                  color: Colors.black54,
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Likes: ${_images[index]['likes']}',
                        style: TextStyle(color: Colors.white),
                      ),
                      Text(
                        'Views: ${_images[index]['views']}',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}