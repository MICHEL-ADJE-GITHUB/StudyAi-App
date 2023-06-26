import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:study_ai/models/articles.dart';

import '../network/app_urls.dart';
import '../network/ko_exception.dart';

class ArticleProvider with ChangeNotifier {
  // List of al lthe created docuuments
  List<Article> _allArticles = [];

  List<Article> get allArticles {
    return [..._allArticles];
  }

  Future<void> initArticles(String interests) async {
    if (_allArticles.isEmpty) {
      await fetchOnlineArticles(interests);
    }
  }

  Future<List<Article>> fetchOnlineArticles(String interests) async {
    try {
      final response = await get(Uri.parse("${AppUrl.getArticles}$interests"));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        debugPrint("--- Response Data for docs : $data");
        final List<Article> docList = [];
        for (dynamic documents in data) {
          final doc = Article.fromJson(documents);
          docList.add(doc);
        }
        _allArticles = docList;
        notifyListeners();

        return docList;
      } else {
        throw Exception('Could not parse response.');
      }
    } on DioError catch (e) {
      if (e.response != null && e.response!.statusCode != null) {
        throw KoException(
          statusCode: e.response!.statusCode!,
          message: e.response!.data.toString(),
        );
      } else {
        throw Exception(e.message);
      }
    }
  }
}
