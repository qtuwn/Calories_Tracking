import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../../domain/foods/food.dart';
import '../../../../domain/foods/food_repository.dart';

class VoiceMealService {
  final FoodRepository _foodRepository;

  VoiceMealService(this._foodRepository);

  String _normalizeTranscript(String transcript) {
    String normalized = transcript.toLowerCase().trim();
    
    final fillerWords = [
      'ngon',
      'alo',
      'à',
      'ạ',
      'ơi',
      'nha',
      'nhé',
      'đi',
      'thôi',
      'vậy',
      'thì',
      'là',
      'của',
      'một',
      'hai',
      'ba',
      'bốn',
      'năm',
      'sáu',
      'bảy',  
      'tám',
      'chín',
      'bị',
      'còn',
      'được', 
      'điều',
    ];
    
    for (final filler in fillerWords) {
      normalized = normalized.replaceAll(RegExp('\\b$filler\\b'), '');
    }
    
    normalized = normalized.replaceAll(RegExp('\\s+'), ' ').trim();
    
    return normalized;
  }

  Future<List<Food>> suggestFoodsForTranscript(String transcript) async {
    if (transcript.trim().isEmpty) {
      debugPrint('[VoiceMealService] ⚠️ Empty transcript, returning empty list');
      return [];
    }

    try {
      final normalizedQuery = _normalizeTranscript(transcript);
      debugPrint('[VoiceMealService] Normalized query="$normalizedQuery" (from transcript: "$transcript")');
      
      if (normalizedQuery.isEmpty) {
        debugPrint('[VoiceMealService] ⚠️ Normalized query is empty, returning empty list');
        return [];
      }

      final foodsStream = _foodRepository.search(normalizedQuery);
      
      final foods = await foodsStream.first.timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          debugPrint('[VoiceMealService] ⚠️ Food search timed out');
          return <Food>[];
        },
      );

      debugPrint('[VoiceMealService] Found ${foods.length} suggestions');
      
      return foods;
    } catch (e, stackTrace) {
      debugPrint('[VoiceMealService] ❌ Error suggesting foods: $e');
      debugPrint('[VoiceMealService] Stack trace: $stackTrace');
      return [];
    }
  }
}

