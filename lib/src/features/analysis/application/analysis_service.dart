import 'package:flutter/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'analysis_service.g.dart';

class AnalysisResult {
  final int wordCount;
  final int readingTimeMinutes;
  final String readingLevel;
  AnalysisResult({
    required this.wordCount,
    required this.readingTimeMinutes,
    required this.readingLevel,
  });
}

class AnalysisService {
  Set<String> _daleChallWords = {};
  Future<void> initialize() async {
    final wordString = await rootBundle.loadString('assets/data/dale-chall.txt');
    _daleChallWords = wordString.split('\n').map((e) => e.trim().toLowerCase()).toSet();
  }
  AnalysisResult analyze(String text) {
    final wordCount = _calculateWordCount(text);
    if (wordCount == 0) {
      return AnalysisResult(wordCount: 0, readingTimeMinutes: 0, readingLevel: 'N/A');
    }
    final readingTime = (wordCount / 200).ceil(); 
    final readingLevel = _calculateDaleChall(text);
    return AnalysisResult(
      wordCount: wordCount,
      readingTimeMinutes: readingTime,
      readingLevel: readingLevel,
    );
  }
  int _calculateWordCount(String text) => text.split(RegExp(r'\s+')).where((s) => s.isNotEmpty).length;
  int _countSentences(String text) {
    if (text.isEmpty) return 0;
    final sentenceEndings = RegExp(r'[.!?]+(\s|$)');
    final count = sentenceEndings.allMatches(text).length;
    return count > 0 ? count : 1;
  }
  int _countDifficultWords(String text) {
    final words = text.toLowerCase().split(RegExp(r'[^a-zA-Z]+')).where((s) => s.isNotEmpty);
    return words.where((word) => !_daleChallWords.contains(word)).length;
  }
  String _calculateDaleChall(String text) {
    final wordCount = _calculateWordCount(text);
    if (wordCount < 100) {
      return 'Below 4th grade'; 
    }
    final sentenceCount = _countSentences(text);
    final difficultWords = _countDifficultWords(text);
    final pDw = (difficultWords / wordCount) * 100;
    final asl = wordCount / sentenceCount;
    double score = (0.1579 * pDw) + (0.0496 * asl);
    if (pDw > 5) {
      score += 3.6365;
    }
    if (score <= 4.9) return '4th grade and below';
    if (score <= 5.9) return '5th–6th grade';
    if (score <= 6.9) return '7th–8th grade';
    if (score <= 7.9) return '9th–10th grade';
    if (score <= 8.9) return '11th–12th grade';
    if (score <= 9.9) return 'College';
    return 'College graduate';
  }
}

@riverpod
Future<AnalysisService> analysisService(Ref ref) async {
  final service = AnalysisService();
  await service.initialize();
  return service;
}
