import 'package:flutter/foundation.dart';
import '../../domain/repositories/voice_repository.dart';
import '../../domain/entities/recognized_food.dart';
import '../remote/gemini_voice_api.dart';

class VoiceRepositoryImpl implements VoiceRepository {
  final GeminiVoiceApi _api;

  VoiceRepositoryImpl({GeminiVoiceApi? api})
      : _api = api ?? GeminiVoiceApi();

  @override
  Future<RecognizedFood> parseTranscript(String transcript) async {
    if (transcript.trim().isEmpty) {
      throw Exception('Transcript cannot be empty');
    }

    try {
      debugPrint('[VoiceRepositoryImpl] 🔵 Parsing transcript: $transcript');
      
      final jsonData = await _api.parseFoodTranscript(transcript);
      
      final recognizedFood = RecognizedFood.fromJson(jsonData);
      
      debugPrint('[VoiceRepositoryImpl] ✅ Parsed food: $recognizedFood');
      
      return recognizedFood;
    } catch (e, stackTrace) {
      debugPrint('[VoiceRepositoryImpl] ❌ Error parsing transcript: $e');
      debugPrint('[VoiceRepositoryImpl] Stack trace: $stackTrace');
      rethrow;
    }
  }
}

